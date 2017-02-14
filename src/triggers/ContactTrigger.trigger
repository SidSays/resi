trigger ContactTrigger on Contact (after insert, after update, before insert, before update) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('ContactTrigger');
    /*if(triggerSetting.isActive__c){
        if(trigger.isAfter){
            if(trigger.isInsert){
                ContactTriggerController.populateContactOnAccount();
            }
            else if(trigger.isUpdate){
                ContactTriggerController.updateAccountName();
            }  
        }
    }*/
    
   if(triggerSetting != null && triggerSetting.isActive__c){
        if(trigger.isBefore){
            ContactTriggerController.updateBirthdate(Trigger.New);
        }
    }
}