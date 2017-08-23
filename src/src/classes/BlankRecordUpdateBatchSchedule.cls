/******************************************************************************************
Name : BlankRecordUpdateBatchSchedule
Description : This batch class created to schedule BlankRecordUpdateBatch. This batch cab used to update any other object as well
User Story : US1164265
Date : 22 August 2017
Author : Animesh Datta 
*******************************************************************************************/
global class BlankRecordUpdateBatchSchedule implements Schedulable {
    /* 
        Description : This method schedule batch class at specified time
        User Story : US1164265
        Date : 22 August 2017
        Author : Animesh Datta
    */
    global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        /*String query='SELECT Id FROM Customer_Address__c WHERE Property_Code__c !=null AND Region__c != null';*/
        String queryString = ''; 
        if(System.Label.BlankRecordUpdateBatchQuery != Null){
            queryString = System.Label.BlankRecordUpdateBatchQuery;
        }       
        Integer batchSize = 200;
        if(System.Label.BlankRecordUpdateBatchSize !=null && System.Label.BlankRecordUpdateBatchSize.isNumeric()){
            batchSize = Integer.valueOf(System.Label.BlankRecordUpdateBatchSize);
        }       
        BlankRecordUpdateBatch recordUpdate = new BlankRecordUpdateBatch(queryString); 
        if(!Test.isRunningTest()){database.executebatch(recordUpdate,batchSize);}
    }
}