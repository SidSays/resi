/**************************************************************************************************
Name : UpdateBillerPurgedArchiveBatch
Description : This batch class created to go over the accounts with "Biller Purged" flag as true and 
check if this account has any related "order", "opportunity" and other object records. 
If no related records found, set the flag "Biller Purged Archive" as true. 
User Story : US561665
Date : 30 September 2015
Author : Rahul Prabhakar
***************************************************************************************************/
global class UpdateBillerPurgedArchiveBatch implements Database.Batchable<sObject>,  Database.Stateful {
    /*
    * Data Member 
    */      
    global final String query;
    
    global UpdateBillerPurgedArchiveBatch(String queryString){
        //String query = 'Select Id,Name,Biller_Purged__c,Biller_Purged_Archive__c From Account where Biller_Purged__c = True';
        query = queryString;
    }
    
   global Database.QueryLocator start(Database.BatchableContext BC){
        /*
        * Query execution to fetch all accounts based on Biller_Purged__c = True
        */
        //query = 'Select Id,Name,Biller_Purged__c,Biller_Purged_Archive__c From Account where Biller_Purged__c = True';       
        return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<Account> scope){
       try{  
           List<Account> accountsUpdated= new List<Account>();
           List<Id> accountIdList = new List<Id>();
           for(Account accountList: scope)
           {
            accountIdList.add(accountList.Id);
           }
               
           /* Update the field Biller_Purged_Archive__c = True in Account records for which there is no related orders and opportunities */
           for(Account accountRecords : [Select Id,(Select Id From Opportunities),(Select Id From OrderContracts__r) From Account where Id IN: accountIdList])
           {
                if(accountRecords.Opportunities.size() == 0 && accountRecords.OrderContracts__r.size() == 0){
                    accountRecords.Biller_Purged_Archive__c = True;
                    accountsUpdated.add(accountRecords);
                }
           }
           Database.SaveResult[] updateAccount = Database.Update(accountsUpdated,false);
        } catch(Exception e) {
             system.debug('Exception in UpdateBillerPurgedArchiveBatch***'+ e.getMessage());
        }
    }
   
   //Execute Finish logic after execution of batch records completed
   global void finish(Database.BatchableContext BC){
        // No action
    }
  
}