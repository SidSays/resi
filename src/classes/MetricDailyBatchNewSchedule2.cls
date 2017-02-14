/**************************************************************************************************
Name : MetricDailyBatchNewSchedule2
Description : This batch class created to schedule MetricDailyUpdateBatchNew
Date : 15 Aug 2015
Author : Ritesh Saxena 
***************************************************************************************************/
global class MetricDailyBatchNewSchedule2 implements Schedulable {
  /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        String queryString = '';
        //String queryString = 'SELECT Id From User WHERE IsActive = True AND ProfileId =: DIRECT_SALES_REPR_PROFILE_ID AND  UserPermissionsWorkDotComUserFeature = true AND Region__c IN ('Florida Region','Greater Chicago Market','Portland/Salem Market','California Market','Houston Market','Seattle Market','Twin Cities Market','Mile High Region','Salt Lake City Market','Heartland Region','Greater Boston Market')'; 
        
        if(System.Label.MetricDailyBatchQueryNew2!= Null){
            queryString = System.Label.MetricDailyBatchQueryNew2;
        }
        Integer batchSize=200;
        if(System.Label.MetricDailyNewBatchSize2!=null && System.Label.MetricDailyNewBatchSize2.isNumeric()){
            batchSize=Integer.valueOf(System.Label.MetricDailyNewBatchSize2);
        }
        MetricDailyUpdateBatchNew inst= new MetricDailyUpdateBatchNew(queryString); 
        database.executebatch(inst, batchSize);
   }
}