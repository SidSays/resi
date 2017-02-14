/**************************************************************************************************
Name : MduContractWriteBackBatch
Description : This Batch class will execute on hourly basis to create contract record in SF from emptoris 
User Story : 47
Date : 12 January 2015
Author : Ashish Sonawane
***************************************************************************************************/
global class MduContractWriteBackBatch implements Database.Batchable<sObject>,Database.Stateful,  Database.AllowsCallouts{ 
  
    // Contract Id set to capture processed Contracts from Emptoris & set back status, terms as processed back to Emptoris
    private Set<String> contractIdSetUpdate = New Set<String>{};
      
    /*
    * Execute query
    */
    global Database.QueryLocator start(Database.BatchableContext batchableContext){
       // Query on User object to fetch a single record and pass call to execute method for Contract records processing.
       string query = 'select id from user limit 1';
       return Database.getQueryLocator(query);    
    }
    
    
    /*
    * Execute business logic on Contract (Active/Archived) data from Emptoris.
    */  
    global void execute(Database.BatchableContext batchableContext, List<User> uList){
        
        Set<string> contractIdSet = new Set<string>();         
        //Call tp process Contract and related child records
        MDU_ContractWriteBack.createContractDataOperation();      
        contractIdSet = MDU_ContractWriteBack.statusUpdatecontractIdSet;    
        if(contractIdSet!=null && !contractIdSet.isEmpty()){
            //Add processed contract in stateful varaible process in finish method for subStatus, term update callouts.
            contractIdSetUpdate.addAll(contractIdSet);        
        }           
    }
    
    
    /*
    * Finish call to execute callouts on Contracts successfully processed in SFDC.
    * Updates the subStatus, term in Emptoris
    */
    global void finish(Database.BatchableContext batchableContext) {
        
        //Check whether Contract's are Available to update sub-status, terms of contract at Emptoris
        if(contractIdSetUpdate!=null && !contractIdSetUpdate.isEmpty() ){            
            MDU_ContractWriteBack.successRequestExecute(contractIdSetUpdate);
        }
     }
    
}