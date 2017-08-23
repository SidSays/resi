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
private class GetAddressByIdRESTTest {
private static testMethod void testGetAddressById(){
    SetupTestData.createCustomSettingRecords();
    RetrieveAllAccounts__c retrieveAcc = new RetrieveAllAccounts__c();
        retrieveAcc.Name = 'GetPlanServicesREST4';
        retrieveAcc.isActive__c= true;
        insert retrieveAcc;    
    
    
    Test.startTest();
    
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
    address1.Latitude__c = 11.1111;
    address1.Longitude__c = 22.2222;
    address1.Last_Knock_Date__c = System.now();
    address1.Most_Recent_Disposition__c = 'Contact';
    insert address1; 
    
    Account acc = new Account();
    acc.Name = 'TestAccount';
    acc.Customer_Status__c = 'Active';
    acc.Installation_Status__c = 'Active';
    acc.Region__c = null;
    acc.Service_Address__c = address1.Id;
    insert acc;
    
    Order__c order = new Order__c();
    order.Name = 'TestOrder';
    order.Order_Number__c = '1';  
    order.Salesperson_ID__c = 'abc1111';//Giving the sales ID of the user.
    order.Account__c = acc.Id;
    insert order;
    
    Order_Line_Item__c orderLineItem = new Order_Line_Item__c();
    orderLineItem.Order__c = order.Id;
    insert orderLineItem;
    
    Restrequest req = new Restrequest();
    req.requestURI = '/services/apexrest/GetAddressByIdREST';
    req.httpMethod = 'GET';
    req.addParameter('addressId', address1.Id);
    RestContext.request = req;
    
    List<Address> addList = new List<Address>();
    addList = GetAddressByIdREST.getAddressesById();
    System.assert(addList != null, 'aList was null.');
    Test.stopTest();
    
    
    
}
}