/**
* This test class will call MockHttpResponseForContractWriteBack & will cover test coverage of MDU_ContractWriteBackBatch class.
* Created: 31-March-2015
* Date : 31 March 2015
* Author : Ashish Sonawane
*/
@isTest
public class MDU_ContractWriteBackBatchTest {
    
    private static final string LABEL_NAME_SPLIT = ';';
   
    /*
    * Mock callout search Executed Response.
    */   
    @isTest static void calloutSearchExecutedResponse() {
       
        String propetyComplexId = '';                 
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();        
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        TestDataUtility.setApplicationLogEnableCS(currentProfileId);  
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcUser){          
               
            MDU_Property__c testProperty = createTestPropertyData();                       
            if(!Mdu_Property__c.Complex_ID__c.getDescribe().isAutoNumber()){
                testProperty.put('Complex_ID__c', '121250044');
            }
            Database.insert(testProperty);            
            //set Property complex Id
            MDU_Property__c[] propetyList =(List<MDU_Property__c>) [Select Id, Complex_ID__c FROM MDU_Property__c where Id=: testProperty.Id];
           
            propetyComplexId = propetyList[0].Complex_ID__c;            
            List<Id> recordTypeIdSet = new List<Id>();
            String labelName = System.Label.XfinityOpportunityRecordType; //Get  MDU Record Type
            if(!string.IsBlank(labelName)){
                for(String str: labelName.split(LABEL_NAME_SPLIT)){
                    recordTypeIdSet.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(str).getRecordTypeId());
                }
            }              
            List<Opportunity> testOpportunity = TestDataUtility.createOpportunity(1);
            testOpportunity[0].recordTypeId = recordTypeIdSet[0];
            testOpportunity[0].MDU_Opportunity_ID__c = '169510';
            Database.insert(testOpportunity[0]);                       
            
