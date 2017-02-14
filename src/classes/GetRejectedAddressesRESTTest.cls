@isTest
private class GetRejectedAddressesRESTTest{
    
    private static testMethod void getRejectedAddress1(){
        SetupTestData.createCustomSettingRecords();
        String RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(Label.Knock).getRecordTypeId();
        Date startDate = System.Today();
        Date endDate =  startDate - 179;
        DateTime dt1 = DateTime.newInstance(startDate.year(),startDate.month(),startDate.day(),23,59,59);
        DateTime dt2 = DateTime.newInstance(endDate.year(),endDate.month(),endDate.day(),0,0,0);
        
        
        Plan__c testPlan = new Plan__c();
        testPlan.Name = 'Plan for Test';
        testPlan.Plan_Level__c = 'Turf';
        testPlan.Plan_Status__c = 'Draft';
        insert testPlan;
        
        Customer_Address__c testAddress = new Customer_Address__c();
        testAddress.Address__c = 'Test Address Line1';
        testAddress.City__c = 'Test city';
        testAddress.State__c = 'Test State';
        testAddress.PostalCode__c = '98564';
        testAddress.Country__c = 'Test Country';
        testAddress.Last_Knock_Date__c = System.now();
        testAddress.Rejected_Reason__c = 'Test Rejection Reason';
        testAddress.Plan__c = testPlan.Id;
        insert testAddress;
        
        Task testTask = new Task();
        testTask.WhatId = testAddress.Id;
        //testTask.RecordType.Id = RecordTypeId;
        testTask.Rejected__c = True;
        testTask.Rejected_Reason__c = testAddress.Rejected_Reason__c;
        insert testTask;
        
        Test.startTest();
        List<Customer_Address__c> testAddressList = [SELECT Id,Address__c,Plan__c,Last_Knock_Date__c, LastModifiedDate,(SELECT Id, WhatId,CreatedDate,Rejected_Reason__c FROM Tasks) From Customer_Address__c WHERE Id = :testAddress.Id];
        List<Task> testTaskList = [SELECT Id, WhatId,CreatedDate,Rejected_Reason__c FROM Task WHERE WhatId = :testAddress.Id]; 
                                   
        //GetRejectedAddressesREST.RejectedAddressesAPIWrapper wrapList = new GetRejectedAddressesREST.RejectedAddressesAPIWrapper();
        //wrapList.rejectedAddressList.add(testAddress);
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/GetRejectedAddressesREST';
        request.httpMethod = 'GET';
        request.addParameter('planId',testPlan.Id);
        request.addParameter('startDate',String.valueOf(dt1));
        request.addParameter('endDate',String.valueOf(dt2));
        RestContext.request = request;
        try{
        GetRejectedAddressesREST.doGet();
        }
        catch(Exception e){
            System.debug('Exception occured');
        }
        Test.stopTest();
     }
}