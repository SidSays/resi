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
        oppList[0].Common_Area_Wide_WiFi_Ready__c = 'Yes';
        oppList[0].Property_Wide_WiFi_Ready__c = 'Yes';
        oppList[0].X3rd_Party_Consultant__c = 'Other';
        oppList[0].WiFi_Ready__c = 'Yes';
        
        MDU_Property__c MDUprop1 = TestDataUtility.createProperty();
        MDUprop1.Property_Type__c = 'CONDOMINIUM';
        MDUprop1.Common_Area_Wide_WiFi_Ready__c='Yes';
        MDUprop1.Property_Wide_WiFi_Ready__c='Yes';
        MDUprop1.WiFi_Ready__c='Yes';
        MDU_Property__c MDUprop2 = TestDataUtility.createProperty();
        MDUprop2.Property_Type__c = 'CONDOMINIUM';
        MDU_Property__c MDUprop3 = TestDataUtility.createProperty();
        MDUprop3.Property_Type__c = 'CONDOMINIUM';
        MDU_Property__c MDUprop4 = TestDataUtility.createProperty();
        MDUprop4.Property_Type__c = 'CONDOMINIUM';
        
        
        
        User u = TestDataUtility.createXCIntegrationUser();
        System.runAs(u){
                    
            Database.Insert(MDUprop1);          
            Database.Insert(oppList);       
            Opportunity_Property__c oppPropInst1 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop1.id); 
            oppPropInst1.Primary_Property__c = true;
            Database.insert(oppPropInst1);
            
            
            Database.Insert(MDUprop2);
            Database.Insert(MDUprop3);
            Database.Insert(MDUprop4);            
            Opportunity_Property__c oppPropInst2 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop2.id);
            Database.insert(oppPropInst2);
         
            Test.startTest();
                                    
                PageReference pageRef = Page.OpportunityPropertyPage;
                Test.setCurrentPage(pageRef); 
                ApexPages.StandardController sc = new ApexPages.standardController(oppPropInst1);
                ApexPages.currentPage().getParameters().put('oppId', oppList[0].id);
                
                OpportunityPropertyExtensions e = new OpportunityPropertyExtensions(sc);
                e.oppProperty.Property__c = MDUprop1.Id;
                e.doSave();
                e.doCancel();
                
                ApexPages.StandardController sc1 = new ApexPages.standardController(oppPropInst2);
                OpportunityPropertyExtensions op = new OpportunityPropertyExtensions(sc1);
                op.oppProperty.Id_List__c = MDUprop3.id+';'+MDUprop4.id+';';
                op.SelectedPropId = MDUprop4.id;
                op.showProps();
                op.removeProp();
                op.doSave();
                             
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
        oppList[0].Common_Area_Wide_WiFi_Ready__c = 'Yes';
        oppList[0].Property_Wide_WiFi_Ready__c = 'Yes';
        oppList[0].X3rd_Party_Consultant__c = 'Other';
        oppList[0].WiFi_Ready__c = 'Yes';
        
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
                e.SelectedPropId = null;
                e.removeProp();
                
            Test.stopTest();
        }    
    }

}