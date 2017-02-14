/**************************************************************************************************
Name : CreateSdmAsmActivityGoalBatchSchedule
Description : This batch class created to schedule CreateSdmAsmActivityGoalBatch
User Story : US491514
Date : 02 December 2015
Author : Pranjal Singh
***************************************************************************************************/
global class CreateSdmAsmActivityGoalBatchSchedule implements Schedulable{
 /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        //String query='Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c, ManagerId,Manager.ManagerId from User where  IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true ';    
        String queryString = ''; 
        if(System.Label.CreateSdmAsmActivityGoalStringLabel != Null){
            queryString = System.Label.CreateSdmAsmActivityGoalStringLabel;
        }
        Integer batchSize=200;
        if(System.Label.SdmAsmActivityGoalBatchSize!=null && System.Label.SdmAsmActivityGoalBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.SdmAsmActivityGoalBatchSize);
        }
        CreateSdmAsmActivityGoalBatch inst= new CreateSdmAsmActivityGoalBatch(queryString); 
        Id batchId= database.executebatch(inst, batchSize);
   }
}