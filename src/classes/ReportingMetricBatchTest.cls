/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 5-July-2013
 * Description: This is Test class for "ReportingMetricBatch", "ReportingMetricDailyBatch", "ScheduleWeeklyReportBatch",
                "ScheduleMonthlyReportBatch", " ScheduleDailyReportBatch" class.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class ReportingMetricBatchTest {
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    public static string sch = '0 0 8 L * ?';
    public static string schdaily = '0 0 13 * * ?';
    public static testMethod void testReportingMetricBatch(){
    try{
        User sharedData = [Select Id, Name from User where Name='Shared Data User'];
            SetupTestData.createCustomSettingRecords();
            SetupTestData.createUsers();
            Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
            Id RecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId(); 
            List<Task> knockList = new List<Task>();
            List<Customer_Address__c> custList = new List<Customer_Address__c>();
            Customer_Address__c addr;
            Account acc;
            Plan__c pln;

            // Create Account
            acc = new Account();
            acc.Name = 'Test Account';
            acc.Customer_Status__c = 'Active';
            System.runAs(new User(Id = Userinfo.getUserId())) {
            
            insert acc;
      }


            
            // Create Addresses
            for(Integer i =0; i<=6; i++){
            addr = new Customer_Address__c();
            addr.Account__c  = acc.Id;
            addr.Address__c = 'Test Address' +i;
            addr.State__c = 'Test State' +i;
            addr.City__c = 'Test City' +i;
            addr.Country__c = 'Test Country';
            addr.Node__c = '1111';
            addr.Corp__c = '11111111';
            addr.Route_Code__c = '1111111111';
            addr.PostalCode__c = '12345';
            addr.OwnerId=sharedData.Id;
            addr.Division=freedomRegion.Id;
//            addr.Status__c = 'Active';            
            addr.Region__c = 'Freedom Market';
            custList.add(addr);
            }
            custList[0].Dwelling_Type__c = 'Single Family';
            custList[1].Dwelling_Type__c = 'Bulk Billed Master';
            custList[2].Dwelling_Type__c = 'Bulk Billed MDU';
            custList[3].Dwelling_Type__c = 'Non Bulk Billed MDU';
            custList[4].Dwelling_Type__c = 'Single Family Unit';
            custList[5].Dwelling_Type__c = 'Multiple Dwelling Unit';
            custList[6].Dwelling_Type__c = 'Non Bulk Billed';
            System.runAs(new User(Id = Userinfo.getUserId())) {
        insert custList;
      }
        
        //System.runAs(SetupTestData.supervisorUser){
            // Create Plans
            pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';   
            pln.Expiration_Date__c = system.Today() + 30;
            Test.StartTest(); 
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.quickSave();
            extnObj1.selectedTemplate.Customer_Status__c = 'Active';
            extnObj1.searchAddressses();
            extnObj1.nextSetOfRecords();
            extnObj1.previousSetOfRecords();           
            extnObj1.addAll();    
            
            // Assign Plan
            pln.User__c = SetupTestData.dsrUser.Id;
            extnObj1.Save();

            for(Customer_Address__c add:custList){
                add.Plan__c=pln.Id;
            }

           System.runAs(new User(Id = Userinfo.getUserId())) {
        update custList;
      }
        
            Task knock;
            // Create Knocks
            for(Integer i=0; i<10; i++ ) {
            Knock = new Task();
            knock.RecordTypeId = RecTypeId;
            knock.Region__c='Freedom Market';
            //knock.Knocked_Date__c = system.Today()-i;
            knock.Plan_Id__c = pln.Id;
            knock.status = 'Completed';
            knockList.add(knock);
            }
           
            knockList[0].WhatId = custList[0].Id;
            knockList[0].Disposition__c = 'Contact';
            knockList[0].Knocked_Date__c = system.Today();
            knockList[0].Video_Active__c = true;
            knockList[0].HSI_Active__c = true;
            knockList[0].Voice_Active__c = true;
            knockList[0].XH_Active__c = true;
            
            knockList[1].WhatId = custList[1].Id;
            knockList[1].Knocked_Date__c = system.Today()-1;
            knockList[1].Disposition__c = 'Start';
            knockList[1].Sales_Type__c = 'Winback';
            
            knockList[2].WhatId = custList[1].Id;
            knockList[2].Knocked_Date__c = system.Today();
            knockList[2].Disposition__c = 'Start';
            knockList[2].Sales_Type__c = 'Winback';
            
            knockList[3].WhatId = custList[2].Id;
            knockList[3].Disposition__c = 'Door Hanger';
            knockList[3].Knocked_Date__c = system.Today()-3;
            KnockList[3].Disposition_Latitude__c = 123.14;
            KnockList[3].Disposition_Longitude__c = 254.25;
            knockList[3].Off_Turf__c = true;
            
            knockList[4].WhatId = custList[2].Id;
            knockList[4].Knocked_Date__c = system.Today()-4;
            knockList[4].Disposition__c = 'Start';
            knockList[4].Sales_Type__c = 'Upgrade';
            knockList[4].Video_Active__c = true;
            knockList[4].HSI_Active__c = true;
            knockList[4].Voice_Active__c = true;
            knockList[4].XH_Active__c = true;
            
            knockList[5].WhatId = custList[3].Id;
            knockList[5].Knocked_Date__c = system.Today()-5;
            knockList[5].Disposition__c = 'Start';
            knockList[5].Sales_Type__c = 'Upgrade';
            
            knockList[6].WhatId = custList[4].Id;
            knockList[6].Knocked_Date__c = system.Today()-6;
            knockList[6].Disposition__c = 'Start';
            knockList[6].Sales_Type__c = 'Winback';
            
            knockList[7].WhatId = custList[5].Id;
            knockList[7].Knocked_Date__c = system.Today();
            knockList[7].Disposition__c = 'Start';
            knockList[7].Sales_Type__c = 'Winback';
            knockList[7].Off_Turf__c = false;
            
            system.debug('>>>>>>knockList'+knockList);
            System.runAs(new User(Id = Userinfo.getUserId())) {
        insert knockList;
      }
            for(Task kn: knockList){
                system.debug('>>>>>>>>'+kn.Region__c);
            }
       //}    
            // Test the Batches
            System.runAs(SetupTestData.businessAdminUser){ 
                
                ScheduleWeeklyReportBatch ScheduleWeeklyReportBatchObj = new ScheduleWeeklyReportBatch();
                String scheduledJobId = System.schedule('testScheduledApex', CRON_EXP, ScheduleWeeklyReportBatchObj);
                Test.stopTest();
            }
       }
       catch(Exception ex){
           system.debug('---------' +ex);
       }
    }
    
    public static testMethod void testReportingMetricBatch1(){
    try{
        User sharedData = [Select Id, Name from User where Name='Shared Data User'];
            SetupTestData.createCustomSettingRecords();
            SetupTestData.createUsers();
            Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
            Id RecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId(); 
            List<Task> knockList = new List<Task>();
            List<Customer_Address__c> custList = new List<Customer_Address__c>();
            Customer_Address__c addr;
            Account acc;
            Plan__c pln;

            // Create Account
            acc = new Account();
            acc.Name = 'Test Account';
            acc.Customer_Status__c = 'Active';
            System.runAs(new User(Id = Userinfo.getUserId())) {
        insert acc;
      }


            
            // Create Addresses
            for(Integer i =0; i<=6; i++){
            addr = new Customer_Address__c();
            addr.Account__c  = acc.Id;
            addr.Address__c = 'Test Address' +i;
            addr.State__c = 'Test State' +i;
            addr.City__c = 'Test City' +i;
            addr.Country__c = 'Test Country';
            addr.Node__c = '1111';
            addr.Corp__c = '11111111';
            addr.Route_Code__c = '1111111111';
            addr.PostalCode__c = '12345';
            addr.OwnerId=sharedData.Id;
            addr.Division=freedomRegion.Id;
//            addr.Status__c = 'Active';            
            addr.Region__c = 'Freedom Market';
            custList.add(addr);
            }
            custList[0].Dwelling_Type__c = 'Single Family';
            custList[1].Dwelling_Type__c = 'Bulk Billed Master';
            custList[2].Dwelling_Type__c = 'Bulk Billed MDU';
            custList[3].Dwelling_Type__c = 'Non Bulk Billed MDU';
            custList[4].Dwelling_Type__c = 'Single Family Unit';
            custList[5].Dwelling_Type__c = 'Multiple Dwelling Unit';
            custList[6].Dwelling_Type__c = 'Non Bulk Billed';
            System.runAs(new User(Id = Userinfo.getUserId())) {
        insert custList;
      }
        
        //System.runAs(SetupTestData.supervisorUser){
            // Create Plans
            pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';   
            pln.Expiration_Date__c = system.Today() + 30;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            Test.StartTest(); 
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.quickSave();
            extnObj1.selectedTemplate.Customer_Status__c = 'Active';
            extnObj1.searchAddressses();
            extnObj1.nextSetOfRecords();
            extnObj1.previousSetOfRecords();           
            extnObj1.addAll();    
            
            // Assign Plan
            pln.User__c = SetupTestData.dsrUser.Id;
            extnObj1.Save();

            for(Customer_Address__c add:custList){
                add.Plan__c=pln.Id;
            }

           System.runAs(new User(Id = Userinfo.getUserId())) {
        update custList;
      }
        
            Task knock;
            // Create Knocks
            for(Integer i=0; i<10; i++ ) {
            Knock = new Task();
            knock.RecordTypeId = RecTypeId;
            knock.Region__c='Freedom Market';
            //knock.Knocked_Date__c = system.Today()-i;
            knock.Plan_Id__c = pln.Id;
            knock.status = 'Completed';
            knockList.add(knock);
            }
           
            knockList[0].WhatId = custList[0].Id;
            knockList[0].Disposition__c = 'Contact';
            knockList[0].Knocked_Date__c = system.Today()+15;
            knockList[0].Video_Active__c = true;
            knockList[0].HSI_Active__c = true;
            knockList[0].Voice_Active__c = true;
            knockList[0].XH_Active__c = true;
            
            knockList[1].WhatId = custList[1].Id;
            knockList[1].Knocked_Date__c = system.Today()-1;
            knockList[1].Disposition__c = 'Start';
            knockList[1].Sales_Type__c = 'Winback';
            
            knockList[2].WhatId = custList[1].Id;
            knockList[2].Knocked_Date__c = system.Today();
            knockList[2].Disposition__c = 'Start';
            knockList[2].Sales_Type__c = 'Winback';
            
            knockList[3].WhatId = custList[2].Id;
            knockList[3].Disposition__c = 'Door Hanger';
            knockList[3].Knocked_Date__c = system.Today()-3;
            KnockList[3].Disposition_Latitude__c = 123.14;
            KnockList[3].Disposition_Longitude__c = 254.25;
            knockList[3].Off_Turf__c = true;
            
            knockList[4].WhatId = custList[2].Id;
            knockList[4].Knocked_Date__c = system.Today()-4;
            knockList[4].Disposition__c = 'Start';
            knockList[4].Sales_Type__c = 'Upgrade';
            knockList[4].Video_Active__c = true;
            knockList[4].HSI_Active__c = true;
            knockList[4].Voice_Active__c = true;
            knockList[4].XH_Active__c = true;
            
            knockList[5].WhatId = custList[3].Id;
            knockList[5].Knocked_Date__c = system.Today()-5;
            knockList[5].Disposition__c = 'Start';
            knockList[5].Sales_Type__c = 'Upgrade';
            
            knockList[6].WhatId = custList[4].Id;
            knockList[6].Knocked_Date__c = system.Today()-6;
            knockList[6].Disposition__c = 'Start';
            knockList[6].Sales_Type__c = 'Winback';
            
            knockList[7].WhatId = custList[5].Id;
            knockList[7].Knocked_Date__c = system.Today();
            knockList[7].Disposition__c = 'Start';
            knockList[7].Sales_Type__c = 'Winback';
            knockList[7].Off_Turf__c = false;
            
            system.debug('>>>>>>knockList'+knockList);
            System.runAs(new User(Id = Userinfo.getUserId())) {
        insert knockList;
      }
            for(Task kn: knockList){
                system.debug('>>>>>>>>'+kn.Region__c);
            }
       //}    
            // Test the Batches
            System.runAs(SetupTestData.businessAdminUser){ 
                
                ScheduleMonthlyReportBatch ScheduleMonthlyReportBatchObj = new ScheduleMonthlyReportBatch();
                String scheduledJobId = System.schedule('testScheduledApex1', sch, ScheduleMonthlyReportBatchObj);
                Test.stopTest();
            }
    }
    catch(Exception ex){
           system.debug('---------' +ex);
       }
    }
    
    
    
    
}