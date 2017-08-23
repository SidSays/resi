/*
 * @description Used to provide a hook to schedule the WaveAssetMetadata.upserWaveAssetMetadata method
 * @author Salesforce Program Architect
 * @date 20170612
 */ 
global class WaveAssetMetadataSchedulable implements Schedulable {
    global void execute (SchedulableContext SC) {
        WaveAssetMetadata.upsertWaveAssetMetadata();
    }
}