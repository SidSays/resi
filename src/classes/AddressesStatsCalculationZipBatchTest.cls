@isTest
public class AddressesStatsCalculationZipBatchTest
{    

    public static testMethod void testAddressStatsCalculationBatch()
    {   
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        Customer_Address__c address1 = new Customer_Address__c();
        Customer_Address__c address2 = new Customer_Address__c();
        // Creating Customer Address records.
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        System.runAs(new User(Id = UserInfo.getUserId())){
            
            SetupTestData.createCustomSettingRecords();
            SetupTestData.createUsers();
            
           
            
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
            insert address1;            
            
            
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
            insert address2;
        }   
            Plan__c planObj = new Plan__c();
            
        //Creating a Plan
        System.runAs(SetupTestData.supervisorUser)
        {
            planObj.Name = 'Test Turf Plan';
            planObj.Plan_Status__c = 'Draft';
            planObj.Plan_Level__c = 'Turf';
            insert planObj;
        }
        
        Address_Statistics__c addrsStatsObj1 = new Address_Statistics__c();
        Address_Statistics__c addrsStatsObj2 = new Address_Statistics__c();
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            List<Customer_Address__c> addressUpdate=new List<Customer_Address__c>();
            address1.Plan__c = planObj.Id; 
            address1.OwnerId=SetupTestData.DSRUser.Id;
            address1.Division=freedomRegion.Id;
            address2.Plan__c = planObj.Id; 
            address2.OwnerId=SetupTestData.DSRUser.Id;
            address2.Division=freedomRegion.Id;
            addressUpdate.add(address1);
            addressUpdate.add(address2);
            update addressUpdate;
            
             //Creating Address statistics records.            
            addrsStatsObj1.Name = 'Zip Code Stats1';
            addrsStatsObj1.Zip_Code__c='98564';
            addrsStatsObj1.Currently_Assigned_to_Turf__c = false;
            addrsStatsObj1.Assigned__c = false;
            addrsStatsObj1.Percent_Currently_Assigned__c = null;
            addrsStatsObj1.Num_of_Currently_Assigned__c = null;
            addrsStatsObj1.Region__c='Freedom Market';
            
            addrsStatsObj2 = new Address_Statistics__c(Name='Node Stats1',Node__c='6542', Region__c='Freedom Market');
            
            insert addrsStatsObj1;
            insert addrsStatsObj2;
        } 
        
        System.runAs(SetupTestData.supervisorUser)
        {
            planObj.User__c=SetupTestData.DSRUser.Id;
            planObj.Plan_Status__c='Assigned';
            planObj.Expiration_Date__c=System.Date.today();
            //update planObj;
        }    
           
            
            
            
        Test.StartTest();                
            //AddressesStatsCalculationZipBatch asczb= new AddressesStatsCalculationZipBatch();
            //asczb.queryString='Select Id, Num_of_Currently_Assigned__c, Percent_Currently_Assigned__c, Currently_Assigned_to_Turf__c, Assigned__c, Percent_Complex_Code__c, Zip_Code__c, Region__c from Address_Statistics__c WHERE Id=\''+addrsStatsObj1.Id+'\'';               
            //Database.executeBatch(asczb,1);
        //Test.StopTest();      
            
            String scheduledJobId;            
            //Scheduling the schdedulable class 
            //Test.StartTest();        
            ScheduleAddressStatsCalculation scheduleAddressStatsCalculationObj = new ScheduleAddressStatsCalculation();
            scheduledJobId = System.schedule('testScheduledApex', CRON_EXP, scheduleAddressStatsCalculationObj);
        Test.StopTest();     
            System.assert(scheduledJobId != null);
            
    }
        
}