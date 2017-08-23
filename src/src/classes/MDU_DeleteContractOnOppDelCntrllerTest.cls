@isTest
public with sharing class MDU_DeleteContractOnOppDelCntrllerTest {
    
    private static final string LABEL_NAME_SPLIT = ';';  
     
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
    
    @isTest static void deleteContractForOppDelete() {
       
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
        Opportunity oppToDel = [Select Id from Opportunity];     
        // Set mock callout class to delete contract
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForDeleteContract(true));
        MDU_DeleteContractOnOppDeleteController.deleteContractOnOppDel(oppToDel.Id); 
        ApexPages.StandardController deleteOppController = new ApexPages.StandardController(oppToDel);
        MDU_DeleteContractOnOppDeleteController deleteContract = new MDU_DeleteContractOnOppDeleteController(deleteOppController);
        deleteContract.openPage();
        Test.stopTest();
    }
    
    @isTest static void deleteContractForOppDeleteWithNoECMId() {
       
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
        Opportunity oppToDel = [Select Id from Opportunity];     
        // Set mock callout class to delete contract
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForDeleteContract(true));
        MDU_DeleteContractOnOppDeleteController.deleteContractOnOppDel(oppToDel.Id); 
        ApexPages.StandardController deleteOppController = new ApexPages.StandardController(oppToDel);
        MDU_DeleteContractOnOppDeleteController deleteContract = new MDU_DeleteContractOnOppDeleteController(deleteOppController);
        deleteContract.openPage();
        Test.stopTest();
    }
}