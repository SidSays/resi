/**
 * Resets RGU fields to 0 on Account at the end of each fiscal month
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 12/3/14
 */

global class ResetRGUSchedulable implements Schedulable {
	
	global void execute(SchedulableContext sc) {
		List<Account> stores = getStores();
		for (Account store : stores) {
			store.RGU_Orders_This_Fiscal_Month__c = 0;
			store.RGU_Activations_This_Fiscal_Month__c = 0;
		}

		update stores;
	}

	private List<Account> getStores(){
		RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :StoreVisitUtility.RECORD_TYPE_DEV_NAME];

		return new List<Account>([
			SELECT RGU_Orders_This_Fiscal_Month__c, RGU_Activations_This_Fiscal_Month__c
			FROM Account
			WHERE RecordTypeId = :recordType.Id]);
	}
}