@RestResource(urlMapping='/AddAddressServicesRESTUpdated/*')
global without sharing class AddAddressServicesRESTUpdated {

@HttpPost
    global static returnValues addAddresses(addressObject add) {
      
        List<Customer_Address__c> addressesToUpdate = new List<Customer_Address__c>();  
        List<Customer_Address__c> inputAddressList = new List<Customer_Address__c>();
        
        returnValues rValue = new returnValues();

        String playListName = add.playListName;
        Plan__c plan = new Plan__c();
        plan.Name = add.playListName;
        plan.Parent_Plan__c = add.parentPlanId; //Bulk comes here
        plan.Number_of_Addresses__c=add.numberOfAddresses;
        plan.True_count_of_Addresses__c=add.numberOfAddresses;
        String expDateStr = add.expirationDate;
        //Moved down to handle bulk scenario
        //date expdate = date.parse(expDateStr);
        //plan.Expiration_Date__c = expdate;
        plan.OwnerId = add.owner;
        plan.User__c = add.user;
        plan.Plan_Status__c = 'Assigned';
        plan.Plan_Level__c = add.planType;
        plan.Playlist_External_Id__c= add.uniqueId;
        plan.Playlist_Source__c=add.PlaylistSource;
        
        inputAddressList.addAll([SELECT Plan__c, Plan__r.Expiration_Date__c FROM Customer_Address__c WHERE Id in : add.addressList]);

      
        // Changes for Bulk Plan.
        Plan__c p = [Select Id, Plan_Level__c from Plan__c where Id=: add.parentPlanId];
        
        if(p!=null && p.Plan_Level__c!=null && p.Plan_Level__c=='Bulk'){
            if(!inputAddressList.isEmpty()){
                plan.Parent_Plan__c= inputAddressList[0].Plan__c; // Override value with current plan for Bulk
                plan.Expiration_Date__c = inputAddressList[0].Plan__r.Expiration_Date__c;
            }
        } else {
            plan.Expiration_Date__c = date.parse(expDateStr);
        }
      
        try {
              upsert plan Playlist_External_Id__c;
              rValue.result = true;
        }catch(DMLException ex) {
            rValue.result = false;
            System.debug('Following exception occurred :'+ex.getMessage());
            return rValue;
        }

        rValue.planId = plan.Id;
        
        for(Customer_Address__c custAdd: inputAddressList ){
            custAdd.Plan__c = plan.Id;         
            addressesToUpdate.add(custAdd);  
        }
        
        Database.SaveResult[] saveResult;
        try {
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
       global String uniqueId;
       global String PlaylistSource;
 
    }
    
    global class returnValues {

       global boolean result;
       global String planId;

    }
}