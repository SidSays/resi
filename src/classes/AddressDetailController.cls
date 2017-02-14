public with sharing class AddressDetailController {
    
    public AddressDetailController(ApexPages.StandardController stdController) {
    }

    public void updateAddressFromBiller(){
       System.debug('getAddressesByID....');
        String addressId = ApexPages.currentPage().getParameters().get('Id');
        UpdateInformationInSalesforce.cAddress wsaddress = new UpdateInformationInSalesforce.cAddress();
        List<Customer_Address__c> addressesForWebService=[SELECT Billing_House_Key__c FROM Customer_Address__c WHERE Id = :addressId];
        if(!addressesForWebService.isEmpty()){
            wsaddress.billingHouseKey = addressesForWebService.get(0).Billing_House_Key__c;
             String status;        
            if (!Test.isRunningTest())
{             status = UpdateInformationInSalesforce.getUpdateStatus(wsaddress);
}           system.debug(status);
        }
    }
}