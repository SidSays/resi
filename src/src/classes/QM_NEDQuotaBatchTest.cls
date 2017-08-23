@isTest
private class QM_NEDQuotaBatchTest 
{    
    static testmethod void testNEDQuotaBatch() 
    {
      // WorkTestDataUtility.createCustomSettingOtherRecords();
         WorkTestDataUtility.createCustomSettingRecords();
            
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'QM_NEDQuotaBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
      
        User currentUser = [Select Id,username from User where Id =: userInfo.getUserId()];
        
        GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
        User NEDAeUser = WorkTestDataUtility.createAEUser();
        system.runAs(currentUser){
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = false;
            insert userTrigger;
            
            
            NEDAeUser.Sales_Rep_Type__c = 'NED';      
            insert NEDAeUser;
            
            // Create GoalTemplate CustomSetting
            GoalTemplateDates__c  gt = new GoalTemplateDates__c();
            gt.Name = 'NED_Quota';
            gt.Current_Period_Start_Date__c = System.Today().addDays(+2);
            gt.Current_Period_Due_Date__c = System.Today().addDays(-2); 
            insert gt;
            
            
            Goal goalTemp = new Goal(); // Standard obj
            goalTemp.Name = 'Test NED Goal';
            goalTemp.Status = 'Draft';
            goalTemp.Profile_Name__c = 'XC Account Executive';
            goalTemp.Sales_Rep_Type__c = 'NED';
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
            
            Goal goalRec = new Goal();
            goalRec.Name = 'TestUser_NED Quota_December 2014';
            goalRec.Status = 'Draft';
            goalRec.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
            goalRec.OwnerId = NEDAeUser.id;
            goalRec.StartDate = System.Today().addDays(-8);
            goalRec.DueDate = System.Today().addDays(-5);        
            insert goalRec;   
        }
        Test.startTest();
            database.executebatch(new QM_NEDQuotaBatch(WorkTestDataUtility.NEDQuotaBatchString));       
        Test.stopTest();
    }
    
 }