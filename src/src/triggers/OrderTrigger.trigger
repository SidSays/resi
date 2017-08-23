trigger OrderTrigger on Order__c (before insert, before update) {
	TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('OrderTrigger');
	if(triggerSetting.isActive__c){
		if(trigger.isBefore){
			if(trigger.isInsert){
				OrderTriggerController.updateActivatedByOnOrder();
			}
			else if(trigger.isUpdate){
				OrderTriggerController.updateActivatedByOnOrder();
			}
		}
	}
}