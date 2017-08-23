/**
 * Validates the store visit, check in, and check out
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 9/11/14
 */

public virtual with sharing class StoreVisitValidator {

    private final Account store;
    protected final Store_Visit__c storeVisit;
    private final Geolocation storeLocation;
    private final Store_Settings__c storeSettings;

    public StoreVisitValidator(final Account store, final Store_Visit__c storeVisit, final Store_Settings__c storeSettings) {
        this.store = store;

        if(store != null) {
            this.storeLocation = new Geolocation(
                store.Store_Location__Latitude__s.doubleValue(), 
                store.Store_Location__Longitude__s.doubleValue()
                );
        }
        this.storeVisit = storeVisit;
        this.storeSettings = storeSettings;
    }

    public virtual ValidationResult validateCheckIn(final Geolocation currentLocation) {
        List<String> errors = new List<String>();
        if (!isUserInStore(currentLocation)) {
        //   errors.add('You are not close enough to the store.');
        }
        return new ValidationResult(errors.isEmpty(), errors);
    }

    public virtual ValidationResult validateCheckOut(final Geolocation currentLocation, final List<RequiredStoreActivity> requiredStoreActivities) {
        List<String> errors = new List<String>();
        if (!isUserInStore(currentLocation)) {
        //   errors.add('You are not close enough to the store.');
        } 
        if (!areRequiredActivitiesComplete(requiredStoreActivities)) {
            errors.add('The required store activities have not been completed. Select "Cancel" to go back and complete the store activity or select "Confirm" to proceed with completing the store visit.');
        }
        if (!isMinimumRequiredDuration(this.storeVisit.Start_Date_Time__c)) {
        //  errors.add('You have not met the minimum visit duration.');
        }
        return new ValidationResult(errors.isEmpty(), errors);
    }

    private Boolean isUserInStore(final Geolocation currentLocation) {
        GeoDistanceCalculator distanceCalculator = new GeoDistanceCalculator(GeoDistanceCalculator.DistanceUnit.FEET);
        double distance = distanceCalculator.getDistance(currentLocation, storeLocation);

        return distance <= this.storeSettings.Max_Store_Visit_Distance_Feet__c;
    }

    protected boolean areRequiredActivitiesComplete(final List<RequiredStoreActivity> requiredStoreActivities) {
        for (RequiredStoreActivity requiredActivity : requiredStoreActivities) {
            if (!requiredActivity.areRequiredActivitiesComplete()) {
                return false;
            }
        }
        return true;
    }

    protected boolean isMinimumRequiredDuration(final DateTime visitStartTime) {
        Integer durationMinutes = StoreVisitUtility.convertMsToMinutes(
            DateTime.now().getTime() - visitStartTime.getTime()
            );
        return durationMinutes >= this.storeSettings.Min_Visit_Time_Minutes__c;
    }

    public static StoreVisitValidator createValidator(final Account store, final Store_Visit__c storeVisit, final Store_Settings__c storeSettings) {
        if (store == null) {
            return new ProspectiveStoreVisitValidator(storeVisit, storeSettings);
        }
        else {
            return new StoreVisitValidator(store, storeVisit, storeSettings);
        }
    }

    public virtual Boolean isValidationRequired() {
        return true;
    }

    public virtual class ValidationResult {
        public final Boolean IsValid {get; private set;}
        public final Boolean IsFatal {get; private set;}
        public final List<String> Errors {get; private set;}

        public ValidationResult(final Boolean isValid, final List<String> errors) {
            this(isValid, errors, false);           
        }

        public ValidationResult(final Boolean isValid, final List<String> errors, final Boolean isFatal) {
            this.IsValid = isValid;
            this.IsFatal = isFatal;
            this.Errors = errors;
        }
    }
}