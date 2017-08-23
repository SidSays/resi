@isTest
private class UserInactiveAddressUpdateBatchTest{
        public static String CRON_EXP1 = '0 0 0 3 9 ? 2022';
        public static String CRON_EXP2 = '0 0 0 3 9 ? 2022';        
    public static testMethod void UserInactiveAddressUpdateBatchTestMethod(){


        //Setting up test data for custom setting
        SetupTestData.createCustomSettingRecords();
        VariableSettingTestUtility.variableSettingsData(); 
        
                //Create a User with System Admin Profile
        Profile systemAdministratorProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User testUser1 = new User(Alias = 'standt2', Email='standarduser221@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing11122', LanguageLocaleKey='en_US',NTLogin__c='asd11122',FederationIdentifier='asd11122',
        LocaleSidKey='en_US', ProfileId = systemAdministratorProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser11122@testorgg.com');
        
         System.runas(testUser1){ 
            //Create a User with Retail Sales Rep Profile
            Profile directSalesRepProfile = [SELECT Id FROM Profile WHERE Name='XFINITY Sales Professional']; 
            User testUser2 = new User(Alias = 'standt', Email='standarduser112@testorg.com',
            PERNR__c='10254424',
            EmailEncodingKey='UTF-8', LastName='Testing111', LanguageLocaleKey='en_US',NTLogin__c='asd111',FederationIdentifier='asd111',
            LocaleSidKey='en_US', ProfileId = directSalesRepProfile.Id, TimeZoneSidKey='America/Los_Angeles', UserName='standarduser111@testorgg.com');
            Insert testUser2;
            
//Create Plan
        Plan__c testPlan = new Plan__c();
        testPlan.Name = 'TestPlan1';
        testPlan.Plan_Level__c = 'Turf';
        testPlan.Plan_Status__c = Label.PlanStatusDraft;
        date ExpireDate = date.today().addDays(2);
        testPlan.Expiration_Date__c = ExpireDate;
        testPlan.User__c = testUser2.Id;        
        Insert testPlan;
        
        //Create a list of Addresses and adding them to the plan 
      Customer_Address__c addr = new Customer_Address__c();
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '12345';
            addr.Route_Code__c = '1111111111';
            addr.Corp__c = '111111';
            addr.Non_Marketable__c = TRUE;
            addr.Do_Not_Knock__C = TRUE;
            addr.ManagementArea__c = '12345';
            insert addr;
            addr.Plan__c = testPlan.Id;
            addr.ownerid=testUser2.Id;
            update addr;
                   
            System.debug('testPlan --------------------------------------->'+testPlan);
            
            //Making the user inactive
            testUser2.IsActive = false;
            date YesDate = system.today() - 1;            
            //testUser2.LastModifiedDate=YesDate;
            update testUser2;
            System.debug('Test User 2 --------------------------------------->'+testUser2);
            System.debug('testPlan --------------------------------------->'+testPlan);
            
            // Schedule apex            
            Test.StartTest();                    
            UserInactivePlanBatch UserInactivePlanBatchObj = new UserInactivePlanBatch();     
            UserInactiveAddressBatch UserInactiveAddressBatchobj = new UserInactiveAddressBatch();       
            String scheduledJobId1 = System.schedule('testScheduledApex1', CRON_EXP1, UserInactivePlanBatchObj);            
            String scheduledJobId2 = System.schedule('testScheduledApex2', CRON_EXP2, UserInactiveAddressBatchobj);  
            Test.StopTest();             
            System.assert(scheduledJobId1 != null);
            
            System.assert(scheduledJobId2 != null);            

        }
    }
}