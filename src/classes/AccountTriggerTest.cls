/**
 * Test class for Account Trigger
 *
 * @Author Ryan Sayles <rsayles@acumensolutions.com>
 * @Date 9/29/14
 */


@isTest
private class AccountTriggerTest {
    
    static testMethod void deleteRelatedStoreVisits() {

        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c accountTriggerSettings = StoreTestUtility.createTriggerSettings('AccountTrigger');
        insert accountTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        User inactiveTestUser = StoreTestUtility.createUser('inactivestoretestuser@comcast.mi.com', p.Id, 'SNU2');
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        insert storeVisit;

        List<Store_Visit__c> visitList = [
            SELECT Id
            FROM Store_Visit__c
            WHERE Store__c IN :new List<Account> {testAccount}
            ];


        Test.startTest();
        testAccount.Total_Monthly_Rate__c=0;
        update testAccount;
        delete testAccount;
        Test.stopTest();

        List<Store_Visit__c> visits = [SELECT Id, Store__c FROM Store_Visit__c];



        //System.assertEquals(0, visits.size(), 'There should be no store visits since the account was deleted');
    }

}