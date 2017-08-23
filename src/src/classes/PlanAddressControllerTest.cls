/**********************************
 * Author     : Malay Desai, Accenture
 * Date       : 24-Apr-2017
 * Description: This is Test class for "PlanAddressController" class.
 * PROJECT    : Direct Sales
 */
@isTest
private class PlanAddressControllerTest {
    
    @testSetup
    static void setupTestData1() {
        SetupTestData.createCustomSettingRecords();
        SetupTestData.createUsers();
        User runningUser = [SELECT Id,Division,Region__c FROM User WHERE Id = :UserInfo.getUserId()];     
        User xsp = [SELECT Id FROM User WHERE Name = 'Testing1' AND FederationIdentifier = 'FedId4'];
        System.runAs(runningUser){
            Plan__c turfPlanObj = new Plan__c();
            turfPlanObj.Name = 'Test Turf Plan';
            turfPlanObj.Plan_Status__c = 'Assigned';
            turfPlanObj.Plan_Level__c = 'Turf';
            turfPlanObj.PlanCriteria__c = null;
            turfPlanObj.Expiration_Date__c = System.Today() + 10;
            turfPlanObj.User__c=xsp.Id;
            turfPlanObj.OwnerId=xsp.Id;
            turfPlanObj.Total_Worked_Addresses__c = 1;
            turfPlanObj.True_count_of_Addresses__c = 1;
            insert turfPlanObj;            
            
            Customer_Address__c addr  = new Customer_Address__c();
            Customer_Address__c addr1 = new Customer_Address__c();
            Customer_Address__c addr2 = new Customer_Address__c();
            Customer_Address__c addr3 = new Customer_Address__c();
                 
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '12345';
            addr.Route_Code__c = '1111111111';
            addr.Corp__c = '111111';
            addr.Region__c = runningUser.Region__c;
            addr.Division = runningUser.Division;
            addr.Rejected_Reason__c = 'test';           
            addr.Plan__c = turfPlanObj.Id;
            insert addr;
                       
            addr1.Address__c = 'Test Address1';
            addr1.State__c = 'Test State1';
            addr1.City__c = 'Test City1';
            addr1.Country__c = 'Test Country1';
            addr1.PostalCode__c = '12342';
            addr1.Node__c = '12342';
            addr1.Route_Code__c = '1111111111';
            addr1.Corp__c = '111111';
            addr1.Region__c = runningUser.Region__c;
            addr1.Division = runningUser.Division;           
            addr1.Plan__c = turfPlanObj.Id;
            insert addr1;
            
            addr3.Address__c = 'Test Address2';
            addr3.State__c = 'Test State2';
            addr3.City__c = 'Test City2';
            addr3.Country__c = 'Test Country2';
            addr3.PostalCode__c = '123422';
            addr3.Node__c = '123422';
            addr3.Route_Code__c = '11111111112';
            addr3.Corp__c = '1111112';
            addr3.Region__c = runningUser.Region__c;           
            insert addr3;
            
            
            Team__c team = new Team__c();
            team.Name = 'Test Team1';
            team.Region__c = runningUser.Region__c;
            team.Supervisor__c = SetupTestData.supervisorUser.Id;
            team.All_Team_Members__c = runningUser.id;
            insert team;
             system.debug('team1'+team);
            
            Team_Member__c teamMember = new Team_Member__c();
            teamMember.Team__c = team.Id;
            teamMember.User_Name__c = runningUser.Id;
            insert teamMember;
            
            Plan__c planObj = new Plan__c();
            planObj.Name = 'Test Turf Plan1';
            planObj.Plan_Status__c = 'Assigned';
            planObj.Plan_Level__c = 'Turf';
            planObj.PlanCriteria__c = null;
            planObj.Expiration_Date__c = System.Today() + 10;
            planObj.OwnerId=xsp.Id;
            planObj.Total_Worked_Addresses__c = 1;
            planObj.True_count_of_Addresses__c = 1;
            planObj.Assigned_Team__c = team.id;
            insert planObj;   
            
            
            addr2.Address__c = 'Test Address11';
            addr2.State__c = 'Test State';
            addr2.City__c = 'Test City';
            addr2.Country__c = 'Test Country';
            addr2.PostalCode__c = '12345';
            addr2.Node__c = '12345';
            addr2.Route_Code__c = '1111111111';
            addr2.Corp__c = '111111';
            addr2.Division = runningUser.Division;          
            addr2.Plan__c = planObj.Id;
            insert addr2;
            
            
        }
    }
    
