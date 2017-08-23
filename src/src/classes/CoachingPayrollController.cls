/*********************************************
@Author: Steven M. Giangrasso
@Description: There is a single object that underlies the 1-1 Coaching widget (label=1-1 Coaching, 
api name=one_one_Coaching__c), the goal would be to show the last 5 1-1 Coaching records 
from the selected Payroll Cycle (End) date, 
which means this date would be cached (i.e. as a filter event) for use if/when a single Sales Rep is selected. 
For now, displaying the hyperlinked name (i.e. URL to the detail record in a new tab) would be a great start. 
If the hyperlink can, instead, pop up the detail record in a modal dialog, even better, but not essential.
@Date: 5/17/2017
ModifiedDate- 7/7/2017  
ModifiedBy- Radhika Bansal
Description- To show the records based on XSP selected
* @Last modified By: Amit Kumar Pradhan, Accenture
* @Last modified Date: 31-July-2017 
* @Description : passing userdetails, coachingid information in wrapper 
* @User Story : US1141906(Coach/Wave App - Coaching Lightning Component - Create new 1:1 Coaching)
*********************************************/
public class CoachingPayrollController{
    
    private static final String NO_RECORDS_FOUND = 'No_records_found';
    private static final String ONLY_SUBORDINATES = 'only_view_records_of_subordinate';
    private static final String NO_COACHING_FOUND = 'No_coaching_records_found';
    private static final String SYS_EXCEPTION = 'system_exception';
	private static final String SELECT_ONLY_ONE = 'select_only_one_user';    
    private static final String FILTER_BY_ONE = 'X_Filter_By_One';
    /*
    * Wrapper to return values for whether user is under the logged in user and the coaching records.
    */
    public class CoachingWrapper{
        @AuraEnabled
        public Boolean validUser = false;
        @AuraEnabled
        public Boolean isRep = false;
        @AuraEnabled
        public String coachingId = '';
        @AuraEnabled
        public String errorMsg = '';
        @AuraEnabled
        public User userInfo = new User();
        @AuraEnabled
        public List<one_one_Coaching__c> oneOneCoachingList = new List<one_one_Coaching__c>();
        public CoachingWrapper(boolean validUser, Boolean isRep, String coachingId, 
                               String errorMsg, User userInfo, List<one_one_Coaching__c> oneOneCoachingList){            
            this.validUser = validUser;
            this.isRep = isRep;
            this.coachingId = coachingId;
            this.errorMsg = errorMsg;
            this.userInfo = userInfo;
            this.oneOneCoachingList = oneOneCoachingList;
        } 
    }
    
    /******
    * @MethodName: checkUserAndCoaching
    * @Author: Radhika Bansal, Accenture
    * @Description: This method is used to check whether the user comes under logged in user 
                    or not and then send one one coaching records
    * @Return: Return wrapper object
    * @Last modified By: Amit Kumar Pradhan, Accenture
    * @Last modified Date: 31-July-2017 
    * @Description : passing userdetails, coachingid information in wrapper 
    * @User Story : US1141906(Coach/Wave App - Coaching Lightning Component - Create new 1:1 Coaching)
    *******/    
    @AuraEnabled
    public static CoachingWrapper checkUserAndCoaching(String pernrID){
        CoachingWrapper wrapperObj;     
        
        
        try{
            List<User> selectedUser = [SELECT Id, Name, ManagerId, Manager.Name, PERNR__c FROM User 
                                       WHERE PERNR__c =: pernrID 
                                       AND (ManagerId =: UserInfo.getUserId()
                                       OR Id = :UserInfo.getUserId()) LIMIT 1];
            if(!selectedUser.isEmpty()){
                //Setting isRep boolean variable to find out logged in user is a Rep/Manager
                Boolean isRep = false;
                if(selectedUser[0].Id == UserInfo.getUserId()){
                    isRep = true;
                }else if(selectedUser[0].Id != null && selectedUser[0].ManagerId == UserInfo.getUserId()){
                    isRep = false;
                }else{}

                
                //Query the last 5 one one Coaching Records
                List<one_one_Coaching__c> oneOneCoachingRecords = getOneOneCoachingList(selectedUser[0].Id);
                
                if(!oneOneCoachingRecords.isEmpty()){
                    wrapperObj = new CoachingWrapper(true, isRep, oneOneCoachingRecords[0].coaching__c, 
                                                     null, selectedUser[0], oneOneCoachingRecords);
                }else{
                    //Fetching Coaching Record between Manager And Selected User
                    List<WorkCoaching> coachingRecord = 
                        [SELECT Id, CoachId FROM WorkCoaching 
                         WHERE CoachedId =: selectedUser[0].Id 
                         AND CoachId=:selectedUser[0].ManagerId
                         ORDER BY CreatedDate DESC LIMIT 1];
                    
                    if(!coachingRecord.isEmpty()){
                        if(isRep){
                            wrapperObj = new CoachingWrapper(true, isRep, coachingRecord[0].Id,
                                                             ErrorMessages.getErrorMessage(NO_RECORDS_FOUND), selectedUser[0], null);
                        }
                        else{
                            if(coachingRecord[0].CoachId == UserInfo.getUserId()){
                                wrapperObj = new CoachingWrapper(true, isRep, coachingRecord[0].Id,
                                                             ErrorMessages.getErrorMessage(NO_RECORDS_FOUND), selectedUser[0], null);
                            } else{
                            	wrapperObj = new CoachingWrapper(true, isRep, coachingRecord[0].Id, ErrorMessages.getErrorMessage(ONLY_SUBORDINATES), selectedUser[0], null);
                            }
                        }
                    }else{
                        wrapperObj = new CoachingWrapper(true, isRep, null,ErrorMessages.getErrorMessage(NO_COACHING_FOUND), selectedUser[0], null);
                    }                                                       
                }
            }else{      
                wrapperObj = new CoachingWrapper(false, false, null,ErrorMessages.getErrorMessage(ONLY_SUBORDINATES), null, null);
            }
        }catch(Exception e){  wrapperObj = new CoachingWrapper(false, false, null, ErrorMessages.getErrorMessage(SYS_EXCEPTION), null, null);
        }
        return wrapperObj;
    }
   
