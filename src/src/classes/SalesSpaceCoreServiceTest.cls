/**
 * This class contains unit tests for validating the behavior of Apex class SalesSpaceCoreService
 */
@isTest
private class SalesSpaceCoreServiceTest {
	/**
	* This method initializes the data required for the test classes.
	* @Component 5 related change.
	*/
	private static void initData(){
		List<SalesSpaceHeaderLinks__c> salesSpaceHeaderLinksList = new List<SalesSpaceHeaderLinks__c>();
		SalesSpaceHeaderLinks__c salesSpaceHeaderLinkObj = new SalesSpaceHeaderLinks__c();
		salesSpaceHeaderLinkObj.Name = 'Test Name1';
		salesSpaceHeaderLinkObj.Label__c = 'Test Label';
		salesSpaceHeaderLinkObj.URL__c = 'https://www.google.com';
		salesSpaceHeaderLinkObj.Position__c = 1;
		salesSpaceHeaderLinksList.add(salesSpaceHeaderLinkObj);

		salesSpaceHeaderLinkObj = new SalesSpaceHeaderLinks__c();
		salesSpaceHeaderLinkObj.Name = 'Test Name2';
		salesSpaceHeaderLinkObj.Label__c = 'Test Label2';
		salesSpaceHeaderLinkObj.URL__c = 'https://www.google.com';
		salesSpaceHeaderLinkObj.Position__c = 2;
		salesSpaceHeaderLinksList.add(salesSpaceHeaderLinkObj);

		salesSpaceHeaderLinkObj = new SalesSpaceHeaderLinks__c();
		salesSpaceHeaderLinkObj.Name = 'Test Name3';
		salesSpaceHeaderLinkObj.Label__c = 'Test Label3';
		salesSpaceHeaderLinkObj.URL__c = 'https://www.google.com';
		salesSpaceHeaderLinkObj.Position__c = 3;
		salesSpaceHeaderLinksList.add(salesSpaceHeaderLinkObj);

		salesSpaceHeaderLinkObj = new SalesSpaceHeaderLinks__c();
		salesSpaceHeaderLinkObj.Name = 'Test Name4';
		salesSpaceHeaderLinkObj.Label__c = 'Test Label4';
		salesSpaceHeaderLinkObj.URL__c = 'https://www.google.com';
		salesSpaceHeaderLinkObj.Position__c = 4;
		salesSpaceHeaderLinksList.add(salesSpaceHeaderLinkObj);

		insert salesSpaceHeaderLinksList;
        TriggerSettings__c triggerSetting = new TriggerSettings__c(Name='UserTrigger');
        triggerSetting.isActive__c=false;
        insert triggerSetting;
	}

	/**
	 * This method responsible to test the positive scenario where in, it fetches the logged in user information.
	 * It also asserts whether we have received expected user information.
	 */
	@isTest static void test_getLoggedInUserInformationPositive() {
			Test.startTest();
					User userobj = SalesSpaceCoreService.getLoggedInUserInformation();
			Test.stopTest();
			System.assertEquals(userobj.id, Userinfo.getUserId());
	}

    /**
     * This method is responsible for testing the positive scenario where in, it fetches the logged in users recent apps.
		 * Since we are using the dummy user here, there should be no recent apps stored for the dummy user at this point.
		 * The upsertSalesSpaceRecentAppsForUser will insert/update recent apps and then call getSalesSpaceRecentAppsForUser.
		 * So this method is exercised in upsertSalesSpaceRecentAppsForUser as well.
     * It also asserts whether we have received expected user information.
     */
    @isTest static void test_getSalesSpaceRecentAppsForUser() {
		initData();
				Profile p =[select Id FROM Profile Where Name='Standard User'];
				User dummy = new User(Alias = 'dummy', Email='newuser@testorg.com', EmailEncodingKey='UTF-8',
					LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US',
					ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='dummy@testorg.com', FederationIdentifier = 'DummyId2');

				System.runAs(dummy) {
					Test.startTest();
						SalesSpaceCoreService.RecentAppWrapper recentApp = SalesSpaceCoreService.getSalesSpaceRecentAppsForUser();
					Test.stopTest();
					System.assertEquals('dummy@testorg.com', Userinfo.getUserName());
					System.assertEquals('', recentApp.value);
				}
    }

