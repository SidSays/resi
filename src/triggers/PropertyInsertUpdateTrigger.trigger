/*
* Name: PropertyInsertUpdateTrigger
* Description: To execute custom logic on property like apex sharing and customized behaviour via apex classes
*/
trigger PropertyInsertUpdateTrigger on MDU_Property__c (after insert,after update) {
   try{
     TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('PropertyInsertUpdateTrigger');
     if(triggerSetting.isActive__c){
       if(trigger.isAfter) {           
          if(trigger.isUpdate || trigger.isInsert){
             SharePropertyWithCAR.sharePropertyWithCAR(trigger.old,trigger.new,Trigger.isUpdate);
             // US724346: Communities: Opportunity Read Only Access to the property's XC regional public group
             OpportunityShares oppShr = new OpportunityShares();      
             oppShr.recalculatePropertyShares(trigger.oldMap,Trigger.newMap);
            }
       }     
     }  
   }catch (System.NullPointerException e) {}       
}