@isTest
private class UpdateBillerPurgedArchiveBatchTest{
static testmethod void method() {
    Account account= new Account();
    account.Name = 'New Account';
    account.Biller_Purged__c = true;
    account.Biller_Purged_Archive__c = false;
    insert account;
    Test.startTest();
        String query = 'Select Id,Name,Biller_Purged__c,Biller_Purged_Archive__c From Account where Biller_Purged__c = True ';
        Database.executeBatch(new UpdateBillerPurgedArchiveBatch(query),200);
    Test.stopTest();
  }
}