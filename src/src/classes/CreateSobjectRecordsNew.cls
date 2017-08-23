global class CreateSobjectRecordsNew {
    webService static void createAccount(List<Account> accountList) {
        Account accountToUpsert = new Account();
        List<Account> accountToUpsertList = new List<Account>();
        for(Account acc: accountList){
            accountToUpsert.Name = acc.Name;
            accountToUpsert.Production_Account_Id__c = acc.Id;
            accountToUpsertList.add(accountToUpsert);
        }
        Upsert accountToUpsertList;
        //Upsert accountToUpsertList Production_Account_Id__c;
    }
    webService static void createContact(List<Contact> contactList) {
        Contact contactToUpsert = new Contact();
        List<Contact> contactToUpsertList = new List<Contact>();
        List<Account> accList = [SELECT Id,Production_Account_Id__c FROM Account WHERE Production_Account_Id__c!= null];
        Set<Id> accSetId = new Set<Id>();
        Map<Id,Id> accountIDProdAccIDMap = new Map<Id,Id>();
        for(Account acc: accList){
            accountIDProdAccIDMap.put(acc.Production_Account_Id__c,acc.Id);
        }
        for(Contact cont: contactList){
            if(accountIDProdAccIDMap.containsKey(cont.AccountId)){
                contactToUpsert.FirstName = cont.FirstName;
                contactToUpsert.LastName = cont.LastName;
                contactToUpsert.Production_Contact_Id__c = cont.Id;
                contactToUpsert.AccountId = accountIDProdAccIDMap.get(cont.AccountId);
                contactToUpsertList.add(contactToUpsert);
            }
        }
        Upsert contactToUpsertList;
        //Upsert contactToUpsertList Production_Contact_Id__c;
    }
}