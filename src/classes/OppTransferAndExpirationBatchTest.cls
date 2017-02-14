@isTest
private class OppTransferAndExpirationBatchTest {
    
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';

    @isTest static void OppTransferAndExpirationBatchTest() {
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
        user.UserRoleId=role.Id;
        user.ProfileId = p.Id;
        user.FederationIdentifier = 'FedId2';
        insert user; 
        // Creating Affiliate Accounts
        Account accObj1 = new Account(Name='Test Account1', LeadTransferDuration__c=-2, LeadExpirationDuration__c=-1, OpportunityTransferDuration__c=-2, OpportunityExpirationDuration__c=-1);
        Account accObj2 = new Account(Name='Test Account2', LeadTransferDuration__c=-2, LeadExpirationDuration__c=1, OpportunityTransferDuration__c=-2, OpportunityExpirationDuration__c=1);
        Opportunity oppObj1;
        Opportunity oppObj2;

        String oppIdString='';
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
            oppObj1 = new Opportunity(Name='Test Opty1', OwnerId=user.Id, StageName='Open', CloseDate=Date.today(), Affiliate_Account__c=accObj1.Id);        
            oppObj2 = new Opportunity(Name='Test Opty2', OwnerId=user.Id, StageName='Open', CloseDate=Date.today(), Affiliate_Account__c=accObj2.Id);                    
            try {
                insert oppObj1;
                oppIdString+='\''+oppObj1.Id+'\',';
                insert oppObj2;
                oppIdString+='\''+oppObj2.Id+'\'';

            }catch(Exception ex) {
                System.debug('Following Exception occurred while inserting Lead or Opportunity:'+ex);
            }
        }
    //}
        
        // Scheduling ScheduleTransferAndExpiration class that will start the batch process.
        Test.StartTest();      
        ScheduleOpportunityTransferAndExpiration scheduleOpportunityTransferAndExpirationObj = new ScheduleOpportunityTransferAndExpiration();
        String scheduledJobIdOpp = System.schedule('testScheduledOppApex', CRON_EXP, scheduleOpportunityTransferAndExpirationObj);  
        
        OpportunityTransferAndExpirationBatch oteb=new OpportunityTransferAndExpirationBatch();
        oteb.query='Select Id, OwnerId, Owner.Profile.Name, CreatedDate, Affiliate_Account__c, Affiliate_Account__r.OpportunityExpirationDuration__c, Affiliate_Account__r.OpportunityTransferDuration__c from Opportunity where Affiliate_Account__r.IsPartner=true  And IsClosed=false And Owner.Profile.Name=\'Integration User\' AND Id IN ('+oppIdString+') order by CreatedDate';      
        database.executebatch(oteb);
        Test.StopTest();
    }
  }
}