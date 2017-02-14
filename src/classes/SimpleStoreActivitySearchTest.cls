/**
 * Test class for SimpleStoreActivitySearch
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 10/8/14
 */

@isTest
private class SimpleStoreActivitySearchTest {
    
    static testMethod void storeActivitySearch(){

        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Xfinity Sales Rep'];
        UserRole role2=[Select Id, DeveloperName, Name From UserRole WHERE Name='Indirect Manager'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        testUser.FederationIdentifier = 'FedId1';
        insert testUser;

        User testUser2 = StoreTestUtility.createUser('teststore2user@comcast.mi.com', p.Id, 'SNU2');
        testUser2.UserRole = role2;
        testUser2.FederationIdentifier = 'FedId11';
        insert testUser2;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Contact testContact = StoreTestUtility.createContact(testAccount.Id);
        insert testContact;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-2));
        testStoreVisit.End_Date_Time__c = null;
        insert testStoreVisit;

        Store_Visit__c testStoreVisit2 = StoreTestUtility.createStoreVisit(testAccount.Id, testUser2.Id, Datetime.now().addHours(-2));
        testStoreVisit2.End_Date_Time__c = null;
        insert testStoreVisit2;

        Store_Activity__c testStoreActivity1 = StoreTestUtility.createStoreActivity(testStoreVisit.Id);    
        testStoreActivity1.Who_did_you_meet_with__c = testContact.Id;
        testStoreActivity1.What_is_the_store_s_focus_this_month__c = 'Accessories';
        testStoreActivity1.Engagement_level_of_manager__c = '3';
        testStoreActivity1.What_did_you_review_with_the_manager__c = 'Commissions, Incentives';
        insert testStoreActivity1;

        Store_Activity__c testStoreActivity2 = StoreTestUtility.createStoreActivity(testStoreVisit2.Id);    
        testStoreActivity2.Who_did_you_meet_with__c = testContact.Id;
        testStoreActivity2.What_is_the_store_s_focus_this_month__c = 'Accessories';
        testStoreActivity2.Engagement_level_of_manager__c = '3';
        testStoreActivity2.What_did_you_review_with_the_manager__c = 'Commissions, Incentives';
        insert testStoreActivity2;

        Set<String> visitIds = new Set<String>();
        visitIds.add(testStoreVisit.Id);
        visitIds.add(testStoreVisit2.Id);

        Test.startTest();
            SimpleStoreActivitySearch activitySearch = new SimpleStoreActivitySearch(visitIds);
            List<Store_Activity__c> storeActivities = activitySearch.queryStoreActivities();
        Test.stopTest();

        System.assertEquals(true, storeActivities.size() > 0, 'Query should return a list of store activities');

    }

}