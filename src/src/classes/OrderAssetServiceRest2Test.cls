@isTest
public class OrderAssetServiceRest2Test {
    private static testMethod void testOrderAssetServiceRest2(){
    	SetupTestData.createCustomSettingRecords();
    	Test.startTest();

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

    	Asset asset = new Asset();
    	asset.Name = 'Test Asset';
    	asset.AccountId = account.Id;
    	insert asset;

    	Order__c order = new Order__c();
    	order.Name = 'Test Order';
    	order.Account__c = account.Id;
    	order.Order_Number__c = '11111111111';
    	insert order;

    	Order_Line_Item__c orderLineItem = new Order_Line_Item__c();
    	orderLineItem.Name = 'Test Order Line Item';
    	orderLineItem.Order__c = order.Id;
    	insert orderLineItem;

		Restrequest req = new Restrequest();
		req.requestURI = '/services/apexrest/OrderAssetServiceRest2';
		req.httpMethod = 'GET';
		req.addParameter('planId', plan.Id +'');
		req.addParameter('page', '1');
		RestContext.request = req;

		System.assert(OrderAssetServiceRest2.getOrderAsset().orderList != null, 'orderList was null');
		System.assert(OrderAssetServiceRest2.getOrderAsset().assetList != null, 'assetList was null');

    	Test.stopTest();
    }
}