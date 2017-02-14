@isTest
private class QM_AnnualBaselineContractorBatchTest  {
    
     static testmethod void testQuotaAnnualBaselineBatch () {
        //WorkTestDataUtility.createCustomSettingOtherRecords();
        //try
        //{
            System.debug('Inside Try block');
            createTestData();         
        //}
        //catch(exception e)
        //{
        //System.debug('Inside catch block with exception '+e);
        //}
       // Test.startTest();
      //  database.executebatch(new QM_QuotaAnnualBaselineBatch(WorkTestDataUtility.QmQuotaAnnualBaselineQuery ),500);
      //  Test.stopTest();
    }
    
    public static void createTestData() {
        WorkTestDataUtility.createCustomSettingRecords();
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'QM_AnnualBaselineBatchContractor';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
        
        User conAEUser;
        User XCManagerUser;
        User XCManagerUser2;
        System.runAs(new User(Id=UserInfo.getUserId())){
        Profile profConAE = [Select Id, Name From Profile where Name = 'XC AE Contractors' limit 1];
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        conAEUser = new User(Alias = 'AE_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = profConAE.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
                                    database.insert(conAEUser);  
                                    
        Profile profManager = [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
        //generate Random String 
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        XCManagerUser = new User(Alias = 'DSR_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = profManager.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr1,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
                                    );
                                    database.insert(XCManagerUser);
          String randomstr2 = Math.round(Math.random()*Math.pow(10, 5)+1150)+'';                          
          XCManagerUser2 = new User(Alias = 'DSR_' + randomstr2.substring(0,4),
                                    Email = randomstr2 + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = profManager.Id,
                                    Username = 'userTest1' + randomstr2 + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr2,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr2.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
                                    );
                                    database.insert(XCManagerUser2);                          
          }                         
          List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        //TriggerSettings__c userTrigger = new TriggerSettings__c() ;
             //userTrigger.Name = 'UserTrigger';
             //userTrigger.isActive__c = false;
             //triggerSettingsList.add(userTrigger);
         /*TriggerSettings__c goalTrigger= new TriggerSettings__c();
            goalTrigger.Name = 'GoalTrigger';
            goalTrigger.isActive__c = true;
            triggerSettingsList.add(goalTrigger);*/
            
             TriggerSettings__c contractTrigger = new TriggerSettings__c() ;
             contractTrigger.Name = 'ContractorRegionMappingTrigger';
             contractTrigger.isActive__c = true;
             insert contractTrigger;
             //triggerSettingsList.add(contractTrigger);
            
             //insert triggerSettingsList ; 
         
         Contractor_Region_Mapping__c contRegMap =  new Contractor_Region_Mapping__c();
                    contRegMap.Region__c =  'Freedom Market';
                    contRegMap.Reporting_Manager__c = XCManagerUser.Id;
                    contRegMap.AE_Contractor__c = conAEUser.ID ;
                    insert contRegMap;
                    
    GoalTemplateDates__c  gt = new GoalTemplateDates__c();
            gt.Name = 'Regional Baseline Quota for Contractor';
            gt.Current_Period_Start_Date__c = System.Today().addDays(-2);
            gt.Current_Period_Due_Date__c = System.Today().addDays(+2); 
            insert gt;  

      Goal goalObject = new Goal();
        goalObject.Name = 'Test Goal';
        goalObject.Status = 'Draft';
        goalObject.RecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId(); 
        goalObject.OwnerId = UserInfo.getUserId();
        insert goalObject;

        goalObject.Profile_Name__c ='XC AE Contractors';
        goalObject.OwnerId = XCManagerUser.id;
     //   g.Region__c = AE_Manager.Region__c;
        goalObject.recordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId();
        goalObject.Template_Type__c = 'Communities';
        goalObject.StartDate = gt.Current_Period_Start_Date__c;
        goalObject.DueDate = gt.Current_Period_Due_Date__c; 
        goalObject.Region__c = 'Freedom Market';
        //g.OrigGoalId__c =UserInfo.getUserId();
        //g.UserOrGroupId =[Select id,name from Goal where managerId =: Owner.id ];
        update goalObject;      
        
        List<Metric> merticList = new List<Metric>();
        for(integer i=0; i<1; i++){
            Metric metricObj = new Metric();
            metricObj.OwnerId = UserInfo.getUserId();
            if(i==0){
                metricObj.Name = 'Units';
                metricObj.TargetValue = 100;
            }
            
            merticList.add(metricObj);
        }
        Database.Insert(merticList);
        
        
        List<Metric> updatedNewMetrics = new List<Metric>();
        for(Metric m : merticList ){
            m.GoalId  = goalObject.Id;
            m.OwnerId = goalObject.OwnerId;
            updatedNewMetrics.add(m);
        }
        update updatedNewMetrics;
        
         Test.startTest();
        //System.schedule('Scheduled Job 1', '0 0 * * * ?', new  QM_AnnualBaselineContractorBatchSchedule());
        String queryString='SELECT Id, Name, AE_Contractor__c, AE_Contractor__r.UserPermissionsWorkDotComUserFeature,AE_Contractor__r.Profile.Name, AE_Contractor__r.Name, Reporting_Manager__c, Region__c, Region_Mapping_Key__c FROM Contractor_Region_Mapping__c WHERE AE_Contractor__r.Profile.name = \'XC AE Contractors\' AND AE_Contractor__r.UserPermissionsWorkDotComUserFeature = true AND AE_Contractor__r.isActive = true';
        QM_AnnualBaselineContractorBatch quotaAnnualBaselineBatch = new QM_AnnualBaselineContractorBatch(queryString); 
        database.executebatch(quotaAnnualBaselineBatch,5);
        contRegMap.Reporting_Manager__c = XCManagerUser2.Id;
        update contRegMap;
        Test.stopTest();
    }
}