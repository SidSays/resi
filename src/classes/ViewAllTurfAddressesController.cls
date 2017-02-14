/**
* Class Name: ViewAllTurfAddressesController
* Author: Amitkumar Bangad, Accenture
* Date: 7-May-2013 
* Requirement # Request Id: 210   
* Description: Contains support actions to view all the addresses on Turf/Playlist with Pagination.
* Last Modified :
*/
public class ViewAllTurfAddressesController {
    
    public list<Customer_Address__c> addressesList {get;set;}
    public list<Customer_Address__c> addList {get;set;}
    public string planId {get;set;}
    public Boolean showFlag {get;set;}
    public integer size  {get;set;}
    public integer excluded {get;set;}
    public integer included {get;set;}
    public ApexPages.StandardSetController con {get;set;}
    
    /**
    * @Description: Constructor for ViewAllTurfAddressesController class
    * @Param: Standard Controller instance
    */
    public ViewAllTurfAddressesController(ApexPages.StandardController controller) {
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
        if (addressesList.size() <= 0){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.NoAddressInPlanErrorMsg));   
        } else{
            showFlag = true; 
            if(con == null) {
                con = new ApexPages.StandardSetController(addressesList);
                con.setPageSize(10);
            }
        }
    }
    
    /**
    * @Description: this method fetches addresses related  to Plan
    * @Param: None
    * @Return: AddressList
    */
    public List<Customer_Address__c> getAddresses(){
        addList = new list<Customer_Address__c>();
        for (Customer_Address__c cs: ((List<Customer_Address__c>) con.getRecords())){
            addList.add(cs);    
        }
        if (addressesList.size() <= 0){
             Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.NoAddressInPlanErrorMsg));     
        } else{
            showFlag = true; 
        }
        return addList;
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
 
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
 
    // returns the first page of records
    public void first() {
        con.first();
    }
 
    // returns the last page of records
    public void last() {
        con.last();
    }
 
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
 
    // returns the next page of records
    public void next() {
        con.next();
    }
 
    // returns the PageReference of the original page, if known, or the home page.
    public void cancel() {
        con.cancel();
    }
}