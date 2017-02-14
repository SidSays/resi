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
        SetupTestData.createUsers();
         test.startTest();
        System.runAs(SetupTestData.SupervisorUser){
            
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
            cust.OwnerId=SetupTestData.DSRUser.Id;
            insert cust;
        }
        System.runAs(SetupTestData.DSRUser){ 
        
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
            loc.OwnerId=SetupTestData.DSRUser.Id;
            loc.Geocode_TimeStamp__c = Datetime.now().format('YYYY-MM-DD-HH:mm:ss');
            
            
            Location__c loc1 = new Location__c();
            loc1.Name = 'Test Location1';
            loc1.Latitude__c = 44.9918;
            loc1.Longitude__c = -93.1669;
            loc1.OwnerId=SetupTestData.DSRUser.Id;
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
            logCon.selectedRep = SetupTestData.DSRUser.Id;
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
            logCon.selectedTeam=SetupTestData.supervisorUser.Id;
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
            logCon.changeRegions();
            test.stopTest();          
       // }
    }
}