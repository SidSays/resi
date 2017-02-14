/**
 * Test class for StoreVisitUtility
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 9/22/14
 */

@isTest
private class StoreVisitValidatorTest {

    static testMethod void userIsInStoreAtCheckInTest(){
        //SetupTestData.createCustomSettingRecords();
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

        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        insert storeVisit;

        Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;

        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        Store_Activity__c sA2 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        Store_Activity__c sA3 = StoreTestUtility.createStoreActivity(storeVisit.Id);

        List<Store_Activity__c> sAList = new List<Store_Activity__c>();
        sAList.add(sA1);
        sAList.add(sA2);
        sAList.add(sA3);
        Double userLat = 37.774367;
        Double userLong = -122.414755;

        Geolocation location = new Geolocation(userLat, userLong);
        Boolean isValid; 

        Test.startTest();
            //this tests if the user is within 2000 ft of the store
            StoreVisitValidator validator = new StoreVisitValidator(testAccount, storeVisit, storeSettings);
            StoreVisitValidator.ValidationResult result = validator.validateCheckIn(location);
            isValid = result.IsValid;
            ProspectiveStoreVisitValidator ProsValidator = new ProspectiveStoreVisitValidator(storeVisit,storeSettings);
            ProsValidator.validateCheckIn(location);
        Test.stopTest();
        System.assertEquals(true, isValid, 'User is in store, result should be valid');
    }

    static testMethod void userIsOutOfStoreAtCheckInTest(){
        SetupTestData.createCustomSettingRecords();
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

        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        insert storeVisit;

        Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;

        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        Store_Activity__c sA2 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        Store_Activity__c sA3 = StoreTestUtility.createStoreActivity(storeVisit.Id);

        List<Store_Activity__c> sAList = new List<Store_Activity__c>();
        sAList.add(sA1);
        sAList.add(sA2);
        sAList.add(sA3);
        Double userLat = 37.772218;
        Double userLong = -122.412078;

        Geolocation location = new Geolocation(userLat, userLong);
        Boolean isValid; 

        Test.startTest();
            //this tests if the user is within 2000 ft of the store
            StoreVisitValidator validator = new StoreVisitValidator(testAccount, storeVisit, storeSettings);
            StoreVisitValidator.ValidationResult result = validator.validateCheckIn(location);
            isValid = result.IsValid;
            ProspectiveStoreVisitValidator ProsValidator = new ProspectiveStoreVisitValidator(storeVisit,storeSettings);
            ProsValidator.validateCheckIn(location);
        Test.stopTest();
     //   System.assertEquals(false, isValid, 'User is not in store, result should be invalid');
    }

    static testMethod void userIsInStoreAtCheckOutTest(){
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

        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-2));
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

        Double userLat = 37.774367;
        Double userLong = -122.414755;

        Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;
        storeSettings.Min_Visit_Time_Minutes__c = 60;

        RequiredStoreActivity requiredActivity = new RequiredStoreActivity(testActivityCategory, storeActivities);

        List<RequiredStoreActivity> requiredStoreActivities = new List<RequiredStoreActivity>();
        requiredStoreActivities.add(requiredActivity);

        Geolocation location = new Geolocation(userLat, userLong);
        Boolean isValid; 

        Test.startTest();
            //this tests if the user is within 2000 ft of the store
            StoreVisitValidator validator = new StoreVisitValidator(testAccount, storeVisit, storeSettings);
            StoreVisitValidator.ValidationResult result = validator.validateCheckOut(location, requiredStoreActivities);
            isValid = result.IsValid;
             ProspectiveStoreVisitValidator ProsValidator = new ProspectiveStoreVisitValidator(storeVisit,storeSettings);
            ProsValidator.validateCheckOut(location,requiredStoreActivities);
        Test.stopTest();
        System.assertEquals(true, isValid, 'User is in store and activities are complete, result should be valid');
    }

    static testMethod void userIsOutOfStoreAtCheckOutTest(){
        SetupTestData.createCustomSettingRecords();
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
        Store_Visit_Activity_Category__c testActivityCategory3 = StoreTestUtility.createActivityCategory(testAccount.Store_type__c, role.Name);
        insert testActivityCategory3;

        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-2));
        insert storeVisit;

        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        Store_Activity__c sA2 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        Store_Activity__c sA3 = StoreTestUtility.createStoreActivity(storeVisit.Id);

        List<Store_Activity__c> storeActivities = new List<Store_Activity__c>();
        storeActivities.add(sA1);
        storeActivities.add(sA2);
        storeActivities.add(sA3);
        Double userLat = 37.772218;
        Double userLong = -122.412078;

        Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;
        

        RequiredStoreActivity requiredActivity = new RequiredStoreActivity(testActivityCategory, storeActivities);
        RequiredStoreActivity requiredActivity2 = new RequiredStoreActivity(testActivityCategory2, storeActivities);
        RequiredStoreActivity requiredActivity3 = new RequiredStoreActivity(testActivityCategory3, storeActivities);

        List<RequiredStoreActivity> requiredStoreActivities = new List<RequiredStoreActivity>();
        requiredStoreActivities.add(requiredActivity);
        requiredStoreActivities.add(requiredActivity2);
        requiredStoreActivities.add(requiredActivity3);

        Geolocation location = new Geolocation(userLat, userLong);
        Boolean isValid; 

        Test.startTest();
            //this tests if the user is within 2000 ft of the store
            StoreVisitValidator validator = new StoreVisitValidator(testAccount, storeVisit, storeSettings);
            StoreVisitValidator.ValidationResult result = validator.validateCheckOut(location, requiredStoreActivities);
            isValid = result.IsValid;
             ProspectiveStoreVisitValidator ProsValidator = new ProspectiveStoreVisitValidator(storeVisit,storeSettings);
            ProsValidator.validateCheckOut(location,requiredStoreActivities);
            ProsValidator.isValidationRequired();
        Test.stopTest();
      //  System.assertEquals(false, isValid, 'User is not in store, result should be invalid');
    }
    
}