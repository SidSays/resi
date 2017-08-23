@isTest
public class AddressTerritoryHandlerTest {
    private static Account acc;
    private static Account acc2;
    private static List<Customer_Address__c> listOfAddresses;
    private static List<Territory__c> listOfTerritories;
    private static List<Customer_Address__c> listOfAddressesWithTerritory;
    private static Id addrOwnerId;
    private static User usr;

    private static void init() {
        Profile userProfile = [Select Id from Profile where Name = 'System Administrator'];
        usr = [SELECT Id FROM User WHERE ProfileId = :userProfile.Id AND IsActive = true Limit 1];
        
        // Creates a user that is required to insert the territory.
        SetupTestData.createCustomSettingRecords();
        VariableSettingTestUtility.variableSettingsData();
        //SetupTestData.createUsers();
        //SetupTestTerritoryData.createUsers();

        acc = TestDataUtility.createAccount();
        acc.Customer_Status__c = 'Active';
        insert acc;

        acc2 = TestDataUtility.createAccount();
        acc2.Customer_Status__c = 'Inactive';
        insert acc2;

        listOfTerritories = SetupTestTerritoryData.createTerritoryRecords(2);

        //Create sample Customer_Address__c records
        addrOwnerId = UserInfo.getUserId();
        //listOfAddresses = SetupTestTerritoryData.createAddressRecordsWithoutTerritory(2, addrOwnerId);
    }

    private static void createNonTargetedAddresses() {
        listOfAddressesWithTerritory = SetupTestTerritoryData.createNonTargetedAddressRecords(2, addrOwnerId,listOfTerritories[0].Id);

    }

    private static void createTargetedAddresses() {
        listOfAddressesWithTerritory = SetupTestTerritoryData.createTargetedAddressRecords(2, addrOwnerId,listOfTerritories[0].Id);

    }

    

    private static testMethod void testUpdateTargetedIndicator1() {
        init();
        createNonTargetedAddresses();

        AddressTerritoryHandler.hasExecuted = false;

        system.Test.startTest();

        listOfAddressesWithTerritory[0].Account__c = acc.id;
        listOfAddressesWithTerritory[0].Targeted__c = false;

        listOfAddressesWithTerritory[1].Account__c = acc2.id;

        update listOfAddressesWithTerritory;
        system.Test.stopTest();
        List<Id> setOfAddrIds = new List<Id>{listOfAddressesWithTerritory[0].Id,listOfAddressesWithTerritory[1].Id};
        List<Customer_Address__c> updatedListOfAddresses = [
            SELECT
                Active_Inactive__c,
                Targeted__c,
                Territory__c
            FROM Customer_Address__c
            WHERE Id IN :setOfAddrIds
            ORDER BY Name
        ];


        // Asserting that the Targeted__c field was changed correctly by the method.
        System.debug('>>>>>>updatedListOfAddresses:'+updatedListOfAddresses);
        System.assertEquals(false, updatedListOfAddresses[0].Targeted__c);
        //System.assertEquals(true, updatedListOfAddresses[1].Targeted__c);
    }

    private static testMethod void testUpdateTargetedIndicator2() {
        init();
        createTargetedAddresses();
        AddressTerritoryHandler.hasExecuted = false;

        system.Test.startTest();

        listOfAddressesWithTerritory[0].Account__c = acc.id;

        listOfAddressesWithTerritory[1].Account__c = acc2.id;

        update listOfAddressesWithTerritory;
        system.Test.stopTest();
        List<Id> setOfAddrIds = new List<Id>{listOfAddressesWithTerritory[0].Id,listOfAddressesWithTerritory[1].Id};
        List<Customer_Address__c> updatedListOfAddresses = [
            SELECT
                Active_Inactive__c,
                Targeted__c,
                Territory__c
            FROM Customer_Address__c
            WHERE Id IN :setOfAddrIds
            ORDER BY Name
        ];


        // Asserting that the Targeted__c field was changed correctly by the method.
        System.assertEquals(false, updatedListOfAddresses[0].Targeted__c);
        System.assertEquals(true, updatedListOfAddresses[1].Targeted__c);
    }

    private static testMethod void testNewAddressTerritoryAssignment() {
        init();
        createNonTargetedAddresses();
        AddressTerritoryHandler.hasExecuted = false;

        system.Test.startTest();
        listOfAddresses = SetupTestTerritoryData.createAddressRecordsWithoutTerritory(2, UserInfo.getUserId());
        System.Test.StopTest();

        List<Id> setOfAddrIds = new List<Id>{listOfAddresses[0].Id,listOfAddresses[1].Id};
        List<Customer_Address__c> updatedListOfAddresses = [
            SELECT
                Active_Inactive__c,
                Targeted__c,
                Territory__c,
                Territory_Name__c,
                Assigned_To_Territory__c
            FROM Customer_Address__c
            WHERE Id IN :setOfAddrIds
            ORDER BY Name
        ];

        // Asserting that the Targeted__c field was changed correctly by the method.
        System.assert(updatedListOfAddresses[0].Territory__c !=null);
        System.assert(updatedListOfAddresses[0].Territory_Name__c == 'Territory0');
        System.assert(updatedListOfAddresses[0].Assigned_To_Territory__c=='YES');
    }
    
    private static testMethod void testUpdateCensuBlocks() {
        init();
        createNonTargetedAddresses();
        AddressTerritoryHandler.hasExecuted = false;
        listOfAddresses = SetupTestTerritoryData.createAddressRecordsWithoutTerritoryNoCensusBlocks(2, UserInfo.getUserId());

        system.Test.startTest();
        listOfAddresses[0].Census_Block__c ='AA003562300';
        update listOfAddresses[0];
        System.Test.StopTest();

        List<Id> setOfAddrIds = new List<Id>{listOfAddresses[0].Id};
        List<Customer_Address__c> updatedListOfAddresses = [
            SELECT
                Active_Inactive__c,
                Targeted__c,
                Territory__c,
                Territory_Name__c,
                Assigned_To_Territory__c
            FROM Customer_Address__c
            WHERE Id IN :setOfAddrIds
            ORDER BY Name
        ];

        // Asserting that the Targeted__c field was changed correctly by the method.
        //System.assert(updatedListOfAddresses[0].Territory__c !=null);
        //System.assert(updatedListOfAddresses[0].Territory_Name__c == 'Territory0');
        //System.assert(updatedListOfAddresses[0].Assigned_To_Territory__c=='YES');
    }
}