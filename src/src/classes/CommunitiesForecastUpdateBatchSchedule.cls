/**************************************************************************************************
Name : CommunitiesForecastUpdateBatchSchedule
Description : This batch class created to schedule CommunitiesForecastUpdateBatch
User Story : US670614
Date : 25 April 2016
Author : Sucheta Verma 
**************************************************************************************************/

global class CommunitiesForecastUpdateBatchSchedule implements Schedulable{
    /*
    * This method schedule batch class at specified time
    */
    
     global void execute(SchedulableContext schedulableContext){
        String queryString = ''; 
        if(System.Label.CommunitiesForecastUpdateBatchScheduleQuery != Null){
            queryString = System.Label.CommunitiesForecastUpdateBatchScheduleQuery;
        }
        
        Integer batchSize=200;
        if(System.Label.CommunitiesForecastUpdateBatchSize!=null && System.Label.CommunitiesForecastUpdateBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.CommunitiesForecastUpdateBatchSize);
        }
        
        CommunitiesForecastUpdateBatch MetricUnitsUpdate = new CommunitiesForecastUpdateBatch(queryString);
        if(!Test.isRunningTest()){  
            database.executebatch(MetricUnitsUpdate,batchSize);
        }    
     }
    
}