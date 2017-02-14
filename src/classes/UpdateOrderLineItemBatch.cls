/***************************************************************************************************************************************
*Author: Apurva Gandhi, Accenture
*Description: This is a batch class to update existing orderlineitem records to update its activity status based on orederlineitems recon status
*Request id:456 (Develop batch job to update existing records with the new Recon Activity Status.)
*Date: 2-Dec-2013
***************************************************************************************************************************************/
global class UpdateOrderLineItemBatch implements Database.Batchable<sObject>{
    public string query ='SELECT id,RECON_Status__c,Order__c from Order_Line_Item__c where RECON_Status__c!= null AND Order__r.Activity_Status__c = null';
/*****************************************************
*description: Queries Order_Line_Item__c to process
*param: Database.BatchableContext bc    
*return: Database queryLocator
******************************************************/ 
    global Database.QueryLocator start (Database.BatchableContext bc){
    return Database.getQueryLocator(query);
    }  
/*****************************************************************************
*param: Database.BatchableContext BC, List<Activity_Cost__c> activityCostList
******************************************************************************/   
    global Void execute(Database.BatchableContext BC,List<Sobject> Scope){
        List<Order_Line_Item__c > OliList=new list<Order_Line_Item__c >();
        system.debug(scope);
        for(Order_Line_Item__c s : (List<Order_Line_Item__c >)scope){
            OliList.add(s);
            system.debug('Scope'+scope);
        }
        try{
        update OliList;
        }
        catch(System.DmlException e){
            for (Integer i = 0; i < e.getNumDml(); i++){
                // Process exception here
                System.debug(e.getDmlMessage(i)); 
            }
        }
    }
/***********************************
param: Database.BatchableContext bc
************************************/ 
    global void finish(Database.BatchableContext BC){
    }
}