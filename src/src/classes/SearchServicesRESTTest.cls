/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest 
public with sharing class SearchServicesRESTTest {
    private static testMethod void testSearchServicesREST(){
        SetupTestData.createCustomSettingRecords();
        SetupTestData.createUsers();        
        Test.startTest();
        System.runAs(SetupTestData.supervisorUser){
        Plan__c plan = new Plan__c();
        plan.Name = 'Druv Plan';
        plan.Plan_Status__c = 'Draft';
        plan.Plan_Level__c = 'Turf';  
        plan.Expiration_Date__c = date.today();
        plan.User__c = SetupTestData.dsrUser4.Id;
        insert plan;
        
        Customer_Address__c address1 = new Customer_Address__c();
        address1.Address__c = 'Test Address Line1';
        address1.City__c = 'Test city';
        address1.State__c = 'Test State';
        address1.PostalCode__c = '98564';
        address1.Country__c = 'Test Country';
        address1.Corp__c = '111111';
        address1.Route_Code__c = '1111111111';
        address1.Node__c = '1111';
        address1.Assigned_Date__c = Date.today()-10;
        address1.Plan__c = plan.Id; 
        address1.PostalCode__c = '11234';
        address1.Address__c = '1123 Spring Hill Rd';
        address1.Latitude__c = 11.1111;
        address1.Longitude__c = 22.2222;
        address1.City__c = 'Sprutown';
        address1.State__c = 'SP';
        address1.Last_Knock_Date__c = System.now();
        address1.Most_Recent_Disposition__c = 'Contact';
        insert address1;

        Customer_Address__c address2 = new Customer_Address__c();
        address2.Address__c = 'Test Address Line1';
        address2.City__c = 'Test city';
        address2.State__c = 'Test State';
        address2.PostalCode__c = '98564';
        address2.Country__c = 'Test Country';
        address2.Corp__c = '111111';
        address2.Route_Code__c = '1111111111';
        address2.Node__c = '1111';
        address2.Assigned_Date__c = Date.today()-10;
        address2.Plan__c = plan.Id; 
        address2.PostalCode__c = '11234';
        address2.Address__c = '1123 Spring Hill Rd';
        address2.Latitude__c = 11.1111;
        address2.Longitude__c = 22.2222;
        address2.City__c = 'Sprutown';
        address2.State__c = 'SP';
        address2.Last_Knock_Date__c = System.now();
        address2.Most_Recent_Disposition__c = 'Contact';
        address2.Parent_Address__c=address1.Id;
        insert address2;


        Account contactacc = new Account();
        contactacc.Name = 'TestAccount';
        contactacc.Customer_Status__c = 'Active';
        contactacc.Installation_Status__c = 'Active';
        contactacc.Region__c = null;
        insert contactacc;

        Contact partContact = new Contact();
        partContact.lastName = 'Test Contact';
        partContact.AccountId=contactacc.Id;
        insert partContact;
        
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Billing_Account_Number__c='123456789';
        acc.Customer_Status__c = 'Active';
        acc.Installation_Status__c = 'Active';
        acc.Region__c = null;
        acc.Customer__c=partContact.id;
        acc.Service_Address__c = address1.Id;
        insert acc;
       
       
        Restrequest req = new Restrequest();
        req.requestURI = '/services/apexrest/SearchServicesREST';
        req.httpMethod = 'POST';
        // Search object ON,Plan,Number
        SearchServicesREST.searchObject searchObjOnWithPlanNo = new SearchServicesREST.searchObject();
        searchObjOnWithPlanNo.onOffTurf = 'On';
        searchObjOnWithPlanNo.planId = plan.Id; 
        searchObjOnWithPlanNo.searchParam = '123';
        
        
        // Search object ON,Plan,Alphabet
        SearchServicesREST.searchObject searchObjOnWithPlanAlp = new SearchServicesREST.searchObject();
        searchObjOnWithPlanAlp.searchParam = 'Test';
        searchObjOnWithPlanAlp.onOffTurf = 'On';
        searchObjOnWithPlanAlp.planId = plan.Id; 
        
        // Search object ON,No Plan,Number
        SearchServicesREST.searchObject searchObjOnWithoutPlanNo = new SearchServicesREST.searchObject();
        searchObjOnWithoutPlanNo.searchParam = '123';
        searchObjOnWithoutPlanNo.onOffTurf = 'On';
        searchObjOnWithoutPlanNo.userId = SetupTestData.dsrUser4.Id;
        
        // Search object ON,No Plan,Alphabet
        SearchServicesREST.searchObject searchObjOnWithoutPlanAlp = new SearchServicesREST.searchObject();
        searchObjOnWithoutPlanAlp.searchParam = 'Test';
        searchObjOnWithoutPlanAlp.onOffTurf = 'On';
        searchObjOnWithoutPlanAlp.userId = SetupTestData.dsrUser4.Id;
        
        // Search object OFF,Region,Plan,Number
        SearchServicesREST.searchObject searchObjOffNo = new SearchServicesREST.searchObject();
        searchObjOffNo.searchParam = '123';
        searchObjOffNo.onOffTurf = 'Off';
        searchObjOffNo.userId = SetupTestData.dsrUser4.Id;
        
        // Search object OFF,Region,Plan,Alphabet
        
        SearchServicesREST.searchObject searchObjOffAlp = new SearchServicesREST.searchObject();
        searchObjOffAlp.searchParam = 'Test';
        searchObjOffAlp.onOffTurf = 'Off';
        searchObjOffAlp.userId = SetupTestData.dsrUser4.Id;
        
        
         List<Customer_Address__c> address3 = [SELECT id, name from Customer_Address__c];
         Id [] fixedSearchResults= new Id[2];
         fixedSearchResults[0]=address3.get(0).id; 
         fixedSearchResults[1]=address3.get(1).id; 
         Test.setFixedSearchResults(fixedSearchResults); 
        
        List<Customer_Address__c> custAddList = new List<Customer_Address__c>();
        
        custAddList = SearchServicesREST.searchAddressAccount(searchObjOnWithPlanNo);
        custAddList = SearchServicesREST.searchAddressAccount(searchObjOnWithPlanAlp);
        custAddList = SearchServicesREST.searchAddressAccount(searchObjOnWithoutPlanNo);
        custAddList = SearchServicesREST.searchAddressAccount(searchObjOnWithoutPlanAlp);
        custAddList = SearchServicesREST.searchAddressAccount(searchObjOffNo);
        custAddList = SearchServicesREST.searchAddressAccount(searchObjOffAlp);
        System.assert(custAddList != null, 'aList was null.');

    }

    }
}