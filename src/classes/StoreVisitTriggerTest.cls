/**
*   Tests for store visit trigger
*
*   @author Sahil Grover    <sgrover@acumensolutions.com>
*/
@isTest
private class StoreVisitTriggerTest {
    
    @isTest static void testPopulateStore() {
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;
        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;
        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('testUser@test.comcast.com', p.Id, 'cTestUser');
        insert testUser;
        
        String str = 'Store';
        Account testStore = new Account();
        testStore.Name = 'Test Account';
        testStore.OwnerId = testUser.id;
        testStore.Store_Location__Latitude__s = 37.776114;
        testStore.Store_Location__Longitude__s = -122.417047;
        testStore.Store_Type__c = 'Best Buy';
        testStore.Parent_Account_Dropdown__c = 'Best Buy';
        testStore.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId();
        insert testStore;
        
       // Account testStore = StoreTestUtility.createAccount(testUser.Id);
        //insert testStore;
        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testStore.Id, testUser.Id);
        insert testStoreVisit;
        Store_Activity__c testStoreActivity = StoreTestUtility.createStoreActivity(testStoreVisit.Id);

        Test.startTest();
            insert testStoreActivity;
        Test.stopTest();

        Store_Activity__c confirmStoreActivity = [SELECT Store__c FROM Store_Activity__c WHERE Id = :testStoreActivity.Id];
        System.assertEquals(testStore.Id, confirmStoreActivity.Store__c, 'The Store lookup was not set properly on the Store Activity record.');
    }

    @isTest static void testRemoveEventOnInsert() {
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;
        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
        insert eventTriggerSettings;
        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;
        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('testUser@test.comcast.com', p.Id, 'cTestUser');
        insert testUser;
        Account testStore = StoreTestUtility.createAccount(testUser.Id);
        insert testStore;
        system.runAs(new User(id = UserInfo.getUserId())) {
        Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
        insert storeSettings;
        
            Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
            //EmailTemplate alertTemplate = StoreTestUtility.createEmailTemplate(storeSettings, folder.Id);
            EmailTemplate testEmailTemplate = new EmailTemplate();
            testEmailTemplate.DeveloperName = storeSettings.Scheduled_Visit_Alert_Template__c;
            testEmailTemplate.Name ='TestEmailTemplate';
            testEmailTemplate.FolderId = folder.Id;
            testEmailTemplate.TemplateType ='text';
            testEmailTemplate.Body = 'Test Email Body';
            testEmailTemplate.HtmlValue = 'Test HTML Email Body';
            insert testEmailTemplate;
        }
        Event event = StoreTestUtility.createEvent(testUser.Id, testStore.Id, Datetime.now());
        insert event;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testStore.Id, testUser.Id, DateTime.now());
        testStoreVisit.End_Date_Time__c = null;
        
        Test.startTest();
            System.runAs(testUser){
                insert testStoreVisit;
            }
        Test.stopTest();
        

        List<Event> confirmEvent = [SELECT Id, Is_Visit_Complete__c FROM EVENT WHERE AccountId = :testStore.Id];

        //System.assert(confirmEvent.Is_Visit_Complete__c, 'Event status should be complete');
    }
}