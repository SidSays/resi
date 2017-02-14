/**
* This class contains unit tests for validating the MDUContractWriteBackSchedule call.
* Created: 26-May-2015
*/
@isTest(seeAllData=false)
private class MDUContractWriteBackScheduleTest {
    
    private static final string LABEL_NAME_SPLIT = ';';
    /*
    * Test scheduler call
    */
    static testMethod void writeBackScheduleTest() {
          
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
        
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseForContractWriteBack(true,propetyComplexId,''));      
            // Schedular Test
            MDUContractWriteBackSchedule sc = new MDUContractWriteBackSchedule();       
            datetime currentDateTime = datetime.now();
            String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
            String schExp = '0 '+min+' * * * ? ';   
            system.schedule('Schedular Test :'+datetime.now(), schExp, sc);     
            
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
    * create Opportunity Property Record and return Complex Id 
    */
    public static string generatePropertyComplexId(){
        String propetyComplexId = '';
        MDU_Property__c testProperty = createTestPropertyData();                       
        if(!Mdu_Property__c.Complex_ID__c.getDescribe().isAutoNumber()){
            testProperty.put('Complex_ID__c', '121250044');
        }
        Database.insert(testProperty);            
        //set Property complex Id
        MDU_Property__c[] propetyList =(List<MDU_Property__c>) [Select Id, Complex_ID__c FROM MDU_Property__c];      
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