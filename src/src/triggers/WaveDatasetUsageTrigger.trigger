/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-23
 * Enrich records with Dashbaord Labels via Dashboard Id lookup
 */ 
trigger WaveDatasetUsageTrigger on WaveDatasetUsage__c (before insert) {
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert){
            // Add Dataset Labels to Records via Dataset Id lookup
            WaveDatasetUsageTriggerHandler.addDatasetLabelsToRecords(trigger.new);
        }
    }
}