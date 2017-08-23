/**************************************************************************************************
Name : MduContractWriteBackSchedule
Description : This Schedulable class use to schedule  MDU_ContractWriteBack class on hourly basis
User Story : 
Date : 21 March 2015
Author : Ashish Sonawane
***************************************************************************************************/
global class MDUContractWriteBackSchedule implements Schedulable {
   global final string BATCHNAME = 'ContractBatch';
  /*
   * This method schedule MDU_ContractWriteBack class createContractDataOperation() method on hourly basis
   */
   global void execute(SchedulableContext schedulableContext) {                    
        // Schedule WriteBack Batch job
        MduContractWriteBackBatch writeBackBatch = new  MduContractWriteBackBatch();
        Database.executeBatch(writeBackBatch);                                             
    }
}