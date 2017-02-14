/********************************************************************************************************************************
Name : MetricDailyUpdateBatchSchedule2
Description : This batch class created to schedule MetricDailyUpdateBatch based on Knock data for specified regions
Due to sequential processing of Goal trigger (SFDC design limitation), multiple schedulers are created MetricDailyUpdateBatch
Author : Ritesh Saxena 
*********************************************************************************************************************************/

global class MetricDailyUpdateBatchSchedule2 implements Schedulable {
  /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
       // The query string passed while batch is executed.
       //String queryString = 'SELECT Timestamp__c, Knocked_Date__c , Id, CreatedDate, Hour_of_Day__c, Off_Turf__c, Disposition__c, HSI_Sold__c, Video_Sold__c, Voice_Sold__c, XH_Sold__c, OwnerId, Owner.ProfileId FROM Task WHERE   Owner.ProfileId =: DIRECT_SALES_REPR_PROFILE_ID AND RecordTypeId =: knockRecordTypeId AND CreatedDate >= :BYWEEK_COMMISION_START_DATE AND CreatedDate < :taskCommsionEndDate';  
        String queryString = ''; 
        if(System.Label.MetricDailyBatchQueryString2 != Null){
            queryString = System.Label.MetricDailyBatchQueryString2;
        }
        Integer batchSize=200;
        if(System.Label.MetricDailyUpdateBatchSize2!=null && System.Label.MetricDailyUpdateBatchSize2.isNumeric()){
            batchSize=Integer.valueOf(System.Label.MetricDailyUpdateBatchSize2);
        }
        MetricDailyUpdateBatch inst= new MetricDailyUpdateBatch(queryString); 
        database.executebatch(inst, batchSize);
   }
}