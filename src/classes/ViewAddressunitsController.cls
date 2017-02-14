/**
* Class Name: ViewAddressunitsController 
* Author: Amitkumar Bangad, Accenture
* Date: 14-March-2013 
* Requirement # Request Id: 130  
* Description: This class contains controller action for ViewAddressUnits VF page.
* Last Modified :
*/
public class ViewAddressunitsController {
    
    public list<Customer_Address__c> unitsList {get;set;}
    public list<Customer_Address__c> unitsL {get;set;}
    public string parentId;
    public string queryString;
    public Boolean showFlag {get;set;}
    public integer size  {get;set;}
    public ApexPages.StandardSetController con {get;set;}
    
    /**
    * @description: Constructor
    * @param: Standard Controller instance
    */
    public ViewAddressunitsController(ApexPages.StandardController controller) {
        parentId = ApexPages.currentPage().getParameters().get('Id');
        showFlag = false;
        unitsList  = new list<Customer_Address__c>();
        try{
            unitsList = [Select Id, Name, Parent_Address__c, Status__c, Last_Knock_Date__c, Most_Recent_Disposition__c, Address_2__c from Customer_Address__c where Parent_Address__c =: parentId];
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.NoUnitsInComplexOffice));
        }
        size = unitsList.size();
        if (unitsList.size() <= 0){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.NoUnitsInComplexOffice));   
        } else{
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.TotalUnitsInComplexOffice + size));
            showFlag = true;
            if(con == null) {
                con = new ApexPages.StandardSetController(unitsList);
                con.setPageSize(5);
            } 
        }       
    }
    
    /**
    * @description: Fetch all the unit addresses for a Property Address
    * @param: Standard Controller instance
    */
    public List<Customer_Address__c> getUnits(){
        unitsL = new list<Customer_Address__c>();
        for (Customer_Address__c cs: ((List<Customer_Address__c>) con.getRecords())){
            unitsL.add(cs);    
        }
        if (unitsList.size() <= 0){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.NoUnitsInComplexOffice));   
        } else{
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.TotalUnitsInComplexOffice + size));
            showFlag = true; 
        }
        return unitsL;
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
             if(con != null){
                return con.getHasNext();
            } else{
                return null;
            }
        }
        set;
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            if(con != null){
                return con.getHasPrevious();
            } else{
                return null;
            }
        }
        set;
    }
 
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
             if(con != null){
                return con.getPageNumber();
            } else{
                return null;
            }
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