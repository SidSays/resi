@isTest
private class StoreQueryUtilityTest {
    
    static testMethod void queryStore(){
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Account testAccount2;

        Test.startTest();
            testAccount2 = StoreQueryUtility.queryStore(testAccount.Id);
        Test.stopTest();

        System.assertEquals(testAccount.Id, testAccount2.Id, 'Accounts should have the same ID');   
    }

    static testMethod void queryUserRole(){
        UserRole testRole = [Select Id, DeveloperName, Name From UserRole WHERE Name='Indirect Manager'];
        UserRole testRole2; 

        Test.startTest();
            testRole2 = StoreQueryUtility.queryUserRole(testRole.Id);
        Test.stopTest();

        System.assertEquals(testRole.Id, testRole2.Id, 'UserRoles should have the same ID');
    }

    static testMethod void queryActivityCategories(){
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Indirect Manager'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;
 
        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_type__c, role.Name);
        insert testActivityCategory;

        List<Store_Visit_Activity_Category__c> activityCategories;
        Test.startTest();
            activityCategories = StoreQueryUtility.queryActivityCategories(testAccount.Store_Type__c, role.Name);
        Test.stopTest();

        System.assertEquals(1, activityCategories.size(), 'Query should return list with one object');

    }
    
    static testMethod void queryStoreActivities(){
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        testStoreVisit.End_Date_Time__c = null;
        insert testStoreVisit;
 
        Store_Activity__c testStoreActivity = StoreTestUtility.createStoreActivity(testStoreVisit.Id);
        insert testStoreActivity;
        Store_Activity__c testStoreActivity2 = StoreTestUtility.createStoreActivity(testStoreVisit.Id);
        insert testStoreActivity2;
        Store_Activity__c testStoreActivity3 = StoreTestUtility.createStoreActivity(testStoreVisit.Id);
        insert testStoreActivity3;
        List<Store_Activity__c> testStoreActivities;

        Test.startTest();
            testStoreActivities = StoreQueryUtility.queryStoreActivities(testStoreVisit.Id);
        Test.stopTest();

        System.assertEquals(3, testStoreActivities.size(), 'Query should return list with 3 objects');
    }
    
    static testMethod void queryRecordTypes(){
        List<RecordType> testRecordTypes;

        Test.startTest();
            testRecordTypes = StoreQueryUtility.queryRecordTypes('Store_Activity__c');
        Test.stopTest();

        System.assertEquals(true, testRecordTypes.size() > 0, 'Query should return list with x number of objects');
    }

    static testMethod void queryEmailTemplate(){
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
        insert eventTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        User inactiveTestUser = StoreTestUtility.createUser('inactivestoretestuser@comcast.mi.com', p.Id, 'SNU2');
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;
        
        system.runas(testUser){
        Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
        insert storeSettings;
        
        
        Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
        //EmailTemplate testTemplate = StoreTestUtility.createEmailTemplate(storeSettings, folder.Id);
        EmailTemplate testTemplate = new EmailTemplate (developerName = 'test', FolderId = folder.Id, TemplateType= 'Text', Name = 'test');
        insert testTemplate;
        
        EmailTemplate queriedEmailTemplate;

        Test.startTest();
            //queriedEmailTemplate = StoreQueryUtility.queryEmailTemplate(testTemplate.DeveloperName);
            queriedEmailTemplate = StoreQueryUtility.queryEmailTemplate(testTemplate.DeveloperName);
        Test.stopTest();
    
        System.assertEquals(testTemplate.Id, queriedEmailTemplate.Id, 'Query should return EmailTemplate with the same Id');
    }
    }
    static testMethod void queryStoreVisit(){
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        testStoreVisit.End_Date_Time__c = null;
        insert testStoreVisit;

        Store_Visit__c queriedStoreVisit;

        Test.startTest();
            queriedStoreVisit = StoreQueryUtility.queryStoreVisit(testStoreVisit.Id);
        Test.stopTest();

        System.assertEquals(testStoreVisit.Id, queriedStoreVisit.Id, 'Query should return a StoreVisit with the same Id');
    }

    static testMethod void queryVisitTasks(){

        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c taskTriggerSettings = StoreTestUtility.createTriggerSettings('TaskTrigger');
        insert taskTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        testStoreVisit.End_Date_Time__c = null;
        insert testStoreVisit;

        Task testTask = StoreTestUtility.createTask(testUser.Id, testStoreVisit.Id);
        insert testTask;

        List<Task> tasks;

        Test.startTest();
            tasks = StoreQueryUtility.queryVisitTasks(testStoreVisit.Id);
        Test.stopTest();

        //System.assertEquals(1, tasks.size(), 'Query should return list with 1 object');
    }

    static testMethod void queryRecordType(){
        List<RecordType> testRecordTypes = new List<RecordType>();

        Test.startTest();
            RecordType testRecordType = StoreQueryUtility.queryRecordType('Task');
            testRecordTypes.add(testRecordType);
        Test.stopTest();

        System.assertEquals(1, testRecordTypes.size(), 'Query should return list with 1 object');
    }

    static testMethod void queryUser(){
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        insert testUser;

        List<User> testUsers = new List<User>();

        Test.startTest();
            User queriedUser = StoreQueryUtility.queryUser(testUser.Id);
            testUsers.add(queriedUser);
        Test.stopTest();

        System.assertEquals(1, testUsers.size(), 'Query should return list with 1 object');
    }
    
}