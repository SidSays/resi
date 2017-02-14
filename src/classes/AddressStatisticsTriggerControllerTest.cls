@isTest
private class AddressStatisticsTriggerControllerTest {
	
	@isTest 
	static void testAddressStatisticsTriggerController(){
		SetupTestData.createCustomSettingRecords();

		Test.startTest();
		Address_Statistics__c addressStats = new Address_Statistics__c();
		addressStats.Assigned__c = true;
		addressStats.Legacy_ID__c='195B NodeBELTWAY MARKET';
		addressStats.Region__c='BELTWAY MARKET';
		insert addressStats;

		addressStats.Prevent_Address_Locking__c = true;
		update addressStats;
		if(!addressStats.Assigned__c){
			System.debug('Address Statistics Trigger is working as intended');
		} else {
			System.debug('Address Statistics Trigger is not working as intended');
		}
		Test.stopTest();
	}
}