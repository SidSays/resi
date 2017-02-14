@isTest
private class AcceptTermsAndConditionsControllerTest {

	    private static testMethod void testTandCResetBatch() {
		SetupTestData.createCustomSettingRecords();
		SetupTestData.createUsers();
		SetupTestData.dsrUser.Terms_and_Conditions_Accepted__c=System.today();
		update SetupTestData.dsrUser;
		Terms_and_Conditions__c tc = new Terms_and_Conditions__c();
		tc.Terms_and_Conditions_Text__c='Test Test';
		tc.Active__c=true;
		System.runAs(new User(Id = Userinfo.getUserId())) {
            insert tc;
        }
      
		tc.Terms_and_Conditions_Text__c='Test Test Test Test';
		tc.Reset_Terms_and_Conditions_Accepted__c=true;
		System.runAs(new User(Id = Userinfo.getUserId())) {
            update tc;
        }
		//Test.stopTest();
	}
	
	static testMethod void testTandCController() {

		SetupTestData.createCustomSettingRecords();
		
		Terms_and_Conditions__c tc = new Terms_and_Conditions__c();
		tc.Terms_and_Conditions_Text__c='Test Test Test';
		tc.Active__c=true;
		insert tc;
		Group g1;
		List<Group> caGroups=[Select Id From Group Where Name= 'Chatter Administrators'];
		if(!caGroups.isEmpty()){
			g1=caGroups.get(0);
			}else{
				g1 = new Group(Name= 'Chatter Administrators', type='Regular');            
				insert g1;
			}

		GroupMember gm= new GroupMember(GroupId=g1.Id, UserOrGroupId=UserInfo.getUserId()); 
		
        	System.runAs(new User(Id = Userinfo.getUserId())) {
            	insert gm;
        	}
      
	        AcceptTermsAndConditionsController atac = new AcceptTermsAndConditionsController();
	        atac.firstname='';
	        atac.lastName='';
	        atac.email='';
	        atac.acceptTandC=false;
	        atac.emailTermsAndCondtionsSignupInfoForUser();
	       	atac.firstname='Fred';
	       	atac.emailTermsAndCondtionsSignupInfoForUser();
	        atac.firstName='Fred';
	        atac.lastName='Flintstone';
	        atac.emailTermsAndCondtionsSignupInfoForUser();
	        atac.firstName='Fred';
	        atac.lastName='Flintstone';
	        atac.email='test@test.com';
	        atac.emailTermsAndCondtionsSignupInfoForUser();
	        atac.acceptTandC=true;
	        atac.emailTermsAndCondtionsSignupInfoForUser();
	        
	       

	}
	
}