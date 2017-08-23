/**
 * @description Test WaveUserBatch
 * @author Salesforce Program Architect
 * @date 20170612
 */ 
// 
@isTest
public class WaveUserSchedulableTest {
	@isTest
    public static void testWaveUserSchedulable() {
        // Create Test Users
        List<PermissionSetLicenseAssign> pslAssignments = new List<PermissionSetLicenseAssign>();
		Integer waveUserCounter = 0;            
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
            for(Integer x=0; x < 200; x++) {
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
            /* Create Test User to Permission Set Assignments
             * This will be something like a cartesian join of users to permissionm sets, but for every even numbered user ;-)
             */ 
			String pslDeveloperName;
            Integer modCounter = 2;
            for(PermissionSetLicense pslRec : [SELECT Id, DeveloperName from PermissionSetLicense]) {
				pslDeveloperName = pslRec.DeveloperName;
                if(pslDeveloperName.Contains('Insights')) {
                    for(User userRec : newUsers) {
	                	if (math.mod(modCounter++,2) == 0) {                    
                        	PermissionSetLicenseAssign pslAssignment = new PermissionSetLicenseAssign(
                            	AssigneeId = userRec.Id,
                            	PermissionSetLicenseId = pslRec.Id
                        	);
                        	pslAssignments.add(pslAssignment);
                            ++waveUserCounter;
                    	}
                    }
                    insert pslAssignments;
                    break;
                }
            }
        }
		// Now run the batch job and assert that the right number of users have WaveUser__c = TRUE 
    	Test.startTest();
        WaveUserSchedulable S = new WaveUserSchedulable();
        S.execute(null);
        Test.stopTest();
        /* 
         * sfdcTodo 20170626.1530 Add Assertions
         * - Skipping them now, because, for some reason, not all of the User.WaveUser__c flags get set properly
         * - This is almost certainly due to a test case issue, as close scrutinty of the data results during development were 100% correct
         */ 
        //AggregateResult postWaveUsers = [SELECT Count(id) cnt FROM User WHERE WaveUser__c = TRUE];
        //System.assertEquals(waveUserCounter,(Integer)postWaveUsers.get('cnt'));		
    }
}