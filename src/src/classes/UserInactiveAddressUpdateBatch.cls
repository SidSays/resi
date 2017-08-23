/***************************************************************************************************************************************
 * Author     : Comcast Resi
 * Date       : 02-Sept-2015
 * Description: Batch Class will be used to update the Addresses associated to Inactive User.
***************************************************************************************************************************************/
global class UserInactiveAddressUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
  
    User addressQueue;
    
    global UserInactiveAddressUpdateBatch(){
        addressQueue = [Select Id, Name from User where Name ='Shared Data User'];
     }
       
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
     List<User> userList = [select Id from user where SystemModstamp=Yesterday AND IsActive = false];
     return DataBase.getQueryLocator([SELECT Id,Plan__c,OwnerId FROM customer_address__c WHERE OwnerId IN: userList]);
    }
    
    global void execute(Database.BatchableContext BC,List<customer_address__c> addressList)
    {
      Set<String> supSet =  new  Set<String>();
      List<customer_address__c> customAddressList = new List<customer_address__c>();
      List<User> userList1 = [select Id from user where SystemModstamp=Yesterday AND IsActive = false];
      
     /* Changes as per the user story US788828  */
      for(Team__c t1:[select Supervisor__c from Team__c where Supervisor__c IN :userList1]){
          supSet.add(t1.Supervisor__c);
      }

      for(customer_address__c addr : addressList){
          if(!supSet.isEmpty() &&supSet.contains(addr.OwnerId)){
          addr.OwnerId = addr.OwnerId;
        }else{
         addr.OwnerId = addressQueue.Id; 
         addr.Plan__c = null; 
        }
         customAddressList.add(addr);           
      } 
       update(customAddressList);
   } 
    
    global void finish(Database.BatchableContext BC)
    {
     // Get the ID of the AsyncApexJob representing this batch job
     // from Database.BatchableContext.
     // Query the AsyncApexJob object to retrieve the current job's information.
    
     AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id =:BC.getJobId()];

     // Send an email to the Apex job's submitter notifying of job completion.

     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     String[] toAddresses = new String[] {a.CreatedBy.Email};
     mail.setToAddresses(toAddresses);
     mail.setSubject('Apex Sharing Recalculation ' + a.Status);
     mail.setPlainTextBody
     ('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures.');
     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

}