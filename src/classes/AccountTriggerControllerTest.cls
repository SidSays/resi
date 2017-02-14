/*Test Class to cover AccountTriggerControllerTest
AAuthor: Animesh Datta, Date: 8-Nov-2016
*/
@isTest
public class AccountTriggerControllerTest {

    static testMethod Void endActiveStoreVisitOwnerChage() {
        
        //Declare variables
        String AccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId();
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        List<User> usrList = new List<User>();
        
        //insert custom settings data
        TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = false;
            triggerSettingsList.add(userTrigger);

        TriggerSettings__c conTrigger = new TriggerSettings__c();
            conTrigger.Name = 'ContactTrigger';
            conTrigger.isActive__c = true;
            triggerSettingsList.add(conTrigger);

        TriggerSettings__c accTrigger = new TriggerSettings__c();
            accTrigger.Name = 'AccountTrigger';
            accTrigger.isActive__c = true;
            triggerSettingsList.add(accTrigger);

        TriggerSettings__c storeAccTrigger = new TriggerSettings__c();
            storeAccTrigger.Name = 'StoreAccountTrigger';
            storeAccTrigger.isActive__c = true;
            triggerSettingsList.add(storeAccTrigger);

        TriggerSettings__c storeVisitTrigger = new TriggerSettings__c();
            storeVisitTrigger.Name = 'StoreVisitTrigger';
            storeVisitTrigger.isActive__c = true;
            triggerSettingsList.add(storeVisitTrigger);


        if(!triggerSettingsList.isEmpty()){
            Database.insert(triggerSettingsList,false); 
        }
        
        //create users
        Profile profile = [SELECT Id FROM Profile WHERE Name='Retail Sales Rep']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE DeveloperName='Xfinity_Sales_Rep'];

        User testUser = new User();
            testUser.City='Test City';
            testUser.Username = 'storetestuser@comcast.mi.com';
            testUser.LastName = 'LastName';
            testUser.Email = 'storehomeuser1@test1.com';
            testUser.Alias = 'SHUser';
            testUser.CommunityNickname = 'SNU';
            testUser.TimeZoneSidKey = 'America/Panama';
            testUser.LocaleSidKey = 'en_US';
            testUser.EmailEncodingKey = 'ISO-8859-1';
            testUser.LanguageLocaleKey = 'en_US';
            testUser.FederationIdentifier = 'FedId1321';
            testUser.Sales_Rep_Type__c = 'Dealer AE';
            testUser.ProfileId = profile.Id;
        insert testUser;
        
        //create Account
        Account testAccount = new Account();
            testAccount.Name = 'Test Account';
            testAccount.OwnerId = testUser.id;
            testAccount.Store_Type__c = '3PL';
            testAccount.Parent_Account_Dropdown__c = 'Walmart';
            testAccount.BillingStreet ='TestStreet';
            testAccount.BillingCity = 'TestCity';
            testAccount.BillingState ='TestState'; 
            testAccount.BillingPostalCode= '12345'; 
            testAccount.BillingCountry ='TestCountry';
            testaccount.recordtypeId= AccountRecType ;
            testaccount.Region__c = 'Freedom Market';
            testAccount.Store_Location__Latitude__s = 41.175154;
            testAccount.Store_Location__Longitude__s = -85.143841;
        insert testAccount;
        
        //create store visit
        Store_Visit__c testStoreVisit = new Store_Visit__c();
            testStoreVisit.Store__c = testAccount.Id;
            testStoreVisit.OwnerId = testUser.Id;
            testStoreVisit.Start_Date_Time__c = Datetime.now();
        insert testStoreVisit;
        
        //change store to cover business logic
        testAccount.OwnerId = userinfo.getUserId();
        update testAccount;
    }
}