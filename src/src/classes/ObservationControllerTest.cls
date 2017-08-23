/**************************************************************************************************
Name : ObservationControllerTest
Description : This test class created to cover the classes ObservationController and ObservationUtils.
Author : Ashish Srivastava
***************************************************************************************************/
@isTest
public class ObservationControllerTest{
        private static User DSSupUser,DSRepUser,carDir,carMgr,carUser,rsruser,rsmuser;
        private static Profile CARProfile,CARManagerProfile,RSRProfile,RSMManagerProfile; 
        private static RecordType xspRecType,oneOnOneRecordType,carHuddleObservationRecordType,carTeamHuddleRecordType,carEventObservationRecordType,carFieldObservationRecordType,indirecttObservationRecordType;
        private static ObservationForm__mdt objObsForm;
        private static TriggerSettings__c ts1, ts2;
        private static User loggedInUser = [Select Id from User where Id=:UserInfo.getUserId()];
        
        @isTest
        static void testMethod1() {
        
        
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.ActivityGoalCommissionCycle();
        
        xspRecType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name = :Label.XSP_Ridealong LIMIT 1];
        objObsForm  = [SELECT Feedback_Form__c,Profile__c FROM ObservationForm__mdt LIMIT 1];
        
        DSSupUser = WorkTestDataUtility.createDSSupervisorUser();
        DSRepUser = WorkTestDataUtility.createDSRepUser();
        
        
        /* Assign PermissionSet to Coresponding Profile user */
        System.runAs(loggedInUser){                     
                AssignPermissionSet('SalesSpace_Coach_Access_SDM',DSSupUser.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_XSP',DSRepUser.Id);
                AssignPermissionSet('Xfinity_Sales_Executive',DSRepUser.Id);
        }
        MDU_Property__c propertyObj = new MDU_Property__c();
        propertyObj.Name = 'Test Property';
        propertyObj.Assigned_CAR__c = DSRepUser.Id;
        propertyObj.MDU_State__c = 'Indiana';
        propertyObj.System__c = '04 - Neptune Beach';
        propertyObj.Industry_Type__c = 'Multi Family';
        propertyObj.Property_Type__c = 'Assisted Living';
        propertyObj.Contracting_Org_Type__c = 'Developer';
        insert propertyObj;
        
        WorkPerformanceCycle wperformance = new WorkPerformanceCycle();
        wperformance.Name = 'Performance1';
        wperformance.ActivityFrom = System.Today()-10;
        wperformance.ActivityTo = System.Today()+30;
        wperformance.RecordTypeId = xspRecType.Id;
        wperformance.State = 'Setup';
        insert wperformance ;
        
        WorkFeedbackQuestionSet wquestion = new WorkFeedbackQuestionSet();
        wquestion.Name = 'Test Name';
        wquestion.PerformanceCycleId = wperformance.Id;
        wquestion.FeedbackType = 'CycleManager';
        wquestion.duedate = System.Today()+30;
        insert wquestion;
       
        List<WorkFeedbackQuestion> feedbackQuestionList = new List<WorkFeedbackQuestion>();
        WorkFeedbackQuestion wquest = new WorkFeedbackQuestion ();
        wquest.QuestionSetId = wquestion.Id;
        wquest.Name = 'Prepare - Energy';
        wquest.Text = 'Prepare - Energy';
        wquest.detail = 'Test Detail';
        wquest.Number = 1;
        wquest.Type = 'Freetext';
        wquest.Category__c = 'Prepare - Energy';
        wquest.Section__c = 'Observation';
        wquest.Weight__c = 20;
        feedbackQuestionList.add(wquest);

        WorkFeedbackQuestion wquestcat = new WorkFeedbackQuestion ();
        wquestcat.QuestionSetId = wquestion.Id;
        wquestcat.Name = 'Overall Notes1';
        wquestcat.Text = 'Overall Notes1';
        wquestcat.detail = 'Test Detail1';
        wquestcat.Number = 2;
        wquestcat.Type = 'Freetext';
        wquestcat.Category__c = null;
        wquestcat.Section__c = 'Common';
        wquestcat.Weight__c = 20;
        feedbackQuestionList.add(wquestcat);

        WorkFeedbackQuestion wquest2 = new WorkFeedbackQuestion ();
        wquest2.QuestionSetId = wquestion.Id;
        wquest2.Name = 'Engage';
        wquest2.Text = 'Engage';
        wquest2.Choices= 'Needs Improvement\nAchieved Expectations\nHighly Effective';
        wquest2.Number = 30;
        wquest2.Type = 'MultipleChoice';
        wquest2.Category__c = 'Engage';
        wquest2.Section__c = 'Observation';
        wquest2.Weight__c = 10;
        feedbackQuestionList.add(wquest2);

        WorkFeedbackQuestion wquest3 = new WorkFeedbackQuestion ();
        wquest3.QuestionSetId = wquestion.Id;
        wquest3.Name = 'TestEngage';
        wquest3.Text = 'TestEngage';
        wquest3.Choices= 'Needs Improvement\nAchieved Expectations';
        wquest3.Number = 32;
        wquest3.Type = 'MultipleChoice';
        wquest3.Category__c = 'Engage';
        wquest3.Section__c = 'Observation';
        wquest3.Weight__c = 10;
        feedbackQuestionList.add(wquest3);

        WorkFeedbackQuestion wquest4 = new WorkFeedbackQuestion ();
        wquest4.QuestionSetId = wquestion.Id;
        wquest4.Name = 'TestEngage1';
        wquest4.Text = 'TestEngage1';
        wquest4.Number = 34;
        wquest4.Type = 'Freetext';
        wquest4.Category__c = 'testEngage';
        wquest4.Section__c = 'Observation';
        wquest4.Weight__c = 10;
        feedbackQuestionList.add(wquest4);

        Database.insert(feedbackQuestionList,false);
        
        WorkFeedbackRequest workfeedbackrequest;
        WorkFeedbackRequest workfeedbackrequest1;    
        System.runAs(DSSupUser){
            
            workfeedbackrequest = new WorkFeedbackRequest(RecipientId = DSSupUser.Id, SubjectId = DSRepUser.Id,
                Type__c= 'Walkalong',AdHocQuestion = 'How is the feedback1',Score__c = 10,FeedbackRequestState='Draft');
            workfeedbackrequest1 = new WorkFeedbackRequest(RecipientId = DSSupUser.Id, SubjectId = DSRepUser.Id,
                Type__c= 'Walkalong',AdHocQuestion = 'How is the feedback2',Score__c = 10,FeedbackRequestState='Draft');
            insert new List<WorkFeedbackRequest>{workfeedbackrequest,workfeedbackrequest1};
             ObservationUtils.getFeedbackForXsp('XSP Walkalong',DSRepUser.Id,null,null,null);
        }
        
        List<ObservationController.Question> question = new List<ObservationController.Question>();
        ObservationController.Question ques = new ObservationController.Question();  
        ques.name = 'Contacts';
        ques.text = 'Strength';
        ques.rating ='Strength';
        ques.notes ='Confidence';
        ques.showNotes = true;
        ques.showHelpText  = true;
        ques.qnId  = null;
        ques.qnNotesId = null;
        ques.section = 'Observations';
        question.add(ques);
        
        List<ObservationController.Category> categories = new List<ObservationController.Category>();
        ObservationController.Category category = new ObservationController.Category();
        category.category = 'Contacts';
        category.text ='Prepare - Energy';
        category.rating = 'Highly Effective';
        category.showNotes = true;
        category.categoryQnId = null;
        category.weights = 200;
        category.questions = question;
        category.addQuestion(ques);
        categories.add(category);
        
        ObservationController.Section section = new ObservationController.Section ();
        section.name= 'Observations';
        section.showSection = true;
        section.questions = question;
        section.categories = categories;
        section.addQuestion(ques);
        section.addCategory(category);

        ObservationController.WalkAlongData walkAlongData = new ObservationController.WalkAlongData();
        walkAlongData.walkAlongStarted = true; 
        //walkAlongData.requestId =  wfrList[0].Id;
        walkAlongData.requestId = null;
        walkAlongData.showSection = true;
        walkAlongData.walkAlongStopped = true;
        walkAlongData.startTime ='04:56:00';
        walkAlongData.endTime ='09:56:00';
        walkAlongData.showNotes = true;
        walkAlongData.lastSavedDate = String.valueOf(system.today());
        walkAlongData.score = 100;
        walkAlongData.scorePct = 100;
        walkAlongData.overallRating = 'Achieved Expectations';
        walkAlongData.propString = 'Test Prop';
        walkAlongData.selectedPersonCoach = 'Test Coach';
        walkAlongData.selectedPersonObserved = 'Test Person Observed';
        walkAlongData.selectedActivity = 'Test Activity';
        walkAlongData.selectedXSP = DSRepUser.Id;
        walkAlongData.selectedRecordType =xspRecType.Name;
        walkAlongData.recordTypeName = 'Property Visit';
        walkAlongData.addSection(section);
        
        ObservationController.Xsp xsp = new ObservationController.Xsp(DSRepUser.name,DSRepUser.Id,DSRepUser.Profile.Name);
        ObservationController.getXSPList();    
        ObservationController.RecordTypeCustom recordtypeCustom = new ObservationController.RecordTypeCustom(xspRecType.name,xspRecType.Id);
        ObservationController.RecordTypePerformace recordtypecarval = 
        	new ObservationController.RecordTypePerformace('XSP Observation',new List<ObservationController.RecordTypeCustom> {recordtypeCustom});
        ObservationController.getRecordTypePerformCycleList();  
        
        ObservationController.saveData(walkAlongData,'@@@@@Test@@@@');
        ObservationUtils.getFeedbackForXsp('XSP Walkalong',DSRepUser.Id,null,null,null);
        ObservationController.submitWalkAlong(walkAlongData,'@@@@@Test@@@@');
        ObservationUtils.getFeedbackForXsp('XSP Walkalong',DSRepUser.Id,null,null,null);
        ObservationUtils.calculateScore(walkAlongData);
        ObservationController obCls = new  ObservationController ();
        obCls.getSF1();
   }
   
