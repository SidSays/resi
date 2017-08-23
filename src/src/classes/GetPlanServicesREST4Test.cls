@isTest
private class GetPlanServicesREST4Test{
    private static testMethod void testGetPlanServicesREST4(){
        SetupTestData.createCustomSettingRecords();
        RetrieveAllAccounts__c retrieveAcc = new RetrieveAllAccounts__c();
        retrieveAcc.Name = 'GetPlanServicesREST4';
        retrieveAcc.isActive__c= true;
        insert retrieveAcc;    
        Test.startTest();

        Plan__c plan = new Plan__c();
        plan.Name = 'kbray Plan';
        plan.Plan_Status__c = 'Draft';
        plan.Plan_Level__c = 'Turf';  
        plan.Expiration_Date__c = date.today();
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
        address1.Plan__c = plan.Id;
        address1.Assigned_Date__c = Date.today()-10;
        address1.Latitude__c = 11.1111;
        address1.Longitude__c = 22.2222;
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
        address2.Plan__c = plan.Id;
        address2.Assigned_Date__c = Date.today()-10;
        address2.Latitude__c = 11.1111;
        address2.Longitude__c = 22.2222;
        address2.Last_Knock_Date__c = System.now();
        address2.Most_Recent_Disposition__c = 'Contact';
        address2.Parent_Address__c=address1.Id;
        insert address2; 



        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Customer_Status__c = 'Active';
        acc.Installation_Status__c = 'Active';
        acc.Region__c = null;
        acc.Service_Address__c = address1.Id;
        insert acc;

        Order__c order1 = new Order__c();
        order1.Name = '110795673534';
        order1.Account__c = acc.Id;
        order1.Order_Number__c = '110795673534';
        order1.OrderStatus__c = 'Activated';
        order1.Order_Created_Date__c = system.now() - 200;
        order1.OrderCompletedDate__c = system.today() - 100;
        insert order1;

        Restrequest req = new Restrequest();
        req.requestURI = '/services/apexrest/GetPlanServicesREST5';
        req.httpMethod = 'GET';
        req.addParameter('parentPlanId', plan.Id);
        req.addParameter('page', '1');
        req.addParameter('date', Datetime.now().addDays(-1) +'');
        RestContext.request = req;

        order1 = new Order__c();
        order1.Name = '110795673535';
        order1.Account__c = acc.Id;
        order1.Order_Number__c = '110795673535';
        order1.OrderStatus__c = 'Activated';
        order1.Order_Created_Date__c = system.now() - 200;
        order1.OrderCompletedDate__c = system.today() - 100;
        insert order1;

        req = new Restrequest();
        req.requestURI = '/services/apexrest/GetPlanServicesREST4';
        req.httpMethod = 'GET';
        req.addParameter('parentPlanId', plan.Id);
        req.addParameter('page', '1');
        req.addParameter('date', Datetime.now().addDays(-1) +'');
        RestContext.request = req;

        List<Address> addressList = GetPlanServicesREST4.getAddresses();
        System.assert(addressList != null, 'addressList was null.');
        Test.stopTest();
    }
}