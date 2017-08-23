/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-23
 * Enrich records with Dashbaord Labels via Dashboard Id lookup
 */ 
trigger WaveLensUsageTrigger on WaveLensUsage__c (before insert) {
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert){
            // Add Lens Labels to Records via Lens Id lookup
            WaveLensUsageTriggerHandler.addLensLabelsToRecords(trigger.new);
        }
    }
}