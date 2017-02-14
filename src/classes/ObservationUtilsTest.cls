/**************************************************************************************************
Name : ObservationControllerTest
Description : This test class created to cover the classes ObservationController and ObservationUtils.
User Story : US571014
Date : 15 October 2015
Author : Rahul Prabhakar & Anil Singh
***************************************************************************************************/
@isTest
    public class ObservationUtilsTest{
    
    static testmethod void method() {
    RecordType xspRecType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name =:Label.XSP_Ridealong LIMIT 1];
   // RecordType CarRecType = [SELECT Id FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name =:Label.CAR_Event LIMIT 1];
    //RecordType PropertyRecType = [SELECT Id FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name =:Label.Property_Visit LIMIT 1];
    
    WorkPerformanceCycle wperformance = new WorkPerformanceCycle();
    wperformance.Name = 'Performance1';
    wperformance.ActivityFrom = System.Today()-10;
    wperformance.ActivityTo = System.Today()+30;
    wperformance.RecordTypeId = xspRecType.Id;
    wperformance.State = 'Setup';
    insert wperformance;
   
    WorkFeedbackQuestionSet wquestion = new WorkFeedbackQuestionSet ();
    wquestion.Name = 'XSP Walkalong';
    wquestion.PerformanceCycleId = wperformance.Id;
    wquestion.FeedbackType = 'CycleManager';
    wquestion.duedate = System.Today()+30;
    insert wquestion;
   
    WorkFeedbackQuestion wquest = new WorkFeedbackQuestion ();
    wquest.QuestionSetId = wquestion.Id;
    wquest.Name = 'Overall Notes';
    wquest.Text = 'Overall Notes';
    wquest.Number = 1;
    wquest.Type = 'FreeText';
    wquest.Category__c = 'Prepare - Energy';
    wquest.Section__c = 'Observation';
    wquest.Weight__c = 20;
    insert wquest;
   
    WorkTestDataUtility.createCustomSettingRecords();
    WorkTestDataUtility.ActivityGoalCommissionCycle();
    User DSSupUser = WorkTestDataUtility.createDSSupervisorUser();
    User DSRepUser = WorkTestDataUtility.createDSRepUser();

    /* Assign PermissionSet to Coresponding Profile user */
    User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
    System.runAs(currentUser){                     
            AssignPermissionSet('SalesSpace_Coach_Access_SDM',DSSupUser.Id);
            AssignPermissionSet('SalesSpace_Coach_Access_XSP',DSRepUser.Id);
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
    WFR.FeedbackRequestState='Submitted'; 
    WFR.QuestionSetId = wquestion.Id;
   // WFR.PerformanceCycle.RecordTypeId = wperformance.RecordTypeId;
    wfrList.add(WFR);
    insert wfrList;
    System.debug('&&&&&&&&&&&' +wfrList);
    ObservationController.Category category= new ObservationController.Category();
    category.category = 'Contacts';
    category.text ='Prepare - Energy';
    category.rating = 'Highly Effective';
    category.showNotes = true;
    category.categoryQnId = null;
    
    ObservationController.Section section = new ObservationController.Section ();
    section.name= 'Common';
    section.showSection = true;

    ObservationController.WalkAlongData walkAlongData = new ObservationController.WalkAlongData();
    /*walkAlongData.overallNotes = 'He is good performer';
    walkAlongData.overallNotesQnId =null;
    walkAlongData.knocks ='5';
    walkAlongData.knocksQnId =null;
    walkAlongData.contacts ='3';
    walkAlongData.contactsQnId =null;
    walkAlongData.requestId =null;
    walkAlongData.starts = '4';
    walkAlongData.startsQnId =null;
    walkAlongData.areaOfFocus ='Prepare - Energy';
    walkAlongData.areaOfFocusQnId =null;
    walkAlongData.areaOfFocusNotes ='Good Performer';
    walkAlongData.areaOfFocusQnNotesId =null;*/
    walkAlongData.walkAlongStarted = true; 
    walkAlongData.showSection = true;
    walkAlongData.walkAlongStopped = true;
    walkAlongData.startTime ='04:56:00';
    walkAlongData.endTime ='09:56:00';
    walkAlongData.showNotes = true;
    walkAlongData.lastSavedDate ='11/10/2010';
    walkAlongData.score = 100;
    walkAlongData.scorePct = 100;
    walkAlongData.overallRating = 'Achieved Expectations';
    walkAlongData.addSection(section);
    
    List<ObservationController.Question> question = new List<ObservationController.Question>();
    ObservationController.Question ques = new ObservationController.Question();  
    ques.name = 'Contacts';
    ques.text = 'Strength';
    ques.rating ='Strength';
    ques.notes ='Confidence';
    ques.showNotes = true;
    ques.showHelpText  = true;
    ques.qnId  = null;
    ques.qnNotesId = 'test';
    question.add(ques);
   
    category.questions = question;
    category.addQuestion(ques);
   
    List<ObservationController.Category> categories = new List<ObservationController.Category>();
    categories.add(category);
    Goal goalTemp = WorkTestDataUtility.createGoal();
    goalTemp.OwnerId = DSSupUser.Id;
    goalTemp.StartDate = System.Today().addDays(-2);
    goalTemp.DueDate = System.Today().addDays(+2);
    Database.Update(goalTemp); 
    
    List<Metric> metricList = new List<Metric>();
    For(Metric metricTemp : CreateMetrics()){
        metricTemp.GoalId = goalTemp.Id;
        metricTemp.Status = 'Behind';
        metricList.add(metricTemp);
    } 
    
    Database.update(metricList);
    
      System.runAs(DSRepUser){
             workfeedbackrequest.subjectId = DSRepUser.Id; 
             ObservationController.Xsp xsp = new ObservationController.Xsp(DSRepUser.name,DSRepUser.Id);
             ObservationController.getXSPList();    
             walkAlongData.selectedXSP =DSRepUser.Id; 
             
             ObservationController.RecordTypeCar recordtypecarval = new ObservationController.RecordTypeCar(xspRecType.name,xspRecType.Id);
             ObservationController.getRecordTypeCarList();    
             walkAlongData.selectedRecordType =xspRecType.Id; 
    }      
    ObservationController.getObservationForm();
     ObservationUtils.saveSubmitFeedback(walkAlongData,'abc',false);
  //   ObservationController.getRecordTypeCarList();
  //   ObservationController.saveData(walkAlongData);
   
    
     
    //ObservationController.submitWalkAlong(walkAlongData);
     
   }
    Public static List<Metric> CreateMetrics(){
        List<Metric> merticList = new List<Metric>();
        for(integer i=0; i<3; i++){
            Metric MetricObj = new Metric();
            if(i==0){
                MetricObj.Name = 'Walkalongs';                               
            }
            else if(i==1){
                MetricObj.Name = 'Team Huddle';               
            }
            else if(i==2){
                MetricObj.Name = 'Team Forum';               
            }
            
            MetricObj.TargetValue = 100;
            //MetricObj.Status = 'Not Started';
            merticList.add(MetricObj);
        }
        Database.Insert(merticList);
        return merticList;  
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