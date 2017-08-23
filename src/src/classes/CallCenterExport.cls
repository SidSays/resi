public with sharing class CallCenterExport {
	public static void queryLeads(){
		List<Lead> leads = new List<Lead>([SELECT Status FROM Lead WHERE Status = 'Open' AND 
			Credit_Check__c = 'GOOD' limit 10]);
	}
}