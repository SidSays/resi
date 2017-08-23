/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-23
 * Implementation for WaveLensUsageTrigger
 */ 
public class WaveLensUsageTriggerHandler {
    public static void addLensLabelsToRecords (List<WaveLensUsage__c> usageRecords) {
        // Build a map of Dashboard Ids, Labels
        Map<String, String> lensIdLabelMap = new Map<String, String>();
        for (WaveLens__c wL : [SELECT LensId__c, Name FROM WaveLens__c]) {
            lensIdLabelMap.put(wL.LensId__c, wL.Name);
        }
		// Enrich Trigger.New Records with Dashboard Label via Dashboard Id lookup
        for (WaveLensUsage__c uRec : usageRecords) {
            uRec.LensName__c = lensIdLabelMap.get(uRec.LensId__c);
        }  
    }
}