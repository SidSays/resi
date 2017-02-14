/**
 * Test class for StoreVisitMailer
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 10/12/14
 */

@isTest
private class StoreVisitMailerTest {
    
    static testMethod void visitMailerTest(){
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
        insert eventTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        TriggerSettings__c contactTriggerSettings = StoreTestUtility.createTriggerSettings('ContactTrigger');
        insert contactTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Xfinity Sales Rep'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        testAccount.Store_Type__c = '3PL';
        insert testAccount;

        Contact testContact = StoreTestUtility.createContact(testAccount.Id);
        insert testContact;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-2));
        testStoreVisit.End_Date_Time__c = null;
        insert testStoreVisit;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_Type__c, role.Name);
        testActivityCategory.Email_Template__c = 'summaryTemplate';
        testActivityCategory.Name = '5';
        testActivityCategory.Number_Required__c = 0;
        testActivityCategory.Record_Type_Name__c = 'Issue_Resolution';
        testActivityCategory.Store_Activity_Category__c = 'Issue Resolution';
        testActivityCategory.Send_Mail_Check_Field__c = null;
        insert testActivityCategory;

        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(testStoreVisit.Id);
        sA1.Notes__c = 'This is a test note for Issue Resolution Summary';
        insert sA1;

        Store_Activity__c confirmActivity = [SELECT Id, Notes__c
                                             FROM Store_Activity__c
                                             WHERE Id = :sA1.Id];

        List<Store_Activity__c> storeActivities = new List<Store_Activity__c>();
        storeActivities.add(confirmActivity);

        RequiredStoreActivity requiredActivity = new RequiredStoreActivity(testActivityCategory, storeActivities);
 
        List<RequiredStoreActivity> requiredStoreActivities = new List<RequiredStoreActivity>();
        requiredStoreActivities.add(requiredActivity);

        testStoreVisit.End_Date_Time__c = Datetime.now();
        update testStoreVisit;

        StoreVisitSummary testVisitSummary = new StoreVisitSummary(testAccount, testStoreVisit, requiredStoreActivities);

        System.runAs(testUser) {
            Store_Settings__c storeSettings = Store_Settings__c.getInstance();
            storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;
            storeSettings.Min_Visit_Time_Minutes__c = 60;
            storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
            insert storeSettings;

            Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
            EmailTemplate summaryTemplate = StoreTestUtility.createEmailTemplate(storeSettings, folder.Id);
            summaryTemplate.DeveloperName = 't01';
            summaryTemplate.Body = 'To whom it may concern, {!Store_Visit__c.Owner_Full_Name__c} ' +
                ' just conducted a store visit for {!Store_Visit__c.Store_Name__c} located at ' +
                ' {!Store_Visit__c.Store_Address__c}. While visiting the store, ' + 
                ' {!Store_Visit__c.Owner_Full_Name__c} noticed the following things: <StoreActivities>';
            summaryTemplate.HtmlValue = 'To whom it may concern, {!Store_Visit__c.Owner_Full_Name__c} ' +
                ' just conducted a store visit for {!Store_Visit__c.Store_Name__c} located at ' +
                ' {!Store_Visit__c.Store_Address__c}. While visiting the store, ' + 
                ' {!Store_Visit__c.Owner_Full_Name__c} noticed the following things: <StoreActivities>';
            insert summaryTemplate;

            EmailTemplate activityTemplate1 = StoreTestUtility.createEmailTemplate(storeSettings, folder.Id);
            activityTemplate1.Body = 'An issue was discovered with the following description: ' + 
                ' {!Store_Activity__c.Notes__c} Issue Resolved in Store?';
            activityTemplate1.HtmlValue = 'An issue was discovered with the following description: ' + 
                ' {!Store_Activity__c.Notes__c} Issue Resolved in Store?';
            activityTemplate1.Name ='activityTemplate1';

            List<EmailTemplate> activityTemplates = new List<EmailTemplate>();
            activityTemplates.add(activityTemplate1);
            insert activityTemplates;

            Test.startTest();
                StoreVisitMailer mailer = new StoreVisitMailer(summaryTemplate, activityTemplates);
                //String body = mailer.generateEmailBody(testVisitSummary);
            Test.stopTest();


            String assertedEmailBody = 'To whom it may concern, {!Store_Visit__c.Owner_Full_Name__c} ' +
                ' just conducted a store visit for {!Store_Visit__c.Store_Name__c} located at ' +
                ' {!Store_Visit__c.Store_Address__c}. While visiting the store, ' + 
                ' {!Store_Visit__c.Owner_Full_Name__c} noticed the following things: {!' + confirmActivity.Id + '}';

           // System.assertEquals(assertedEmailBody, body, 'Body should match string');

        }

    }
    
}