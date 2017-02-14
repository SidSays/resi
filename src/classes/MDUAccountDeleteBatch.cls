/**************************************************************************************************
Name : MDUAccountDeleteBatch
Description : This Batch class will auto-delete an Account, under the following conditions: 
- No related records on the Account except Contact records (Opportunity, Property etc.)
- Account Type = Owner, Management Company, Developer 
- Parent Organization flag = FALSE  
User Story : 47
Date : 12 January 2015
Author : Abhishek Mathur
***************************************************************************************************/
global class MDUAccountDeleteBatch implements Database.Batchable<sObject>, Database.Stateful { 
          
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = System.Label.Xffinity_Account_Delete_Batch_Name;
    private static final string QUERY_STRING = 'select Id, Is_Parent_Organization__c, Name from Account  where Is_Parent_Organization__c = false and RecordTypeId IN: recordTypeIds  ';
    private static final string OBJECT_TYPE = 'Account';
    private static final string TEST_LIMIT = ' limit 25';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';
    private static final string DEVELOPER_NAME = '';
    private static final string RECORD_TYPE_SEPERATION = ';';
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private Id jobStatusId = null; 
   
    /*
    * Query execution for AutoRenewMduContractBatch
    */
    global Database.QueryLocator start(Database.BatchableContext batchableContext){
            
        //Create Job Status Object
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME + JOB_NAME_SPACE  + Datetime.now();
        jobStatus.Status__c = JOB_STATUS;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Total_RGU_Activations_Processed__c = 0;
        jobStatus.Total_RGU_Orders_Processed__c = 0;
        jobStatus.Total_RGU_ORders_Upserted_Today__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = JOB_COMMENT;
        jobStatus.Number_Of_Fallouts__c = 0;
        Database.insert(jobStatus);  
        jobStatusId = jobStatus.Id;
               
        Set<Id> recordTypeIds = new Set<Id>();      
        String labelName = System.Label.XfinityAccountRecordType;  
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(RECORD_TYPE_SEPERATION)){
                recordTypeIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }          
        String query = QUERY_STRING ;       
        if(Test.isRunningTest()) {
            query+= TEST_LIMIT;
        } else {
            query+= ' AND CreatedDate< LAST_N_DAYS:7 ';
        }
        return Database.getQueryLocator(query);
    }
    
    
    /*
    * Execute business logic on data come in propertyList list
    */  
    global void execute(Database.BatchableContext batchableContext, LIST<Account> listOfAccounts){
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);  
        try{                 
            //Execution Logic       
            LIST<Account> accountsForDeletionList = new LIST<Account>();
            Set<Id> accountIdsWithAssociatn = new Set<Id>(); 
            Set<Id> accountIdSet = new Set<Id>();
            //Store account id in set of account id
            for(Account selectedAccount: listOfAccounts){                            
                accountIdSet.add(selectedAccount.Id);          
            }
            
            //Get Map of associated Opportunity
            For(Opportunity opp: [Select id, Name, AccountId from Opportunity where AccountId IN: accountIdSet]){            
                if(null != opp.AccountId){
                    accountIdsWithAssociatn.add(opp.AccountId);
                }else{}
            }
    
            for(MDU_Property__c prop: [Select id, Name, Owner_Account__c, Management_Company__c, Developer__c  from MDU_Property__c 
                                                    where Owner_Account__c IN: accountIdSet OR  Management_Company__c IN: accountIdSet OR Developer__c IN: accountIdSet]){
                if(null != prop.Owner_Account__c){
                    accountIdsWithAssociatn.add(prop.Owner_Account__c);
                } else{}
                if(null != prop.Management_Company__c){
                    accountIdsWithAssociatn.add(prop.Management_Company__c);
                } else{}
                if(null != prop.Developer__c){
                    accountIdsWithAssociatn.add(prop.Developer__c);
                } else{}
            }
            //Check Whether Account Exist In Contract Record
            for(Contract__c contact : [select Account_Name__c from Contract__c where Account_Name__c In : accountIdSet]){
                if(null != contact.Account_Name__c){ 
                 accountIdsWithAssociatn.add(contact.Account_Name__c);
                } else{}
            }        
            
            //Logic to delete the record
            for(Account acc: listOfAccounts){                                 
                 // Check condition to ensure record meets criteria for deletion
                 if(!accountIdsWithAssociatn.contains(acc.Id)){
                     // Mark for Deletion
                     accountsForDeletionList.add(acc);
                 } else{}                   
            }        
            
            // Delete Records and clear Recycle Bin       
            if(!accountsForDeletionList.isEMpty()){        
                Database.DeleteResult[] saveResult = Database.delete(accountsForDeletionList , false);                
                DataBase.emptyRecycleBin(accountsForDeletionList);                
                if(jobStatus!=null && !jobStatus.isEmpty()){
                    for (Database.DeleteResult result : saveResult) {
                        jobStatus[0].Total_Records_Processed__c ++;
                        if(!result.isSuccess()){                                                 
                            for (Database.Error error : result.getErrors()) {
                                jobStatus[0].Number_Of_Fallouts__c  ++;
                                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + NEW_LINE;                                    
                                jobStatus[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;                                                                 
                             }
                        } else{}       
                    }
                    Database.update(jobStatus[0]);
                }
                
            }
        }
        catch(Exception e) {
            if(jobStatus!=null && !jobStatus.isEmpty()){
                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                    
                jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0]);   
            }           
        } 
    }
              
    /*
    * Finish call for the batch
    */
    global void finish(Database.BatchableContext batchableContext) {
      //Add Job Status       
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        if(jobStatus!=null && !jobStatus.isEmpty()){
            jobStatus[0].Batch_End_Time__c = Datetime.now();
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ;   
            Database.update(jobStatus[0]);  
        }       
    }
     
    /*
    /*Get job status
    */       
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        return [SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                Total_RGU_ORders_Upserted_Today__c 
                FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId];
    }  

}