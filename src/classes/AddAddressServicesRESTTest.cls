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
private class AddAddressServicesRESTTest {
    private static testMethod void testAddAddresses(){
        User usr = [select Id from User where Id = :userInfo.getUserId() limit 1];
        SetupTestData.createCustomSettingRecords();
        
        system.runAs(usr){
            SetupTestData.createIndirectUser();
            SetupTestData.createUsers();
        }
        Test.startTest();
        Restrequest req = new Restrequest();
        req.requestURI = '/services/apexrest/AddAddressServicesREST';
        req.httpMethod = 'POST';
        RestContext.request = req;

        System.runAs(SetupTestData.supervisorUser){
        Plan__c plan = new Plan__c();
        plan.Name = 'Druv Plan';
        plan.Plan_Status__c = 'Draft';
        plan.Plan_Level__c = 'Turf';  
        plan.Expiration_Date__c = date.today();
        plan.User__c=SetupTestData.dsrUser4.Id;
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
        address1.Latitude__c = 11.1111;
        address1.Longitude__c = 22.2222;
        address1.Last_Knock_Date__c = System.now();
        address1.Most_Recent_Disposition__c = 'Contact';
        insert address1; 

        plan.Plan_Status__c='Assigned';
        update plan;

        AddAddressServicesREST.addressObject add = new AddAddressServicesREST.addressObject();
        add.expirationDate = DateTime.now().addDays(5).format('MM/dd/yyyy');
        add.owner = SetupTestData.dsrUser4.Id;
        add.parentPlanId = plan.Id;
        add.planType = 'Playlist';
        add.playListName = 'Playlist Test 1';
        add.user = SetupTestData.dsrUser4.Id;
        List<String> addList = new List<String>();
        addList.add(address1.Id);
        add.addressList = addList;
        
        AddAddressServicesREST.returnValues ret = new AddAddressServicesREST.returnValues();
        ret = AddAddressServicesREST.addAddresses(add);
        
        add = new AddAddressServicesREST.addressObject();
        add.expirationDate = DateTime.now().addDays(-1).format('MM/dd/yyyy');
        add.owner = SetupTestData.dsrUser4.Id;
        add.parentPlanId = plan.Id;
        add.planType = 'Playlist';
        add.playListName = 'Playlist Test 1';
        add.user = SetupTestData.dsrUser4.Id;
        addList = new List<String>();
        addList.add(address1.Id);
        add.addressList = addList;

        ret = new AddAddressServicesREST.returnValues();
        ret = AddAddressServicesREST.addAddresses(add);
        String planId = ret.planId;
        System.assert(true,planId != Null);
        Boolean returnId = ret.result;
        System.assert(true,returnId != Null);
        // -------------AddAddressServicesRESTUpdated-------------------------------------------------------------
        AddAddressServicesRESTUpdated.addressObject add1 = new AddAddressServicesRESTUpdated.addressObject();
        add1.expirationDate = DateTime.now().addDays(5).format('MM/dd/yyyy');
        add1.owner = SetupTestData.dsrUser4.Id;
        add1.parentPlanId = plan.Id;
        add1.planType = 'Playlist';
        add1.PlaylistSource='Lasso';
        add1.playListName = 'Playlist Test 1';
        add1.user = SetupTestData.dsrUser4.Id;
        add1.numberOfAddresses = 1;
        add1.uniqueId = 'UniqueSid';
        List<String> addList1 = new List<String>();
        addList1.add(address1.Id);
        add1.addressList = addList1;
        
        AddAddressServicesRESTUpdated.returnValues ret1 = new AddAddressServicesRESTUpdated.returnValues();
        ret1 = AddAddressServicesRESTUpdated.addAddresses(add1);
        
        add1 = new AddAddressServicesRESTUpdated.addressObject();
        add1.expirationDate = DateTime.now().addDays(-1).format('MM/dd/yyyy');
        add1.owner = SetupTestData.dsrUser4.Id;
        add1.parentPlanId = plan.Id;
        add1.planType = 'Playlist';
        add1.PlaylistSource='Lasso';
        add1.playListName = 'Playlist Test 1';
        add1.user = SetupTestData.dsrUser4.Id;
        add1.numberOfAddresses = 1;
        add1.uniqueId = 'UniqueSid';
        addList1 = new List<String>();
        addList1.add(address1.Id);
        add1.addressList = addList1;

        ret1 = new AddAddressServicesRESTUpdated.returnValues();
        ret1 = AddAddressServicesRESTUpdated.addAddresses(add1);
        String planId1 = ret1.planId;
        System.assert(true,planId1 != Null);
        Boolean returnaId = ret1.result;
        System.assert(true,returnaId != Null);
        //------------------
                }
        Test.stopTest();
    }
}