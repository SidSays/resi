/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-24
 * Enrich records with a multitude of values
 */ 
trigger WaveUserTrigger on WaveUser__c (before insert) {
    if(Trigger.isBefore) {
        if(Trigger.isInsert){
            WaveUserTriggerHandler.enrichRecords(trigger.new);
        }
    }
}