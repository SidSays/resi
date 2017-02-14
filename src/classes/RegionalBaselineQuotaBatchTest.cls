@isTest
private class RegionalBaselineQuotaBatchTest 
{
    
    static testmethod void testReionalBaselineQuotaBatch() 
    {
       // WorkTestDataUtility.createCustomSettingOtherRecords();
        WorkTestDataUtility.createCustomSettingRecords();
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'RegionalBaselineQuotaBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
        
         User currentUser = [Select Id,username from User where Id =: userInfo.getUserId()];
        //List<User> insertUserList = new List<User>();
        
       // User AE = WorkTestDataUtility.createAEUser();
       /// AE.Sales_Rep_Type__c = 'Region';
       // insertUserList.add(AE);
     
      //  Test.startTest();
     //   insert insertUserList;
      //  Test.stopTest();
    
        system.runAs(currentUser){
        
        // Create GoalTemplate CustomSetting
        GoalTemplateDates__c  gt = new GoalTemplateDates__c();
        gt.Name = 'Regional_Baseline_Quota';
        gt.Current_Period_Start_Date__c = Date.newinstance(2015, 12, 22);
        gt.Current_Period_Due_Date__c = Date.newinstance(2016, 01, 21); 
        insert gt;
        
        
        
        
         // Create New Goal Template records for manager 
        Goal g = WorkTestDataUtility.createRegionalQuotaGoal(); // Standard obj
        g.Profile_Name__c =WorkTestDataUtility.getXCManagerProfile().Name;
        g.OwnerId = currentUser.id;
        g.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId();
        g.StartDate = gt.Current_Period_Start_Date__c;
        g.DueDate = gt.Current_Period_Due_Date__c; 
        g.Region__c = 'Beltway Market';
         update g;
       
                  
      /*  Map<Id, Id> groupMap = new Map<Id, Id>(); // To map the user id with its manager hierarchy
        for(Group grp : [SELECT Id, RelatedId,Type FROM Group WHERE Type = 'Regular' AND RelatedId =:AE.Id]){
            groupMap.put(grp.RelatedId, grp.Id);
        }
                GoalShare WGRecord = new GoalShare();                   
                                    WGRecord.userorgroupId = groupMap.get(AE.Id);
                                    WGRecord.AccessLevel = 'Edit';
                                    WGRecord.rowCause = Schema.GoalShare.rowCause.Manual;
                                    WGRecord.ParentId = g.Id; 
                                    insert WGRecord;
        */
       
       
        
        List<Metric> newmetrics = WorkTestDataUtility.createRegionalQuotaMetric();
        List<Metric> updatedNewMetrics = new List<Metric>();
        for(Metric m : newmetrics ){
            m.GoalId  = g.Id;
            m.OwnerId = g.OwnerId;
            updatedNewMetrics.add(m);
        }
        update updatedNewMetrics;
        
        // Create Goal custom setting record
        List<Goal> goals = new List<Goal>();
        
        Goal goalRec = new Goal();
        goalRec.Name = 'Regional Quota_Beltway Market_December 2085';
        goalRec.Status = 'Draft';
        goalRec.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
       
        goalRec.OwnerId = currentUser.id;
        goals.add(goalRec);
        insert goals;
        
        List<TriggerSettings__c> ts = new List<TriggerSettings__c>();
        TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('MetricTrigger');
           triggerSetting.isActive__c = false;
          ts.add(triggerSetting);
          update ts;
         // Schedular Test
        // Test.startTest();
      //  System.schedule('Scheduled Job 1', '0 0 * * * ?', new  QM_NEDQuotaBatchSchedule());
      //  Test.stopTest();
        
        }
        
       database.executebatch(new RegionalBaselineQuotaBatch(WorkTestDataUtility.RegionalBaselineQuotaBatchString));
       
    }
      
    
    
 }