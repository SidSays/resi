trigger OrderLineItemTrigger on Order_Line_Item__c (after insert, after update) {
	TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('OrderLineItemTrigger');
	if(triggerSetting.isActive__c){
		if(trigger.isAfter){
			if(trigger.isInsert){
				OrderLineItemTriggerController.populateActivityStatusOnOrder();
			}
			else if(trigger.isUpdate){
				OrderLineItemTriggerController.populateActivityStatusOnOrder();
			}
		}
	}
}