/**
*	Schedules Store Visit Summary emails
*
*	@author	Sahil Grover
*/
global with sharing class StoreVisitMailScheduler implements Schedulable {

	public Messaging.SendEmailResult EmailResult {get; private set;}

	private Store_Visit__c storeVisit;

	global StoreVisitMailScheduler(final Store_Visit__c storeVisit) {
		this.storeVisit = storeVisit;
	}

	global void execute(SchedulableContext sc) {

		Account store;
		EmailTemplate masterTemplate;

		User rep = StoreQueryUtility.queryUser(this.storeVisit.OwnerId);

		SimpleStoreActivitySearch activitySearch = new SimpleStoreActivitySearch(
			new Set<String>{this.storeVisit.Id}
			);
		List<Store_Activity__c> storeActivities = activitySearch.queryStoreActivities();

		List<Store_Visit_Activity_Category__c> activityCategories = getStoreVisitActivityCategories(storeActivities);

		Store_Settings__c storeSettings = Store_Settings__c.getInstance();

		try {
			store = StoreQueryUtility.queryStore(this.storeVisit.Store__c);
			masterTemplate = StoreQueryUtility.queryEmailTemplate(storeSettings.Detailed_Visit_Summary_Template__c);
		} catch (QueryException ex) {
			store = null;
			masterTemplate = StoreQueryUtility.queryEmailTemplate(storeSettings.Prospect_Store_Visit_Summary_Template__c);
		}
		List<EmailTemplate> activityTemplates = getActivityEmailTemplates(activityCategories);

		StoreVisitMailer visitMailer = new StoreVisitMailer(masterTemplate, activityTemplates);
		RequiredStoreActivityBuilder activityBuilder = new RequiredStoreActivityBuilder(activityCategories);

		List<RequiredStoreActivity> requiredStoreActivities = 
			activityBuilder.buildRequiredStoreActivities(storeActivities);

		StoreVisitSummary visitSummary = new StoreVisitSummary(
			store,
			this.storeVisit,
			requiredStoreActivities
			);

		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>{
			generateMailMessage(visitMailer, visitSummary, rep.Email)
		};

		this.EmailResult = Messaging.sendEmail(emails, false)[0];
	}

	private Messaging.SingleEmailMessage generateMailMessage(
		final StoreVisitMailer visitMailer, 
		final StoreVisitSummary visitSummary, 
		final String recipientAddress) {

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		List<String> toAddresses = new List<String>{
			recipientAddress
		};
		email.setToAddresses(toAddresses);
		email.setHtmlBody(visitMailer.generateEmailBody(visitSummary));

		return email;
	}

	private List<Store_Visit_Activity_Category__c> getStoreVisitActivityCategories(final List<Store_Activity__c> storeActivities) {
		Set<String> recordTypeNames = StoreVisitUtility.getFieldSet(storeActivities, 'Record_Type_Name__c');
		return new List<Store_Visit_Activity_Category__c>([
			SELECT Store_Type__c, Store_Activity_Category__c, Record_Type_Name__c, User_Role__c, Email_Template__c,
				Number_Required__c, Send_Mail_Check_Field__c
			FROM Store_Visit_Activity_Category__c
			WHERE Record_Type_Name__c IN :recordTypeNames
			]);
	}

	private List<EmailTemplate> getActivityEmailTemplates(final List<Store_Visit_Activity_Category__c> storeActivityCategories) {
		Set<String> emailTemplateNames = StoreVisitUtility.getFieldSet(storeActivityCategories, 'Email_Template__c');
		return new List<EmailTemplate>([
			SELECT Name, Id, Body, DeveloperName, HtmlValue
			FROM EmailTemplate
			WHERE DeveloperName IN :emailTemplateNames
			]);
	}
}