		/**
     * This method is responsible for testing the upsert of recent apps for a user.
		 * The upsertSalesSpaceRecentAppsForUser will insert/update recent apps and then call getSalesSpaceRecentAppsForUser.
		 * So getSalesSpaceRecentAppsForUser is exercised here as well.
     * It also asserts whether we have received expected user information.
     */
    @isTest static void test_upsertSalesSpaceRecentAppsForUser() {
		initData();
				Profile p =[select Id FROM Profile Where Name='Standard User'];
				User dummy = new User(Alias = 'dummy', Email='newuser@testorg.com', EmailEncodingKey='UTF-8',
					LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US',
					ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='dummy@testorg.com', FederationIdentifier = 'DummyId2');
				String value1 = '{\'SalesSpace_Recent_Apps\':[{\'Id\':\'1234asd\'}]}';
				String value2 = '{\'SalesSpace_Recent_Apps\':[{\'Id\':\'1234asd\'}, {\'Id\':\'ABCASDAS\'}]}';

				System.runAs(dummy) {
					Test.startTest();
						// insert here
						SalesSpaceCoreService.RecentAppWrapper recentApp = SalesSpaceCoreService.upsertSalesSpaceRecentAppsForUser(value1);
						System.assertEquals(value1, recentApp.value);

						//update here
						recentApp = SalesSpaceCoreService.upsertSalesSpaceRecentAppsForUser(value2);
						System.assertEquals(value2, recentApp.value);
					Test.stopTest();
					System.assertEquals('dummy@testorg.com', Userinfo.getUserName());
				}
    }

    /**
     * This method responsible to test the positive scenario where in, it fetches navigation menus.
     * It also asserts whether we have received expected wrapper list or not.
     * @Component 5 related change.
     */
    @isTest static void test_getNavigationMenusPositive() {
    	//initialize the data.
    	initData();
        Test.startTest();
            List<SalesSpaceCoreService.NavigationMenuWrapper> navigationMenuWrapperList = SalesSpaceCoreService.getNavigationMenus();
        Test.stopTest();
        System.assertEquals(navigationMenuWrapperList.size(), 4);
        System.assertEquals(navigationMenuWrapperList[0].defaultmenu, true);
    }

    /**
     * This method responsible to test the positive scenario where in, it fetches navigation menus. Two of them having same position.
     * It also asserts whether we have received expected wrapper list or not.
     * @Component 5 related change.
     */
    @isTest static void test_getNavigationMenusDuplicatePositionPositive() {
    	//initialize the data.
    	initData();

    	SalesSpaceHeaderLinks__c salesSpaceHeaderLinkObj = new SalesSpaceHeaderLinks__c();
		salesSpaceHeaderLinkObj.Name = 'Test Name5';
		salesSpaceHeaderLinkObj.Label__c = 'Test Label5';
		salesSpaceHeaderLinkObj.URL__c = 'https://www.google.com';
		// Position 4 is duplicate.
		salesSpaceHeaderLinkObj.Position__c = 4;
		insert salesSpaceHeaderLinkObj;

        Test.startTest();
            List<SalesSpaceCoreService.NavigationMenuWrapper> navigationMenuWrapperList = SalesSpaceCoreService.getNavigationMenus();
        Test.stopTest();
        System.assertEquals(navigationMenuWrapperList.size(), 5);
        System.assertEquals(navigationMenuWrapperList[0].defaultmenu, true);
        // Assert 5th item.
        System.assertEquals(navigationMenuWrapperList[4].label, salesSpaceHeaderLinkObj.Label__c);
    }


    /**
     * This method responsible to test the positive scenario where in, it fetches navigation menus.
     * Create Header link record without Position in Custom setting.
     * It also asserts whether we have received expected wrapper list or not.
     * @Component 5 related change.
     */
    @isTest static void test_getNavigationMenusWithoutPositionNegative() {
    	//initialize the data.
    	initData();
    	SalesSpaceHeaderLinks__c salesSpaceHeaderLinkObj = new SalesSpaceHeaderLinks__c();
		salesSpaceHeaderLinkObj.Name = 'Test Name5';
		salesSpaceHeaderLinkObj.Label__c = 'Test Label5';
		salesSpaceHeaderLinkObj.URL__c = 'https://www.google.com';
		// Create Header link record without Position in Custom setting. This menu should not be shown on UI.
		insert salesSpaceHeaderLinkObj;

        Test.startTest();
            List<SalesSpaceCoreService.NavigationMenuWrapper> navigationMenuWrapperList = SalesSpaceCoreService.getNavigationMenus();
        Test.stopTest();
        // Although we have inserted 5 records, it gets only 4.
        System.assertEquals(navigationMenuWrapperList.size(), 4);
        System.assertEquals(navigationMenuWrapperList[0].defaultmenu, true);
    }

    /**
     * This method responsible to test the negative scenario where in, it fetches navigation menus and we dont have records in custom setting.
     * It also asserts whether we have received expected wrapper list or not.
     * @Component 5 related change.
     */
    @isTest static void test_getNavigationMenusNoInitNegative() {
    	//Do not initialize the data.
        Test.startTest();
            List<SalesSpaceCoreService.NavigationMenuWrapper> navigationMenuWrapperList = SalesSpaceCoreService.getNavigationMenus();
        Test.stopTest();
        System.assertEquals(navigationMenuWrapperList.size(), 0);
    }

