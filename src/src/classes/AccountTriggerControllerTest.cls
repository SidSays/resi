/*Test Class to cover AccountTriggerControllerTest
AAuthor: Animesh Datta, Date: 8-Nov-2016
*/
@isTest
public class AccountTriggerControllerTest {

    static testMethod Void endActiveStoreVisitOwnerChage() {
    	
    	VariableSettingTestUtility.variableSettingsData();
        
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
        list<territory__c>listOfTerritories = SetupTestTerritoryData.createTerritoryRecords(2);
        //Id addrOwnerId = SetupTestData.Contractor.Id;
        Id territoryId = [SELECT Id FROM Territory__c WHERE Name = 'Territory0'].Id;
        List<Customer_Address__c> lstcusomeraddress = SetupTestTerritoryData.createAddressRecords(10, testUser.id, territoryId, true);
        List<Customer_Address__c> lstcusomeraddress1 = SetupTestTerritoryData.createAddressRecordsWithoutTerritory(10, testUser.id);
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
            testAccount.Customer_Status__c = 'Active';
            testAccount.Is_Parent_Organization__c = true;
            testAccount.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId();
        insert testAccount;
        
         Account testAccount1 = new Account();
            testAccount1.Name = 'Test Account1';
            testAccount1.OwnerId = testUser.id;
            testAccount1.Store_Type__c = '3PL1';
            testAccount1.Parent_Account_Dropdown__c = 'ABB';
            testAccount1.BillingStreet ='TestStreet1';
            testAccount1.BillingCity = 'TestCity';
            testAccount1.BillingState ='TestState'; 
            testAccount1.BillingPostalCode= '12345'; 
            testAccount1.BillingCountry ='TestCountry';
            testAccount1.recordtypeId= AccountRecType ;
            testAccount1.Region__c = 'Freedom Market';
            testAccount1.Store_Location__Latitude__s = 41.175154;
            testAccount1.Store_Location__Longitude__s = -85.143841;
            testAccount1.Customer_Status__c = 'false';
            testAccount1.Is_Parent_Organization__c = false;
            testAccount1.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Xfinity Record Type').getRecordTypeId();
        insert testAccount1;
        lstcusomeraddress[0].Account__c = testAccount1.id;
        update lstcusomeraddress[0];
        lstcusomeraddress1[0].Account__c = testAccount1.id;
        update lstcusomeraddress1[0];
        testAccount1.Customer_Status__c = 'Active';
        update testAccount1;
        lstcusomeraddress[0].Targeted__c = false;
        testAccount1.Customer_Status__c = 'InActive';
       update  lstcusomeraddress[0];
        update testAccount1;
         
        //create store visit
        Store_Visit__c testStoreVisit = new Store_Visit__c();
            testStoreVisit.Store__c = testAccount.Id;
            testStoreVisit.OwnerId = testUser.Id;
            testStoreVisit.Start_Date_Time__c = Datetime.now();
        insert testStoreVisit;
        
        //change store to cover business logic
        testAccount.OwnerId = userinfo.getUserId();
        update testAccount;
        Map<Id, Account> OldAccMap= new Map<Id, Account>();
        OldAccMap.put(testAccount.Id,testAccount);
        
        Map<Id, Account> OldAccMap1= new Map<Id, Account>();
        OldAccMap1.put(testAccount1.Id,testAccount1);
        
        Set<Id> storeIds = new Set<Id> ();
        storeIds.add(testStoreVisit.id);
        List<Account> lstAcct = new List<Account>();
        
        lstAcct.add(testAccount1);
        
        String labelName = System.Label.AccountRecordType;
        Set<String> parentAccountSelectSet = new Set<String>();
        parentAccountSelectSet.add(labelName);
        
        String labelName1 = System.Label.XfinityAccountRecordType;  
        Set<String> recordTypeIdSet = new Set<String>();
        recordTypeIdSet.add(labelName1);       
        
        test.startTest();
     //   AccountTriggerHelper acctTrigHelper =  new AccountTriggerHelper();
        AccountTriggerHelper.deleteRelatedStoreVisits(OldAccMap);
   		AccountTriggerHelper.getAllAccountRecordTypes();
        AccountTriggerHelper.getAccountRecordType();
        AccountTriggerHelper.getStoreVisits(storeIds);
        AccountTriggerHelper.suffixParentAccountName(lstAcct);
        AccountTriggerHelper.endActiveStoreVisitOwnerChage(lstAcct,OldAccMap1);
        AccountTriggerHelper.getAccountRecordType();
       // AccountTriggerHelper.assignParentBeforeInsert(lstAcct);
        AccountTriggerHelper.assignParentBeforeUpdate(lstAcct,OldAccMap1);
        AccountTriggerHelper.parentAccountAssignment(parentAccountSelectSet,lstAcct);
        AccountTriggerHelper.validateAccessBeforeUpdate(lstAcct,OldAccMap1);        
        AccountTriggerHelper.populateParentAccount(lstAcct);
        AccountTriggerHelper.addressOrangeFieldUpdate(lstAcct,OldAccMap1);
        
        
       test.stopTest(); 
       
       
    }
    
