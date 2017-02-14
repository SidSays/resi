//commented as the changes already included in Address Trigger
trigger AddressTriggerAfterUpdate on Customer_Address__c (after update) {
   /* TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('AddressTrigger');
    if(triggerSetting.isActive__c){
            if(Trigger.isAfter)
            {
                if(Trigger.isUpdate)
                {
                    AddressTriggerController.AddressShareAccess(Trigger.New);
                }
           }
    }*/
}