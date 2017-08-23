@isTest
public class CoachingPayrollControllerTest {
    
    @testSetup static void createTestData(){
        Profile retailConsultant = [Select Id from Profile where Name = 'Retail Sales Consultant'];
        Profile retailStManager = [Select Id from Profile where Name = 'Retail Store Manager'];
        List<User> consultants = new List<User>();
        List<WorkCoaching> coachings = new List<WorkCoaching>();
        	User RetailStoreManager = new User();
            RetailStoreManager.profileId = retailStManager.Id;
            RetailStoreManager.FirstName = 'TestStManager';
            RetailStoreManager.ManagerId = UserInfo.getUserId();
            RetailStoreManager.PERNR__c = '33423';
            RetailStoreManager.UserPermissionsWorkDotComUserFeature = true;
            RetailStoreManager.Username = 'TestStM@abc.com.devpro1';
            RetailStoreManager.LastName = 'LastName';
            RetailStoreManager.Email = 'TestStM@abc.com';    
            RetailStoreManager.Alias = 'TestStm';
            RetailStoreManager.CommunityNickname = 'CommunityNicknamestm';
            RetailStoreManager.TimeZoneSidKey =  'America/Panama';
            RetailStoreManager.LocaleSidKey = 'en_US';
            RetailStoreManager.EmailEncodingKey = 'ISO-8859-1';
            RetailStoreManager.LanguageLocaleKey = 'en_US';
            RetailStoreManager.FederationIdentifier = 'FedId32312';
            insert RetailStoreManager;
        	
        	
            User RetailSaleUser = new User();
            RetailSaleUser.profileId = retailConsultant.Id;
            RetailSaleUser.FirstName = 'TestUser1';
            RetailSaleUser.ManagerId = UserInfo.getUserId();
            RetailSaleUser.PERNR__c = '12345';
            RetailSaleUser.UserPermissionsWorkDotComUserFeature = true;
            RetailSaleUser.Username = 'Testuser@abc.com.devpro1';
            RetailSaleUser.LastName = 'LastName';
            RetailSaleUser.Email = 'Testuser@abc.com';    
            RetailSaleUser.Alias = 'Testuser';
            RetailSaleUser.CommunityNickname = 'CommunityNickname0';
            RetailSaleUser.TimeZoneSidKey =  'America/Panama';
            RetailSaleUser.LocaleSidKey = 'en_US';
            RetailSaleUser.EmailEncodingKey = 'ISO-8859-1';
            RetailSaleUser.LanguageLocaleKey = 'en_US';
            RetailSaleUser.FederationIdentifier = 'FedId1321';
            consultants.add(RetailSaleUser);
       
            User RetailSaleUser2 = new User();
            RetailSaleUser2.profileId = retailConsultant.Id;
            RetailSaleUser2.FirstName = 'TestUser2';            
            RetailSaleUser2.PERNR__c = '123456';
            RetailSaleUser2.Username = 'Testuser2@abc.com.devpro1';
            RetailSaleUser2.LastName = 'LastName';
            RetailSaleUser2.ManagerId = RetailStoreManager.Id;
            RetailSaleUser2.UserPermissionsWorkDotComUserFeature = true;
            RetailSaleUser2.Email = 'Testuser@abc.com';    
            RetailSaleUser2.Alias = 'Test2';
            RetailSaleUser2.CommunityNickname = 'CommunityNickname1';
            RetailSaleUser2.TimeZoneSidKey =  'America/Panama';
            RetailSaleUser2.LocaleSidKey = 'en_US';
            RetailSaleUser2.EmailEncodingKey = 'ISO-8859-1';
            RetailSaleUser2.LanguageLocaleKey = 'en_US';
            RetailSaleUser2.FederationIdentifier = 'FedIdtestuser2';
            consultants.add(RetailSaleUser2);
            
            User RetailSaleUser3 = new User();
            RetailSaleUser3.profileId = retailConsultant.Id;
            RetailSaleUser3.FirstName = 'TestUser3';            
            RetailSaleUser3.PERNR__c = '1234567';
            RetailSaleUser3.ManagerId = UserInfo.getUserId();
            RetailSaleUser3.Username = 'Testuser3@abc.com.devpro1';
            RetailSaleUser3.LastName = 'LastName';
            RetailSaleUser3.UserPermissionsWorkDotComUserFeature = true;
            RetailSaleUser3.Email = 'Testuser@abc.com';    
            RetailSaleUser3.Alias = 'Test3';
            RetailSaleUser3.CommunityNickname = 'CommunityNickname2';
            RetailSaleUser3.TimeZoneSidKey =  'America/Panama';
            RetailSaleUser3.LocaleSidKey = 'en_US';
            RetailSaleUser3.EmailEncodingKey = 'ISO-8859-1';
            RetailSaleUser3.LanguageLocaleKey = 'en_US';
            RetailSaleUser3.FederationIdentifier = 'FedIdtestuser3';
            consultants.add(RetailSaleUser3);
        	
        	User RetailSaleUser4 = new User();
            RetailSaleUser4.profileId = retailConsultant.Id;
            RetailSaleUser4.FirstName = 'TestUser4';            
            RetailSaleUser4.PERNR__c = '1432423';
            RetailSaleUser4.ManagerId = RetailStoreManager.Id;
            RetailSaleUser4.Username = 'Testuser4@abc.com.devpro1';
            RetailSaleUser4.LastName = 'LastName';
            RetailSaleUser4.UserPermissionsWorkDotComUserFeature = true;
            RetailSaleUser4.Email = 'Testuser4@abc.com';    
            RetailSaleUser4.Alias = 'Test4';
            RetailSaleUser4.CommunityNickname = 'CommunityNickname4';
            RetailSaleUser4.TimeZoneSidKey =  'America/Panama';
            RetailSaleUser4.LocaleSidKey = 'en_US';
            RetailSaleUser4.EmailEncodingKey = 'ISO-8859-1';
            RetailSaleUser4.LanguageLocaleKey = 'en_US';
            RetailSaleUser4.FederationIdentifier = 'FedIdtestuser4';
            consultants.add(RetailSaleUser4);
          
        	insert consultants;
        
            WorkCoaching workCoach = new WorkCoaching(coachId=UserInfo.getUserId(),CoachedId = RetailSaleUser.Id );
            insert workCoach;
            One_One_Coaching__c oneOneCoach = new One_One_Coaching__c();
            oneOneCoach.Coaching__c = workCoach.Id;
            oneOneCoach.Status__c = 'Submitted';
            insert oneOneCoach;
            
            coachings.add(new WorkCoaching(coachId = UserInfo.getUserId(),CoachedId = RetailSaleUser3.Id));
        	coachings.add(new WorkCoaching(coachId = RetailStoreManager.Id,CoachedId = RetailSaleUser2.Id));
            insert coachings;
            CoachingPayrollController.getCoachingDetails(oneOneCoach.Id);
    }
    
