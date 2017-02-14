/**************************************************************************************************
Name : MduContractAutoRenewBatchSchedule
Description : This Schedulable class created to schedule batch job that will reschedule contract status (This shall be set nightly at midnight (must run before Risk Status).).   
User Story : 24
Date : 16 January 2015
Author : Ashish Sonawane
***************************************************************************************************/

global class MDUContractAutoRenewBatchSchedule implements Schedulable {
  /*
   * This method schedule batch able class at specified time
   */
   global void execute(SchedulableContext schedulableContext) {
        MduContractAutoRenewBatch contractAutoRenewBatch = new MduContractAutoRenewBatch(); 
        Integer batchSize=200;
        if(System.Label.XCContractAutoRenewBatchSize!=null && System.Label.XCContractAutoRenewBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.XCContractAutoRenewBatchSize);
        }
        database.executebatch(contractAutoRenewBatch,batchSize);
   }
}