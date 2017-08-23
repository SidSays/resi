/**********************************************************
* Page Name: WalkalongUtilsReadOnly
* Author: Ashish Sonawane, Accenture
* Date: 21-March-2016 
* Description: Use to show walkalong in readonly mode to users  
* Last Modified by:Revan Kumar
* Last Modified by/Date/Description: Animesh Datta, 03-March-2017. Added changes to in corporate Private Notes in Completed Observation Form
* Last Modified by/Date: Animesh Datta, 23-March-2017. Modified so that CAR Director/CAR Manager can see submitted Field Observation (US945250)
* Last Modified by/Date: Amit Pradhan and Animesh Datta, 24-March-2017. Modified so that CAR Director can perform both Super Coach Observation(For reporting CAR Manager) and CAR Event, Property Visit(For reporting CAR) Observation
* Last Modified by/Date: Animesh, 28-April-2017. Adding check for retails sales rep to extend chatter post functionality for Indirect Channel-  SP53 - US1094059
* Last Modified by/Date: Shalaka Kadwade, 10-May-2017. Added space after Feedback about for string FEEDBACK_ABOUT as part of defect fix of DE181134.
***********************************************************/
global class WalkalongUtilsReadOnly{   
    public boolean flag {get; set;}
    private static final String AREAOF_FOCUS_NOTES = 'Area of Focus - Notes';
    private static final String XFINITY_SALES_EXECUTIVE_PERMISSION = 'Xfinity_Sales_Executive';
    global static string strNotesVal {get;set;}   
    global static string sfdcIFrameHost = 'sfdcIFrameHost';
    global static string sfdcIFrameOrigin = 'sfdcIFrameOrigin';
    global static string retURL = 'retURL';
    global static string projectone = 'projectone';
    global static string isdtp = 'isdtp';
    global static string p1Val = 'p1';
    global static string MultipleChoice = 'MultipleChoice';
    global static string FreeText = 'FreeText'; 
    global string subject{get;set;}
    global String feedback{get;set;}
    private static final String feedbackDuration = System.Label.WalkAlongFeedbackDuration;
    private static final String HYPHEN_STR = ' - ';
    private static final String FORWARD_SLASH_STR = '/';
    private static final String SUBJECTID_STR = 'SubjectId';
    private static final String FEEDBACKID_STR = 'FeedbackId';
    private static final String FEEDBACK_ABOUT = 'Feedback about '; //DE181134 Added space after Feedback about
    private static final String SPACE_STR = ' ';
    private static final string OBSERVATION_PROFILE_CHECK = 'CompletedObservationProfiles';//US1133821: Kiran Changes
    private static final string COMMA_SEPARATION = ',';//US1133821: Kiran Changes
    global WalkalongUtilsReadOnly(){
        subject = System.currentPageReference().getParameters().get(SUBJECTID_STR);
        feedback = System.currentPageReference().getParameters().get(FEEDBACKID_STR);
    }
    
    //Wrapper class for Rep Details
    global class Xsp{
        public String name {get; set;}
        public Boolean xspLogin{get;set;}
        public Boolean isCarMgr{get;set;}
        public Id id {get; set;} 
        public Xsp(String name, Id id, boolean isXspLogin, boolean isCarMgr){
            this.name = name;
            this.id = id;
            this.xspLogin = isXspLogin;
            this.isCarMgr = isCarMgr;
        }       
    }
    
    //Wrapper class for Submitted Feedback  Details
    global class XspFeedback{
        public String XspFeedbackName{get; set;}
        public Id id {get; set;} 
        public XspFeedback(String name,Id id){
            this.XspFeedbackName=name;
            this.id=id;
        }       
    }
   
    /****************************************************
    * @Description: This method determines if this is SF1 app or not
    * @Author: Pranjal Singh, Accenture
    * @Param: None
    * @Return: Boolean
    *****************************************************/
      public Boolean getSF1(){
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get(sfdcIFrameHost)) ||
            String.isNotBlank(ApexPages.currentPage().getParameters().get(sfdcIFrameOrigin)) ||
            ApexPages.currentPage().getParameters().get(isdtp) == p1Val ||
            (ApexPages.currentPage().getParameters().get(retURL) != null && ApexPages.currentPage().getParameters().get(retURL).contains(projectone) )
        ){
            flag=true;
        }else{
            flag=false;
        }
        return flag;
    }
    
    
    @RemoteAction
    global static string fetchSubject(string strSubjectId) {
        return strSubjectId;
    }
    
    @RemoteAction
    global static String fetchFeedback(String strFeedbackId) {
        return strFeedbackId;
    }
    
    /****************************************************
    * @Description: This method is for geting Rep List for completed Observation Form
    * @Author: Ashish Sonawane, Accenture
    * @Date: 21-March-2016 
    * @Param: None
    * @Return: List<Xsp>
    * @Last Modified By : Kiran Kumar 
    * @Last Modified Data : 28nd June 2017
    * @Description :  XC Manager or CAR/XC Regional Lead who's coaching an Xfinity CAR Manager, should be able to view his completed Observations.
    * @User Story : US1133821(Coach for CAR Leaders - XC Manager Can't See Completed Observation)
    *****************************************************/
     @RemoteAction
    global static List<Xsp> getXSPList(){
        List<Xsp> xspList = new List<Xsp>();
        
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> carMgrPSAList = new List<PermissionSetAssignment>();
        String profileName = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()][0].Profile.Name; 
        
        //Check logged in User is a XSE(XSP User with XfinitySalesExecutive permission set) User or XSP User
        if(profileName.equalsIgnoreCase(System.Label.DSRProfileName)){
            List<PermissionSet> xsePermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name =: XFINITY_SALES_EXECUTIVE_PERMISSION Limit 1];
            if(!xsePermissionSet.isEmpty()){
                psaList = [SELECT Id, Assignee.Name, AssigneeId FROM PermissionSetAssignment 
                                  WHERE PermissionSetId =: xsePermissionSet[0].Id and AssigneeId=:UserInfo.getUserId() Limit 1];
            }                     
        }      
        //Check logged in User is a Car Director(Car Manager User with "Coach - CAR Director/Manager" permission set) User 
        if(profileName.equalsIgnoreCase(System.Label.Profile_Name_CAR_Manager)){
            List<PermissionSet> carDirectorPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name =: Label.CAR_Director_Senior_Manager_Permission Limit 1];
            if(!carDirectorPermissionSet.isEmpty()){
                carMgrPSAList = [SELECT Id, Assignee.Name, AssigneeId FROM PermissionSetAssignment 
                                  WHERE PermissionSetId =: carDirectorPermissionSet[0].Id and AssigneeId=:UserInfo.getUserId() Limit 1];
            }
        }     
        // US1133821: Kiran Changes Starts
        Set<String> ObservationListOfProfilesSet = new Set<String>();
        Variable_Setting__c ObservationListOfProfiles = Variable_Setting__c.getInstance(OBSERVATION_PROFILE_CHECK);
        if(OBSERVATION_PROFILE_CHECK!= null){
            ObservationListOfProfilesSet.addAll(ObservationListOfProfiles.Value__c.split(COMMA_SEPARATION));//Splited by comma separate and add in a set for profile check
        }     
        // US1133821: Kiran Changes Ends 
        if(profileName.equalsIgnoreCase(label.Profile_Name_RSM)
                || !carMgrPSAList.isEmpty()){             
            for(User userObj : [SELECT Id, Name FROM User WHERE ManagerId=:UserInfo.getUserId() AND IsActive=true 
                                AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, false));
            }
        }
        else if((profileName.equalsIgnoreCase(System.Label.DSRProfileName) && !psaList.isEmpty())){
            for(User userObj : [SELECT Id, Name FROM User 
                                WHERE (ManagerId=:UserInfo.getUserId() OR Manager.ManagerId=:UserInfo.getUserId() OR Id =:UserInfo.getUserId()) 
                                AND IsActive = true AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, false));
            }
        }
        else if(profileName.equalsIgnoreCase(label.Profile_Name_ASM)){
            for(User userObj : [SELECT Id, Name FROM User 
                                WHERE (ManagerId=:UserInfo.getUserId() OR Manager.ManagerId=:UserInfo.getUserId() OR Id =: UserInfo.getUserId()) 
                                AND IsActive = true AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, false));
            }
        }
        else if(profileName.equalsIgnoreCase(label.Profile_Name_SDM)){
            for(User userObj : [SELECT Id, Name FROM User 
                                WHERE (ManagerId=:UserInfo.getUserId() OR Manager.ManagerId =: UserInfo.getUserId() OR Id =:UserInfo.getUserId()) 
                                AND IsActive = true AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, false));
            }
        }
        else if(profileName.equalsIgnoreCase(label.Profile_Name_DSD)){
            for(User userObj : [SELECT Id, Name FROM User 
                                WHERE (ManagerId=:UserInfo.getUserId() OR Manager.ManagerId =: UserInfo.getUserId() OR Manager.Manager.ManagerId=:UserInfo.getUserId()) 
                                AND IsActive = true AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, false));
            }
        }
        else if(profileName.equalsIgnoreCase(label.Profile_Name_CAR_Manager)){
            xspList.add(new Xsp(UserInfo.getName(),UserInfo.getUserId(),true, true));
            for(User userObj : [SELECT Id, Name FROM User 
                                WHERE ManagerId =: UserInfo.getUserId() AND IsActive=true 
                                AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, true));
            } 
        //US1133821: Kiran Changes Starts
        }else if(!ObservationListOfProfilesSet.isempty() && ObservationListOfProfilesSet.contains(profileName)){
            xspList.add(new Xsp(UserInfo.getName(),UserInfo.getUserId(),true, true));
            for(User userObj : [SELECT Id, Name FROM User 
                                WHERE ManagerId =: UserInfo.getUserId() AND IsActive=true 
                                AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, true));
            } 
        //US1133821: Kiran changes Ends
        }else if(profileName.equalsIgnoreCase('Retail Store Manager')){             
            for(User userObj : [SELECT Id, Name FROM User WHERE ManagerId =: UserInfo.getUserId() AND IsActive=true 
                                AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, false));
            }        
        }else{
            xspList.add(new Xsp(UserInfo.getName(),UserInfo.getUserId(),true, false));
        }                       
        return xspList;
    }
  
    /****************************************************
    * @Description: This method is for geting submitted FeedBackRequest List for completed Observation Form
    * @Author: Ashish Sonawane, Accenture
    * @Date: 21-March-2016 
    * @Param: String
    * @Return: List<XspFeedback>
    *****************************************************/
     @RemoteAction
    global static List<XspFeedback> getXspFeedbackData(String subjectId){
        List<XspFeedback> xspFeedbackList = new List<XspFeedback>();
        Integer duration = 0;
        if(feedbackDuration!=null && feedbackDuration.length()>0) {
             duration = Integer.valueOf(feedbackDuration.trim());
        }            
        String query =  'Select Id, PerformanceCycle.RecordType.Name, Name, SubmittedDate  FROM WorkFeedbackRequest WHERE SubjectId =:subjectId and FeedbackRequestState=\'Submitted\' AND CreatedDate = LAST_N_DAYS:'+duration +'order by SubmittedDate  DESC';
        List<WorkFeedBackRequest> lstFeedBackRequest = database.query(query); 
        String strPerRecType;
        for(WorkFeedbackRequest feedback : lstFeedBackRequest){           
            if(feedback.PerformanceCycle.RecordType.Name.equals(Label.XSP_Ridealong)){
                 xspFeedbackList.add(new XspFeedback(feedback.Name + HYPHEN_STR + feedback.SubmittedDate.Month() + FORWARD_SLASH_STR +feedback.SubmittedDate.Day()+FORWARD_SLASH_STR+feedback.SubmittedDate.Year(),feedback.Id));
            }
            else{
                 strPerRecType = feedback.PerformanceCycle.RecordType.Name;
                 xspFeedbackList.add(new XspFeedback(feedback.Name + HYPHEN_STR + strPerRecType + HYPHEN_STR + feedback.SubmittedDate.Month()+FORWARD_SLASH_STR+feedback.SubmittedDate.Day()+FORWARD_SLASH_STR+feedback.SubmittedDate.Year(),feedback.Id));    
            }           
        }
        return xspFeedbackList;  
    }
    
    /****************************************************
    * @Description: This method is for geting submitted Observation data for selected FeedBackRequest for completed Observation Form
    * @Author: Ashish Sonawane, Accenture
    * @Date: 21-March-2016 
    * @Param: String
    * @Return: WalkalongUtilsReadOnly.WalkAlongData
    *****************************************************/    
    @RemoteAction
    global static WalkalongUtilsReadOnly.WalkAlongData getFeedbackForXsp(String workFeedbackId){
        List<WorkFeedbackRequest> wfrList = new List<WorkFeedbackRequest> ();
        List<PermissionSetAssignment> carMgrPSAList = new List<PermissionSetAssignment>(); 
        //adding field Field_Observation_Feedback_Request__c in query for Completed Field Observation (US945250 - Sprint 50)
        wfrList = [SELECT Id, SelectedProperty__c, Related_1_1_Coaching__r.Name, Huddle_Id__c, Huddle_Name__c, Field_Observation_Feedback_Request__c, 
                    LastModifiedDate, PerformanceCycle.RecordType.Name, SubmittedDate, SubjectId, PerformanceCycle.Name, Score__c, 
                    Recipient.Name, RecipientId, Subject.Name, QuestionSetId, Private_Notes__c, Transaction_types__c FROM WorkFeedbackRequest 
                    WHERE id =: workFeedbackId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];  
        //List<WorkFeedbackQuestion> wfrFeedBackQuestion = new List<WorkFeedbackQuestion> ();
        WalkalongUtilsReadOnly.WalkAlongData data = new WalkalongUtilsReadOnly.WalkAlongData();
        if(wfrList.size()== 1){            
            if(UserInfo.getUserId() == wfrList[0].RecipientId){
                data.isPrivateNotesVisible = true;
            }
            else{
                data.isPrivateNotesVisible = false;
            }
            
            //Check logged in User is a Car Director(Car Manager User with "Coach - CAR Director/Manager" permission set) User            
            List<PermissionSet> carDirectorPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name =: Label.CAR_Director_Senior_Manager_Permission Limit 1];
            if(!carDirectorPermissionSet.isEmpty()){
                carMgrPSAList = [SELECT Id, Assignee.Name, AssigneeId FROM PermissionSetAssignment 
                                  WHERE PermissionSetId =: carDirectorPermissionSet[0].Id and AssigneeId=:UserInfo.getUserId() Limit 1];
            }                     
           
            if(!carMgrPSAList.isEmpty()){
                data.isCarDirector = true;
            }else{
                data.isCarDirector = false;
            }
            String strXSPWalk;
            //wfrFeedBackQuestion = [SELECT Id, Name FROM WorkFeedbackQuestion WHERE QuestionSetId=:wfrList[0].QuestionSetId];
            //data.selectedXSP = xspUserId;
            strXSPWalk = wfrList[0].PerformanceCycle.RecordType.Name;
            data.peformanceCycle = wfrList[0].PerformanceCycle.Name;
            data.feedbackFrom = wfrList[0].Recipient.Name;
            data.feedbackTo = wfrList[0].Subject.Name;
            data.submittedDate = wfrList[0].SubmittedDate.Month() + FORWARD_SLASH_STR + wfrList[0].SubmittedDate.Day() + FORWARD_SLASH_STR+wfrList[0].SubmittedDate.Year();
            data.score = wfrList[0].Score__c; 
            data.requestId=wfrList[0].Id;
            data.lastSavedDate=wfrList[0].LastModifiedDate.format();
            data.showNotes=false;
            data.selectedXSP=wfrList[0].SubjectId;
            data.propList = wfrList[0].SelectedProperty__c;
            data.privateNotes = wfrList[0].Private_Notes__c;
            
            if(wfrList[0].Transaction_types__c != null){
                data.transactionTypes = getTransactionTypes();
                data.selectedTransactionTypes = wfrList[0].Transaction_types__c;
            }
           
            if(wfrList[0].Huddle_Id__c != null){
                Task huddleTask = [SELECT Id, Subject, CreatedDate FROM Task WHERE Id =: wfrList[0].Huddle_Id__c Limit 1];
                String huddleDate = String.ValueOf(huddleTask.CreatedDate);
                if(huddleTask.Subject != ''){
                    data.huddleActivity = huddleTask.Subject+ HYPHEN_STR +huddleDate;
                }
            }
            if(wfrList[0].Related_1_1_Coaching__r.Name != null){
                data.oneOnOneCoachingActivity = wfrList[0].Related_1_1_Coaching__r.Name;
            }
            
            //Start - US945250 - Sprint 50 - Completed Field Observation
            if(wfrList[0].Field_Observation_Feedback_Request__c != null){
                WorkFeedBackRequest feedbackRequest =  [SELECT Id, PerformanceCycle.RecordType.Name, Name, SubmittedDate 
                                                        FROM WorkFeedbackRequest WHERE ID =:wfrList[0].Field_Observation_Feedback_Request__c Limit 1];
                if(feedbackRequest.Name !=null && feedbackRequest.PerformanceCycle.RecordType.Name != null && feedbackRequest.SubmittedDate != null){
                    data.fieldObservationActivity = feedbackRequest.Name + HYPHEN_STR + feedbackRequest.PerformanceCycle.RecordType.Name + HYPHEN_STR + feedbackRequest.SubmittedDate.Month() + FORWARD_SLASH_STR + feedbackRequest.SubmittedDate.Day() + FORWARD_SLASH_STR + feedbackRequest.SubmittedDate.Year();
                }
            }
            //End - US945250 - Sprint 50 - Completed Field Observation
            
            data.recordTypeName = strXSPWalk;
            List<WorkFeedback> feedbackList = [SELECT Id, Question.Name, Question.Text, Question.Category__c,
                                                        Feedback,Question.Number,Question.Type
                                                        FROM WorkFeedback WHERE RequestId=:wfrList[0].Id
                                                        order by Question.Number LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                                                
            Integer currIdx=0;
            //Overallnotes            
            data.overallNotes=feedbackList[currIdx].feedback;  
            data.overallNotesQnId=feedbackList[currIdx].Id;

            //Area of Focus is the first two questions
            if(feedbackList[currIdx+1].Question.Name == 'Area of Focus'){
                currIdx++;
                data.areaOfFocus=feedbackList[currIdx].feedback;
                data.areaOfFocusQnId=feedbackList[currIdx].Id;
            }                        
            //Area of Focus Notes is the first two questions
            if(feedbackList[currIdx+1].Question.Name == AREAOF_FOCUS_NOTES) {
                currIdx++;
                data.areaOfFocusNotes=feedbackList[currIdx].feedback;
                data.areaOfFocusQnNotesId=feedbackList[currIdx].Id; 
            }
            
            if(!Test.isRunningTest()){
                if(strXSPWalk.equals(Label.XSP_Ridealong)) {
                    //Knocks
                    currIdx++;
                    data.knocks=feedbackList[currIdx].feedback;
                    data.knocksQnId=feedbackList[currIdx].Id;
        
                    //Contacts
                    currIdx++;
                    data.contacts=feedbackList[currIdx].feedback;
                    data.contactsQnId=feedbackList[currIdx].Id;
        
                    //Starts
                    currIdx++;
                    data.starts=feedbackList[currIdx].feedback;
                    data.startsQnId=feedbackList[currIdx].Id;
                }
            }
            currIdx++; 
            WalkalongUtilsReadOnly.Category category;
            WalkalongUtilsReadOnly.Question question;
            //Categories and questions 
            for(Integer idx=currIdx;idx<feedbackList.size();idx++){
                WorkFeedback feedback = feedbackList[idx];    
                if(feedback.question.Name == feedback.question.Category__c){
                    //This is the question corresponding to the Category
                    category = new WalkalongUtilsReadOnly.Category();
                    category.category=feedback.question.Category__c;
                    category.rating=feedback.Feedback;
                    category.text=feedback.question.Text;
                    category.categoryQnId=feedback.Id;                 
                    if(!Test.isRunningTest()){
                        category.category=feedback.Question.Text.replace(' ','_');
                    }
                    category.showNotes=false;
                    data.addCategory(category);
                }else{
                    //This is the questions within a category
                    if(feedback.question.Type == MultipleChoice){
                        question = new WalkalongUtilsReadOnly.Question();
                        question.name=feedback.question.Name;
                        question.text=feedback.question.Text;
                        question.rating=feedback.Feedback;
                        question.qnId=feedback.Id;
                        question.showNotes=false;
                        question.showHelpText=false;    
                    }else if(feedback.question.Type == FreeText){                      
                        if(feedback.Feedback!=null)
                            question.notes=feedback.Feedback;
                            //strNotesVal = strNotesVal + ' ' + question.notes;
                            System.debug('feedback.Id>>>'+feedback.Id);
                            question.qnNotesId=feedback.Id;
                            //Once notes comes up add the question and reset the current question
                            category.addQuestion(question);
                           // question = new WalkalongController.Question();
                    }else{
                        //Something is not right
                    }                     
                }
            }                              
        }  
        return data;        
    }
    
    /****************************************************
    * @Description: This method is for geting submitted Observation data for chatter post   
    * @Param: String
    * @Return: WalkalongUtilsReadOnly.WalkAlongData
    * Last Modified by Animesh - adding check for retails sales rep to extend chatter post functionality for Indirect Channel-  SP53 - US1094059 - 28-April-2017
    *****************************************************/   
    @RemoteAction
    global static WalkalongUtilsReadOnly.WalkAlongData getFeedbackForXsp1(String FeedbackId){
        List<WorkFeedbackRequest> wfrList = new List<WorkFeedbackRequest>();
        List<WorkFeedbackQuestion> wfrFeedBackQuestion = new List<WorkFeedbackQuestion>();      
        WalkalongUtilsReadOnly.WalkAlongData data = new WalkalongUtilsReadOnly.WalkAlongData();
        
        String profileCheck = [SELECT Id, Profile.Name FROM User WHERE id=:UserInfo.getUserId()][0].Profile.Name;  
        PermissionSet objPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE NAME =: XFINITY_SALES_EXECUTIVE_PERMISSION Limit 1];
        data.loggedInUserId = Userinfo.getUserId();
        
        if(profileCheck.equalsIgnoreCase(System.label.Xfinity_CAR_ProfileName) || profileCheck.equalsIgnoreCase(ConstantHandler.RETAIL_SALES_REP_PROFILE_NAME)){//Adding check for retail sales Rep - SP53 - US1094059
            data.profileFlag=true;
        }
        else{
            for(User usr:[SELECT Id, Name FROM User WHERE (ManagerId=:UserInfo.getUserId() OR Manager.ManagerId=:UserInfo.getUserId()) 
                            AND IsActive=true AND UserPermissionsWorkDotComUserFeature = true //Adding check for retail sales Rep - SP53 - US1094059
                            AND (Profile.Name =: Label.Xfinity_CAR_ProfileName OR Profile.Name =: ConstantHandler.RETAIL_SALES_REP_PROFILE_NAME)  LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){ //Updated the query for US609427- WalkAlong Form Enhancements                          
                data.profileFlag =false;
            }
        }
        
        Set<String> myset = new Set<String>();
        for(PermissionSetAssignment itrPer : [SELECT Id, assignee.name, assigneeid FROM PermissionSetAssignment 
                                                WHERE PermissionSetId =:objPermissionSet.Id AND AssigneeId=:UserInfo.getUserId()]){
            myset.add(itrPer.AssigneeId);
            for(User usr : [SELECT Id, Name FROM User WHERE ManagerId=:UserInfo.getUserId() 
                            AND IsActive=true AND UserPermissionsWorkDotComUserFeature = true]){ //Updated the query for US609427- WalkAlong Form Enhancements                          
                data.profileFlag = false;
            }          
        }
        
        if(profileCheck.equalsIgnoreCase(System.Label.DSRProfileName) && myset.isEmpty()) {
             data.profileFlag = true;    
        }
        else{
            for(User usr:[SELECT Id, Name FROM User WHERE (ManagerId=:UserInfo.getUserId() OR Manager.ManagerId=:UserInfo.getUserId() 
                                                        OR Manager.Manager.ManagerId=:UserInfo.getUserId() OR Id=:UserInfo.getUserId()) 
                            AND IsActive=true AND UserPermissionsWorkDotComUserFeature = true 
                            AND (Profile.Name =: Label.DSRProfileName OR Profile.Name =: Label.Profile_Name_ASM OR Profile.Name =: Label.Profile_Name_SDM)]){ //Updated the query for US609427- WalkAlong Form Enhancements                          
                data.profileFlag= false;
            }    
        }
                
        wfrList = [SELECT Id, SelectedProperty__c, LastModifiedDate, PerformanceCycle.RecordType.Name, SubmittedDate, SubjectId, 
                    PerformanceCycle.Name, Score__c, Recipient.Name, RecipientId, Subject.Name, QuestionSetId, Private_Notes__c 
                    FROM WorkFeedbackRequest WHERE Id=:FeedbackId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];  //added Private Notes in Query (US1025294)
                
        if(wfrList.size() == 1){
            String strXSPWalk;
            wfrFeedBackQuestion = [SELECT Id, Name FROM WorkFeedbackQuestion WHERE QuestionSetId=:wfrList[0].QuestionSetId 
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            //data.selectedXSP = xspUserId;
            strXSPWalk = wfrList[0].PerformanceCycle.RecordType.Name;
            data.peformanceCycle = wfrList[0].PerformanceCycle.Name;
            data.feedbackFrom = wfrList[0].Recipient.Name;
            data.feedbackFromId = wfrList[0].RecipientId;
            data.feedbackTo = wfrList[0].Subject.Name;
            data.submittedDate = wfrList[0].SubmittedDate.Month() + FORWARD_SLASH_STR + wfrList[0].SubmittedDate.Day()+ FORWARD_SLASH_STR + wfrList[0].SubmittedDate.Year();
            data.score = wfrList[0].Score__c; 
            data.requestId=wfrList[0].Id;
            data.lastSavedDate=wfrList[0].LastModifiedDate.format();
            data.showNotes=false;
            data.selectedXSP=wfrList[0].SubjectId;
            data.propList = wfrList[0].SelectedProperty__c;
            data.privateNotes = wfrList[0].Private_Notes__c;
            data.recordTypeName = strXSPWalk;
            String feedbackTyp = FEEDBACK_ABOUT + data.feedbackTo + HYPHEN_STR + strXSPWalk + HYPHEN_STR + data.submittedDate;
            data.feedbackType=feedbackTyp ;
            List<WorkFeedback> feedbackList = [SELECT Id, Question.Name, Question.Text, Question.Category__c,
                                                Feedback, Question.Number, Question.Type FROM WorkFeedback WHERE RequestId=:wfrList[0].Id
                                                order by Question.Number LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                                                
            Integer currIdx=0;
            //Overallnotes
            data.overallNotes=feedbackList[currIdx].feedback;
            data.overallNotesQnId=feedbackList[currIdx].Id;
        
            //Area of Focus is the first two questions
            currIdx++;
            data.areaOfFocus=feedbackList[currIdx].feedback;
            data.areaOfFocusQnId=feedbackList[currIdx].Id;
            
            //Area of Focus Notes is the first two questions                 
            /*if(feedbackList[currIdx+1].Question.Name == AREAOF_FOCUS_NOTES) {
                currIdx++;
                data.areaOfFocusNotes=feedbackList[currIdx].feedback;
                data.areaOfFocusQnNotesId=feedbackList[currIdx].Id; 
            }*/
                        
            if(!Test.isRunningTest()){
                if(strXSPWalk.equals(Label.XSP_Ridealong)) {
                    //Knocks
                    currIdx++;
                    data.knocks=feedbackList[currIdx].feedback;
                    data.knocksQnId=feedbackList[currIdx].Id;
        
                    //Contacts
                    currIdx++;
                    data.contacts=feedbackList[currIdx].feedback;
                    data.contactsQnId=feedbackList[currIdx].Id;
        
                    //Starts
                    currIdx++;
                    data.starts=feedbackList[currIdx].feedback;
                    data.startsQnId=feedbackList[currIdx].Id;
                }
            }
            currIdx++; 
            WalkalongUtilsReadOnly.Category category;
            WalkalongUtilsReadOnly.Question question;
            //Categories and questions 
            for(Integer idx=currIdx;idx<feedbackList.size();idx++){
                WorkFeedback feedback = feedbackList[idx];    
                if(feedback.question.Name == feedback.question.Category__c){
                    //This is the question corresponding to the Category
                    category = new WalkalongUtilsReadOnly.Category();
                    category.category=feedback.question.Category__c;
                    category.rating=feedback.Feedback;
                    category.text=feedback.question.Text;
                    category.categoryQnId=feedback.Id;                 
                    if(!Test.isRunningTest()){
                        category.category=feedback.Question.Text.replace(' ','_');
                    }
                    category.showNotes=false;
                    data.addCategory(category);
                }else{
                    //This is the questions within a category
                    if(feedback.question.Type == MultipleChoice){
                        question = new WalkalongUtilsReadOnly.Question();
                        question.name=feedback.question.Name;
                        question.text=feedback.question.Text;
                        question.rating=feedback.Feedback;
                        question.qnId=feedback.Id;
                        question.showNotes=false;
                        question.showHelpText=false;
                    }else if(feedback.question.Type == FreeText){                      
                        if(feedback.Feedback!=null)
                        question.notes=feedback.Feedback;
                        strNotesVal = strNotesVal + SPACE_STR + question.notes;
                        question.qnNotesId=feedback.Id;
                        //Once notes comes up add the question and reset the current question
                        category.addQuestion(question);
                        //question = new WalkalongController.Question();
                    }else{
                        //Something is not right
                    }                    
                }
            }                              
        }  
        return data;        
    }
    
    //Wrapper class for Observation Details Data
    global class WalkAlongData{
        public String requestId {get; set;}
        public String peformanceCycle{get; set;}
        public String feedbackType{get;set;}
        public String feedbackFrom{get; set;}       
        public String feedbackTo{get; set;}       
        public String submittedDate{get; set;}
        public String overallNotes {get; set;}
        public String overallNotesQnId {get; set;}
        public String knocks {get; set;}
        public String knocksQnId {get; set;}
        public String contacts {get; set;}
        public String contactsQnId {get; set;}
        public String starts {get; set;}
        public String startsQnId {get; set;}
        public String areaOfFocus {get; set;}
        public String areaOfFocusQnId {get; set;}
        public String areaOfFocusNotes {get; set;}
        public String areaOfFocusQnNotesId {get; set;}
        public String selectedXSP {get; set;}
        public String selectedRecordType {get; set;}
        public List<Category> categories {get; set;}
        public Boolean walkAlongStarted {get; set;}
        public Boolean walkAlongStopped {get; set;}
        public String startTime {get; set;}
        public String endTime {get; set;}
        public Boolean profileFlag{get;set;}
        public Boolean showNotes {get; set;}
        public String lastSavedDate {get; set;}
        public Double score {get; set;}
        public String propList {get; set;}
        public String recordTypeName {get; set;}
        public List<String> transactionTypes {get; set;}//Added this to capture transaction Types picklist values for Retail observation 
        public String selectedTransactionTypes {get; set;}//Added this to capture selected transaction Types values for Retail observation 
        
        public String huddleActivity {get; set;}
        public String oneOnOneCoachingActivity {get; set;}
        public String fieldObservationActivity {get; set;}
        public Boolean isCarDirector {get; set;}
        
        //start added variable to incorporate private notes
        public String privateNotes {get; set;}
        public String loggedInUserId{get; set;}
        public String feedbackFromId{get; set;}
        public Boolean isPrivateNotesVisible{get; set;}
        //end added variable to incorporate private notes
        
        //public Integer scorePct {get; set;}
        public String overallRating {get; set;}
        public void addCategory(Category catg){
            if(this.categories==null){
                this.categories=new List<Category>();
            }
            this.categories.add(catg);
        }
    }
    
    //Wrapper class for Category Details
    global class Category{
        public String category {get; set;}
        public String text {get; set;}
        public String rating {get; set;}
        public List<Question> questions {get; set;}
        public Boolean showNotes {get; set;}
        public String categoryQnId {get; set;}
        public void addQuestion(Question qn){
            if(this.questions==null){
                this.questions=new List<Question>();
            }
            this.questions.add(qn);
        }
    }
    
    //Wrapper class for Question Details for each Category 
    global class Question{
        public String name {get; set;}
        public String text {get; set;}
        public String rating {get; set;}
        public String notes {get; set;}
        public Boolean showNotes {get; set;}
        public Boolean showHelpText {get; set;}
        public String qnId {get; set;}
        public String qnNotesId {get; set;}     
    }
    
    /****************************************************
    * @Description: geting picklist values of Transaction Types
    * @Param: null
    * @Return: List<String>
    * @Auther : Amit Kumar Pradhan
    * @Date : 21-Aug-2017
    *****************************************************/ 
    public Static List<String> getTransactionTypes(){
        List<String> options = new List<String>();        
        Schema.DescribeFieldResult fieldResult = WorkFeedbackRequest.Transaction_types__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues(); 
        for(Schema.PicklistEntry picklistEntry : pickListValues)
        {
            options.add(picklistEntry.getValue());
        }       
        return options;
    }
}