            Opportunity_Property__c oppProp = new Opportunity_Property__c();
            oppProp.Property__c = testProperty.Id;
            oppProp.Opportunity__c = testOpportunity[0].Id;
            Database.insert(oppProp);
        }
        
        User xcUser2 = TestDataUtility.createXCIntegrationUser(); 
                                           
        System.runAs(xcUser2){  
            Test.startTest();       
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(true,propetyComplexId,''));                
            MDU_ContractWriteBack.createContractDataOperation();        
            Test.stopTest();
        }  
        
        Opportunity oportunityTemp = [Select Id ,StageName From Opportunity ];
        //Opportunity Stage will be 'close Won' when Opportunity updated  
        System.assertEquals('Closed Won', oportunityTemp.StageName);      
        Contracted_Bulk_Service__c[] contractedBulkService = [Select Id  From Contracted_Bulk_Service__c];
        Property_Fees__c[] propertyFeesList = [Select Id  From Property_Fees__c];
        //Three Bulk Service Record will created as per Response
        System.assertEquals(3, contractedBulkService.size());
        //Two Property Fees Record will created as per Response
        System.assertEquals(2, propertyFeesList.size());
        //System.debug(LoggingLevel.Error,'Bulk Service Size'+contractedBulkService.size() +' Property Fees Size'+propertyFeesList.size());
    }
    
    /*
    * Mock callout Response for Video Bulk Service Type. 
    */
    @isTest static void calloutResponseForVideo() {
       
        String propetyComplexId = '';             
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();       
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
         TestDataUtility.setApplicationLogEnableCS(currentProfileId); 
        System.runAs(xcUser){          
               
            MDU_Property__c testProperty = createTestPropertyData();                       
            testProperty.Industry_Type__c = 'Healthcare';
            if(!Mdu_Property__c.Complex_ID__c.getDescribe().isAutoNumber()){
                testProperty.put('Complex_ID__c', '121250044');
            }
            Database.insert(testProperty);            
            //set Property complex Id
            MDU_Property__c[] propetyList =(List<MDU_Property__c>) [Select Id, Complex_ID__c FROM MDU_Property__c where Id=: testProperty.Id];            
            propetyComplexId = propetyList[0].Complex_ID__c;            
            List<Id> recordTypeIdSet = new List<Id>();
            String labelName = System.Label.XfinityOpportunityRecordType; //Get  MDU Record Type
            if(!string.IsBlank(labelName)){
                for(String str: labelName.split(LABEL_NAME_SPLIT)){
                    recordTypeIdSet.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(str).getRecordTypeId());
                }
            }              
            List<Opportunity> testOpportunity = TestDataUtility.createOpportunity(1);
            testOpportunity[0].recordTypeId = recordTypeIdSet[0];
            testOpportunity[0].MDU_Opportunity_ID__c = '169510';
            Database.insert(testOpportunity[0]);                       
           
            Opportunity_Property__c oppProp = new Opportunity_Property__c();
            oppProp.Property__c = testProperty.Id;
            oppProp.Opportunity__c = testOpportunity[0].Id;
            Database.insert(oppProp);
        }                                 
        
        User xcUser2 = TestDataUtility.createXCIntegrationUser();  
        System.runAs(xcUser2){  
            Test.startTest();                   
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(true,propetyComplexId, ''));         
            MDU_ContractWriteBack.createContractDataOperation();
            Test.stopTest();
        }
                              
        
    }
     
    /*
    * Mock callout Response for Video and Data Bulk Service Type.
    */
    
    @isTest static void calloutResponseForVideoAndData() {
       
        String propetyComplexId = '';              
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();       
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        TestDataUtility.setApplicationLogEnableCS(currentProfileId); 
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcUser){          
               
            MDU_Property__c testProperty = createTestPropertyData();                       
            if(!Mdu_Property__c.Complex_ID__c.getDescribe().isAutoNumber()){
                testProperty.put('Complex_ID__c', '121250044');
            }
            Database.insert(testProperty);            
            //set Property complex Id
            MDU_Property__c[] propetyList =(List<MDU_Property__c>) [Select Id, Complex_ID__c FROM MDU_Property__c where Id=: testProperty.Id];             
            propetyComplexId = propetyList[0].Complex_ID__c;            
            List<Id> recordTypeIdSet = new List<Id>();
            String labelName = System.Label.XfinityOpportunityRecordType; //Get  MDU Record Type
            if(!string.IsBlank(labelName)){
                for(String str: labelName.split(LABEL_NAME_SPLIT)){
                    recordTypeIdSet.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(str).getRecordTypeId());
                }
            }              
            List<Opportunity> testOpportunity = TestDataUtility.createOpportunity(1);
            testOpportunity[0].recordTypeId = recordTypeIdSet[0];
            testOpportunity[0].MDU_Opportunity_ID__c = '169510';
           
            Database.insert(testOpportunity[0]);                       
            Opportunity_Property__c oppProp = new Opportunity_Property__c();
            oppProp.Property__c = testProperty.Id;
            oppProp.Opportunity__c = testOpportunity[0].Id;
            Database.insert(oppProp);
        }                                 
        User xcUser2 = TestDataUtility.createXCIntegrationUser();  
                       
        System.runAs(xcUser2){ 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(true,propetyComplexId, ''));
            MDU_ContractWriteBack.createContractDataOperation();
            Test.stopTest();
        }
       
        
    }   
    
   /*
    * Mock callout Response For Retail Service Type.
    */  
    @isTest static void calloutForRetailServiceResponse() {
       
        String propetyComplexId = '';           
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();        
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        TestDataUtility.setApplicationLogEnableCS(currentProfileId); 
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcUser){          
               
            MDU_Property__c testProperty = createTestPropertyData();   
            testProperty.Industry_Type__c = 'Government';
            testProperty.Property_Type__c = 'Government';
            if(!Mdu_Property__c.Complex_ID__c.getDescribe().isAutoNumber()){
                testProperty.put('Complex_ID__c', '121250044');
            }
            Database.insert(testProperty);            
            //set Property complex Id
            MDU_Property__c[] propetyList =(List<MDU_Property__c>) [Select Id, Complex_ID__c FROM MDU_Property__c where Id=: testProperty.Id];            
            propetyComplexId = propetyList[0].Complex_ID__c;            
            List<Id> recordTypeIdSet = new List<Id>();
            String labelName = System.Label.XfinityOpportunityRecordType; //Get  MDU Record Type
            if(!string.IsBlank(labelName)){
                for(String str: labelName.split(LABEL_NAME_SPLIT)){
                    recordTypeIdSet.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(str).getRecordTypeId());
                }
            }              
            
            List<Opportunity> testOpportunity = TestDataUtility.createOpportunity(1);
            testOpportunity[0].recordTypeId = recordTypeIdSet[0];
            testOpportunity[0].MDU_Opportunity_ID__c = '169510';
            
            Database.insert(testOpportunity[0]);                       
            Opportunity_Property__c oppProp = new Opportunity_Property__c();
            oppProp.Property__c = testProperty.Id;
            oppProp.Opportunity__c = testOpportunity[0].Id;
            Database.insert(oppProp);
        }
        
        User xcUser2 = TestDataUtility.createXCIntegrationUser();  
                       
        System.runAs(xcUser2){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(true,propetyComplexId, ''));
            MDU_ContractWriteBack.createContractDataOperation();  
            Test.stopTest();
        }
                        
       
    }
    
    /*
    * Mock callout Response To Test successRequestMethod in batch.
    */  
    @isTest static void calloutForsuccessRequestMethod() {       
        Set<String> contractIdSet =  new Set<String>{'d68f482c9ab94a65b6e3e53f88d3e9db'};
        String propetyComplexId = '';            
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();        
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        TestDataUtility.setApplicationLogEnableCS(currentProfileId); 
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcUser){          
            propetyComplexId = generatePropertyComplexId();
        }
                       
        User xcUser2 = TestDataUtility.createXCIntegrationUser();  
                       
        System.runAs(xcUser2){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(true,propetyComplexId,''))  ; 
            MDU_ContractWriteBack.successRequestExecute(contractIdSet);   
            Test.stopTest();
        }       
               
    }
    
    /*
    * Mock call out fail Response to change contract status at emptoris for fail response
    */  
    @isTest static void testContractStatusForFailRespMethod() {       
        Set<String> contractIdSet =  new Set<String>{'d68f482c9ab94a65b6e3e53f88d3e9db'};
        String propetyComplexId = '';
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();        
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();          
        TestDataUtility.setApplicationLogEnableCS(currentProfileId); 
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcUser){          
            propetyComplexId = generatePropertyComplexId();
        }
        
        
        Test.startTest();
                
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(false, propetyComplexId, '5'));   
        MDU_ContractWriteBack.successRequestExecute(contractIdSet);
          
        Test.stopTest();
    }   
    
   /*
    * Mock call out fail Response to change term at emptoris for fail response
    */      
    @isTest static void testContractTermFailRespMethod() {       
        Set<String> contractIdSet =  new Set<String>{'d68f482c9ab94a65b6e3e53f88d3e9db'};
        String propetyComplexId = '';
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();        
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();          
        TestDataUtility.setApplicationLogEnableCS(currentProfileId); 
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcUser){          
            propetyComplexId = generatePropertyComplexId();
        }
         
        Test.startTest();               
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(false, propetyComplexId, '6')); 
        MDU_ContractWriteBack.successRequestExecute(contractIdSet);         
        
        Test.stopTest();
    }   
    
     /*
    * Mock call out fail Response to change custom property for fail response
    */  
    @isTest static void testCustPropertyFailRespMethod() {       
        Set<String> contractIdSet =  new Set<String>{'d68f482c9ab94a65b6e3e53f88d3e9db'};
        String propetyComplexId = '';
        Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();        
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();          
        TestDataUtility.setApplicationLogEnableCS(currentProfileId); 
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcUser){          
            propetyComplexId = generatePropertyComplexId();
        }
                       
         
        Test.startTest();
                      
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(false,propetyComplexId,'7'));   
        MDU_ContractWriteBack.successRequestExecute(contractIdSet);     
       
        Test.stopTest();
    }   
    
    /*
    * Mock callout Fail Response To search executed contract
    */ 
    @isTest static void calloutSearchExecutedFailResponse() {
       
        String propetyComplexId = '';
        //Id currentProfileId = userinfo.getProfileId();          
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();        
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        TestDataUtility.setApplicationLogEnableCS(currentProfileId); 
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcUser){          
            propetyComplexId = generatePropertyComplexId();
        }
                                 
        User xcUser2 = TestDataUtility.createXCIntegrationUser();                    
        System.runAs(xcUser2){   
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(false,propetyComplexId, '1'));                    
            MDU_ContractWriteBack.createContractDataOperation();
            Test.stopTest();
        }       
    }
    
    /*
    * Mock callout Fail Response To search active contract
    */ 
    @isTest static void calloutSearchActiveFailResponse() {
       
        String propetyComplexId = '';               
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();       
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        TestDataUtility.setApplicationLogEnableCS(currentProfileId); 
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcUser){          
            propetyComplexId = generatePropertyComplexId();             
        }
        User xcUser2 = TestDataUtility.createXCIntegrationUser();  
        
        System.runAs(xcUser2){   
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(false,propetyComplexId, '2'));                    
            MDU_ContractWriteBack.createContractDataOperation();
             Test.stopTest();
        }       
    }
    
     /*
    * Mock callout Fail Response To get contract records
    */ 
    @isTest static void calloutSearchContractDataFailResponse() {
       
        String propetyComplexId = '';             
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();       
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        TestDataUtility.setApplicationLogEnableCS(currentProfileId); 
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcUser){                         
            propetyComplexId = generatePropertyComplexId();
        }
                                
        User xcUser2 = TestDataUtility.createXCIntegrationUser();  
       
        
        System.runAs(xcUser2){     
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(false,propetyComplexId, '3'));                    
            MDU_ContractWriteBack.createContractDataOperation();
            Test.stopTest();
        }
       
    }
    
    /*
    * Mock callout Fail Response To get contract Attachment
    */ 
    @isTest static void calloutContractAttachmentFailResponse() {
       
        String propetyComplexId = '';              
        TestDataUtility.createCustomSettingRecords();
        TestDataUtility.createContractExtractionCS();        
        List<MDU_EmptorisIntegrationCS__c> listCustomSet = TestDataUtility.createIntegrationCS();
        Database.insert(listCustomSet); 
        User xcUser = TestDataUtility.createXCIntegrationUser();  
        Id currentProfileId = xcUser.ProfileId;
        TestDataUtility.setApplicationLogEnableCS(currentProfileId); 
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcUser){                         
            propetyComplexId = generatePropertyComplexId();
        }
        
        User xcUser2 = TestDataUtility.createXCIntegrationUser();                 
        System.runAs(xcUser2){ 
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(false,propetyComplexId, '4'));                
            MDU_ContractWriteBack.createContractDataOperation();
            Test.stopTest();
        }        
    }
    
    
   /*
    * Call to create test data
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
    * Generate property complex Id 
    */
    public static string generatePropertyComplexId(){
        String propetyComplexId = '';
        MDU_Property__c testProperty = createTestPropertyData();                       
        if(!Mdu_Property__c.Complex_ID__c.getDescribe().isAutoNumber()){
            testProperty.put('Complex_ID__c', '121250044');
        }
        Database.insert(testProperty);            
        //set Property complex Id
        MDU_Property__c[] propetyList =(List<MDU_Property__c>) [Select Id, Complex_ID__c FROM MDU_Property__c where Id=: testProperty.Id];      
        propetyComplexId = propetyList[0].Complex_ID__c;            
        List<Id> recordTypeIdSet = new List<Id>();
        String labelName = System.Label.XfinityOpportunityRecordType; //Get  MDU Record Type
        if(!string.IsBlank(labelName)){
            for(String str: labelName.split(LABEL_NAME_SPLIT)){
                recordTypeIdSet.add(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }              
        List<Opportunity> testOpportunity = TestDataUtility.createOpportunity(1);
        testOpportunity[0].recordTypeId = recordTypeIdSet[0];
        testOpportunity[0].MDU_Opportunity_ID__c = '169510';
        Database.insert(testOpportunity[0]);                       
        
        Opportunity_Property__c oppProp = new Opportunity_Property__c();
        oppProp.Property__c = testProperty.Id;
        oppProp.Opportunity__c = testOpportunity[0].Id;
        Database.insert(oppProp);
        return propetyComplexId;
    }
     
}