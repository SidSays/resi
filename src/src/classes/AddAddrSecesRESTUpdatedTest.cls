@isTest
private class AddAddrSecesRESTUpdatedTest {
    private static testMethod void testAddAddresses(){
        User usr = [select Id from User where Id = :userInfo.getUserId() limit 1];
        SetupTestData.createCustomSettingRecords();
        
        system.runAs(usr){
            SetupTestData.createIndirectUser();
            SetupTestData.createUsers();
        }
        Test.startTest();
        Restrequest req = new Restrequest();
        req.requestURI = '/services/apexrest/AddAddressServicesRESTUpdated';
        req.httpMethod = 'POST';
        RestContext.request = req;

        System.runAs(SetupTestData.supervisorUser){
        Plan__c plan = new Plan__c();
        plan.Name = 'Druv Plan';
        plan.Plan_Status__c = 'Draft';
        plan.Plan_Level__c = 'Turf';  
        plan.Expiration_Date__c = date.today();
        plan.User__c=SetupTestData.dsrUser4.Id;
        plan.Playlist_External_Id__c = 'Test111';
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

        AddAddressServicesRESTUpdated.addressObject add = new AddAddressServicesRESTUpdated.addressObject();
        add.expirationDate = DateTime.now().addDays(5).format('MM/dd/yyyy');
        add.owner = SetupTestData.dsrUser4.Id;
        add.parentPlanId = plan.Id;
        add.planType = 'Playlist';
        add.playListName = 'Playlist Test 1';
        add.user = SetupTestData.dsrUser4.Id;
        add.uniqueId = '12345';
        List<String> addList = new List<String>();
        addList.add(address1.Id);
        add.addressList = addList;

        AddAddressServicesRESTUpdated.returnValues ret = new AddAddressServicesRESTUpdated.returnValues();
        ret = AddAddressServicesRESTUpdated.addAddresses(add);

        add = new AddAddressServicesRESTUpdated.addressObject();
        add.expirationDate = DateTime.now().addDays(-1).format('MM/dd/yyyy');
        add.owner = SetupTestData.dsrUser4.Id;
        add.parentPlanId = plan.Id;
        add.planType = 'Playlist';
        add.playListName = 'Playlist Test 1';
        add.uniqueId = '123456';        
        add.user = SetupTestData.dsrUser4.Id;
        addList = new List<String>();
        addList.add(address1.Id);
        add.addressList = addList;

        ret = new AddAddressServicesRESTUpdated.returnValues();
        ret = AddAddressServicesRESTUpdated.addAddresses(add);
        String planId = ret.planId;
        System.assert(true,planId != Null);
        Boolean returnId = ret.result;
        System.assert(true,returnId != Null);
                }
        Test.stopTest();
    }
}