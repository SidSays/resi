/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-24
 * Test Class for WaveUserTrigger/Handler
 */ 
@isTest
public class WaveUserTriggerTest {
    static testMethod void WaveUserTriggerTest() {
        // Create Test Users
        List<PermissionSetLicenseAssign> pslAssignments = new List<PermissionSetLicenseAssign>();
        // Avoid Mixed-DML Issues: Put all setup DML in a system.runAs block
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
            List<User> newUsers = new List<User>();
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
            // Create Test User to Permission Set Assignments. This will be a cartesian join of users to permissionm sets
            for(PermissionSetLicense pslRec : [SELECT Id, DeveloperName from PermissionSetLicense]) {
                for(User userRec : newUsers) {
                    if(pslRec.DeveloperName == 'InsightsBuilderPsl') {
	                    PermissionSetLicenseAssign pslAssignment = new PermissionSetLicenseAssign(
    	                    AssigneeId = userRec.Id,
        	                PermissionSetLicenseId = pslRec.Id
            	        );
                	    pslAssignments.add(pslAssignment);
                    }
                }
            }
            insert pslAssignments;
        }
        // In practice, the WaveUserTrigger will be exercised when WaveUser records are inserted with just the User Id and PermissionSetLicense Id
        List<WaveUser__c> waveUsers = new List<WaveUser__c>();
        for(PermissionSetLicenseAssign pslAssignment : pslAssignments) {
            WaveUser__c waveUser = new WaveUser__c(
                UserId__c = pslAssignment.AssigneeId,
                UserPermissionSetLicenseId__c = pslAssignment.PermissionSetLicenseId
            );
            waveUsers.add(waveUser);
        }
        test.startTest();
        insert waveUsers;
        test.stopTest();
        /*
         * Now let's check to see if the WaveUserTrigger/Handler worked. 
         * We do not need to check all of the straight-forward formula fields.
         * We mainly need to check the specific fields that the WaveUserTrigger/Handler populate:
         * - UserLicenseName__c, which also proxies for the UserLicneseId__c
         * - UserPermissionSetLicenseName__c
         * We will rely on our test setup data (above) for the assertions
         * We will need to specifically select fields from WaveUsers__c because they are not in the collection above
         */ 
        for(WaveUser__c waveUser : [SELECT Id, UserLicenseName__c, UserPermissionSetLicenseName__c FROM WaveUser__c]) {
            System.assertEquals(waveUser.UserLicenseName__c,'Salesforce');
            System.assertEquals(waveUser.UserPermissionSetLicenseName__c,'InsightsBuilderPsl');
            System.debug('>>>sdfcDebug>>> System.assertEquals: ' + waveUser.UserLicenseName__c + ' = ' + 'Salesforce');
            System.debug('>>>sdfcDebug>>> System.assertEquals: ' + waveUser.UserPermissionSetLicenseName__c + ' = ' + 'InsightsBuilderPsl');
        }
    } 
}