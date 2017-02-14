/**************************************************************************************************
Name : QM_AnnualBaselineContractorBatchSchedule
Description : This batch class created to schedule QM_AnnualBaselineContractorBatch
User Story : US776812
Date : 05 Oct 2016
Author : Animesh Datta
Last Modified By : 
**************************************************************************************************/

global class QM_AnnualBaselineContractorBatchSchedule implements Schedulable {
  /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        //String queryString='SELECT Id, Name, AE_Contractor__c, AE_Contractor__r.UserPermissionsWorkDotComUserFeature,AE_Contractor__r.Profile.Name, AE_Contractor__r.Name, Reporting_Manager__c, Region__c, Region_Mapping_Key__c, Region_Formula__c FROM Contractor_Region_Mapping__c WHERE AE_Contractor__r.Profile.name = \'XC AE Contractors\' AND AE_Contractor__r.UserPermissionsWorkDotComUserFeature = true AND AE_Contractor__r.isActive = true';
        String queryString = '';
        if(System.Label.QuotaAnnualBaselineBatchForContractorScheduleLabel != Null){
            queryString = System.Label.QuotaAnnualBaselineBatchForContractorScheduleLabel;
        }
        
        Integer batchSize=200;
        if(System.Label.QuotaAnnualBaselineBatchForContractorSize!=null && System.Label.QuotaAnnualBaselineBatchForContractorSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.QuotaAnnualBaselineBatchForContractorSize);
        }
        
        QM_AnnualBaselineContractorBatch quotaAnnualBaselineBatch = new QM_AnnualBaselineContractorBatch(queryString);
        if(!Test.isRunningTest()){ 
            database.executebatch(quotaAnnualBaselineBatch, batchSize);
        }
   }
}