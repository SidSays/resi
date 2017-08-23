/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 07-June-2013
 * Description: This is Test class for "PlanTriggerController" class.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal, Accenture 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
@isTest
public class PlanTriggerControllerTest{
    
   
    private static testMethod void testPlanTriggerController (){
        //SetupTestData.createCustomSettingRecords();
        //SetupTestData.createUsers();
		VariableSettingTestUtility.variableSettingsData(); 

        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();

        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);

        TriggerSettings__c addressStatisticsTrigger = new TriggerSettings__c();
        addressStatisticsTrigger.Name = 'AddressStatisticsTrigger';
        addressStatisticsTrigger.isActive__c = True;
        triggerSettingsList.add(addressStatisticsTrigger);

        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = True;
        triggerSettingsList.add(planTrigger);
        
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);

        insert triggerSettingsList;
        
        User supervisorUser;
        User dsrUser;
        
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
                                        PERNR__c = '98896787',
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
        
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        Plan__c pln;  
        Plan__c plnDraft;
        Customer_Address__c addr = new Customer_Address__c();
        System.runAs(supervisorUser){                        
            //Create a turf Level Plan 
            pln = new Plan__c();            
            pln.Name = 'TestPlan';            
            pln.Plan_Level__c = 'Turf'; 
            pln.Expiration_Date__c = system.Today() + 30; 
            pln.Plan_Status__c='Draft';
            insert pln;
             
            pln.Expiration_Date__c = system.Today() + 32;
           //  pln.User__c = dsrUser.Id; 
            update pln; 
            
 
           // ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);            
           // PlanEditExtn extnObj1 = new PlanEditExtn(controller1);            
           // extnObj1.quickSave();

            plnDraft = new Plan__c();            
            plnDraft.Name = 'TestPlan';            
            plnDraft.Plan_Level__c = 'Turf'; 
            plnDraft.Expiration_Date__c = system.Today() + 45; 
            plnDraft.Plan_Status__c='Draft';
            insert plnDraft;
            
            //Create Customer Address
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '12345';
            addr.Route_Code__c = '1111111111';
            addr.Corp__c = '111111';
            addr.Division = freedomRegion.Id;
            insert addr;
            addr.Plan__c = pln.Id;
            update addr;
            
            //  Assign Plan 
            pln.User__c = dsrUser.Id; 
           // update pln;
            system.debug('********PLAN******'+pln);
            system.debug('********PLAN******'+pln.Id);
            
            ApexPages.StandardController controller3 = new ApexPages.StandardController(pln);            
            PlanEditExtn extnObj3 = new PlanEditExtn(controller3);            
            extnObj3.Save(); 
            
        }
        System.runAs(dsrUser){  
             //Create a Playlist Level Plan 
            Plan__c pln2 = new Plan__c();            
            pln2.Name = 'TestPlaylist';            
            pln2.Plan_Level__c = 'Playlist'; 
            pln2.Parent_Plan__c = pln.Id;  
            pln2.PlanCriteria__c='zip_codes__c==12345'; 
            pln2.Plan_Status__c='Draft';
            insert pln2;
            addr.Plan__c=pln2.Id;
            update addr;
            
            ApexPages.StandardController controller2 = new ApexPages.StandardController(pln2);            
            PlanEditExtn extnObj2 = new PlanEditExtn(controller2);            
            extnObj2.quickSave();
            
           
            
            try{
                delete pln;
            } catch (Exception e){
                system.debug(e.getMessage());
                System.AssertNotEquals(e.getMessage(),null);    
            }

            try{
                delete plnDraft;
            }catch(Exception e){
                system.debug(e.getMessage());
                System.AssertNotEquals(e.getMessage(),null); 
            }
            // Delete the Playlist
            /*try{
                delete pln2;
            } catch (Exception e){
                System.AssertNotEquals(e.getMessage(),null);    
            }*/
        }
        System.runAs(supervisorUser){
        
         pln.Expiration_Date__c = system.Today() + 37;
         update pln;  
            // Delete the Plan
            try{
                delete pln;
            } catch (Exception e){
                system.debug(e.getMessage());
                System.AssertNotEquals(e.getMessage(),null);    
            }
        }
    }

    private static testMethod void testPlanTriggerController2(){
            //SetupTestData.createCustomSettingRecords();
            //SetupTestData.createUsers();
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();

        TriggerSettings__c addressTrigger = new TriggerSettings__c();
        addressTrigger.Name = 'AddressTrigger';
        addressTrigger.isActive__c = True;
        triggerSettingsList.add(addressTrigger);

        TriggerSettings__c addressStatisticsTrigger = new TriggerSettings__c();
        addressStatisticsTrigger.Name = 'AddressStatisticsTrigger';
        addressStatisticsTrigger.isActive__c = True;
        triggerSettingsList.add(addressStatisticsTrigger);

        TriggerSettings__c planTrigger = new TriggerSettings__c();
        planTrigger.Name = 'PlanTrigger';
        planTrigger.isActive__c = True;
        triggerSettingsList.add(planTrigger);
        
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);

        insert triggerSettingsList;
        
        User businessAdminUser;
        User dsrUser;
        
        Profile p1 = [Select UserType, UserLicenseId, Name From Profile where Name like 'XFINITY Sales Professional'];
        UserRole r1 = [Select Id, Name from UserRole where Name='DSR'];
        Profile p4 = [Select UserType, UserLicenseId, Name From Profile where Name like 'Business Administrator'];
        UserRole r4 = [Select Id, Name from UserRole where Name='National Manager'];
        
        String randomstr4 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user){
            businessAdminUser = new User(Alias = 'DA_' + randomstr4.substring(0,4),
                                        Email = randomstr4 + 'userTest@SampleclassTest.com',
                                        LastName='Testing',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = p4.Id,
                                        UserRoleId = r4.Id,
                                        Username = 'userTest' + randomstr4 + '@SampleclassTest.com',
                                        Region__c = 'Freedom',
                                        FederationIdentifier = 'FedId1',
                                        EmployeeNumber = 'Emp' + randomstr4.substring(0,4));
            insert businessAdminUser;
          
        
            
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
                                            FederationIdentifier = 'FedId4',
                                            EmployeeNumber = 'Emp' + randomstr1.substring(0,4));  
                
            insert dsrUser;
                
        }   
            
            System.runAs(businessAdminUser){
            // Create a new Plan
            
            Plan__c pln1 = new Plan__c();            
            pln1.Name = 'TestPlan1';            
            pln1.Plan_Level__c = 'Turf';    
            pln1.Plan_Status__c = 'Draft';       
            pln1.Expiration_Date__c = system.Today() + 30;            
            ApexPages.StandardController controller2 = new ApexPages.StandardController(pln1);            
            PlanEditExtn extnObj2 = new PlanEditExtn(controller2);            
            extnObj2.quickSave();
            pln1.User__c = dsrUser.Id;
            update pln1;
            // Delete the Plan in context of Admin
            try{
                //delete pln1;
            } catch (Exception e){
                System.AssertNotEquals(e.getMessage(),null);    
            }
        }
    }
    
}