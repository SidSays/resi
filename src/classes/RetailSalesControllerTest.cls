/**
 * Test class for the RetailSalesController
 *
 * @Author Ryan Sayles
 * @Date 9/28/14 
 */

@isTest
private class RetailSalesControllerTest {
    
    static testMethod void queryStores() {

        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.FederationIdentifier = 'FedId1';
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        System.runAs(testUser){
            Test.startTest();
                RetailSalesController rSController = new RetailSalesController();
                rSController.dummyFunc(); //used just for coverage, function only used for rerender on VF page
            Test.stopTest();
            System.assertEquals(1, rSController.getUserStores().size(), 'Query should return 1 store');
        }

    }

    static testMethod void queryStoresEmpty() {
        SetupTestData.createCustomSettingRecords();
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.FederationIdentifier = 'FedId35235';
        User inactiveTestUser = StoreTestUtility.createUser('inactivestoretestuser@comcast.mi.com', p.Id, 'SNU2');
        inactiveTestUser.FederationIdentifier = 'FedId25467';
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        System.runAs(inactiveTestUser) {
            Test.startTest();
                RetailSalesController rSController = new RetailSalesController();
            Test.stopTest();
            System.assertEquals(0, rSController.getUserStores().size(), 'Query should return no stores');
        }

    }

    static testMethod void queryTodayVisitEvents() {
        SetupTestData.createCustomSettingRecords();
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
        insert eventTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        User inactiveTestUser = StoreTestUtility.createUser('inactivestoretestuser@comcast.mi.com', p.Id, 'SNU2');
        testUser.FederationIdentifier = 'FedId1';
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;
        Account testAccount2 = StoreTestUtility.createAccount(testUser.Id);
        testAccount2.Name = 'Test Store 2';
        insert testAccount2;

        /*Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
        insert storeSettings;

        Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
        EmailTemplate alertTemplate = StoreTestUtility.createEmailTemplate(SetupTestData.storeSettings, folder.Id);
        insert alertTemplate;*/

        Event testEvent1 = StoreTestUtility.createEvent(testUser.Id, testAccount.Id, Datetime.now());
        insert testEvent1;
        Event testEvent2 = StoreTestUtility.createEvent(testUser.Id, testAccount2.Id, Datetime.now()-1);
        insert testEvent2;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        insert testStoreVisit;
        Store_Visit__c testStoreVisit2 = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now()-1);
        insert testStoreVisit2;

        System.runAs(testUser) {
            Test.startTest();
                RetailSalesController rSController = new RetailSalesController();
                rSController.SelectedDateFilter = 'Today';
            Test.stopTest();
            System.assertEquals(2, rSController.SelectedVisitEvents.size(), 'SelectedVisitEvents size should be 2');
        }
        
    }

    static testMethod void queryYesterdayVisitEvents() {
        SetupTestData.createCustomSettingRecords();
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
        insert eventTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        User inactiveTestUser = StoreTestUtility.createUser('inactivestoretestuser@comcast.mi.com', p.Id, 'SNU2');
        testUser.FederationIdentifier = 'FedId1';
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;
        Account testAccount2 = StoreTestUtility.createAccount(testUser.Id);
        testAccount2.Name = 'Test Store 2';
        insert testAccount2;

        /*Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
        insert storeSettings;

        Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
        EmailTemplate alertTemplate = StoreTestUtility.createEmailTemplate(SetupTestData.storeSettings, folder.Id);
        insert alertTemplate;*/

        Event testEvent1 = StoreTestUtility.createEvent(testUser.Id, testAccount.Id, Datetime.now());
        insert testEvent1;
        Event testEvent2 = StoreTestUtility.createEvent(testUser.Id, testAccount2.Id, Datetime.now()-1);
        insert testEvent2;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        insert testStoreVisit;
        Store_Visit__c testStoreVisit2 = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now()-1);
        insert testStoreVisit2;

        System.runAs(testUser){
            Test.startTest();
                RetailSalesController rSController = new RetailSalesController();
                rSController.SelectedDateFilter = 'Yesterday';
            Test.stopTest();
            System.assertEquals(2, rSController.SelectedVisitEvents.size(), 'SelectedVisitEvents size should be 2');
        }
        
    }

    static testMethod void queryWeekVisitEvents() {
        SetupTestData.createCustomSettingRecords();
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
        insert eventTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        User inactiveTestUser = StoreTestUtility.createUser('inactivestoretestuser@comcast.mi.com', p.Id, 'SNU2');
        testUser.FederationIdentifier = 'FedId1';
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;
        Account testAccount2 = StoreTestUtility.createAccount(testUser.Id);
        testAccount2.Name = 'Test Store 2';
        insert testAccount2;

        /*Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
        insert storeSettings;

        Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
        EmailTemplate alertTemplate = StoreTestUtility.createEmailTemplate(SetupTestData.storeSettings, folder.Id);
        insert alertTemplate;*/

        Event testEvent1 = StoreTestUtility.createEvent(testUser.Id, testAccount.Id, Datetime.now());
        insert testEvent1;
        Event testEvent2 = StoreTestUtility.createEvent(testUser.Id, testAccount.Id, Datetime.now()-7);
        insert testEvent2;
        Event testEvent3 = StoreTestUtility.createEvent(testUser.Id, testAccount2.Id, Datetime.now()+7);
        insert testEvent3;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        insert testStoreVisit;
        Store_Visit__c testStoreVisit2 = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now()-7);
        insert testStoreVisit2;
        //Store_Visit__c testStoreVisit3 = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now()+7);
        //insert testStoreVisit3;

        System.runAs(testUser) {
            Test.startTest();
                RetailSalesController rSController = new RetailSalesController();
                rSController.SelectedDateFilter = 'Week';
            Test.stopTest();
            System.assertEquals(2, rSController.SelectedVisitEvents.size(), 'SelectedVisitEvents size should be 2');
        }
        
    }

}