/******************************************************************************************************
* Class Name: ObservationController
* Author: 
* Date: 
* Description: Controller class for ObservationForm
* Version : 1.0
  Author Last Updated : Revan Bhadange and Amit Kumar Pradhan, Accenture(Combined Car Event and Property Visit Observation)
  PROJECT : Coach for CAR
* Version : 2.0
  Author Last Updated : Animesh Datta and Amit Kumar Pradhan, Accenture(Combined Indirect Observation)
  PROJECT : Coach for Indirect
* Version : 3.0
  Author Last Updated : Animesh Datta, Accenture(Combined Super Coach Observation)
  PROJECT : Super Coach for CAR 
* Version : 4.0
  Author Last Updated : Animesh Datta and Amit Kumar Pradhan, Accenture(Combined Car Event and Property Visit Observation for Super Coach Observation)
  PROJECT : Super Coach for CAR 
  User Story : US1028099
* Version : 5.0
  Author Last Updated : Malay Desai, Accenture(Code commented to retrive Feedback Request for CAR Managers)
  PROJECT : Super Coach for CAR 
  User Story : US1124994 
* Version : 6.0
  Author Last Updated : Malay Desai, Accenture(Code changes to display grouping of observations when CAR Leader does observation)
  PROJECT : Super Coach for CAR 
  User Story : US1086148
* Version : 7.0
  Author Last Updated : Amit Kumar Pradhan, Accenture(Merging code for Coach for Retail Observation)
  PROJECT : Coach For Retail 
  User Story : US1158971(Coach for Retail - Observation - Form w/ question categories, specific questions, and ratings (answer options))
* Version : 8.0
  Author Last Updated : Amit Kumar Pradhan, Accenture(Added two walkalong data variable)
  PROJECT : Coach For Retail 
  User Story : US1165802(Coach for Retail: As a manager, allow transaction type to be recorded as part of an observation)    
********************************************************************************************************/
global class ObservationController{
    public boolean flag {get; set;}
    public static final String XSP_WALKALONG = 'XSP Walkalong';
    public static final String WORK_PERFORMANCE_CYCLE = 'WorkPerformanceCycle';
    public static final String SFDC_FRAME_HOST = 'sfdcIFrameHost';
    public static final String IS_DTP = 'isdtp';
    public static final String RETURL = 'retURL';
    public static final String projectone = 'projectone';
    public static final String CAR_TEAM_HUDDLE_RECORD_TYPE = 'CAR Team Huddle';
    public static final String CAR_EVENT_RECORD_TYPE = 'CAR Event';
    public static final String PROPERTY_VISIT_RECORD_TYPE = 'Property Visit';
    public static final String SUBMITTED_STATUS = 'Submitted';
    public static final String COMPLETED_STATUS = 'Completed';
    public static final String ACTIVITY_NAME_SPACE =  ' - ';
    public static final String P1_STRING =  'p1';
    public static final String XSP_OBSERVATION ='XSP Observation';
    public static final String RSR_OBSERVATION ='RSR Observation';
    public static final String CAR_OBSERVATIONS ='CAR Observations';
    public static final String CAR_MANAGER_OBSERVATIONS='CAR Manager Observations';
    public static final String RETAIL_OBSERVATION ='Retail Observation';//part of US1158971
    
    //Wrapper class for Rep Details
    global class Xsp{       
        public String name {get; set;}
        public Id id {get; set;}
        //Added Profile Name in Rep Details(Part Of US1028099)
        //Last Modified By : Amit Kumar Pradhan
        public String profileName {get; set;}
        public Xsp(String name,Id id,String profileName){
            this.name=name;
            this.id=id;
            this.profileName=profileName;
        }       
    }
    
    //Wrapper class for Observation Type Details(RecordType of Performace Cycle)
    //Changes for : US1086148
    global class RecordTypePerformace{
        public String forWhom {get; set;}
        public List<RecordTypeCustom> recordTypes{get;set;} 
        public RecordTypePerformace(String forWhom,List<RecordTypeCustom> recordTypes){
            this.forWhom=forWhom;
            this.recordTypes=recordTypes;
        }
    }
    
    //Wrapper for RecordTypes
    // Changes for : US1086148
    global class RecordTypeCustom{
      public String name {get; set;}
        public String id {get; set;} 
        //Constructor
        public RecordTypeCustom(String name,String id){
            this.name=name;
            this.id=id;
        }
    }
    
    //Wrapper class for Person Coach Details(Part of Super Coach Observation)
    global class PersonCoach{
        public String name {get; set;}
        public Id id {get; set;} 
        //Constructor
        public PersonCoach(String name,Id id){
            this.name=name;
            this.id=id;
        }       
    }
    
    //Wrapper class for one one coaching Details(Part of Super Coach Observation)
    global class OneOneCoachingData{
        public String keyString {get; set;}
        public String name {get; set;}
        public Id id {get; set;} 
        public OneOneCoachingData(String keyString,String name, Id id){
            this.keyString=keyString;
            this.name=name;
            this.id=id;
        }       
    }
    
    //Wrapper class for huddle activity Details(Part of Super Coach Observation)
    global class HuddleActivity{
        public String name {get;set;}       
        public Id id {get;set;}
        public Datetime huddleDate {get; set;}
        public HuddleActivity(String name,Id id, Datetime huddleDate){
            this.name=name;
            this.id=id;
            this.huddleDate=huddleDate;
        }
    }
    
    //Wrapper class for observation activity Details of car(Part of Super Coach Observation)
    global class FieldObservationCoachee{
        public String name {get; set;}
        public Id id {get; set;} 
        public FieldObservationCoachee(String name,Id id){
            this.name=name;
            this.id=id;
        }       
    }
    
    //Wrapper class for Feedback Request Data Details of car(Part of Super Coach Observation)
    global class FeedbackRequestData{
        public String keyString {get; set;}
        public String name {get; set;}
        public Id id {get; set;} 
        public FeedbackRequestData(String keyString,String name, Id id){
            this.keyString=keyString;
            this.name=name;
            this.id=id;
        }       
    }
    
    //Wrapper class for activity details(coaching activity, huddle activity, observation activity)
    global class activityData{
        public List<PersonCoach> personCoachList {get; set;}       
        public List<OneOneCoachingData> oneOneCoachingDataList {get; set;}
        public List<HuddleActivity> huddleActivityList {get; set;} 
        public List<FieldObservationCoachee> fieldObservationCoacheeList {get; set;}
        public List<FeedbackRequestData> feedbackRequestDataList {get; set;}

        public void addPersonCoach(PersonCoach coached){
            if(this.personCoachList==null){
                this.personCoachList=new List<PersonCoach>();
            }else{}
            this.personCoachList.add(coached);
        }  
        
        public void addOneOneCoachingData(OneOneCoachingData oneOneCoaching){
            if(this.oneOneCoachingDataList==null){
                this.oneOneCoachingDataList=new List<OneOneCoachingData>();
            }else{}
            this.oneOneCoachingDataList.add(oneOneCoaching);
        } 
        
        public void addHuddleActivity(HuddleActivity huddle){
            if(this.huddleActivityList==null){
                this.huddleActivityList=new List<HuddleActivity>();
            }else{}
            this.huddleActivityList.add(huddle);
        }

        public void addFieldObservationCoachee(FieldObservationCoachee fieldObsCoachee){
            if(this.fieldObservationCoacheeList==null){
                this.fieldObservationCoacheeList=new List<FieldObservationCoachee>();
            }else{}
            this.fieldObservationCoacheeList.add(fieldObsCoachee);
        }
        
        public void addFeedbackRequestData(FeedbackRequestData feedbackData){
            if(this.feedbackRequestDataList==null){
                this.feedbackRequestDataList=new List<FeedbackRequestData>();
            }else{}
            this.feedbackRequestDataList.add(feedbackData);
        } 
    }
    
    //Wrapper class for Observation details(Section setup, category setup, Question setup etc.) while creating an observation   
    global class WalkAlongData{
        public List<String> propNameList;
        public String requestId {get; set;}
        public String selectedXSP {get; set;}
        public String selectedRecordType {get; set;}
        public List<Section> sections {get; set;}
        public Boolean showSection {get; set;}
        public Boolean walkAlongStarted {get; set;}
        public Boolean walkAlongStopped {get; set;}
        public String startTime {get; set;}
        public String endTime {get; set;}
        public Boolean showNotes {get; set;}
        public String lastSavedDate {get; set;}
        public Double score {get; set;}
        public Integer scorePct {get; set;}
        public String overallRating {get; set;}
        public String propString {get; set;}
        public String recordTypeName {get; set;}
        public String selectedPersonCoach {get; set;}
        public String selectedActivity {get; set;}        
        public String selectedPersonObserved {get; set;}
        public String privateNotes {get; set;}
        public Integer autoSaveInterval {get; set;}//Added this to capture the Custom Label for Auto saving the observation
        public List<String> transactionTypes {get; set;}//Added this to capture transaction Types picklist values for Retail observation 
        public String selectedTransactionTypes {get; set;}//Added this to capture selected transaction Types values for Retail observation 
        
        public void addSection(Section sec){
            if(this.sections==null){
                this.sections=new List<Section>();
            }else{}
            this.sections.add(sec);
        } 
        
    }
    
    //Wrapper class for Section Details(Common, Observation Count, Observation Section)
    global class Section{
        public String name {get; set;}
        public List<Question> questions {get; set;}
        public List<Category> categories {get; set;}
        public Boolean showSection {get; set;}
        
        public void addQuestion(Question qn){
            if(this.questions==null){
                this.questions=new List<Question>();
            }else{}
            this.questions.add(qn);
        }
        public void addCategory(Category catg){
            if(this.categories==null){
                this.categories=new List<Category>();
            }else{}
            this.categories.add(catg);
        }        
    }
    
    //Wrapper class for Category Details for Observation Section(weight, question set etc.)
    global class Category{
        public String category {get; set;}
        public String text {get; set;}
        public String rating {get; set;}
        public Double weights {get; set;}
        public List<Question> questions {get; set;}
        public Boolean showNotes {get; set;}
        public String categoryQnId {get; set;}
        public void addQuestion(Question qn){
            if(this.questions==null){
                this.questions=new List<Question>();
            }else{}
            this.questions.add(qn);
        }
    }
    
    //Wrapper class for Question Details for each category(question name, rating etc.)
    global class Question{
        public String name {get; set;}
        public String text {get; set;}
        public String rating {get; set;}
        public String notes {get; set;}
        public Boolean showNotes {get; set;}
        public Boolean showHelpText {get; set;}
        public String qnId {get; set;}
        public String qnNotesId {get; set;}
        public String section {get; set;}
    }
     
    /****************************************************
    * @Description: This method fetches profile, record type access from ObservationForm metaData.
    * @Author: Amit Kumar Pradhan, Accenture
    * @Param: None
    * @Return: Map<String,String>
    
    * LastModified By : Amit Kumar Pradhan
    * LastModified Date : 24-March-2017
    * Description : CAR Directors can create Super Coach(Super Coach Huddles/Super Coach 1:1s/Super Coach CAR Manager Field Obs) 
                    & CAR Manager(CAR Event/Property Visit) Observations
    * User Story : US1028099
    *****************************************************/
    global static Map<String,String> getObservationForm(){
        Map<String, String> mapStrObsForm = new Map<String, String>();
        //Refactoring the code and remove permisssion set check(Part Of US1028099)
        //Last Modified By : Amit Kumar Pradhan
        for(ObservationForm__mdt observationMdt : [SELECT Feedback_Form__c, Profile__c, DeveloperName 
                                                    FROM ObservationForm__mdt LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
        {            
            mapStrObsForm.put(observationMdt.Profile__c,observationMdt.Feedback_Form__c);       
        }      
        return mapStrObsForm; 
    } 
     
    /****************************************************
    * @Description: This method determines if this is SF1 app or not
    * @Author: Pranjal Singh, Accenture
    * @Param: None
    * @Return: Boolean
    *****************************************************/
    public Boolean getSF1(){
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get(SFDC_FRAME_HOST)) ||
            String.isNotBlank(ApexPages.currentPage().getParameters().get(SFDC_FRAME_HOST)) ||
            ApexPages.currentPage().getParameters().get(IS_DTP) == P1_STRING ||
            (ApexPages.currentPage().getParameters().get(RETURL) != null && ApexPages.currentPage().getParameters().get(RETURL).contains(projectone)))
        {            
            flag=true;
        }else{
            flag=false;
        }
        return flag;
    } 
    
    /****************************************************
    * @Description: This method is for geting Rep List while creating Observation
    * @Param: None
    * @Return: List<Xsp>
    * LastModified By : Amit Kumar Pradhan
    * LastModified Date : 24-March-2017
    * Description : CAR Directors can create Super Coach(Super Coach Huddles/Super Coach 1:1s/Super Coach CAR Manager Field Obs) 
                    & CAR Manager(CAR Event/Property Visit) Observations
    * User Story : US1028099
    *****************************************************/
    @RemoteAction
    global static List<Xsp> getXSPList(){
        List<Xsp> xspList = new List<Xsp>();
        Map<String,String> mapProfile = new Map<String,String>();
        List<User> UserList = new List<User>();
        try{
            String loginProfileId = Userinfo.getProfileId();  
            mapProfile = getObservationForm();
            //Included Property Visit and CAR Event Obs for CAR Directors(Part of US1028099)
            //Last Modified By : Amit Kumar Pradhan
            if(loginProfileId == System.Label.CARManagerProfileId){
                UserList = [SELECT Id,Name,Profile.Name FROM User WHERE ManagerId=:UserInfo.getUserId() AND IsActive=true 
                            AND UserPermissionsWorkDotComUserFeature = true AND Profile.Name IN : mapProfile.keySet() ORDER BY NAME ASC 
                            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            }else{
                UserList = [SELECT Id,Name,Profile.Name FROM User 
                            WHERE (ManagerId=:UserInfo.getUserId() OR Manager.ManagerId=:UserInfo.getUserId() OR Manager.Manager.ManagerId=:UserInfo.getUserId()) 
                            AND IsActive=true AND UserPermissionsWorkDotComUserFeature = true 
                            AND Profile.Name IN : mapProfile.keySet() ORDER BY NAME ASC LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];            
            }
            
            for(User userObj : UserList){       
                xspList.add(new Xsp(userObj.Name,userObj.Id,userObj.Profile.Name));
            }           
        }catch(Exception e){
            System.debug('***Following exception has occured***'+e.getMessage());           
        }
        return xspList;
    }
    
    /****************************************************
    * @Description: This method is for geting Record Type List of Performance cycle(Form Name) while creating Observation
    * @Author: Revan Bhadange, Accenture
    * @Param: None
    * @Return: List<RecordTypePerformace>
    * LastModified By : Amit Kumar Pradhan
    * LastModified Date : 24-March-2017
    * Description : CAR Directors can create Super Coach(Super Coach Huddles/Super Coach 1:1s/Super Coach CAR Manager Field Obs) 
                    & CAR Manager(CAR Event/Property Visit) Observations
    * User Story : US1028099
    * LastModified Date : 2-July-2017
    * Description : As CAR Director while creating an Observation when I select 'Select Observation Form' my available options 
      should be grouped by 'CAR Observations' and 'CAR Manager Observations'
    * User Story : US1086148
    * LastModified By : Amit Kumar Pradhan
    * LastModified Date : 10-Aug-2017
    * Description : Handeled performance record type of Retail Manager Observation(For Retail Observation)
    * User Story : US1158971(Coach for Retail - Observation - Form w/ question categories, specific questions, and ratings (answer options))
    *****************************************************/   
    @RemoteAction
    global static List<RecordTypePerformace> getRecordTypePerformCycleList() {
        Map<String,String> mapObForm = new Map<String,String>();             
        List<RecordTypePerformace> recordTypePerformCycleList = new List<RecordTypePerformace>();
        List<RecordTypeCustom> recordTypeCustomList= new List<RecordTypeCustom>();
        List<RecordTypeCustom> recordTypeCustomListForCAR= new List<RecordTypeCustom>();
        List<RecordTypeCustom> recordTypeCustomListForCARMgr= new List<RecordTypeCustom>();
        List<String> lstObsFormString = new List<String>();
        List<String> lstObsNewFormString = new List<String>();
        Boolean rtpAlreadyExist1=false,rtpAlreadyExist2=false;
        try{
            mapObForm = getObservationForm();        
            for(String metaData : mapObForm.values()){   
                lstObsFormString = metaData.split(',');
                for(String strObsForm : lstObsFormString){                
                    lstObsNewFormString.add(strObsForm);  
                } 
            }
            //Added record type in metadata(Part Of US1028099)
            //Last Modified By : Amit Kumar Pradhan
            for(RecordType rec : [SELECT Id, Name FROM RecordType WHERE SObjectType =: WORK_PERFORMANCE_CYCLE and Name IN : lstObsNewFormString 
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){                   
                Schema.RecordTypeInfo rtById = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosById().get(rec.Id);
                if(rtById.isAvailable()){               
                    if(rec.Name.equals(Label.XSP_Ridealong)) {
                        recordTypeCustomList.add(new RecordTypeCustom(XSP_WALKALONG,rec.Id)) ;
                        recordTypePerformCycleList.add(new RecordTypePerformace(XSP_OBSERVATION,recordTypeCustomList)); 
                    }else if(rec.Name.equals(Label.Indirect_Observation)){
                        recordTypeCustomList.add(new RecordTypeCustom(Label.Indirect_Observation,rec.Id)) ;
                        recordTypePerformCycleList.add(new RecordTypePerformace(RSR_OBSERVATION,recordTypeCustomList));
                    /**************************
                    * User Story : US1158971-Start
                    * LastModified By : Amit Kumar Pradhan
                    * LastModified Date : 10-Aug-2017
                    * Description : Handeled performance record type of Retail Manager Observation(For Retail Observation) 
                    ***************************/
                    }else if(rec.Name.equals(Label.Retail_Manager_Observation)){
                        recordTypeCustomList.add(new RecordTypeCustom(Label.Retail_Manager_Observation,rec.Id)) ;
                        recordTypePerformCycleList.add(new RecordTypePerformace(RETAIL_OBSERVATION,recordTypeCustomList));
                    /**************************
                    * User Story : US1158971-End
                    ***************************/
                    }else{
                        if(rec.Name.equals(Label.Property_Visit) || rec.Name.equals(Label.CAR_Event)){
                            recordTypeCustomListForCAR.add(new RecordTypeCustom(rec.Name,rec.Id)) ;
                            
                            for(RecordTypePerformace rtp : recordTypePerformCycleList){
                                if(rtp.forWhom.equals(CAR_OBSERVATIONS)) rtpAlreadyExist1 = true;
                            }
                            if(!rtpAlreadyExist1){
                                recordTypePerformCycleList.add(new RecordTypePerformace(CAR_OBSERVATIONS, recordTypeCustomListForCAR));
                            }
                        }else{
                            recordTypeCustomListForCARMgr.add(new RecordTypeCustom(rec.Name,rec.Id)) ;
                            
                            for(RecordTypePerformace rtp : recordTypePerformCycleList){
                                if(rtp.forWhom.equals(CAR_MANAGER_OBSERVATIONS)) rtpAlreadyExist2 = true;
                            }
                            if(!rtpAlreadyExist2){
                                recordTypePerformCycleList.add(new RecordTypePerformace(CAR_MANAGER_OBSERVATIONS, recordTypeCustomListForCARMgr));
                            }
                        }                           
                    }               
                }else{}
            }
        }catch(Exception e){
            System.debug('***Following exception has occured***'+e.getMessage());
        }
        return recordTypePerformCycleList;
    }
    
    /****************************************************
    * @Description: This method is for geting activity list(one one coaching, huddle, observation)
    * @Author: Animesh Datta, Accenture
    * @Date: 18-Feb-2017 
    * @Param: String, String
    * @Return: ObservationController.activityData
    * Last Modified Date: 02- March - 2017
    * Last Modified By : Animesh Datta
    * Last Modified Description : Added logic for Field Observation
    *****************************************************/    
    @RemoteAction
    global static ObservationController.activityData getActivitiesData(String carMgr, String formName) {        
        ObservationController.activityData activityList = new ObservationController.activityData();
        Set<String> coachingId = new Set<String>();
        try{
            String huddleRecordTypeName = Schema.SObjectType.Task.getRecordTypeInfosByName().get(CAR_TEAM_HUDDLE_RECORD_TYPE).getRecordTypeId();
            if(formName == System.Label.CAR_Manager_1_1_Obs){              
                for(User usr:[SELECT Id, Name FROM USER WHERE ManagerId=:carMgr AND IsActive=true AND UserPermissionsWorkDotComUserFeature = true 
                                AND Profile.Name =: System.Label.Xfinity_CAR_ProfileName LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    activityList.addPersonCoach(new ObservationController.PersonCoach(usr.Name,usr.Id));               
                }
                
                for(WorkCoaching workCoachingObj : [SELECT Id,Name From WorkCoaching WHERE CoachId=:carMgr 
                                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    coachingId.add(workCoachingObj.Id);
                }
                
                for(one_one_Coaching__c oneOneCoachingObj : [SELECT Id, Name, Coaching__c, Coaching__r.CoachedId, Coaching__r.CoachId,CreatedDate 
                                                                FROM one_one_Coaching__c WHERE Coaching__c IN : coachingId AND Status__c =: SUBMITTED_STATUS 
                                                                ORDER BY Createddate DESC LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    String combinedString = String.ValueOf(oneOneCoachingObj.Coaching__r.CoachedId) + String.ValueOf(oneOneCoachingObj.Id);
                    activityList.addOneOneCoachingData(new ObservationController.OneOneCoachingData(combinedString,oneOneCoachingObj.Name,oneOneCoachingObj.Id));
                }
                
            }else{}
            
            if(formName == System.Label.CAR_Manager_Huddle_Obs){  
                for(Task huddleTask : [SELECT Id, Subject, CreatedDate FROM Task WHERE CreatedById =: carMgr 
                                        AND recordTypeId=:huddleRecordTypeName AND Status =: COMPLETED_STATUS ORDER BY CreatedDate DESC 
                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    String huddleDate = String.ValueOf(huddleTask.CreatedDate);
                    activityList.addHuddleActivity(new ObservationController.HuddleActivity(huddleTask.Subject + ACTIVITY_NAME_SPACE + huddleDate, huddleTask.Id, huddleTask.CreatedDate));
                }
            }else{}
            
            if(formName == System.Label.CAR_Manager_Field_Obs){              
                for(User usr:[SELECT Id, Name FROM USER WHERE ManagerId=:carMgr AND IsActive=true AND UserPermissionsWorkDotComUserFeature = true 
                                AND Profile.Name =: System.Label.Xfinity_CAR_ProfileName LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    activityList.addFieldObservationCoachee(new ObservationController.FieldObservationCoachee(usr.Name,usr.Id));               
                }
                // US1124994 - Coach for CAR Leaders: Remove Field Observation Dependency - Start
                /*for(WorkFeedbackRequest feedbackRequestObj : [SELECT Id, Name, SubjectId, SubmittedDate, PerformanceCycle.RecordType.Name 
                                                                FROM WorkFeedbackRequest WHERE RecipientId =: carMgr 
                                                                AND FeedbackRequestState =: SUBMITTED_STATUS 
                                                                AND PerformanceCycle.RecordType.Name IN (:CAR_EVENT_RECORD_TYPE,:PROPERTY_VISIT_RECORD_TYPE) 
                                                                ORDER BY SubmittedDate DESC LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    String typeAndDate = String.ValueOf(feedbackRequestObj.PerformanceCycle.RecordType.Name) + ACTIVITY_NAME_SPACE + String.ValueOf(feedbackRequestObj.SubmittedDate);
                    String combinedString = String.ValueOf(feedbackRequestObj.SubjectId) + String.ValueOf(feedbackRequestObj.id);
                    activityList.addFeedbackRequestData(new ObservationController.FeedbackRequestData(combinedString,typeAndDate,feedbackRequestObj.Id));
                }*/
                //US1124994 - Coach for CAR Leaders: Remove Field Observation Dependency - End
            }else{}
        }catch(Exception e){
            System.debug('***Following exception has occured***'+e.getMessage());
        }   
        return activityList;
    }
    
    /****************************************************
    * @Description: This method is for saving the feedback data(FeedbackRequestStatus = Draft) after clicking the save button 
    * @Param: WalkAlongData, String
    * @Return: WalkAlongData
    *****************************************************/   
    @RemoteAction
    global static WalkAlongData saveData(WalkAlongData walkAlongData,String propString) {        
        return observationUtils.saveSubmitFeedback(walkAlongData,propString,false);     
    }
    
    /****************************************************
    * @Description: This method is for saving the feedback data(FeedbackRequestStatus = Submitted) after clicking the submit button 
    * @Param: WalkAlongData, String
    * @Return: WalkAlongData
    *****************************************************/    
    @RemoteAction
    global static WalkAlongData submitWalkAlong(WalkAlongData walkAlongData,String propString) {                
        return observationUtils.saveSubmitFeedback(walkAlongData,propString,true);
    }
    
    /****************************************************
    * @Description: This method is for getting the feedback data if any feedback request of draft status or from Performance cycle questions
    * @Param: WalkAlongData, String
    * @Return: WalkAlongData
    * Last Modified Date: 02- March - 2017
    * Last Modified By : Animesh Datta
    * Last Modified Description : Added parameter personCAR for Field Observation
    *****************************************************/    
    @RemoteAction
    global static WalkAlongData getFeedbackForXsp(String formName, String xspId, String cocheeId, String activityId, String personCAR){
        return observationUtils.getFeedbackForXsp(formName,xspId,cocheeId,activityId,personCAR); 
    }
    
    Set<String> originalvalues = new Set<String>{'A','B','C','D','E','F','G'};
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
     
    public ObservationController(){
        leftselected = new List<String>();
        rightselected = new List<String>();
        leftvalues.addAll(originalValues);
    }
     
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
     
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        } 
        return null;
    } 
 
    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }
 
    public List<SelectOption> getSelectedValues(){
        List<SelectOption> options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }  
    
}