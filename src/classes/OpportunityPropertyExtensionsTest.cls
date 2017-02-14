/**************************************************************************************************
Name : OpportunityPropertyExtensionsTest 
Date : 02 March 2015
Description : This class use to test MDU Property Extension Class created for Opportunity Property Junction Object
Author : Sagar Gurav
***************************************************************************************************/
@isTest
private class OpportunityPropertyExtensionsTest {
   
    /*
    * Validate Opportunity Property insert call
    */
     private static testMethod void OppPropertyExtensionsSaveCancel() {
        // Create test data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        Database.Insert(acc);        
      
        List<Opportunity> oppList = TestDataUtility.createOpportunity(4);   
        oppList[0].StageName = 'Closed Won';    
        oppList[0].ContractTermUnit__c = 'months';
        oppList[0].ContractTerm__c = 2;
        oppList[0].AccountId = acc.id;
        oppList[0].Contract_Type__c = 'Bulk';
        oppList[0].Fiber_To_The_Unit__c = 'Fiber to the Unit';
        
        MDU_Property__c MDUprop1 = TestDataUtility.createProperty();
        MDUprop1.Property_Type__c = 'CONDOMINIUM';
        
        
        User u = TestDataUtility.createXCIntegrationUser();
        System.runAs(u){
                    
            Database.Insert(MDUprop1);          
            Database.Insert(oppList);       
            Opportunity_Property__c oppPropInst1 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop1.id); 
            oppPropInst1.Primary_Property__c = true;
            Database.insert(oppPropInst1); 
         
            Test.startTest();
                                    
                PageReference pageRef = Page.OpportunityPropertyPage;
                Test.setCurrentPage(pageRef); 
                ApexPages.StandardController sc = new ApexPages.standardController(oppPropInst1);
                ApexPages.currentPage().getParameters().put('oppId', oppList[0].id);
                
                OpportunityPropertyExtensions e = new OpportunityPropertyExtensions(sc);
                e.oppProperty.Property__c = MDUprop1.Id;
                e.doSave();
                e.doCancel();
            Test.stopTest();
        }    
    }
    
    /*
    * Opportunity Property save- Negative test 
    */
     private static testMethod void OppPropertyExtNegativeTest() {
        // Create test data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        Database.Insert(acc);        
      
        List<Opportunity> oppList = TestDataUtility.createOpportunity(4);   
        oppList[0].StageName = 'Closed Won';    
        oppList[0].ContractTermUnit__c = 'months';
        oppList[0].ContractTerm__c = 2;
        oppList[0].AccountId = acc.id;
        oppList[0].Contract_Type__c = 'Bulk';
        oppList[0].Fiber_To_The_Unit__c = 'Fiber to the Unit';
        
        MDU_Property__c MDUprop1 = TestDataUtility.createProperty();
        MDUprop1.Property_Type__c = 'CONDOMINIUM';
        
        
        User u = TestDataUtility.createXCIntegrationUser();
        System.runAs(u){
                    
            Database.Insert(MDUprop1);          
            Database.Insert(oppList);       
            Opportunity_Property__c oppPropInst1 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop1.id); 
            oppPropInst1.Primary_Property__c = true;
            Database.insert(oppPropInst1); 
         
            Test.startTest();
                                    
                PageReference pageRef = Page.OpportunityPropertyPage;
                Test.setCurrentPage(pageRef); 
                ApexPages.StandardController sc = new ApexPages.standardController(oppPropInst1);
                ApexPages.currentPage().getParameters().put('oppId', oppList[0].id);
                
                OpportunityPropertyExtensions e = new OpportunityPropertyExtensions(sc);
                // Remove Property binding //e.oppProperty.Property__c = MDUprop1.Id;
                e.doSave();
                e.doCancel();
            Test.stopTest();
        }    
    }

}