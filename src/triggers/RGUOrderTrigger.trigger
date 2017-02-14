/**
 * Trigger for the RGU order object
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 11/25/14
 */

trigger RGUOrderTrigger on RGU_Order__c (before insert, before update) {
	TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('RGUOrderTrigger');
	if (triggerSetting.isActive__c) {
		if (Trigger.isBefore) {
			if (Trigger.isInsert || Trigger.isUpdate) {
				RGUOrderTriggerHelper.associateAccount(Trigger.New);
			}
		}
	}
}