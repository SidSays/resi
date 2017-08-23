/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-24
 * Test Class for WaveLensUsageTrigger/Handler
 */ 
@isTest
public class WaveLensUsageTriggerTest {
    static testMethod void WaveLensUsageTriggerTest() {
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
        // Create WaveLens__c records. Luckily, these are completely self-referential. 
        List<WaveLens__c> waveLenses = new List<WaveLens__c>();
        for(Integer x=0; x < 5; x++) {
            WaveLens__c waveLens = new WaveLens__c();
            waveLens.LensId__c = '00000000000000' + x;
            waveLens.Name = 'Lens_' + x;
   			waveLenses.add(waveLens);
        }
        insert waveLenses;
        // Create WaveLensUsage__c records with the same base data that will be available via Splunk
        // The WaveLensUsageTrigger/Handler will enrich the records accordingly, which we will check later
        List<WaveLensUsage__c> waveLensUsage = new List<WaveLensUsage__c>();
        Integer requestId = 0;
        Date requestDate = Date.today();
        for (User waveUser : newUsers) {
            for (WaveLens__c waveLens : waveLenses) {
                WaveLensUsage__c wDU = new WaveLensUsage__c(
               		Name = 'Request_' + requestId++,
                    LensId__c = waveLens.LensId__c,
                    UserId__c = waveUser.Id,
                    Date__c = requestDate
                );
                waveLensUsage.add(wDU);
            }
        }
        test.startTest();
        insert waveLensUsage;
        test.stopTest();
        /*
         * Now let's check to see if the WaveLensUsageTrigger/Handler worked. 
         * We do not need to check all of the straight-forward formula fields.
         * We mainly need to check the specific fields that the WaveLensUsageTrigger/Handler populates:
         * - LensName__c
         * We will rely on our test setup data (above) for the assertions
         * We will need to specifically select fields from WaveLensUsage__c because they are not in the collection above
         */ 
		Map<String,String> waveLensMap = new Map<String,String>();
        for(WaveLens__c waveLens : [SELECT LensId__c, Name FROM WaveLens__c]) {
            waveLensMap.put(waveLens.LensId__c, waveLens.Name);
        }
        for(WaveLensUsage__c wDU : [SELECT LensId__c, LensName__c FROM WaveLensUsage__c]) {
            System.assertEquals(wDU.LensName__c, waveLensMap.get(wDU.LensId__c));
            System.debug('>>>sdfcDebug>>> System.assertEquals: ' + wDU.LensName__c + ' = ' + waveLensMap.get(wDU.LensId__c));
        }
    }
}