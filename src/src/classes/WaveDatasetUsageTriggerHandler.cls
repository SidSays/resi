/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-22
 * Implementation for WaveDatasetUsageTrigger
 */ 
public class WaveDatasetUsageTriggerHandler {
    public static void addDatasetLabelsToRecords (List<WaveDatasetUsage__c> usageRecords) {
        // Build a map of Dataset Ids, Labels
        Map<String, String> datasetIdLabelMap = new Map<String, String>();
        for (WaveDataset__c wD : [SELECT DatasetId__c, Name FROM WaveDataset__c]) {
            datasetIdLabelMap.put(wD.DatasetId__c, wD.Name);
        }
		// Enrich Trigger.New Records with Dashboard Label via Dashboard Id lookup
        for (WaveDatasetUsage__c uRec : usageRecords) {
            uRec.DatasetName__c = datasetIdLabelMap.get(uRec.DatasetId__c);
        }  
    }
}