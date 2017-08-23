global class CreateAccountRecords {
    webService static List<Account> createAccount(List<Account> accountList) {
        Account accountToUpsert = new Account();
        List<Account> accountToUpsertList = new List<Account>();
        for(Account acc: accountList){
            accountToUpsert.Name = acc.Name;
            accountToUpsert.Production_Account_Id__c = acc.Id;
            accountToUpsertList.add(accountToUpsert);
        }
        Upsert accountToUpsertList;
        return accountToUpsertList;
        //Upsert accountToUpsertList Production_Account_Id__c;
    }
}