    static testMethod void testMethod1() {
        Test.startTest();
        String loggedInUser = UserInfo.getUserId();
            User usr = [select Id,Region__c from User where Id = :userInfo.getUserId() limit 1];
            String likeLoggedInUser = loggedInUser.substring(0, 15);
        Plan__c p1 = [SELECT Id,Assigned_Team__c FROM Plan__c WHERE Name = 'Test Turf Plan'];
        User xsp = [SELECT Id FROM User WHERE Name = 'Testing1' AND FederationIdentifier = 'FedId4'];

        System.runAs(xsp){
             ApexPages.currentPage().getHeaders().put('USER-AGENT','iPhone');
            PlanAddressController paController = new PlanAddressController(new ApexPages.StandardController(p1));       
            PlanAddressController.getPlanAddresses(p1.Id);
             Test.setCurrentPage(Page.AddressFiltering);
        }       
        Test.stopTest();
    }

    static testMethod void testMethod2() {
        Test.startTest();
        User xsp = [SELECT Id FROM User WHERE Name = 'Testing1' AND FederationIdentifier = 'FedId4'];
        Plan__c p1 = [SELECT Id FROM Plan__c WHERE Name = 'Test Turf Plan'];
        Customer_Address__c a = [SELECT Id FROM Customer_Address__c WHERE Address__c = 'Test Address'];
        Customer_Address__c a1 = [SELECT Id FROM Customer_Address__c WHERE Address__c = 'Test Address1'];       
        
        List<Customer_Address__c> addresses = new List<Customer_Address__c>();
        addresses.add(a);
        addresses.add(a1);
        System.runAs(xsp){
             ApexPages.currentPage().getHeaders().put('USER-AGENT','Chrome 41.0.2228.0');
            PlanAddressController paController = new PlanAddressController(new ApexPages.StandardController(p1));
            
            String playlist = PlanAddressController.createPlaylistFromTurf(addresses,p1.Id,'Test Playlist'); 
               
            Plan__c p2 = [SELECT Id FROM Plan__c WHERE Id =: playlist];
            PlanAddressController.createPlaylistFromTurf(addresses,p2.Id,'Test Playlist2');
            Test.setCurrentPage(paController.redirectBasedOnBrowser());         
        }        
        Test.stopTest();
    }
     static testMethod void testMethod3() {
         Test.startTest();
        String loggedInUser = UserInfo.getUserId();
            User usr = [select Id,Region__c from User where Id = :userInfo.getUserId() limit 1];
            String likeLoggedInUser = loggedInUser.substring(0, 15);
        Plan__c p1 = [SELECT Id,Assigned_Team__c FROM Plan__c WHERE Name = 'Test Turf Plan1'];
        User xsp = [SELECT Id FROM User WHERE Name = 'Testing1' AND FederationIdentifier = 'FedId4'];
        
        System.runAs(usr){
             ApexPages.currentPage().getHeaders().put('USER-AGENT','iPhone');
            PlanAddressController paController = new PlanAddressController(new ApexPages.StandardController(p1));       
            PlanAddressController.getPlanAddresses(p1.Id);
            //Test.setCurrentPage(paController.redirectBasedOnBrowser());
        }       
       
        Test.stopTest();
    }
    
    static testMethod void testfindAddressesBySearchKey1() {
         Test.startTest();
        String loggedInUser = UserInfo.getUserId();
            User usr = [select Id,Region__c from User where Id = :userInfo.getUserId() limit 1];
            String likeLoggedInUser = loggedInUser.substring(0, 15);
          Plan__c p1 = [SELECT Id,Assigned_Team__c FROM Plan__c WHERE Name = 'Test Turf Plan'];
           String d1 = string.valueOf(system.today());
          String d2 = string.valueOf(System.Today().addDays(2));
        System.runAs(usr){
            PlanAddressController paController = new PlanAddressController(new ApexPages.StandardController(p1));       
            PlanAddressController.findAddressesBySearchKey('Test Address', 'on', p1.Id);
            PlanAddressController.findAddressesBySearchKey('Test Address2', 'off', p1.Id);
            PlanAddressController.findAddressesBySearchKey('Test Address1', 'both', p1.Id);
            PlanAddressController.getRejectedAddresses(d1, d2, p1.Id);
            
        }       
       
        Test.stopTest();
    }
    
}