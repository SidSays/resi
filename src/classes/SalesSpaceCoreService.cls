/**
 * This global class provides the helper methods, used in the following components.
 * 1) Top Navigation panel.
 * 2) App Launcher.
 * 3) My SalesSpaceCore Applications
 * */
global with sharing class SalesSpaceCoreService {

	/**
	 * This method responsible to return the logged in user information.
	 * @return : User object retrieved.
	 * */
	@AuraEnabled global static User getLoggedInUserInformation(){
		return [select smallphotourl, FullPhotoUrl, name from User where id=: Userinfo.getUserId()];
	}


	/**
	 * This method responsible to get the navigation menus defined in the custom setting called SalesSpaceHeaderLinks__c.
	 * @return : returns the list of NavigationMenuWrapper, with data returned by custom setting.
	 * @Component 5 related change.
	 * */
	@AuraEnabled global static List<NavigationMenuWrapper> getNavigationMenus(){
		List<NavigationMenuWrapper> navigationMenuWrapperList = new List<NavigationMenuWrapper>();
		// Order by position Ascending
		List<SalesSpaceHeaderLinks__c> salesSpaceHeaderLinksList = [select id, Label__c, Position__c, URL__c from SalesSpaceHeaderLinks__c where Position__c != null order by Position__c];

		// Null check
		if(salesSpaceHeaderLinksList != null && salesSpaceHeaderLinksList.size() > 0){
			// Iterate over items.
			for(SalesSpaceHeaderLinks__c salesSpaceHeaderObj : salesSpaceHeaderLinksList){
				NavigationMenuWrapper navigationMenuWrapperObj = new NavigationMenuWrapper();
				navigationMenuWrapperObj.label = salesSpaceHeaderObj.Label__c;
				navigationMenuWrapperObj.url = salesSpaceHeaderObj.URL__c;
				navigationMenuWrapperObj.defaultMenu = false;
				navigationMenuWrapperList.add(navigationMenuWrapperObj);
			}

			// Make first item visible, on page load.
			if(navigationMenuWrapperList.size() > 0){
				navigationMenuWrapperList[0].defaultMenu = true;
			}

		}else{
			return new List<NavigationMenuWrapper>();
		}

		// Return the list of menu items.
		return navigationMenuWrapperList;
	}

	/**
	 * Method to get the Salesforce data for the MySalesSpaceApps list.
	 * This will wrap the Salesforce data into MySalesSpaceAppWrapper objects.
	 * @return : returns a list of MySalesSpaceAppWrapper objects.
	 * */
	@AuraEnabled global static List<MySalesSpaceAppWrapper> getMySalesSpaceApps(){
		List<AppMenuItem> appMenuItemList = getAppMenuItems();
		List<MySalesSpaceAppWrapper> mySalesAppWrapperList = null;
		if(appMenuItemList != null ){

			mySalesAppWrapperList = new List<MySalesSpaceAppWrapper>();

			if(appMenuItemList != null){
				for(AppMenuItem appmenuItemObj : appMenuItemList){
					MySalesSpaceAppWrapper mySalesAppWrapperObj = new MySalesSpaceAppWrapper();
					mySalesAppWrapperObj.label = appmenuItemObj.Label;
					mySalesAppWrapperObj.logoURL= appmenuItemObj.LogoUrl;
					mySalesAppWrapperObj.iconUrl = appmenuItemObj.IconUrl;
					mySalesAppWrapperObj.altText = convertLabeltoAlt(appmenuItemObj.Label);
					mySalesAppWrapperObj.id = appmenuItemObj.id;
					mySalesAppWrapperObj.url = appmenuItemObj.StartUrl;
					mySalesAppWrapperObj.mobileUrl = appmenuItemObj.MobileStartUrl;
					mySalesAppWrapperObj.appBinaryUrl = appmenuItemObj.MobileAppInstallUrl;

					if(mySalesAppWrapperObj.logoURL == null || mySalesAppWrapperObj.logoURL == ''){mySalesAppWrapperObj.logoURL = Constants.DEFAULT_IMAGENA_URL;}

					mySalesAppWrapperList.add(mySalesAppWrapperObj);
				}
			}

		}
		return mySalesAppWrapperList;

	}

	/*
	 * Method to order items in a specific order defined by order.
	 * Follows same logic as whats in getAppMenuItems.
	 * @param{List<AppMenuItem>} itemsToOrder - Items to order.
	 * @param{List<String> order} order - The order the items should be in.
	 * @returns {List<AppMenuItem>} - Newly ordered list.
	 */
	@TestVisible private static List<AppMenuItem> specificAppOrder(List<AppMenuItem> itemsToOrder, List<String> order) {
			List<AppMenuItem> returnList = new List<AppMenuItem>();
			Map<String, AppMenuItem> remainingElementsMap = new Map<String, AppMenuItem>();
			String currId;

			if (itemsToOrder != null && order != null) {
				// Create Map of AppMenuItem to isolate the remaining items, for the below requirement,
				// If apps are present that are not specified by the specific profile app ordering then they should be put at the end of the list and maintain the original order returned by SF.
				// If a connected app is in the order definition, but is not in the list of returned connected apps it will be ignored.
				for(AppMenuItem appMenuItemObj : itemsToOrder){
					remainingElementsMap.put(appMenuItemObj.label, appMenuItemObj);
				}

				for(String orderItem : order){
					for(AppMenuItem appMenuItemObj : itemsToOrder){
						currId = orderItem != null ? orderItem.trim() : '';
						// If we have a valid Id and its equal to appMenuItemObj.Id, remove element from Map to get remaining elements.
						if((currId.length() == 15 || currId.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', currId) && currId == appMenuItemObj.Id){
							returnList.add(appMenuItemObj);remainingElementsMap.remove(appMenuItemObj.label);
						}
					}
				}

				// Add remaining AppMenuUItems which are not available in Settings.
				for(AppMenuItem appMenuItemObj : remainingElementsMap.values()){
					returnList.add(appMenuItemObj);
				}
			}

			return returnList;
	}

	/**
	 * This method reused at two places which retrieves the app menu items for both the components, AppLauncher and MySalesspace apps.
	 * */
	private static List<AppMenuItem> getAppMenuItems(){
		List<SetupEntityAccess> listOfSetupEntityAccess = [select SetupEntityId from SetupEntityAccess
		                                                   where SetupEntityType =: Constants.SETUP_ENTITY_CONNECTED_APP
		                                                   and ParentId IN (Select PermissionSetId From PermissionSetAssignment where
		                                                		   (AssigneeId =:UserInfo.getUserId() or
		                                                		   PermissionSet.profileid=:UserInfo.getProfileId()))];
		List<AppMenuItem> returnList = null;

		if(listOfSetupEntityAccess != null ){
			List<String> listOfApplicationId = new List<String>();

			for(SetupEntityAccess obj : listOfSetupEntityAccess) {
				listOfApplicationId.add(obj.SetupEntityId);
			}

			List<AppMenuItem> appMenuItemList = [Select id, Label, StartUrl, MobileStartUrl, MobileAppInstallUrl, LogoUrl, Name, IconUrl, Type, CreatedDate From AppMenuItem
			                                     where applicationid=:listOfApplicationId];
			// Get the profile of logged in user.
			String profileName = [Select Name from Profile where Id = :UserInfo.getProfileId()].name;

			// Get the records of metadata.
			List<Profile_App_Order__mdt> profileAppOrderList = [SELECT DeveloperName, id, Label, Language, MasterLabel, NamespacePrefix, QualifiedApiName, App_Name__c, Position__c FROM Profile_App_Order__mdt where MasterLabel=:profileName order by Position__c ASC NULLS LAST];
			// Get the profile specific app ordering
			List<SalesSpace_Profile_Specific_App_Ordering__c> specificProfileAppOrderList = [SELECT App_Ids_Csv_Str__c FROM SalesSpace_Profile_Specific_App_Ordering__c WHERE Profile_Identifier__c=:profileName];
			returnList = new List<AppMenuItem>();
			Map<String, AppMenuItem> remainingElementsMap = new Map<String, AppMenuItem>();
			List<String> specificProfileAppOrder = null;
			String appIdsCsvStr;

			// Get the specific order for the profile. Should only return 1 row. We need to split the csv string into a list.
			if(specificProfileAppOrderList.size() == 1){appIdsCsvStr = specificProfileAppOrderList.get(0).App_Ids_Csv_Str__c != null ? specificProfileAppOrderList.get(0).App_Ids_Csv_Str__c : '' ;specificProfileAppOrder = appIdsCsvStr.split(',');}

			// Create Map of AppMenuItem to isolate the remaining items, for the below requirement,
			// If apps are present that are not specified by the profile app ordering then they should be put at the end of the list and maintain the original order returned by SF.
			// If a connected app is in the order definition, but is not in the list of returned connected apps it will be ignored.

			if(appMenuItemList != null){
				for(AppMenuItem appMenuItemObj : appMenuItemList){
					remainingElementsMap.put(appMenuItemObj.label, appMenuItemObj);
				}
			}

			if(profileAppOrderList != null ){
				for(Profile_App_Order__mdt profileAppOrder : profileAppOrderList){
					for(AppMenuItem appMenuItemObj : appMenuItemList){
						// Remove element from Map to get remaining elements.
						if(profileAppOrder.App_Name__c == appMenuItemObj.Name){returnList.add(appMenuItemObj);remainingElementsMap.remove(appMenuItemObj.label);}
					}
				}

				// Add remaining AppMenuUItems which are not available in Settings.
				for(AppMenuItem appMenuItemObj : remainingElementsMap.values()){
					returnList.add(appMenuItemObj);
				}
			}

			// Specific app ordering if available
			if(returnList.size() > 0 && specificProfileAppOrder != null) {returnList = specificAppOrder(returnList, specificProfileAppOrder);}

		}
		// Return the list with the ordered data.
		return returnList;
	}

	/**
	 * Method to get the Salesforce data for the app section list.
	 * This will wrap the Salesforce data into AppLauncherWrapper objects.
	 * These wrapped objects will be put into a list that is then set as a property of an AppSection object.
	 * @return : returns a list of AppSection objects.
	 * */
	@AuraEnabled global static List<AppSection> getAppSections(){


		List<AppMenuItem> appMenuItemList = getAppMenuItems();
		List<AppSection> appSectionList;
		if(appMenuItemList != null){
			Map<String, List<MySalesSpaceAppWrapper>> appMenuItemMap = new Map<String, List<MySalesSpaceAppWrapper>>();

			for(AppMenuItem appmenuItemObj : appMenuItemList){
				MySalesSpaceAppWrapper mySalesAppWrapperObj = new MySalesSpaceAppWrapper();
				mySalesAppWrapperObj.label = appmenuItemObj.Label;
				mySalesAppWrapperObj.logoUrl= appmenuItemObj.LogoUrl;
				mySalesAppWrapperObj.iconUrl= appmenuItemObj.IconUrl;
				mySalesAppWrapperObj.altText = convertLabeltoAlt(appmenuItemObj.Label);
				mySalesAppWrapperObj.id = appmenuItemObj.id;
				mySalesAppWrapperObj.url = appmenuItemObj.StartUrl;
				mySalesAppWrapperObj.mobileUrl = appmenuItemObj.MobileStartUrl;
				mySalesAppWrapperObj.appBinaryUrl = appmenuItemObj.MobileAppInstallUrl;

				if(mySalesAppWrapperObj.logoURL == null || mySalesAppWrapperObj.logoURL == ''){mySalesAppWrapperObj.logoURL = Constants.DEFAULT_IMAGENA_URL;}

				string appmenuType = appmenuItemObj.type != null && appmenuItemObj.type == 'ConnectedApplication' ? Constants.APPLICATIONS_LABEL: appmenuItemObj.type;
				if(appMenuItemMap.containsKey(appmenuType)){
					List<MySalesSpaceAppWrapper> myssappWrapperList = appMenuItemMap.get(appmenuType);
					myssappWrapperList.add(mySalesAppWrapperObj);
					appMenuItemMap.put(appmenuType, myssappWrapperList);
				}else{
					appMenuItemMap.put(appmenuType, new List<MySalesSpaceAppWrapper>{mySalesAppWrapperObj});
				}
			}

			appSectionList = new List<AppSection>();

			for(String mapKey:  appMenuItemMap.keySet()){
				AppSection appSectionObj = new AppSection();
				appSectionObj.appLabel = mapKey;
				appSectionObj.appLaucherWrapperList = appMenuItemMap.get(mapKey);
				appSectionList.add(appSectionObj);

			}
		}

		return appSectionList;

	}

	/**
	 * This method is responsible to get the Submenu options present under the profile submenu's.
	 * @return : List<SubmenuWrapper> returns the list of Submenu's with wrapper containing the data.
	 * */
	@AuraEnabled global static List<SubmenuWrapper> getProfileSubmenuOptions(){

		List<SubmenuWrapper> submenuWrapperList = new List<SubmenuWrapper>();
		SubmenuWrapper submenuWrapperObj = new SubmenuWrapper();
		/*
		submenuWrapperObj.label = 'My Profile';
		submenuWrapperObj.url = '/'+ Userinfo.getUserId();
		submenuWrapperList.add(submenuWrapperObj);

		submenuWrapperObj = new SubmenuWrapper();
		submenuWrapperObj.label = 'My Cases';
		submenuWrapperObj.url = '/500';
		submenuWrapperList.add(submenuWrapperObj);
		*/

		submenuWrapperObj = new SubmenuWrapper();
		submenuWrapperObj.label = 'Sign Out';
		submenuWrapperObj.url = '/secur/logout.jsp';
		submenuWrapperList.add(submenuWrapperObj);

		return submenuWrapperList;

	}

	/**
	 * This method is responsible for returning the recent app value for the current user.
	 * @return : RecentAppWrapper object.
	 * */
	@AuraEnabled global static RecentAppWrapper getSalesSpaceRecentAppsForUser(){
		List<SalesSpaceRecentApp__c> recentAppList = [select ValueStr__c from SalesSpaceRecentApp__c where UserId__c=: Userinfo.getUserId() limit 1];
		SalesSpaceRecentApp__c recentApp = (recentAppList != null && recentAppList.size() == 1) ? recentAppList.get(0) : null;
		RecentAppWrapper recentAppWrapper = new RecentAppWrapper();
		recentAppWrapper.value = (recentApp != null) ? recentApp.ValueStr__c : '';

		return recentAppWrapper;
	}

	/**
	 * This method is responsible for upserting the recent app value for the current user.
	 * @param {String} value - The value to save.
	 * @return : RecentAppWrapper object.
	 * */
	@AuraEnabled global static RecentAppWrapper upsertSalesSpaceRecentAppsForUser(String value){
		List<SalesSpaceRecentApp__c> recentAppList = [select ValueStr__c from SalesSpaceRecentApp__c where UserId__c=: Userinfo.getUserId() limit 1];
		SalesSpaceRecentApp__c recentApp = (recentAppList != null && recentAppList.size() == 1) ? recentAppList.get(0) : null;

		if (recentApp != null) {
			recentApp.ValueStr__c = value;
			update recentApp;
		} else {
			SalesSpaceRecentApp__c newRecentApp = new SalesSpaceRecentApp__c();
			newRecentApp.UserId__c = Userinfo.getUserId();
			newRecentApp.ValueStr__c = value;

			insert newRecentApp;
		}

		return getSalesSpaceRecentAppsForUser();
	}

	/**
	 * This wrapper class holds the data for Navigation menus component.
	 * */
	global class NavigationMenuWrapper{
		@AuraEnabled global String label {get;set;}
		@AuraEnabled global String url {get;set;}
		@AuraEnabled global Boolean defaultMenu {get;set;}
	}

	/**
	 * This wrapper class holds the data for Navigation menus component.
	 * */
	global class RecentAppWrapper{
		@AuraEnabled global String value {get;set;}
	}


	/**
	 * This wrapper class holds the data for App Section component
	 * Each App Section contains multiple AppLauncherWrapper.
	 * */
	global class AppSection{
		@AuraEnabled global String appLabel {get;set;}
		@AuraEnabled List<MySalesSpaceAppWrapper> appLaucherWrapperList {get; set;}
	}

	/**
	 * This wrapper class holds the data for MySalessSpace Apps component.
	 * */
	global class MySalesSpaceAppWrapper{
		@AuraEnabled global String label {get;set;}
		@AuraEnabled global String logoURL {get;set;}
		@AuraEnabled global String iconURL {get;set;}
		@AuraEnabled global String altText {get;set;}
		@AuraEnabled global String id {get;set;}
		@AuraEnabled global String url {get;set;}
		@AuraEnabled global String mobileUrl {get;set;}
		@AuraEnabled global String appBinaryUrl {get;set;}
	}

	/**
	 * This wrapper class holds the data for Submenus under the profile image
	 * */
	global class SubmenuWrapper{
		@AuraEnabled global String label {get;set;}
		@AuraEnabled global String url {get;set;}
	}

	/**
	 * This private method converts the App label to Alt string.
	 * It will capitalize the first character of each word and takes up upto 2 words.
	 * @return: returns the string with Capitalized upto two characters.
	 * */
	@TestVisible private static String convertLabeltoAlt(String label){
		if(label != null){
			List<String> splitList = label.split(' ');
			String altText = '';
			Integer countInitials = 0;
			for(String word : splitList){
				altText += word.capitalize().substring(0,1);
				// We have to return just two characters, not more than that.
				if(countInitials > 0){
					break;
				}
				countInitials ++;
			}
			return altText;
		}
		return null;
	}
}