/**************************************************************************************************
Name : WalkalongUtilsReadOnlyTest
Description : This test class created to cover the class WalkalongUtilsReadOnly
Date : 5 April 2016
Author : Saket Sharma
***************************************************************************************************/
@isTest
    public class WalkalongUtilsReadOnlyTest{
    static testmethod void method1() {
        VariableSettingTestUtility.variableSettingsData();
        RecordType xspRecType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name =:Label.XSP_Ridealong LIMIT 1];
        List<WorkPerformanceCycle> lstWorkPerfor = new List<WorkPerformanceCycle>();
        WorkPerformanceCycle wperformance = new WorkPerformanceCycle();
        wperformance.Name = 'Performance1';
        wperformance.ActivityFrom = System.Today()-10;
        wperformance.ActivityTo = System.Today()+30;
        wperformance.RecordTypeId = xspRecType.Id;
        insert wperformance;
        lstWorkPerfor.add(wperformance);
        
        WorkFeedbackQuestionSet wquestion = new WorkFeedbackQuestionSet ();
        wquestion.Name = 'XSP Walkalong';
        wquestion.PerformanceCycleId = wperformance.Id;
        wquestion.FeedbackType = 'CycleManager';
        wquestion.duedate = System.Today()+30;
        insert wquestion;
        
        List<WorkFeedbackQuestion> qfpList = new List<WorkFeedbackQuestion> ();
        WorkFeedbackQuestion wfq=new WorkFeedbackQuestion();
        wfq.Name='Overall Notes';
        wfq.Text='Overall Notes';
        wfq.Number=1;
        //wfq.Choices='N/A\nStrength\nOpportunity';
        wfq.QuestionSetId=wquestion.Id;
        wfq.Type='FreeText';
        wfq.Section__c = 'common';
        //wfq.Weight__c = 10;
        //insert wfq;
        qfpList.add(wfq);
        
        WorkFeedbackQuestion wfq1 = new WorkFeedbackQuestion();
        wfq1.Name='Area of Focus';
        wfq1.Text='Area of Focus';
        wfq1.Number=2;
        wfq1.QuestionSetId=wquestion.Id;
        wfq1.Choices= 'Engage\nCloses';
        wfq1.Type='MultipleChoice';
        wfq1.Section__c = 'Common';
        //wfq1.Weight__c = 10;
        //insert wfq1;
        qfpList.add(wfq1);
        
        WorkFeedbackQuestion wfq2 = new WorkFeedbackQuestion();
        wfq2.Name='Area of Focus - Notes';
        wfq2.Text='Area of Focus - Notes';
        wfq2.Number=3;
        wfq2.QuestionSetId=wquestion.Id;
        wfq2.Type='FreeText';
        wfq2.Section__c = 'Common';
        //wfq2.Weight__c = 10;
        //insert wfq2;
        //qfpList.add(wfq2);
        
        WorkFeedbackQuestion wfq3 = new WorkFeedbackQuestion();
        wfq3.QuestionSetId = wquestion.Id;
        wfq3.Name = 'Engage';
        wfq3.Text = 'Engage';
        wfq3.Choices= 'Needs Improvement\nAchieved Expectations\nHighly Effective';
        wfq3.Number = 4;
        wfq3.Type = 'MultipleChoice';
        wfq3.Category__c = 'Engage';
        wfq3.Section__c = 'Observation';
        wfq3.Weight__c = 10;
        //insert wfq3;
        qfpList.add(wfq3);
        
        WorkFeedbackQuestion wfq4 = new WorkFeedbackQuestion();
        wfq4.QuestionSetId = wquestion.Id;
        wfq4.Name = 'Abc';
        wfq4.Text = 'Abc';
        wfq4.Choices= 'N/A\nStrength\nOpportunity';
        wfq4.Number = 5;
        wfq4.Type = 'MultipleChoice';
        wfq4.Category__c = 'Engage';
        wfq4.Section__c = 'Observation';        
        //insert wfq4;
        qfpList.add(wfq4);
        database.insert(qfpList,false);
        
		Variable_Setting__c variableSetting3 = new Variable_Setting__c();
		variableSetting3.name = 'CompletedObservationProfiles';
		variableSetting3.Description__c = 'This are the profiles who can see completed observation form';
		variableSetting3.Value__c = 'XC Manager,CAR/XC Regional Lead';
		insert variableSetting3;
        
        
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.ActivityGoalCommissionCycle();
        User DSSupUser = WorkTestDataUtility.createDSSupervisorUserForCoaching();
        User DSMgrUser = WorkTestDataUtility.createDSManagerUserForCoaching();
        User DSRepUser = WorkTestDataUtility.createDSRepUserForCoaching();
        User CARUser = WorkTestDataUtility.createCARUser();
        User carMgr = WorkTestDataUtility.createCARManagerUser();
        User carDir = WorkTestDataUtility.createCARManagerUser();
        User XCMgr = WorkTestDataUtility.createXCManagerUser();
        
        User XSPUser = WorkTestDataUtility.createDSRepUserForCoaching();
		XSPUser.ManagerId = XCMgr.Id;
		XSPUser.FirstName = 'TestXSPUser';
        
        //User CARXC = WorkTestDataUtility.createCARXCUser();
        List<User> userList = new List<User>();
        userList.add(XSPUser);
        userList.add(DSSupUser);
        userList.add(DSMgrUser);
        userList.add(DSRepUser);
        insert userList;
        Task huddleTask = new Task();
        huddleTask.Subject = 'Call';
        insert huddleTask;
        

        /* Assign PermissionSet to Coresponding Profile user */
        User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
        System.runAs(currentUser){
            AssignPermissionSet('Coach_CAR_Director_Manager',carDir.Id);            
            AssignPermissionSet('SalesSpace_Coach_Access_SDM',DSSupUser.Id);
            AssignPermissionSet('SalesSpace_Coach_Access_ASM',DSMgrUser.Id);
            AssignPermissionSet('SalesSpace_Coach_Access_XSP',DSRepUser.Id);
            AssignPermissionSet('Xfinity_Sales_Executive',DSRepUser.Id);
            AssignPermissionSet('Coach_CAR_Director_Manager',XCMgr.Id);
            //AssignPermissionSet('Coach_CAR_Director_Manager',CARXC.Id);
        }

        WorkFeedbackRequest workfeedbackrequest;        
        System.runAs(DSSupUser){
            workfeedbackrequest = new WorkFeedbackRequest(RecipientId = DSSupUser.Id,
                                    Type__c= 'Walkalong',AdHocQuestion = 'How is the feedback',Score__c = 10,FeedbackRequestState='Draft');
        }
        
       
        List<WorkFeedbackRequest> wfrList = new List<WorkFeedbackRequest>();
        WorkFeedbackRequest WFR = new WorkFeedbackRequest();
        WFR.RecipientId = DSSupUser.Id;
        WFR.Type__c= 'CycleManager';
        WFR.Score__c = 10;
        WFR.FeedbackRequestState ='Draft';
        WFR.submittedDate = System.today();
        WFR.SubjectId = DSRepUser.Id; 
        WFR.SubmitFeedbackToId = DSSupUser.Id;
        WFR.QuestionSetId = wquestion.Id;
        WFR.Huddle_Id__c = huddleTask.Id;
        wfrList.add(WFR);
         
        insert wfrList;
        
        WalkalongUtilsReadOnly.Category category= new WalkalongUtilsReadOnly.Category();
        category.category = 'Contacts1';
        category.text ='Prepare - Energy';
        category.rating = 'Highly Effective';
        category.showNotes = true;
        category.categoryQnId = null;
       
        WalkalongUtilsReadOnly.WalkAlongData walkAlongData = new WalkalongUtilsReadOnly.WalkAlongData();
        String strXSPWalk = xspRecType.name;
        Integer currIdx=0;
        walkAlongData.profileFlag= false;
        walkAlongData.overallNotes = 'He is good performer';
        walkAlongData.overallNotesQnId =null;
        walkAlongData.knocks ='5';
        walkAlongData.knocksQnId =null;
        walkAlongData.contacts ='3';
        walkAlongData.contactsQnId =null;
        walkAlongData.starts = 'Confidence';
        walkAlongData.startsQnId =null;
        walkAlongData.areaOfFocus ='Engage';
        walkAlongData.areaOfFocusQnId =null;
        walkAlongData.areaOfFocusNotes ='Good Performer';
        walkAlongData.areaOfFocusQnNotesId =null;
        walkAlongData.walkAlongStarted = true; 
        walkAlongData.walkAlongStopped = true;
        walkAlongData.startTime ='04:56:00';
        walkAlongData.endTime ='09:56:00';
        walkAlongData.showNotes = false;
        walkAlongData.lastSavedDate ='11/10/2010';
        walkAlongData.score = 100;
        walkAlongData.overallRating = 'Achieved Expectations';
        walkAlongData.addCategory(category);
        walkAlongData.peformanceCycle = '1';
        walkAlongData.feedbackFrom = 'Davina Adams';
        walkAlongData.feedbackTo = 'Mark Abel';
        walkAlongData.submittedDate = '11/10/2010';
        walkAlongData.requestId = WFR.id;
        walkAlongData.selectedRecordType = xspRecType.Id;
        
        
       
        List<WalkalongUtilsReadOnly.Question> question = new List<WalkalongUtilsReadOnly.Question>();
        WalkalongUtilsReadOnly.Question ques = new WalkalongUtilsReadOnly.Question();  
        ques.name = 'Contacts';
        ques.text = 'Strength';
        ques.rating ='Strength';
        ques.notes ='Confidence';
        ques.showNotes = true;
        ques.showHelpText  = true;
        ques.qnId  = null;
        ques.qnNotesId = null;
        question.add(ques);
        
        
        WalkalongUtilsReadOnly.Question ques1 = new WalkalongUtilsReadOnly.Question();  
        ques1.name = 'AreaofFocusNotesVal';
        ques1.text = 'Strength';
        ques1.rating ='Strength';
        ques1.notes ='Confidence';
        ques1.showNotes = true;
        ques1.showHelpText  = true;
        ques1.qnId  = null;
        ques1.qnNotesId = null;
        question.add(ques1);
         
        category.questions = question;
        category.addQuestion(ques);  
        category.addQuestion(ques1);  
       
        List<WalkalongUtilsReadOnly.Category> categories = new List<WalkalongUtilsReadOnly.Category>();
        categories.add(category);
        walkAlongData.categories = categories;
     
        List<WorkFeedback> WFList = new List<WorkFeedback>();
        
        WorkFeedback feedback;
        feedback = new WorkFeedback(RequestId=WFR.Id,
                                        QuestionId=wfq.Id,
                                        Feedback=walkAlongData.overallNotes);
        WFList.add(feedback);
        //insert feedback;
        
        WorkFeedback feedback1;
        feedback1 = new WorkFeedback(RequestId=WFR.Id,
                                        QuestionId=wfq1.Id,
                                        Feedback=walkAlongData.areaOfFocus);
        WFList.add(feedback1);
        //insert feedback1;
        WorkFeedback feedback2;
        feedback2 = new WorkFeedback(RequestId=WFR.Id,
                                        
                                        Feedback=walkAlongData.overallNotesQnId);
        WFList.add(feedback2);
        //insert feedback2;
        /*
        WorkFeedback feedback3;
        feedback3 = new WorkFeedback(RequestId=WFR.Id,
                                        Feedback=walkAlongData.knocks);
        WFList.add(feedback3);    
        
        WorkFeedback feedback4;
        feedback4 = new WorkFeedback(RequestId=WFR.Id,
                                        Feedback=walkAlongData.knocksQnId);
        WFList.add(feedback4);
        
        
        WorkFeedback feedback5;
        feedback5 = new WorkFeedback(RequestId=WFR.Id,
                                        Feedback=walkAlongData.contacts);
        WFList.add(feedback5);
        
        WorkFeedback feedback6;
        feedback6 = new WorkFeedback(RequestId=WFR.Id,
                                        Feedback=walkAlongData.contactsQnId);
        WFList.add(feedback6);
       
        
        WorkFeedback feedback8;
        feedback8 = new WorkFeedback(RequestId=WFR.Id,
                                        Feedback=walkAlongData.startsQnId);
        WFList.add(feedback8);
        
        WorkFeedback feedback7;
        feedback7 = new WorkFeedback(RequestId=WFR.Id,
                                        Feedback=walkAlongData.starts);
        WFList.add(feedback7);
        */
        
        WorkFeedback feedback8;
        feedback8 = new WorkFeedback(RequestId=WFR.Id,
                                        QuestionId=wfq3.Id,Feedback='Needs Improvement');
        WFList.add(feedback8);
        //insert feedback8;
        
        WorkFeedback feedback9;
        feedback9 = new WorkFeedback(RequestId=WFR.Id,
                                        QuestionId=wfq4.Id,Feedback='Strength');
        WFList.add(feedback9);
        //insert feedback9;
        database.insert(WFList,false);
        Test.startTest();
            System.runAs(DSRepUser){
                workfeedbackrequest.subjectId = DSRepUser.Id; 
                WalkalongUtilsReadOnly.XspFeedback xspfbd = new WalkalongUtilsReadOnly.XspFeedback(DSRepUser.name,DSRepUser.Id);
                WalkalongUtilsReadOnly.getXSPList();    
                walkAlongData.selectedXSP =DSRepUser.Id;                                 
            } 
            System.runAs(DSSupUser){                 
                WalkalongUtilsReadOnly.getXSPList();                                                 
            } 
            System.runAs(CARUser){
                workfeedbackrequest.subjectId = CARUser.Id; 
                WalkalongUtilsReadOnly.XspFeedback xspfbd = new WalkalongUtilsReadOnly.XspFeedback(CARUser.name,CARUser.Id);
                WalkalongUtilsReadOnly.getXSPList();    
                walkAlongData.selectedXSP =CARUser.Id;                               
            }
            System.runAs(carMgr){                
                WalkalongUtilsReadOnly.getXSPList();                                                 
            } 
            System.runAs(carDir){                
                WalkalongUtilsReadOnly.getXSPList();                                                 
            } 
            System.runAs(DSMgrUser){                
                WalkalongUtilsReadOnly.getXSPList();  
            } 
            System.runAs(XCMgr){                
                WalkalongUtilsReadOnly.getXSPList();  
             /*
             } 
            System.runAs(CARXC){                
                WalkalongUtilsReadOnly.getXSPList();                  
            */ 
            }       
             WalkalongUtilsReadOnly.getXspFeedbackData(WFR.SubjectId);
             WalkalongUtilsReadOnly.getFeedbackForXsp(WFR.Id);
             WalkalongUtilsReadOnly.getFeedbackForXsp1(WFR.Id); 
             WalkalongUtilsReadOnly.strNotesVal = xspRecType.Name; 
             WalkalongUtilsReadOnly obcls = new WalkalongUtilsReadOnly();
             obcls.getSF1();
             WalkalongUtilsReadOnly.fetchSubject('SubjectId');
             WalkalongUtilsReadOnly.fetchFeedback('FeedBackId');
        Test.stopTest();
    }

    /*
    *  This method set permission set to user base on permissionSetName
    */ 
    static void AssignPermissionSet(String permissionSetName, Id userId){        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);
        
    }
}