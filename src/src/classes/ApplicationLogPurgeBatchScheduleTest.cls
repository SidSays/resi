/**************************************************************************************************
Name : ApplicationLogPurgeBatchScheduleTest
Description : Scheduler for ApplicationLogPurgeBatchSchedule
User Story : US1026408: Create a trigger exception logging framework
Date : 25 June 2017
Author : Amit Kumar
***************************************************************************************************/
@isTest (seealldata =false)
private class ApplicationLogPurgeBatchScheduleTest{
/*
	Test Method for Schedule class
*/	
	static testMethod void testApplicationLogPurgeBatchSchedule(){
		VariableSettingTestUtility.variableSettingsData();
		Test.startTest();
		ApplicationLogPurgeBatchSchedule lpbs = new ApplicationLogPurgeBatchSchedule();
		String sch = '0 0 23 * * ?';
		system.schedule('Test Log Purge', sch, lpbs);
		Test.stopTest();
	}
	
}