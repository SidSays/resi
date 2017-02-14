@isTest
private class QM_NAMsQuotaBatchTest 
{   
    static testmethod void testNAMQuotaBatch() 
    {     
        WorkTestDataUtility.createCustomSettingRecords();            
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'QM_NAMsQuotaBatchTest';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
        
        User currentUser = [Select Id,username from User where Id =: userInfo.getUserId()];
      
        // Create GoalTemplate CustomSetting
        GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
        User NamAeUser = WorkTestDataUtility.createAEUser();
        System.runAs(currentUser){
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = false;
            insert userTrigger;
            
            /*User NamAeManager = WorkTestDataUtility.createXCManagerUser();
            NamAeManager.Sales_Rep_Type__c = 'NAM';
            update NamAeManager;*/
        
            
            NamAeUser.Sales_Rep_Type__c = 'NAM';        
            //NamAeUser.ManagerId = NamAeManager.id;
            insert NamAeUser;
            
            goalTemplateDateCS.Name = 'NAMs_Quota';
            goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
            goalTemplateDateCS.Current_Period_Start_Date__c = System.Today().addDays(-2);
            Database.insert(goalTemplateDateCS);
        }
        // Create New Goal Template records for AE 
        Goal goalTemp = new Goal(); // Standard obj
        goalTemp.Name = 'Test NAM Goal';
        goalTemp.Status = 'Draft';
        goalTemp.Profile_Name__c = 'XC Account Executive';
        goalTemp.Sales_Rep_Type__c = 'NAM';
        goalTemp.Template_Type__c = system.label.Goal_Template_Type_Communities;
        goalTemp.OwnerId = currentUser.id;
        goalTemp.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId();
        goalTemp.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
        goalTemp.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c; 
        goalTemp.Region__c = 'Beltway Market';        
        insert goalTemp;
        
        Metric MetricObj = new Metric();
        MetricObj.OwnerId = goalTemp.OwnerId;
        MetricObj.GoalId  = goalTemp.Id;
        MetricObj.Name = 'Units';                               
        MetricObj.TargetValue = 100;
        insert MetricObj;
       
        /*List<Metric> newmetrics = WorkTestDataUtility.createNEDQuotaMetric();
        List<Metric> updatedNewMetrics = new List<Metric>();
        for(Metric metricTemp : newmetrics){
            metricTemp.GoalId  = goalTemp.Id;
            metricTemp.OwnerId = goalTemp.OwnerId;
            updatedNewMetrics.add(metricTemp);
        }
        update updatedNewMetrics;*/
    
        // Create Goal custom setting record              
        Goal goalRec = new Goal();
        goalRec.Name = 'TestUser_NAM Quota_December 2085';
        goalRec.Status = 'Draft';
        goalRec.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
        goalRec.OwnerId = NamAeUser.id;
        goalRec.StartDate = System.Today().addDays(-8);
        goalRec.DueDate = System.Today().addDays(-5);        
        insert goalRec;
        
        Test.startTest(); 
            database.executebatch(new QM_NAMsQuotaBatch(WorkTestDataUtility.NAMQuotaBatchString));
        Test.stopTest();  
    } 
 }