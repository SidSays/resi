@isTest
private class NoteSyncServicesREST3Test{
    private static testMethod void testNoteSyncServicesREST3(){
        SetupTestData.createCustomSettingRecords();
        

        Plan__c plan = new Plan__c();
        plan.Name = 'kbrayer Plan';
        plan.Plan_Status__c = 'Draft';
        plan.Plan_Level__c = 'Turf';  
        plan.Expiration_Date__c = date.today();
        insert plan;

        Account account = new Account();
        account.Name = 'TestAccount';
        
        Customer_Address__c address = new Customer_Address__c();
        address.Address__c = 'Test Address Line1';
        address.City__c = 'Test city';
        address.State__c = 'Test State';
        address.PostalCode__c = '98564';
        address.Country__c = 'Test Country';
        address.Corp__c = '111111';
        address.Route_Code__c = '1111111111';
        address.Node__c = '1111';
        address.Assigned_Date__c = Date.today()-10;
        address.Plan__c = plan.Id; 
        address.Latitude__c = 11.1111;
        address.Longitude__c = 22.2222;
        address.Last_Knock_Date__c = System.now();
        address.Most_Recent_Disposition__c = 'Contact';
        address.Account__c = account.Id;
        insert address;

        account.Service_Address__c = address.Id;
        insert account;

        Note note1 = new Note();
        note1.Title = 'Test Account Note';
        note1.Body = 'Test Account Note Body';
        note1.parentId = account.Id;
        insert note1;

        Note note2 = new Note();
        note2.Title = 'Test Address Note';
        note2.Body = 'Test Address Note Body';
        note2.parentId = address.Id;
        insert note2;

        Restrequest req = new Restrequest();
        req.requestURI = '/services/apexrest/NoteSyncServicesREST3/';
        req.httpMethod = 'GET';
        req.addParameter('planId', plan.Id +'&');
        req.addParameter('page','2');
        RestContext.request = req;
         RestResponse res = new RestResponse();
        RestContext.response = res;
        Test.startTest();
        
        NoteSyncServicesREST3.addressAccountNotifications();
        Test.StopTest();
        //System.assert(NoteSyncServicesREST3.addressAccountNotifications().noteList.size() == 2, 'did not properly fetch notes');

        
    }
}