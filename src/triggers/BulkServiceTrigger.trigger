/** **********************************************************************
* Name: BulkServiceTrigger
* Author: Ashish Sonawane
* User Story : 087 
* Description: Trigger on custom Bulk_Service__c Object to create next bulk service if bulk service implemented.
    Date                 PRJ/DFCT/ENHC#            Summary of Changes 
  -------------         -----------------       ------------------------------
  23-January-2015        Comcast Resi(MDU)              Initial Release 
  
**************************************************************************/

trigger BulkServiceTrigger on Bulk_Service__c (after update,after insert) {
    try{
        TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('BulkServiceTrigger');
        if(triggerSetting.isActive__c){
            if(Trigger.IsAfter && Trigger.IsUpdate){
                BulkServiceTriggerSequencer.afterInsertOperation();
            } 
            else if(Trigger.IsAfter && Trigger.IsInsert){
                BulkServiceTriggerSequencer.afterInsertOperation();
            } 
        }   
    }
    catch(Exception e)
    {
        System.debug('>>>>>>>>>>>>>Error Message'+e.getMessage());
    }
}