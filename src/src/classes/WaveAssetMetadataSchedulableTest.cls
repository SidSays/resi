/*
 * @description Test WaveAssetMetadataSchedulable
 * @author Salesforce Program Architect
 * @date 20170616
 */ 
@isTest
public class WaveAssetMetadataSchedulableTest {
    @isTest static void testWaveAssetMetadataSchedulable() {        
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
         * Populate the custom objects targeted for storing Wave asset metadata
		 * Leverage the existing mocking framework created for WaveApiUtil
		 * WaveAPIUtilHttpCalloutMock implements the Salesforce HttpCalloutMock interface
		 * HTTP callouts during testing will be intercepted by WaveAPIUtilHttpCalloutMock
		 * Contrived HTTP/JSON responses will be returned, which will be suitable for our purposes
		 */ 
		Test.setMock(HttpCalloutMock.class, new WaveAPIUtilHttpCalloutMock());
        /*
         * We enclose the execute method with startTest and stopTest to force the @future method to complete, so we can assert on DML
         * (If we did not do this, the assertions would likely fail, for want of the DML being committed prior to asssertions)
         */ 
		Test.startTest();
// Attempted	Datetime dt = Datetime.now().addMinutes(1);
// Attempt#1	String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
// Attempt#2	String CRON_EXP = '0 '+ dt.minute() + ' * * * ?';
// Attempted	String jobId = System.schedule('WaveAssetMetadataSchedulable', CRON_EXP, new WaveAssetMetadataSchedulable());
// Attempted	System.assertNotEquals(null, jobId);
        WaveAssetMetadataSchedulable S = new WaveAssetMetadataSchedulable();
        S.execute(null);
        Test.stopTest();
        AggregateResult postDashboards = [SELECT count(id) cnt FROM WaveDashboard__c];
        System.debug('>>>sfdcDebug>>> postDashboards.cnt: ' + (Integer)postDashboards.get('cnt'));
        System.assert((Integer)postDashboards.get('cnt') > 0);
        AggregateResult postDatasets = [SELECT count(id) cnt FROM WaveDataset__c];
        System.debug('>>>sfdcDebug>>> postDatasets.cnt: ' + (Integer)postDatasets.get('cnt'));
        System.assert((Integer)postDatasets.get('cnt') > 0);
        AggregateResult postLenses = [SELECT count(id) cnt FROM WaveLens__c];
        System.debug('>>>sfdcDebug>>> postLenses.cnt: ' + (Integer)postLenses.get('cnt'));
        System.assert((Integer)postLenses.get('cnt') > 0);
    }
}