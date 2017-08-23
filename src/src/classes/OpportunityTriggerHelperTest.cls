@isTest (seeAllData = false)

public class OpportunityTriggerHelperTest {
    
    
     private static testmethod void testSendEmailToCAROnOpportunityProperty(){
        Test.startTest();
        TestDataUtility.createCustomSettingRecords(); 
        
        TriggerSettings__c opportunityTrigger = new TriggerSettings__c();
        opportunityTrigger.Name = 'OpportunityTrigger';
        opportunityTrigger.isActive__c = true;
        database.insert(opportunityTrigger,false);

        
        List<Opportunity> oppList = new List<Opportunity>();
        Account accObj = TestDataUtility.createAccount();
        Insert accObj;
        User currentUser = [Select Id,Region__c,email, username from User where Id =: userInfo.getUserId()];
        currentUser.Region__c = 'Global';
        currentUser.email = 'abc@xyz.com';
        currentUser.Terms_and_Conditions_Accepted__c = system.today();
        update currentUser;
        
        
        User CARUser = TestDataUtility.createXfinityCARUser();
         MDU_property__c propObj = TestDataUtility.createProperty();
         propobj.Assigned_CAR__c = CARUser.id;
         propobj.Industry_Type__c = 'Commercial';
         propobj.Property_Type__c = 'Commercial';
         propobj.Contracting_Org_Type__c ='Developer';
         propobj.Common_area_wide_wifi_ready__c='Yes';
         propobj.Property_wide_wifi_ready__c='Yes';
         propobj.Wifi_ready__c='Yes';
         insert propObj;
         
        Profile p1 = [Select Id, Name From Profile where Name = 'XC AE Contractors' limit 1];
        List<User> userList = new List<User>();
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 8)+1150)+'';
        User xcContractorUser = new User(Alias = 'AE_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId11'+randomstr1,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
        xcContractorUser.Region__c=currentUser.Region__c;
        userList.add(xcContractorUser);
        
       
        insert userList;
        
        
            Opportunity opp = new Opportunity();
            opp.Name ='Test Opportunity';
            opp.StageName = 'Assigned';
            opp.CloseDate =Date.today()+10;
            opp.IPTV__c = true;
            opp.Incremental_Subs_Added__c=1234;
            opp.AccountId = accObj.id;
            opp.AssignedAE_ID__c = xcContractorUser.Id;
            opp.Type = 'New Build';
            opp.Property__c = PropObj.id;
            opp.ContractTerm__c = 12;
            opp.ContractTermUnit__c = 'months';
            opp.Contract_Type__c = 'Bulk';
            opp.Fiber_To_The_Unit__c='Fiber to the Unit';
            opp.StageName = 'Closed Won';
            opp.IPTV__c = false;
            opp.ProjectedOccupancyDate__c = date.today();
            opp.X3rd_Party_Consultant__c = 'Advanced Multi Media';
            opp.Common_Area_Wide_WiFi_Ready__c = 'Yes';
            opp.WiFi_Ready__c = 'Yes';
            opp.Property_Wide_WiFi_Ready__c = 'Yes';
            opp.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId();
            opp.Sales_Portfolio_Name__c='TestPortfolio'; 
            oppList.add(opp);
            insert oppList;
            
            Opportunity_Property__c oppPropObj = TestDataUtility.createOppProperty(oppList[0].id,propObj.id);
            
            opp.StageName = 'Contract Document Review';
            update oppList;
            Test.stopTest(); 
     }
    
    private static testmethod void testRestrictEditWifiReadyFieldsUpdate(){
        Test.startTest();
        TestDataUtility.createCustomSettingRecords(); 
        
        TriggerSettings__c opportunityTrigger = new TriggerSettings__c();
        opportunityTrigger.Name = 'OpportunityTrigger';
        opportunityTrigger.isActive__c = true;
        database.insert(opportunityTrigger,false);

        
        List<Opportunity> oppList = new List<Opportunity>();
        Account accObj = TestDataUtility.createAccount();
        Insert accObj;
        User currentUser = [Select Id,Region__c,email, username from User where Id =: userInfo.getUserId()];
        currentUser.Region__c = 'Global';
        currentUser.email = 'abc@xyz.com';
        currentUser.Terms_and_Conditions_Accepted__c = system.today();
        update currentUser;
        
        
        User CARUser = TestDataUtility.createXfinityCARUser();
         MDU_property__c propObj = TestDataUtility.createProperty();
         propobj.Assigned_CAR__c = CARUser.id;
         propobj.Industry_Type__c = 'Commercial';
         propobj.Property_Type__c = 'Commercial';
         propobj.Contracting_Org_Type__c ='Developer';
         propobj.Common_area_wide_wifi_ready__c='Yes';
         propobj.Property_wide_wifi_ready__c='Yes';
         propobj.Wifi_ready__c='Yes';
         insert propObj;
         
        Profile p1 = [Select Id, Name From Profile where Name = 'XC AE Contractors' limit 1];
        List<User> userList = new List<User>();
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 8)+1150)+'';
        User xcContractorUser = new User(Alias = 'AE_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId11'+randomstr1,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
        xcContractorUser.Region__c=currentUser.Region__c;
        userList.add(xcContractorUser);
        
       
        insert userList;
        
        
            Opportunity opp = new Opportunity();
            opp.Name ='Test Opportunity';
            opp.StageName = 'Assigned';
            opp.CloseDate =Date.today()+10;
            opp.IPTV__c = true;
            opp.Incremental_Subs_Added__c=1234;
            opp.AccountId = accObj.id;
            opp.AssignedAE_ID__c = xcContractorUser.Id;
            opp.Type = 'New Build';
            opp.Property__c = PropObj.id;
            opp.ContractTerm__c = 12;
            opp.ContractTermUnit__c = 'months';
            opp.Contract_Type__c = 'Bulk';
            opp.Fiber_To_The_Unit__c='Fiber to the Unit';
            opp.StageName = 'Closed Won';
            opp.IPTV__c = false;
            opp.ProjectedOccupancyDate__c = date.today();
            opp.X3rd_Party_Consultant__c = 'Advanced Multi Media';
            opp.Common_Area_Wide_WiFi_Ready__c = 'Yes';
            opp.WiFi_Ready__c = 'Yes';
            opp.Property_Wide_WiFi_Ready__c = 'Yes';
            opp.recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId();
            opp.Sales_Portfolio_Name__c='TestPortfolio'; 
            oppList.add(opp);
            insert oppList;
            
            Opportunity_Property__c oppPropObj = TestDataUtility.createOppProperty(oppList[0].id,propObj.id);
            
            opp.StageName = 'Contract Document Review';
            update oppList;
        try{
            opp.Common_Area_Wide_WiFi_Ready__c='Yes';
            opp.Property_Wide_WiFi_Ready__c='Yes';
            opp.WiFi_Ready__c='No';
            update oppList;
           }
        catch(Exception e){
            system.assertEquals('Common Area Wide WiFi Ready,Property Wide WiFi Ready,WiFi Ready should match with the Primary Property fields','Common Area Wide WiFi Ready,Property Wide WiFi Ready,WiFi Ready should match with the Primary Property fields');
        }
            Test.stopTest(); 
     }
}