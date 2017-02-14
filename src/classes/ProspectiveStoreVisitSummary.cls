/**
 * Child Class to handle store visit summary for prospective store visits
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 11/11/14
 */

public with sharing class ProspectiveStoreVisitSummary extends StoreVisitSummary {

	public ProspectiveStoreVisitSummary(final Store_Visit__c storeVisit, final List<RequiredStoreActivity> requiredActivities) {
		super(null, storeVisit, requiredActivities);
	}

	public ProspectiveStoreVisitSummary(
		final Store_Visit__c storeVisit, 
		final List<RequiredStoreActivity> requiredActivities,
		final List<Task> visitTasks
		) {
		super(null, storeVisit, requiredActivities, visitTasks);
	}

	public override String getStoreDisplayName() {
		if(StoreVisit.Prospect_Store_Name__c != null) {
			return StoreVisit.Prospect_Store_Name__c;
		}
		else {
			return 'Prospect';
		}
	}

}