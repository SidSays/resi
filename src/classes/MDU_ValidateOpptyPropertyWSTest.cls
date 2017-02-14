/*
* Test class foer MDU_ValidateOpptyPropertyWS- covers the Portfolio Opportunity validation.
*/
@isTest                  
private class MDU_ValidateOpptyPropertyWSTest{
   
    private static final string LABEL_NAME_SPLIT = ';';
    /*
    * Create test Property
    */    
    public static MDU_Property__c createTestPropertyData(){
        
        String labelName = System.Label.XfinityPropertyRecordType;  
        List<String> recordTypeSet = new List<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }                  
        MDU_Property__c propertyObject = TestDataUtility.createProperty() ;
        propertyObject.RecordTypeId = recordTypeSet[0]; 
        return propertyObject;
    }
    
    
    /*
    * Test Portfolio Opportunity validation message
    */
    @isTest static void testvalidation() {
        
        //create test data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        Database.insert(acc);   
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1);   
        oppList[0].ContractTerm__c = 2;
        oppList[0].AccountId = acc.id;
        oppList[0].Contract_Type__c = 'Bulk';
        oppList[0].Sales_Portfolio_Name__c = null;
        
        MDU_Property__c prop = createTestPropertyData();
        prop.PostalCode__c = '10541';
        prop.Bulk_Status__c = 'Bulk';
        prop.Property_Type__c = 'CONDOMINIUM';
            
        User u = TestDataUtility.createXCIntegrationUser();

        System.runAs(u){
            Database.insert(oppList[0]);  
            Database.insert(prop);
            Opportunity_Property__c oppPropInst1 = TestDataUtility.createOppProperty(oppList[0].id, prop.id); 
            oppPropInst1.Primary_Property__c = true;
            Database.insert (oppPropInst1);
            
            Test.startTest();
                String msg= MDU_ValidateOpptyPropertyWS.validateOpptyProperty(oppList[0].Id);
                system.assert(msg.contains(System.Label.Portfolio_Name_Require_Validation_Message));
            Test.stopTest();
        }
    }
    
    /*
    * Portfolio Opportunity bypass validation message
    */   
    @isTest static void testvalidationNegative() {
        
        //create test data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        Database.insert(acc);   
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1);   
        oppList[0].ContractTerm__c = 2;
        oppList[0].AccountId = acc.id;
        oppList[0].Contract_Type__c = 'Bulk';
        oppList[0].Sales_Portfolio_Name__c = 'Test121@Test***!!!::Test';
        
        MDU_Property__c prop = createTestPropertyData();
        prop.PostalCode__c = '10541';
        prop.Bulk_Status__c = 'Bulk';
        prop.Property_Type__c = 'CONDOMINIUM';
            
        User u = TestDataUtility.createXCIntegrationUser();

        System.runAs(u){
            Database.insert(oppList[0]);  
            Database.insert(prop);
            Opportunity_Property__c oppPropInst1 = TestDataUtility.createOppProperty(oppList[0].id, prop.id); 
            oppPropInst1.Primary_Property__c = true;
            Database.insert (oppPropInst1);
            
            Test.startTest();
                String msg= MDU_ValidateOpptyPropertyWS.validateOpptyProperty(oppList[0].Id);
                system.assert(String.IsBlank(msg));
            Test.stopTest();
        }
    }
}