trigger CaseTrigger on Case (before insert, before update, after insert, after update) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('CaseTrigger');
    if(triggerSetting != null && triggerSetting.isActive__c){
        if(trigger.isBefore){
            if(trigger.isInsert){
                CaseTriggerController.updateCases(null, trigger.new);
            }
            else if(trigger.isUpdate){
                CaseTriggerController.updateCases(trigger.oldMap, trigger.new);
            }
        }
        if(trigger.isAfter){
            if(trigger.isInsert){
                CaseTriggerController.fireAssignmentRule(trigger.new);
            }
            if(trigger.isUpdate){
              CaseTriggerController.caseRecordAccess(trigger.oldMap,trigger.new);
            }
        }
    }
}