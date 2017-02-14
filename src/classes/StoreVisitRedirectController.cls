/**
*   Controller for pages redirecting to Store Visits
*
*   @author Sahil Grover    <sgrover@acumensolutions.com>
*/
public with sharing class StoreVisitRedirectController {

    public Boolean IsVisitActive {
        get {
            return this.storeVisit.Store_Visit_Status__c == StoreVisitUtility.VISIT_STATUS_ACTIVE;
        }
    }

    private ApexPages.StandardController stdCon;
    public Store_Visit__c storeVisit{get;set;}

    public StoreVisitRedirectController(ApexPages.StandardController stdCon) {
        this.stdCon = stdCon;
    }

    public PageReference checkActiveVisit() {
        try {
            this.storeVisit = [
                SELECT Id, Store__c, Store_Visit_Status__c
                FROM Store_Visit__c
                WHERE Id = :this.stdCon.getId()
            ];
            system.debug('----------' +this.storeVisit);
        } catch (DmlException ex) {
            return stdCon.cancel();
        }
        return null;
    }
}