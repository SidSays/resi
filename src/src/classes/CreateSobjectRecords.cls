global class CreateSobjectRecords {
    webService static Id createAccount(String Name, String AccountNumber, String RecordTypeId, String AccountSource, String Type, String BillingAccountNumber,
    String CustomerStatus, String HouseKey, Boolean IsActive, String Region, String Id) {
        Account acct = new Account(Name = Name, AccountNumber = AccountNumber, RecordTypeId = RecordTypeId, AccountSource = AccountSource, Type = Type, 
        Billing_Account_Number__c = BillingAccountNumber, Customer_Status__c = CustomerStatus,
        House_Key__c = HouseKey, IsActive__c = IsActive, Region__c = Region, Production_Account_Id__c = Id);
        upsert acct Production_Account_Id__c ; 
        return acct.id; 
    }
    webService static Id createContact(String firstName, String LastName, String Id, String RecordTypeId, Boolean Active,
    String Status, String Type) {
        Contact con = new Contact(lastName = lastName, firstName = firstName, Production_Contact_Id__c = Id, RecordTypeId = RecordTypeId, Active__c= Active,
        Status__c = Status, Type__c = Type); 
        upsert con Production_Contact_Id__c; 
        return con.id; 
    }
}