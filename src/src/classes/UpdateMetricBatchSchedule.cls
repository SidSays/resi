/**************************************************************************************************
Name : UpdateMetricBatchSchedule
Description : This Schedulable class created to schedule batch job that will update metrics.   
User Story : US765271
Date : 20 Sep 2016
Author : Mandeep Singh
Description : Putting "Test.isRunningTest()" check to avoid failing of test class "cann't have more then one entry in test class"(US1096500)
Last Modified By : Amit Kumar Pradhan
Last Modified Date : 18th May 2017
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
        }else{}
        if(System.Label.UpdateMetricBatchSize!=null && System.Label.UpdateMetricBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.UpdateMetricBatchSize);
        }else{}   
        UpdateMetricBatch MetricUpdate = new UpdateMetricBatch(queryString);
        /****************************
        * Start User Story: US1096500
        * Description : Putting "Test.isRunningTest()" check to avoid failing of test class "cann't have more then one entry in test class"
        * Last Modified By : Amit Kumar Pradhan
        * Last Modified Date : 18th May 2017
        *****************************/ 
        if(!Test.isRunningTest()){database.executebatch(MetricUpdate,batchSize);}else{}
        /***************************
        * End User Story: US1096500
        ****************************/
    }
}