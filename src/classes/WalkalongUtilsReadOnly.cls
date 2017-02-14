/**********************************************************
* Page Name: WalkalongUtilsReadOnly
* Author: Ashish Sonawane, Accenture
* Date: 21-March-2016 
* Description: Use to show walkalong in readonly mode to users  
* Last Modified by:Revan Kumar
***********************************************************/
 
global class WalkalongUtilsReadOnly{
  
 
   public boolean flag {get; set;}
   global static String strAsm = 'Area Sales Manager';
   global static String strSDM = 'Sales Development Manager';
   //global static String strAsm = 'Direct Sales Manager';
   //global static String strSDM = 'Direct Sales Supervisor';
   global static String AreaofFocusNotesVal = 'Area of Focus - Notes';
   global static String XfinitySalesExecutive = 'Xfinity_Sales_Executive';
   global static String carDirector = 'Coach_CAR_Director_Manager';
   global static string strNotesVal {get;set;}   
   global static string sfdcIFrameHost = 'sfdcIFrameHost';
   global static string sfdcIFrameOrigin = 'sfdcIFrameOrigin';
   global static string retURL = 'retURL';
   global static string projectone = 'projectone';
   global static string isdtp = 'isdtp';
   global static string p1Val = 'p1';
   global static string MultipleChoice = 'MultipleChoice';
   global static string FreeText = 'FreeText';
   private static final String feedbackDuration = System.Label.WalkAlongFeedbackDuration;
   global string subject{get;set;}
   global String feedback{get;set;}
   
   global WalkalongUtilsReadOnly(){
        subject = System.currentPageReference().getParameters().get('SubjectId');
        feedback = System.currentPageReference().getParameters().get('FeedbackId');
   }
   
   global class Xsp{
        public String name {get; set;}
        public Boolean xspLogin{get;set;}
        public Boolean isCarMgr{get;set;}
        public Id id {get; set;} 
        public Xsp(String name, Id id, boolean isXspLogin,  boolean isCarMgr){
            this.name = name;
            this.id = id;
            this.xspLogin = isXspLogin;
            this.isCarMgr = isCarMgr;
        }       
    }
       
    global class XspFeedback{
        public String XspFeedbackName{get; set;}
        public Id id {get; set;} 
        public XspFeedback(String name,Id id){
            this.XspFeedbackName=name;
            this.id=id;
        }       
    }
   
    //Determine if this is SF1 app
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
    
    @RemoteAction
    global static List<Xsp> getXSPList(){
        List<Xsp> xspList = new List<Xsp>();
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> carMgrPSAList = new List<PermissionSetAssignment>();
        String profileName = [SELECT Id, Profile.Name FROM User WHERE Id =: UserInfo.getUserId()][0].Profile.Name; 
        
        //Check logged in User is a XSE(XSP User with XfinitySalesExecutive permission set) User or XSP User
        if(profileName.equalsIgnoreCase(System.Label.DSRProfileName)){
            List<PermissionSet> xsePermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name =: XfinitySalesExecutive Limit 1];
            if(!xsePermissionSet.isEmpty()){
                psaList = [SELECT Id, Assignee.Name, AssigneeId FROM PermissionSetAssignment 
                                  WHERE PermissionSetId =: xsePermissionSet[0].Id and AssigneeId=:UserInfo.getUserId()];
            }                     
        }
        
        //Check logged in User is a Car Director(Car Manager User with "Coach - CAR Director/Manager" permission set) User        
        List<PermissionSet> carDirectorPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name =: carDirector Limit 1];
        if(!carDirectorPermissionSet.isEmpty()){
            carMgrPSAList = [SELECT Id, Assignee.Name, AssigneeId FROM PermissionSetAssignment 
                              WHERE PermissionSetId =: carDirectorPermissionSet[0].Id and AssigneeId=:UserInfo.getUserId()];
        }                     
       
        
        /*if(profileName.equalsIgnoreCase(System.label.Xfinity_CAR_ProfileName)){
            xspList.add(new Xsp(UserInfo.getName(),UserInfo.getUserId(),true));
        }
        else{
            for(User usr:[SELECT Id, Name FROM User where (ManagerId=:UserInfo.getUserId() or Manager.ManagerId=:UserInfo.getUserId()) and IsActive=true and UserPermissionsWorkDotComUserFeature = true and Profile.Name =: Label.Xfinity_CAR_ProfileName ORDER BY Name ASC])  {// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(usr.Name,usr.Id,false));
            }
        }
        
        for(PermissionSetAssignment itrPer : [SELECT Id, Assignee.name, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: xsePermissionSet.Id and AssigneeId=:UserInfo.getUserId()]){
            for(User usr : [SELECT Id, Name FROM User where (ManagerId=:UserInfo.getUserId() OR Manager.ManagerId=:UserInfo.getUserId()) and IsActive=true and UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC])  {// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(usr.Name,usr.Id,false));
            }          
        }
        
        if(profileName.equalsIgnoreCase(System.Label.DSRProfileName) || profileName.equalsIgnoreCase(System.Label.Retail_Sales_Rep_ProfileName)) {
            xspList.add(new Xsp(UserInfo.getName(),UserInfo.getUserId(),true));    
        }
        else{
            for(User usr:[SELECT Id,Name FROM User where (ManagerId=:UserInfo.getUserId() or Manager.ManagerId=:UserInfo.getUserId() OR Manager.Manager.ManagerId=:UserInfo.getUserId() OR Id=:UserInfo.getUserId()) and IsActive=true and UserPermissionsWorkDotComUserFeature = true and (Profile.Name =: Label.DSRProfileName OR Profile.Name =:strAsm OR Profile.Name =:strSDM OR Profile.Name =: System.Label.Retail_Sales_Rep_ProfileName) ORDER BY Name ASC])  {// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(usr.Name,usr.Id,false));
            }    
        }*/
        
                        
        if((profileName.equalsIgnoreCase(System.Label.DSRProfileName) && psaList.size() == 1) 
                || profileName.equalsIgnoreCase('Sales Develpment Manager') 
                || profileName.equalsIgnoreCase('Retail Sales Manager')
                || carMgrPSAList.size() == 1){             
            for(User userObj : [SELECT Id, Name FROM User WHERE ManagerId=:UserInfo.getUserId() AND IsActive=true AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC]){// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, false));
            }
        }else if(profileName.equalsIgnoreCase('Area Sales Manager')){
            for(User userObj : [SELECT Id, Name FROM User WHERE (ManagerId=:UserInfo.getUserId() OR Manager.ManagerId=:UserInfo.getUserId()) AND IsActive = true AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC]){// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, false));
            }
        }else if(profileName.equalsIgnoreCase('Direct Sales Director')){
            for(User userObj : [SELECT Id, Name FROM User WHERE (ManagerId=:UserInfo.getUserId() OR Manager.ManagerId=:UserInfo.getUserId() OR Manager.Manager.ManagerId=:UserInfo.getUserId()) AND IsActive = true AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC]){// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, false));
            }
        }else if(profileName.equalsIgnoreCase('Xfinity CAR Manager')){
            xspList.add(new Xsp(UserInfo.getName(),UserInfo.getUserId(),true, true));
            for(User userObj : [SELECT Id, Name FROM User WHERE ManagerId =: UserInfo.getUserId() and IsActive=true AND UserPermissionsWorkDotComUserFeature = true ORDER BY Name ASC]){// Updated the query for US609427- WalkAlong Form Enhancements                          
                xspList.add(new Xsp(userObj.Name, userObj.Id, false, true));
            } 
        }else{
            xspList.add(new Xsp(UserInfo.getName(),UserInfo.getUserId(),true, false));
        }                        
        return xspList;
    }
  
    
    @RemoteAction
    global static List<XspFeedback> getXspFeedbackData(string subjectId){
        List<XspFeedback> xspFeedbackList = new List<XspFeedback>();
        Set<String> strRecType = new Set<String> ();
        Integer duration = 0;
        if(feedbackDuration!=null && feedbackDuration.length()>0) {
             duration = Integer.valueOf(feedbackDuration.trim());
        }            
        String query =  'Select Id,PerformanceCycle.RecordType.Name, Name, SubmittedDate  FROM WorkFeedbackRequest WHERE SubjectId =:subjectId and FeedbackRequestState=\'Submitted\' AND CreatedDate = LAST_N_DAYS:'+duration +'order by SubmittedDate  DESC';
        List<WorkFeedBackRequest> lstFeedBackRequest = database.query(query); 
        String strPerRecType;
        for(WorkFeedbackRequest feedback : lstFeedBackRequest){
            System.debug('feedback****'+feedback);
            if(feedback.PerformanceCycle.RecordType.Name.equals(Label.XSP_Ridealong)){
                 xspFeedbackList.add(new XspFeedback(feedback.Name+' - '+feedback.SubmittedDate.Month()+'/'+feedback.SubmittedDate.Day()+'/'+feedback.SubmittedDate.Year(),feedback.Id));
            }
            else {
                 strPerRecType = feedback.PerformanceCycle.RecordType.Name;
                 xspFeedbackList.add(new XspFeedback(feedback.Name+' - '+strPerRecType+' - '+ feedback.SubmittedDate.Month()+'/'+feedback.SubmittedDate.Day()+'/'+feedback.SubmittedDate.Year(),feedback.Id));    
            }
           
        }
        System.debug('xspFeedbackList****'+xspFeedbackList);
        return xspFeedbackList;
        
    }
    
           
    @RemoteAction
    global static WalkalongUtilsReadOnly.WalkAlongData getFeedbackForXsp(String workFeedbackId){
        List<WorkFeedbackRequest> wfrList = new List<WorkFeedbackRequest> ();
        List<PermissionSetAssignment> carMgrPSAList = new List<PermissionSetAssignment>();
        wfrList = [select Id, SelectedProperty__c, Related_1_1_Coaching__r.Name, Huddle_Id__c, Huddle_Name__c, LastModifiedDate,PerformanceCycle.RecordType.Name,SubmittedDate,SubjectId,PerformanceCycle.Name,Score__c,Recipient.Name,Subject.Name,QuestionSetId from WorkFeedbackRequest where id=:workFeedbackId];  
        //List<WorkFeedbackQuestion> wfrFeedBackQuestion = new List<WorkFeedbackQuestion> ();
        WalkalongUtilsReadOnly.WalkAlongData data = new WalkalongUtilsReadOnly.WalkAlongData();
        if(wfrList.size()== 1){
            
            //Check logged in User is a Car Director(Car Manager User with "Coach - CAR Director/Manager" permission set) User            
            List<PermissionSet> carDirectorPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name =: carDirector Limit 1];
            if(!carDirectorPermissionSet.isEmpty()){
                carMgrPSAList = [SELECT Id, Assignee.Name, AssigneeId FROM PermissionSetAssignment 
                                  WHERE PermissionSetId =: carDirectorPermissionSet[0].Id and AssigneeId=:UserInfo.getUserId()];
            }                     
           
            if(carMgrPSAList.size() == 1){
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
            data.submittedDate = wfrList[0].SubmittedDate.Month()+'/'+wfrList[0].SubmittedDate.Day()+'/'+wfrList[0].SubmittedDate.Year();
            data.score = wfrList[0].Score__c; 
            data.requestId=wfrList[0].Id;
            data.lastSavedDate=wfrList[0].LastModifiedDate.format();
            data.showNotes=false;
            data.selectedXSP=wfrList[0].SubjectId;
            data.propList = wfrList[0].SelectedProperty__c;
           
            if(wfrList[0].Huddle_Id__c != null){
                Task huddleTask = [SELECT Id, Subject, CreatedDate FROM Task WHERE Id =: wfrList[0].Huddle_Id__c];
                String huddleDate = String.ValueOf(huddleTask.CreatedDate);
                if(huddleTask.Subject != ''){
                    data.huddleActivity = huddleTask.Subject+ ' - '+huddleDate;
                }
            }
            data.oneOnOneCoachingActivity = wfrList[0].Related_1_1_Coaching__r.Name;
            data.recordTypeName = strXSPWalk;
            Map<String,List<WorkFeedback>> xspFeedbacks = new Map<String,List<WorkFeedback>>();
            List<WorkFeedback> feedbackList = [SELECT Id, Question.Name, Question.Text, Question.Category__c,
                                                        Feedback,Question.Number,Question.Type
                                                        FROM WorkFeedback WHERE RequestId=:wfrList[0].Id
                                                        order by Question.Number];
            
                                    
            Integer currIdx=0;
            //Overallnotes            
            data.overallNotes=feedbackList[currIdx].feedback;  
            data.overallNotesQnId=feedbackList[currIdx].Id;

            //Area of Focus is the first two questions
            currIdx++;
            data.areaOfFocus=feedbackList[currIdx].feedback;
            data.areaOfFocusQnId=feedbackList[currIdx].Id;
            
            
            
            //Area of Focus Notes is the first two questions
            if(feedbackList[currIdx+1].Question.Name == AreaofFocusNotesVal) {
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
                            strNotesVal = strNotesVal + ' ' + question.notes;                      
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
    /*
    @RemoteAction
    global static WalkalongUtilsReadOnly.WalkAlongData getFeedbackForXsp1(String FeedbackId){
        
        WalkalongUtilsReadOnly.WalkAlongData data = new WalkalongUtilsReadOnly.WalkAlongData();
        
        String profileCheck = [Select Id, Profile.Name From User WHERE id=:UserInfo.getUserId()][0].Profile.Name;  
        PermissionSet objPermissionSet = [SELECT Id, Name FROM PermissionSet WHERE NAME =:XfinitySalesExecutive Limit 1];
        
        if(profileCheck.equalsIgnoreCase(System.label.Xfinity_CAR_ProfileName)){
                data.profileFlag=true;
        }
        else{
            for(User usr:[select Id,Name from User where (ManagerId=:UserInfo.getUserId() or Manager.ManagerId=:UserInfo.getUserId()) and IsActive=true and UserPermissionsWorkDotComUserFeature = true and Profile.Name =: Label.Xfinity_CAR_ProfileName])  {// Updated the query for US609427- WalkAlong Form Enhancements                          
                data.profileFlag =false;
            }
        }  
        Set<String> myset = new Set<String> ();
        for(PermissionSetAssignment itrPer : [SELECT Id,assignee.name,assigneeid FROM PermissionSetAssignment WHERE PermissionSetId =:objPermissionSet.Id and AssigneeId=:UserInfo.getUserId()]){
           myset.add(itrPer.AssigneeId);
           for(User usr:[select Id,Name from User where ManagerId=:UserInfo.getUserId() and IsActive=true and UserPermissionsWorkDotComUserFeature = true])  {// Updated the query for US609427- WalkAlong Form Enhancements                          
                   data.profileFlag = false;
           }          
        }
        if(profileCheck.equalsIgnoreCase(System.Label.DSRProfileName) && myset.isEmpty()) {
             data.profileFlag = true;    
        }
        else {
            for(User usr:[select Id,Name from User where (ManagerId=:UserInfo.getUserId() or Manager.ManagerId=:UserInfo.getUserId() OR Manager.Manager.ManagerId=:UserInfo.getUserId() OR Id=:UserInfo.getUserId()) and IsActive=true and UserPermissionsWorkDotComUserFeature = true and (Profile.Name =: Label.DSRProfileName OR Profile.Name =:strAsm OR Profile.Name =:strSDM)])  {// Updated the query for US609427- WalkAlong Form Enhancements                          
                data.profileFlag= false;
            }    
        }
        List<WorkFeedbackRequest> wfrList = new List<WorkFeedbackRequest> ();
        wfrList = [select Id,SelectedProperty__c,LastModifiedDate,PerformanceCycle.RecordType.Name,SubmittedDate,SubjectId,PerformanceCycle.Name,Score__c,Recipient.Name,Subject.Name,QuestionSetId from WorkFeedbackRequest where id=:FeedbackId];  
        List<WorkFeedbackQuestion> wfrFeedBackQuestion = new List<WorkFeedbackQuestion> ();
        
        if(wfrList.size()== 1){
            String strXSPWalk;
            wfrFeedBackQuestion = [SELECT Id, Name FROM WorkFeedbackQuestion WHERE QuestionSetId=:wfrList[0].QuestionSetId];
            //data.selectedXSP = xspUserId;
            strXSPWalk = wfrList[0].PerformanceCycle.RecordType.Name;
            data.peformanceCycle = wfrList[0].PerformanceCycle.Name;
            data.feedbackFrom = wfrList[0].Recipient.Name;
            data.feedbackTo = wfrList[0].Subject.Name;
            data.submittedDate = wfrList[0].SubmittedDate.Month()+'/'+wfrList[0].SubmittedDate.Day()+'/'+wfrList[0].SubmittedDate.Year();
            data.score = wfrList[0].Score__c; 
            data.requestId=wfrList[0].Id;
            data.lastSavedDate=wfrList[0].LastModifiedDate.format();
            data.showNotes=false;
            data.selectedXSP=wfrList[0].SubjectId;
            data.propList = wfrList[0].SelectedProperty__c;
            data.recordTypeName = strXSPWalk;
            String feedbackTyp = 'Feedback about' +data.feedbackTo+ ' - '+strXSPWalk +' - '+data.submittedDate;
            data.feedbackType=feedbackTyp ;
            Map<String,List<WorkFeedback>> xspFeedbacks = new Map<String,List<WorkFeedback>>();
            List<WorkFeedback> feedbackList = [ select  Id,Question.Name,Question.Text,Question.Category__c,
                                                        Feedback,Question.Number,Question.Type
                                                from WorkFeedback 
                                                where RequestId=:wfrList[0].Id
                                                order by Question.Number];
            
                                    
            Integer currIdx=0;
            //Overallnotes
            data.overallNotes=feedbackList[currIdx].feedback;
            data.overallNotesQnId=feedbackList[currIdx].Id;
        
            //Area of Focus is the first two questions
            currIdx++;
            data.areaOfFocus=feedbackList[currIdx].feedback;
            data.areaOfFocusQnId=feedbackList[currIdx].Id;
            
         //  Area of Focus Notes is the first two questions 
         
        */ 
            /*if(feedbackList[currIdx+1].Question.Name == AreaofFocusNotesVal) {
                currIdx++;
                data.areaOfFocusNotes=feedbackList[currIdx].feedback;
                data.areaOfFocusQnNotesId=feedbackList[currIdx].Id; 
            }*/
            
            
         /*   if(!Test.isRunningTest()){
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
                                strNotesVal = strNotesVal + ' ' + question.notes;
                       //     System.debug('>>>>>>>>>>>>Feedback feedback'+question.notes);
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
        
    }*/
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
        
        public String huddleActivity {get; set;}
        public String oneOnOneCoachingActivity {get; set;}
        public Boolean isCarDirector {get; set;}
        
       // public Integer scorePct {get; set;}
        public String overallRating {get; set;}
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
     
    }
}