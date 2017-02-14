/**
*	Decorator to keep track of added activities for a specific store activity category
*	
*	@author	Sahil Grover	<sgrover@acumensolutions.com>
*/
public class RequiredStoreActivity implements Comparable {

	public final Store_Visit_Activity_Category__c StoreActivityCategory {get; private set;}
	public List<Store_Activity__c> StoreActivities {get; set;}

	public RequiredStoreActivity(final Store_Visit_Activity_Category__c storeActivityCategory) {
		this(storeActivityCategory, new List<Store_Activity__c>());
	}
 
	public RequiredStoreActivity(Store_Visit_Activity_Category__c storeActivityCategory, List<Store_Activity__c> storeActivities) {
		this.StoreActivityCategory = storeActivityCategory;
		this.StoreActivities = storeActivities;
	}

	public Integer getNumberOfCompletedActivities() {
		Integer numberOfActivitiesCompleted = 0; 

		for(Store_Activity__c storeActivity : this.StoreActivities) {
			if(storeActivity.Is_Activity_Complete__c) {
				numberOfActivitiesCompleted++;
			}
		}

		return numberOfActivitiesCompleted;
	}

	public boolean areRequiredActivitiesComplete() {
		return getNumberOfCompletedActivities() >= this.StoreActivityCategory.Number_Required__c;
	}

	public Integer compareTo(final Object compareActivity) {
		RequiredStoreActivity compareToActivity = (RequiredStoreActivity) compareActivity;
		Integer numberRequiredForThisActivity = (Integer)this.StoreActivityCategory.Number_Required__c;
		Integer numberRequiredForCompareActivity = (Integer)compareToActivity.StoreActivityCategory.Number_Required__c;
		if (numberRequiredForThisActivity == numberRequiredForCompareActivity) {
			return 0;
		} else if (numberRequiredForThisActivity < numberRequiredForCompareActivity) {
			return 1;
		} else {
			return -1;
		}
	}
	
}