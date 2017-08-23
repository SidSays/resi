@isTest
private class GetComplexAddressesRESTTest{
	private static testMethod void testGetComplexAddressesREST(){
		User u = [Select Id From User where Id =: UserInfo.getUserId() Limit 1];
		System.runAs(u){
			SetupTestData.createCustomSettingRecords();
			SetupTestData.createUsers();
		}
		
		Test.startTest();

		Plan__c plan = new Plan__c();
		plan.Name = 'kbrayer Plan';
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
    	address1.Assigned_Date__c = Date.today()-10;
		address1.Plan__c = plan.Id; 
    	address1.Latitude__c = 11.1111;
    	address1.Longitude__c = 22.2222;
    	address1.Last_Knock_Date__c = System.now();
    	address1.Most_Recent_Disposition__c = 'Contact';
    	address1.OwnerId = SetupTestData.dsrUser.Id;
    	address1.Complex_Office__c = true;
    	insert address1;
		
		System.runAs(SetupTestData.dsrUser){
			RestRequest req = new RestRequest();
			req.requestURI = '/services.apexrest/GetComplexAddressesREST';
			req.httpMethod = 'GET';
			req.addParameter('userId', SetupTestData.dsrUser.Id);
			RestContext.request = req;

			List<Customer_Address__c> addList = new List<Customer_Address__c>();
			addList = GetComplexAddressesREST.getAddressesById();
			System.assert(addList != null, 'address list was null');
		}
		Test.stopTest();
	}
}