/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-24
 * Test Class for WaveDashboardUsageTrigger/Handler
 */ 
@isTest
public class WaveDashboardUsageTriggerTest {
    static testMethod void WaveDashbaordUsageTriggerTest() {
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
        // Create WaveDashboard__c records. Luckily, these are completely self-referential. 
        List<WaveDashboard__c> waveDashboards = new List<WaveDashboard__c>();
        for(Integer x=0; x < 5; x++) {
            WaveDashboard__c waveDashboard = new WaveDashboard__c();
            waveDashboard.DashboardId__c = '00000000000000' + x;
            waveDashboard.Name = 'Dashboard_' + x;
   			waveDashboards.add(waveDashboard);
        }
        insert waveDashboards;
        // Create WaveDashboardUsage__c records with the same base data that will be available via Splunk
        // The WaveDashboardUsageTrigger/Handler will enrich the records accordingly, which we will check later
        List<WaveDashboardUsage__c> waveDashboardUsage = new List<WaveDashboardUsage__c>();
        Integer requestId = 0;
        Date requestDate = Date.today();
        for (User waveUser : newUsers) {
            for (WaveDashboard__c waveDashboard : waveDashboards) {
                WaveDashboardUsage__c wDU = new WaveDashboardUsage__c(
               		Name = 'Request_' + requestId++,
                    DashboardId__c = waveDashboard.DashboardId__c,
                    UserId__c = waveUser.Id,
                    Date__c = requestDate
                );
                waveDashboardUsage.add(wDU);
            }
        }
        test.startTest();
        insert waveDashboardUsage;
        test.stopTest();
        /*
         * Now let's check to see if the WaveDashboardUsageTrigger/Handler worked. 
         * We do not need to check all of the straight-forward formula fields.
         * We mainly need to check the specific fields that the WaveDashboardUsageTrigger/Handler populates:
         * - DashboardName__c
         * We will rely on our test setup data (above) for the assertions
         * We will need to specifically select fields from WaveDashboardUsage__c because they are not in the collection above
         */ 
		Map<String,String> waveDashboardMap = new Map<String,String>();
        for(WaveDashboard__c waveDashboard : [SELECT DashboardId__c, Name FROM WaveDashboard__c]) {
            waveDashboardMap.put(waveDashboard.DashboardId__c, waveDashboard.Name);
        }
        for(WaveDashboardUsage__c wDU : [SELECT DashboardId__c, DashboardName__c FROM WaveDashboardUsage__c]) {
            System.assertEquals(wDU.DashboardName__c, waveDashboardMap.get(wDU.DashboardId__c));
            System.debug('>>>sdfcDebug>>> System.assertEquals: ' + wDU.DashboardName__c + ' = ' + waveDashboardMap.get(wDU.DashboardId__c));
        }
    }
}