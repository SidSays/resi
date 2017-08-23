@isTest
public class AddressesStatstoPlanCalZipBatchTest
{    

    public static testMethod void testAddressStatsCalculationBatch()
        {
            //User carUser;
            //carUser = TestDataUtility.createXfinityCARUser();
            System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            //System.runAs (carUser) {    
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            SetupTestData.createCustomSettingRecords();
            SetupTestData.createUsers();
            VariableSettingTestUtility.variableSettingsData(); 
            
             List<User> userList = new List<User>();
             Profile p =  [Select Id, Name From Profile where Name = 'Xfinity CAR' limit 1];
             String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
             String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1050)+'';
             String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1250)+'';
             User XfinityCARUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    LastName='Testing1',
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
                                    LastName='Testing1',
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
            insert addressList;
            
            List<Plan__c> plans = new List<Plan__c>();
            
            Plan__c planObj = new Plan__c();
            Plan__c planObj1 = new Plan__c();
            Plan__c planObj2 = new Plan__c();
            Plan__c planObj3 = new Plan__c();
            Plan__c planObj4 = new Plan__c();
            Plan__c planObj5 = new Plan__c();
  
            
            
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
            
            planObj.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj.Plan_Status__c = 'Draft';
            planObj.Plan_Level__c = 'Turf';
            planObj.Assigned_To_CAR__c=XfinityCARUser.id;
            planObj.Assigned_Team__c = team.id;
            planObj.Address_Zip_Codes__c='98564';
            
            planObj1.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj1.Plan_Status__c = 'Draft';
            planObj1.Plan_Level__c = 'Turf';
            planObj1.User__c = XfinityCARUser1.Id;
            planObj1.Assigned_To_CAR__c=XfinityCARUser.id;
            planObj1.Address_Zip_Codes__c='98564';
            
            planObj2.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj2.Plan_Status__c = 'Draft';
            planObj2.Plan_Level__c = 'Turf';
            planObj2.Assigned_Team__c = team.id;
            planObj2.Address_Zip_Codes__c='98564';
            
            planObj3.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj3.Plan_Status__c = 'Draft';
            planObj3.Plan_Level__c = 'Turf';
            planObj3.User__c = XfinityCARUser.Id;
            planObj3.Address_Zip_Codes__c='98564';
            
            planObj4.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj4.Plan_Status__c = 'Draft';
            planObj4.Plan_Level__c = 'Turf';
           // planObj4.User__c = XfinityCARUser1.Id;
            planObj4.Address_Zip_Codes__c='98564';
            
            planObj5.Name = 'Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf PlanPP Test Turf1';
            planObj5.Plan_Status__c = 'Draft';
            planObj5.Plan_Level__c = 'Turf';
            planObj5.User__c = XfinityCARUser2.Id;
            planObj1.Assigned_To_CAR__c=XfinityCARUser1.id;
            planObj5.Address_Zip_Codes__c='98564';

    
            
            plans.add(planObj); 
            plans.add(planObj1);
            plans.add(planObj2);
            plans.add(planObj3);
            plans.add(planObj4);
            plans.add(planObj5);
            insert plans;

           
           
           /* insert planObj;
            insert planObj1;
            insert planObj2;
            insert planObj4;
            insert planObj3; */
            
            //Creating Address statistics records.
            Address_Statistics__c addrsStatsObj1 = new Address_Statistics__c();
            addrsStatsObj1.Name = 'Zip Code Stats1';
            addrsStatsObj1.Zip_Code__c='98564';
            addrsStatsObj1.Currently_Assigned_to_Turf__c = false;
            addrsStatsObj1.Assigned__c = false;
            addrsStatsObj1.Percent_Currently_Assigned__c = null;
            addrsStatsObj1.Num_of_Currently_Assigned__c = null;
            addrsStatsObj1.Region__c='Freedom';
            

            
            
           // Address_Statistics__c addrsStatsObj2 = new Address_Statistics__c(Name='Node Stats1',Node__c='6542', Region__c='Freedom Market');
            
            insert addrsStatsObj1;

            }
    
            List<Customer_Address__c> addressUpdate=new List<Customer_Address__c>();
            address1.Plan__c = planObj.Id; 
            address1.OwnerId=SetupTestData.DSRUser.Id;
            address1.Division=freedomRegion.Id;
            address2.Plan__c = planObj1.Id; 
            address2.OwnerId=SetupTestData.DSRUser.Id;
            address2.Division=freedomRegion.Id;
            address3.Plan__c = planObj2.Id; 
            address3.OwnerId=SetupTestData.DSRUser.Id;
            address3.Division=freedomRegion.Id;
            address4.Plan__c = planObj3.Id; 
            address4.OwnerId=SetupTestData.DSRUser.Id;
            address4.Division=freedomRegion.Id;
            addressUpdate.add(address1);
            addressUpdate.add(address2);
            addressUpdate.add(address3);
            addressUpdate.add(address4);
            Test.StartTest();        
            update addressUpdate;
         /*   update planObj;
            update planObj1;
            update planObj2;*/
            
   
           // insert addrsStatsObj2;
            
            
            AddressesStatstoPlanCalculationZipBatch asczb= new AddressesStatstoPlanCalculationZipBatch();
            asczb.queryString='Select Id, Num_of_Currently_Assigned__c, Percent_Currently_Unassigned__c , Num_of_Currently_Unassigned__c , Knocked__c, Worked__c, Percent_Currently_Assigned__c, Latitude__c, Longitude__c, Colour__c, Currently_Assigned_to_Turf__c, Assigned__c, Assigned_in_last__c, Knocked_in_last__c, Percent_Complex_Code__c, Zip_Code__c, Region__c from Address_Statistics__c where Zip_Code__c!=\'\'';                
            Database.executeBatch(asczb,10);
            
            String scheduledJobId;            
            //Scheduling the schdedulable class 
            //Test.StartTest();        
            ScheduleAddressStatsCalculation scheduleAddressStatsCalculationObj = new ScheduleAddressStatsCalculation();
            scheduledJobId = System.schedule('testScheduledApex', CRON_EXP, scheduleAddressStatsCalculationObj);
            Test.StopTest();     
            System.assert(scheduledJobId != null);
            }
        }
        
        
}