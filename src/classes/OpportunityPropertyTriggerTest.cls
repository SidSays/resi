/**
* This class contains unit tests for validating the OpportunityPropertyTriggerTest call.
* Created: 24-Feb-2015
* Author : Sagar Gurav
*/
@isTest
public class OpportunityPropertyTriggerTest {
    
    private static final string LABEL_NAME_SPLIT = ';';
    
    /*
    Create test Property
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
    
    /*to handle 1. To set Property as Primary Property if Opportunity has not other Property associated.
               2. To validate that no property, associated with any other open opportunity, can be added to an Opportunity
               3. To validate property type of secondary property should be same as the property type of primary property of associated opportunity
    * Testing setPrimaryPropeertyOrFireValidation method
    */
    static testMethod void setPriPropOrFireValidationTest() {
        
        //create test data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        Database.insert(acc);   
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1);         
        
        Test.startTest();
            /*
            * Handling closed Opportunity conditions.
            */        
            oppList[0].StageName = 'Closed Won';    
            oppList[0].ContractTermUnit__c = 'months';
            oppList[0].ContractTerm__c = 2;
            oppList[0].AccountId = acc.id;
            oppList[0].Contract_Type__c = 'Bulk';
            oppList[0].Fiber_To_The_Unit__c = 'Fiber to the Building';
                
            /*
            * testing property type & bulk status condition on property
            */
            MDU_Property__c MDUprop1 = createTestPropertyData();
            MDUprop1.PostalCode__c = '10541';
            MDUprop1.Bulk_Status__c = 'Bulk';
            MDUprop1.Property_Type__c = 'CONDOMINIUM';
            
            User u = TestDataUtility.createXCIntegrationUser();

