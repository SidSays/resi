/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-24
 * Test Class for WaveDatasetUsageTrigger/Handler
 */ 
@isTest
public class WaveDatasetUsageTriggerTest {
    static testMethod void WaveDatasetUsageTriggerTest() {
    	// Avoid Mixed-DML Issues: Put all setup DML in a system.runAs block
        List<User> newUsers = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            Id profileId;
            for(Profile profileRec : [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]) {
                profileId = profileRec.Id;
            }
            Id divisionId;
            for(Division divisionRec : [SELECT Id FROM Division WHERE Name = 'Global' LIMIT 1]) {
                divisionId = divisionRec.Id;
            }
            for(Integer x=0; x < 5; x++) {
                User newUser = new User(
                    ProfileId = profileId,
                    DefaultDivision = divisionId,
                    LastName = 'LastName_' + x,
                    Alias = 'LN_' + x,
                    Email = 'LastName_' + x + '@example.com',
                    UserName = 'LastName_' + x + '@example.com',
                    NTLogin__c = 'LN_' + x,
                    TimeZoneSidKey = 'America/New_York',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US'
                );
                newUsers.add(newUser);
            }
            // Turn off the UserTrigger so that we do not get FUBARed
            TriggerSettings__c userTriggerSetting = new TriggerSettings__c();
            userTriggerSetting.Name = 'UserTrigger';
            userTriggerSetting.IsActive__c = FALSE;
            insert userTriggerSetting;
            // Insert Users
            insert newUsers;
        }
        // Create WaveDataset__c records. Luckily, these are completely self-referential. 
        List<WaveDataset__c> waveDatasets = new List<WaveDataset__c>();
        for(Integer x=0; x < 5; x++) {
            WaveDataset__c waveDataset = new WaveDataset__c();
            waveDataset.DatasetId__c = '00000000000000' + x;
            waveDataset.Name = 'Dataset_' + x;
   			waveDatasets.add(waveDataset);
        }
        insert waveDatasets;
        // Create WaveDatasetUsage__c records with the same base data that will be available via Splunk
        // The WaveDatasetUsageTrigger/Handler will enrich the records accordingly, which we will check later
        List<WaveDatasetUsage__c> waveDatasetUsage = new List<WaveDatasetUsage__c>();
        Integer requestId = 0;
        Date requestDate = Date.today();
        for (User waveUser : newUsers) {
            for (WaveDataset__c waveDataset : waveDatasets) {
                WaveDatasetUsage__c wDU = new WaveDatasetUsage__c(
               		Name = 'Request_' + requestId++,
                    DatasetId__c = waveDataset.DatasetId__c,
                    UserId__c = waveUser.Id,
                    Date__c = requestDate
                );
                waveDatasetUsage.add(wDU);
            }
        }
        test.startTest();
        insert waveDatasetUsage;
        test.stopTest();
        /*
         * Now let's check to see if the WaveDatasetUsageTrigger/Handler worked. 
         * We do not need to check all of the straight-forward formula fields.
         * We mainly need to check the specific fields that the WaveDatasetUsageTrigger/Handler populates:
         * - DatasetName__c
         * We will rely on our test setup data (above) for the assertions
         * We will need to specifically select fields from WaveDatasetUsage__c because they are not in the collection above
         */ 
		Map<String,String> waveDatasetMap = new Map<String,String>();
        for(WaveDataset__c waveDataset : [SELECT DatasetId__c, Name FROM WaveDataset__c]) {
            waveDatasetMap.put(waveDataset.DatasetId__c, waveDataset.Name);
        }
        for(WaveDatasetUsage__c wDU : [SELECT DatasetId__c, DatasetName__c FROM WaveDatasetUsage__c]) {
            System.assertEquals(wDU.DatasetName__c, waveDatasetMap.get(wDU.DatasetId__c));
            System.debug('>>>sdfcDebug>>> System.assertEquals: ' + wDU.DatasetName__c + ' = ' + waveDatasetMap.get(wDU.DatasetId__c));
        }
    }
}