/**************************************************************************************************
Name : MDUPropertyriskStatusAutoSetSchedule 
Description : This Schedulable class created to schedule batch job that will auto set risk status of property (This shall be set nightly at 2am EST).   
User Story : 78
Date : 16 January 2015
Author : Ashish Sonawane
***************************************************************************************************/
global class MDUPropertyRiskStatusAutoSetSchedule implements Schedulable {
  /*
   * This method schedule batch able class at specified time
   */
   global void execute(SchedulableContext schedulableContext) {
        MDUPropertyRiskStatusAutoSetBatch propertyRatingBatch= new MDUPropertyRiskStatusAutoSetBatch(); 
        Integer batchSize=200;
        if(System.Label.XCPropertyRiskStatusBatchSize!=null && System.Label.XCPropertyRiskStatusBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.XCPropertyRiskStatusBatchSize);
        }
        Id batchId= database.executebatch(propertyRatingBatch, batchSize);
   }
}