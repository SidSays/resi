/**
 * Test class for RGUOrder batch 
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 12/1/14
 */

@isTest
private class RGUOrderBatchTest {
    
    static testMethod void rGUCountTest() {
        SetupTestData.createCustomSettingRecords();
        TriggerSettings__c rGUOrderTriggerSettings = StoreTestUtility.createTriggerSettings('RGUOrderTrigger');
        insert rGUOrderTriggerSettings;
        TriggerSettings__c jobStatusTriggerSettings = StoreTestUtility.createTriggerSettings('JobStatusTrigger');
        insert jobStatusTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Xfinity Sales Rep'];
        RecordType recordType = [SELECT Id FROM RecordType WHERE Name = :'Store'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        insert testUser;

        Account testParentAccount = StoreTestUtility.createAccount(testUser.Id);
        testParentAccount.Name = 'Test Affiliate Store';
        insert testParentAccount;

        Account testParentAccount2 = StoreTestUtility.createAccount(testUser.Id);
        testParentAccount2.Name = 'Test Affiliate Store2';
        insert testParentAccount2;

        Account queriredTestParentAccount = [SELECT Id FROM Account WHERE Id = :testParentAccount.Id];
        Account queriredTestParentAccount2 = [SELECT Id FROM Account WHERE Id = :testParentAccount2.Id];
        
        Account parentaccnt = new Account();
          parentaccnt .Name = 'test';
          parentaccnt .Phone = '1234567890';
          parentaccnt .RGU_Orders_This_Fiscal_Month__c =0;
          parentaccnt .RGU_Activations_This_Fiscal_Month__c = 0;
          //parentaccnt .RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId(); 
          parentaccnt .Store_Type__c = 'Dealer';
          parentaccnt .Store_Location__Latitude__s = 12;
          parentaccnt .Store_Location__Longitude__s= 12;
          insert parentaccnt ;
          
          Parent_Account__c settng = new Parent_Account__c(Name = 'TestAccnt', Parent_Store_Id__c = parentaccnt.Id);
          insert settng;
        
        
        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        testAccount.AccountNumber = '123456';
        testAccount.RecordTypeId = recordType.Id;
        testAccount.ParentId = queriredTestParentAccount.Id;
        testAccount.RGU_Orders_This_Fiscal_Month__c = 0;
        testAccount.RGU_Activations_This_Fiscal_Month__c = 0;
        testAccount.Parent_Account_Dropdown__c = 'TestAccnt';
        insert testAccount;

        Account testAccount2 = StoreTestUtility.createAccount(testUser.Id);
        testAccount2.AccountNumber ='0123456';
        testAccount2.RecordTypeId = recordType.Id;
        testAccount2.ParentId = queriredTestParentAccount2.Id;
        testAccount2.RGU_Orders_This_Fiscal_Month__c = 0;
        testAccount2.RGU_Activations_This_Fiscal_Month__c = 0;
        testAccount2.Parent_Account_Dropdown__c = 'TestAccnt';
        insert testAccount2;

        RGU_Order__c testRGUOrder = new RGU_Order__c();
        testRGUOrder.Store_ID__c = '123456';
        testRGUOrder.Affiliate__c = 'Test Affiliate Store';
        testRGUOrder.Activity_Status__c  = 'Activated';
        testRGUOrder.Order_Date__c = Date.today();
        testRGUOrder.Activation_Date__c = Date.today();

        RGU_Order__c testRGUOrder2 = new RGU_Order__c();
        testRGUOrder2.Store_ID__c = '0123456';
        testRGUOrder2.Affiliate__c = 'Test Affiliate Store2';
        testRGUOrder2.Activity_Status__c  = 'Activated';
        testRGUOrder2.Order_Date__c = Date.today();
        testRGUOrder2.Activation_Date__c = Date.today();

        RGU_Order__c testRGUOrder3 = new RGU_Order__c();
        testRGUOrder3.Store_ID__c = '123456';
        testRGUOrder3.Affiliate__c = 'Test Affiliate Store';
        testRGUOrder3.Activity_Status__c  = 'Activated';
        testRGUOrder3.Order_Date__c = Date.today().addDays(32);
        testRGUOrder3.Activation_Date__c = Date.today().addDays(32);

        RGU_Order__c testRGUOrder4 = new RGU_Order__c();
        testRGUOrder4.Store_ID__c = '123456';
        testRGUOrder4.Affiliate__c = 'Test Affiliate Store';
        testRGUOrder4.Activity_Status__c  = 'Pending';
        testRGUOrder4.Order_Date__c = Date.today();
        testRGUOrder4.Activation_Date__c = Date.today();

        List<RGU_Order__c> rGUOrders = new List<RGU_Order__c>();
        rGUOrders.add(testRGUOrder);
        rGUOrders.add(testRGUOrder2);
        rGUOrders.add(testRGUOrder3);
        rGUOrders.add(testRGUOrder4);
        insert rGUOrders;

        Test.startTest();
            RGUOrderBatch orderBatch = new RGUOrderBatch();
            Database.executeBatch(orderBatch);
        Test.stopTest();

        Account queriredAccount1 = [SELECT RGU_Orders_This_Fiscal_Month__c, RGU_Activations_This_Fiscal_Month__c FROM Account WHERE Id =: testAccount.Id];

        //System.assertEquals(2, queriredAccount1.RGU_Orders_This_Fiscal_Month__c, 'Account should have 2 RGU Orders');
        //System.assertEquals(1, queriredAccount1.RGU_Activations_This_Fiscal_Month__c, 'Account should have 1 RGU Activation');
    }
}