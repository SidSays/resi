/**
* Class Name: ExcludedAddressesController 
* Author: Amitkumar Bangad, Accenture
* Date: 19-March-2013 
* Requirement # Request Id: 210  
* Description: Contains supporting actions for View Excluded Addresses Inline VF
* Last Modified :
*/
public class ExcludedAddressesController {
    
    public list<Customer_Address__c> addressesList {get;set;}
    public list<Customer_Address__c> pageAddressesList {get;set;}
    public string planId {get;set;}
    public Boolean showFlag {get;set;}
    public integer size  {get;set;}
    public integer excluded {get;set;}
    public integer included {get;set;}
    public ApexPages.StandardSetController con {get;set;}
    
    /**
    * @Description: Constructor for ExcludedAddressesController class
    * @Param: StandardController 
    */
    public ExcludedAddressesController(ApexPages.StandardController controller) {
        
        planId = ApexPages.currentPage().getParameters().get('Id');
        showFlag = false;
        excluded = 0;
        addressesList = new list<Customer_Address__c>();
        addressesList = [Select Id, Name, Node__c, Corp__c, City__c, State__c, PostalCode__c, 
                        Last_Knock_Date__c, Status__c, Dwelling_Type__c, Excluded__c from Customer_Address__c where Plan__c =: planId];
        size = addressesList.size();
        included = size;
        for (Customer_Address__c addrs: addressesList){
            if(addrs.Excluded__c){
                excluded = excluded +1;
            }
        }
        included = included - excluded;
        
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(addressesList);
        pageAddressesList = stdSetController.getRecords();
        if (addressesList.size() <= 0){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.No_Address_Error));   
        } else{
            showFlag = true; 
        }
    }
}