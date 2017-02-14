/*
    Class        : MDU_ViewDeleteContractPageCtrlTest   
    Description  :This class use to test MDU_ViewContractPageCtrl using Mock HttpResponse
    Created Date : 21 May 2015
    Created By   : Ashish Sonawane
*/
@isTest
public class MDU_ViewDeleteContractPageCtrlTest{
         
    private static final string LABEL_NAME_SPLIT = ';';
   
    /*
    * Mock call out for viewContractTestWithECMIdRun with positive response.
    */
    @isTest static void viewContractTestWithECMIdRun() {
       
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser){           
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);  
            List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
            Database.insert(listCustomSet); 
            createOpptyPropertyRecord(true);
        }
                                               
        Test.startTest();
        
        Id oppPropertyId = [Select Id from Opportunity_Property__c ].Id;        
        // Set mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForViewContract(true));
        MDU_ViewContractPageCtrl.viewContract(oppPropertyId); 
          
        Test.stopTest();
    }
    
    
    /*
    * Mock call out with fail response to read contract data.
    */
    @isTest static void viewContractFail1TestWithECMIdRun() {
       
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser){           
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);  
            List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
            Database.insert(listCustomSet); 
            createOpptyPropertyRecord(true);
        }
                                                
        Test.startTest();        
        Id oppPropertyId = [Select Id from Opportunity_Property__c ].Id;        
        // Set mock callout 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForViewContract(false,1));
        MDU_ViewContractPageCtrl.viewContract(oppPropertyId);         
        System.assertEquals(true,MDU_ContractServices.finalResult.contains('Authentication failed'));
        Test.stopTest();
    }
    
     /*
    * Mock call out with fail response to get url to see Emptoris contract.
    */
    @isTest static void viewContractFail2TestWithECMIdRun() {
       
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser){           
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);  
            List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
            Database.insert(listCustomSet); 
            createOpptyPropertyRecord(true);
        }
                                                
        Test.startTest();        
        Id oppPropertyId = [Select Id from Opportunity_Property__c ].Id;        
        // Set mock callout 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForViewContract(false,2));
        MDU_ViewContractPageCtrl.viewContract(oppPropertyId);         
        System.assertEquals(true,MDU_ContractServices.finalResult.contains('Authentication failed'));
        Test.stopTest();
    }
    
    
    /*
    * Mock call out for deleteContractTestWithECMIdRun with positive response.
    */
    @isTest static void deleteContractTestWithECMIdRun() {
       
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser){           
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);  
            List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
            Database.insert(listCustomSet); 
            createOpptyPropertyRecord(true);
        }
      
                                           
        Test.startTest();        
        Id oppPropertyId = [Select Id from Opportunity_Property__c ].Id;        
        // Set mock callout class to delete contract
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForDeleteContract(true));
        MDU_DeleteContractPageCtrl.deleteContract(oppPropertyId); 
        Test.stopTest();
    }
    
    
    /*
    * Mock call out for  with fail response1.
    */
    @isTest static void deleteContractFailResp1TestWithECMIdRun() {
       
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser){           
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);  
            List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
            Database.insert(listCustomSet); 
            createOpptyPropertyRecord(true);
        }
                                               
        Test.startTest();        
        Id oppPropertyId = [Select Id from Opportunity_Property__c ].Id;        
        // Set mock callout 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForDeleteContract(false,1));
        MDU_DeleteContractPageCtrl.deleteContract(oppPropertyId); 
        System.assertEquals(true,MDU_ContractServices.finalResult.contains('Authentication failed'));     
        Test.stopTest();
    }
    
    /*
    * Mock call out for  with fail response2.
    */
    @isTest static void deleteContractFailResp2TestWithECMIdRun() {
       
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser){           
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);  
            List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
            Database.insert(listCustomSet); 
            createOpptyPropertyRecord(true);
        }
                                               
        Test.startTest();        
        Id oppPropertyId = [Select Id from Opportunity_Property__c ].Id;        
        // Set mock callout 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForDeleteContract(false,2));
        MDU_DeleteContractPageCtrl.deleteContract(oppPropertyId); 
        System.assertEquals(true,MDU_ContractServices.finalResult.contains('Authentication failed'));     
        Test.stopTest();
    }
    
    /*
    * Mock call out for  with fail response3.
    */
    @isTest static void deleteContractFailResp3TestWithECMIdRun() {
       
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser){           
            TestDataUtility.setApplicationLogEnableCS(currentProfileId);  
            List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
            Database.insert(listCustomSet); 
            createOpptyPropertyRecord(true);
        }
                                               
        Test.startTest();        
        Id oppPropertyId = [Select Id from Opportunity_Property__c ].Id;        
        // Set mock callout 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForDeleteContract(false,3));
        MDU_DeleteContractPageCtrl.deleteContract(oppPropertyId); 
        System.assertEquals(true,MDU_ContractServices.finalResult.contains('Authentication failed'));     
        Test.stopTest();
    }
    
   /*
    * Mock call out for deleting contract with property that doesn't have ECM Id 
    */
    @isTest static void deleteContractTestWithoutECMIdRun() {
        
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser){           
           
           TestDataUtility.setApplicationLogEnableCS(currentProfileId);             
            List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
            Database.insert(listCustomSet); 
            createOpptyPropertyRecord(false);
        }
                                                
        Test.startTest();         
        Id oppPropertyId = [Select Id from Opportunity_Property__c ].Id;        
        // Set mock callout class to view contract  
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForDeleteContract(true));
        MDU_DeleteContractPageCtrl.deleteContract(oppPropertyId);       
        System.assertEquals(true,MDU_ContractServices.finalResult.contains('Contract already deleted OR Contract Id does not exist'));
        Test.stopTest();
    }
    
    /*
    * Mock call out for viewContractTestWithECMIdRun with negative test without ECM Id.
    */
    @isTest static void viewContractTestWithoutECMIdRun() {
        
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser){           
           
           TestDataUtility.setApplicationLogEnableCS(currentProfileId);             
            List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
            Database.insert(listCustomSet); 
            createOpptyPropertyRecord(false);
        }
                                                
        Test.startTest();         
        Id oppPropertyId = [Select Id from Opportunity_Property__c ].Id;        
        // Set mock callout class to view contract  
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForViewContract(true));
        MDU_ViewContractPageCtrl.viewContract(oppPropertyId);  
        Test.stopTest();
    }
    
    
   /*
    * Cover exception in MDU_ViewContractPageCtrlTest 
    */
    @isTest static void viewContractTestWithException() {
        
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser){           
           
           TestDataUtility.setApplicationLogEnableCS(currentProfileId);             
            List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
            Database.insert(listCustomSet); 
            createOpptyPropertyRecord(true);
        }
                                                
        Test.startTest();         
        Id oppPropertyId = 'a21K0000000xpk9';//[Select Id from Opportunity_Property__c ].Id;        
        // Set mock callout class to view contract  
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseForViewContract(true));
        MDU_ViewContractPageCtrl.viewContract(oppPropertyId);  
        Test.stopTest();
    }   
    
   /*
    * method cover exception in MDU_ViewContractPageCtrlTest
    */
    @isTest static void deleteContractTestWithException() {
        
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser){           
           
           TestDataUtility.setApplicationLogEnableCS(currentProfileId);             
            List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
            Database.insert(listCustomSet); 
            createOpptyPropertyRecord(true);
        }
                                                
        Test.startTest();         
        Id oppPropertyId = 'a21K0000000xpk9';//[Select Id from Opportunity_Property__c ].Id;        
        // Set mock callout class to view contract  
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseForDeleteContract(true));
        MDU_DeleteContractPageCtrl.deleteContract(oppPropertyId);       
        //System.assertEquals(true,MDU_ContractServices.finalResult.contains('Contract already deleted OR Contract Id does not exist'));
        Test.stopTest();
    }
    
    /*
    * Create Property test data
    */
    public static MDU_Property__c createTestPropertyData(){
        TestDataUtility.createCustomSettingRecords();
        String labelName = System.Label.XfinityPropertyRecordType;  
        List<String> recordTypeSet = new List<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }    
        MDU_Property__c  testProperty = TestDataUtility.createProperty();
        testProperty.recordTypeId = recordTypeSet[0];
        return testProperty;
    }
    
   /*
    * Create Opportunity Property test data
    */
    private static void createOpptyPropertyRecord(boolean ecmId){
        
        MDU_Property__c testProperty = createTestPropertyData();            
        Database.insert(testProperty);
        
        List<Id> recordTypeIdSet = new List<Id>();
        String labelName = System.Label.XfinityOpportunityRecordType; //Get  MDU Record Type
        if(!string.IsBlank(labelName)){
            for(String str: labelName.split(LABEL_NAME_SPLIT)){
                recordTypeIdSet.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }else{}   
        
        List<Opportunity> testOpportunity = TestDataUtility.createOpportunity(1);
        testOpportunity[0].recordTypeId = recordTypeIdSet[0];            
        Database.insert(testOpportunity[0]);
        
        //Set ECM__c to empty
        Opportunity_Property__c oppProp = new Opportunity_Property__c();
        oppProp.Property__c = testProperty.Id;
        if(ecmId){
            oppProp.ECM__c = '3d12c962ea834e828d221544a11df05d';    
        }       
        oppProp.Opportunity__c = testOpportunity[0].Id;
        Database.insert(oppProp);
        
    }
  
    
}