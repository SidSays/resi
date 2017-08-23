/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-22
 * Enrich records with Dashbaord Labels via Dashboard Id lookup
 */ 
trigger WaveDashboardUsageTrigger on WaveDashboardUsage__c (before insert) {
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert){
            // Add Dashboard Labels to Records via Dashboard Id lookup
            WaveDashboardUsageTriggerHandler.addDashboardLabelsToRecords(trigger.new);
        }
    }
}