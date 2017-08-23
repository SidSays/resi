/**
 * Utility class to set up test data
 *
 * @Author Ryan Sayles
 * @Date 8/27/14
 */
 
@isTest
public with sharing class StoreTestUtility {

    public static User createUser(String username, Id profileId, String commNickName) {
        User testUser = new User();
        testUser.City='Test City';
        testUser.Username = username;
        testUser.LastName = 'LastName';
        testUser.Email = 'storehomeuser1@test1.com';
        testUser.Alias = 'SHUser';
        testUser.CommunityNickname = commNickName;
        testUser.TimeZoneSidKey = 'America/Panama';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.FederationIdentifier = 'FedId1'+username;
        testUser.ProfileId = profileId;
        return testUser;
    }

    public static Account createAccount(Id userId) {
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.OwnerId = userId;
        testAccount.Store_Location__Latitude__s = 37.776114;
        testAccount.Store_Location__Longitude__s = -122.417047;
        testAccount.Store_Type__c = 'Best Buy';
        return testAccount;
    }

    public static Event createEvent(Id userId, Id accountId, DateTime startDateTime) {
        Event testEvent = new Event();
        testEvent.OwnerId = userId;
        testEvent.WhatId = accountId;
        testEvent.StartDateTime = startDateTime;
        testEvent.DurationInMinutes = 15;
        return testEvent;
    }

    public static Task createTask(Id userId, Id visitId) {
        Task testTask = new Task();
        testTask.WhatId = visitId;
        testTask.Subject = 'Call';
        testTask.OwnerId = userId;
        testTask.Status = 'Completed';
        testTask.Priority = 'Normal';
        testTask.ActivityDate = System.Today();

        return testTask;
    }

    public static Contact createContact(Id storeId) {
        Contact testContact = new Contact();
        testContact.AccountId = storeId;
        testContact.LastName = 'Test';
        return testContact;
    }

    public static Store_Visit__c createStoreVisit(Id storeId, Id ownerId) {
        return createStoreVisit(storeId, ownerId, null);
    }

    public static Store_Visit__c createStoreVisit(Id storeId, Id ownerId, DateTime startDateTime) {
        Store_Visit__c testStoreVisit = new Store_Visit__c();
        testStoreVisit.Store__c = storeId;
        testStoreVisit.OwnerId = ownerId;
        testStoreVisit.Start_Date_Time__c = startDateTime;
        if (startDateTime != null) {
            testStoreVisit.End_Date_Time__c = startDateTime.addHours(2);
        }
        return testStoreVisit;
    }

    public static Store_Activity__c createStoreActivity(Id storeVisitId) {
        Store_Activity__c storeActivity = new Store_Activity__c();
        storeActivity.Store_Visit__c = storeVisitId;
        return storeActivity;
    }

    public static RecordType createRecordType(String name) {
        RecordType testRecordType = new RecordType();
        testRecordType.Name = name;
        return testRecordType;
    }

    public static TriggerSettings__c createTriggerSettings(String name) {
        TriggerSettings__c triggerSetting = new TriggerSettings__c();
        triggerSetting.Name = name;
        triggerSetting.IsActive__c = true;

        return triggerSetting;
    }

    public static EmailTemplate createEmailTemplate(Store_Settings__c storeSettings, Id folderId) {
        EmailTemplate testEmailTemplate = new EmailTemplate();
        testEmailTemplate.DeveloperName = storeSettings.Scheduled_Visit_Alert_Template__c;
        testEmailTemplate.Name ='TestEmailTemplate';
        testEmailTemplate.FolderId = folderId;
        testEmailTemplate.TemplateType ='text';
        testEmailTemplate.Body = 'Test Email Body';
        testEmailTemplate.HtmlValue = 'Test HTML Email Body';

        return testEmailTemplate;
    }

    public static EmailTemplate createProspectEmailTemplate(Store_Settings__c storeSettings, Id folderId) {
        EmailTemplate testEmailTemplate = new EmailTemplate();
        testEmailTemplate.DeveloperName = storeSettings.Prospect_Store_Visit_Summary_Template__c;
        testEmailTemplate.Name ='ProspectTestEmailTemplate';
        testEmailTemplate.FolderId = folderId;
        testEmailTemplate.TemplateType ='text';
        testEmailTemplate.Body = 'Test Email Body';
        testEmailTemplate.HtmlValue = 'Test HTML Email Body';

        return testEmailTemplate;
    }

    public static Store_Visit_Activity_Category__c createActivityCategory(String storeType, String userRoleName) {
        Store_Visit_Activity_Category__c activityCategory = new Store_Visit_Activity_Category__c();
        activityCategory.Name = '140';
        activityCategory.Number_Required__c = 1;
        activityCategory.Record_Type_Name__c = 'Best_Buy_Manager_Review_New';
        activityCategory.Store_Activity_Category__c = 'Manager Review';
        activityCategory.Store_Type__c = storeType;
        activityCategory.User_Role__c = userRoleName;
        activityCategory.New_Records__c = True;

        return activityCategory;
    }

}