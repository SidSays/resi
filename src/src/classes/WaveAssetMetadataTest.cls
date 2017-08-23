/**
 * @description Test WaveAssetMetadata, thereby testing the extensions to WaveApiUtil
 * @author Salesforce Program Architect
 * @date 20170612
 */ 
@isTest
public class WaveAssetMetadataTest {
    @isTest 
    public static void testWaveAssetMetadata() {        
        /*
         * Assert that the custom objects targeted for storing Wave asset metadata have no data
         * (This is, of course, within the context of our test execution, with seeAllData = false (default)
         */ 
        AggregateResult preDashboards = [SELECT count(id) cnt FROM WaveDashboard__c];
        System.assertEquals(0, (Integer)preDashboards.get('cnt'));
        AggregateResult preDatasets = [SELECT count(id) cnt FROM WaveDataset__c];
        System.assertEquals(0, (Integer)preDatasets.get('cnt'));
        AggregateResult preLenses = [SELECT count(id) cnt FROM WaveLens__c];
        System.assertEquals(0, (Integer)preLenses.get('cnt'));
        /*
         * Populate the Wave Asset Metadata custom objects, leveraging the existing mocking framework for WaveApiUtil
		 * WaveAPIUtilHttpCalloutMock implements the Salesforce HttpCalloutMock interface, which intercepts HTTP calls and returns static JSON
		 * We enclose this top-level method with startTest and stopTest to force the @future method to complete, so we can assert on DML
         * (If we did not do this, the assertions would likely fail, for want of the DML being committed prior to asssertions)
         */ 
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new WaveAPIUtilHttpCalloutMock());
        WaveAssetMetadata.upsertWaveAssetMetadata();
		Test.stopTest();
        AggregateResult postDashboards = [SELECT count(id) cnt FROM WaveDashboard__c];
        System.assert((Integer)postDashboards.get('cnt') > 0);
        AggregateResult postDatasets = [SELECT count(id) cnt FROM WaveDataset__c];
        System.assert((Integer)postDatasets.get('cnt') > 0);
        AggregateResult postLenses = [SELECT count(id) cnt FROM WaveLens__c];
        System.assert((Integer)postLenses.get('cnt') > 0);
    }    
    /**
     * @description Test upsertWaveDashboardMetadata
     */ 
    @isTest
    public static void testUpsertWaveDashboardMetadata() {
        AggregateResult preDashboards = [SELECT count(id) cnt FROM WaveDashboard__c];
        System.assertEquals(0, (Integer)preDashboards.get('cnt'));
		Test.setMock(HttpCalloutMock.class, new WaveAPIUtilHttpCalloutMock());
        WaveAssetMetadata.upsertWaveDashboardMetadata();
        AggregateResult postDashboards = [SELECT count(id) cnt FROM WaveDashboard__c];
        System.assert((Integer)postDashboards.get('cnt') > 0);
    }
    
    /**
     * @description Test upsertWaveDatasetMetadata
     */    
    @isTest
    public static void testUpsertWaveDatasetMetadata() {
        AggregateResult preDatasets = [SELECT count(id) cnt FROM WaveDataset__c];
        System.assertEquals(0, (Integer)preDatasets.get('cnt'));
		Test.setMock(HttpCalloutMock.class, new WaveAPIUtilHttpCalloutMock());
        WaveAssetMetadata.upsertWaveDatasetMetadata();
        AggregateResult postDatasets = [SELECT count(id) cnt FROM WaveDataset__c];
        System.assert((Integer)postDatasets.get('cnt') > 0);
    }

    /**
     * @description Test upsertWaveLensMetadata
     */        
    @isTest
    public static void testUpsertWaveLensMetadata() {
        AggregateResult preLenses = [SELECT count(id) cnt FROM WaveLens__c];
        System.assertEquals(0, (Integer)preLenses.get('cnt'));
		Test.setMock(HttpCalloutMock.class, new WaveAPIUtilHttpCalloutMock());
		WaveAssetMetadata.upsertWaveLensMetadata();
        AggregateResult postLenses = [SELECT count(id) cnt FROM WaveLens__c];
        System.assert((Integer)postLenses.get('cnt') > 0);
    }
}