@isTest (seealldata =false)
private class LocationPurgeBatchScheduleTest{
	
	static testMethod void testLocationPurgeBatchSchedule(){
		
		Test.startTest();
		LocationPurgeBatchSchedule lpbs = new LocationPurgeBatchSchedule();
		String sch = '0 0 23 * * ?';
		system.schedule('Test Location Purge', sch, lpbs);
		Test.stopTest();
	}
	
}