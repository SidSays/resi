/**
 * Test class for StoreActivityTrigger
 *
 * @author Ryan Sayles <rsayles@acumensolutions>
 * @date 10/9/14
 */

@isTest
private class StoreActivityTriggerTest {
    
    static testMethod void populateActivityStore(){
       
        User currentUser = [Select id from User Where Id =: UserInfo.getUserId()];
        
                       
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;
        
        Store_Activity__c testStoreActivity ;
        Account testAccount;
        Store_Visit__c storeVisit;
        User testUser;
        system.runAs(currentUser){
        
    
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
            insert testUser;
    
            testAccount = StoreTestUtility.createAccount(testUser.Id);
            insert testAccount;
    
            storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
            storeVisit.End_Date_Time__c = null;
            insert storeVisit;
    
            testStoreActivity = StoreTestUtility.createStoreActivity(storeVisit.Id);
            
         }
        
        Test.startTest();
            insert testStoreActivity;
        Test.stopTest();

        Store_Activity__c queriedStoreActivity = [SELECT Id, Store__c FROM Store_Activity__c WHERE Id = :testStoreActivity.Id];

        System.assertEquals(testAccount.Id, queriedStoreActivity.Store__c, 'Store Ids should be the same');
    }
    
}