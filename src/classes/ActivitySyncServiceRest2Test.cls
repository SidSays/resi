@isTest
private class ActivitySyncServiceRest2Test {
    private static testMethod void testActivitySyncService2EmptyTaskandEvent(){
    	SetupTestData.createCustomSettingRecords();
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
    	insert address1;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ActivitySyncServicesREST2';
        req.httpMethod = 'GET';
        req.addParameter('planId', plan.Id);
        req.addParameter('page', '1');
        RestContext.request = req;

		System.assert(ActivitySyncServiceRest2.getActivityByTurf() != null, 'activityList was null');
		Test.stopTest();
    }

        private static testMethod void testActivitySyncService2EmptyEvent(){
        SetupTestData.createCustomSettingRecords();
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
        insert address1;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ActivitySyncServicesREST2';
        req.httpMethod = 'GET';
        req.addParameter('planId', plan.Id);
        req.addParameter('page', '1');
        RestContext.request = req;

        Task task = new Task();
        task.Plan_Id__c = plan.Id;
        task.WhatId = address1.Id;
        insert task;

        task = new Task();
        task.Plan_Id__c = plan.Id;
        task.WhatId = address1.Id;
        insert task;

        req = new RestRequest();
        req.requestURI = '/services/apexrest/ActivitySyncServicesREST2';
        req.httpMethod = 'GET';
        req.addParameter('planId', plan.Id);
        req.addParameter('page', '1');
        RestContext.request = req;

        System.assert(ActivitySyncServiceRest2.getActivityByTurf() != null, 'activityList was null');
        Test.stopTest();
    }

    private static testMethod void testActivitySyncService2EmptyTask(){
        SetupTestData.createCustomSettingRecords();
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
        insert address1;

        Event event = new Event();
        event.Plan_Id__c = plan.Id;
        event.WhatId = address1.Id;
        event.DurationInMinutes=60;
        event.ActivityDateTime=DateTime.now();
        insert event;

        event = new Event();
        event.Plan_Id__c = plan.Id;
        event.WhatId = address1.Id;
        event.DurationInMinutes=60;
        event.ActivityDateTime=DateTime.now();
        insert event;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ActivitySyncServicesREST2';
        req.httpMethod = 'GET';
        req.addParameter('planId', plan.Id);
        req.addParameter('page', '1');
        RestContext.request = req;

        System.assert(ActivitySyncServiceRest2.getActivityByTurf() != null, 'activityList was null');
        Test.stopTest();
    }

    private static testMethod void testActivitySyncService2TaskandEvent(){
        SetupTestData.createCustomSettingRecords();
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
        insert address1;

        Event event = new Event();
        event.Plan_Id__c = plan.Id;
        event.WhatId = address1.Id;
        event.DurationInMinutes=60;
        event.ActivityDateTime=DateTime.now();
        insert event;

        event = new Event();
        event.Plan_Id__c = plan.Id;
        event.WhatId = address1.Id;
        event.DurationInMinutes=60;
        event.ActivityDateTime=DateTime.now();
        insert event;

        Task task = new Task();
        task.Plan_Id__c = plan.Id;
        task.WhatId = address1.Id;
        insert task;

        task = new Task();
        task.Plan_Id__c = plan.Id;
        task.WhatId = address1.Id;
        insert task;

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/ActivitySyncServicesREST2';
        req.httpMethod = 'GET';
        req.addParameter('planId', plan.Id);
        req.addParameter('page', '1');
        RestContext.request = req;

        System.assert(ActivitySyncServiceRest2.getActivityByTurf() != null, 'activityList was null');
        Test.stopTest();
    }
}