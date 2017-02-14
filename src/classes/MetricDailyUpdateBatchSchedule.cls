/**************************************************************************************************
Name : MetricDailyUpdateBatchSchedule
Description : This batch class created to schedule MduContractAutoRenewBatch
User Story : US491510
Date : 30 July 2015
Author : Ashish Sonawane
Last Modified By : 1. Suchita Sharma(Constructor defined for batch which should take query string as parameter for execution.)  
                   2. Ashish Sonawane 22/Oct/2015 use custom label to store query string     
***************************************************************************************************/

global class MetricDailyUpdateBatchSchedule implements Schedulable {
  /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
       // The query string passed while batch is executed.
       //String queryString = 'SELECT Timestamp__c, Knocked_Date__c , Id, CreatedDate, Hour_of_Day__c, Off_Turf__c, Disposition__c, HSI_Sold__c, Video_Sold__c, Voice_Sold__c, XH_Sold__c, OwnerId, Owner.ProfileId FROM Task WHERE   Owner.ProfileId =: DIRECT_SALES_REPR_PROFILE_ID AND RecordTypeId =: knockRecordTypeId AND CreatedDate >= :BYWEEK_COMMISION_START_DATE AND CreatedDate < :taskCommsionEndDate';  
        String queryString = ''; 
        if(System.Label.MetricDailyBatchQueryStringLabel != Null){
            queryString = System.Label.MetricDailyBatchQueryStringLabel;
        }
        Integer batchSize=200;
        if(System.Label.MetricDailyUpdateBatchSize!=null && System.Label.MetricDailyUpdateBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.MetricDailyUpdateBatchSize);
        }
        MetricDailyUpdateBatch inst= new MetricDailyUpdateBatch(queryString); 
        database.executebatch(inst, batchSize);
   }
}