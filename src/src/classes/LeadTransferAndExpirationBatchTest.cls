@isTest
private class LeadTransferAndExpirationBatchTest {
    
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';

    @isTest static void LeadTransferAndExpirationBatch() {
        SetupTestData.createCustomSettingRecords();
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration User']; 
        UserRole role=[Select Id From UserRole WHERE Name='Comcast: Residential'];
        User user = new User();
        user.City='Test Integration';
        user.Username = 'testint@acme.com';
        user.LastName = 'Last Name';
        user.Email = 'testint@gmail.com';
        user.Alias = 'testint';
        user.CommunityNickname = 'testint';
        user.TimeZoneSidKey = 'America/Panama';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.ProfileId = p.Id;
        User.FederationIdentifier = 'Test@testmail.com';
        user.UserRoleId=role.Id;
        insert user; 
        // Creating Affiliate Accounts
        Account accObj1 = new Account(Name='Test Account1', LeadTransferDuration__c=-2, LeadExpirationDuration__c=-1, OpportunityTransferDuration__c=-2, OpportunityExpirationDuration__c=-1);
        Account accObj2 = new Account(Name='Test Account2', LeadTransferDuration__c=-2, LeadExpirationDuration__c=1, OpportunityTransferDuration__c=-2, OpportunityExpirationDuration__c=1);
        Lead leadObj1;
        Lead leadObj2;
        String leadIdString='';
        User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
        system.runAs(currentUser){        
        try {
            insert accObj1;
            insert accObj2;
        }catch(Exception ex) {
            System.debug('Following Exception occurred while inserting Account:'+ex);
        }        
        if(accObj1.Id != null) {
            accObj1 = [Select IsPartner, LeadTransferDuration__c, LeadExpirationDuration__c, OpportunityTransferDuration__c, OpportunityExpirationDuration__c from Account where Id=:accObj1.Id];
            accObj1.IsPartner = true;
            accObj2 = [Select IsPartner, LeadTransferDuration__c, LeadExpirationDuration__c, OpportunityTransferDuration__c, OpportunityExpirationDuration__c from Account where Id=:accObj2.Id];
            accObj2.IsPartner = true;
            try {
                update  accObj1;
                update  accObj2;
            }catch(Exception ex) {
            System.debug('Following Exception occurred while updating Account:'+ex);
            }
            leadObj1 = new Lead(LastName='Test Lead1', OwnerId=user.Id, Company='Test Company1', Status='Open', Affiliate_Account__c=accObj1.Id);
            leadObj2 = new Lead(LastName='Test Lead2', OwnerId=user.Id, Company='Test Company2', Status='Open', Affiliate_Account__c=accObj2.Id);
            try {
                insert leadObj1;  
                leadIdString+='\''+leadObj1.Id+'\',';  
                insert leadObj2;  
                leadIdString+='\''+leadObj2.Id+'\''; 

            }catch(Exception ex) {
                System.debug('Following Exception occurred while inserting Lead or Opportunity:'+ex);
            }
        }
        //}
        
        // Scheduling ScheduleTransferAndExpiration class that will start the batch process.
        Test.StartTest();      
        ScheduleLeadTransferAndExpiration scheduleLeadTransferAndExpirationObj = new ScheduleLeadTransferAndExpiration();
        String scheduledJobIdLead = System.schedule('testScheduledLeadApex', CRON_EXP, scheduleLeadTransferAndExpirationObj);
        
        LeadTransferAndExpirationBatch lteb=new LeadTransferAndExpirationBatch();
        lteb.query='Select Id, OwnerId, Owner.Profile.Name, CreatedDate, Affiliate_Account__c, Affiliate_Account__r.LeadExpirationDuration__c, Affiliate_Account__r.LeadTransferDuration__c from Lead where Affiliate_Account__r.IsPartner=true AND Id IN ('+leadIdString+') And IsConverted=false And Status!=\'Closed\' And Owner.Profile.Name=\'Integration User\' order by CreatedDate';      
        database.executebatch(lteb);
        Test.StopTest();
    }
  }
}