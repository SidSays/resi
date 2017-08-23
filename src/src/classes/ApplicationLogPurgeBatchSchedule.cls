/**************************************************************************************************
Name : ApplicationLogPurgeBatchSchedule
Description : Scheduler for ApplicationLogPurgeBatch
User Story : US1026408: Create a trigger exception logging framework
Date : 25 June 2017
Author : Amit Kumar
***************************************************************************************************/
global class ApplicationLogPurgeBatchSchedule implements Schedulable{
	/************************************************************************************************************
        @Name       :   execute
        @Description:   Method to schedule the ApplicationLogPurgeBatch Class
        @Parameters :   schedulable Context
        @Returns    :   void
    ************************************************************************************************************/
	global void execute(SchedulableContext sc){
	    Id nonintegrationRTypeId = Schema.SObjectType.Application_Log__c.getRecordTypeInfosByName().get(ConstantHandler.APPLOGNONINTEGRATION).getRecordTypeId();
		String query = ConstantHandler.APPLOGDELETEBATCHQUERY; //Get the query from Custom setting
        ApplicationLogPurgeBatch deletelog = new ApplicationLogPurgeBatch(query);//Initiate the Batch class
        ID batchID = Database.executeBatch(deletelog); //Call the batch class
	}
}