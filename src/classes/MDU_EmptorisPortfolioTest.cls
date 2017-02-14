/**
* This class contains unit tests for MDU_EmptorisPortfolio
* Created: 18-May-2015
* Author : Ritesh Saxena
*/
@isTest(seeAllData=false)
private class MDU_EmptorisPortfolioTest {
    
    private static testMethod void generateMappingData() {
        
        List<MDU_Property__c> pList = new List<MDU_Property__c>();
        List<Opportunity_Property__c> oppPropList = new List<Opportunity_Property__c>();
        Map<string, String> franchiseLegalMap = new Map<String, String>();
        
        // Create CS data for Trigger execution
        TestDataUtility.createCustomSettingRecords();
        // Create Custom setting Record for Emptoris Field Mapping
        TestDataUtility.createEmptorisFieldMapping();
        
        
        //create Legal & Franchise data
        List<Franchise__c> franchiseList = TestDataUtility.createFranchiseList();
        database.insert(franchiseList);
        
        for(Franchise__c fObj : [Select Id, Franchise_Name__c, Legal_Entity__c from Franchise__c where Id in: franchiseList]){
            franchiseLegalMap.put(fObj.Franchise_Name__c, ''+ fObj.Id +'-'+ fObj.Legal_Entity__c);          
        }
        
        Account acc = TestDataUtility.createAccount();
        database.insert(acc);
                
        Franchise__c franchise = TestDataUtility.createFranchise();
        MDU_Property__c p = TestDataUtility.createProperty();
            p.Industry_Type__c = 'Government';
            p.MDU_State__c = 'Alaska';
            p.Number_of_Units__c = 5;
            p.Comcast_Data_Serviced__c = 'Yes';
            p.Developer__c = acc.id;
            p.Video_Billing_Type__c = 'Bulk';
            p.Franchise_New__c  = 'Aberdeen Town-Alabama T.V. Cable, Inc.';
            p.Franchise_Legal_ID__c = franchiseLegalMap.get('Aberdeen Town');
            pList.add(p);
            
        MDU_Property__c p2 = TestDataUtility.createProperty();
            p2.Industry_Type__c = 'Government';
            p2.MDU_State__c = 'Alabama';
            p2.Number_of_Units__c = 15;
            p2.Comcast_Data_Serviced__c = 'Yes';
            p2.Developer__c = acc.id;
            p2.Video_Billing_Type__c = 'Bulk';
            p2.Franchise_New__c  = 'Abbeville City-Adelphia Cablevision of West Palm Beach III, LLC';
            p2.Franchise_Legal_ID__c = franchiseLegalMap.get('Abbeville City');         
            pList.add(p2);
                       
        database.insert(pList);

        User u = TestDataUtility.createXCIntegrationUser();
        TestDataUtility.bypassValidationCS(u.Id);
        
        System.runAs(u){ 
            List<Opportunity> oppList = TestDataUtility.createOpportunity(1);
            oppList[0].Video_Bulk_Proposed_Rate__c = 2;
            oppList[0].Voice_Bulk_Proposed_Rate__c = 2;
            oppList[0].Data_Bulk_Proposed_Rate__c = 2;
            oppList[0].Property__c = pList[0].Id;
            database.insert(oppList);
            
            Opportunity_Property__c oppProp1 = TestDataUtility.createOppProperty(oppList[0].Id, pList[1].Id);
            oppPropList.add(oppProp1);
            database.insert(oppPropList);
            
            List<MDU_EmptorisPortfolio.WrapperProp> objList = MDU_EmptorisPortfolio.getPropertyInfo(oppList[0].Id);
            system.assert(objList.size()>0);
            system.assert(objList[0].PropertyComplexId !=null);           
        }             
    }

}