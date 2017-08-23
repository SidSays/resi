@isTest
private class UpdateMetricBatchTest {

       //public static string sch = '0 0 8 L * ?';
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
    
    static testmethod void TestUpdateMetricBatch() {
        WorkTestDataUtility.createCustomSettingRecords(); 
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'UpdateMetricBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
          
        User SupervisorUser = WorkTestDataUtility.createDSSupervisorUserForCoaching(); 
        insert SupervisorUser;
      
        GoalTemplateDates__c activityGoalCycleDates = new GoalTemplateDates__c();
        TriggerSettings__c triggerSetting = new TriggerSettings__c();
        TriggerSettings__c goaltriggerSetting = new TriggerSettings__c();
        List<TriggerSettings__c> triggerList = new List<TriggerSettings__c>();
     
        activityGoalCycleDates.name = 'ActivityGoalCommissionCycle';
        activityGoalCycleDates.Current_Period_Start_Date__c = System.Today().addDays(-2);
        activityGoalCycleDates.Current_Period_Due_Date__c = System.Today().addDays(+2);   
        Database.insert(activityGoalCycleDates);
        
        triggerSetting.name = 'GoalTrigger';
        triggerSetting.isActive__c= False;
        Database.insert(triggerSetting);
        //triggerList.add(triggerSetting);
        
        goaltriggerSetting.name = 'MetricTriggerBatchCheck';
        goaltriggerSetting.isActive__c= true;
        //triggerList.add(goaltriggerSetting);
        
        Database.insert(goaltriggerSetting);
        
        Variable_Setting__c vs = new Variable_Setting__c();
        vs.Name = 'ProfileCheckForActivityMetricUpdate';
        vs.Value__c = 'Area Sales Manager';
        insert vs;
        
        Metric_Name_Setting__c metricName = new Metric_Name_Setting__c();
        metricName.Name = 'Team Huddles';
        metricName.Metric_Name__c = 'Team Huddles';
        insert metricName;
        
        //User currentUser = [Select Id, ManagerId From User Where Id =: UserInfo.getUserId()];
    System.runAs(new User(Id = UserInfo.getUserId())){ 
    
        AssignPermissionSet('SalesSpace_Coach_Access_SDM',SupervisorUser.Id);
         
        Goal goalObj = new Goal();
        goalObj.Name = 'Test Activity Goal';
        goalObj.OwnerId =  SupervisorUser.Id;
        goalObj.Status = 'Published';
        goalObj.StartDate =  activityGoalCycleDates.Current_Period_Start_Date__c;
        goalObj.DueDate = activityGoalCycleDates.Current_Period_Due_Date__c;
        Database.insert(goalObj);
        
        Metric m = new Metric();
        m.name = 'Team Huddles';
        m.CurrentValue = 1;
        m.targetvalue = 4;
        m.goalId = goalObj.id;
        m.ownerid = SupervisorUser.Id;
        insert m;
    
        UpdateMetricBatch metricUpdate = new UpdateMetricBatch('SELECT id,name,goal.name,goal.StartDate,ownerid,owner.name,owner.profileid,owner.profile.name FROM metric LIMIT 5');
        //UpdateMetricBatchSchedule scheduleMetricUpdate  = new UpdateMetricBatchSchedule();

        Test.startTest();       
            database.executebatch(metricUpdate);   
        Test.stopTest();
         
        //String scheduledJobId = System.schedule('testScheduledApex1', sch, scheduleMetricUpdate);
       }  
    }
}