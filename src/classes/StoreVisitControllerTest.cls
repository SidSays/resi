/**
 * Test class for the StoreVisitController
 *
 * @Author Ryan Sayles
 * @Date 9/11/14
 */

@isTest
private class StoreVisitControllerTest {
   
    static testMethod void validateStartStoreVisit(){
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
        testUser.UserRoleId = role.Id;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            insert testUser;
        }
        
        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        System.runAs(new User(Id = Userinfo.getUserId())) {
            insert testAccount;
        }

        ApexPages.StandardController stdCon = new ApexPages.StandardController(testAccount);
        Double userLat = 37.776114;
        Double userLong = -122.417047;

        Geolocation location = new Geolocation(userLat, userLong);

        Store_Visit__c setStoreVisit;

        User queriedUser = [SELECT Id, UserRoleId FROM User WHERE Id = :testUser.Id];

        System.runAs(queriedUser){

            Store_Settings__c storeSettings = Store_Settings__c.getInstance();
            storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;
            storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
            upsert storeSettings;

            Test.startTest();
                StoreVisitController storeVisitCont = new StoreVisitController(stdCon);
                setStoreVisit = storeVisitCont.StoreVisit;
                storeVisitCont.UserLocation = location;
                storeVisitCont.validateStartVisit();
            Test.stopTest();
        }

        Store_Visit__c queriedStoreVisit = [SELECT Id FROM Store_Visit__c WHERE Store__c = :testAccount.Id];
        System.assertEquals(setStoreVisit.Id, queriedStoreVisit.Id, 'Test should have created a new StoreVisit object');
    }

    static testMethod void validateStopStoreVisit(){
        SetupTestData.createCustomSettingRecords();
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c taskTriggerSettings = StoreTestUtility.createTriggerSettings('TaskTrigger');
        insert taskTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Xfinity Sales Rep'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRoleId = role.Id;
        System.runAs(new User(Id = Userinfo.getUserId())) {
            insert testUser;
        }
        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        System.runAs(new User(Id = Userinfo.getUserId())) {
            insert testAccount;
        }
        Contact testContact = StoreTestUtility.createContact(testAccount.Id);
        System.runAs(new User(Id = Userinfo.getUserId())) {
            insert testContact;
        }

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, DateTime.now().addHours(-2));
        testStoreVisit.End_Date_Time__c = null;
        insert testStoreVisit;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_Type__c, role.Name);
        insert testActivityCategory;
     User queriedUser = [SELECT Id, UserRoleId FROM User WHERE Id = :testUser.Id];
     System.runAs(queriedUser){
     
        Store_Activity__c testStoreActivity = StoreTestUtility.createStoreActivity(testStoreVisit.Id);    
        testStoreActivity.Who_did_you_meet_with__c = testContact.Id;
        testStoreActivity.What_is_the_store_s_focus_this_month__c = 'Accessories';
        testStoreActivity.Engagement_level_of_manager__c = '3';
        testStoreActivity.What_did_you_review_with_the_manager__c = 'Commissions, Incentives';
        insert testStoreActivity;

        ApexPages.StandardController stdCon = new ApexPages.StandardController(testAccount);
       
        Double userLat = 37.776114;
        Double userLong = -122.417047;
        Geolocation location = new Geolocation(userLat, userLong);

        Store_Visit__c setStoreVisit;

        

       

            Store_Settings__c storeSettings = Store_Settings__c.getInstance();
            storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;
            storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
            storeSettings.Min_Visit_Time_Minutes__c = 60;
            upsert storeSettings;
            
            
            Store_Activity__c StoreActivityQuery = [SELECT Id, Location__Latitude__s FROM Store_Activity__c WHERE Id = :testStoreActivity.Id];
            
            
            Store_Visit_Activity_Category__c storeCategory= new Store_Visit_Activity_Category__c();
            storeCategory.Record_Type_Name__c = 'Big_Box_Manager_Review';
            Test.startTest();
                
                List<Store_Activity__c > StoreActivitylist = new List<Store_Activity__c >();
                StoreActivitylist.add(StoreActivityQuery);
                StoreVisitController storeVisitCont = new StoreVisitController(stdCon);
                setStoreVisit = storeVisitCont.StoreVisit;
                storeVisitCont.UserLocation = location;
                storeVisitCont.SelectedActivityId = testStoreActivity.Id;
                storeVisitCont.SelectedRecordType = 'Big_Box_Manager_Review';
                RequiredStoreActivity requiredstoreAct = New RequiredStoreActivity(storeCategory,StoreActivitylist);
                storeVisitCont.RequiredStoreActivities.add(requiredstoreAct);
                storeVisitCont.setActivityLocation();
                storeVisitCont.addStoreActivity();
                storeVisitCont.validateStopVisit();
                storeVisitCont.addTask();
                Boolean Flag = storeVisitCont.IsValidationRequired;
                Double doubleValue = storeVisitCont.VisitStartDateTimeMs;
                StoreVisitSummary sm = storeVisitCont.VisitSummary;
                storeVisitCont.validateStartVisit();
            Test.stopTest();
        

        Store_Visit__c queriedStoreVisit = [SELECT Id FROM Store_Visit__c WHERE Store__c = :testAccount.Id];
        System.assertEquals(setStoreVisit.Id, queriedStoreVisit.Id, 'Test should have created a new StoreVisit object');
        
        Store_Activity__c queriedStoreActivity = [SELECT Id, Location__Latitude__s FROM Store_Activity__c WHERE Id = :testStoreActivity.Id];
        System.assertEquals(userLat, queriedStoreActivity.Location__Latitude__s, 'Location on Store Activity should be set to users');
        
        List<Task> queriedTask = [SELECT Id, Subject FROM Task WHERE WhatId = :setStoreVisit.Id];
        //System.assertEquals('Reminder Task', queriedTask.Subject, 'Task should be created with subject: Reminder Task');

        }
    }

}