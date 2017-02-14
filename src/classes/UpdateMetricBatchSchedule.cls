/**************************************************************************************************
Name : UpdateMetricBatchSchedule
Description : This Schedulable class created to schedule batch job that will update metrics.   
User Story : US765271
Date : 20 Sep 2016
Author : Mandeep Singh
***************************************************************************************************/


global class UpdateMetricBatchSchedule implements Schedulable {
    /*
    * This method schedule batch class at specified time
    */
    global void execute(SchedulableContext schedulableContext){
        
        String queryString = ''; 
        Integer batchSize=200;
        if(System.Label.UpdateMetricBatchLabel!= Null){
            queryString = System.Label.UpdateMetricBatchLabel;
        }
        if(System.Label.UpdateMetricBatchSize!=null && System.Label.UpdateMetricBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.UpdateMetricBatchSize);
        }   
        UpdateMetricBatch MetricUpdate = new UpdateMetricBatch(queryString); 
        database.executebatch(MetricUpdate,batchSize);
    }
}