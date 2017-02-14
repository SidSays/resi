/**************************************************************************************************
Name : MDUPropertyRatingAutoSetBatchSchedule
Description : This Schedulable class created to schedule batch job that will auto set Property Type of property   
User Story : 76
Date : 16 January 2015
Author : Ashish Sonawane
***************************************************************************************************/

global class MDUPropertyRatingAutoSetBatchSchedule implements Schedulable {
   /*
   * This method schedule batchable class at specified time
   */
   global void execute(SchedulableContext schedulableContext) {
        MDUPropertyRatingAutoSetBatch propertyRatingBatch = new MDUPropertyRatingAutoSetBatch(); 
        Integer batchSize=200;
        if(System.Label.XCPropertyRatingBatchSize!=null && System.Label.XCPropertyRatingBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.XCPropertyRatingBatchSize);
        }
        database.executebatch(propertyRatingBatch, batchSize);
   }
}