/*
 * @Author Salesforce Program Architect
 * @Date 2017-04-24
 * Implementation for WaveUserTrigger
 */ 
public class WaveUserTriggerHandler {
    // Build a rather self-explanatory set of maps to help swap in Names (etc) for Ids
    // These are static variables initialized by static code, so that the related queries are not run with every trigger invocation
    private static Map<String,String> UserId_ProfileId_Map = new Map<String,String>();
    private static Map<String,DateTime> UserId_LastLoginDate_Map = new Map<String,DateTime>();
    static {
        System.debug('>>>sfdcDebug>>> Initializing UserId_ProfileId_Map');
        System.debug('>>>sfdcDebug>>> Initializing UserId_LastLoginDate_Map');
        for (User uRec : [SELECT Id, ProfileId, LastLoginDate FROM User]) {
            UserId_ProfileId_Map.put(uRec.Id, uRec.ProfileId);
            UserId_LastLoginDate_Map.put(uRec.Id, uRec.LastLoginDate);
        }        
    }
    private static Map<String,String> ProfileId_UserLicenseId_Map = new Map<String,String>();
    static {
        System.debug('>>>sfdcDebug>>> Initializing ProfileId_UserLicenseId_Map');
        for(Profile pRec : [SELECT Id, UserLicenseId FROM Profile]) {
            ProfileId_UserLicenseId_Map.put(pRec.Id, pRec.UserLicenseId);
        }        
    }
    private static Map<String,String> UserLicenseId_UserLicenseName_Map = new Map<String,String>();
    static {
        System.debug('>>>sfdcDebug>>> Initializing UserLicenseId_UserLicenseName_Map');
        for (UserLicense ulRec : [SELECT Id, Name FROM UserLicense]) {
            UserLicenseId_UserLicenseName_Map.put(ulRec.Id, ulRec.Name);
        }        
    }
    private static Map<String,String> PermissionSetLicenseId_PermissionSetLicenseName_Map = new Map<String,String>();
    static {
        System.debug('>>>sfdcDebug>>> Initializing PermissionSetLicenseId_PermissionSetLicenseName_Map');
        for (PermissionSetLicense pslRec : [SELECT Id, DeveloperName FROM PermissionSetLicense]) {
            PermissionSetLicenseId_PermissionSetLicenseName_Map.put(pslRec.Id, pslRec.DeveloperName);
        }        
    }

    // Leverage the above maps to enrich records with values
    public static void enrichRecords (List<WaveUser__c> waveUsers) {
        for (WaveUser__c waveUser : waveUsers) {
			waveUser.Name = waveUser.UserId__c + '_' + waveUser.UserPermissionSetLicenseId__c;
            waveUser.UserLastLoginDate__c = UserId_LastLoginDate_Map.get(waveUser.UserId__c);
            waveUser.UserLicenseId__c = ProfileId_UserLicenseId_Map.get(UserId_ProfileId_Map.get(waveUser.UserId__c));
            waveUser.UserLicenseName__c = UserLicenseId_UserLicenseName_Map.get(waveUser.UserLicenseId__c);
            waveUser.UserPermissionSetLicenseName__c = PermissionSetLicenseId_PermissionSetLicenseName_Map.get(waveUser.UserPermissionSetLicenseId__c);
        }
    }
}