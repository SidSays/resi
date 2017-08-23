@isTest
public class ReportingMetricBatchTestNew {
     public static String CRON_EXP = '0 0 0 3 9 ? 2022';
     //public static Map < String, Map < String, List < Task >>> regionWithTypeAndKnocks;
     public static Map < String, Map < String, Reporting_Metric__c >> regionAndReportingMetric;
     public static Map < String, Map < String, Map < Id, Map < Integer, Set < String >>> >> userAndHoursWorked;
     public static Map < String, Map < String, Set < Id >>> regionWithProductiveUserCount;
     public static Map < String, Map < String, Set < Id >>> regionWithProductiveStartUserCount;
     

     public static testMethod void testReportingMetricBatch(){
        WorkTestDataUtility.createCustomSettingRecords();
        User currentUser = [select id from user where  id=:userinfo.getuserid()];
        User repUser = WorkTestDataUtility.createDSRepUser();
        repUser.Sales_Rep_Type__c = 'Winback';
        update repUser;
        string knockRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();  
        string metricRecordTypeId = Schema.SObjectType.Reporting_Metric__c.getRecordTypeInfosByName().get(Label.RM_Week_Rec_Type).getRecordTypeId();            
       
        
 
        Account acc;
       // Create Account
        acc = new Account();
        acc.Name = 'Test Account';
        acc.Customer_Status__c = 'Active';
        insert acc;
            
            // Create Addresses
       List<Customer_Address__c> custList = new List<Customer_Address__c>();
        Customer_Address__c addr;
       for(Integer i =0; i<=9; i++){
        addr = new Customer_Address__c();
        addr.Address__c = 'Test Address';
        addr.State__c = 'Test State';
        addr.City__c = 'Test City';
        addr.Country__c = 'Test Country';
        addr.PostalCode__c = '12345';
        addr.Node__c = '1111';
        addr.Corp__c = '11111111';
        addr.Route_Code__c = '1111111111';
        addr.Region__c = 'Freedom Market';
        addr.Latitude__c=41.405556;
        addr.Longitude__c=-81.664167;
        custList.add(addr);
            }
            custList[0].Dwelling_Type__c = 'Single Family';
            custList[1].Dwelling_Type__c = 'Bulk Billed Master';
            custList[2].Dwelling_Type__c = 'Bulk Billed MDU';
            custList[3].Dwelling_Type__c = 'Non Bulk Billed MDU';
            custList[4].Dwelling_Type__c = 'Single Family Unit';
            custList[5].Dwelling_Type__c = 'Multiple Dwelling Unit';
            custList[6].Dwelling_Type__c = 'Non Bulk Billed'; 
            custList[7].Dwelling_Type__c = 'OTHER'; 
            custList[8].Dwelling_Type__c = 'MDU';
            custList[9].Dwelling_Type__c = 'SFU';
        Database.insert(custList,false);
        
        List<Task> knockList = new List<Task>();
        
  
        Task knock; 
   for(Integer i =0; i<=9; i++){
         knock = new Task(); 
        knock.RecordTypeId = knockRecordTypeId;
        knock.WhatId = custList[i].Id;         
        knock.Event_Category__c = 'Fair';
        knock.Knocked_Date__c = system.Now();
        knock.OwnerId= repUser.Id;
        knock.status = 'Completed';
        knock.Disposition__c ='Start';
        knock.Sales_Type__c ='Winback';
        knock.Off_Turf__c= false;
        knock.Region__c = 'Beltway Market';
        knock.DSR_Type__c = 'Winback';
        knock.Disposition_Latitude__c= 78.00;
        knock.Disposition_Longitude__c = 58.00;
        knockList.add(knock);
    }
        
       
        
         knockList[0].Dwelling_Type__c = 'Single Family';
         knockList[1].Dwelling_Type__c = 'Bulk Billed Master';
         knockList[2].Dwelling_Type__c = 'Bulk Billed MDU';
         knockList[3].Dwelling_Type__c = 'Non Bulk Billed MDU';
         knockList[4].Dwelling_Type__c = 'Single Family Unit';
         knockList[5].Dwelling_Type__c = 'Multiple Dwelling Unit';
         knockList[6].Dwelling_Type__c = 'Non Bulk Billed'; 
         knockList[7].Dwelling_Type__c = 'OTHER';
         knockList[8].Dwelling_Type__c = 'MDU';
         knockList[9].Dwelling_Type__c = 'SFU';
       
        
                
        database.insert(knockList,false);
        
      
            // Reporting metric data
            
            Reporting_Metric__c rmObj = new Reporting_Metric__c();
            rmObj.Name = 'Test Reporting mertric';
            rmObj.Region__c = Label.DivisionGlobal;
            rmObj.DSR_Type__c = Label.DSRType_All;
            rmObj.RecordTypeId = metricRecordTypeId;
            rmObj.Of_Knocks__c = 0;
            rmObj.Of_Contacts__c = 0;
            rmObj.Of_Knocks_SFU__c = 0;
            rmObj.Of_Knocks_MDU__c = 0;
            rmObj.Of_Starts__c = 0;
            rmObj.Of_Starts_SFU__c = 0;
            rmObj.Of_Starts_MDU__c = 0;
            rmObj.Of_Winback_Starts__c = 0;
            rmObj.Of_On_Turf_Starts__c = 0;
            rmObj.Of_Knocks_with_GPS__c = 0;
            rmObj.Of_Dispositions_4_through_9pm__c = 0;
            rmObj.Of_Days__c = 0;
            rmObj.Of_Hours__c = 0;
            rmObj.Of_Productive_Users_In_Region__c = 0;
            rmObj.Of_Productive_Users_With_Start__c = 0;
            rmObj.Of_Active_Users_In_Region__c = 0;
            rmObj.Created_Date__c = System.today();
            Database.insert(rmObj,false);
            
                  
             
            String queryString;
            queryString = 'SELECT Id, Disposition__c, Region__c, Knocked_Date__c, DSR_Type__c, Dwelling_Type__c, Sales_Type__c, Off_Turf__c, Disposition_Latitude__c, Disposition_Longitude__c, Hour_of_Day__c, OwnerId  FROM Task WHERE RecordTypeId=\'' + knockRecordTypeId + '\' AND Region__c != \'Global\' LIMIT 1';
            queryString += ' AND Knocked_Date__c >= LAST_WEEK AND Knocked_Date__c != THIS_WEEK';

            ReportingMetricBatch b = new ReportingMetricBatch(queryString);
            dataBase.executeBatch(b);
            
            String queryStringMonthly;
            queryStringMonthly = 'SELECT Id, Disposition__c, Region__c, Knocked_Date__c, DSR_Type__c, Dwelling_Type__c, Sales_Type__c, Off_Turf__c, Disposition_Latitude__c, Disposition_Longitude__c, Hour_of_Day__c, OwnerId  FROM Task WHERE RecordTypeId=\'' + knockRecordTypeId + '\' AND Region__c != \'Global\' LIMIT 1';
            queryStringMonthly += ' AND Knocked_Date__c >= LAST_MONTH AND Knocked_Date__c != THIS_MONTH';
            
            ReportingMetricBatch bm = new ReportingMetricBatch(queryStringMonthly);
            dataBase.executeBatch(bm);
            
            Test.startTest();
            ScheduleWeeklyReportBatch ScheduleWeeklyReportBatchObj = new ScheduleWeeklyReportBatch();
            String scheduledJobId = System.schedule('testScheduledApex', CRON_EXP, ScheduleWeeklyReportBatchObj);
            ScheduleMonthlyReportBatch ScheduleMonthlyReportBatchObj = new ScheduleMonthlyReportBatch();
            String scheduledJobId1 = System.schedule('testScheduledApex1', CRON_EXP, ScheduleMonthlyReportBatchObj);
            Test.stopTest();           
            
            
     }
     
     
    }