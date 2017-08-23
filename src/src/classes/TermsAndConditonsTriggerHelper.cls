public with sharing class TermsAndConditonsTriggerHelper 
{
	public static void checkIfTandCActive(Terms_and_Conditions__c tandc) 
	{
		List<Terms_and_Conditions__c> tandcList=[Select Id, Name From Terms_and_Conditions__c Where Active__c=true];

		if(!tandcList.isEmpty() && tandcList.get(0).Id!=tandc.Id)
		{
			tandc.addError('There is already an active Terms & Conditions record, <a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+tandcList.get(0).Id+'" target="_blank">'+tandcList.get(0).Name+'</a>. Please edit the existing record, or deactivate it before activating the current record.', false);
		}

	}
}