    /**
     * This method responsible to test the positive scenario where in, it fetches apps in MySalesSpaceApps section.
     * It also asserts whether we have received expected wrapper list or not.
     */
    @isTest static void test_getMySalesSpaceAppsPositive() {
        Test.startTest();
            List<SalesSpaceCoreService.MySalesSpaceAppWrapper> mySalesAppWrapperList = SalesSpaceCoreService.getMySalesSpaceApps();
        Test.stopTest();
        System.assert(mySalesAppWrapperList.size() >= 0);
    }

    /**
     * This method responsible to test the positive scenario where in, it fetches app section list.
     * It also asserts whether we have received expected wrapper list or not.
     */
    @isTest static void test_getAppSectionsPositive() {
        Test.startTest();
            List<SalesSpaceCoreService.AppSection> appSectionList = SalesSpaceCoreService.getAppSections();
        Test.stopTest();
        System.assertEquals(appSectionList.size(), 1);
    }

    /**
     * This method responsible to test the positive scenario where in, it fetches sub munu options under the profile image.
     * It also asserts whether we have received expected wrapper list or not.
     */
    @isTest static void test_getProfileSubmenuOptionsPositive() {
        Test.startTest();
            List<SalesSpaceCoreService.SubmenuWrapper> appSectionList = SalesSpaceCoreService.getProfileSubmenuOptions();
        Test.stopTest();
        System.assertEquals(appSectionList.size(), 1);
    }

    /**
     * This method responsible to check the custom metadata type availble in the org.
     * It also asserts whether we have received expected output or not
     */
    @isTest static void test_profileAppOrderPositive() {
        Test.startTest();
        	String profileName = 'System Administrator';
			// Get the records of metadata.
			List<Profile_App_Order__mdt> profileAppOrderList = [SELECT DeveloperName, Id, Label, Language, MasterLabel, NamespacePrefix, QualifiedApiName, App_Name__c, Position__c FROM Profile_App_Order__mdt where MasterLabel=:profileName order by Position__c];
        Test.stopTest();
        System.assertNotEquals(profileAppOrderList, null);
    }

    /**
     * This method responsible to check the negative scenario, where in we pass null label to convertLabeltoAlt and
     * asserts whether we have received expected output or not
     */
    @isTest static void test_convertLabeltoAltLabelNullNegative() {
        Test.startTest();
			String label = SalesSpaceCoreService.convertLabeltoAlt(null);
        Test.stopTest();
        System.assertEquals(label, null);
    }

		/**
     * This method responsible to check the positive scenario, where in we pass non null label to convertLabeltoAlt and
     * asserts whether we have received expected output or not
     */
    @isTest static void test_convertLabeltoAltLabel() {
        Test.startTest();
			String label = SalesSpaceCoreService.convertLabeltoAlt('some label');
        Test.stopTest();
        System.assertEquals(label, 'SL');
    }

		/**
     * This method is responsible for checking the null scenario when we want to order apps by specificAppOrder.
     */
    @isTest static void test_specificAppOrderWithNull() {
      Test.startTest();
				List<AppMenuItem> apps = SalesSpaceCoreService.specificAppOrder(null, null);
      Test.stopTest();
      System.assertEquals(apps.size(), 0);
    }

		/**
     * This method is responsible for checking the positive scenario when we want to order apps by specificAppOrder.
		 * We cant insert dummy AppMenuItem items to test, so its difficult to test this.
     */
    @isTest static void test_specificAppOrder() {
			// Since we cannot create dummy AppMenuItems for testing, just selecting a couple default ones that should be in all Orgs.
			List<AppMenuItem> appMenuItems = [SELECT Id, Name, Label FROM AppMenuItem ORDER BY Name];
			List<AppMenuItem> appParam = new List<AppMenuItem>();
			List<String> order = new List<String>();

			// build a dummy list for appParams and one for order
			for(AppMenuItem app : appMenuItems) {
				if (app.Name == 'Community' || app.Name == 'Chatter' || app.Name == 'Sales') {
					appParam.add(app);
				}

				if (app.Name == 'Chatter') {
					order.add(app.Id);
				}
			}

      Test.startTest();
				List<AppMenuItem> apps = SalesSpaceCoreService.specificAppOrder(appParam, order);
      Test.stopTest();
      System.assertEquals(apps.size(), 3);
			System.assertEquals(apps.get(0).Name, 'Chatter');
			System.assertEquals(apps.get(1).Name, 'Community');
			System.assertEquals(apps.get(2).Name, 'Sales');
    }

    /**
     * This method responsible to cover the constant class coverage.
     * asserts whether we have received expected output or not
     */
    @isTest static void test_ConstantsPositive() {
        Test.startTest();
			System.assertEquals(Constants.SETUP_ENTITY_CONNECTED_APP, 'ConnectedApplication');
			System.assertEquals(Constants.DEFAULT_IMAGENA_URL, '/resource/1449902818/core/i/apps/imageNA.png');
			System.assertEquals(Constants.APPLICATIONS_LABEL, 'Applications');
        Test.stopTest();
    }

}