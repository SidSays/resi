@RestResource(urlMapping='/AddAddressServicesREST/*')
global without sharing class AddAddressServicesREST {

@HttpPost
    global static returnValues addAddresses(addressObject add) {
      
      returnValues rValue = new returnValues();
       
      String playListName = add.playListName;
      Plan__c plan = new Plan__c();
      try {
      plan.Name = add.playListName;
      plan.Parent_Plan__c = add.parentPlanId;
      plan.Number_of_Addresses__c=add.numberOfAddresses;
      plan.True_count_of_Addresses__c=add.numberOfAddresses;
      String expDateStr = add.expirationDate;
      date expdate = date.parse(expDateStr);
      plan.Expiration_Date__c = expdate;
      plan.OwnerId = add.owner;
        plan.User__c = add.user;
        plan.Plan_Status__c = 'Assigned';
      plan.Plan_Level__c = add.planType;
      
      
     
              insert plan;
              rValue.result = true;
        }catch(DMLException ex) {
             rValue.result = false;
            System.debug('Following exception occurred :'+ex.getMessage());
            return rValue;
        }
        
        try {
         List<Customer_Address__c> addressesToUpdate = new List<Customer_Address__c>();  
         
         List<Customer_Address__c> inputAddressList = new List<Customer_Address__c>();
        
         inputAddressList.addAll([SELECT Plan__c FROM Customer_Address__c WHERE Id in : add.addressList]);
         rValue.planId = plan.Id;
 
       
        for(Customer_Address__c custAdd: inputAddressList ){
            custAdd.Plan__c = plan.Id;         
            addressesToUpdate.add(custAdd);  
        }
        
        Database.SaveResult[] saveResult;
        
            saveResult = Database.update(addressesToUpdate, false);
            rValue.result = true;
        }catch(Exception ex) {
           rValue.result = false;
            System.debug('Following exception occurred :'+ex.getMessage());
            return rValue;
        } 
        return rValue;
    }

    global class addressObject {

       global List<String> addressList;
       global String playListName;
       global String parentPlanId;
       global String expirationDate;
       global String owner;
       global String user;
       global String planType;
       global Integer numberOfAddresses;

    }
     global class returnValues {

       global boolean result;
       global String planId;

    }
}