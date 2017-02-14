/**************************************************************************************************
Name : ObservationControllerTest
Description : This test class created to cover the classes ObservationController and ObservationUtils.
User Story : US688169
Date : 27th May 2016
Author : Revan Kumar
***************************************************************************************************/
@isTest
    public class ObservationControllerTest{
    
    static testmethod void method1() {
        RecordType xspRecType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name =:Label.XSP_Ridealong LIMIT 1];
        ObservationForm__mdt objObsForm = new ObservationForm__mdt();
        objObsForm  = [SELECT Feedback_Form__c,Profile__c FROM ObservationForm__mdt LIMIT 1];
        Test.StartTest();
        WorkPerformanceCycle wperformance = new WorkPerformanceCycle();
        wperformance.Name = 'Performance1';
        wperformance.ActivityFrom = System.Today();
        wperformance.ActivityTo = System.Today();
        wperformance.RecordTypeId = xspRecType.Id;
        //wperformance.State = 'Setup';
        insert wperformance ;
        
        WorkFeedbackQuestionSet wquestion = new WorkFeedbackQuestionSet ();
        wquestion.Name = 'Test Name';
        wquestion.PerformanceCycleId = wperformance.Id;
        wquestion.FeedbackType = 'CycleManager';
        wquestion.duedate = System.Today()+30;
        insert wquestion;
       
        WorkFeedbackQuestion wquest = new WorkFeedbackQuestion ();
        wquest.QuestionSetId = wquestion.Id;
        wquest.Name = 'Prepare - Energy';
        wquest.Text = 'Prepare - Energy';
        wquest.detail = 'Test Detail';
        wquest.Number = 1;
        wquest.Type = 'Freetext';
        wquest.Category__c = 'Prepare - Energy';
        wquest.Section__c = 'Observations';
        wquest.Weight__c = 20;
        insert wquest;
        
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
        insert wquestcat;
        
        WorkFeedbackQuestion wquest2 = new WorkFeedbackQuestion ();
        wquest2.QuestionSetId = wquestion.Id;
        wquest2.Name = 'Engage';
        wquest2.Text = 'Engage';
        wquest2.Choices= 'Needs Improvement\nAchieved Expectations\nHighly Effective';
        wquest2.Number = 30;
        wquest2.Type = 'MultipleChoice';
        wquest2.Category__c = 'Engage';
        wquest2.Section__c = 'Observations';
        wquest2.Weight__c = 10;
        insert wquest2;
        
        WorkFeedbackQuestion wquest3 = new WorkFeedbackQuestion ();
        wquest3.QuestionSetId = wquestion.Id;
        wquest3.Name = 'TestEngage';
        wquest3.Text = 'TestEngage';
        wquest3.Choices= 'Needs Improvement\nAchieved Expectations';
        wquest3.Number = 32;
        wquest3.Type = 'MultipleChoice';
        wquest3.Category__c = 'Engage';
        wquest3.Section__c = 'Observations';
        wquest3.Weight__c = 10;
        insert wquest3;
        
        WorkFeedbackQuestion wquest4 = new WorkFeedbackQuestion ();
        wquest4.QuestionSetId = wquestion.Id;
        wquest4.Name = 'TestEngage1';
        wquest4.Text = 'TestEngage1';
        wquest4.Number = 34;
        wquest4.Type = 'Freetext';
        wquest4.Category__c = 'testEngage';
        wquest4.Section__c = 'Observations';
        wquest4.Weight__c = 10;
        insert wquest4;
        
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.ActivityGoalCommissionCycle();
        User DSSupUser = WorkTestDataUtility.createDSSupervisorUser();
        User DSRepUser = WorkTestDataUtility.createDSRepUser();
    
        /* Assign PermissionSet to Coresponding Profile user */
        User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
        System.runAs(currentUser){                     
                AssignPermissionSet('SalesSpace_Coach_Access_SDM',DSSupUser.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_XSP',DSRepUser.Id);
                AssignPermissionSet('Xfinity_Sales_Executive',DSRepUser.Id);
        }
    
        /*WorkFeedbackRequest workfeedbackrequest;
        WorkFeedbackRequest workfeedbackrequest1;    
        System.runAs(DSSupUser){
            
            workfeedbackrequest = new WorkFeedbackRequest(RecipientId = DSSupUser.Id, SubjectId = DSRepUser.Id,
                Type__c= 'Walkalong',AdHocQuestion = 'How is the feedback1',Score__c = 10,FeedbackRequestState='Submitted');
            workfeedbackrequest1 = new WorkFeedbackRequest(RecipientId = DSSupUser.Id, SubjectId = DSRepUser.Id,
                Type__c= 'Walkalong',AdHocQuestion = 'How is the feedback2',Score__c = 10,FeedbackRequestState='Submitted');
             ObservationUtils.getFeedbackForXsp(DSRepUser.Id,xspRecType.Id);
        }*/
    
        WorkFeedbackRequest WFR = new WorkFeedbackRequest ();
        WFR.RecipientId = DSSupUser.Id;
        WFR.Type__c= 'CycleManager';
        WFR.Score__c = 10;
        WFR.FeedbackRequestState ='Draft';
        WFR.submittedDate = System.today();
        WFR.SubjectId = DSRepUser.Id; 
        WFR.SubmitFeedbackToId = DSSupUser.Id;
        WFR.QuestionSetId = wquestion.Id;
       // WFR.PerformanceCycle.RecordType.Id='012160000010oBb';
        database.insert(WFR);
        System.debug('WFR123****'+WFR.Id);
        
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
        
        ObservationController.Category category= new ObservationController.Category();
        category.category = 'Contacts';
        category.text ='Prepare - Energy';
        category.rating = 'Highly Effective';
        category.showNotes = true;
        category.categoryQnId = null;
        category.weights = 200;
        category.questions = question;
        category.addQuestion(ques);
        
        List<ObservationController.Category> categories = new List<ObservationController.Category>();
        categories.add(category);
        
        
        ObservationController.Section section = new ObservationController.Section ();
        section.name= 'Common';
        section.showSection = true;
        section.questions = question;
        section.categories = categories;
        section.addQuestion(ques);
        section.addCategory(category);
        
        ObservationController.Section section1 = new ObservationController.Section ();
        section1.name= 'Common';
        section1.showSection = true;
        section1.questions = question;
        section1.categories = categories;
        section1.addQuestion(ques);
        section1.addCategory(category);
        List<ObservationController.Section> lstSection = new List<ObservationController.Section>{section,section1};
        
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
        walkAlongData.addSection(section);
        System.runAs(DSSupUser){
             //workfeedbackrequest.subjectId = DSRepUser.Id; 
             ObservationController.Xsp xsp = new ObservationController.Xsp(DSRepUser.name,DSRepUser.Id);
             ObservationController.getXSPList();    
             walkAlongData.selectedXSP = DSRepUser.Id; 
             ObservationController.RecordTypeCar recordtypecarval = new ObservationController.RecordTypeCar(xspRecType.name,xspRecType.Id);
             ObservationController.getRecordTypeCarList();  
             walkAlongData.selectedRecordType =xspRecType.Id;
             ObservationUtils.getFeedbackForXsp(DSRepUser.Id,xspRecType.Id);
             
        }
      
         ObservationController.saveData(walkAlongData,'abc');
         ObservationController.submitWalkAlong(walkAlongData,'abc');
         ObservationUtils.calculateScore(walkAlongData);
         ObservationController obCls = new  ObservationController ();
         obCls.getSF1();
         ObservationUtils.calculateScore(walkAlongData);
         Test.StopTest();
   }
   /* static testmethod void method2() {
        RecordType xspRecType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name =:Label.XSP_Ridealong LIMIT 1];
        ObservationForm__mdt objObsForm = new ObservationForm__mdt();
        objObsForm  = [SELECT Feedback_Form__c,Profile__c FROM ObservationForm__mdt LIMIT 1];
        
        WorkPerformanceCycle wperformance = new WorkPerformanceCycle();
        wperformance.Name = 'Performance1';
        wperformance.ActivityFrom = System.Today();
        wperformance.ActivityTo = System.Today();
        wperformance.RecordTypeId = xspRecType.Id;
        insert wperformance ;
       
        WorkFeedbackQuestionSet wquestion = new WorkFeedbackQuestionSet ();
        wquestion.Name = 'Test Name';
        wquestion.PerformanceCycleId = wperformance.Id;
        wquestion.FeedbackType = 'CycleManager';
        wquestion.duedate = System.Today()+30;
        insert wquestion;
        
        WorkFeedbackQuestion wquest = new WorkFeedbackQuestion ();
        wquest.QuestionSetId = wquestion.Id;
        wquest.Name = 'Overall Notes';
        wquest.Text = 'Overall Notes';
        wquest.detail = 'Test Detail';
        wquest.Number = 1;
        wquest.Type = 'Freetext';
        wquest.Category__c = 'Prepare - Energy';
        wquest.Section__c = 'Observations';
        wquest.Weight__c = 20;
        insert wquest;
        
        WorkFeedbackQuestion wquest1 = new WorkFeedbackQuestion ();
        wquest1.QuestionSetId = wquestion.Id;
        wquest1.Name = 'Knocks Val';
        wquest1.Text = 'Knocks Val';
        wquest1.detail = 'Test Detail1';
        wquest1.Number = 5;
        wquest1.Type = 'Freetext';
        wquest1.Category__c = null;
        wquest1.Section__c = 'ObservationCounts';
        wquest1.Weight__c = 20;
        insert wquest1;
        
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.ActivityGoalCommissionCycle();
        User DSSupUser = WorkTestDataUtility.createDSSupervisorUser();
        User DSRepUser = WorkTestDataUtility.createDSRepUser();
        User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
        System.runAs(currentUser){                     
                AssignPermissionSet('SalesSpace_Coach_Access_SDM',DSSupUser.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_XSP',DSRepUser.Id);
                AssignPermissionSet('Xfinity_Sales_Executive',DSRepUser.Id);
        }
        System.runAs(DSSupUser){ 
            ObservationController.Xsp xsp = new ObservationController.Xsp(xspRecType.name,DSSupUser.Id);
            ObservationController.getXSPList(); 
            ObservationController.RecordTypeCar recordtypecarval = new ObservationController.RecordTypeCar(xspRecType.name,xspRecType.Id); 
            ObservationController.getRecordTypeCarList(); 
            ObservationUtils.getFeedbackForXsp(DSSupUser.Id,DSSupUser.Id);
        }
        /*WorkFeedbackRequest workfeedbackrequest;
        WorkFeedbackRequest workfeedbackrequest1;
        System.runAs(DSSupUser){
            workfeedbackrequest = new WorkFeedbackRequest(RecipientId = DSSupUser.Id,
                Type__c= 'Walkalong',AdHocQuestion = 'How is the feedback',Score__c = 10,FeedbackRequestState='Submitted');
            workfeedbackrequest1 = new WorkFeedbackRequest(RecipientId = DSSupUser.Id,
                Type__c= 'Walkalong',AdHocQuestion = 'How is the feedback',Score__c = 10,FeedbackRequestState='Submitted');
        }***********************/
        
      /*  List<WorkFeedbackRequest> wfrList = new List<WorkFeedbackRequest>();
        WorkFeedbackRequest WFR = new WorkFeedbackRequest ();
        WFR.RecipientId = DSSupUser.Id;
        WFR.Type__c= 'CycleManager';
        WFR.Score__c = 10;
        WFR.FeedbackRequestState ='Draft';
        WFR.submittedDate = System.today();
        WFR.SubjectId = DSRepUser.Id; 
        WFR.SubmitFeedbackToId = DSSupUser.Id;
        WFR.QuestionSetId = wquestion.Id;
        wfrList.add(WFR);
        
        WorkFeedbackRequest WFR1 = new WorkFeedbackRequest ();
        WFR1.RecipientId = DSSupUser.Id;
        WFR1.Type__c= 'CycleManager';
        WFR1.Score__c = 10;
        WFR1.submittedDate = System.today();
        WFR1.SubjectId = DSRepUser.Id; 
        WFR1.SubmitFeedbackToId = DSSupUser.Id;
        WFR1.FeedbackRequestState='Draft'; 
        WFR1.QuestionSetId = wquestion.Id;
        wfrList.add(WFR1);
        
        WorkFeedbackRequest WFR2 = new WorkFeedbackRequest ();
        WFR2.RecipientId = DSSupUser.Id;
        WFR2.Type__c= 'CycleManager';
        WFR2.Score__c = 10;
        WFR2.submittedDate = System.today();
        WFR2.SubjectId = DSRepUser.Id; 
        WFR2.SubmitFeedbackToId = DSSupUser.Id;
        WFR2.FeedbackRequestState='Draft'; 
        WFR2.QuestionSetId = wquestion.Id;
        wfrList.add(WFR2);
        insert wfrList;
        System.debug('WFR305*****'+wfrList);
        System.debug('WFR306*****'+WFR1.Id);
        System.debug('WFR307*****'+WFR2.Id);
      
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
        
        ObservationController.Question ques1 = new ObservationController.Question();  
        ques1.name = 'KnocksVal';
        ques1.text = 'KnocksVal';
        ques1.rating ='None';
        ques1.notes ='Confidence';
        ques1.showNotes = true;
        ques1.showHelpText  = true;
        ques1.qnId  = null;
        ques1.qnNotesId = null;
        ques1.section = 'ObservationCounts';
        question.add(ques1);
        
        ObservationController.Category category= new ObservationController.Category();
        category.category = 'Contacts';
        category.text ='Prepare - Energy';
        category.rating = 'Achieved Expectations';
        category.showNotes = true;
        category.categoryQnId = null;
        category.weights = 200;
        category.questions = question;
        category.addQuestion(ques);
        
        category.category = 'Contacts1';
        category.text ='Prepare - Energy';
        category.rating = 'Achieved Expectations1';
        category.showNotes = true;
        category.categoryQnId = null;
        category.weights = 200;
        category.questions = null;
        category.addQuestion(ques);
        
        ObservationController.Category category1 = new ObservationController.Category();
        category1.category = 'Prepare - Energy';
        category1.text ='Prepare - Energy';
        category1.rating = '';
        category1.showNotes = true;
        category1.categoryQnId = null;
        category1.weights = 200;
        category1.questions = null;
        category1.addQuestion(ques);
        
        List<ObservationController.Category> categories = new List<ObservationController.Category>();
        categories.add(category);
        
        ObservationController.Section section = new ObservationController.Section ();
        section.name= 'Observations';
        section.showSection = true;
        section.questions = null;
        section.categories = null;
        section.addQuestion(ques);
        section.addCategory(category);
        section.addCategory(category1);
       
        ObservationController.WalkAlongData walkAlongData = new ObservationController.WalkAlongData();
        walkAlongData.walkAlongStarted = true; 
        walkAlongData.requestId = null;
        walkAlongData.showSection = true;
        walkAlongData.walkAlongStopped = true;
        walkAlongData.selectedXSP = DSRepUser.Id;
        walkAlongData.showNotes = false;
        walkAlongData.selectedRecordType = xspRecType.Id;
        walkAlongData.startTime ='04:56:00';
        walkAlongData.endTime ='09:56:00';
        walkAlongData.showNotes = true;
        walkAlongData.lastSavedDate = String.valueOf(system.today());
        walkAlongData.score = 100;
        walkAlongData.scorePct = 100;
        walkAlongData.overallRating = 'Highly Effective';
        walkAlongData.addSection(section);
        System.runAs(DSRepUser){
             List<ObservationController.RecordTypeCar>lstRecCar = new List<ObservationController.RecordTypeCar> ();
             //workfeedbackrequest.subjectId = DSRepUser.Id; 
             ObservationController.Xsp xsp = new ObservationController.Xsp(DSRepUser.name,DSRepUser.Id);
             ObservationController.getXSPList();    
             walkAlongData.selectedXSP = DSRepUser.Id; 
             ObservationController.RecordTypeCar recordtypecarval1 = new ObservationController.RecordTypeCar(xspRecType.name,xspRecType.Id);
             lstRecCar.add(recordtypecarval1);
             ObservationController.getRecordTypeCarList();  
             walkAlongData.selectedRecordType =xspRecType.Id;
        } 
        
        Test.StartTest();
        ObservationController.saveData(walkAlongData,'abc');
        ObservationController.submitWalkAlong(walkAlongData,'abc');
        ObservationController.getFeedbackForXsp(walkAlongData.selectedXSP, walkAlongData.selectedRecordType); 
        ObservationUtils.getFeedbackForXsp(DSRepUser.Id,xspRecType.Id);
        ObservationUtils.calculateScore(walkAlongData);
        ObservationController obCls = new  ObservationController ();
        ObservationController.sfdcIFrameHost = 'sfdcIFrameHost';
        ObservationController.retURL = 'retURL';
        obCls.flag = true;
        obCls.getSF1 ();
        //ObservationUtils.calculateScore(walkAlongData);
        ObservationUtils.saveSubmitFeedback(walkAlongData,'abc',true);
        
        Test.StopTest();
    } */
       
    /*  This method set permission set to user base on permissionSetName
    */ 
   static void AssignPermissionSet(String permissionSetName, Id userId){
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);
        
    } 
}