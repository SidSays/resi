/**
*	Trigger helper for Event object
*
*	@author	Sahil Grover	<sgrover@acumensolutions.com>
*	@author Ryan Sayles		<rsayles@acumensolutions.com>
*/
public with sharing class EventTriggerHelper {

	public static void sendStoreVisitAlerts(List<Event> scheduledVisits) {
		Set<String> accountIds = StoreVisitUtility.getFieldSet(scheduledVisits, 'AccountId');
		List<Contact> accountContacts = getAccountContacts(accountIds);
		Map<String, List<Contact>> accountContactsMap = StoreVisitUtility.buildFieldSetMap(accountContacts, 'AccountId');

		Store_Settings__c storeSettings = Store_Settings__c.getInstance();
		EmailTemplate alertTemplate;
		try {
			alertTemplate = StoreQueryUtility.queryEmailTemplate(storeSettings.Scheduled_Visit_Alert_Template__c);
		} catch (DmlException ex) {
			return;	// Don't bother trying to send emails without the template
		}

		MergeFieldBinder fieldBinder = new MergeFieldBinder(alertTemplate.Body);

		List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
		for (Event scheduledVisit : scheduledVisits) {
			if (!scheduledVisit.Email_Store_Contact__c) {
				continue;
			}

			List<Contact> visitContacts = accountContactsMap.get(scheduledVisit.AccountId);
			if (visitContacts == null || visitContacts.isEmpty()) {
				continue;
			}

			// this implementation personalizes a separate message to each contact
			// if we run into email limits, we may need to make the template more generic
			// and send a single message to multiple contacts
			for(Integer i = 0; i < visitContacts.size(); i++) {
				emailMessages.add(
					createStoreVisitAlertMail(scheduledVisit, fieldBinder, visitContacts[i])
					);
			}
		}

		Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailMessages, false);

		for (integer i = 0; i < emailResults.size(); i++) {
			if (!emailResults[i].success) {
				String errorMessage = 'Failed to send an email to the store contact!';
				for (Messaging.SendEmailError sendError : emailResults[i].getErrors()) {
					errorMessage += '  ' + sendError.getMessage();
				}
				scheduledVisits[i].addError(errorMessage);
			}
		}
	}

	private static Messaging.SingleEmailMessage createStoreVisitAlertMail(
		final Event scheduledVisit, 
		final MergeFieldBinder fieldBinder, 
		final Contact storeContact) {

		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		email.setToAddresses(new List<String>{storeContact.Email});

		Map<String, SObject> sobjectMap = new Map<String, SObject>{
			'Event' => scheduledVisit,
			'Contact' => storeContact
		};

		String emailBody = fieldBinder.replaceMergeFields(sobjectMap);

		email.setPlainTextBody(emailBody);

		return email;
	}

	private static List<Contact> getAccountContacts(final Set<String> accountIds) {
		return new List<Contact>([
			SELECT Id, AccountId, Email, FirstName, LastName, Store_Address__c
			FROM Contact
			WHERE AccountId IN :accountIds AND Active__c =: true AND Priority__c =: 'Primary'
			]);
	}
}