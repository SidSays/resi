/*
* @description Upsert Wave Asset Metadata into Utility Objects for Wave Usage Reporting
* We upsert to accumulate Wave Asset Metadata to support hisotical reporting
* @author Salesforce Program Architect
* @date 2017-03-29
*/
public class WaveAssetMetadata {
    private static WaveAPIUtil wave;
    static {
        wave = WaveAPIUtil.getInstance();
    }
    /*
     * Provide a single method to get and upsert all relevant Wave Asset Metadata
	 * To achieve this:
	 * Step 1: Call the methods to get the data (i.e. the individual getWave<Asset>Metadata methods below)
	 *   These methods rely on the wave.getWaveAssetMetadata method to retrieve metadata from Wave via the Rest API
	 *   This method is recursive, which is a bit risky, in terms of recursively making API calls
	 *   Ideally, one would adopt a more future-proof batch apex paradigm, passing in nextPageUrl for each invocation
	 *   Practically, we can make 100 REST API calls per transaction
	 *   With a pageSize of 200, this code is save so long as we have less than 20,000 Wave assets
	 * Step 2: Upsert the results, so as not to co-mingle DML with API calls, which is not allowed

	*/ 
    @future (callout=true)
    public static void upsertWaveAssetMetadata() {
        // Get Wave Dashbaord Ids and Labels
        List<WaveDashboard__c> waveDashboardMetadata = getWaveDashboardMetadata();
        // Unescape HTML Characters - i.e. &amp; = & and &#39; = ‘ (apostrophe) and so on
        for(WaveDashboard__c wDashboard : waveDashboardMetadata){
            wDashboard.Name = wDashboard.Name.unescapeHtml4();
        }
        List<WaveDataset__c> waveDatasetMetadata = getWaveDatasetMetadata();
        // Unescape HTML Characters - i.e. &amp; = & and &#39; = ‘ (apostrophe) and so on
        for(WaveDataset__c wDataset : waveDatasetMetadata){
            wDataset.Name = wDataset.Name.unescapeHtml4();
        }
        List<WaveLens__c> waveLensMetadata = getWaveLensMetadata();
        // Unescape HTML Characters - i.e. &amp; = & and &#39; = ‘ (apostrophe) and so on
        for(WaveLens__c wLens : waveLensMetadata){
            wLens.Name = wLens.Name.unescapeHtml4();
        }
        upsert waveDashboardMetadata DashboardId__c;
        upsert waveDatasetMetadata DatasetId__c;
        upsert waveLensMetadata LensId__c;		
    }
	// Provide a method to get and upsert Wave Asset Metadata for Dashboards
    public static List<WaveDashboard__c> getWaveDashboardMetadata() {
        Map<String,String> waveMetadataMap;
        List<WaveDashboard__c> waveMetadata = new List<WaveDashboard__c>();
        waveMetadataMap = wave.getWaveAssetMetadata('dashboards');
        for(String assetId : waveMetadataMap.keySet()) {
            WaveDashboard__c metadataRec = new WaveDashboard__c();
            metadataRec.DashboardId__c = assetId;
            metadataRec.Name = waveMetadataMap.get(assetId);
            waveMetadata.add(metadataRec);
        }
		return waveMetadata;        
    }
    public static void upsertWaveDashboardMetadata() {
		List<WaveDashboard__c> waveDashboardMetadata = getWaveDashboardMetadata();
        upsert waveDashboardMetadata DashboardId__c;
    }
  	// Provide a method to get and upsert Wave Asset Metadata for Datasets
    public static List<WaveDataset__c> getWaveDatasetMetadata() {
        Map<String,String> waveMetadataMap;
        List<WaveDataset__c> waveMetadata = new List<WaveDataset__c>();
        waveMetadataMap = wave.getWaveAssetMetadata('datasets');
        for(String assetId : waveMetadataMap.keySet()) {
            WaveDataset__c metadataRec = new WaveDataset__c();
            metadataRec.DatasetId__c = assetId;
            metadataRec.Name = waveMetadataMap.get(assetId);
            waveMetadata.add(metadataRec);
        }
		return waveMetadata;        
    }
    public static void upsertWaveDatasetMetadata() {
		List<WaveDataset__c> waveDatasetMetadata = getWaveDatasetMetadata();
        upsert waveDatasetMetadata DatasetId__c;
    }
	// Provide a method to get and upsert Wave Asset Metadata for Lenses
    public static List<WaveLens__c> getWaveLensMetadata() {
        Map<String,String> waveMetadataMap;
        List<WaveLens__c> waveMetadata = new List<WaveLens__c>();
        waveMetadataMap = wave.getWaveAssetMetadata('lenses');
        for(String assetId : waveMetadataMap.keySet()) {
            WaveLens__c metadataRec = new WaveLens__c();
            metadataRec.LensId__c = assetId;
            metadataRec.Name = waveMetadataMap.get(assetId);
            waveMetadata.add(metadataRec);
        }
		return waveMetadata;        
    }
    public static void upsertWaveLensMetadata() {
		List<WaveLens__c> waveLensMetadata = getWaveLensMetadata();
        upsert waveLensMetadata LensId__c;
    }
}