/**************************************************************************************************
Name : IndirectMonthlyGoalCreationBatchSchedule
Description : This batch class created to schedule IndirectMonthlyGoalCreationBatch
User Story : US1024513/ US1041420
Date : 22/03/2017
Author : Tejaswini Kasar
***************************************************************************************************/
global class IndirectMonthlyGoalCreationBatchSchedule implements Schedulable{
 /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        //String query='Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c from User where  IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true ';   
        String queryString = '';
        if(System.Label.IndirectMonthlyGoalCreationBatchQueryStringLabel != Null){
            queryString = System.Label.IndirectMonthlyGoalCreationBatchQueryStringLabel;
        }
        Integer batchSize=200;
        if(System.Label.IndirectMonthlyGoalCreationBatchSize!=null && System.Label.IndirectMonthlyGoalCreationBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.IndirectMonthlyGoalCreationBatchSize);
        }
        IndirectMonthlyGoalCreationBatch inst= new IndirectMonthlyGoalCreationBatch(queryString); 
        if(!Test.isRunningTest()){
            database.executebatch(inst, batchSize);
        }
   }    
}