/**
* This is the unit test for the AddressAssignment Class
*
* @Author salesforce Services
* @Date 08/23/2016
*/
@isTest(SeeAllData=false)
private class AddressAssignmentTest {

	@testSetup static void setup() {

		//Follow existing precedence to set up the test Users we will use in our test methods
        SetupTestData.createCustomSettingRecords();
        SetupTestData.createUsers();
        SetupTestTerritoryData.createUsers();
        
        //Create Territory and Plan records for us to use in our test methods
        SetupTestTerritoryData.createTerritoryRecords(2);
        //SetupTestData.createPlanRecords(2);

        //Create sample Customer_Address__c records
        Id addrOwnerId = SetupTestData.Contractor.Id;
        Id territoryId = [SELECT Id FROM Territory__c WHERE Name = 'Territory0'].Id;
        SetupTestTerritoryData.createAddressRecords(10, addrOwnerId, territoryId);

	}	
	
	@isTest static void validateAlignToTerritory() {

		//Run as the RSA User
		User rsaUser = [SELECT Id, Profile.Id, Profile.Name FROM User WHERE Alias = 'rsaUser'];
        System.runAs(rsaUser){

			//Captue the Id of the new Territory and Plan records
			Id terr2Id = [SELECT Id FROM Territory__c WHERE Name = 'Territory1'].Id;

			Test.startTest();
			//Query the db for some sample Customer_Address__c records to pass to the AddressAssignment class
			Set<Id> mockWaveData = new Set<Id>();
			for(Customer_Address__c c : [SELECT Id FROM Customer_Address__c LIMIT 10000]){
				mockWaveData.add(c.Id);
			}

			//Call the AddressAssignment.alignToTerritory method and try to reassign Address records to the XSP user
			Boolean result = AddressAssignment.alignToTerritory(terr2Id, mockWaveData);
			
			//Assert true that the AddressAssignment.alignToTerritory method reassigned the Address records as expected
			System.assertEquals(true, result);
			Test.stopTest();
        }
	}
	
}