            System.runAs(u){
                Database.insert(oppList[0]);  
                Database.insert(MDUprop1);
                // insert opportunity property 
                Opportunity_Property__c oppPropInst1 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop1.id); 
                oppPropInst1.Primary_Property__c = true;
                Database.insert (oppPropInst1);
                //update Opportunity Property
                Opportunity_Property__c oppPropInst2 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop1.id); 
                database.insert (oppPropInst2);
                oppPropInst2.Primary_Property__c = true;
                Database.update(oppPropInst2);
            }           
        Test.stopTest();
    }
    
    /*
    * Testing conditions on open opportunity
    */
    static testMethod void testOpptyPropValidation(){
        
        //create test data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        Database.insert(acc);   
         /*
        *open opportunity property will throw validation msg handling
        */
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1);       
        oppList[0].Fiber_To_The_Unit__c = 'Fiber to the Building';
        
        /*
        *property associated with open opportunity.
        */
        List<MDU_Property__c> propList = new List<MDU_Property__c>();     
        MDU_Property__c MDUprop6 = createTestPropertyData();
        MDUprop6.Property_Type__c = 'CONDOMINIUM';
        propList.add(MDUprop6);
        
        MDU_Property__c MDUprop7 = createTestPropertyData();
        propList.add(MDUprop7);
    
        User u = TestDataUtility.createXCIntegrationUser();

        System.runAs(u){
            Database.insert(oppList[0]);  
            Database.insert(propList);
            system.debug('>>>>>1:' + propList);
                          
                Opportunity_Property__c oppPropInst6 = TestDataUtility.createOppProperty(oppList[0].id, propList[0].id); 
                oppPropInst6.Primary_Property__c = true;
                Database.insert(oppPropInst6); 
                system.debug('>>>>>2:' + oppPropInst6);
            try {
                Test.startTest();
                    Opportunity_Property__c oppPropInst7 = TestDataUtility.createOppProperty(oppList[0].id, propList[1].id);                
                    Database.insert(oppPropInst7);   
                    system.debug('>>>>>3:' + oppPropInst7);
                Test.stopTest();
            } catch(Exception e) {
                system.debug('>>>>>>>' + e.getMessage());
                Boolean exp =  e.getMessage().contains('Property Type on the new property should be same as that of Primary Property.') ? true : false;
                system.assertEquals(exp,true);
            }
        }           
    }
    
    
    /*
    * Testing empty property on opp prop
    */
    static testMethod void testOpptyPropValidationNegative(){

        //create test data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        Database.insert(acc);   
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1); 
        
        User u = TestDataUtility.createXCIntegrationUser();

        System.runAs(u){
            oppList[0].Fiber_To_The_Unit__c = 'Fiber to the Building';
            Database.insert(oppList[0]);  
                
            Opportunity_Property__c oppPropInst8 = TestDataUtility.createOppProperty(oppList[0].id, null); 
            try{
                Database.insert(oppPropInst8);
            }catch(Exception e){
                Boolean exp =  e.getMessage().contains('REQUIRED_FIELD_MISSING') ? true : false;
                system.assertEquals(exp,true);
            }
        }

    }
    
    
    /*
    * Testing conditions on open opportunity - Cannot add Property as it is associated with one or more Open Opportunity.
    */
    static testMethod void testOpptyPropValidationNegative2(){
        
        //create test data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        Database.insert(acc); 

        /*
        *open opportunity property will throw validation msg handling
        */
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1); 
        oppList[0].Fiber_To_The_Unit__c = 'Fiber to the Building';
        
        /*
        *property associated with open opportunity.
        */
        MDU_Property__c MDUprop2 = createTestPropertyData();
        
        User u = TestDataUtility.createXCIntegrationUser();

        System.runAs(u){
            Database.insert(oppList[0]);  
            Database.insert(MDUprop2);
    
            try {               
                Opportunity_Property__c oppPropInst3 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop2.id); 
                oppPropInst3.Primary_Property__c = true;
                Database.insert(oppPropInst3);
                Opportunity_Property__c oppPropInst4 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop2.id); 
                insert oppPropInst4;
                /*oppPropInst4.Primary_Property__c = true;
                Database.update(oppPropInst4);*/
            }
            catch(Exception e) {
                Boolean exp =  e.getMessage().contains('Cannot add Property as it is associated with one or more Open Opportunity.') ? true : false;
                system.assertEquals(exp,true);
            }
        }
    }
    
    
    /* 
    *   To handle delete functionality for created date later than current primary opportuntiy property.
    */
    static testMethod void deleteFunc() {
        
        //create test Data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        insert acc;
       
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1); 
        oppList[0].StageName = 'Closed Won';    
        oppList[0].ContractTermUnit__c = 'months';
        oppList[0].ContractTerm__c = 2;
        oppList[0].AccountId = acc.id;
        oppList[0].Contract_Type__c = 'Bulk';
        oppList[0].Fiber_To_The_Unit__c = 'Fiber to the Building';
        
        MDU_Property__c MDUprop1 = createTestPropertyData();
        MDUprop1.PostalCode__c = '10541';
        MDUprop1.Bulk_Status__c = 'Bulk';
        MDUprop1.Property_Type__c = 'CONDOMINIUM';
        
        User u = TestDataUtility.createXCIntegrationUser();

        System.runAs(u){
            Database.insert(oppList[0]);
            Database.insert(MDUprop1);
            List<Opportunity_Property__c> oppPropList = new List<Opportunity_Property__c>();
            Opportunity_Property__c oppPropInst1 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop1.id); 
            oppPropInst1.Primary_Property__c = true;
            oppPropList.add(oppPropInst1);
            
            Opportunity_Property__c oppPropInst2 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop1.id); 
            oppPropList.add(oppPropInst2);
            
            Test.startTest();
                Database.insert(oppPropList);
                Database.delete(oppPropList[1]);           
            Test.stopTest();
        }       

    }
    
    
    /* 
    *   To handle delete functionality validation
    */
    static testMethod void deleteFuncNegative1() {
        
        //create test Data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        database.insert(acc);
       
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1); 
        /*
        * test:  to handle validation of only one opp prop trying to delete
        */
        oppList[0].Fiber_To_The_Unit__c = 'Fiber to the Building';
        
        MDU_Property__c MDUprop1 = createTestPropertyData();
        MDUprop1.PostalCode__c = '10541';
        MDUprop1.Bulk_Status__c = 'Bulk';
        MDUprop1.Property_Type__c = 'CONDOMINIUM';
        
        User u = TestDataUtility.createXCIntegrationUser();

        System.runAs(u){
            Database.insert(oppList[0]); 
            Database.insert(MDUprop1);
            //Single opp prop trying to delete validation error
            Opportunity_Property__c oppPropInst4 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop1.id); 
            oppPropInst4.Primary_Property__c = true;
            Database.insert(oppPropInst4);
            
            Test.startTest();
                try{
                    Database.delete(oppPropInst4);
                }
                catch(Exception e) {
                    Boolean exp =  e.getMessage().contains('Cannot delete opportunity property which has no other opportunity property on it.') ? true : false;
                    system.assertEquals(exp,true);
                }
            Test.stopTest();
        }
    }
    
    /* 
    *   To handle delete functionality validation
    */
    static testMethod void deleteFuncNegative() {
        
        //create test Data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        database.insert(acc);
       
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1); 
        oppList[0].StageName = 'Closed Won';    
        oppList[0].ContractTermUnit__c = 'months';
        oppList[0].ContractTerm__c = 2;
        oppList[0].AccountId = acc.id;
        oppList[0].Contract_Type__c = 'Bulk';
        oppList[0].Fiber_To_The_Unit__c = 'Fiber to the Building';  

        /*
        * property type CONDOMINIUM
        */  
        MDU_Property__c MDUprop1 = createTestPropertyData();
        MDUprop1.PostalCode__c = '10541';
        MDUprop1.Bulk_Status__c = 'Bulk';
        MDUprop1.Property_Type__c = 'CONDOMINIUM';
        
        User u = TestDataUtility.createXCIntegrationUser();

        System.runAs(u){
            Database.insert(oppList[0]);   
            Database.insert(MDUprop1);
            Opportunity_Property__c oppPropInst3 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop1.id); 
            oppPropInst3.ECM__c = '2131233';
            Database.insert(oppPropInst3);      
            
            Test.startTest();
                /*
                * test: ECM__c field validation error
                */  
                try{                        
                    Database.delete(oppPropInst3);
                }
                catch(Exception e) {
                    Boolean exp =  e.getMessage().contains('Cannot delete opportunity property which has ECM Contract ID field present on it') ? true : false;
                    system.assertEquals(exp,true);
                }
            Test.stopTest();
        }
    }
    
    
    /* 
    *   To handle delete functionality 
    */
    static testMethod void deleteFunc1() {
    
        //create test Data
        TestDataUtility.createCustomSettingRecords(); 
        Account acc = TestDataUtility.createAccount();
        database.insert(acc);
       
        List<Opportunity> oppList = TestDataUtility.createOpportunity(1); 
        oppList[0].StageName = 'Closed Won';    
        oppList[0].ContractTermUnit__c = 'months';
        oppList[0].ContractTerm__c = 2;
        oppList[0].AccountId = acc.id;
        oppList[0].Contract_Type__c = 'Bulk';
        oppList[0].Fiber_To_The_Unit__c = 'Fiber to the Building';
        
        MDU_Property__c MDUprop2 = createTestPropertyData();

        List<Opportunity_Property__c> oppPropList = new List<Opportunity_Property__c>();
        
        
        User u = TestDataUtility.createXCIntegrationUser();

        System.runAs(u){
            Database.insert(oppList[0]);
            Database.insert(MDUprop2);
            Opportunity_Property__c oppPropInst5 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop2.id); 
            oppPropList.add(oppPropInst5);
        
            Opportunity_Property__c oppPropInst6 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop2.id); 
            oppPropInst6.Primary_Property__c     = true;
            oppPropList.add(oppPropInst6);
            
            Opportunity_Property__c oppPropInst7 = TestDataUtility.createOppProperty(oppList[0].id, MDUprop2.id); 
            oppPropList.add(oppPropInst7);
            database.insert(oppPropList);
            
            Test.startTest();
                Database.delete(oppPropList[0]);
            Test.stopTest();
        }
    }
    
    /* This Method test that Active Opportunity checkbox is true on deleting closed opportunity*/
    private static testMethod void ActiveOppForDeleteTrue() {   
    
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();
        User xcIntegrationUser = TestDataUtility.createXCIntegrationUser();                       
        Id currentProfileId = xcIntegrationUser.ProfileId;       
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcIntegrationUser) {
       
            MDU_Property__c PropObj = TestDataUtility.createProperty();
            Database.Insert(PropObj) ;
            MDU_Property__c PropObj2 = TestDataUtility.createProperty();
            Database.Insert(PropObj2) ;
            
            List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
            oppList[0].Property__c = PropObj.id;
            oppList[1].Property__c = PropObj.id;
            oppList[1].StageName = 'Closed Won';
            Database.Insert(oppList);
            
            Opportunity_Property__c opptyPropObj = TestDataUtility.createOppProperty(oppList[1].id,PropObj2.id);
            Database.Insert(opptyPropObj);
            

            List<Opportunity_Property__c> opptyPropList = [select id from Opportunity_Property__c where Property__c =: PropObj.id];
            Database.Delete(opptyPropList[1]);
            
            MDU_Property__c PropTemp = [Select Id, Active_Opportunity__c from MDU_Property__c where Id = :PropObj.Id];
            System.assertEquals(PropTemp.Active_Opportunity__c,true);
            Test.stopTest();
        }
    }
    
    /* This Method test that Active Opportunity checkbox is false on deleting open opportunity*/
    private static testMethod void ActiveOppForDeleteFalse() {   
    
        TestDataUtility.createCustomSettingRecords();
        Test.startTest();
        User xcIntegrationUser = TestDataUtility.createXCIntegrationUser();                       
        Id currentProfileId = xcIntegrationUser.ProfileId;       
        TestDataUtility.bypassValidationCS(currentProfileId);
        System.runAs(xcIntegrationUser) {
       
            MDU_Property__c PropObj = TestDataUtility.createProperty();
            Database.Insert(PropObj) ;
            MDU_Property__c PropObj2 = TestDataUtility.createProperty();
            Database.Insert(PropObj2) ;
            
            List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
            oppList[0].Property__c = PropObj.id;
            oppList[1].Property__c = PropObj.id; 
            oppList[1].StageName = 'Closed Won';
            Database.Insert(oppList);
            
            Opportunity_Property__c opptyPropObj = TestDataUtility.createOppProperty(oppList[0].id,PropObj2.id);
            Database.Insert(opptyPropObj);
            

            List<Opportunity_Property__c> opptyPropList = [select id from Opportunity_Property__c where Property__c =: PropObj.id];
            Database.Delete(opptyPropList[0]);
            
            MDU_Property__c PropTemp = [Select Id, Active_Opportunity__c from MDU_Property__c where Id = :PropObj.Id];
            System.assertEquals(PropTemp.Active_Opportunity__c,false);
            Test.stopTest();
        }
    }
}