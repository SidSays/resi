/**************************************************************************************************
Name : MDUPropertyContractExtensionsTest
Date : 6 March 2015
User Story :
Description : This class use to test MDUPropertyContractExtensions class for contract list inline VF page on property page layout
Author : Jui Desai
***************************************************************************************************/

@isTest (seeAllData = false)
Private Class MDUPropertyContractExtensionsTest
{
    private static testMethod void MDUPropertyContractExtensionsTest(){ 
        SetupTestData.createCustomSettingRecords(); 
        Test.startTest();  
        
        
        MDU_Property__c  PropertObject = TestDataUtility.createProperty();
        Database.Insert(PropertObject);        
        
        List<Contract__c> ContractList = new List<Contract__c>(); 
        for(integer i = 0 ; i < 5; i++){
            Contract__c  ContractObject = TestDataUtility.createContract(PropertObject.id);
            ContractList.add(ContractObject);
        }
        Database.Insert(ContractList); 
        
        /* Initialise MDUPropertyContractExtensions*/ 
        PageReference pageRef = Page.MDUPropertyContract;
        Test.setCurrentPage(pageRef); 

        /* test for all contract selected for property to show in PrintSummary */
        pageRef.getParameters().put('id',PropertObject.id);
        MDUPropertyContractExtensions obj = new MDUPropertyContractExtensions(null); 
      
        Test.stopTest();
    }   
}