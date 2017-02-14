/**
*	Builds Required Store Activity objects
*
*	@author	Sahil Grover	<sgrover@acumensolutions>
*/
public with sharing class RequiredStoreActivityBuilder {

	private final List<Store_Visit_Activity_Category__c> storeActivityCategories;

	public RequiredStoreActivityBuilder(final List<Store_Visit_Activity_Category__c> storeActivityCategories) {
		this.storeActivityCategories = storeActivityCategories;
	}

	/**
	*	Builds a list of required store activities
	*	Store Activity records require the RecordType.DeveloperName field
	*
	*	@param	storeActivities	The store activities to load into the required activities
	*
	*	@return	Returns a list of required store activities
	*/
	public List<RequiredStoreActivity> buildRequiredStoreActivities(final List<Store_Activity__c> storeActivities) {
		List<RequiredStoreActivity> requiredActivities = new List<RequiredStoreActivity>();
		for (Store_Visit_Activity_Category__c activityCategory : this.storeActivityCategories) {

			RequiredStoreActivity requiredActivity = new RequiredStoreActivity(activityCategory);
			for (Store_Activity__c storeActivity : storeActivities) {
				if ( isActivityInCategory(storeActivity, activityCategory) ) {
					requiredActivity.StoreActivities.add(storeActivity);
				}
			}

			requiredActivities.add(requiredActivity);
		}

		return requiredActivities;
	}

	private boolean isActivityInCategory(Store_Activity__c storeActivity, Store_Visit_Activity_Category__c activityCategory) {
		return
			activityCategory.Record_Type_Name__c.equalsIgnoreCase(storeActivity.RecordType.DeveloperName)
			&& activityCategory.Store_Type__c.equalsIgnoreCase(storeActivity.Store_Type__c);
	}
}