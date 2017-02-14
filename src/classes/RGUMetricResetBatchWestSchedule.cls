/**************************************************************************************************
Name : RGUMetricResetBatchWestSchedule
Description : This batch class created to schedule RGUMetricResetBatch for West Division
Date : 02 Jan 2017
Author : Animesh Datta
***************************************************************************************************/
global class RGUMetricResetBatchWestSchedule implements Schedulable {
  /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        String queryString = '';
        Boolean isWest = true;
        //String query= 'SELECT Id, Status, DueDate, CurrentValue FROM Metric where Goal.RecordTypeId=: GOAL_DIRECTSALES_RECORD_ID and Goal.Name like \'%RGU%\' and DueDate =: BYWEEK_COMMISION_END_DATE ';
        
        if(System.Label.RGUMetricResetBatchQueryWest!= Null){
            queryString = System.Label.RGUMetricResetBatchQueryWest;
        }
        Integer batchSize=200;
        if(System.Label.RGUMetricResetBatchSizeWest!=null && System.Label.RGUMetricResetBatchSizeWest.isNumeric()){
            batchSize=Integer.valueOf(System.Label.RGUMetricResetBatchSizeWest);
        }
        if(!Test.isRunningTest()){RGUMetricResetBatch inst= new RGUMetricResetBatch(queryString,isWest); database.executebatch(inst, batchSize);}
   }
}