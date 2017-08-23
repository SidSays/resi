/*
* Description: Test class for PropertyLookupPageController coverage
* Created By: Sagar Gurav
*/
@isTest
private class PropertyLookupPageControllerTest {

    /*
    *   Handle if property type is in 'Condominium, Condominium-Detached, Town Homes'
    */
    static testMethod void lookupTestInCCT() {
        
        TestDataUtility.createCustomSettingRecords();
        List<MDU_Property__c> propList = new List<MDU_Property__c>();
        Account acc = TestDataUtility.createAccount() ;
        database.insert (acc);
               
        // Handle if property type is in 'Condominium, Condominium-Detached, Town Homes'      
        MDU_Property__c MDUprop1 = TestDataUtility.createProperty();
        MDUprop1.Property_Type__c = 'Condominium';
        propList.add(MDUprop1);
        
        // property type assisted living
        MDU_Property__c MDUprop2 = TestDataUtility.createProperty();
        propList.add(MDUprop2);
        
        // name less than 3 character validation prop.
        MDU_Property__c MDUprop3 = TestDataUtility.createProperty();
        MDUprop3.Name = 'ab';
        propList.add(MDUprop3);
        
        // property type Town Homes
        MDU_Property__c MDUprop4 = TestDataUtility.createProperty();
        MDUprop4.Property_Type__c = 'Town Homes';
        propList.add(MDUprop4); 
        database.insert(propList);
        
        User u = TestDataUtility.createXCIntegrationUser();
        List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
        Opportunity_Property__c oppPropInst = new Opportunity_Property__c();
        System.runAs(u){
            
            database.insert (oppList[0]);
        
            //This is opp prop which is primary set with type as Condominium
            Opportunity_Property__c oppPropInst1 = TestDataUtility.createOppProperty(oppList[0].id, propList[0].id); 
            oppPropInst1.Primary_Property__c = true;
            database.insert (oppPropInst1);
            
            //adding one more opportuntity property which has one primary opp property.           
            oppPropInst.Opportunity__c = oppList[0].id;
        }
        
        Test.startTest();
     
            ApexPages.currentPage().getParameters().put('optyId', oppList[0].id);
            
            ApexPages.StandardController stdCon = new ApexPages.StandardController(oppPropInst);
            PropertyLookupPageController propLookupObj = new PropertyLookupPageController(stdCon);
            propLookupObj.searchProperties();
            propLookupObj.wrapperList = null;
            propLookupObj.processSelected();
        
        Test.stopTest();
        
    }

    
    /* 
    *   Handle if property type is NOT in 'Condominium, Condominium-Detached, Town Homes'
    */
    static testMethod void lookupTestNotInCCT() {
          
        TestDataUtility.createCustomSettingRecords();
        List<MDU_Property__c> propList = new List<MDU_Property__c>();
        Account acc = TestDataUtility.createAccount() ;
        database.insert(acc);
   
        // property used in primary opp property which is of type 'Assisted Living'
        MDU_Property__c MDUprop1 = TestDataUtility.createProperty();
        propList.add(MDUprop1);
        
        // property type assisted living
        MDU_Property__c MDUprop2 = TestDataUtility.createProperty();
        propList.add(MDUprop2);
        
        // name less than 3 character validation prop.
        MDU_Property__c MDUprop3 = TestDataUtility.createProperty();
        MDUprop3.Name = 'ab';
        propList.add(MDUprop3);
        
        // property type Town Homes
        MDU_Property__c MDUprop4 = TestDataUtility.createProperty();
        MDUprop4.Property_Type__c = 'Town Homes';
        propList.add(MDUprop4);
        
        database.insert(propList);
        
        User u = TestDataUtility.createXCIntegrationUser();
        List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
        
        Opportunity_Property__c oppPropInst = new Opportunity_Property__c();
        System.runAs(u){
            
            database.insert(oppList[0]);
            
            //This is opp prop which is primary set with type as Assisted Living
            Opportunity_Property__c oppPropInst1 = TestDataUtility.createOppProperty(oppList[0].id, propList[0].id); 
            oppPropInst1.Primary_Property__c  = true;
            database.insert(oppPropInst1);
            
            //adding one more opportunity property which has one primary opp property.
            oppPropInst.Opportunity__c = oppList[0].id;
        }
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('optyId', oppList[0].id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(oppPropInst);
        PropertyLookupPageController propLookupObj = new PropertyLookupPageController(stdCon);
        propLookupObj.searchProperties();
        propLookupObj.searchProperties();
        propLookupObj.searchText= 'ab';
        propLookupObj.searchProperties();
        propLookupObj.searchText= 'abcd';
        propLookupObj.searchProperties();
        propLookupObj.searchText= '';
        propLookupObj.searchProperties();
        
        propLookupObj.selecting();
        
        Test.stopTest();
    }
    
    /*
    * Function to handle which has no primary property on it. i.e adding 1st opp property for that opp.
    */ 
    static testMethod void lookupTestWithNoPrimaryProp() {
        
        TestDataUtility.createCustomSettingRecords();
        List<MDU_Property__c> propList = new List<MDU_Property__c>();
        Account acc = TestDataUtility.createAccount() ;
        database.insert(acc);
        
        // property type assisted living
        MDU_Property__c MDUprop2 = TestDataUtility.createProperty();
        propList.add(MDUprop2);      
        // name less than 3 character validation prop.
        MDU_Property__c MDUprop3 = TestDataUtility.createProperty();
        MDUprop3.Name = 'ab';
        propList.add(MDUprop3);
        
        // property type Town Homes
        MDU_Property__c MDUprop4 = TestDataUtility.createProperty();
        MDUprop4.Property_Type__c = 'Town Homes';
            
        database.insert(propList);
        
        List<Opportunity> oppList = TestDataUtility.createOpportunity(2);
        User u = TestDataUtility.createXCIntegrationUser();
        System.runAs(u){
            propList.add(MDUprop4);
            database.insert(oppList[0]);
        }
        
        //adding first opp prop on that opp.
        Opportunity_Property__c oppPropInst = new Opportunity_Property__c();
        oppPropInst.Opportunity__c = oppList[0].id;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('optyId', oppList[0].id);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(oppPropInst);
        PropertyLookupPageController propLookupObj = new PropertyLookupPageController(stdCon);
        propLookupObj.searchProperties();
        propLookupObj.searchText= 'ab';
        propLookupObj.searchProperties();
        propLookupObj.searchText= 'abcd';
        propLookupObj.searchProperties();
        Test.stopTest();
        
    }
    
    
    /*
    * PageableMock for Virtual class
    */
    private class PageableMock extends PageableUtil {
           
        public override Integer getRecordCount(){
            return 20;
        }       
    }
    
    /*
    * PageableMock for Virtual class
    */
    private class PageableMock2 extends PageableUtil {                  
    }

    /*
    * Function to cover Pageable class methods
    */ 
    static testMethod void pageableTestCall() {
        
        PageableMock pg = new PageableMock();
        PageableMock2 pg2 = new PageableMock2();

        Test.startTest();
               
        pg.getRecordCount(); 
        pg.MoveNext();
        pg.MovePrev();
        pg.MoveLast();
        pg.moveFirst();
        pg.testCall();
              
        pg2.getRecordCount(); 
        pg2.MoveNext();
        pg2.MovePrev();
        pg2.MoveLast();
        pg2.moveFirst();
        pg2.testCall();
        
        Test.StopTest();
        
    } 
}