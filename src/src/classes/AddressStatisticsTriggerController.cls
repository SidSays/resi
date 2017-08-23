public with sharing class AddressStatisticsTriggerController {

	public static void preventAddressLocking(List<Address_Statistics__c> addressStatsList){
		for(Address_Statistics__c a : addressStatsList){
			if(a.Prevent_Address_Locking__c){
				a.Assigned__c = false;
			}
		}
	}
}