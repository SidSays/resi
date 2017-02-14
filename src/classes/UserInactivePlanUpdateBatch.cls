/***************************************************************************************************************************************
 * Author     : Comcast Resi
 * Date       : 02-Sept-2015
 * Description: Batch Class will be used to update the Addresses associated to Inactive User.
***************************************************************************************************************************************/

global class UserInactivePlanUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        List<User> userList = [SELECT Id FROM user where SystemModstamp= Yesterday AND IsActive = false AND ManagerID != null]; // Updated on 12/22/2016 for US905258 by Radhika         
            return DataBase.getQueryLocator([SELECT Id, User__r.ManagerID FROM Plan__c  WHERE Plan_Status__c != 'Expired' AND Plan_Level__c != 'Bulk' AND Plan_Level__c != 'Playlist' AND User__c in : userList]);
      
    }
    
    global void execute(Database.BatchableContext BC,List<Plan__c> planList)
    {
    //   RecursiveTriggerHandler.isFirstTimePlanTriggerBeforeUpdate = false;
        List<Plan__c> updatePlans=new list<Plan__c>();
        if(!planList.isEmpty()){ // Added on 12/22/2016 for US905258 by Radhika 
            for(Plan__c p : planList){
                p.User__c = p.User__r.ManagerID;
                updatePlans.add(p);
                }
            
            update updatePlans;
        }
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