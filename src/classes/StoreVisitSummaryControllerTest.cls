/**
 * Test class for StoreVisitSummaryController
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 10/9/14
 */

@isTest
private class StoreVisitSummaryControllerTest {
    
    static testMethod void summaryControllerTest(){
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
        testUser.UserRoleId = role.Id;
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Contact testContact = StoreTestUtility.createContact(testAccount.Id);
        insert testContact;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_Type__c, role.Name);
        insert testActivityCategory;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-2));
        testStoreVisit.End_Date_Time__c = null;
        insert testStoreVisit;

        Store_Activity__c testStoreActivity = StoreTestUtility.createStoreActivity(testStoreVisit.Id);    
        testStoreActivity.Who_did_you_meet_with__c = testContact.Id;
        testStoreActivity.What_is_the_store_s_focus_this_month__c = 'Accessories';
        testStoreActivity.Engagement_level_of_manager__c = '3';
        testStoreActivity.What_did_you_review_with_the_manager__c = 'Commissions, Incentives';
        insert testStoreActivity;

        Store_Activity__c confirmActivity = [SELECT Id, Is_Activity_Complete__c, Who_did_you_meet_with__c, What_did_you_review_with_the_manager__c, Engagement_level_of_manager__c,
                                                    What_is_the_store_s_focus_this_month__c
                                             FROM Store_Activity__c
                                             WHERE Id = :testStoreActivity.Id];

        List<Store_Activity__c> storeActivities = new List<Store_Activity__c>();
        storeActivities.add(confirmActivity);

        Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;
        storeSettings.Min_Visit_Time_Minutes__c = 60;

        RequiredStoreActivity requiredActivity = new RequiredStoreActivity(testActivityCategory, storeActivities);

        List<RequiredStoreActivity> requiredStoreActivities = new List<RequiredStoreActivity>();
        requiredStoreActivities.add(requiredActivity);

        testStoreVisit.End_Date_Time__c = Datetime.now();
        update testStoreVisit;

        User visitOwner = [SELECT Id, UserRoleId FROM User WHERE Id = :testUser.Id];

        ApexPages.StandardController stdCon = new ApexPages.StandardController(testStoreVisit);

        Test.startTest();
            StoreVisitSummaryController summaryController = new StoreVisitSummaryController(stdCon);
        Test.stopTest();

        Integer timeToInt = Integer.valueOf(summaryController.VisitSummary.TimeSpentInStore.remove(':'));

        System.assertEquals(0, summaryController.VisitSummary.NumberOfRemainingActivities, 'There should be no remaining activities');
        System.assertEquals(100, summaryController.VisitSummary.PercentOfCompletedActivities, 'Percent of completed activities should be 100');
        System.assertEquals(false, summaryController.VisitSummary.IsVisitActive, 'Visit should not be active');
        System.assertEquals(true, summaryController.VisitSummary.IsVisitComplete, 'Visit should be complete');
        System.assertEquals(true, timeToInt >= 20000, 'Time spent in store should be 2 hours');
        System.assertEquals('Test Account', summaryController.VisitSummary.getStoreDisplayName(), 'Store Display Name should be Test Account');
        System.assertEquals(0, summaryController.VisitSummary.NumberOfCompletedTasks, 'There should be no tasks completed');
    }
    
}