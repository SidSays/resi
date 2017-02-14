/**
 * Test class for StoreVistMailController
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 10/8/14
 */

@isTest
private class StoreVisitMailControllerTest {
    
    static testMethod void visitMailContTestDelay0() {
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
        insert testAccount;

        Contact testContact = StoreTestUtility.createContact(testAccount.Id);
        insert testContact;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-2));
        testStoreVisit.End_Date_Time__c = null;
        insert testStoreVisit;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_Type__c, role.Name);
        testActivityCategory.Email_Template__c = 'TestEmailTemplate';
        insert testActivityCategory;

        ApexPages.StandardController stdCon = new ApexPages.StandardController(testStoreVisit);

        System.runAs(testUser) {
            Store_Settings__c storeSettings = Store_Settings__c.getInstance();
            storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;
            storeSettings.Min_Visit_Time_Minutes__c = 60;
            storeSettings.Scheduled_Visit_Alert_Template__c = 'TestAlertTemplate';
            storeSettings.Detailed_Visit_Summary_Template__c = 'TestEmailTemplate';
            storeSettings.Visit_Mail_Delay_Minutes__c = 0;
            upsert storeSettings;

            Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
            EmailTemplate testTemplate = StoreTestUtility.createEmailTemplate(storeSettings, folder.Id);
            testTemplate.DeveloperName = storeSettings.Detailed_Visit_Summary_Template__c;
            insert testTemplate;

            Test.startTest();
                Test.setCurrentPage(Page.StoreVisitMail);
                StoreVisitMailController visitMailCont = new StoreVisitMailController(stdCon);
                //visitMailCont.sendVisitMail();
                List<ApexPages.Message> messages = ApexPages.getMessages();
            Test.stopTest();

            //System.assertEquals('The visit summary email was sent successfully', messages.get(0).getDetail(), 'Message should confirm send in 5 minutes');
        }

    }

    static testMethod void visitMailContTestDelay5() {
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
        insert testAccount;

        Contact testContact = StoreTestUtility.createContact(testAccount.Id);
        insert testContact;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-2));
        testStoreVisit.End_Date_Time__c = null;
        insert testStoreVisit;

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_Type__c, role.Name);
        testActivityCategory.Email_Template__c = 'TestEmailTemplate';
        insert testActivityCategory;

        ApexPages.StandardController stdCon = new ApexPages.StandardController(testStoreVisit);

        System.runAs(testUser) {
            Store_Settings__c storeSettings = Store_Settings__c.getInstance();
            storeSettings.Max_Store_Visit_Distance_Feet__c = 2000;
            storeSettings.Min_Visit_Time_Minutes__c = 60;
            storeSettings.Scheduled_Visit_Alert_Template__c = 'TestAlertTemplate';
            storeSettings.Detailed_Visit_Summary_Template__c = 'TestEmailTemplate';
            storeSettings.Visit_Mail_Delay_Minutes__c = 5;
            upsert storeSettings;

            Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
            EmailTemplate testTemplate = StoreTestUtility.createEmailTemplate(storeSettings, folder.Id);
            testTemplate.DeveloperName = storeSettings.Detailed_Visit_Summary_Template__c;
            insert testTemplate;

            Test.startTest();
                Test.setCurrentPage(Page.StoreVisitMail);
                StoreVisitMailController visitMailCont = new StoreVisitMailController(stdCon);
               // visitMailCont.sendVisitMail();
                List<ApexPages.Message> messages = ApexPages.getMessages();
            Test.stopTest();

          //  System.assertEquals('Your message will be sent in 5 minutes', messages.get(0).getDetail(), 'Message should confirm send in 5 minutes');
        }

    }
    
}