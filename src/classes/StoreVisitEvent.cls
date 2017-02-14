/**
 * Decorator class to wrap store Events and Store Visits
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 10/2/14
 */

public class StoreVisitEvent implements Comparable{

	public Id RedirectId {get; private set;}
	public String StoreName {get; private set;}
	public DateTime StartDateTime {get; private set;}
	public DateTime EndDateTime {get; private set;}
	public String StoreAddress {get; private set;}
	public Boolean IsVisitOverdue {get; private set;}
	public String VisitStatus {get; private set;}

	public StoreVisitEvent(final Event visitEvent) {
		this.RedirectId = visitEvent.AccountId;
		this.StoreName = visitEvent.Account.Name;
		this.StartDateTime = visitEvent.StartDateTime;
		this.EndDateTime = visitEvent.EndDateTime;
		this.StoreAddress = createAddressString(
			visitEvent.Account.BillingStreet,
			visitEvent.Account.BillingCity,
			visitEvent.Account.BillingState,
			visitEvent.Account.BillingPostalCode
			);
		this.IsVisitOverdue = (!visitEvent.Is_Visit_Complete__c && (DateTime.now() > visitEvent.StartDateTime));
		if(IsVisitOverdue){
			this.VisitStatus = 'You are late for this visit';
		}
		else{
			this.VisitStatus = 'Scheduled';
		}
	}

	public StoreVisitEvent(final Store_Visit__c storeVisit) {
		if(storeVisit.Store__c != null) {
			createStoreVisitEvent(storeVisit);
		}
		else{
			createProspectStoreVisitEvent(storeVisit);
		}
	}

	public void createStoreVisitEvent(final Store_Visit__c storeVisit) {
		this.RedirectId = storeVisit.Store__c; 
		this.StoreName = storeVisit.Store__r.Name;
		this.StartDateTime = storeVisit.Start_Date_Time__c;
		this.EndDateTime = storeVisit.End_Date_Time__c;
		this.StoreAddress = createAddressString(
			storeVisit.Store__r.BillingStreet,
			storeVisit.Store__r.BillingCity,
			storeVisit.Store__r.BillingState,
			storeVisit.Store__r.BillingPostalCode
			);
		this.IsVisitOverdue = storeVisit.Store__r.Overdue__c;
		this.VisitStatus = 'Visit ' + storeVisit.Store_Visit_Status__c;
	}

	public void createProspectStoreVisitEvent(final Store_Visit__c storeVisit) {
		this.RedirectId = storeVisit.Id;
		
		if(storeVisit.Prospect_Store_Name__c == null) {
			this.StoreName = 'Prospect Visit';
		}
		else {
			this.StoreName = storeVisit.Prospect_Store_Name__c;
		}

		this.StartDateTime = storeVisit.Start_Date_Time__c;
		this.EndDateTime = storeVisit.End_Date_Time__c;
		this.StoreAddress = 'Prospect Visit';
		this.IsVisitOverdue = false;
		this.VisitStatus = 'Visit ' + storeVisit.Store_Visit_Status__c;
	}

	private String createAddressString(final String street, final String city, final String state, final String postalCode) {
		return street + ', ' + city + ', ' + state + ' ' + postalCode;
	}

	public Integer compareTo(final Object compareStoreVisitEvent) {
		StoreVisitEvent compareToStoreVisitEvent = (StoreVisitEvent) compareStoreVisitEvent;
		DateTime thisStoreVisitEventStartTime = this.StartDateTime;
		DateTime compareStoreVisitEventStartTime = compareToStoreVisitEvent.StartDateTime;

		if(thisStoreVisitEventStartTime == compareStoreVisitEventStartTime){
			return 0;
		} 
		else if(thisStoreVisitEventStartTime > compareStoreVisitEventStartTime){
			return 1;
		}
		else{
			return -1;
		}
	}
}