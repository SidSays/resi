/**************************************************************************************************
Name : QM_QuotaAnnualBaselineBatchSchedule
Description : This batch class created to schedule QM_QuotaAnnualBaselineBatch
User Story : US481446
Date : 17 Aug 2015
Author : Suchita Sharma
Last Modified By : Suchita Sharma(Constructor defined for batch which should take query string as parameter for execution.)  
**************************************************************************************************/

global class QM_QuotaAnnualBaselineBatchSchedule implements Schedulable {
  /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        //String query='Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND Profile.Name IN: profileNameSet and UserPermissionsWorkDotComUserFeature = true';
        String queryString = ''; 
        if(System.Label.QuotaAnnualBaselineBatchScheduleLabel != Null){
            queryString = System.Label.QuotaAnnualBaselineBatchScheduleLabel;
        }
        
        Integer batchSize=200;
        if(System.Label.QuotaAnnualBaselineBatchSize!=null && System.Label.QuotaAnnualBaselineBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.QuotaAnnualBaselineBatchSize);
        }
        
        QM_QuotaAnnualBaselineBatch quotaAnnualBaselineBatch = new QM_QuotaAnnualBaselineBatch(queryString);
        if(!Test.isRunningTest()){ 
            database.executebatch(quotaAnnualBaselineBatch, batchSize);
        }    
   }
}