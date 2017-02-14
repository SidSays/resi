/**
 * Test class for StoreVisitSummary
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 10/1/14
 *
 */ 

 @isTest
private class StoreVisitSummaryTest {
    
    static testMethod void storeVisitSummary(){
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

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-2));
        testStoreVisit.End_Date_Time__c = null;
        insert testStoreVisit;

        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(testStoreVisit.Id);    
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

        Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;
        storeSettings.Min_Visit_Time_Minutes__c = 60;

        RequiredStoreActivity requiredActivity = new RequiredStoreActivity(testActivityCategory, storeActivities);
        //test data for task.
        List<Task> taskVisit = new List<Task>();
        Task tk = new Task();
        tk.OwnerId = UserInfo.getUserId();
        //tk.whoId = ld.Id;
        tk.Subject = 'test';
        tk.Status = 'Completed';
        tk.Priority = 'Normal';
        tk.ActivityDate = System.Today();
        insert tk;
        taskVisit.add(tk);

        List<RequiredStoreActivity> requiredStoreActivities = new List<RequiredStoreActivity>();
        requiredStoreActivities.add(requiredActivity);

        testStoreVisit.End_Date_Time__c = Datetime.now();
        update testStoreVisit;
 

        Test.startTest();
            StoreVisitSummary visitSummary = new StoreVisitSummary(testAccount, testStoreVisit, requiredStoreActivities);
            StoreVisitSummary.createSummary(testAccount, testStoreVisit, requiredStoreActivities,taskVisit);
            ProspectiveStoreVisitSummary objProspect = new ProspectiveStoreVisitSummary(testStoreVisit, requiredStoreActivities, taskVisit);
            ProspectiveStoreVisitSummary objProspectTwo = new ProspectiveStoreVisitSummary(testStoreVisit, requiredStoreActivities);
            objProspect.getStoreDisplayName();
        Test.stopTest();

        Integer timeToInt = Integer.valueOf(visitSummary.TimeSpentInStore.remove(':'));

        System.assertEquals(0, visitSummary.NumberOfRemainingActivities, 'There should be no remaining activities');
        System.assertEquals(100, visitSummary.PercentOfCompletedActivities, 'Percent of completed activities should be 100');
        System.assertEquals(false, visitSummary.IsVisitActive, 'Visit should not be active');
        System.assertEquals(true, visitSummary.IsVisitComplete, 'Visit should be complete');
        System.assertEquals(true, timeToInt >= 20000, 'Time spent in store should be 2 hours');
        System.assertEquals('Test Account', visitSummary.getStoreDisplayName(), 'Store Display Name should be Test Account');
        System.assertEquals(0, visitSummary.NumberOfCompletedTasks, 'There should be no tasks completed');
        //System.assertEquals(StoreVisitUtility.getLocalTimeFromGmt(DateTime.now().addHours(-2)), visitSummary.StartDateTime, 'Start time should be 2 hours prior to the current time');
        //System.assertEquals(StoreVisitUtility.getLocalTimeFromGmt(DateTime.now()), visitSummary.EndDateTime, 'End time should be the current time');
    }

}