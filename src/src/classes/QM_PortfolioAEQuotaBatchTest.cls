@isTest
private class QM_PortfolioAEQuotaBatchTest 
{
 
    public testmethod static void testPortfolioAEQuotaBatch(){
        WorkTestDataUtility.createCustomSettingRecords();
   
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'QM_PortfolioAEQuotaBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
        
       
        
        //List<User> insertUserList = new List<User>();
        
        User currentUser = [Select Id,username from User where Id =: userInfo.getUserId()];

       // User AEUser= WorkTestDataUtility.createAEUser();
       // insertUserList.add(AEUser);   
    
     /** User XCManagerUser = WorkTestDataUtility.createXCManagerUser();
        insertUserList.add(XCManagerUser);
        XCManagerUser.region__c = 'Beltway Market';
        insertUserList.add(XCManagerUser );
        system.debug('INSIDE userlist:' +insertUserList); **/
        User portfolioAeUser= WorkTestDataUtility.createAEUser();
        
        
        system.runAs(currentUser){
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = false;
            insert userTrigger;
            
            // Create GoalTemplate CustomSetting
            GoalTemplateDates__c  gt = new GoalTemplateDates__c();
            gt.Name = 'PortfolioAEs_Quota';
            gt.Current_Period_Start_Date__c = System.Today().addDays(-2);
            gt.Current_Period_Due_Date__c = System.Today().addDays(+2); 
            insert gt;
            
            portfolioAeUser.ProfileId = [Select Id, Name From Profile where Name = 'XC Portfolio AE' limit 1].Id;
            portfolioAeUser.Sales_Rep_Type__c = 'Division';         
            insert portfolioAeUser;
            
            Goal goalTemp = new Goal(); // Standard obj
            goalTemp.Name = 'Test Division Goal';
            goalTemp.Status = 'Draft';
            goalTemp.Profile_Name__c = 'XC Portfolio AE';
            goalTemp.Sales_Rep_Type__c = 'Division';
            goalTemp.Template_Type__c = system.label.Goal_Template_Type_Communities;
            goalTemp.OwnerId = currentUser.id;
            goalTemp.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId();
            goalTemp.StartDate = gt.Current_Period_Start_Date__c;
            goalTemp.DueDate = gt.Current_Period_Due_Date__c;            
            goalTemp.Division__c = 'Northeast';         
            insert goalTemp;
            
            Metric MetricObj = new Metric();
            MetricObj.OwnerId = goalTemp.OwnerId;
            MetricObj.GoalId  = goalTemp.Id;
            MetricObj.Name = 'Units';                               
            MetricObj.TargetValue = 100;
            insert MetricObj;
            
            // Create Goal custom setting record              
            Goal goalRec = new Goal();
            goalRec.Name = 'TestUser_Division Quota_December 2085';
            goalRec.Status = 'Draft';
            goalRec.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
            goalRec.OwnerId = portfolioAeUser.id;
            goalRec.StartDate = System.Today().addDays(-8);
            goalRec.DueDate = System.Today().addDays(-5);        
            insert goalRec;
        String portfolioAEQuotaBatchString ='Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, Comcast_Division__c, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND  Sales_Rep_Type__c = \'Division\' and UserPermissionsWorkDotComUserFeature = true';
        Test.startTest();
            database.executebatch(new QM_PortfolioAEQuotaBatch(PortfolioAEQuotaBatchString));
        Test.stopTest();
        
       }    
    }
}