    /***************************************
    * @MethodName: getErrorsFromCustomMetaData(AuraEnabled)
    * @Auther : Malay Desai, Accenture
    * @Date : 28-July-2017 
    * @Description : Method to return information of the specific coaching record selected by 
                    the User in Lightning component 
    * @User Story : US1142567
    * @Param : null
    * @Return : String
    *****************************************/
    @AuraEnabled
    public static List<String> getErrorsFromCustomMetaData(){
        
        return new List<String>{ErrorMessages.getErrorMessage(SELECT_ONLY_ONE),
            ErrorMessages.getErrorMessage(FILTER_BY_ONE)};
    }
    
    /***************************************
    * @MethodName: getLatestFiveOneOneCoachings(AuraEnabled)
    * @Auther : Amit Kumar Pradhan, Accenture
    * @Date : 31-July-2017 
    * @Description : Method to return latest 5 one one coaching records in Lightning component 
    * @User Story : US1141906(Coach/Wave App - Coaching Lightning Component - Create new 1:1 Coaching)
    * @Param : String
    * @Return : List<one_one_Coaching__c>
    *****************************************/
    @AuraEnabled
    public static List<one_one_Coaching__c> getLatestFiveOneOneCoachings(String coachedId){
        return getOneOneCoachingList(coachedId);
    }
    
    /***************************************
    * @MethodName: getOneOneCoachingList
    * @Auther : Amit Kumar Pradhan, Accenture
    * @Date : 31-July-2017 
    * @Description : Query the last 5 one one Coaching Records 
    * @User Story : US1141906(Coach/Wave App - Coaching Lightning Component - Create new 1:1 Coaching)
    * @Param : String
    * @Return : List<one_one_Coaching__c>
    *****************************************/
    public static List<one_one_Coaching__c> getOneOneCoachingList(String coachedId){
        return [SELECT Manager_Comments__c, Status__c, Name, coaching__c FROM one_one_Coaching__c 
                    WHERE  coaching__r.CoachedId =: coachedId ORDER BY CreatedDate DESC LIMIT 5];
    }
        
    /***************************************
    * @MethodName: getCoachingDetails
    * @Auther : Radhika Bansal, Accenture
    * @Date : 25-July-2017 
    * @Description : Method to return information of the specific coaching record selected by 
                    the User in Lightning component 
    * @Param : String
    * @Return : one_one_Coaching__c
    *****************************************/
    @AuraEnabled
    public static one_one_Coaching__c getCoachingDetails(String recordId){
        return [SELECT CreatedDate,Name, ID, Action_Plan__c, Opportunities__c, 
                Manager_Comments__c, Status__c, Strengths__c FROM one_one_Coaching__c
                WHERE id = :recordId];
    }
        
}