/************************************************************************************************
*Author: Apurva Gandhi, Accenture
*Description:This class calls UpdateOrderLineItemBatch 
*param: SchedulableContext.
*Request id:456 (Develop batch job to update existing records with the new Recon Activity Status.)
*Date: 2-Dec-2013
**************************************************************************************************/
global with sharing class UpdateOrderLineItemBatchSchedulable implements Schedulable {
     
    global void execute(SchedulableContext schContext){
    ID batchProcessId = Database.executeBatch(new UpdateOrderLineItembatch());
    }
}