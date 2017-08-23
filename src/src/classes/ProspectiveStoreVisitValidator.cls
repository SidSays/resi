/**
 * Child class to handle validation for prospective store visits
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 11/10/14
 */

public with sharing class ProspectiveStoreVisitValidator extends StoreVisitValidator{
	
	public ProspectiveStoreVisitValidator(final Store_Visit__c storeVisit, final Store_Settings__c storeSettings) {
		super(null, storeVisit, storeSettings);
	}

	public override ValidationResult validateCheckIn(final Geolocation currentLocation) {
        return new ValidationResult(true, null);
    }

    public override ValidationResult validateCheckOut(final Geolocation currentLocation, final List<RequiredStoreActivity> requiredStoreActivities) {
        return new ValidationResult(true, null);
    }

    public override Boolean isValidationRequired() {
    	return false; 
    }
}