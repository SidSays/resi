/**************************************************************************************************
Name : RGUMetricResetBatchSchedule
Description : This batch class created to schedule RGUMetricResetBatch
Date : 19 Aug 2015
Author : Ritesh Saxena 
***************************************************************************************************/
global class RGUMetricResetBatchSchedule implements Schedulable {
  /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        String queryString = '';
        Boolean isWest = false;
        //String query= 'SELECT Id, Status, DueDate, CurrentValue FROM Metric where Goal.RecordTypeId=: GOAL_DIRECTSALES_RECORD_ID and Goal.Name like \'%RGU%\' and DueDate =: BYWEEK_COMMISION_END_DATE ';
        
        if(System.Label.RGUMetricResetBatchQuery!= Null){
            queryString = System.Label.RGUMetricResetBatchQuery;
        }
        Integer batchSize=200;
        if(System.Label.RGUMetricResetBatchSize!=null && System.Label.RGUMetricResetBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.RGUMetricResetBatchSize);
        }
        if(!Test.isRunningTest()){RGUMetricResetBatch inst= new RGUMetricResetBatch(queryString,isWest); database.executebatch(inst, batchSize);}
   }
}