    @isTest static void validateCheckUserAndCoaching(){
        User testuser1 = [Select id,PERNR__c from user where FirstName = 'TestUser1' ];
        System.runAs(testuser1){
            CoachingPayrollController.checkUserAndCoaching(testuser1.PERNR__c);
            CoachingPayrollController.getErrorsFromCustomMetaData();
            CoachingPayrollController.getLatestFiveOneOneCoachings(testuser1.Id);
        }
        User testuser2 = [Select id,PERNR__c from user where FirstName = 'TestUser2' ];
        CoachingPayrollController.checkUserAndCoaching(testuser2.PERNR__c);
        
        User testuser3 = [Select id,PERNR__c from user where FirstName = 'TestUser3' ];
        System.runAs(testuser3){
            CoachingPayrollController.checkUserAndCoaching(testuser3.PERNR__c);
        }
    }    
    
        @isTest static void validateCheckUserAndCoaching2(){
        User testStrManager = [Select id,PERNR__c from user where FirstName = 'TestStManager' ];
        User testuser4 = [Select id,PERNR__c from user where FirstName = 'TestUser2' ];
            User testuser2 = [Select id,PERNR__c from user where FirstName = 'TestUser4' ];
        System.runAs(testStrManager){
            CoachingPayrollController.checkUserAndCoaching(testuser2.PERNR__c);
            CoachingPayrollController.checkUserAndCoaching(testuser4.PERNR__c);
        }
	} 
}