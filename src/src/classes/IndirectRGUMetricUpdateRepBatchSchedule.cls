/**************************************************************************************************
*Name : IndirectRGUMetricUpdateRepBatchSchedule
*Description : This batch class created to schedule IndirectRGUMetricUpdateRepBatch
* User Story : US1024537(Indirect - Coach for Indirect - Retail Sales Rep - RGU Goal - Metric Targets and Actuals)
* Date : 19 April 2017
* Author : Animesh Datta
**************************************************************************************************/
global class IndirectRGUMetricUpdateRepBatchSchedule implements Schedulable {
    /*
    * This method schedule batch class at specified time
    */
    global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        String queryString = ''; 
        if(System.Label.IndirectRGUMetricUpdateRepBatchQuery != Null){
            queryString = System.Label.IndirectRGUMetricUpdateRepBatchQuery;
        }       
        Integer batchSize = 1;
        if(System.Label.IndirectRGUMetricUpdateRepBatchSize !=null && System.Label.IndirectRGUMetricUpdateRepBatchSize.isNumeric()){
            batchSize = Integer.valueOf(System.Label.IndirectRGUMetricUpdateRepBatchSize);
        }
        if(!Test.isRunningTest()){database.executebatch(new IndirectRGUMetricUpdateRepBatch(queryString),batchSize);}
    }
}