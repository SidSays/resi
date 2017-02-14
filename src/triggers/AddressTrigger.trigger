trigger AddressTrigger on Customer_Address__c (before insert, before update, after insert, after update) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('AddressTrigger');
    if(triggerSetting.isActive__c){
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                AddressTerritoryHandler.addAddressToTerritoryOnInsert(Trigger.New);
                AddressTriggerController.setIsNewOnAddress(Trigger.new);
            }
            else if(Trigger.isUpdate){
               // AddressTerritoryHandler.addAddressToTerritoryOnUpdate(Trigger.New,Trigger.Old);
               AddressTriggerController.setFlagOnRemovingParentAddress(Trigger.New, Trigger.oldMap);
            }
            AddressTriggerController.setCheckboxes(Trigger.New);
            AddressTriggerController.setAddressDivisionAndDisconnected(Trigger.New); 
            AddressTriggerController.setPropertyToAddress(Trigger.New);
            AddressTriggerController.removePropertyFromAddress(Trigger.New);
            //AddressTerritoryHandler.updateTargetedIndicator(Trigger.New);
        }
        else{   
            if(Trigger.isInsert){
               // AddressTriggerController.shareAddressWithinRegionalGroups(Trigger.New);
            }
            if(Trigger.isUpdate){
                AddressTriggerController.AddressShareAccess(Trigger.New);
                //AddressTriggerController.updateAddressSharingOnRegionChange(Trigger.New, Trigger.oldMap);
                
            }    
        }
    }
}