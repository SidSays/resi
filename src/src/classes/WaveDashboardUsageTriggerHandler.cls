/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-22
 * Implementation for WaveDashboardUsageTrigger
 */ 
public class WaveDashboardUsageTriggerHandler {
    public static void addDashboardLabelsToRecords (List<WaveDashboardUsage__c> usageRecords) {
        // Build a map of Dashboard Ids, Labels
        Map<String, String> dashboardIdLabelMap = new Map<String, String>();
        for (WaveDashboard__c wD : [SELECT DashboardId__c, Name FROM WaveDashboard__c]) {
            dashboardIdLabelMap.put(wD.DashboardId__c, wD.Name);
        }
		// Enrich Trigger.New Records with Dashboard Label via Dashboard Id lookup
        for (WaveDashboardUsage__c uRec : usageRecords) {
            uRec.DashboardName__c = dashboardIdLabelMap.get(uRec.DashboardId__c);
        }  
    }
}