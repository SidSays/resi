global class ObservationController {
    public boolean flag {get; set;}
    public static string strXSPRecTye = 'XSP Walkalong';
    public static string WorkPerformanceCycle = 'WorkPerformanceCycle';
    public static string sfdcIFrameHost = 'sfdcIFrameHost';
    public static string isdtp = 'isdtp';
    public static string retURL = 'retURL';
    public static string projectone = 'projectone';
    
    
    global class Xsp{
        public String name {get; set;}
        public Id id {get; set;} 
        public Xsp(String name,Id id){
            this.name=name;
            this.id=id;
        }       
    }
    
    global class RecordTypePerformace{
        public String name {get; set;}
        public String id {get; set;} 
        public RecordTypePerformace(String name,String id){
            this.name=name;
            this.id=id;
        }       
    }
    
    global class PersonCoach{
        public String name {get; set;}
        public Id id {get; set;} 
        public PersonCoach(String name,Id id){
            this.name=name;
            this.id=id;
        }       
    }
    
    
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
    
    global class activityData{
        public List<PersonCoach> personCoachList {get; set;}       
        public List<OneOneCoachingData> oneOneCoachingDataList {get; set;}
        public List<HuddleActivity> huddleActivityList {get; set;} 

        public void addPersonCoach(PersonCoach coached){
            if(this.personCoachList==null){
                this.personCoachList=new List<PersonCoach>();
            }
            this.personCoachList.add(coached);
        }  
        
        public void addOneOneCoachingData(OneOneCoachingData oneOneCoaching){
            if(this.oneOneCoachingDataList==null){
                this.oneOneCoachingDataList=new List<OneOneCoachingData>();
            }
            this.oneOneCoachingDataList.add(oneOneCoaching);
        } 
        
        public void addHuddleActivity(HuddleActivity huddle){
            if(this.huddleActivityList==null){
                this.huddleActivityList=new List<HuddleActivity>();
            }
            this.huddleActivityList.add(huddle);
        }  
    }
    
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
        
        public void addSection(Section sec){
            if(this.sections==null){
                this.sections=new List<Section>();
            }
            this.sections.add(sec);
        } 
        
    }
    global class Section{
        public String name {get; set;}
        public List<Question> questions {get; set;}
        public List<Category> categories {get; set;}
        public Boolean showSection {get; set;}
        
        public void addQuestion(Question qn){
            if(this.questions==null){
                this.questions=new List<Question>();
            }
            this.questions.add(qn);
        }
        public void addCategory(Category catg){
            if(this.categories==null){
                this.categories=new List<Category>();
            }
            this.categories.add(catg);
        }        
    }
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
            }
            this.questions.add(qn);
        }
    }
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
     
     //Static method for observation form with profile
    global static Map<string,string> getObservationForm () {
        Map<String, String> mapStrObsForm = new Map<String, String> ();
        Map<String, String> mapStrObsFormSuperCARCoach = new Map<String, String> ();
        Map<String, String> mapStrObsFormCoach = new Map<String, String> ();
        PermissionSet directorPermissionSet = [SELECT Id, Label, Name FROM PermissionSet WHERE Name = 'Coach_CAR_Director_Manager'];
        String loggedInUserId = Userinfo.getUserId();
        List<PermissionSetAssignment> directorPermissionAssignment = new List<PermissionSetAssignment>();
        if(directorPermissionSet!=null){
            directorPermissionAssignment = [SELECT Id,AssigneeId,PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId =: loggedInUserId AND PermissionSetId =: directorPermissionSet.Id];
        }

        for(ObservationForm__mdt itrPropertyCarVisit : [select Feedback_Form__c,Profile__c,DeveloperName FROM ObservationForm__mdt LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
        {  
            if(!directorPermissionAssignment.isEmpty() && itrPropertyCarVisit.DeveloperName=='CAR_Super_Coach'){
                mapStrObsForm.put(itrPropertyCarVisit.Profile__c,itrPropertyCarVisit.Feedback_Form__c);
            }
            
            if(directorPermissionAssignment.isEmpty() && itrPropertyCarVisit.DeveloperName!='CAR_Super_Coach'){
                mapStrObsForm.put(itrPropertyCarVisit.Profile__c,itrPropertyCarVisit.Feedback_Form__c);
            }
            
        }      
        return mapStrObsForm; 
    } 
     
    //Determine if this is SF1 app
    public Boolean getSF1(){
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get(sfdcIFrameHost)) ||
            String.isNotBlank(ApexPages.currentPage().getParameters().get(sfdcIFrameHost)) ||
            ApexPages.currentPage().getParameters().get(isdtp) == 'p1' ||
            (ApexPages.currentPage().getParameters().get(retURL) != null && ApexPages.currentPage().getParameters().get(retURL).contains(projectone))
        )
        {            
            flag=true;
        }else{
            flag=false;
        }
        return flag;
    } 
    
    @RemoteAction
    global static List<Xsp> getXSPList() {
        List<Xsp> xspList = new List<Xsp>();
        Map<String,String> mapProfile = new Map<String,String>();
        List<User> UserList = new List<User>();
        String loginProfileId = Userinfo.getProfileId();
        //mapProfile = getObservationForm ();  
        mapProfile = getObservationForm ();
        if(loginProfileId == System.Label.CARManagerProfileId){
            UserList = [SELECT Id,Name,Profile.Name FROM User WHERE ManagerId=:UserInfo.getUserId() AND IsActive=true AND UserPermissionsWorkDotComUserFeature = true AND Profile.Name IN : mapProfile.keySet() ORDER BY NAME ASC LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        }else{
            UserList = [SELECT Id,Name,Profile.Name FROM User WHERE (ManagerId=:UserInfo.getUserId() or Manager.ManagerId=:UserInfo.getUserId() or Manager.Manager.ManagerId=:UserInfo.getUserId()) AND IsActive=true AND UserPermissionsWorkDotComUserFeature = true AND Profile.Name IN : mapProfile.keySet() ORDER BY NAME ASC LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];            
        }
        
        for(User usr:UserList)
        {
            xspList.add(new Xsp(usr.Name,usr.Id));
        }
        return xspList;
    }
    
    @RemoteAction
    global static List<RecordTypePerformace> getRecordTypePerformCycleList() {
        Map<String,String> mapObForm = new Map<String,String> ();
        Set<String> setObsFormString = new Set<String>();        
        List<RecordTypePerformace> recordTypePerformCycleList = new List<RecordTypePerformace>();
        List<String> lstObsFormString = new List<String>();
        List<String> lstObsNewFormString = new List<String>();
        mapObForm = getObservationForm();
        
        for(String metaData : mapObForm.values())
        {   
            lstObsFormString = metaData.split(',');
            for(String strObsForm : lstObsFormString){
                
                lstObsNewFormString.add(strObsForm);  
            } 
        }
        
        for(RecordType rec : [SELECT Id, Name FROM RecordType WHERE SObjectType=:WorkPerformanceCycle and Name IN : lstObsNewFormString LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
            String strXSPWalkalong;
            Schema.DescribeSObjectResult d = Schema.SObjectType.WorkPerformanceCycle; 
            Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
            Schema.RecordTypeInfo rtById =  rtMapById.get(rec.id);
            if(rtById.isAvailable()){
                
                if(rec.Name.equals(Label.XSP_Ridealong)) {
                    strXSPWalkalong = strXSPRecTye;
                    recordTypePerformCycleList.add(new RecordTypePerformace(strXSPWalkalong,rec.Id)); 
                }else{
                    recordTypePerformCycleList.add(new RecordTypePerformace(rec.Name,rec.Id));    
                }
                
            }
        }       
        return recordTypePerformCycleList;
    }
    
    @RemoteAction
    global static ObservationController.activityData getActivitiesData(String carMgr, String formName) {
        String huddleRecordTypeName = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CAR Team Huddle').getRecordTypeId();
        ObservationController.activityData activityList = new ObservationController.activityData();
        Set<String> coachingId = new Set<String>();
        
        if(formName=='Super CAR Coach 1_1'){              
            for(User usr:[SELECT Id, Name FROM USER WHERE ManagerId=:carMgr AND IsActive=true AND UserPermissionsWorkDotComUserFeature = true AND Profile.Name = 'Xfinity CAR']){
                activityList.addPersonCoach(new ObservationController.PersonCoach(usr.Name,usr.Id));               
            }
            
            for(WorkCoaching workCoachingObj : [SELECT Id,Name From WorkCoaching WHERE CoachId=:carMgr]){
                coachingId.add(workCoachingObj.Id);
            }
            
            for(one_one_Coaching__c oneOneCoachingObj : [SELECT Id, Name, Coaching__c, Coaching__r.CoachedId, Coaching__r.CoachId,CreatedDate FROM one_one_Coaching__c WHERE Coaching__c IN : coachingId AND Status__c='Submitted' ORDER BY Createddate DESC]){
                String combinedString = String.ValueOf(oneOneCoachingObj.Coaching__r.CoachedId) + String.ValueOf(oneOneCoachingObj.Id);
                activityList.addOneOneCoachingData(new ObservationController.OneOneCoachingData(combinedString,oneOneCoachingObj.Name,oneOneCoachingObj.Id));
            }
        }
        
        if(formName=='CAR Manager Huddle Observation'){  
            for(Task huddleTask : [SELECT Id, Subject, CreatedDate FROM Task WHERE CreatedById =: carMgr AND recordTypeId=:huddleRecordTypeName AND Status='Completed' ORDER BY CreatedDate DESC]){
                String huddleDate = String.ValueOf(huddleTask.CreatedDate);
                activityList.addHuddleActivity(new ObservationController.HuddleActivity(huddleTask.Subject+ ' - '+huddleDate, huddleTask.Id, huddleTask.CreatedDate));
            }
        }
        
        return activityList;
    }
    
    @RemoteAction
    global static WalkAlongData saveData(WalkAlongData walkAlongData,String propString) {        
        return observationUtils.saveSubmitFeedback(walkAlongData,propString,false);     
    }
    
    @RemoteAction
    global static WalkAlongData submitWalkAlong(WalkAlongData walkAlongData,String propString) {                
        return observationUtils.saveSubmitFeedback(walkAlongData,propString,true);
    }

    @RemoteAction
    global static WalkAlongData getFeedbackForXsp(String xspId, String formName, String cocheeId, String activityId){
        return observationUtils.getFeedbackForXsp(formName,xspId,cocheeId,activityId); 
    }
    
    Set<String> originalvalues = new Set<String>{'A','B','C','D','E','F','G'};
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
     
    public ObservationController (){
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