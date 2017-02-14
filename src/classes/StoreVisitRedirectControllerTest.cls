/**
 * Test class for StoreVisitRedirectController
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 10/9/14
 */


@isTest
private class StoreVisitRedirectControllerTest {
	
	static testMethod void storeVisitRedirect(){
		TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Xfinity Sales Rep'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        insert testUser;

        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        insert testAccount;

        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now().addHours(-2));
        testStoreVisit.End_Date_Time__c = null;
        insert testStoreVisit;

        ApexPages.StandardController stdCon = new ApexPages.StandardController(testStoreVisit);

        System.runAs(testUser){
        	Test.startTest();
        		StoreVisitRedirectController visitRedirectCont = new StoreVisitRedirectController(stdCon);
        		PageReference pr = visitRedirectCont.checkActiveVisit();
        	Test.stopTest();

        	System.assertEquals(true, visitRedirectCont.IsVisitActive, 'Visit should be active');
        }

	}
	
}