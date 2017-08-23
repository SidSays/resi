/**
* Class Name: DailyDSRLogControllerTest 
* Author: Amitkumar Bangad, Accenture
* Date: 23-May-2013 
* Description: Test Class for DailyDSRLogController 
* Last Modified :
*/
@isTest
public class DailyDSRLogControllerTest {
    private static testMethod void testDailyDSRLogController() { 
        Customer_Address__c cust;
        SetupTestData.createCustomSettingRecords();
        //SetupTestData.createUsers();
        
        User supervisorUser;
        User dsrUser;
        User adminUser;
        Profile p1 = [Select UserType, UserLicenseId, Name From Profile where Name like 'XFINITY Sales Professional'];
        UserRole r1 = [Select Id, Name from UserRole where Name='DSR'];
        Profile p2 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Sales Development Manager'];
        UserRole r2 = [Select Id, Name from UserRole where Name='DS Supervisor'];
        //generate Random String 
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1000)+''; 
        
          supervisorUser = new User(Alias = 'DA_' + randomstr2.substring(0,4),
                                    Email = randomstr2 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p2.Id,
                                    UserRoleId = r2.Id,
                                    PERNR__c = '23344556',
                                    Username = 'userTest' + randomstr2 + '@SampleclassTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId3',
                                    EmployeeNumber = 'Emp' + randomstr2.substring(0,4));
        
         dsrUser = new User(Alias = 'DA_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest@SampleclassTest.com',
                                    LastName='Testing1',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    UserRoleId = r1.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleclassTest.com',
                                    Region__c = 'Freedom Market',
                                    Sales_Rep_Type__c = 'Upgrade',
                                    Device_Phone_Number__c = '111111',
                                    PERNR__c = '11111111',
                                    Sales_ID__c = 'abc1111',
                                    ManagerId = supervisorUser.Id,
                                    FederationIdentifier = 'FedId4',
                                    EmployeeNumber = 'Emp' + randomstr1.substring(0,4)); 
        system.runAs(new User(Id = UserInfo.getUserId())){
            List<User> usersToInsert = new List<User>();
            usersToInsert.add(dsrUser);
            usersToInsert.add(supervisorUser);
            insert usersToInsert;
        
        }
         test.startTest();
        System.runAs(SupervisorUser){
            
            // Create Address Record
            cust = new Customer_Address__c();
            //cust.OwnerId = SetupTestData.DSRUser.Id;
            cust.Address__c = 'Test Address';
            cust.State__c = 'Test State';
            cust.City__c = 'Test City';
            cust.Country__c = 'Test Country';
            cust.PostalCode__c = '12345';
            cust.Region__c = 'Freedom Market';
            cust.Corp__c = '111111';
            cust.Route_code__c = '1111111111';
            cust.Node__c = '1111';
            cust.Latitude__c = 44.9759;
            cust.Longitude__c = -93.1285;
            cust.OwnerId=DSRUser.Id;
            insert cust;
        }
        System.runAs(DSRUser){ 
        
            // Create Knock Records
            Id RecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();  
            Task knock = new Task();
            knock.RecordTypeId = RecTypeId;
            knock.WhatId = cust.Id;
            knock.Disposition__c = 'No Answer';
            knock.Disposition_Latitude__c = 44.9759;
            knock.Disposition_Longitude__c = -93.1085;
            knock.Knocked_Date__c = system.Now();
            knock.status = 'Completed';
            insert knock;
            
            Task knock1 = new Task();
            knock1.RecordTypeId = RecTypeId;
            knock1.WhatId = cust.Id;
            knock1.Disposition__c = 'Door Hanger';
            knock1.Disposition_Latitude__c = 44.9459;
            knock1.Disposition_Longitude__c = -93.1185;
            knock1.Knocked_Date__c = system.Now();
            knock1.status = 'In Progress';
            insert knock1;
        }
            
            // Mimic Location Lat-Long Data of DSR 
            Location__c loc = new Location__c();
            loc.Name = 'Test Location';
            loc.Latitude__c = 44.9759;
            loc.Longitude__c = -93.1085;
            loc.OwnerId=DSRUser.Id;
            loc.Geocode_TimeStamp__c = Datetime.now().format('YYYY-MM-DD-HH:mm:ss');
            
            
            Location__c loc1 = new Location__c();
            loc1.Name = 'Test Location1';
            loc1.Latitude__c = 44.9918;
            loc1.Longitude__c = -93.1669;
            loc1.OwnerId=DSRUser.Id;
            loc1.Geocode_TimeStamp__c = Datetime.now().format('YYYY-MM-DD-HH:mm:ss');
            
            if (Test.isRunningTest()) {
                System.runAs(new User(Id = Userinfo.getUserId())) {
                    insert loc;
                    insert loc1;
                }
            } else{
                insert loc;
                insert loc1;
            }
            
            Date dt1 = system.today();
            Date dt2 = system.today() -20;
           // test.startTest();
            
            // Set Location Log page as Page reference
            PageReference pageRef = Page.DSRLocationLog;
            Test.setCurrentPage(pageRef);
            DailyDSRLogController logCon = new DailyDSRLogController();
            logCon.getRegionValues();
            logCon.initMapLoad();
            
            // Test for error without selecting a view
            logCon.selectedRep = DSRUser.Id;
            logCon.selectedMapType = '0';
            logCon.Go();

            
            // Test for Last Reported DSR Location
            logCon.selectedMapType = '1';
            logCon.Go();
            // Test for Daily DSR Log Without entering Date
            logCon.selectedMapType = '2';
            logCon.Go();
            
            // Test for Daily DSR Log with entering Date
            logCon.selectedMapType = '2';
            logCon.utilObj.Date_Field__c  = dt1;
            logCon.Go();
            
            // Test for Daily Knock & Address disposition
            logCon.selectedMapType = '3';
            logCon.utilObj.Date_Field__c  = dt1;
            logCon.addressMap.put(cust.Id, cust);
            logCon.Go();
            
            // Show Proximity Exceptions
            logCon.bproxExc = true;
            logCon.Go();
            
            // Select Invalid Date
            logCon.utilObj.Date_Field__c  = dt2;
            logCon.Go();
            
            // Search with No DSR Selected
            logCon.utilObj.Date_Field__c  = dt1;
            logCon.selectedRep = null;
            logCon.Go();

            logCon.selectedRep = null;
            logCon.selectedTeam=supervisorUser.Id;
            logCon.selectedMapType = '0';
            logCon.Go();

            // Test for Last Reported DSR Location
            logCon.selectedMapType = '1';
            logCon.Go();
            // Test for Daily DSR Log Without entering Date
            logCon.selectedMapType = '2';
            logCon.Go();
            
            // Test for Daily DSR Log with entering Date
            logCon.selectedMapType = '2';
            logCon.utilObj.Date_Field__c  = dt1;
            logCon.Go();
            
            // Test for Daily Knock & Address disposition
            logCon.selectedMapType = '3';
            logCon.utilObj.Date_Field__c  = dt1;
            logCon.addressMap.put(cust.Id, cust);
            logCon.Go();
            
            // Change Region
            //logCon.changeRegions();
            test.stopTest();          
       // }
    }
}