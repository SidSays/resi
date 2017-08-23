/**
 * This class contains unit tests for validating the behavior of Apex class
 * and triggers.
 */
@isTest
private class CoachingEditRedirectControllerTest {
	
	private static User XSPUser, XSPUser2, SDMUser, ASMUser;
	private static PermissionSet ps1,ps2,ps3;
  	private static PermissionSetAssignment psa1,psa2,psa3,psa4;
    private static User loggedInUser = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
	
	@testSetup
    static void createTestData() {
    	
    	WorkTestDataUtility.createCustomSettingRecords();
		ps1 = WorkTestDataUtility.getCoachAccessForXSP();
		ps2 = WorkTestDataUtility.getCoachAccessForSDM();
		ps3 = WorkTestDataUtility.getCoachAccessForASM();
		
		ASMUser = WorkTestDataUtility.createDSManagerUserForCoaching();
		ASMUser.FirstName = 'TestASMUser';
		insert ASMUser;
		
       	System.debug('1 ASM User : ' + (ASMUser==null));
       	
       	
		SDMUser = WorkTestDataUtility.createDSSupervisorUserForCoaching();
		SDMUser.ManagerId = ASMUser.Id;
		SDMUser.FirstName = 'TestSDMUser';
		insert SDMUser;
		
		XSPUser = WorkTestDataUtility.createDSRepUserForCoaching();
		XSPUser.ManagerId = SDMUser.Id;
		XSPUser.FirstName = 'TestXSPUser';
		insert XSPUser;
		
		XSPUser2 = WorkTestDataUtility.createDSRepUserForCoaching();
		XSPUser2.ManagerId = SDMUser.Id;
		XSPUser2.FirstName = 'TestXSPUser2';
		insert XSPUser2;
		
		system.runAs(loggedInUser){
			psa1 = new PermissionSetAssignment(assigneeId=XSPUser.id,PermissionSetId = ps1.Id);
	    	psa2 = new PermissionSetAssignment(assigneeId=SDMUser.id,PermissionSetId = ps2.Id);
	    	psa3 = new PermissionSetAssignment(assigneeId=ASMUser.id,PermissionSetId = ps3.Id);
	    	insert new List<PermissionSetAssignment>{psa1,psa2,psa3};
		}		
		
    }
    
    @isTest static void TestCoahingEditRedirectAsXSP (){    
       Test.startTest();
       XSPUser = [SELECT Id, Name FROM User WHERE FirstName = 'TestXSPUser'];
       SDMUser = [SELECT Id, Name FROM User WHERE FirstName = 'TestSDMUser'];
         system.runAs(XSPUser){
			WorkCoaching coaching = new WorkCoaching(coachId = XSPUser.Id, coachedId = SDMUser.Id);
			ApexPages.StandardController coachingCont = new ApexPages.StandardController(coaching);
			CoachingEditRedirectController controller = new CoachingEditRedirectController(coachingCont);
			
			Test.setCurrentPage(Page.CoachingEditRedirect);
			
			System.assertEquals(controller.redirectBasedOnProfile().getURL(), page.CoachingEdit.getURL());
         }
       Test.stopTest(); 
     }
     
     @isTest static void TestCoahingEditRedirectAsSDM (){    
       Test.startTest();
       SDMUser = [SELECT Id, Name FROM User WHERE FirstName = 'TestSDMUser'];
       ASMUser = [SELECT Id, Name FROM User WHERE FirstName = 'TestASMUser'];
         system.runAs(SDMUser){
			WorkCoaching coaching = new WorkCoaching(coachId = SDMUser.Id, coachedId = ASMUser.Id);
			ApexPages.StandardController coachingCont = new ApexPages.StandardController(coaching);
			CoachingEditRedirectController controller = new CoachingEditRedirectController(coachingCont);
			
			Test.setCurrentPage(Page.CoachingEditRedirect);
			
			System.assertNotEquals(controller.redirectBasedOnProfile().getURL(), page.CoachingEdit.getURL());
         }
       Test.stopTest(); 
     }
     
     @isTest static void TestCoahingEditAsXSP (){    
       Test.startTest();
       XSPUser = [SELECT Id, Name FROM User WHERE FirstName = 'TestXSPUser'];
       SDMUser = [SELECT Id, Name FROM User WHERE FirstName = 'TestSDMUser'];
         system.runAs(XSPUser){
			WorkCoaching coaching = new WorkCoaching(coachId = XSPUser.Id, coachedId = SDMUser.Id);
			ApexPages.StandardController coachingCont = new ApexPages.StandardController(coaching);
			CoachingEditRedirectController controller = new CoachingEditRedirectController(coachingCont);
			
			Test.setCurrentPage(controller.redirectBasedOnProfile());
			
			String nextPage = controller.saveRecord().getURL();
         }
       Test.stopTest(); 
     }
     
     @isTest static void TestCoahingEditAsXSPException (){    
       Test.startTest();
       
       XSPUser2 = [SELECT Id, Name FROM User WHERE FirstName = 'TestXSPUser2'];
       SDMUser = [SELECT Id, Name FROM User WHERE FirstName = 'TestSDMUser'];
	   
	     system.runAs(XSPUser2){
			WorkCoaching coaching = new WorkCoaching(coachId = XSPUser2.Id, coachedId = SDMUser.Id);
			ApexPages.StandardController coachingCont = new ApexPages.StandardController(coaching);
			CoachingEditRedirectController controller = new CoachingEditRedirectController(coachingCont);
			
			Test.setCurrentPage(controller.redirectBasedOnProfile());
			
			String nextPage = controller.saveRecord().getURL();
	     }
       Test.stopTest(); 
     }
     
     @isTest static void TestCoahingEditAsXSPManagerInactive (){    
       Test.startTest();
       
       XSPUser = [SELECT Id, Name FROM User WHERE FirstName = 'TestXSPUser'];
       SDMUser = [SELECT Id, Name FROM User WHERE FirstName = 'TestSDMUser'];
	   SDMUser.isActive = false;
	   update SDMUser;
	     system.runAs(XSPUser){
			WorkCoaching coaching = new WorkCoaching(coachId = XSPUser.Id, coachedId = SDMUser.Id);
			ApexPages.StandardController coachingCont = new ApexPages.StandardController(coaching);
			CoachingEditRedirectController controller = new CoachingEditRedirectController(coachingCont);
			
			Test.setCurrentPage(controller.redirectBasedOnProfile());
			
			String nextPage = controller.saveRecord().getURL();
	     }
       Test.stopTest(); 
     }
}