   @isTest
   static void testMethod2(){
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.ActivityGoalCommissionCycle();
        
        CARProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR' limit 1];
        CARManagerProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' limit 1];
        
        ts1= new TriggerSettings__c();
        ts1.Name = 'UserTrigger';
        ts1.isActive__c = true;
         
        ts2 = new TriggerSettings__c();
        ts2.Name = 'OneOnOnecoachingTrigger';
        ts2.isActive__c = true;
         
        insert new List<TriggerSettings__c>{ts1,ts2};
        
        oneOnOneRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name = 'CAR Manager 1:1 Observation' LIMIT 1];
     
        DSRepUser = WorkTestDataUtility.createDSRepUser();
        
        carDir = new User(Alias = 'DIR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARDIR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARManagerProfile.Id,
                                      Username = 'userTest1' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId1'+randomstr,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
        insert carDir;
        
        carMgr = new User(Alias = 'MGR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARMGR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARManagerProfile.Id,
                                      Username = 'userTest3' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId2'+randomstr, ManagerId = carDir.Id,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
                                      
        insert carMgr;
                                      
        carUser = new User(Alias = 'CAR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest3@SampleTest.com',
                                      LastName='CAR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARProfile.Id,
                                      Username = 'userTest5' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId3'+randomstr, ManagerId = carMgr.Id,
                                      EmployeeNumber = 'Emp3' + randomstr.substring(0,4));
                                      
        insert carUser;
        
        loggedInUser.Terms_and_Conditions_Accepted__c = System.Today();
        update loggedInUser;
        
        GoalTemplateDates__c templateCustomSet = new GoalTemplateDates__c();
        templateCustomSet.Name = 'Property Lab CAR';
        templateCustomSet.Current_Period_Start_Date__c = system.today().addDays(-2);
        templateCustomSet.Current_Period_Due_Date__c = system.today().addDays(+2);
        insert templateCustomSet;
       
        /* Assign PermissionSet to Coresponding Profile user */
        System.runAs(loggedInUser){                     
                AssignPermissionSet('Coach_CAR_Director_Manager',carDir.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_CAR',carUser.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_CAR_Manager',carMgr.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_XSP',DSRepUser.Id);
                AssignPermissionSet('Xfinity_Sales_Executive',DSRepUser.Id);
        }

        WorkPerformanceCycle wperformance = new WorkPerformanceCycle();
        wperformance.Name = 'Performance2';
        wperformance.ActivityFrom = System.Today()-5;
        wperformance.ActivityTo = System.Today()+5;
        wperformance.RecordTypeId = oneOnOneRecordType.Id;
        wperformance.State = 'Setup';
        insert wperformance ;
        
        WorkFeedbackQuestionSet wquestion = new WorkFeedbackQuestionSet();
        wquestion.Name = 'Test Name';
        wquestion.PerformanceCycleId = wperformance.Id;
        wquestion.FeedbackType = 'CycleManager';
        wquestion.duedate = System.Today()+30;
        insert wquestion;
        
        WorkFeedbackQuestion wquest1 = new WorkFeedbackQuestion ();
        wquest1.QuestionSetId = wquestion.Id;
        wquest1.Name = 'Engage';
        wquest1.Text = 'Engage';
        wquest1.detail = 'Test Detail';
        wquest1.Number = 1;
        wquest1.Type = 'MultipleChoice';
        wquest1.Choices= 'Needs Improvement\nAchieved Expectations\nHighly Effective';
        wquest1.Category__c = null;
        wquest1.Section__c = 'Common';
        wquest1.Weight__c = 20;
        insert wquest1;
        
        WorkFeedbackQuestion wquest2 = new WorkFeedbackQuestion ();
        wquest2.QuestionSetId = wquestion.Id;
        wquest2.Name = 'Prepare - Energy';
        wquest2.Text = 'Prepare - Energy';
        wquest2.detail = 'Test Detail2';
        wquest2.Number = 10;
        wquest2.Type = 'MultipleChoice';
        wquest2.Choices= 'Needs Improvement\nAchieved Expectations\nHighly Effective';
        wquest2.Category__c = 'Engage';
        wquest2.Section__c = 'Common';
        wquest2.Weight__c = 20;
        insert wquest2;
        
        List<ObservationController.Question> question = new List<ObservationController.Question>();
        ObservationController.Question ques = new ObservationController.Question();  
        ques.name = 'Contacts';
        ques.text = 'Strength';
        ques.rating ='Strength';
        ques.notes ='Confidence';
        ques.showNotes = true;
        ques.showHelpText  = true;
        ques.qnId  = null;
        ques.qnNotesId = null;
        ques.section = 'Common';
        question.add(ques);
        
        List<ObservationController.Category> categories = new List<ObservationController.Category>();
        ObservationController.Category category = new ObservationController.Category();
        category.category = 'Contacts';
        category.text ='Prepare - Energy';
        category.rating = 'Achieved Expectations';
        category.showNotes = true;
        category.categoryQnId = null;
        category.weights = 200;
        category.questions = question;
        category.addQuestion(ques);
        categories.add(category);
        
        ObservationController.Section section = new ObservationController.Section ();
        section.name= 'Common';
        section.showSection = true;
        section.questions = question;
        section.categories = categories;
        section.addQuestion(ques);
        section.addCategory(category);
        
       Test.startTest();
       
           WorkCoaching workCoach = new WorkCoaching();
           workCoach.coachId = carMgr.Id;
           workCoach.CoachedId = carUser.Id;
           insert workCoach;
        
           One_One_Coaching__c oneOneCoach = new One_One_Coaching__c();
           oneOneCoach.Coaching__c = workCoach.Id;
           oneOneCoach.Status__c = 'Submitted';
           insert oneOneCoach;
           
            WorkFeedbackRequest WFR = new WorkFeedbackRequest();
            WFR.RecipientId = carMgr.Id;
            WFR.Type__c= 'CycleManager';
            WFR.Score__c = 10;
            WFR.FeedbackRequestState ='Draft';
            WFR.submittedDate = System.today();
            WFR.SubjectId = DSRepUser.Id; 
            WFR.SubmitFeedbackToId = carMgr.Id;
            WFR.QuestionSetId = wquestion.Id;
            WFR.RelatedObjectId = wperformance.Id;
            WFR.Person_Coach__c = carUser.Id;
            WFR.Related_1_1_Coaching__c = oneOneCoach.Id;
            insert WFR;
            ObservationUtils.getFeedbackForXsp('CAR Manager 1:1 Observation',DSRepUser.Id,carUser.Id,oneOneCoach.Id,null);
        ObservationController.WalkAlongData walkAlongData = new ObservationController.WalkAlongData();
        walkAlongData.walkAlongStarted = true; 
        walkAlongData.requestId = null;
        walkAlongData.showSection = true;
        walkAlongData.walkAlongStopped = true;
        walkAlongData.startTime ='04:56:00';
        walkAlongData.endTime ='09:56:00';
        walkAlongData.showNotes = true;
        walkAlongData.lastSavedDate = String.valueOf(system.today());
        walkAlongData.score = 100;
        walkAlongData.scorePct = 100;
        walkAlongData.overallRating = 'Achieved Expectations';
        walkAlongData.propString = 'Test Prop';
        walkAlongData.selectedPersonCoach = carUser.Id;
        walkAlongData.selectedActivity = oneOneCoach.Id;
        walkAlongData.selectedXSP = DSRepUser.Id;
        walkAlongData.selectedRecordType = oneOnOneRecordType.Name;
        walkAlongData.recordTypeName = 'CAR Manager 1:1 Observation';
        walkAlongData.addSection(section);
           
            ObservationController.activityData actData = new ObservationController.activityData();
            ObservationController.PersonCoach personCoach = new ObservationController.PersonCoach(carUser.name,carUser.Id);
            ObservationController.OneOneCoachingData oneOneCoachData = new ObservationController.OneOneCoachingData('keyCoachString',oneOneCoach.Name,oneOneCoach.Id);
            actData.addPersonCoach(personCoach);
            actData.addOneOneCoachingData(oneOneCoachData);
            ObservationController.getActivitiesData(carMgr.Id,'CAR Manager 1:1 Observation');
            
            ObservationController.saveData(walkAlongData,'@@@@@Test@@@@');
            ObservationUtils.getFeedbackForXsp('CAR Manager 1:1 Observation',DSRepUser.Id,carUser.Id,oneOneCoach.Id,null);
            ObservationController.submitWalkAlong(walkAlongData,'@@@@@Test@@@@');
            
            PageReference pageRef = Page.ObservationForm;
            Test.setCurrentPage(pageRef);
            ObservationController obCon = new ObservationController();
            obCon.getunSelectedValues();
            obCon.getSelectedValues();
            obCon.selectClick();
            obCon.unselectclick();
       Test.stopTest();
   }
   
   @isTest
   static void testMethod3(){
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.ActivityGoalCommissionCycle();
        
        CARProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR' limit 1];
        CARManagerProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' limit 1];
        
        ts1= new TriggerSettings__c();
        ts1.Name = 'UserTrigger';
        ts1.isActive__c = true;
         
        ts2 = new TriggerSettings__c();
        ts2.Name = 'OneOnOnecoachingTrigger';
        ts2.isActive__c = true;
         
        insert new List<TriggerSettings__c>{ts1,ts2};
        
        carHuddleObservationRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name = 'CAR Manager Huddle Observation' LIMIT 1];
        carTeamHuddleRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType='Task' AND Name = 'CAR Team Huddle' LIMIT 1];
        
        DSRepUser = WorkTestDataUtility.createDSRepUser();
        
        carDir = new User(Alias = 'DIR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARDIR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARManagerProfile.Id,
                                      Username = 'userTest1' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId1'+randomstr,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
        insert carDir;
        
        carMgr = new User(Alias = 'MGR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARMGR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARManagerProfile.Id,
                                      Username = 'userTest3' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId2'+randomstr, ManagerId = carDir.Id,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
                                      
        insert carMgr;
                                      
        carUser = new User(Alias = 'CAR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest3@SampleTest.com',
                                      LastName='CAR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARProfile.Id,
                                      Username = 'userTest5' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId3'+randomstr, ManagerId = carMgr.Id,
                                      EmployeeNumber = 'Emp3' + randomstr.substring(0,4));
                                      
        insert carUser;
        
        loggedInUser.Terms_and_Conditions_Accepted__c = System.Today();
        update loggedInUser;
        
        /* Assign PermissionSet to Coresponding Profile user */
        System.runAs(loggedInUser){                     
                AssignPermissionSet('Coach_CAR_Director_Manager',carDir.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_CAR',carUser.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_CAR_Manager',carMgr.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_XSP',DSRepUser.Id);
                AssignPermissionSet('Xfinity_Sales_Executive',DSRepUser.Id);
        }

        WorkPerformanceCycle wperformance = new WorkPerformanceCycle();
        wperformance.Name = 'Performance3';
        wperformance.ActivityFrom = System.Today()-5;
        wperformance.ActivityTo = System.Today()+5;
        wperformance.RecordTypeId = carHuddleObservationRecordType.Id;
        wperformance.State = 'Setup';
        insert wperformance ;
        
        WorkFeedbackQuestionSet wquestion = new WorkFeedbackQuestionSet();
        wquestion.Name = 'Test Name';
        wquestion.PerformanceCycleId = wperformance.Id;
        wquestion.FeedbackType = 'CycleManager';
        wquestion.duedate = System.Today()+30;
        insert wquestion;
        
        WorkFeedbackQuestion wquest1 = new WorkFeedbackQuestion ();
        wquest1.QuestionSetId = wquestion.Id;
        wquest1.Name = 'Engage';
        wquest1.Text = 'Engage';
        wquest1.detail = 'Test Detail';
        wquest1.Number = 1;
        wquest1.Type = 'FreeText';
        wquest1.Category__c = null;
        wquest1.Section__c = 'Observations';
        wquest1.Weight__c = 20;
        insert wquest1;

        List<ObservationController.Question> question = new List<ObservationController.Question>();
        ObservationController.Question ques = new ObservationController.Question();  
        ques.name = 'Contacts';
        ques.text = 'Strength';
        ques.rating ='Strength';
        ques.notes ='Confidence';
        ques.showNotes = true;
        ques.showHelpText  = true;
        ques.qnId  = null;
        ques.qnNotesId = null;
        ques.section = 'Observations';
        question.add(ques);
        
        List<ObservationController.Category> categories = new List<ObservationController.Category>();
        ObservationController.Category category = new ObservationController.Category();
        category.category = 'Contacts';
        category.text ='Prepare - Energy';
        category.rating = 'Exceptional';
        category.showNotes = true;
        category.categoryQnId = null;
        category.weights = 200;
        category.questions = question;
        category.addQuestion(ques);
        categories.add(category);
        
        ObservationController.Section section = new ObservationController.Section ();
        section.name= 'Observations';
        section.showSection = true;
        section.questions = question;
        section.categories = categories;
        section.addQuestion(ques);
        section.addCategory(category);
        
       Test.startTest();
       Task huddleTask;
       GoalTemplateDates__c templateCustomSet = new GoalTemplateDates__c();
       templateCustomSet.Name = 'Property Lab CAR';
       templateCustomSet.Current_Period_Start_Date__c = system.today().addDays(-2);
       templateCustomSet.Current_Period_Due_Date__c = system.today().addDays(+2);
       insert templateCustomSet;

        system.runAs(carMgr){
           huddleTask = new Task();
           huddleTask.Subject = 'Observation Huddle';
           huddleTask.CAR_Process__c = 'Create a Winning Strategy';
           huddleTask.CAR_Huddle_Forum_Name__c = '6. Replicating Success';
           huddleTask.RecordTypeId = carTeamHuddleRecordType.Id;
           huddleTask.Status='Completed';
           huddleTask.OwnerId = carMgr.Id;
           huddleTask.ActivityDate = system.today();
           huddleTask.Comments__c = 'Test Class';
           insert huddleTask;
        }
            WorkFeedbackRequest WFR = new WorkFeedbackRequest();
            WFR.RecipientId = carMgr.Id;
            WFR.Type__c= 'CycleManager';
            WFR.Score__c = 10;
            WFR.FeedbackRequestState ='Draft';
            WFR.submittedDate = System.today();
            WFR.SubjectId = DSRepUser.Id; 
            WFR.SubmitFeedbackToId = carMgr.Id;
            WFR.QuestionSetId = wquestion.Id;
            WFR.RelatedObjectId = wperformance.Id;
            WFR.Person_Coach__c = carUser.Id;
            //WFR.Related_1_1_Coaching__c = oneOneCoach.Id;
            insert WFR;
            ObservationUtils.getFeedbackForXsp('CAR Manager Huddle Observation',DSRepUser.Id,carUser.Id,huddleTask.Id,null);
            
        ObservationController.WalkAlongData walkAlongData = new ObservationController.WalkAlongData();
        walkAlongData.walkAlongStarted = true; 
        walkAlongData.requestId = null;
        walkAlongData.showSection = true;
        walkAlongData.walkAlongStopped = true;
        walkAlongData.startTime ='04:56:00';
        walkAlongData.endTime ='09:56:00';
        walkAlongData.showNotes = true;
        walkAlongData.lastSavedDate = String.valueOf(system.today());
        walkAlongData.score = 100;
        walkAlongData.scorePct = 100;
        walkAlongData.overallRating = 'Achieved Expectations';
        walkAlongData.propString = 'Test Prop';
        walkAlongData.selectedPersonCoach = carUser.Id;
        walkAlongData.selectedActivity = huddleTask.Id;
        walkAlongData.selectedXSP = DSRepUser.Id;
        walkAlongData.selectedRecordType = carHuddleObservationRecordType.Name;
        walkAlongData.recordTypeName = 'CAR Manager Huddle Observation';
        walkAlongData.addSection(section);
           
            ObservationController.activityData actData = new ObservationController.activityData();
            ObservationController.HuddleActivity huddleData = new ObservationController.HuddleActivity(huddleTask.Subject,huddleTask.Id,System.Now());
            actData.addHuddleActivity(huddleData);
            ObservationController.getActivitiesData(carMgr.Id,'CAR Manager Huddle Observation');
            
            ObservationController.saveData(walkAlongData,'@@@@@Test@@@@');
            ObservationUtils.getFeedbackForXsp('CAR Manager Huddle Observation',DSRepUser.Id,carUser.Id,huddleTask.Id,null);
            ObservationController.submitWalkAlong(walkAlongData,'@@@@@Test@@@@');
            
            PageReference pageRef = Page.ObservationForm;
            Test.setCurrentPage(pageRef);
            ObservationController obCon = new ObservationController();
            obCon.getunSelectedValues();
            obCon.getSelectedValues();
            obCon.selectClick();
            obCon.unselectclick();
       Test.stopTest();
   }
   
   
   @isTest
   static void testMethod4(){
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.ActivityGoalCommissionCycle();
        
        CARProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR' limit 1];
        CARManagerProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' limit 1];
        
        ts1= new TriggerSettings__c();
        ts1.Name = 'UserTrigger';
        ts1.isActive__c = true;
         
        ts2 = new TriggerSettings__c();
        ts2.Name = 'OneOnOnecoachingTrigger';
        ts2.isActive__c = true;
         
        insert new List<TriggerSettings__c>{ts1,ts2};
        
        carEventObservationRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name = 'CAR Event' LIMIT 1];
        
        carFieldObservationRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name = 'CAR Manager Field Observation' LIMIT 1];
        
        DSRepUser = WorkTestDataUtility.createDSRepUser();
        
        carDir = new User(Alias = 'DIR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARDIR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARManagerProfile.Id,
                                      Username = 'userTest1' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId1'+randomstr,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
        insert carDir;
        
        carMgr = new User(Alias = 'MGR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARMGR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARManagerProfile.Id,
                                      Username = 'userTest3' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId2'+randomstr, ManagerId = carDir.Id,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
                                      
        insert carMgr;
                                      
        carUser = new User(Alias = 'CAR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest3@SampleTest.com',
                                      LastName='CAR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARProfile.Id,
                                      Username = 'userTest5' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId3'+randomstr, ManagerId = carMgr.Id,
                                      EmployeeNumber = 'Emp3' + randomstr.substring(0,4));
                                      
        insert carUser;
        
        loggedInUser.Terms_and_Conditions_Accepted__c = System.Today();
        update loggedInUser;
        
        WorkFeedbackRequest feedbackRequest;
        /* Assign PermissionSet to Coresponding Profile user */
        System.runAs(loggedInUser){                     
                AssignPermissionSet('Coach_CAR_Director_Manager',carDir.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_CAR',carUser.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_CAR_Manager',carMgr.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_XSP',DSRepUser.Id);
                AssignPermissionSet('Xfinity_Sales_Executive',DSRepUser.Id);
        
        }
        
        GoalTemplateDates__c templateDates;
        GoalTemplateDates__c templateCustomSet = new GoalTemplateDates__c();
        templateCustomSet.Name = 'Property Lab CAR';
        templateCustomSet.Current_Period_Start_Date__c = system.today().addDays(-2);
        templateCustomSet.Current_Period_Due_Date__c = system.today().addDays(+2);
        insert templateCustomSet;
        Goal goalObject = new Goal();
        goalObject.Name = 'Test Goal'+PL_Constants.PROPERTY_LAB+carMgr.name;
        goalObject.Status = 'Published';
        goalObject.StartDate = System.Today().addDays(-2);
        goalObject.DueDate = System.Today().addDays(+2);
        goalObject.ownerId = carMgr.Id;
        goalObject.RecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Indirect Sales').getRecordTypeId();
        insert goalObject;
        List<Metric> merticList = new List<Metric>();
        
        for(integer i=0; i<4; i++){
            Metric MetricObj = new Metric();
            if(i==0){
                MetricObj.Name = PL_Constants.METRIC_NAME_OBSERVATION;                               
            }
            else if(i==1){
                MetricObj.Name = PL_Constants.METRIC_NAME_1_1_SUPER_COACH_OBSERVATION;               
            }
            else if(i==2){
                MetricObj.Name = PL_Constants.METRIC_NAME_FIELD_OBSERVATION_SUPER_COACH;               
            }
            else{
                MetricObj.Name = PL_Constants.METRIC_NAME_HUDDLE_OBSERVATION;               
            }
            MetricObj.TargetValue = 100;
            MetricObj.goalid = goalObject.id;
            merticList.add(MetricObj);
            
        }
        Database.Insert(merticList);

        //system.runAs(carMgr){
        WorkPerformanceCycle wperformance1 = new WorkPerformanceCycle();
        wperformance1.Name = 'Performance3';
        wperformance1.ActivityFrom = System.Today()-5;
        wperformance1.ActivityTo = System.Today()+5;
        wperformance1.RecordTypeId = carEventObservationRecordType.Id;
        wperformance1.State = 'Setup';
        insert wperformance1;
        
        WorkFeedbackQuestionSet wquestion1 = new WorkFeedbackQuestionSet();
        wquestion1.Name = 'Test Name1';
        wquestion1.PerformanceCycleId = wperformance1.Id;
        wquestion1.FeedbackType = 'CycleManager';
        wquestion1.duedate = System.Today()+30;
        insert wquestion1;
        
        WorkFeedbackQuestion wquest2 = new WorkFeedbackQuestion ();
        wquest2.QuestionSetId = wquestion1.Id;
        wquest2.Name = 'Engage';
        wquest2.Text = 'Engage';
        wquest2.detail = 'Test Detail';
        wquest2.Number = 1;
        wquest2.Type = 'FreeText';
        wquest2.Category__c = null;
        wquest2.Section__c = 'Observations';
        wquest2.Weight__c = 20;
        insert wquest2;
        
        feedbackRequest = new WorkFeedbackRequest();
           feedbackRequest.Description = 'Test';
           //feedbackRequest.AdHocFeedback = 'Test';
           feedbackRequest.SubjectId = carUser.Id;
           feedbackRequest.RecipientId = carMgr.Id;
           feedbackRequest.FeedbackRequestState = 'Submitted';
           feedbackRequest.Type__c= 'walkAlong';
           feedbackRequest.Score__c = 2.5;
           feedbackRequest.RelatedObjectId = wperformance1.Id;
           //feedbackRequest.PerformanceCycleId = wperformance1.Id;
           feedbackRequest.QuestionSetId = wquestion1.Id;
           feedbackRequest.submittedDate = System.today();
           insert feedbackRequest;

        WorkPerformanceCycle wperformance = new WorkPerformanceCycle();
        wperformance.Name = 'Performance3';
        wperformance.ActivityFrom = System.Today()-5;
        wperformance.ActivityTo = System.Today()+5;
        wperformance.RecordTypeId = carFieldObservationRecordType.Id;
        wperformance.State = 'Setup';
        insert wperformance;
        
        WorkFeedbackQuestionSet wquestion = new WorkFeedbackQuestionSet();
        wquestion.Name = 'Test Name';
        wquestion.PerformanceCycleId = wperformance.Id;
        wquestion.FeedbackType = 'CycleManager';
        wquestion.duedate = System.Today()+30;
        insert wquestion;
        
        WorkFeedbackQuestion wquest1 = new WorkFeedbackQuestion ();
        wquest1.QuestionSetId = wquestion.Id;
        wquest1.Name = 'Engage';
        wquest1.Text = 'Engage';
        wquest1.detail = 'Test Detail';
        wquest1.Number = 1;
        wquest1.Type = 'FreeText';
        wquest1.Category__c = null;
        wquest1.Section__c = 'Observations';
        wquest1.Weight__c = 20;
        insert wquest1;

        List<ObservationController.Question> question = new List<ObservationController.Question>();
        ObservationController.Question ques = new ObservationController.Question();  
        ques.name = 'Contacts';
        ques.text = 'Strength';
        ques.rating ='Strength';
        ques.notes ='Confidence';
        ques.showNotes = true;
        ques.showHelpText  = true;
        ques.qnId  = null;
        ques.qnNotesId = null;
        ques.section = 'Observation Counts';
        question.add(ques);
        
        List<ObservationController.Category> categories = new List<ObservationController.Category>();
        ObservationController.Category category = new ObservationController.Category();
        category.category = 'Contacts';
        category.text ='Prepare - Energy';
        category.rating = 'Needs Improvement';
        category.showNotes = true;
        category.categoryQnId = null;
        category.weights = 200;
        category.questions = question;
        category.addQuestion(ques);
        categories.add(category);
        
        ObservationController.Section section = new ObservationController.Section ();
        section.name= 'Observations';
        section.showSection = true;
        section.questions = question;
        section.categories = categories;
        section.addQuestion(ques);
        section.addCategory(category);
        
       Test.startTest();
       
        //}
            WorkFeedbackRequest wfr = new WorkFeedbackRequest();
            wfr.RecipientId = carDir.Id;
            wfr.Type__c= 'CycleManager';
            wfr.Score__c = 10;
            wfr.FeedbackRequestState ='Submitted';
            wfr.submittedDate = System.today();
            wfr.SubjectId = carMgr.Id; 
            wfr.SubmitFeedbackToId = carDir.Id;
            wfr.QuestionSetId = wquestion.Id;
            wfr.RelatedObjectId = wperformance.Id;
            //wfr.Person_Coach__c = carUser.Id;
            wfr.Field_Observation_Feedback_Request__c = feedbackRequest.Id;
            wfr.Person_CAR_in_Field_Observation__c = carUser.Id;
            //wfr.Related_1_1_Coaching__c = oneOneCoach.Id;
            insert wfr;
            //ObservationUtils.getFeedbackForXsp('Field Observation',carMgr.Id,carUser.Id,feedbackRequest.Id,carUser.Id);
            
        ObservationController.WalkAlongData walkAlongData = new ObservationController.WalkAlongData();
        walkAlongData.walkAlongStarted = true; 
        walkAlongData.requestId = null;
        walkAlongData.showSection = true;
        walkAlongData.walkAlongStopped = true;
        walkAlongData.startTime ='04:56:00';
        walkAlongData.endTime ='09:56:00';
        walkAlongData.showNotes = true;
        walkAlongData.lastSavedDate = String.valueOf(system.today());
        walkAlongData.score = 100;
        walkAlongData.scorePct = 100;
        walkAlongData.overallRating = 'Achieved Expectations';
        walkAlongData.propString = 'Test Prop';
        walkAlongData.selectedPersonCoach = carUser.Id;
        walkAlongData.selectedActivity = feedbackRequest.Id;
        walkAlongData.selectedXSP = carMgr.Id;
        walkAlongData.selectedRecordType = carFieldObservationRecordType.Name;
        walkAlongData.recordTypeName = 'CAR Manager Field Observation';
        walkAlongData.selectedPersonObserved = carUser.Id;
        walkAlongData.addSection(section);
        
        ObservationUtils.getFeedbackForXsp('CAR Manager Field Observation',carMgr.Id,carUser.Id,feedbackRequest.Id,carUser.Id);
            ObservationController.activityData actData = new ObservationController.activityData();
            ObservationController.FieldObservationCoachee personObserved = new ObservationController.FieldObservationCoachee(carUser.name,carUser.Id);
            ObservationController.FeedbackRequestData feedbackRqstData = new ObservationController.FeedbackRequestData('keyString',feedbackRequest.Name,feedbackRequest.Id);
            actData.addFieldObservationCoachee(personObserved);
            actData.addFeedbackRequestData(feedbackRqstData);
            ObservationController.getActivitiesData(carMgr.Id,'CAR Manager Field Observation');
            
            ObservationController.saveData(walkAlongData,'@@@@@Test@@@@');
            ObservationUtils.getFeedbackForXsp('CAR Manager Field Observation',carMgr.Id,carUser.Id,feedbackRequest.Id,carUser.Id);
            ObservationController.submitWalkAlong(walkAlongData,'@@@@@Test@@@@');
            
            ObservationController.getFeedbackForXsp('CAR Manager Field Observation',carMgr.Id,carUser.Id,feedbackRequest.Id,carUser.Id);
            
            PageReference pageRef = Page.ObservationForm;
            Test.setCurrentPage(pageRef);
            ObservationController obCon = new ObservationController();
            obCon.getunSelectedValues();
            obCon.getSelectedValues();
            obCon.selectClick();
            obCon.unselectclick();
       Test.stopTest();
   }
   
   /*  This method set permission set to user base on permissionSetName
    */ 
   static void AssignPermissionSet(String permissionSetName, Id userId){
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);
        
    } 
    @isTest
   static void testMethod5(){
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.ActivityGoalCommissionCycle();
        
        RSRProfile = [Select Id, Name From Profile where Name = 'Retail Sales Rep' limit 1];
        RSMManagerProfile = [Select Id, Name From Profile where Name = 'Retail Sales Manager' limit 1];
        
        ts1= new TriggerSettings__c();
        ts1.Name = 'UserTrigger';
        ts1.isActive__c = true;
         
        ts2 = new TriggerSettings__c();
        ts2.Name = 'OneOnOnecoachingTrigger';
        ts2.isActive__c = true;
         
        insert new List<TriggerSettings__c>{ts1,ts2};
        
        indirecttObservationRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name = 'Indirect Observation' LIMIT 1];
        
        rsmuser = new User(Alias = 'MGR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@Samplse777Test.com',
                                      LastName='RSM1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = RSMManagerProfile.Id,
                                      Username = 'userTest3' + randomstr + '@SampldfgeTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId2'+randomstr, 
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
                                      
        insert rsmuser;
        
        rsruser = new User(Alias = 'rsr_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@Sample777Test.com',
                                      LastName='rsr1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = RSRProfile.Id,
                                      Username = 'userTest1' + randomstr + '@SampleTedfdst.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId1'+randomstr,ManagerId = rsmuser.Id,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
        insert rsruser;
        
                
        loggedInUser.Terms_and_Conditions_Accepted__c = System.Today();
        update loggedInUser;
        
        WorkFeedbackRequest feedbackRequest;
        /* Assign PermissionSet to Coresponding Profile user */
        System.runAs(loggedInUser){                     
                AssignPermissionSet('SalesSpace_Coach_Access_Retail_Rep',rsruser.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_Retail_Sales_Manager',rsmuser.Id);
        }
        
        GoalTemplateDates__c templateDates;
        GoalTemplateDates__c templateCustomSet = new GoalTemplateDates__c();
        templateCustomSet.Name = 'IndirectActivityGoalCommissionCycle';
        templateCustomSet.Current_Period_Start_Date__c = system.today().addDays(-2);
        templateCustomSet.Current_Period_Due_Date__c = system.today().addDays(+2);
        insert templateCustomSet;
        list<Variable_Setting__c> lstvariable = new list<Variable_Setting__c>();
        Variable_Setting__c objvariable;
        objvariable = new Variable_Setting__c();
        objvariable.Name ='Indirect_Observation' ;
        objvariable.Description__c = 'CAR Manager permission set';
        objvariable.Value__c = 'Indirect Observation';
        lstvariable.add(objvariable);
        insert lstvariable;
        Goal goalObject = new Goal();
        goalObject.Name = 'Test Goal'+Indirect_Constants.ACTIVITY_TEMPLATE+rsmuser.name;
        goalObject.Status = 'Published';
        goalObject.StartDate = System.Today().addDays(-2);
        goalObject.DueDate = System.Today().addDays(+2);
        goalObject.ownerId = rsmuser.Id;
        goalObject.RecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Indirect Sales').getRecordTypeId();
        insert goalObject;
        List<Metric> merticList = new List<Metric>();
        Metric MetricObj = new Metric();
        MetricObj.Name = System.Label.CompletedObservations;                               
        MetricObj.TargetValue = 100;
        MetricObj.goalid = goalObject.id;
        merticList.add(MetricObj);
            
        
        Database.Insert(merticList);
        WorkPerformanceCycle wperformance1 = new WorkPerformanceCycle();
        wperformance1.Name = 'Performance3'+rsruser.Name;
        wperformance1.ActivityFrom = System.Today()-5;
        wperformance1.ActivityTo = System.Today()+5;
        wperformance1.RecordTypeId = indirecttObservationRecordType.Id;
        wperformance1.State = 'Setup';
        insert wperformance1;
        
        WorkFeedbackQuestionSet wquestion1 = new WorkFeedbackQuestionSet();
        wquestion1.Name = 'Test Name1'+rsruser.Name;
        wquestion1.PerformanceCycleId = wperformance1.Id;
        wquestion1.FeedbackType = 'CycleManager';
        wquestion1.duedate = System.Today()+30;
        insert wquestion1;
        
        WorkFeedbackQuestion wquest2 = new WorkFeedbackQuestion ();
        wquest2.QuestionSetId = wquestion1.Id;
        wquest2.Name = 'Engage';
        wquest2.Text = 'Engage';
        wquest2.detail = 'Test Detail';
        wquest2.Number = 1;
        wquest2.Type = 'FreeText';
        wquest2.Category__c = null;
        wquest2.Section__c = 'Observations';
        wquest2.Weight__c = 20;
        insert wquest2;
        
        feedbackRequest = new WorkFeedbackRequest();
           feedbackRequest.Description = 'Test';
           //feedbackRequest.AdHocFeedback = 'Test';
           feedbackRequest.SubjectId = rsruser.Id;
           feedbackRequest.RecipientId = rsmuser.Id;
           feedbackRequest.FeedbackRequestState = 'Submitted';
           feedbackRequest.Type__c= 'walkAlong';
           feedbackRequest.Score__c = 2.5;
           feedbackRequest.RelatedObjectId = wperformance1.Id;
           //feedbackRequest.PerformanceCycleId = wperformance1.Id;
           feedbackRequest.QuestionSetId = wquestion1.Id;
           feedbackRequest.submittedDate = System.today();
           insert feedbackRequest;

        List<ObservationController.Question> question = new List<ObservationController.Question>();
        ObservationController.Question ques = new ObservationController.Question();  
        ques.name = 'Contacts';
        ques.text = 'Strength';
        ques.rating ='Strength';
        ques.notes ='Confidence';
        ques.showNotes = true;
        ques.showHelpText  = true;
        ques.qnId  = null;
        ques.qnNotesId = null;
        ques.section = 'Observation Counts';
        question.add(ques);
        
        List<ObservationController.Category> categories = new List<ObservationController.Category>();
        ObservationController.Category category = new ObservationController.Category();
        category.category = 'Contacts';
        category.text ='Prepare - Energy';
        category.rating = 'Needs Improvement';
        category.showNotes = true;
        category.categoryQnId = null;
        category.weights = 200;
        category.questions = question;
        category.addQuestion(ques);
        categories.add(category);
        
        ObservationController.Section section = new ObservationController.Section ();
        section.name= 'Observations';
        section.showSection = true;
        section.questions = question;
        section.categories = categories;
        section.addQuestion(ques);
        section.addCategory(category);
        
       Test.startTest();
       
           WorkFeedbackRequest wfr = new WorkFeedbackRequest();
            wfr.RecipientId =rsruser.Id;
            wfr.Type__c= 'CycleManager';
            wfr.Score__c = 10;
            wfr.FeedbackRequestState ='Submitted';
            wfr.submittedDate = System.today();
            wfr.SubjectId = rsruser.Id; 
            wfr.SubmitFeedbackToId = rsruser.Id;
            wfr.QuestionSetId = wquestion1.Id;
            wfr.RelatedObjectId = wperformance1.Id;
            wfr.Field_Observation_Feedback_Request__c = feedbackRequest.Id;
            wfr.Person_CAR_in_Field_Observation__c = rsruser.Id;
            
            insert wfr;
            
            
        ObservationController.WalkAlongData walkAlongData = new ObservationController.WalkAlongData();
        walkAlongData.walkAlongStarted = true; 
        walkAlongData.requestId = null;
        walkAlongData.showSection = true;
        walkAlongData.walkAlongStopped = true;
        walkAlongData.startTime ='04:56:00';
        walkAlongData.endTime ='09:56:00';
        walkAlongData.showNotes = true;
        walkAlongData.lastSavedDate = String.valueOf(system.today());
        walkAlongData.score = 100;
        walkAlongData.scorePct = 100;
        walkAlongData.overallRating = 'Achieved Expectations';
        walkAlongData.propString = 'Test Prop';
        walkAlongData.selectedPersonCoach = rsruser.Id;
        walkAlongData.selectedActivity = feedbackRequest.Id;
        walkAlongData.selectedXSP = rsruser.Id;
        walkAlongData.selectedRecordType = indirecttObservationRecordType.Name;
        walkAlongData.recordTypeName = 'Indirect Observation';
        walkAlongData.selectedPersonObserved = rsruser.Id;
        walkAlongData.addSection(section);
        system.runas(rsmuser){
        ObservationUtils.getFeedbackForXsp('Indirect Observation',rsmuser.Id,rsruser.Id,feedbackRequest.Id,rsruser.Id);
            ObservationController.activityData actData = new ObservationController.activityData();
            ObservationController.FieldObservationCoachee personObserved = new ObservationController.FieldObservationCoachee(rsruser.name,rsruser.Id);
            ObservationController.FeedbackRequestData feedbackRqstData = new ObservationController.FeedbackRequestData('keyString',feedbackRequest.Name,feedbackRequest.Id);
            actData.addFieldObservationCoachee(personObserved);
            actData.addFeedbackRequestData(feedbackRqstData);
            ObservationController.getActivitiesData(rsmuser.Id,'Indirect Observation');
            
            ObservationController.saveData(walkAlongData,'@@@@@Test@@@@');
            ObservationUtils.getFeedbackForXsp('Indirect Observation',rsmuser.Id,rsruser.Id,feedbackRequest.Id,rsruser.Id);
           
             ObservationController.submitWalkAlong(walkAlongData,'@@@@@Test@@@@');
            }
            ObservationController.getFeedbackForXsp('Indirect Observation',rsmuser.Id,rsruser.Id,feedbackRequest.Id,rsruser.Id);
            
            PageReference pageRef = Page.ObservationForm;
            Test.setCurrentPage(pageRef);
            ObservationController obCon = new ObservationController();
            obCon.getunSelectedValues();
            obCon.getSelectedValues();
            obCon.selectClick();
            obCon.unselectclick();
        
       Test.stopTest();
   }
   
   
}