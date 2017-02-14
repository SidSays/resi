@isTest
private class AddKnockServicesRESTTest {
    private static testMethod void testAddAddresses(){
        User usr = [select Id from User where Id = :userInfo.getUserId() limit 1];
        SetupTestData.createCustomSettingRecords();
        
        system.runAs(usr){
            SetupTestData.createIndirectUser();
            SetupTestData.createUsers();
        }
        Test.startTest();
        Restrequest req = new Restrequest();
        req.requestURI = '/services/apexrest/AddKnockServicesREST';
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

        AddKnockServicesREST.KnockObject knock = new AddKnockServicesREST.KnockObject();
        
        Knock.description = 'test';
       knock.disposition = 'test';
       knock.event_Category = 'test';
       knock.event_Name_or_Number = 'test';
       knock.hsi_Sold = 1;
       knock.home_Security_Competitor = 'test';
       knock.internet_Competitor = 'test';
       knock.knocked_Date = system.now();
       knock.internet_Contract_End = system.today(); 
       knock.video_Contract_End = system.today(); 
       knock.phone_Contract_End = system.today(); 
       knock.security_Contract_End = system.today();
       knock.non_Marketable_Reason = 'test' ;
       knock.ownerId = userInfo.getUserId();
       knock.phone_Competitor = 'test';
       knock.priority = 'test' ;               
       knock.rejected_Reason  = 'test';
       knock.rejected = 1;
       knock.sales_Type = 'test';
       knock.status = 'test';
       knock.subject = 'test';
       knock.type = 'test';
       knock.video_Competitor = 'test';
       knock.video_Sold = 1;
       knock.voice_Sold = 1;
       knock.whatId = address1.Id;
       knock.xh_Sold = 1;
       knock.activity = 'test';       
       knock.call_Date = system.today();
       knock.number_Called = '1234567890';
       knock.purpose_Of_The_Call = 'test';
       knock.resident_Called = 'test';       
       knock.uniqueId = 'test';
       Knock.activityDate = system.today();
       
       AddKnockServicesREST.returnValues ret = new AddKnockServicesREST.returnValues();
       ret = AddKnockServicesREST.addKnocks(Knock);
       

        
            
        Test.stopTest();
    }
    
}
}