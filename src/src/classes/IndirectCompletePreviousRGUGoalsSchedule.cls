/**************************************************************************************************
Name : IndirectCompletePreviousRGUGoalsSchedule
Description : This batch class created to schedule IndirectCompletePreviousRGUGoalsBatch
User Story : 
Date : 19-APR-2017
Author : Tejaswini kasar
***************************************************************************************************/
global class IndirectCompletePreviousRGUGoalsSchedule implements Schedulable{
 /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        //String query='Select Id,Name,profile.name,Region__c from User where  IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true ';   
        String queryString = '';
               if(System.Label.IndirectCompletePreviousRguGoalsQuery != Null){
            queryString = System.Label.IndirectCompletePreviousRguGoalsQuery;
        }
        Integer batchSize=200;
        if(System.Label.IndirectCompletePreviousRguGoalsBatchSize!=null && System.Label.IndirectCompletePreviousRguGoalsBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.IndirectCompletePreviousRguGoalsBatchSize);
        }
        IndirectCompletePreviousRGUGoalsBatch inst= new IndirectCompletePreviousRGUGoalsBatch(queryString);
        if(!Test.isRunningTest()){ 
            database.executebatch(inst, batchSize);
        }    
   }
}