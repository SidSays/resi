/**
 * Controller for the StoreVisit page
 *
 * @author	Ryan Sayles		<rsayles@acumensolutions.com>
 * @author	Sahil Grover	<sgrover@acumensolutions.com>
 */

public with sharing class StoreVisitController {

	public Store_Visit__c StoreVisit {get; set;}
	public List<RequiredStoreActivity> RequiredStoreActivities {get;set;}
	public List<Task> VisitTasks {get; set;}
	public StoreVisitValidator.ValidationResult ValidationResult {get; private set;}
	public Geolocation UserLocation {get; set;}
	public String SelectedRecordType {get; set;}
	public Id SelectedActivityId {get; set;}
	public Boolean IsProspectVisit{get; set;}
	public StoreVisitSummary VisitSummary {
		get {
			return StoreVisitSummary.createSummary(this.store, this.StoreVisit, this.RequiredStoreActivities, this.VisitTasks);
		}
	}
	public Double VisitStartDateTimeMs {
		get {
			if (this.StoreVisit.Start_Date_Time__c == null) {
				return Datetime.now().getTime();
			}
			return this.StoreVisit.Start_Date_Time__c.getTime();
		}
	}
	public Boolean IsValidationRequired {
		get {
			return this.visitValidator.isValidationRequired();
		}
	}

	private Account store;
	private Id userId; 
	private List<Store_Visit_Activity_Category__c> storeActivityCategories;
	private RequiredStoreActivityBuilder requiredActivityBuilder;
	private StoreVisitValidator visitValidator;
	private Map<String, RecordType> activityRecordTypeMap;
	private RecordType taskRecordType;

	public StoreVisitController(ApexPages.StandardController stdCon) {
		userId = UserInfo.getUserId();
		UserRole role = StoreQueryUtility.queryUserRole(UserInfo.getUserRoleId());
		Id storeId = stdCon.getId();

		if (storeId != null) {
			this.store = StoreQueryUtility.queryStore(storeId);
		} else {
			IsProspectVisit = true;
			this.store = null;
		}	

		this.StoreVisit = this.store == null ? queryActiveStoreVisit(null) : queryActiveStoreVisit(storeId);
		String storeType = this.store == null ? 'Prospect' : this.store.Store_Type__c;

		this.storeActivityCategories = StoreQueryUtility.queryActivityCategories(storeType, role.DeveloperName);

		this.requiredActivityBuilder = new RequiredStoreActivityBuilder(storeActivityCategories);

		this.RequiredStoreActivities = buildRequiredStoreActivityList(this.StoreVisit.Id);
		if (this.StoreVisit.Id == null) {
			this.VisitTasks = new List<Task>();
		} else {
			this.VisitTasks = StoreQueryUtility.queryVisitTasks(this.StoreVisit.Id);
		}

		Store_Settings__c storeSettings = Store_Settings__c.getInstance();

		if(this.store == null) {
			this.visitValidator = new ProspectiveStoreVisitValidator(StoreVisit, storeSettings);
		}
		else {
			this.visitValidator = new StoreVisitValidator(this.store, StoreVisit, storeSettings); 
		}

		this.visitValidator = StoreVisitValidator.createValidator(this.store, StoreVisit, storeSettings);

		List<RecordType> recordTypes = StoreQueryUtility.queryRecordTypes('Store_Activity__c');
		this.activityRecordTypeMap = StoreVisitUtility.buildRecordTypeNameMap(recordTypes);
		this.taskRecordType = StoreQueryUtility.queryRecordType('Task');

		this.ValidationResult = new StoreVisitValidator.ValidationResult(true, new List<String>());
		this.UserLocation = new Geolocation();
	}

	private Store_Visit__c queryActiveStoreVisit(final Id storeId) {
		try {
	 		return [
				SELECT Id, Store__c, Start_Date_Time__c, End_Date_Time__c, Notes__c,
					OwnerId, Prospect_Store_Name__c
				FROM Store_Visit__c
				WHERE Store__c = :storeId 
					AND Store_Visit_Status__c = :StoreVisitUtility.VISIT_STATUS_ACTIVE
					AND OwnerId = :userId
				LIMIT 1
				];
		} catch (QueryException ex) {
			return new Store_Visit__c(
				Store__c = storeId
				);
		}
	}

	private List<RequiredStoreActivity> buildRequiredStoreActivityList(final Id storeVisitId) {
		List<Store_Activity__c> storeActivities;
		if (storeVisitId == null) {
			storeActivities = new List<Store_Activity__c>();
		} else {
			storeActivities = StoreQueryUtility.queryStoreActivities(storeVisitId);
		}

		List<RequiredStoreActivity> requiredActivities = this.requiredActivityBuilder.buildRequiredStoreActivities(storeActivities);
		requiredActivities.sort();

		return requiredActivities;
	}

	public void validateStartVisit() {
		this.ValidationResult = this.visitValidator.validateCheckIn(this.UserLocation);
		if (this.ValidationResult.IsValid) {
			startVisit();
		}
	}

	public void startVisit() {
		this.StoreVisit.Start_Date_Time__c = Datetime.now();
		this.StoreVisit.Start_Location__Latitude__s = UserLocation.Latitude;
		this.StoreVisit.Start_Location__Longitude__s = UserLocation.Longitude;
		saveStoreVisit();
	}

	public void validateStopVisit() {
		this.RequiredStoreActivities = buildRequiredStoreActivityList(this.StoreVisit.Id);
		this.VisitTasks = StoreQueryUtility.queryVisitTasks(this.StoreVisit.Id);
		this.ValidationResult = this.visitValidator.validateCheckOut(this.UserLocation, this.RequiredStoreActivities);

		if (this.ValidationResult.IsValid) {
			stopVisit();
		}
	}

	public void stopVisit() {
		this.StoreVisit.End_Date_Time__c = Datetime.now();
		this.StoreVisit.Stop_Location__Latitude__s = UserLocation.Latitude;
		this.StoreVisit.Stop_Location__Longitude__s = UserLocation.Longitude;
		
		Integer numberOfActivities = this.RequiredStoreActivities.size();
		Integer numberOfCompletedActivities = 0;
		for (RequiredStoreActivity activity : this.RequiredStoreActivities) {
			if (activity.areRequiredActivitiesComplete()) {
				numberOfCompletedActivities++;
			}
		}

		if (numberOfCompletedActivities == numberOfActivities) {
			this.StoreVisit.Completed_all_required_activities__c = true;
		}

		saveStoreVisit();
	}

	public void saveStoreVisit() {
		try {
			upsert this.StoreVisit;
		} catch (DmlException ex) {
			this.ValidationResult = new StoreVisitValidator.ValidationResult(
				false, 
				new List<String> {'Failed to save store visit', ex.getMessage()},
				true
				);
		}
	}

	public void setActivityLocation() {
		Store_Activity__c activity = new Store_Activity__c(Id = SelectedActivityId);
		activity.Location__Latitude__s = UserLocation.Latitude;
		activity.Location__Longitude__s = UserLocation.Longitude;

		try {
			update activity;
		} catch (DmlException ex) {}	// explicitly silence -- don't stop execution if we can't save location
	}

	public void addStoreActivity() {
		RequiredStoreActivity requiredActivity;

		for(RequiredStoreActivity activity : RequiredStoreActivities) {
			if(activity.StoreActivityCategory.Record_Type_Name__c == this.SelectedRecordType) {
				requiredActivity = activity;
			}
		}

		if (this.StoreVisit.Id == null || requiredActivity == null) {
			return;
		}

		Store_Activity__c storeActivity = new Store_Activity__c();
		storeActivity.Store_Visit__c = this.StoreVisit.Id;
		storeActivity.RecordTypeId = this.activityRecordTypeMap.get(this.SelectedRecordType).Id;

		try {
			insert storeActivity;
		} catch (DmlException ex) {
			this.ValidationResult = new StoreVisitValidator.ValidationResult(
				false, 
				new List<String> {'Failed to save store activity', ex.getMessage()},
				true
				);
			return;
		}

		requiredActivity.StoreActivities.add(storeActivity);

		// need to rebuild here to get generated activity name
		this.RequiredStoreActivities = buildRequiredStoreActivityList(this.StoreVisit.Id);

	}

	public void addTask() {
		if (this.StoreVisit.Id == null) {
			return;
		}

		Task visitTask = new Task();
		visitTask.Subject = 'Reminder Task';
		Id ownerId = this.StoreVisit.OwnerId;
		if (ownerId == null) {
			ownerId = UserInfo.getUserId();
		}
		visitTask.OwnerId = ownerId;
		visitTask.WhatId = this.StoreVisit.Id;
		visitTask.RecordTypeId = this.taskRecordType.Id;

		try {
			insert visitTask;
		} catch (DmlException ex) {
			this.ValidationResult = new StoreVisitValidator.ValidationResult(
				false, 
				new List<String> {'Failed to save task', ex.getMessage()},
				true
				);
			return;
		}

		this.VisitTasks.add(visitTask);
	}

}