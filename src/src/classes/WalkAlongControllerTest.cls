/**************************************************************************************************
Name : WalkAlongControllerTest
Description : This test class created to cover the classes WalkAlongController and WalkalongUtils.
User Story : US571014
Date : 15 October 2015
Author : Rahul Prabhakar & Anil Singh
***************************************************************************************************/
@isTest
    public class WalkAlongControllerTest{
    static testmethod void method() {

    WorkPerformanceCycle wperformance = new WorkPerformanceCycle();
    wperformance.Name = 'Performance1';
    wperformance.ActivityFrom = System.Today()-10;
    wperformance.ActivityTo = System.Today()+30;
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
    
    WalkAlongController.Category category= new WalkAlongController.Category();
    category.category = 'Contacts';
    category.text ='Prepare - Energy';
    category.rating = 'Highly Effective';
    category.showNotes = true;
    category.categoryQnId = null;

    WalkAlongController.WalkAlongData walkAlongData = new WalkAlongController.WalkAlongData();
    walkAlongData.overallNotes = 'He is good performer';
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
    walkAlongData.areaOfFocusQnNotesId =null;
    walkAlongData.walkAlongStarted = true; 
    walkAlongData.walkAlongStopped = true;
    walkAlongData.startTime ='04:56:00';
    walkAlongData.endTime ='09:56:00';
    walkAlongData.showNotes = true;
    walkAlongData.lastSavedDate ='11/10/2010';
    walkAlongData.score = 100;
    walkAlongData.overallRating = 'Achieved Expectations';
    walkAlongData.addCategory(category);
   
    System.runAs(DSRepUser){
             workfeedbackrequest.subjectId = DSRepUser.Id; 
             WalkAlongController.Xsp xsp = new WalkAlongController.Xsp(DSRepUser.name,DSRepUser.Id);
             WalkAlongController.getXSPList();    
             walkAlongData.selectedXSP =DSRepUser.Id; 
             
    }  
        
    List<WalkAlongController.Question> question = new List<WalkAlongController.Question>();
    WalkAlongController.Question ques = new WalkAlongController.Question();  
    ques.name = 'Contacts';
    ques.text = 'Strength';
    ques.rating ='Strength';
    ques.notes ='Confidence';
    ques.showNotes = true;
    ques.showHelpText  = true;
    ques.qnId  = null;
    question.add(ques);
   
    category.questions = question;
    category.addQuestion(ques);
   
    List<WalkAlongController.Category> categories = new List<WalkAlongController.Category>();
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
    
    walkAlongData.categories = categories;
    WalkAlongController.saveData(walkAlongData);
    WalkAlongController.getFeedbackForXsp(walkAlongData.selectedXSP);
    //WalkAlongController.submitWalkAlong(walkAlongData);
     
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