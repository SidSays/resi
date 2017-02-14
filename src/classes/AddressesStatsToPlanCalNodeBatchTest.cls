@isTest
private class AddressesStatsToPlanCalNodeBatchTest  {

    public static testMethod void testAddressStatsPlanNodeBatch(){
            
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            String CRON_EXP = '0 0 0 3 9 ? 2020';
            SetupTestData.createCustomSettingRecords();
            SetupTestData.createUsers();
            
            List<User> userList = new List<User>();
            
             Profile p =  [Select Id, Name From Profile where Name = 'Community Account Representative​' limit 1];
             String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
             String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1250)+'';
             String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1350)+'';
             String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1050)+'';
             User XfinityCARUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    LastName='Testing1 Testing1 Testing1 Testing1 Te',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
             userList.add(XfinityCARUser);
             
              User XfinityCARUser1 = new User(Alias = 'MDU_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    LastName='Testing1 Testing1 Testing1 Testing1 Te',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1'+randomstr1,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4));
         userList.add(XfinityCARUser1);
             
              User XfinityCARUser2 = new User(Alias = 'MDU_' + randomstr2.substring(0,4),
                                    Email = randomstr2 + 'userTest1@SampleTest.com',
                                    LastName='Testing1 Testing1 Testing1 Testing1 Te',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr2 + '@SampleTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1'+randomstr2,
                                    EmployeeNumber = 'Emp1' + randomstr2.substring(0,4));
            userList.add(XfinityCARUser2);
             
              User XfinityCARUser3 = new User(Alias = 'MDU_' + randomstr3.substring(0,4),
                                    Email = randomstr3 + 'userTest1@SampleTest.com',
                                    LastName='Testing1 Testing1 Testing1 Testing1 Te',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr3 + '@SampleTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1'+randomstr3,
                                    EmployeeNumber = 'Emp1' + randomstr3.substring(0,4));
            userList.add(XfinityCARUser3);
            
            insert userList;
             
            
 
            
            // Creating Customer Address records.
            Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
            List<Customer_Address__c> addressList = new List<Customer_Address__c>();
            
            Customer_Address__c address1 = new Customer_Address__c();
            address1.Address__c = 'Test Address Line1';
            address1.City__c = 'Test city';
            address1.State__c = 'Test State';
            address1.PostalCode__c = '98564';
            address1.Country__c = 'Test Country';
            address1.Corp__c = '111111';
            address1.Division=freedomRegion.Id;
            address1.Route_Code__c = '1111111111';
            address1.Node__c = '6542';
            address1.WorkedDate__c=System.today();
            address1.Region__c='Freedom Market';
            address1.Assigned_Date__c = Date.today()-10;
            address1.Latitude__c = 11.1111;
            address1.Longitude__c = 22.2222;
            address1.Property_Code__c='A011';
            address1.Last_Knock_Date__c = System.now();
            address1.Most_Recent_Disposition__c = 'Contact';
            addressList.add(address1);
                       
            
            Customer_Address__c address2 = new Customer_Address__c();
            address2.Address__c = 'Test Address Line1';
            address2.City__c = 'Test city';
            address2.State__c = 'Test State';
            address2.Node__c = '6542';
            address2.Country__c = 'Test Country';  
            address2.PostalCode__c = '98564';
            address2.Corp__c = '222222';
            address2.WorkedDate__c=System.today().addDays(-5);
            address2.Route_Code__c = '2222222222';
            address2.Region__c='Freedom Market';
            address2.Division=freedomRegion.Id;
            address2.Property_Code__c='A012';
            address2.Assigned_Date__c = Date.today()-10;
            address2.Latitude__c = 33.3333;
            address2.Longitude__c = 44.444;
            address2.Last_Knock_Date__c = System.now()-100;
            address2.Most_Recent_Disposition__c = 'No Answer';
            addressList.add(address2);
            
            Customer_Address__c address3 = new Customer_Address__c();
            address3.Address__c = 'Test Address Line1';
            address3.City__c = 'Test city';
            address3.State__c = 'Test State';
            address3.Node__c = '6542';
            address3.Country__c = 'Test Country';  
            address3.PostalCode__c = '98564';
            address3.Corp__c = '222222';
            address3.WorkedDate__c=System.today().addDays(-5);
            address3.Route_Code__c = '2222222222';
            address3.Region__c='Freedom Market';
            address3.Division=freedomRegion.Id;
            address3.Property_Code__c='A012';
            address3.Assigned_Date__c = Date.today()-10;
            address3.Latitude__c = 33.3333;
            address3.Longitude__c = 44.444;
            address3.Last_Knock_Date__c = System.now()-100;
            address3.Most_Recent_Disposition__c = 'No Answer';
            addressList.add(address3);
            
            Customer_Address__c address4 = new Customer_Address__c();
            address4.Address__c = 'Test Address Line1';
            address4.City__c = 'Test city';
            address4.State__c = 'Test State';
            address4.Node__c = '6542';
            address4.Country__c = 'Test Country';  
            address4.PostalCode__c = '98564';
            address4.Corp__c = '222222';
            address4.WorkedDate__c=System.today().addDays(-5);
            address4.Route_Code__c = '2222222222';
            address4.Region__c='Freedom Market';
            address4.Division=freedomRegion.Id;
            address4.Property_Code__c='A012';
            address4.Assigned_Date__c = Date.today()-10;
            address4.Latitude__c = 33.3333;
            address4.Longitude__c = 44.444;
            address4.Last_Knock_Date__c = System.now()-100;
            address4.Most_Recent_Disposition__c = 'No Answer';
            addressList.add(address4);
            
            Customer_Address__c address5 = new Customer_Address__c();
            address5.Address__c = 'Test Address Line1';
            address5.City__c = 'Test city';
            address5.State__c = 'Test State';
            address5.Node__c = '6542';
            address5.Country__c = 'Test Country';  
            address5.PostalCode__c = '98564';
            address5.Corp__c = '222222';
            address5.WorkedDate__c=System.today().addDays(-5);
            address5.Route_Code__c = '2222222222';
            address5.Region__c='Freedom Market';
            address5.Division=freedomRegion.Id;
            address5.Property_Code__c='A012';
            address5.Assigned_Date__c = Date.today()-10;
            address5.Latitude__c = 33.3333;
            address5.Longitude__c = 44.444;
            address5.Last_Knock_Date__c = System.now()-100;
            address5.Most_Recent_Disposition__c = 'No Answer';
            addressList.add(address5);
            
            Customer_Address__c address6 = new Customer_Address__c();
            address6.Address__c = 'Test Address Line1';
            address6.City__c = 'Test city';
            address6.State__c = 'Test State';
            address6.Node__c = '6542';
            address6.Country__c = 'Test Country';  
            address6.PostalCode__c = '98564';
            address6.Corp__c = '222222';
            address6.WorkedDate__c=System.today().addDays(-5);
            address6.Route_Code__c = '2222222222';
            address6.Region__c='Freedom Market';
            address6.Division=freedomRegion.Id;
            address6.Property_Code__c='A012';
            address6.Assigned_Date__c = Date.today()-10;
            address6.Latitude__c = 33.3333;
            address6.Longitude__c = 44.444;
            address6.Last_Knock_Date__c = System.now()-100;
            address6.Most_Recent_Disposition__c = 'No Answer';
             addressList.add(address6);
            
            Customer_Address__c address7 = new Customer_Address__c();
            address7.Address__c = 'Test Address Line1';
            address7.City__c = 'Test city';
            address7.State__c = 'Test State';
            address7.Node__c = '6542';
            address7.Country__c = 'Test Country';  
            address7.PostalCode__c = '98564';
            address7.Corp__c = '222222';
            address7.WorkedDate__c=System.today().addDays(-5);
            address7.Route_Code__c = '2222222222';
            address7.Region__c='Freedom Market';
            address7.Division=freedomRegion.Id;
            address7.Property_Code__c='A012';
            address7.Assigned_Date__c = Date.today()-10;
            address7.Latitude__c = 33.3333;
            address7.Longitude__c = 44.444;
            address7.Last_Knock_Date__c = System.now()-100;
            address7.Most_Recent_Disposition__c = 'No Answer';
            addressList.add(address7);
            
            Customer_Address__c address8 = new Customer_Address__c();
            address8.Address__c = 'Test Address Line1';
            address8.City__c = 'Test city';
            address8.State__c = 'Test State';
            address8.Node__c = '6542';
            address8.Country__c = 'Test Country';  
            address8.PostalCode__c = '98564';
            address8.Corp__c = '222222';
            address8.WorkedDate__c=System.today().addDays(-5);
            address8.Route_Code__c = '2222222222';
            address8.Region__c='Freedom Market';
            address8.Division=freedomRegion.Id;
            address8.Property_Code__c='A012';
            address8.Assigned_Date__c = Date.today()-10;
            address8.Latitude__c = 33.3333;
            address8.Longitude__c = 44.444;
            address8.Last_Knock_Date__c = System.now()-100;
            address8.Most_Recent_Disposition__c = 'No Answer';
             addressList.add(address8);
            
            Customer_Address__c address9 = new Customer_Address__c();
            address9.Address__c = 'Test Address Line1';
            address9.City__c = 'Test city';
            address9.State__c = 'Test State';
            address9.Node__c = '6542';
            address9.Country__c = 'Test Country';  
            address9.PostalCode__c = '98564';
            address9.Corp__c = '222222';
            address9.WorkedDate__c=System.today().addDays(-5);
            address9.Route_Code__c = '2222222222';
            address9.Region__c='Freedom Market';
            address9.Division=freedomRegion.Id;
            address9.Property_Code__c='A012';
            address9.Assigned_Date__c = Date.today()-10;
            address9.Latitude__c = 33.3333;
            address9.Longitude__c = 44.444;
            address9.Last_Knock_Date__c = System.now()-100;
            address9.Most_Recent_Disposition__c = 'No Answer';
             addressList.add(address9);
            
            Customer_Address__c address10 = new Customer_Address__c();
            address10.Address__c = 'Test Address Line1';
            address10.City__c = 'Test city';
            address10.State__c = 'Test State';
            address10.Node__c = '6542';
            address10.Country__c = 'Test Country';  
            address10.PostalCode__c = '98564';
            address10.Corp__c = '222222';
            address10.WorkedDate__c=System.today().addDays(-5);
            address10.Route_Code__c = '2222222222';
            address10.Region__c='Freedom Market';
            address10.Division=freedomRegion.Id;
            address10.Property_Code__c='A012';
            address10.Assigned_Date__c = Date.today()-10;
            address10.Latitude__c = 33.3333;
            address10.Longitude__c = 44.444;
            address10.Last_Knock_Date__c = System.now()-100;
            address10.Most_Recent_Disposition__c = 'No Answer';
             addressList.add(address10);
             
             insert addressList;
            
            List<Plan__c> plans = new List<Plan__c>();
            
            Plan__c planObj = new Plan__c();
            Plan__c planObj2 = new Plan__c();
            Plan__c planObj3 = new Plan__c();
            Plan__c planObj4 = new Plan__c();
            Plan__c planObj5 = new Plan__c();
            Plan__c planObj6 = new Plan__c();
            Plan__c planObj7 = new Plan__c();
            Plan__c planObj8 = new Plan__c();
            Plan__c planObj9 = new Plan__c();
            Plan__c planObj10 = new Plan__c();
            //Creating a Plan
          //  System.runAs(SetupTestData.supervisorUser)
          System.runAs(XfinityCARUser)
            {
            Team__c team = new Team__c();
            team.Name = 'Test Team';
            team.Region__c = 'Freedom';
            team.Supervisor__c = SetupTestData.supervisorUser.Id;
            team.All_Team_Members__c = 'New';
            insert team;
            
            Team_Member__c teamMember = new Team_Member__c();
            teamMember.Team__c = team.Id;
            teamMember.User_Name__c = XfinityCARUser.Id;
            insert teamMember;
            
            //Creating Address statistics records.
            Address_Statistics__c addrsStatsObj1 = new Address_Statistics__c();
            addrsStatsObj1.Name = 'Node Stats1';
            addrsStatsObj1.Zip_Code__c='98564';
            addrsStatsObj1.Node__c='6542';
            addrsStatsObj1.Currently_Assigned_to_Turf__c = false;
            addrsStatsObj1.Assigned__c = false;
            addrsStatsObj1.Percent_Currently_Assigned__c = 0.0;
            addrsStatsObj1.Num_of_Currently_Assigned__c = 0;
            addrsStatsObj1.Worked__c = false;
            addrsStatsObj1.Percent_Complex_Code__c = 0.0;
            addrsStatsObj1.Region__c = 'Freedom';
            
            //Address_Statistics__c addrsStatsObj2 = new Address_Statistics__c(Name='Node Stats1',Node__c='6542', Region__c='Freedom');
            
            insert addrsStatsObj1;
            
            Address_Statistics__c addrsStatsObj2 = new Address_Statistics__c();
            addrsStatsObj2.Name = 'Node Stats2';
            addrsStatsObj2.Zip_Code__c='98564';
            addrsStatsObj2.Node__c='65421';
            addrsStatsObj2.Currently_Assigned_to_Turf__c = false;
            addrsStatsObj2.Assigned__c = false;
            addrsStatsObj2.Percent_Currently_Assigned__c = 0.0;
            addrsStatsObj2.Num_of_Currently_Assigned__c = 0;
            addrsStatsObj2.Worked__c = false;
            addrsStatsObj2.Percent_Complex_Code__c = 0.0;
            addrsStatsObj2.Region__c = 'Freedom';
            
            //Address_Statistics__c addrsStatsObj2 = new Address_Statistics__c(Name='Node Stats1',Node__c='6542', Region__c='Freedom');
            
            insert addrsStatsObj2;
            
            Address_Statistics__c addrsStatsObj3 = new Address_Statistics__c();
            addrsStatsObj3.Name = 'Node Stats3';
            addrsStatsObj3.Zip_Code__c='98564';
            addrsStatsObj3.Node__c='65422';
            addrsStatsObj3.Currently_Assigned_to_Turf__c = false;
            addrsStatsObj3.Assigned__c = false;
            addrsStatsObj3.Percent_Currently_Assigned__c = 0.0;
            addrsStatsObj3.Num_of_Currently_Assigned__c = 0;
            addrsStatsObj3.Worked__c = false;
            addrsStatsObj3.Percent_Complex_Code__c = 0.0;
            addrsStatsObj3.Region__c = 'Freedom';
            
            //Address_Statistics__c addrsStatsObj2 = new Address_Statistics__c(Name='Node Stats1',Node__c='6542', Region__c='Freedom');
            
            insert addrsStatsObj3;
            
            Address_Statistics__c addrsStatsObj4 = new Address_Statistics__c();
            addrsStatsObj4.Name = 'Node Stats4';
            addrsStatsObj4.Zip_Code__c='98564';
            addrsStatsObj4.Node__c='65423';
            addrsStatsObj4.Currently_Assigned_to_Turf__c = false;
            addrsStatsObj4.Assigned__c = false;
            addrsStatsObj4.Percent_Currently_Assigned__c = 0.0;
            addrsStatsObj4.Num_of_Currently_Assigned__c = 0;
            addrsStatsObj4.Worked__c = false;
            addrsStatsObj4.Percent_Complex_Code__c = 0.0;
            addrsStatsObj4.Region__c = 'Freedom';
            
            //Address_Statistics__c addrsStatsObj2 = new Address_Statistics__c(Name='Node Stats1',Node__c='6542', Region__c='Freedom');
            
            insert addrsStatsObj4;
            
            Address_Statistics__c addrsStatsObj5 = new Address_Statistics__c();
            addrsStatsObj5.Name = 'Node Stats61';
            addrsStatsObj5.Zip_Code__c='98564';
            addrsStatsObj5.Node__c='65423';
            addrsStatsObj5.Currently_Assigned_to_Turf__c = false;
            addrsStatsObj5.Assigned__c = false;
            addrsStatsObj5.Percent_Currently_Assigned__c = 0.0;
            addrsStatsObj5.Num_of_Currently_Assigned__c = 0;
            addrsStatsObj5.Worked__c = false;
            addrsStatsObj5.Percent_Complex_Code__c = 0.0;
            addrsStatsObj5.Region__c = 'Freedom';
            
            //Address_Statistics__c addrsStatsObj2 = new Address_Statistics__c(Name='Node Stats1',Node__c='6542', Region__c='Freedom');
            
            insert addrsStatsObj5;
            
            Address_Statistics__c addrsStatsObj6 = new Address_Statistics__c();
            addrsStatsObj6.Name = 'Node Stats6';
            addrsStatsObj6.Zip_Code__c='98564';
            addrsStatsObj6.Node__c='65423';
            addrsStatsObj6.Currently_Assigned_to_Turf__c = false;
            addrsStatsObj6.Assigned__c = false;
            addrsStatsObj6.Percent_Currently_Assigned__c = 0.0;
            addrsStatsObj6.Num_of_Currently_Assigned__c = 0;
            addrsStatsObj6.Worked__c = false;
            addrsStatsObj6.Percent_Complex_Code__c = 0.0;
            addrsStatsObj6.Region__c = 'Freedom';
            
            //Address_Statistics__c addrsStatsObj2 = new Address_Statistics__c(Name='Node Stats1',Node__c='6542', Region__c='Freedom');
            
            insert addrsStatsObj6;
            
            Address_Statistics__c addrsStatsObj7 = new Address_Statistics__c();
            addrsStatsObj7.Name = 'Node Stats41';
            addrsStatsObj7.Zip_Code__c='98564';
            addrsStatsObj7.Node__c='65423';
            addrsStatsObj7.Currently_Assigned_to_Turf__c = false;
            addrsStatsObj7.Assigned__c = false;
            addrsStatsObj7.Percent_Currently_Assigned__c = 0.0;
            addrsStatsObj7.Num_of_Currently_Assigned__c = 0;
            addrsStatsObj7.Worked__c = false;
            addrsStatsObj7.Percent_Complex_Code__c = 0.0;
            addrsStatsObj7.Region__c = 'Freedom';
            
            //Address_Statistics__c addrsStatsObj2 = new Address_Statistics__c(Name='Node Stats1',Node__c='6542', Region__c='Freedom');
            
            insert addrsStatsObj7;
            
            Address_Statistics__c addrsStatsObj8 = new Address_Statistics__c();
            addrsStatsObj8.Name = 'Node Sta12ts4';
            addrsStatsObj8.Zip_Code__c='98564';
            addrsStatsObj8.Node__c='65423';
            addrsStatsObj8.Currently_Assigned_to_Turf__c = false;
            addrsStatsObj8.Assigned__c = false;
            addrsStatsObj8.Percent_Currently_Assigned__c = 0.0;
            addrsStatsObj8.Num_of_Currently_Assigned__c = 0;
            addrsStatsObj8.Worked__c = false;
            addrsStatsObj8.Percent_Complex_Code__c = 0.0;
            addrsStatsObj8.Region__c = 'Freedom';
            
            //Address_Statistics__c addrsStatsObj2 = new Address_Statistics__c(Name='Node Stats1',Node__c='6542', Region__c='Freedom');
            
            insert addrsStatsObj8;

            
            planObj.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj.Plan_Status__c = 'Draft';
            planObj.Plan_Level__c = 'Turf';
            planObj.Assigned_To_CAR__c=XfinityCARUser.id;
            planObj.Assigned_Team__c = team.id;
            planObj.Address_Nodes_5__c = '6542';
            
            planObj2.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf2';
            planObj2.Plan_Status__c = 'Draft';
            planObj2.Plan_Level__c = 'Turf';
            planObj2.User__c = XfinityCARUser1.Id;
            planObj2.Assigned_To_CAR__c=XfinityCARUser.id;
            planObj2.Address_Nodes_5__c = '6542';
            
            planObj3.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf3';
            planObj3.Plan_Status__c = 'Draft';
            planObj3.Plan_Level__c = 'Turf';
            //planObj3.User__c = XfinityCARUser.Id;
            planObj3.Assigned_Team__c = team.id;
            planObj3.Address_Nodes_5__c = '6542';
            
            planObj4.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj4.Plan_Status__c = 'Draft';
            planObj4.Plan_Level__c = 'Turf';
            planObj4.Assigned_To_CAR__c=XfinityCARUser2.id;
            planObj4.Assigned_Team__c = team.id;
            planObj4.Address_Nodes_5__c = '6542';
            
            planObj5.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj5.Plan_Status__c = 'Draft';
            planObj5.Plan_Level__c = 'Turf';
            planObj5.Assigned_To_CAR__c=XfinityCARUser3.id;
            planObj5.Assigned_Team__c = team.id;
            planObj5.Address_Nodes_5__c = '6542';
            
            planObj6.Name = '6Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj6.Plan_Status__c = 'Draft';
            planObj6.Plan_Level__c = 'Turf';
            planObj6.Assigned_To_CAR__c=XfinityCARUser.id;
            planObj6.Assigned_Team__c = team.id;
            planObj6.Address_Nodes_5__c = '6542';
            
            planObj7.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj7.Plan_Status__c = 'Draft';
            planObj7.Plan_Level__c = 'Turf';
            planObj7.Assigned_To_CAR__c=XfinityCARUser2.id;
            planObj7.Assigned_Team__c = team.id;
            planObj7.Address_Nodes_5__c = '6542';
            
            planObj8.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj8.Plan_Status__c = 'Draft';
            planObj8.Plan_Level__c = 'Turf';
            planObj8.Assigned_To_CAR__c=XfinityCARUser1.id;
            planObj8.Assigned_Team__c = team.id;
            planObj8.Address_Nodes_5__c = '6542';
            
            planObj9.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj9.Plan_Status__c = 'Draft';
            planObj9.Plan_Level__c = 'Turf';
            planObj9.Assigned_To_CAR__c=XfinityCARUser1.id;
            planObj9.Assigned_Team__c = team.id;
            planObj9.Address_Nodes_5__c = '6542';
            
            planObj10.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj10.Plan_Status__c = 'Draft';
            planObj10.Plan_Level__c = 'Turf';
            planObj10.Assigned_To_CAR__c=XfinityCARUser1.id;
            planObj10.Assigned_Team__c = team.id;
            planObj10.Address_Nodes_5__c = '6542';
            
            
           
     /*       insert planObj;
            insert planObj2;
            insert planObj3;
            insert planObj4;
            insert planObj5;
            insert planObj6;
            insert planObj7;
            insert planObj8;
            insert planObj9;
            insert planObj10; */
                        
            plans.add(planObj); 
            plans.add(planObj2);
            plans.add(planObj3);
            plans.add(planObj4);
            plans.add(planObj5);
            plans.add(planObj6);
            plans.add(planObj7);
            plans.add(planObj8);
            plans.add(planObj9);
            plans.add(planObj10);
            insert plans;


            }
            List<Customer_Address__c> addressUpdate=new List<Customer_Address__c>();
            address1.Plan__c = planObj.Id; 
            address1.OwnerId=SetupTestData.DSRUser.Id;
            address1.Division=freedomRegion.Id;
            address2.Plan__c = planObj2.Id;
            address2.OwnerId=SetupTestData.DSRUser.Id;
            address2.Division=freedomRegion.Id;
            address3.Plan__c = planObj3.Id;
            address3.OwnerId=SetupTestData.DSRUser.Id;
            address3.Division=freedomRegion.Id;
            address4.Plan__c = planObj4.Id;
            address4.OwnerId=SetupTestData.DSRUser.Id;
            address4.Division=freedomRegion.Id;
            address5.Plan__c = planObj5.Id;
            address5.OwnerId=SetupTestData.DSRUser.Id;
            address5.Division=freedomRegion.Id;
            address6.Plan__c = planObj6.Id;
            address6.OwnerId=SetupTestData.DSRUser.Id;
            address6.Division=freedomRegion.Id;
            address7.Plan__c = planObj7.Id;
            address7.OwnerId=SetupTestData.DSRUser.Id;
            address7.Division=freedomRegion.Id;
            address8.Plan__c = planObj8.Id;
            address8.OwnerId=SetupTestData.DSRUser.Id;
            address8.Division=freedomRegion.Id;
            address9.Plan__c = planObj9.Id;
            address9.OwnerId=SetupTestData.DSRUser.Id;
            address9.Division=freedomRegion.Id;
            address10.Plan__c = planObj10.Id;
            address10.OwnerId=SetupTestData.DSRUser.Id;
            address10.Division=freedomRegion.Id;
            addressUpdate.add(address1);
            addressUpdate.add(address2);
            addressUpdate.add(address3);
            addressUpdate.add(address4);
            addressUpdate.add(address5);
            addressUpdate.add(address6);
            addressUpdate.add(address7);
            addressUpdate.add(address8);
            addressUpdate.add(address9);
            addressUpdate.add(address10);

            Test.StartTest();
            update addressUpdate;
                    
            /*update planObj;
            update planObj2;
            update planObj3;
            update planObj4;
            update planObj5;
            update planObj6;
            update planObj7;
            update planObj8;
            update planObj9;
            update planObj10;*/
            
            AddressesStatsToPlanCalculationNodeBatch  ascnb= new AddressesStatsToPlanCalculationNodeBatch ();
            ascnb.queryString='Select Id, Num_of_Currently_Assigned__c, Percent_Currently_Assigned__c, Currently_Assigned_to_Turf__c, Assigned__c, Worked__c, Percent_Complex_Code__c, Node__c, Region__c from Address_Statistics__c where Node__c!=null AND Region__c!=null';
            //'Select Id, Num_of_Currently_Assigned__c, Percent_Currently_Assigned__c, Currently_Assigned_to_Turf__c, Assigned__c, Worked__c, Percent_Complex_Code__c, Node__c, //Region__c from Address_Statistics__c WHERE Id=\''+addrsStatsObj1.Id+'\'';
            
            //ascnb.queryString='Select Id, Num_of_Currently_Assigned__c, Percent_Currently_Assigned__c, Currently_Assigned_to_Turf__c, Assigned__c, Worked__c, Percent_Complex_Code__c, Node__c, Region__c from Address_Statistics__c WHERE Id IN (\'+addrsStatsObj1.Id+\',\'+addrsStatsObj2.Id+\')';               
            Database.executeBatch(ascnb,10);
            
            String scheduledJobId;            
            //Scheduling the schdedulable class 
            
            //Database.executeBatch(ascnb);       
            //ScheduleAddressStatsCalculation scheduleAddressStatsCalculationObj = new ScheduleAddressStatsCalculation();
            //scheduledJobId = System.schedule('testScheduledApex', CRON_EXP, scheduleAddressStatsCalculationObj);
            //System.abortJob(scheduledJobId);
            Test.StopTest();     
            //System.assert(scheduledJobId != null);
            //System.abortJob(scheduledJobId);
            }
    }
}