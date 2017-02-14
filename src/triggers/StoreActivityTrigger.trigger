/**
*   Trigger for Store Activity object
*
*   @author Sahil Grover    <sgrover@acumensolutions.com>
*/
trigger StoreActivityTrigger on Store_Activity__c (before insert, after insert, before update, after update) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('StoreActivityTrigger');
    if(triggerSetting.isActive__c){
        if (Trigger.IsBefore) {
            if (Trigger.IsInsert || Trigger.IsUpdate) {
                StoreActivityTriggerHelper.populateActivityStore(Trigger.New);
            }
        }
    }
    
}