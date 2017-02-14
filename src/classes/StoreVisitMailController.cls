/**
*	Controller extension for send visit summary email page
*
*	@author	Sahil Grover
*/
public with sharing class StoreVisitMailController {

	private Id visitId;

	public StoreVisitMailController(ApexPages.StandardController stdCon) {
		this.visitId = stdCon.getId();
	}

	public void sendVisitMail() {
		Store_Visit__c storeVisit = StoreQueryUtility.queryStoreVisit(this.visitId);

		Store_Settings__c storeSettings = Store_Settings__c.getInstance();
		if (storeSettings.Visit_Mail_Delay_Minutes__c == null) {
			return;
		}

		StoreVisitMailScheduler mailScheduler = new StoreVisitMailScheduler(storeVisit);

		Integer mailDelayMinutes = (Integer)storeSettings.Visit_Mail_Delay_Minutes__c;

		if (mailDelayMinutes == null) {
			StoreVisitUtility.addErrorMessage( 'Visit summary emails are disabled for your organization' );
		} else if (mailDelayMinutes == 0) {

			mailScheduler.execute(null);
			if (mailScheduler.EmailResult.isSuccess()) {
				StoreVisitUtility.addConfirmMessage('The visit summary email was sent successfully');
			} else {
				StoreVisitUtility.addErrorMessage('The visit summary email failed to send.');
				for (Messaging.SendEmailError emailError : mailScheduler.EmailResult.getErrors()) {
					StoreVisitUtility.addErrorMessage( emailError.getMessage() );
				}
			}

		} else {
			String cronExpression = StoreVisitUtility.getSchedulerExpression(
				Datetime.now().addMinutes(mailDelayMinutes)
				);

			try {
				System.schedule('Store_Visit_Summary_Mail', cronExpression, mailScheduler);
				StoreVisitUtility.addInfoMessage('Your message will be sent in ' + mailDelayMinutes + ' minutes');
			} catch (System.AsyncException ex) {
				StoreVisitUtility.addErrorMessage('There was a problem scheduling the visit summary email');
				ApexPages.addMessages(ex);
			}
		}
	}
}