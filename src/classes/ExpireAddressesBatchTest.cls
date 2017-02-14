/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 29-May-2013
 * Description: This is Test class for "ExpireAddressesBatch"  and "ExpireAddressesBatchSchedulable" classes.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class ExpireAddressesBatchTest {
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    public static testMethod void testExpireAddressesBatch(){
        
        User supervisorUser;
        User dsrUser;
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        
        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);
        
        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = True;
        triggerSettingsList.add(planTrigger);
        
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);
        
        insert triggerSettingsList;
        
        
        
        Profile p1 = [Select UserType, UserLicenseId, Name From Profile where Name like 'XFINITY Sales Professional'];
        UserRole r1 = [Select Id, Name from UserRole where Name='DSR'];
        Profile p2 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Sales Development Manager'];
        UserRole r2 = [Select Id, Name from UserRole where Name='DS Supervisor'];
        
        String randomstr3 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr2 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user){
            supervisorUser = new User(Alias = 'DA_' + randomstr2.substring(0,4),
                                        Email = randomstr2 + 'userTest@SampleclassTest.com',
                                        LastName='Testing',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = p2.Id,
                                        UserRoleId = r2.Id,
                                        Username = 'userTest' + randomstr2 + '@SampleclassTest.com',
                                        Region__c = 'Freedom',
                                        FederationIdentifier = 'FedId3',
                                        EmployeeNumber = 'Emp' + randomstr3.substring(0,4));
            insert supervisorUser;
            
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
                                        Region__c = 'Freedom',
                                        Sales_Rep_Type__c = 'Upgrade',
                                        Device_Phone_Number__c = '111111',
                                        PERNR__c = '11111111',
                                        Sales_ID__c = 'abc1111',
                                        ManagerId = supervisorUser.Id,
                                        FederationIdentifier = 'FedId4',
                                        EmployeeNumber = 'Emp' + randomstr1.substring(0,4));  
            
            insert dsrUser;
        }
        //SetupTestData.createCustomSettingRecords();
        //SetupTestData.createUsers();
        System.runAs(supervisorUser){
            Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
            // Create and Assign Plan SVN testing Jan142016
            Plan__c pln = new Plan__c();
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';
            pln.Expiration_Date__c = system.Today();
            pln.Plan_Status__c = 'Assigned';
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            extnObj1.quickSave();
            pln.User__c = dsrUser.Id;
            extnObj1.Save();
            System.assert(pln.Plan_Status__c == 'Assigned');
            // Create Addresses & Associated them to plan 
            pln.Expiration_Date__c = system.Today();
            update pln;
            
            List<Customer_Address__c> addressList = new List<Customer_Address__c>();
            Customer_Address__c custAddress;
            for(Integer i=0; i<=5; i++) {
                custAddress = new Customer_Address__c();
                custAddress.Address__c = 'Test Address Line1';
                custAddress.City__c = 'Test city';
                custAddress.State__c = 'Test State';
                custAddress.Plan__c = pln.Id;  
                custAddress.Country__c = 'Test Country';
                custAddress.Region__c = 'Freedom Market';
                custAddress.PostalCode__c = '91100';
                custAddress.Node__c = '1111';
                custAddress.Route_Code__c = '111111';
                custAddress.Corp__c = '111111';
                addressList.add(custAddress);
            }
            insert addressList;
            
        }   
        //User currentUser = [Select Id From User Where Id =: UserInfo.getUserId()];
        
            // Schedule apex
        Test.StartTest();   
        System.runAs(user){ 
                ExpireAddressesBatch expAddObj = new ExpireAddressesBatch();
                database.executebatch(expAddObj); 
                //ExpireAddressesBatchSchedulable ExpireAddressesBatchSchedulableObj = new ExpireAddressesBatchSchedulable();
            //String scheduledJobId = System.schedule('testScheduledApex', CRON_EXP, ExpireAddressesBatchSchedulableObj);
            //System.assert(scheduledJobId != null);
            
            Test.StopTest(); 
           
        }
        
    }
}