/**
 * Test class for RequiredStoreActivity
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 9/30/14
 */

@isTest
private class RequiredStoreActivityTest {
    
    static testMethod void requiredActivitiesComplete(){
        SetupTestData.createCustomSettingRecords();

        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

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

        Contact testContact = StoreTestUtility.createContact(testAccount.Id);
        insert testContact;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_Type__c, role.Name);
        insert testActivityCategory;

        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        storeVisit.End_Date_Time__c = null;
        insert storeVisit;

        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);    
        sA1.Who_did_you_meet_with__c = testContact.Id;
        sA1.What_is_the_store_s_focus_this_month__c = 'Accessories';
        sA1.Engagement_level_of_manager__c = '3';
        sA1.What_did_you_review_with_the_manager__c = 'Commissions, Incentives';
        insert sA1;

        Store_Activity__c confirmActivity = [SELECT Id, Is_Activity_Complete__c, Who_did_you_meet_with__c, What_did_you_review_with_the_manager__c, Engagement_level_of_manager__c,
                                                    What_is_the_store_s_focus_this_month__c
                                             FROM Store_Activity__c
                                             WHERE Id = :sA1.Id];

        List<Store_Activity__c> storeActivities = new List<Store_Activity__c>();
        storeActivities.add(confirmActivity);
        

        Boolean areActivitiesComplete;

        Test.startTest();
            RequiredStoreActivity requiredActivity = new RequiredStoreActivity(testActivityCategory, storeActivities);
            areActivitiesComplete = requiredActivity.areRequiredActivitiesComplete();   
        Test.stopTest();

        System.assertEquals(true, areActivitiesComplete, 'All activities should be complete');
    }
    
    static testMethod void requiredActivitiesIncomplete(){
        SetupTestData.createCustomSettingRecords();

        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

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

        Contact testContact = StoreTestUtility.createContact(testAccount.Id);
        insert testContact;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_Type__c, role.Name);
        insert testActivityCategory;

        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        storeVisit.End_Date_Time__c = null;
        insert storeVisit;

        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);    
        sA1.Who_did_you_meet_with__c = null;
        sA1.What_is_the_store_s_focus_this_month__c = null;
        sA1.Engagement_level_of_manager__c = null;
        sA1.What_did_you_review_with_the_manager__c = null;
        insert sA1;

        Store_Activity__c confirmActivity = [SELECT Id, Is_Activity_Complete__c, Who_did_you_meet_with__c, What_did_you_review_with_the_manager__c, Engagement_level_of_manager__c,
                                                    What_is_the_store_s_focus_this_month__c
                                             FROM Store_Activity__c
                                             WHERE Id = :sA1.Id];

        List<Store_Activity__c> storeActivities = new List<Store_Activity__c>();
        storeActivities.add(confirmActivity);
        

        Boolean areActivitiesComplete;

        Test.startTest();
            RequiredStoreActivity requiredActivity = new RequiredStoreActivity(testActivityCategory, storeActivities);
            areActivitiesComplete = requiredActivity.areRequiredActivitiesComplete();   
        Test.stopTest();

        System.assertEquals(false, areActivitiesComplete, 'A required field is missing, activity should be incomplete');

    }

    static testMethod void compareEqualActivities(){
        SetupTestData.createCustomSettingRecords();
        Integer result;

        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Indirect Manager'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_type__c, role.Name);
        insert testActivityCategory;
        Store_Visit_Activity_Category__c testActivityCategory2 = StoreTestUtility.createActivityCategory(testAccount.Store_type__c, role.Name);
        insert testActivityCategory2;


        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        insert storeVisit;

        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        //sA1.CreatedDate = DateTime.now();
       // sA1.LastModifiedDate = DateTime.now().addHours(1);
        Store_Activity__c sA2 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        //sA2.CreatedDate = DateTime.now();
        //sA2.LastModifiedDate = DateTime.now();
        Store_Activity__c sA3 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        //sA3.CreatedDate = DateTime.now();
        //sA3.LastModifiedDate = DateTime.now();

        List<Store_Activity__c> storeActivities = new List<Store_Activity__c>();
        storeActivities.add(sA1);
        storeActivities.add(sA2);
        storeActivities.add(sA3);

        RequiredStoreActivity requiredActivity = new RequiredStoreActivity(testActivityCategory2);
        RequiredStoreActivity requiredActivity2 = new RequiredStoreActivity(testActivityCategory, storeActivities);

        Test.startTest();
            result = requiredActivity.compareTo(requiredActivity2);
        Test.stopTest();
        System.assertEquals(0, result, 'Activities are equal, result should be 0');
    }

    static testMethod void compareGreaterActivities(){
        SetupTestData.createCustomSettingRecords();
        Integer result;

        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Indirect Manager'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_type__c, role.Name);
        insert testActivityCategory;
        Store_Visit_Activity_Category__c testActivityCategory2 = StoreTestUtility.createActivityCategory(testAccount.Store_type__c, role.Name);
        testActivityCategory2.Number_Required__c = 0;
        insert testActivityCategory2;


        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        insert storeVisit;

        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        //sA1.CreatedDate = DateTime.now();
        //sA1.LastModifiedDate = DateTime.now().addHours(1);
        Store_Activity__c sA2 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        //sA2.CreatedDate = DateTime.now();
        //sA2.LastModifiedDate = DateTime.now();
        Store_Activity__c sA3 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        //sA3.CreatedDate = DateTime.now();
        //sA3.LastModifiedDate = DateTime.now();

        List<Store_Activity__c> storeActivities = new List<Store_Activity__c>();
        storeActivities.add(sA1);
        storeActivities.add(sA2);
        storeActivities.add(sA3);

        RequiredStoreActivity requiredActivity = new RequiredStoreActivity(testActivityCategory2);
        RequiredStoreActivity requiredActivity2 = new RequiredStoreActivity(testActivityCategory, storeActivities);

        Test.startTest();
            result = requiredActivity.compareTo(requiredActivity2);
        Test.stopTest();
        System.assertEquals(1, result, 'Activity one is greater, result should be 1');
    }

    static testMethod void compareLessActivities(){
        SetupTestData.createCustomSettingRecords();
        Integer result;

        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Indirect Manager'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_type__c, role.Name);
        testActivityCategory.Number_Required__c = 0;
        insert testActivityCategory;
        Store_Visit_Activity_Category__c testActivityCategory2 = StoreTestUtility.createActivityCategory(testAccount.Store_type__c, role.Name);
        insert testActivityCategory2;


        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        insert storeVisit; 

        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        //sA1.CreatedDate = DateTime.now();
        //sA1.LastModifiedDate = DateTime.now().addHours(1);
        Store_Activity__c sA2 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        //sA2.CreatedDate = DateTime.now();
        //sA2.LastModifiedDate = DateTime.now();
        Store_Activity__c sA3 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        //sA3.CreatedDate = DateTime.now();
        //sA3.LastModifiedDate = DateTime.now();

        List<Store_Activity__c> storeActivities = new List<Store_Activity__c>();
        storeActivities.add(sA1);
        storeActivities.add(sA2);
        storeActivities.add(sA3);

        RequiredStoreActivity requiredActivity = new RequiredStoreActivity(testActivityCategory2);
        RequiredStoreActivity requiredActivity2 = new RequiredStoreActivity(testActivityCategory, storeActivities);

        Test.startTest();
            result = requiredActivity.compareTo(requiredActivity2);
        Test.stopTest();
        System.assertEquals(-1, result, 'Activity one is less than activity two, result should be -1');
    }
}