    @isTest
    public static void testHsiOnly(){
        
        VariableSettingTestUtility.variableSettingsData();
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
        list<territory__c>listOfTerritories = SetupTestTerritoryData.createTerritoryRecords(2);
        //Id addrOwnerId = SetupTestData.Contractor.Id;
        Id territoryId = [SELECT Id FROM Territory__c WHERE Name = 'Territory0'].Id;
        List<Customer_Address__c> lstcusomeraddress = SetupTestTerritoryData.createAddressRecords(10, testUser.id, territoryId, true);
        List<Customer_Address__c> lstcusomeraddress1 = SetupTestTerritoryData.createAddressRecordsWithoutTerritory(10, testUser.id);
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
            testAccount.Customer_Status__c = 'Active';
            testAccount.Is_Parent_Organization__c = true;
            testAccount.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId();
        insert testAccount;
        
         Account testAccount1 = new Account();
            testAccount1.Name = 'Test Account1';
            testAccount1.OwnerId = testUser.id;
            testAccount1.Store_Type__c = '3PL1';
            testAccount1.Parent_Account_Dropdown__c = 'ABB';
            testAccount1.BillingStreet ='TestStreet1';
            testAccount1.BillingCity = 'TestCity';
            testAccount1.BillingState ='TestState'; 
            testAccount1.BillingPostalCode= '12345'; 
            testAccount1.BillingCountry ='TestCountry';
            testAccount1.recordtypeId= AccountRecType ;
            testAccount1.Region__c = 'Freedom Market';
            testAccount1.Store_Location__Latitude__s = 41.175154;
            testAccount1.Store_Location__Longitude__s = -85.143841;
            testAccount1.Customer_Status__c = 'false';
            testAccount1.Is_Parent_Organization__c = false;
        	testAccount1.HSI_Active__c = true;
            testAccount1.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Xfinity Record Type').getRecordTypeId();
        insert testAccount1;
        lstcusomeraddress[0].Account__c = testAccount1.id;
        update lstcusomeraddress[0];
        lstcusomeraddress1[0].Account__c = testAccount1.id;
        update lstcusomeraddress1[0];
        testAccount1.Customer_Status__c = 'Active';
        update testAccount1;
        lstcusomeraddress[0].Targeted__c = false;
        testAccount1.Customer_Status__c = 'InActive';
       update  lstcusomeraddress[0];
        update testAccount1;
         
        //create store visit
        Store_Visit__c testStoreVisit = new Store_Visit__c();
            testStoreVisit.Store__c = testAccount.Id;
            testStoreVisit.OwnerId = testUser.Id;
            testStoreVisit.Start_Date_Time__c = Datetime.now();
        insert testStoreVisit;
        
        //change store to cover business logic
        testAccount.OwnerId = userinfo.getUserId();
        update testAccount;
        Map<Id, Account> OldAccMap= new Map<Id, Account>();
        OldAccMap.put(testAccount.Id,testAccount);
        
        Map<Id, Account> OldAccMap1= new Map<Id, Account>();
        OldAccMap1.put(testAccount1.Id,testAccount1);
        
        Set<Id> storeIds = new Set<Id> ();
        storeIds.add(testStoreVisit.id);
        List<Account> lstAcct = new List<Account>();
        
        lstAcct.add(testAccount1);
        
        String labelName = System.Label.AccountRecordType;
        Set<String> parentAccountSelectSet = new Set<String>();
        parentAccountSelectSet.add(labelName);
        
        String labelName1 = System.Label.XfinityAccountRecordType;  
        Set<String> recordTypeIdSet = new Set<String>();
        recordTypeIdSet.add(labelName1);       
        
        test.startTest();
     //   AccountTriggerHelper acctTrigHelper =  new AccountTriggerHelper();
        AccountTriggerHelper.deleteRelatedStoreVisits(OldAccMap);
   		AccountTriggerHelper.getAllAccountRecordTypes();
        AccountTriggerHelper.getAccountRecordType();
        AccountTriggerHelper.getStoreVisits(storeIds);
        AccountTriggerHelper.suffixParentAccountName(lstAcct);
        AccountTriggerHelper.endActiveStoreVisitOwnerChage(lstAcct,OldAccMap1);
        AccountTriggerHelper.getAccountRecordType();
       // AccountTriggerHelper.assignParentBeforeInsert(lstAcct);
        AccountTriggerHelper.assignParentBeforeUpdate(lstAcct,OldAccMap1);
        AccountTriggerHelper.parentAccountAssignment(parentAccountSelectSet,lstAcct);
        AccountTriggerHelper.validateAccessBeforeUpdate(lstAcct,OldAccMap1);        
        AccountTriggerHelper.populateParentAccount(lstAcct);
        AccountTriggerHelper.addressOrangeFieldUpdate(lstAcct,OldAccMap1);
        
        
       test.stopTest(); 
       
       
    }
}