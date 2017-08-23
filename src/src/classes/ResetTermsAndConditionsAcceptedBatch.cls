global class ResetTermsAndConditionsAcceptedBatch implements Database.Batchable<sObject> {
	
    public string query = 'SELECT Terms_and_Conditions_Accepted__c FROM User Where Terms_and_Conditions_Accepted__c!=null';
	
	global ResetTermsAndConditionsAcceptedBatch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) 
   	{
   		List < User > usersToUpdate = new List < User > ();

        for (User u: (List < User > ) scope)
        {
            u.Terms_and_Conditions_Accepted__c=null;
            usersToUpdate.add(u);
        }
        update usersToUpdate;
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}