/**************************************************************************************************
Name : LocationPurgeBatchSchedule
Description : Scheduler for LocationPurgeBatch
User Story : US1042773
Date : 17 April 2017
Author : Anshuman Mohanty 
***************************************************************************************************/
global class LocationPurgeBatchSchedule implements Schedulable{
	
	global void execute(SchedulableContext sc){
		
		String query = system.label.Location_Purge_Query;
        LocationPurgeBatch deleteLoc = new LocationPurgeBatch(query);
        ID batchID = Database.executeBatch(deleteLoc);
	}
}