/***************************************************************************************************************************************
 * Author     : Jui Desai, Accenture
 * Date       : 02-June-2015
 * Description: This is Test class for "MDU_PortfolioAccountHierarchyController" Class
 * History
     Version             : 1.0
     Author Last Updated : Jui, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class MDU_PortfolioAccHierarchyCtrlTest{
    
    /*
    *Method to Create account with Property having owner acc and contract
    */
    static testmethod void InsertOwnerAcc(){ 

        TestDataUtility.createCustomSettingRecords();       
        Id currentProfileId = UserInfo.getProfileId();
        TestDataUtility.setAllowParentAccChange(currentProfileId);        
        
        Test.startTest();     
        Account accObj = TestDataUtility.createAccount();
        Database.insert(accObj);

        MDU_Property__c propObj = TestDataUtility.createProperty();
        propObj.Owner_Account__c = accObj.id;
        Database.insert(propObj);   
        
        Contract__c conObj = TestDataUtility.createContract(propObj.id);
        Database.insert(conObj);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(accObj);
        MDU_PortfolioAccountHierarchyController ParentAccountHierarchyObj = new MDU_PortfolioAccountHierarchyController(stdCon);
        MDU_PortfolioAccountHierarchyController.queryStringAccountId = accObj.id;
        MDU_PortfolioAccountHierarchyController.getAccountData(); 
        Test.stopTest();
    }
    
    /*
    *Method to Create account with Property having managemnet company account and contract
    */
    static testmethod void InsertManagementAcc(){ 

        TestDataUtility.createCustomSettingRecords();       
        Id currentProfileId = UserInfo.getProfileId();
        TestDataUtility.setAllowParentAccChange(currentProfileId);        
        
        Test.startTest();     
        Account accObj = TestDataUtility.createAccount();
        Database.insert(accObj);

        MDU_Property__c propObj = TestDataUtility.createProperty();
        propObj.Management_Company__c = accObj.id;
        Database.insert(propObj);   
        
        Contract__c conObj = TestDataUtility.createContract(propObj.id);
        Database.insert(conObj);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(accObj);
        MDU_PortfolioAccountHierarchyController ParentAccountHierarchyObj = new MDU_PortfolioAccountHierarchyController(stdCon);
        MDU_PortfolioAccountHierarchyController.queryStringAccountId = accObj.id;
        MDU_PortfolioAccountHierarchyController.getAccountData(); 
        Test.stopTest();
    }
    
    /*
    *Method to Create account with Property having developer account and contract
    */
    static testmethod void InsertDeveloperAcc(){ 

        TestDataUtility.createCustomSettingRecords();       
        Id currentProfileId = UserInfo.getProfileId();
        TestDataUtility.setAllowParentAccChange(currentProfileId);        
        
        Test.startTest();     
        Account accObj = TestDataUtility.createAccount();
        Database.insert(accObj);

        MDU_Property__c propObj = TestDataUtility.createProperty();
        propObj.Developer__c = accObj.id;
        Database.insert(propObj);   
        
        Contract__c conObj = TestDataUtility.createContract(propObj.id);
        Database.insert(conObj);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(accObj);
        MDU_PortfolioAccountHierarchyController ParentAccountHierarchyObj = new MDU_PortfolioAccountHierarchyController(stdCon);
        MDU_PortfolioAccountHierarchyController.queryStringAccountId = accObj.id;
        MDU_PortfolioAccountHierarchyController.getAccountData(); 
        Test.stopTest();
    }
    
    /*
    *Method to Create account with two Account
    */
    static testmethod void InsertTwoAcc(){ 

        TestDataUtility.createCustomSettingRecords();       
        Id currentProfileId = UserInfo.getProfileId();
        TestDataUtility.setAllowParentAccChange(currentProfileId);        
        
        Test.startTest();     
        Account accObj = TestDataUtility.createAccount();
        Database.insert(accObj);
        Account accObj1 = TestDataUtility.createAccount();
        Database.insert(accObj1);

        MDU_Property__c propObj = TestDataUtility.createProperty();
        propObj.Developer__c = accObj.id;
        propObj.Owner_Account__c = accObj.id;
        propObj.Management_Company__c = accObj1.id;
        Database.insert(propObj);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(accObj);
        MDU_PortfolioAccountHierarchyController ParentAccountHierarchyObj = new MDU_PortfolioAccountHierarchyController(stdCon);
        MDU_PortfolioAccountHierarchyController.queryStringAccountId = accObj.id;
        MDU_PortfolioAccountHierarchyController.getAccountData(); 
        Test.stopTest();
    }
 
    /*
    *Method to Create Parent Account and 1 child account and 1 Opportunity
    */
    static testmethod void InsertOppAcc(){ 

        TestDataUtility.createCustomSettingRecords();       
        Id currentProfileId = UserInfo.getProfileId();
        TestDataUtility.setAllowParentAccChange(currentProfileId); 
        
        Test.startTest();
        Account accObj = TestDataUtility.createAccount();
        Database.insert(accObj);

        MDU_Property__c propObj = TestDataUtility.createProperty();
        propObj.Owner_Account__c = accObj.id;
        propObj.Management_Company__c = accObj.id;
        propObj.Developer__c = accObj.id;
        Database.insert(propObj);   
        
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        System.runAs(xcUser){  
            List<Opportunity> oppList = TestDataUtility.createOpportunity(1);
            oppList[0].AssignedAE_ID__c = xcUser.id;
            oppList[0].property__c = propObj.id;
            Database.insert(oppList);
        }
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(accObj);
        MDU_PortfolioAccountHierarchyController ParentAccountHierarchyObj = new MDU_PortfolioAccountHierarchyController(stdCon);
        MDU_PortfolioAccountHierarchyController.queryStringAccountId = accObj.id;
        MDU_PortfolioAccountHierarchyController.getAccountData(); 
        Test.stopTest();
    }
}