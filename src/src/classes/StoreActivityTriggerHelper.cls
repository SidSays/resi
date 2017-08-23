/**
*   Trigger helper for Store Activity records
*
*   @author Sahil Grover    <sgrover@acumensolutions.com>
*   @author Ryan Sayles     <rsayles@acumensolutions.com>
*/
public with sharing class StoreActivityTriggerHelper {
    
    public static void populateActivityStore(List<Store_Activity__c> updatedStoreActivities) {
        Set<String> storeVisitIds = StoreVisitUtility.getFieldSet(updatedStoreActivities, 'Store_Visit__c');
        Map<Id, Store_Visit__c> storeVisitMap = getStoreVisitMap(storeVisitIds);
        for (Store_Activity__c storeActivity : updatedStoreActivities) {
                if(storeActivity.Please_select_out_of_date_materials__c == null || storeActivity.Please_select_out_of_date_materials__c == '')
                {
                    storeActivity.Please_select_out_of_date_materials__c = 'None';                  
                }
                system.debug('chhhk' + storeActivity.Name_of_Reps__c );
                 if(storeActivity.Name_of_Reps__c== null || storeActivity.Name_of_Reps__c== '' || String.isBlank(storeActivity.Name_of_Reps__c))
                {
                    storeActivity.Name_of_Reps__c= 'No Reps';                  
                }
        
            if (storeActivity.Store__c != null) {
                continue;
              
            }
            
            Store_Visit__c storeVisit = storeVisitMap.get(storeActivity.Store_Visit__c);
            if(storeVisit !=null){
                storeActivity.Store__c = storeVisit.Store__c;
            }
        }
    }

    private static Map<Id, Store_Visit__c> getStoreVisitMap(final Set<String> storeVisitIds) {
        return new Map<Id, Store_Visit__c>([
            SELECT Id, Store__c
            FROM Store_Visit__c
            WHERE Id IN :storeVisitIds
            ]);
    }
    
}