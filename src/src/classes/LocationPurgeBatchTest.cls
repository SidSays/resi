@isTest (seealldata =false)
private class LocationPurgeBatchTest{
	
	@testSetup
	static void setup(){
		
		List<Location__c> lstlocations = new List<Location__c>();
		for(integer i =0;i<150;i++){
			Location__c loc = new Location__c();
			loc.Name = 'Test Loc for Purge batch'+i;
			lstlocations.add(loc);	
		}
		
		Database.insert(lstlocations,false);
		
	}
	
	static testMethod void testLocationPurgeBatch(){
		
		setup();
		Test.startTest();
		LocationPurgeBatch lpb = new LocationPurgeBatch(null);
		Database.executeBatch(	lpb);
		Test.stopTest();
	}
	
}