@isTest
public with sharing class ApplicationLogTriggerHelperTest {
    @isTest static void createApplicationLog(){ 
    
        TriggerSettings__c applicationLogTrigger = new TriggerSettings__c();
        applicationLogTrigger.Name = 'ApplicationLogTrigger';
        applicationLogTrigger.isActive__c = True;
        insert applicationLogTrigger;
        
         List<Opportunity> testOpportunity = TestDataUtility.createOpportunity(1);
        Database.insert(testOpportunity[0]);
            Application_Log__c objApplicationLog = new Application_Log__c();
            objApplicationLog.Start_Time__c = System.Now();
            objApplicationLog.End_Time__c = System.Now()+2;
            objApplicationLog.OpportunityID__c = testOpportunity[0].Id;
            objApplicationLog.isSuccess__c = true;
            Database.insert(objApplicationLog);
            
            objApplicationLog.FlagForOpportunity__c = true;
            Database.update(objApplicationLog);     }
}