/**************************************************************************************************
Name : WalkalongUtilsReadOnlyTest
Description : This test class created to cover the class WalkalongUtilsReadOnly
Date : 5 April 2016
Author : Saket Sharma
***************************************************************************************************/
@isTest
    public class WalkalongUtilsReadOnlyTest{
    static testmethod void method1() {
    RecordType xspRecType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name =:Label.XSP_Ridealong LIMIT 1];
    List<WorkPerformanceCycle>lstWorkPerfor = new List<WorkPerformanceCycle> ();
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
    
    
    WorkFeedbackQuestion wfq=new WorkFeedbackQuestion();
    wfq.Name='On Time';
    wfq.Text='On Time for appointment/event';
    wfq.Number=1;
    wfq.Choices='N/A\nStrength\nOpportunity';
    wfq.QuestionSetId=wquestion.Id;
    wfq.Type='MultipleChoice';
    wfq.Section__c = 'Observations';
    wfq.Weight__c = 10;
    insert wfq;
    
    WorkFeedbackQuestion wfq1=new WorkFeedbackQuestion();
    wfq1.Name='Area of Focus - notes';
    wfq1.Text='Area of Focus - notes';
    wfq1.Number=2;
    wfq1.QuestionSetId=wquestion.Id;
    wfq1.Type='FreeText';
    wfq1.Section__c = 'Common';
    wfq1.Weight__c = 10;
    insert wfq1;
    
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
        insert wquest2;
        
    WorkTestDataUtility.createCustomSettingRecords();
    WorkTestDataUtility.ActivityGoalCommissionCycle();
    User DSSupUser = WorkTestDataUtility.createDSSupervisorUser();
    User DSRepUser = WorkTestDataUtility.createDSRepUser();
    User CARUser = WorkTestDataUtility.createCARUser();

    /* Assign PermissionSet to Coresponding Profile user */
    User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
    System.runAs(currentUser){                     
            AssignPermissionSet('SalesSpace_Coach_Access_SDM',DSSupUser.Id);
            AssignPermissionSet('SalesSpace_Coach_Access_XSP',DSRepUser.Id);
            AssignPermissionSet('Xfinity_Sales_Executive',DSRepUser.Id);
    }

    WorkFeedbackRequest workfeedbackrequest;
    
    System.runAs(DSSupUser){
        workfeedbackrequest = new WorkFeedbackRequest(RecipientId = DSSupUser.Id,
            Type__c= 'Walkalong',AdHocQuestion = 'How is the feedback',Score__c = 10,FeedbackRequestState='Draft');
    }
 
   
    List<WorkFeedbackRequest> wfrList = new List<WorkFeedbackRequest>();
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
    walkAlongData.areaOfFocus ='Prepare - Energy';
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
    

     WorkFeedback feedback1;
    feedback1 = new WorkFeedback(RequestId=WFR.Id,
                                    Feedback=walkAlongData.areaOfFocus);
    WFList.add(feedback1);
    
    WorkFeedback feedback2;
    feedback2 = new WorkFeedback(RequestId=WFR.Id,
                                    Feedback=walkAlongData.overallNotesQnId);
    WFList.add(feedback2);
    
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
    
    System.debug('Feedback========= '+ Feedback);
    
    database.insert(WFList,false);
    System.debug('WFList========= '+ WFList);
    
    System.runAs(DSRepUser){
             workfeedbackrequest.subjectId = DSRepUser.Id; 
             WalkalongUtilsReadOnly.XspFeedback xspfbd = new WalkalongUtilsReadOnly.XspFeedback(DSRepUser.name,DSRepUser.Id);
             WalkalongUtilsReadOnly.getXSPList();    
             walkAlongData.selectedXSP =DSRepUser.Id;
             
             
    } 
    
     System.runAs(CARUser){
             workfeedbackrequest.subjectId = CARUser.Id; 
             WalkalongUtilsReadOnly.XspFeedback xspfbd = new WalkalongUtilsReadOnly.XspFeedback(CARUser.name,CARUser.Id);
             WalkalongUtilsReadOnly.getXSPList();    
             walkAlongData.selectedXSP =CARUser.Id;
             
             
    }
     WalkalongUtilsReadOnly.getXspFeedbackData(WFR.SubjectId);
     WalkalongUtilsReadOnly.getFeedbackForXsp(WFR.Id);
     WalkalongUtilsReadOnly.getFeedbackForXsp1(WFR.Id); 
     WalkalongUtilsReadOnly.strNotesVal = xspRecType.Name; 
     WalkalongUtilsReadOnly obcls = new WalkalongUtilsReadOnly ();
     obcls.getSF1();
     WalkalongUtilsReadOnly.fetchSubject('SubjectId');
     WalkalongUtilsReadOnly.fetchFeedback('FeedBackId');
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