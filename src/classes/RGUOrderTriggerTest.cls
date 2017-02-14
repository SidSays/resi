/**
 * Test class for StoreVisitEvent 
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 11/25/14
 */

@isTest
private class RGUOrderTriggerTest {

    static testMethod void associateAccountTest() {
        SetupTestData.createCustomSettingRecords();

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
          
          TriggerSettings__c trgSettng = new TriggerSettings__c(Name = 'RGUOrderTrigger', isActive__c = true);
          insert trgSettng;
        
        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        testAccount.AccountNumber = '123456';
        testAccount.RecordTypeId = recordType.Id;
        testAccount.ParentId = queriredTestParentAccount.Id;
        testAccount.Parent_Account_Dropdown__c = 'TestAccnt';
        insert testAccount;

        Account testAccount2 = StoreTestUtility.createAccount(testUser.Id);
        testAccount2.AccountNumber ='0123456';
        testAccount2.RecordTypeId = recordType.Id;
        testAccount2.ParentId = queriredTestParentAccount2.Id;
        testAccount2.Parent_Account_Dropdown__c = 'TestAccnt';
        insert testAccount2;

        RGU_Order__c testRGUOrder = new RGU_Order__c();
        testRGUOrder.Store_ID__c = '123456';
        testRGUOrder.Affiliate__c = 'Test Affiliate Store';

        RGU_Order__c testRGUOrder2 = new RGU_Order__c();
        testRGUOrder2.Store_ID__c = '0123456';
        testRGUOrder2.Affiliate__c = 'Test Affiliate Store2';

        List<RGU_Order__c> rGUOrders = new List<RGU_Order__c>();
        rGUOrders.add(testRGUOrder);
        rGUOrders.add(testRGUOrder2);

        Test.startTest();
            insert rGUOrders;
        Test.stopTest();

        RGU_Order__c checkOrder = [SELECT Id, Store__c FROM RGU_Order__c WHERE Id = :testRGUOrder.Id];
        RGU_Order__c checkOrder2 = [SELECT Id, Store__c FROM RGU_Order__c WHERE Id = :testRGUOrder2.Id];
        //System.assertEquals(checkOrder.Store__c, testAccount.Id, 'Account Id should match Store__c on Order');
        //System.assertNotEquals(checkOrder2.Store__c, testAccount.Id, 'Account Id should not match Store__c on Order');
        //System.assertEquals(checkOrder2.Store__c, testAccount2.Id, 'Account Id should match Store__c on Order');
        //System.assertNotEquals(checkOrder.Store__c, testAccount2.Id, 'Account Id should not match Store__c on Order');
    }
}