/**************************************************************************************************
Name : DeletePropertyBatchSchedule
Description : This Schedulable class created to schedule batch job that will delete property.   
User Story : US727101
Date : 10 July 2016
Author : Mandeep Singh
***************************************************************************************************/


global class DeletePropertyBatchSchedule implements Schedulable {
    /*
    * This method schedule batch class at specified time
    */
    global void execute(SchedulableContext schedulableContext){
        
        String queryString = ''; 
        Integer batchSize=200;
        if(System.Label.DeletePropertyBatchLabel!= Null){
            queryString = System.Label.DeletePropertyBatchLabel;
        }
        if(System.Label.DeletePropertyBatchSize!=null && System.Label.DeletePropertyBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.DeletePropertyBatchSize);
        }   
        DeletePropertyBatch DeleteProperty = new DeletePropertyBatch(queryString); 
        database.executebatch(DeleteProperty,batchSize);
    }
}