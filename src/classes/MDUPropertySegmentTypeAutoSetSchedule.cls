/**************************************************************************************************
Name : MDUPropertySegmentTypeAutoSetSchedule
Description : This Schedulable class created to schedule batch job that will auto set segmentation status of property (This shall be set on the 1st day of each month at 11pm EST).   
User Story : 78
Date : 16 January 2015
Author : Ashish Sonawane
***************************************************************************************************/

global class MDUPropertySegmentTypeAutoSetSchedule implements Schedulable {
  /*
   * This method schedule batch able class at specified time
   */
    global void execute(SchedulableContext schedulableContext) {
        MDUPropertySegmentationTypeAutoSetBatch propertySegmentationBatch = new MDUPropertySegmentationTypeAutoSetBatch(); 
        Integer batchSize=200;
        if(System.Label.XCPropertySegmentTypeBatchSize!=null && System.Label.XCPropertySegmentTypeBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.XCPropertySegmentTypeBatchSize);
        } 
        database.executebatch(propertySegmentationBatch, batchSize);
    }
}