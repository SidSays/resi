@isTest
private class QM_QuotaAnnualBaselineBatchTest 
{
    /*static testmethod void testQuotaAnnualBaselineBatch () 
    {
        WorkTestDataUtility.createCustomSettingOtherRecords();
        try
        {
            System.debug('Inside Try block');
            populateTestDataForQuotaAnnualBaselineBatch1();         
        }
        catch(exception e)
        {
        System.debug('Inside catch block with exception '+e);
        }
       // Test.startTest();
      //  database.executebatch(new QM_QuotaAnnualBaselineBatch(WorkTestDataUtility.QmQuotaAnnualBaselineQuery ),500);
      //  Test.stopTest();
    }*/
    
    static testmethod void populateTestDataForQuotaAnnualBaselineBatch1(){
       
        WorkTestDataUtility.createCustomSettingRecords();  
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'QM_QuotaAnnualBaselineBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
        
        List<User> insertUserList = new List<User>();
        System.runAs(new User(Id=UserInfo.getUserId())){
            User AE = WorkTestDataUtility.createAEUser();
            AE.Region__c = 'Beltway Market';
            insertUserList.add(AE);
            
            //User AE_Manager = WorkTestDataUtility.createXCManagerUser();
            //AE_Manager.region__c = 'Beltway Market';
            //insertUserList.add(AE_Manager);        
            insert insertUserList;      
            //AE.ManagerId = AE_Manager.id;
            //update AE;
            
            // Create GoalTemplate CustomSetting
            GoalTemplateDates__c  gt = new GoalTemplateDates__c();
            gt.Name = 'Default_Communities';
            gt.Current_Period_Start_Date__c = System.Today().addDays(-2);
            gt.Current_Period_Due_Date__c = System.Today().addDays(+2); 
            insert gt;
            
            
            
            
             // Create New Goal Template records for manager 
            Goal g = new Goal(); // Standard obj
            g.Name = 'Test';
            g.Profile_Name__c = 'XC Account Executive';
            g.OwnerId = UserInfo.getUserId();    
            g.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId();
            g.Template_Type__c = 'Communities';
            g.StartDate = gt.Current_Period_Start_Date__c;
            g.DueDate = gt.Current_Period_Due_Date__c; 
            g.Region__c = 'Beltway Market';       
            insert g;
            
            Metric MetricObj = new Metric();
            MetricObj.OwnerId = g.OwnerId;
            MetricObj.GoalId  = g.Id;
            MetricObj.Name = 'Units';                               
            MetricObj.TargetValue = 100;
            insert MetricObj;
            
            
            
            Goal goalRec = new Goal();
            goalRec.Name = 'Test AE - November 2014';
            goalRec.Status = 'Published';
            goalRec.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
            goalRec.Assigned_To__c = AE.id;
            goalRec.OwnerId = AE.id;        
            insert goalRec;
        }
        
         // Schedular Test
        Test.startTest();
            database.executebatch(new QM_QuotaAnnualBaselineBatch(WorkTestDataUtility.QmQuotaAnnualBaselineQuery ));
            //System.schedule('Scheduled Job 1', '0 0 * * * ?', new  QM_QuotaAnnualBaselineBatchSchedule());
        Test.stopTest();
        
           
    }
}