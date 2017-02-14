trigger LeadTrigger on Lead (before insert, before update, after update) {
	TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('LeadTrigger');
	if(triggerSetting.isActive__c){
		if(trigger.isBefore){
			if(trigger.isInsert){
				LeadTriggerController.updateActivatedByOnlead();
			}
			else if(trigger.isUpdate){
				LeadTriggerController.updateActivatedByOnlead();
			}
		}
		else {
			if(trigger.isUpdate){
				LeadTriggerController.updateAccount(trigger.new);
			}
		}
	}
}