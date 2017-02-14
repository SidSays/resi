@isTest(seeAllData=false)
private class CommunitiesForecastUpdateBatchTest {
    
    static testMethod void CommunitiesForecastUpdate() { 
        TestDataUtility.createCustomSettingRecords(); 
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'CommunitiesForecastUpdateBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'New';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
        
        String Goal_Communities_RecordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.Goal_Xfinity_Communities_Recordtype).getRecordTypeId();
        String Opportunity_Communities_RecordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId();
        
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = false;
        insert userTrigger;
      
        User xcAEUser = WorkTestDataUtility.createAEUser();
        insert xcAEUser;
        //User currentUser = [Select Id,username from User where Id =: userInfo.getUserId()];
        
        Account accObj = TestDataUtility.createAccount();
    
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1);
        MDU_property__c propObj = TestDataUtility.createProperty();
        GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
        goalTemplateDateCS.Name = 'Forecast_Setting';
        goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
        goalTemplateDateCS.Current_Period_Start_Date__c = System.Today().addDays(-2);
        
        
        System.runAs(new User(Id=Userinfo.getUserId())){ 
            Database.insert(goalTemplateDateCS);
            insert propObj;
            Insert accObj;
            
            Goal goalObj = new Goal();
            goalObj.Name = 'Test Goal';
            goalObj.OwnerId = xcAEUser.Id;
            goalObj.startDate = System.Today()-2;
            goalObj.DueDate = System.Today()+2;
            goalObj.recordTypeId = Goal_Communities_RecordtypeId;
            Database.insert(goalObj);
            
            oppList[0].AccountId = accObj.id;
            oppList[0].recordTypeId = Opportunity_Communities_RecordtypeId;
            oppList[0].AssignedAE_ID__c = xcAEUser.Id;
            oppList[0].Type = 'New Build';
            oppList[0].Property__c = PropObj.id;
            oppList[0].ContractTerm__c = 12;
            oppList[0].ContractTermUnit__c = 'months';
            oppList[0].Contract_Type__c = 'Bulk';
            oppList[0].Fiber_To_The_Unit__c='Fiber to the Unit';
            oppList[0].Goal__c=goalObj.Id;
            oppList[0].StageName = 'Assigned';
            //oppList[0].Number_of_Units__c = PropObj.Number_of_Units__c;
            oppList[0].CompletionForecastDate__c = System.Today();
            //oppList[0].Goal__c = goalObj.Id;
            Database.Insert(oppList);
         
            Opportunity_Property__c oppPropObj = TestDataUtility.createOppProperty(oppList[0].id,propObj.id);
            oppPropObj.Primary_Property__c = true;
            Database.Insert(oppPropObj,false);
                        
            List<Metric> MetricList = new List<Metric>();
            Metric metricNewBuild = new Metric();
            metricNewBuild.OwnerId = xcAEUser.Id;
            metricNewBuild.goalId = goalObj.id;
            metricNewBuild.name = 'Units';
            metricNewBuild.CurrentValue = 0;
            //metricNewBuild.Forecasted_Units_I__c = 101;
            MetricList.add(metricNewBuild);
            Database.insert(MetricList);
         
        }
        Test.startTest();
            database.executebatch(new CommunitiesForecastUpdateBatch(WorkTestDataUtility.communitiesForecastUpdateBatchString));
        Test.stopTest();
    }  
}