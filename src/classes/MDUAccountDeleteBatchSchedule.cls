/**************************************************************************************************
Name : MDUAccountDeleteBatchSchedule
Description : This Schedulable class created to schedule batch job that will autodelete account
User Story : 78
Date : 16 January 2015
Author : Ashish Sonawane
***************************************************************************************************/

global class MDUAccountDeleteBatchSchedule implements Schedulable {
  /*
   * This method schedule batch able class at specified time
   */
   global void execute(SchedulableContext schedulableContext) {
        MDUAccountDeleteBatch propertyAccountDeleteBatch = new MDUAccountDeleteBatch();
        Integer batchSize=200;
        if(System.Label.XCAccountDeleteBatchSize!=null && System.Label.XCAccountDeleteBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.XCAccountDeleteBatchSize);
        } 
        database.executebatch(propertyAccountDeleteBatch, batchSize);
   }
}