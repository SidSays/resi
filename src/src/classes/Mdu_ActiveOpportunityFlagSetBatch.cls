/**************************************************************************************************
Name : ActiveOpportunityFlagSet
Description :This batch will use to set Active Opportunity flag on Property
base on Opportunity associated with that property, this is one time activity after deployment to production
Date : 17 Jun 2015
Author : Ashish Sonawane
***************************************************************************************************/

global class Mdu_ActiveOpportunityFlagSetBatch implements Database.Batchable<sObject>{ 
       
    private static final string QUERY_STRING = 'SELECT Id,Name FROM Mdu_Property__c ';
    private static final string TEST_LIMIT = ' limit 25';
    private static final string CLOSE_WON_STAGE = 'Closed Won';
    private static final string CLOSE_LOST_STAGE = 'Closed Lost'; 
    
    global Database.QueryLocator start(Database.BatchableContext batchableContext){
        String query = QUERY_STRING ;       
        if(Test.isRunningTest()) {
            query+= TEST_LIMIT;
        } 
        return Database.getQueryLocator(query);
    }
    
    /*
    * Execute business logic on data come in propertyList list
    */  
    global void execute(Database.BatchableContext batchableContext, LIST<Mdu_Property__c> propertyList){
        Set<Id> propertyIdSet = new Set<Id>();
        List<MDU_Property__c> propertyObjectList = new List<MDU_Property__c>(); 
        for(Mdu_Property__c propertyObj : propertyList){
            propertyIdSet.add(propertyObj.Id);            
        }
        for(MDU_Property__c propertyObject : [SELECT Id,Active_Opportunity__c, (SELECT Id,Property__C,Opportunity__c, Opportunity__r.StageName,
                                                                            Opportunity__r.Name
                                                                            FROM Opportunity_Properties__r ) 
                                                    FROM MDU_Property__c WHERE ID  IN:propertyIdSet                                                    
                                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){                                                                            
            boolean checkActive = false;
            for(Opportunity_Property__c optyPropetty : propertyObject.Opportunity_Properties__r){                                                              
                if(!CLOSE_WON_STAGE.equalsIgnoreCase(optyPropetty.Opportunity__r.StageName) 
                    && !CLOSE_LOST_STAGE.equalsIgnoreCase(optyPropetty.Opportunity__r.StageName)) {                                       
                    checkActive = true;                                              
                }
            }           
            if(propertyObject.Active_Opportunity__c != checkActive){
                propertyObject.Active_Opportunity__c = checkActive;               
                propertyObjectList.add(propertyObject);
            }                               
        }  
             
        Database.update(propertyObjectList,false);      
    }
    
   /*
    * Finish call for the batch
    */
    global void finish(Database.BatchableContext batchableContext) {
    
    }


}