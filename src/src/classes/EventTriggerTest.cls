@isTest
private class EventTriggerTest {
    
    @isTest static void testVisitAlert() {
        SetupTestData.createCustomSettingRecords();
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
        insert eventTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Contact testContact1 = StoreTestUtility.createContact(testAccount.Id);
        testContact1.Active__c = true;
        testContact1.Priority__c = 'Primary';
        testContact1.Email = 'testcontact@test.com';
        insert testContact1;
        //Contact testContact2 = StoreTestUtility.createContact(testAccount.Id);
        //testContact2.Active__c = true;
        //testContact2.Priority__c = 'Primary';
        //insert testContact2;
        
        /*Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
        insert storeSettings;

        Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
        EmailTemplate alertTemplate = StoreTestUtility.createEmailTemplate(SetupTestData.storeSettings, folder.Id);
        insert alertTemplate;*/

        Event testEvent = StoreTestUtility.createEvent(testUser.Id, testAccount.Id, Datetime.now().addHours(2));
        testEvent.Email_Store_Contact__c = true;

        Test.startTest();
            insert testEvent;
        Test.stopTest();

        List<Event> queriedEvent = [SELECT OwnerId FROM EVENT WHERE Id = :testEvent.Id];
        //System.assertEquals(testUser.Id, queriedEvent.OwnerId, 'User and Owner Ids should be the same');
    
    }
    
}