/**************************************************************************************************
Name : PL_MonthlyGoalCreationBatchSchedule
Description : This batch class created to schedule PL_MonthlyGoalCreationBatch
User Story : US619087
Date : 27 January 2016
Author : Animesh Datta 
**************************************************************************************************/

global class PL_MonthlyGoalCreationBatchSchedule implements Schedulable {
    /*
    * This method schedule batch class at specified time
    */
    global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        ///*String query='Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND Profile.Name IN: profileNameSet and UserPermissionsWorkDotComUserFeature = true';*/
        String queryString = ''; 
        if(System.Label.PL_MonthlyGoalCreationBatchScheduleQuery != Null){
            queryString = System.Label.PL_MonthlyGoalCreationBatchScheduleQuery;
        }       
        Integer batchSize = 1;
        if(System.Label.MonthlyGoalCreationBatchSize !=null && System.Label.MonthlyGoalCreationBatchSize.isNumeric()){
            batchSize = Integer.valueOf(System.Label.MonthlyGoalCreationBatchSize);
        }       
        PL_MonthlyGoalCreationBatch plMonthlyGoalBatch = new PL_MonthlyGoalCreationBatch(queryString); 
        if(!Test.isRunningTest()){database.executebatch(plMonthlyGoalBatch,batchSize);}
    }
}