/**
 * Helper class for RGU Order trigger
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 11/25/14
 */

public with sharing class RGUOrderTriggerHelper {
	public static void associateAccount(List<RGU_Order__c> updatedRGUOrders) {
		Set<String> rGUOrderStoreIds = StoreVisitUtility.getFieldSet(updatedRGUOrders, StoreVisitUtility.RGU_ORDER_STORE_ID);
		List<Account> stores = getStores(rGUOrderStoreIds);
		addAccountToRGUOrder(updatedRGUOrders, stores);
	}

	private static void addAccountToRGUOrder(List<RGU_Order__c> rGUOrders, List<Account> stores) {
		for (RGU_Order__c rGUOrder : rGUOrders) {
			for (Account store : stores) {
				if (rGUOrder.Store_ID__c == store.AccountNumber && rGUOrder.Affiliate__c == store.Parent.Name) {
					rGUOrder.Store__c = store.Id;
					break;
				}
			}
		}
    }

    private static List<Account> getStores(final Set<String> storeIds) {
        RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :StoreVisitUtility.RECORD_TYPE_DEV_NAME];

    	return new List<Account>([
			SELECT Id, AccountNumber, Parent.Name
			FROM Account
			WHERE AccountNumber IN :storeIds 
                AND RecordTypeId = :recordType.Id
			]);
    }
}