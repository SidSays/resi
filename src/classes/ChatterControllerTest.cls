@isTest
private class ChatterControllerTest {

    private static UserRole role=[Select Id From UserRole WHERE Name='Comcast: Residential'];
    
    @isTest static void testChatterTandC() {
        Profile p_delivery = [SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1];

        SetupTestData.createCustomSettingRecords();

        User u1 = new User(
            FirstName = 'Consultant',
            LastName = 'Test',
            Email = 'test@test.com',
            Username = 'pm.test@' + UserInfo.getOrganizationId() + 'test.com',
            Alias = 'pmtest',
            ProfileId = p_delivery.Id,FederationIdentifier = 'FedId2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            UserRoleId=role.Id);
        insert u1;

        System.runAs(u1)
        {
            ChatterController cc = new ChatterController();
            cc.redirect();
        }
        User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
        system.runAs(currentUser){
            Terms_and_Conditions__c tc = new Terms_and_Conditions__c();
            tc.Terms_and_Conditions_Text__c='Test Test Test';
            tc.Active__c=true;
            insert tc;
        }

        System.runAs(u1)
        {
            ChatterController cc = new ChatterController();
            cc.redirect();
            cc.cancel();
            cc.acceptTandC=false;
            cc.acceptTandCRedirect();
            cc.acceptTandC=true;
            cc.acceptTandCRedirect();
            cc.redirect();

        }
    }
    
}