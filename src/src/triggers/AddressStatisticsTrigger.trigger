trigger AddressStatisticsTrigger on Address_Statistics__c (before insert, before update){
	TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('AddressStatisticsTrigger');
	if(triggerSetting.isActive__c){
        if(trigger.isUpdate){
		  AddressStatisticsTriggerController.preventAddressLocking(trigger.new);
		}
	}
}