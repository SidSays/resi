@isTest
private class RequiredStoreActivityBuilderTest {
	 
	static testMethod void buildRequiredStoreActivity(){
		TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
	    insert userTriggerSettings;

	    TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

	    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
	    UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Indirect Manager'];

	    User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
	    testUser.UserRole = role;
	    insert testUser;

	    Account testAccount = StoreTestUtility.createAccount(testUser.Id);
	    insert testAccount;

	    Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        insert storeVisit;
 
        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        Store_Activity__c sA2 = StoreTestUtility.createStoreActivity(storeVisit.Id);
        Store_Activity__c sA3 = StoreTestUtility.createStoreActivity(storeVisit.Id);

        List<Store_Activity__c> sAList = new List<Store_Activity__c>();
        sAList.add(sA1);
        sAList.add(sA2);
        sAList.add(sA3);
 
        List<RequiredStoreActivity> testActivities = new List<RequiredStoreActivity>();
        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory(testAccount.Store_type__c, role.Name);
        insert testActivityCategory;
        
        List<Store_Visit_Activity_Category__c> storeActivityCategories = new List<Store_Visit_Activity_Category__c>();
        storeActivityCategories.add(testActivityCategory);

    	Test.startTest();
    		RequiredStoreActivityBuilder storeActivityBuilder = new RequiredStoreActivityBuilder(storeActivityCategories);
    		testActivities = storeActivityBuilder.buildRequiredStoreActivities(sAList);
		Test.stopTest();

		System.assertEquals(1, testActivities.size(), 'Map size should be 1');
	}
	
}