/**
 * Test class for StoreVisitEvent 
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 10/9/14
 */

@isTest
private class StoreVisitEventTest {
  
  static testMethod void createStoreVisitEventTest(){
        SetupTestData.createCustomSettingRecords();
    TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
        insert eventTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Xfinity Sales Rep'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_Type__c, role.Name);
        insert testActivityCategory;

        /*Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
        insert storeSettings;

        Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
        EmailTemplate alertTemplate = StoreTestUtility.createEmailTemplate(storeSettings, folder.Id);
        insert alertTemplate;*/

        Event testEvent = StoreTestUtility.createEvent(testUser.Id, testAccount.Id, Datetime.now());
        insert testEvent;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-2));
        insert testStoreVisit;
        
        Store_Visit__c testPropectiveStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-2));
        insert testPropectiveStoreVisit;

        List<StoreVisitEvent> visitEvents = new List<StoreVisitEvent>();

        Test.startTest();
            visitEvents.add(new StoreVisitEvent(testEvent));
            visitEvents.add(new StoreVisitEvent(testStoreVisit));
            visitEvents.add(new StoreVisitEvent(testPropectiveStoreVisit));
            visitEvents.sort();
        Test.stopTest();

        System.assertEquals(3, visitEvents.size(), 'VisitEvent list should contain 2 objects');
        System.assertEquals(testStoreVisit.Start_Date_Time__c, visitEvents.get(0).StartDateTime, 'The first object in the list should be the visit');
  }
  static testMethod void createProspectStoreVisitEventTest(){
    SetupTestData.createCustomSettingRecords();
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
        insert eventTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Xfinity Sales Rep'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_Type__c, role.Name);
        insert testActivityCategory;

        /*Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
        insert storeSettings;

        Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
        EmailTemplate alertTemplate = StoreTestUtility.createEmailTemplate(storeSettings, folder.Id);
        insert alertTemplate;*/

        Event testEvent = StoreTestUtility.createEvent(testUser.Id, testAccount.Id, Datetime.now());
        insert testEvent;
        
        Store_Visit__c testStoreVisit = new Store_Visit__c(Store__c = null);
      
        Test.StartTest();
        StoreVisitEvent testStoreVisitEvent = new StoreVisitEvent(testStoreVisit);
        Test.stopTest();
    }
}