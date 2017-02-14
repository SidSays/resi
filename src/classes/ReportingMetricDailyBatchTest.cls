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
public class ReportingMetricDailyBatchTest {
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    public static testMethod void testReportingMetricBatch(){
    WorkTestDataUtility.createCustomSettingRecords();
     String randomstr4 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
      Profile profile = [Select UserType, UserLicenseId, Name From Profile where Name like 'Business Administrator'];
        User businessAdminUser;
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
            
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = True;
            triggerSettingsList.add(userTrigger);
      businessAdminUser = new User(Alias = 'DA_' + randomstr4.substring(0,4),
                                    Email = randomstr4 + 'userTest@SampleclassTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = profile.Id,
                                    //UserRoleId = r4.Id,
                                    Username = 'userTest' + randomstr4 + '@SampleclassTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1',
                                    EmployeeNumber = 'Emp' + randomstr4.substring(0,4));
        insert businessAdminUser;
   
    User DSSupUser = WorkTestDataUtility.createDSSupervisorUser();
    User DSRepUser = WorkTestDataUtility.createDSRepUser();
             User sharedData = [Select Id, Name from User where Name='Shared Data User'];
            //SetupTestData.createCustomSettingRecords();
            //SetupTestData.createUsers();
            Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
            Id RecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId(); 
            List<Task> knockList = new List<Task>();
            List<Customer_Address__c> custList = new List<Customer_Address__c>();
            Customer_Address__c addr;
            Account acc;
            Plan__c pln;

         //   User currentUser=[Select Region__c From User Where Id=:UserInfo.getUserId()];

            System.runAs(sharedData){
                // Create Account
                acc = new Account();
                acc.Name = 'Test Account';
                acc.Customer_Status__c = 'Active';
                insert acc;
                
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
                insert custList;

            }
            
           System.runAs(DSSupUser){
                // Create Plans
                pln = new Plan__c();
                pln.Name = 'TestPlan';
                pln.Plan_Level__c = 'Turf';   
                pln.Expiration_Date__c = system.Today() + 30;
               
                pln.OwnerId=DSSupUser.Id;
                ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
                PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
                extnObj1.quickSave();
                ApexPages.currentPage().getParameters().put('NodeOrZip', custList.get(0).Node__c);
                extnObj1.searchAddressses();
                extnObj1.nextSetOfRecords();
                extnObj1.previousSetOfRecords();           
                extnObj1.addAll();    
                
                // Assign Plan
                pln.User__c = DSSupUser.Id;
                pln.Plan_Status__c='Active';
                extnObj1.Save();
}
                for(Customer_Address__c add:custList){
                    add.Plan__c=pln.Id;
                     System.runAs(DSRepUser){

                                        add.OwnerId=DSRepUser.Id;}
                }

                update custList;
            
            System.runAs(DSRepUser){
                Task knock;
                // Create Knocks
                for(Integer i=0; i<10; i++ ) {
                Knock = new Task();
                knock.RecordTypeId = RecTypeId;
                knock.Region__c='Freedom Market';
                knock.Knocked_Date__c = system.Today();
                knock.Plan_Id__c = pln.Id;
                knock.status = 'Completed';
                knock.OwnerId=DSRepUser.Id;
                knockList.add(knock);
                }
                
                knockList[0].WhatId = custList[0].Id;
                knockList[0].Disposition__c = 'Contact';
                knockList[0].Video_Active__c = true;
                knockList[0].HSI_Active__c = true;
                knockList[0].Voice_Active__c = true;
                knockList[0].XH_Active__c = true;
                
                knockList[1].WhatId = custList[1].Id;
                knockList[1].Disposition__c = 'Start';
                knockList[1].Sales_Type__c = 'Winback';
                
                knockList[2].WhatId = custList[1].Id;
                knockList[2].Disposition__c = 'Start';
                knockList[2].Sales_Type__c = 'Winback';
                
                knockList[3].WhatId = custList[2].Id;
                knockList[3].Disposition__c = 'Door Hanger';
                KnockList[3].Disposition_Latitude__c = 123.14;
                KnockList[3].Disposition_Longitude__c = 254.25;
                knockList[3].Off_Turf__c = true;
                
                knockList[4].WhatId = custList[2].Id;
                knockList[4].Disposition__c = 'Start';
                knockList[4].Sales_Type__c = 'Upgrade';
                knockList[4].Video_Active__c = true;
                knockList[4].HSI_Active__c = true;
                knockList[4].Voice_Active__c = true;
                knockList[4].XH_Active__c = true;
                
                knockList[5].WhatId = custList[3].Id;
                knockList[5].Disposition__c = 'Start';
                knockList[5].Sales_Type__c = 'Upgrade';
                
                knockList[6].WhatId = custList[4].Id;
                knockList[6].Disposition__c = 'Start';
                knockList[6].Sales_Type__c = 'Winback';
                
                knockList[7].WhatId = custList[5].Id;
                knockList[7].Disposition__c = 'Start';
                knockList[7].Sales_Type__c = 'Winback';
                knockList[7].Off_Turf__c = false;

                knockList[8].WhatId = custList[5].Id;
                knockList[8].Disposition__c = 'Close';
                knockList[8].Off_Turf__c = false;

                knockList[9].WhatId = custList[5].Id;
                knockList[9].Disposition__c = 'Start';
                knockList[9].Sales_Type__c = 'Winback';
                knockList[9].Off_Turf__c = false;
                knockList[9].Video_Active__c = true;
                knockList[9].HSI_Active__c = true;
                knockList[9].Voice_Active__c = true;
                knockList[9].XH_Active__c = true;
                
                database.insert(knockList,false);
                for(Task kn: knockList){
                    system.debug('>>>>>>>>'+kn.Disposition__c);
                }
            }    
            // Test the Batches
            System.runAs(businessAdminUser){ 
                Test.startTest();
                ReportingMetricDailyBatch reportingMetricDailyBatchObj = new ReportingMetricDailyBatch(); 
                reportingMetricDailyBatchObj.queryString = 'Select Id, Region__c From User Where Profile.Name=\'XFINITY Sales Professional\' AND IsActive=true AND Id=\''+DSRepUser.Id+'\'';  
                database.executebatch(reportingMetricDailyBatchObj);
                Test.StopTest();
            }

                ScheduleDailyReportBatch scheduleDailyReportBatchObj = new ScheduleDailyReportBatch();
                System.schedule('testScheduledApex', CRON_EXP, scheduleDailyReportBatchObj);
        }
}