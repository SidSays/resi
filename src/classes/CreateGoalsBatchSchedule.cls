/**************************************************************************************************
Name : CreateGoalsBatchSchedule
Description : This batch class created to schedule CreateGoalsBatch
User Story : US491514
Date : 27 July 2015
Author : Rahul Prabhakar
Last Modified By : 1. Suchita Sharma(Constructor defined for batch which should take query string as parameter for execution.)  
                   2. Ashish Sonawane 22/Oct/2015 use custom label to store query string  
***************************************************************************************************/
global class CreateGoalsBatchSchedule implements Schedulable{
 /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        //String query='Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c, ManagerId,Manager.ManagerId from User where  IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true ';   
        String queryString = '';
        Boolean isWest = false;
        if(System.Label.CreateGoalsBatchQueryStringLabel != Null){
            queryString = System.Label.CreateGoalsBatchQueryStringLabel;
        }
        Integer batchSize=200;
        if(System.Label.CreateGoalsBatchSize!=null && System.Label.CreateGoalsBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.CreateGoalsBatchSize);
        }
        if(!Test.isRunningTest()){
            CreateGoalsBatch inst= new CreateGoalsBatch(queryString,isWest); 
            database.executebatch(inst, batchSize);
        }
        // Added to run the scheduler only once and execute again after 14 days from CreateGoalsBatch finish call.
        system.abortJob(schedulableContext.getTriggerId());
   }
}