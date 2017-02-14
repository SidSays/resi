/***************************************************************************************************************************************
 * Author     : Jui Desai, Accenture
 * Date       : 02-June-2015
 * Description: This is Test class for "MDU_ParentAccountHierarchyController" Class
 * History
     Version             : 1.0
     Author Last Updated : Jui, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class MDU_ParentAccountHierarchyControllerTest{
    
    /*
    *Method to Create Parent Account and 3 child account
    */
    static testmethod void InsertDiffChildAcc(){ 

        TestDataUtility.createCustomSettingRecords();       
        Id currentProfileId = UserInfo.getProfileId();
        TestDataUtility.setAllowParentAccChange(currentProfileId);        
        
        Test.startTest();
        Account parentAcc= TestDataUtility.createAccount();
        parentAcc.Name = 'Hometown America';
        parentAcc.Is_Parent_Organization__c= true;
        Database.insert(parentAcc);     
        List<Account> acc = new List<Account>();
        for(integer i =0; i<3; i++){
            
            Account accObj = TestDataUtility.createAccount();
            accObj.ParentAccountSelection__c= 'Hometown America [PARENT]';
            acc.add(accObj);
        }
        Database.insert(acc);
        
        List<Account> accList= [select id, name from Account where id in:acc];
        
        MDU_Property__c propObj = TestDataUtility.createProperty();
        propObj.Owner_Account__c = accList[0].id;
        propObj.Management_Company__c = accList[1].id;
        propObj.Developer__c = accList[2].id;
        Database.insert(propObj);   
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(parentAcc);
        MDU_ParentAccountHierarchyController ParentAccountHierarchyObj = new MDU_ParentAccountHierarchyController(stdCon);
        MDU_ParentAccountHierarchyController.queryStringAccountId = parentAcc.id;
        MDU_ParentAccountHierarchyController.getParentAccountData(); 
        Test.stopTest();
    }
    
    /*
    *Method to Create Parent Account and 1 child account
    */
    static testmethod void InsertSameChildAcc(){ 

        TestDataUtility.createCustomSettingRecords();       
        Id currentProfileId = UserInfo.getProfileId();
        TestDataUtility.setAllowParentAccChange(currentProfileId);        
        
        Test.startTest();
        Account parentAcc= TestDataUtility.createAccount();
        parentAcc.Name = 'Hometown America';
        parentAcc.Is_Parent_Organization__c= true;
        Database.insert(parentAcc);     
        Account accObj = TestDataUtility.createAccount();
        accObj.ParentAccountSelection__c= 'Hometown America [PARENT]';
        Database.insert(accObj);

        MDU_Property__c propObj = TestDataUtility.createProperty();
        propObj.Owner_Account__c = accObj.id;
        propObj.Management_Company__c = accObj.id;
        propObj.Developer__c = accObj.id;
        Database.insert(propObj);   
        
        Contract__c conObj = TestDataUtility.createContract(propObj.id);
        Database.insert(conObj);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(parentAcc);
        MDU_ParentAccountHierarchyController ParentAccountHierarchyObj = new MDU_ParentAccountHierarchyController(stdCon);
        MDU_ParentAccountHierarchyController.queryStringAccountId = accObj.id;
        MDU_ParentAccountHierarchyController.getParentAccountData(); 
        Test.stopTest();
    }
    
    /*
    *Method to Create Parent Account, 3 child account and 2 property
    */
    static testmethod void InsertTwoProperty(){ 

        TestDataUtility.createCustomSettingRecords();       
        Id currentProfileId = UserInfo.getProfileId();
        TestDataUtility.setAllowParentAccChange(currentProfileId);        
        
        Test.startTest();
        Account parentAcc= TestDataUtility.createAccount();
        parentAcc.Name = 'Hometown America';
        parentAcc.Is_Parent_Organization__c= true;
        Database.insert(parentAcc);     
        List<Account> acc = new List<Account>();
        for(integer i =0; i<3; i++){
            
            Account accObj = TestDataUtility.createAccount();
            accObj.ParentAccountSelection__c= 'Hometown America [PARENT]';
            acc.add(accObj);
        }
        Database.insert(acc);
        
        List<Account> accList= [select id, name from Account where id in:acc];
        List<MDU_Property__c> propList = new List<MDU_Property__c>();
        
        MDU_Property__c propObj = TestDataUtility.createProperty();
        propObj.Owner_Account__c = accList[1].id;
        propObj.Management_Company__c = accList[2].id;
        propObj.Developer__c = accList[0].id;
        propList.add(propObj);
        
        MDU_Property__c propObj1 = TestDataUtility.createProperty();
        propObj1.Owner_Account__c = accList[2].id;
        propObj1.Management_Company__c = accList[0].id;
        propObj1.Developer__c = accList[1].id;
        propList.add(propObj1); 
        
        Database.insert(propList);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(parentAcc);
        MDU_ParentAccountHierarchyController ParentAccountHierarchyObj = new MDU_ParentAccountHierarchyController(stdCon);
        MDU_ParentAccountHierarchyController.queryStringAccountId = parentAcc.id;
        MDU_ParentAccountHierarchyController.getParentAccountData(); 
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
        Account parentAcc= TestDataUtility.createAccount();
        parentAcc.Name = 'Hometown America';
        parentAcc.Is_Parent_Organization__c= true;
        Database.insert(parentAcc);     
        Account accObj = TestDataUtility.createAccount();
        accObj.ParentAccountSelection__c= 'Hometown America [PARENT]';
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
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(parentAcc);
        MDU_ParentAccountHierarchyController ParentAccountHierarchyObj = new MDU_ParentAccountHierarchyController(stdCon);
        MDU_ParentAccountHierarchyController.queryStringAccountId = accObj.id;
        MDU_ParentAccountHierarchyController.getParentAccountData(); 
        Test.stopTest();
    }
}