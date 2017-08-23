@isTest
/***********************************************************
* Class Name: TaskTriggerControllerTest
* Author: Amitkumar Bangad, Accenture
* Date: 27-Dec-2012 
* * Description: This class does the test coverage
*              for TaskTriggerController class.
***********************************************************/
  private class TaskTriggerControllerTest{
    static Opportunity opp;
    static Lead ld,ld1,ld2,ld3;
    static List<Lead> leadList;
    Static user integrationUser;
    Static user businessUser;
   
    
    /* This method is creates data for code coverage*/
    private static void setupData() {
        WorkTestDataUtility.createCustomSettingOtherRecords();
        
        //generate Random String & Crete Business Admin User
        // fetch the Integration user profile
        UserRole role=[Select Id From UserRole WHERE Name='Indirect Manager'];
        Profile p1 = [Select UserType, UserLicenseId, Name From Profile where Name like '%Business%' ];
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        businessUser = new User(Alias = 'DA_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest@SampleTest.com',
                                    LastName='Testing',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p1.Id,
                                    FederationIdentifier = 'FedId11'+randomstr1,
                                    UserRoleId=role.Id,
                                    Username = 'userTest' + randomstr1 + '@SampleclassTest.com',
                                    EmployeeNumber = 'Emp' + randomstr1.substring(0,4));
                                    
        insert businessUser ;
         
        User currentUser = [Select Id From User Where Id =: UserInfo.getUserId()];
        System.runAs(currentUser){
            //Create Account of Type Partner
            Account partAcc = new Account();
            partAcc.Name = 'Test Partner Account';
            partAcc.Type = 'Partner';
            partAcc.ClaimEligibilityDuration__c = 240;
            partAcc.ClaimWaitDuration__c = 60;
            insert partAcc; 
            
            //Create Account of Type Customer
            Account custAcc = new Account();
            custAcc.Name = 'Test Customer Account';
            custAcc.Type = 'Customer';
            insert custAcc;
            
            //Enable the account as partner
            partAcc.IsPartner = true;
            update partAcc;
            
            // Create a contact under the partner account
            Contact partContact = new Contact();
            partContact.AccountId = partAcc.Id;
            partContact.lastName = 'Test Contact';
            insert partContact;
            
            // fetch the Integration user profile
            Profile p = [Select UserType, UserLicenseId, Name From Profile where Name = 'XC Integration Profile' ];
            
            //generate Random String 
            String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
            integrationUser = new User(Alias = 'DA_' + randomstr.substring(0,4),
                                        Email = randomstr + 'userTest@SampleTest.com',
                                        LastName='Testing',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = p.Id,
                                        FederationIdentifier = 'FedId10'+randomstr,
                                        Username = 'userTest' + randomstr + '@SampleclassTest.com',
                                        UserRoleId=role.Id,
                                        EmployeeNumber = 'Emp' + randomstr.substring(0,4));
            insert integrationUser;
            

            //Insert Opportunity
            opp = new Opportunity();
            opp.Name = 'Test Opportunity'; 
            opp.AccountId = custAcc.Id; 
            opp.StageName='Open';
            opp.Affiliate_Account__c = partAcc.id;
            opp.CloseDate=Date.today()+30;
            opp.LeadSource = 'Affiliate';
            insert opp;
            
            //Insert Lead
            leadList = new List<Lead>();
            ld = new lead();
            ld.lastName = 'Jamerson';
            ld.Company = 'Jamerson Home';
            ld.Status = 'Contacted';
            ld.LeadSource = 'Comcast Internal';
            leadList.add(ld);
            
            ld1 = new lead();
            ld1.ownerId = integrationUser.Id;
            ld1.Affiliate_Account__c = partAcc.Id;
            ld1.lastName = 'Anderson';
            ld1.Company = 'Anderson Home';
            ld1.Status = 'Contacted';
            ld1.LeadSource = 'Affiliate';
            leadList.add(ld1);
            
            ld2 = new lead();
            ld2.lastName = 'Jackson';
            ld2.Company = 'Jackson Home';
            ld2.Status = 'Contacted';
            ld2.LeadSource = 'Comcast Internal';
            leadList.add(ld2);
            
            ld3 = new lead();
            ld3.lastName = 'Peterson';
            ld3.Company = 'Peterson Home';
            ld3.Status = 'Contacted';
            ld3.LeadSource = 'Comcast Internal';
            leadList.add(ld3);
            insert leadList;
        }
    }
    
     /* This method is used for test coverage of Positive scenarios identifyLeadTimeToTouch method*/

    private static testMethod void timeToTouchPositiveTest() {
        
        //setupData();
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        
            TriggerSettings__c leadTrigger = new TriggerSettings__c();
            leadTrigger.Name = 'LeadTrigger';
            leadTrigger.isActive__c = True;
            triggerSettingsList.add(leadTrigger);
            
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = True;
            triggerSettingsList.add(userTrigger);
            
            TriggerSettings__c taskTrigger = new TriggerSettings__c();
            taskTrigger.Name = 'TaskTrigger';
            taskTrigger.isActive__c = True;
            triggerSettingsList.add(taskTrigger);
            
            insert triggerSettingsList;
            
            GoalTemplateDates__c templateDates = new GoalTemplateDates__c();
            templateDates.Current_Period_Start_Date__c = Date.newinstance(2015, 6, 22);
            templateDates.Current_Period_Due_Date__c = Date.newinstance(2015, 7, 21);
            templateDates.Name = 'ActivityGoalCommissionCycle';
            Database.insert(templateDates);

        User currentUser = [Select Id From User Where Id =: UserInfo.getUserId()];
     
        Test.startTest();
        
        System.runAs(currentUser){
            
            ld = new lead();
            ld.lastName = 'Jamerson';
            ld.Company = 'Jamerson Home';
            ld.Status = 'Contacted';
            ld.LeadSource = 'Comcast Internal';
            insert ld;
            
            ld2 = new lead();
            ld2.lastName = 'Jackson';
            ld2.Company = 'Jackson Home';
            ld2.Status = 'Contacted';
            ld2.LeadSource = 'Comcast Internal';
            insert ld2;
            // Insert Task in System with status as completed on Lead Generated by Comcast Internal
            Task tk = new Task();
            tk.OwnerId = UserInfo.getUserId();
            tk.whoId = ld.Id;
            tk.Subject = 'test';
            tk.Status = 'Completed';
            tk.Priority = 'Normal';
            tk.ActivityDate = System.Today();
            insert tk;

            //Verify that time to touch is captured
            Lead touchedLead = [Select Id, Name, Time_To_Touch__c, FirstModifiedDate__c, 
                                FirstModifiedBy__c from Lead where Id=:ld.id];
           
            System.AssertEquals(touchedLead.Time_To_Touch__c == 0, true);  
            System.AssertEquals(touchedLead.FirstModifiedDate__c == null, false);  
            System.AssertEquals(touchedLead.FirstModifiedBy__c == null, false);
            
            // Insert Task in System with incomplete status on Lead Generated by Comcast Internal
            Task tk1 = new Task();
            tk1.OwnerId = UserInfo.getUserId();
            tk1.whoId = ld2.Id;
            tk1.Subject = 'test';
            tk1.Status = 'In Progress';
            tk1.Priority = 'Normal';
            tk1.ActivityDate = System.Today();
            insert tk1;  
            
            tk1.Status = 'Completed';
            update tk1; 
            
            //Verify that time to touch is captured
            touchedLead = [Select Id, Name, Time_To_Touch__c, FirstModifiedDate__c, 
                                FirstModifiedBy__c from Lead where Id=:ld2.id];
           
            System.AssertEquals(touchedLead.Time_To_Touch__c == 0, true);  
            System.AssertEquals(touchedLead.FirstModifiedDate__c == null, false);  
            System.AssertEquals(touchedLead.FirstModifiedBy__c == null, false); 
        }
                 
        Test.stopTest();
    }
    
    /* This method is used for test coverage of Negative scenarios for identifyLeadTimeToTouch method*/

    /*private static testMethod void timeToTouchNegativeTest() {
    
        //setupData();
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
            TriggerSettings__c leadTrigger = new TriggerSettings__c();
            leadTrigger.Name = 'LeadTrigger';
            leadTrigger.isActive__c = True;
            triggerSettingsList.add(leadTrigger);
            
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = True;
            triggerSettingsList.add(userTrigger);
            
            TriggerSettings__c taskTrigger = new TriggerSettings__c();
            taskTrigger.Name = 'TaskTrigger';
            taskTrigger.isActive__c = True;
            triggerSettingsList.add(taskTrigger);
            
            insert triggerSettingsList;
            
        Test.startTest();
        
        // fetch the Integration user profile
        Profile p = [Select UserType, UserLicenseId, Name From Profile where Name = 'XC Integration Profile' ];
        
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        User currentUser = [Select Id From User Where Id =: UserInfo.getUserId()];
        System.runAs(integrationUser){
            integrationUser = new User(Alias = 'DA_' + randomstr.substring(0,4),
                                        Email = randomstr + 'userTest@SampleTest.com',
                                        LastName='Testing',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = p.Id,
                                        FederationIdentifier = 'FedId10'+randomstr,
                                        Username = 'userTest' + randomstr + '@SampleclassTest.com',
                                        //UserRoleId=role.Id,
                                        EmployeeNumber = 'Emp' + randomstr.substring(0,4));
            insert integrationUser;
        }
        Account partAcc = new Account();
        partAcc.Name = 'Test Partner Account';
        partAcc.Type = 'Partner';
        partAcc.ClaimEligibilityDuration__c = 240;
        partAcc.ClaimWaitDuration__c = 60;
        insert partAcc; 
        
        
        System.runAs(integrationUser){
            List<Lead> leadLst = new List<Lead>();
            //Creating Lead
            ld1 = new lead();
            ld1.ownerId = integrationUser.Id;
            ld1.Affiliate_Account__c = partAcc.Id;
            ld1.lastName = 'Anderson';
            ld1.Company = 'Anderson Home';
            ld1.Status = 'Contacted';
            ld1.LeadSource = 'Affiliate';
            leadLst.add(ld1);
            
            ld3 = new lead();
            ld3.lastName = 'Peterson';
            ld3.Company = 'Peterson Home';
            ld3.Status = 'Contacted';
            ld3.LeadSource = 'Comcast Internal';
            leadLst.add(ld3);
            insert leadLst;
            
            String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Task' and Name = 'Task'].Id;
            
            // Insert Task in System with incomplete status on Lead Generated by Comcast Internal
            Task tk2 = new Task();
            tk2.OwnerId = UserInfo.getUserId();
            tk2.whoId = ld3.Id;
            tk2.Subject = 'test';
            tk2.RecordTypeId = strRecordTypeId;
            tk2.Status = 'In Progress';
            tk2.Priority = 'Normal';
            tk2.ActivityDate = System.Today();
            insert tk2;
            
            //Verify time to touch is not captured
            lead touchedLead = [Select Id, Name, Time_To_Touch__c, FirstModifiedDate__c, 
                                FirstModifiedBy__c from Lead where Id=:ld3.id];
           
            System.AssertEquals(touchedLead.Time_To_Touch__c == null, true);  
            System.AssertEquals(touchedLead.FirstModifiedDate__c == null, true);  
            System.AssertEquals(touchedLead.FirstModifiedBy__c == null, true); 
            
            String strRecordTypeIdtk3 = [Select Id From RecordType Where SobjectType = 'Task' and Name = 'Task'].Id;
            
            // Insert Task in System with completed status on Lead Generated by Affiliate & ownership with Integration User
            Task tk3 = new Task();
            tk3.OwnerId = UserInfo.getUserId();
            tk3.whoId = ld1.Id;
            tk3.Subject = 'test';
            tk3.RecordTypeId = strRecordTypeIdtk3 ;
            tk3.Status = 'In Progress';
            tk3.Priority = 'Normal';
            tk3.ActivityDate = System.Today();
            insert tk3;
            
            //Verify time to touch is not captured
            touchedLead = [Select Id, Name, Time_To_Touch__c, FirstModifiedDate__c, 
                                FirstModifiedBy__c from Lead where Id=:ld1.id];
           
            System.AssertEquals(touchedLead.Time_To_Touch__c == null, true);  
            System.AssertEquals(touchedLead.FirstModifiedDate__c == null, true);  
            System.AssertEquals(touchedLead.FirstModifiedBy__c == null, true); 
            
            // Try deleting Task
            try{
                delete tk2;
            }catch (DmlException dmlEx){
                for(Integer i =0; i<dmlEx.getNumDml(); ++i) { 
                    system.AssertEquals(dmlEx.getDmlMessage(i) != null, true);
                }
            }
        }
        Test.stopTest();
    } */
    
    /* Laxman */
    /* This method is used for test coverage of Positive scenarios of oneAsonecoachingvalidation method*/
   /* private static testMethod void oneAsonecoachingTest(){
      
        WorkTestDataUtility.createCustomSettingRecords();
      
        GoalTemplateDates__c templateDates = new GoalTemplateDates__c();
        templateDates.Current_Period_Start_Date__c = Date.newinstance(2015, 6, 22);
        templateDates.Current_Period_Due_Date__c = Date.newinstance(2015, 7, 21);
        templateDates.Name = 'ActivityGoalCommissionCycle';
        Database.insert(templateDates);
      
      //Creating Test Data for XSP/SDM/ASM user
      User XSP= WorkTestDataUtility.createDSRepUserForCoaching();
      insert XSP;
      User SDM= WorkTestDataUtility.createDSSupervisorUserForCoaching();
      insert SDM;
      User ASM= WorkTestDataUtility.createDSManagerUserForCoaching();
      insert ASM;
      XSP.ManagerId = SDM.Id;
      update XSP;
      SDM.ManagerId = ASM.Id;
      update SDM;
      
      
        User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
        System.runAs(currentUser){            
            AssignPermissionSet('SalesSpace_Coach_Access_ASM',ASM.Id);   
            AssignPermissionSet('SalesSpace_Coach_Access_SDM',SDM.Id);
            AssignPermissionSet('SalesSpace_Coach_Access_XSP',XSP.Id);
        }  
        
      workcoaching wc1 = new workcoaching();
      //coach 
      wc1.coachid=SDM.Id;
      //coachedId person coached
      System.runAs(XSP){
      wc1.coachedid=XSP.Id;
      insert wc1;}
        
      //Insert Task for XSP and SDM Relationship
      system.RunAs(XSP){
        String RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('1:1 Coaching').getRecordTypeId();
            Task tskxsp = new Task();
            tskxsp .RecordTypeId = RecordTypeId;
            tskxsp .OwnerId = UserInfo.getUserId();
            tskxsp .whatId = wc1.id;
            tskxsp .Subject = 'test';
            tskxsp .Status = 'Completed';
            tskxsp .Priority = 'Normal';
            tskxsp .ActivityDate = System.Today();
            insert tskxsp ;
      }
      
      //Insert coaching when relationship between sdm & asm.
      workcoaching wc2 = new workcoaching();
      wc2.coachid=ASM.Id;
      wc2.coachedid=SDM.Id;
      insert wc2;
      
      //Task created by SDM And ASM .
      system.RunAs(SDM){
        String RecordTypeId1 = Schema.SObjectType.Task.getRecordTypeInfosByName().get('1:1 Coaching').getRecordTypeId();
        Task tsksdm = new Task();
        tsksdm .RecordTypeId = RecordTypeId1;
        tsksdm .OwnerId = UserInfo.getUserId();
        tsksdm .whatId = wc2.id;
        tsksdm .Subject = 'test';
        tsksdm .Status = 'Completed';
        tsksdm .Priority = 'Normal';
        tsksdm .ActivityDate = System.Today();
        insert tsksdm ;
      }
    }*/

    /* This method is used for test coverage of Positive scenarios of countCallLogs method*/

    private static testMethod void callCountPositiveTest() {
        //setupData();
        GoalTemplateDates__c templateDates = new GoalTemplateDates__c();
        templateDates.Current_Period_Start_Date__c = Date.newinstance(2015, 6, 22);
        templateDates.Current_Period_Due_Date__c = Date.newinstance(2015, 7, 21);
        templateDates.Name = 'ActivityGoalCommissionCycle';
        Database.insert(templateDates);
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = True;
            triggerSettingsList.add(userTrigger);
            
            TriggerSettings__c leadTrigger = new TriggerSettings__c();
            leadTrigger.Name = 'LeadTrigger';
            leadTrigger.isActive__c = True;
            triggerSettingsList.add(leadTrigger);
            
            TriggerSettings__c taskTrigger = new TriggerSettings__c();
            taskTrigger.Name = 'TaskTrigger';
            taskTrigger.isActive__c = True;
            triggerSettingsList.add(taskTrigger);
            
        database.insert (triggerSettingsList);  
    
        UserRole role=[Select Id From UserRole WHERE Name='Indirect Manager'];
        Profile p1 = [Select UserType, UserLicenseId, Name From Profile where Name = 'Business Administrator'];
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        
        User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
        System.runAs(currentUser){  
            businessUser = new User(Alias = 'DA_' + randomstr1.substring(0,4),
                                        Email = randomstr1 + 'userTest@SampleTest.com',
                                        LastName='Testing',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = p1.Id,
                                        FederationIdentifier = 'FedId11'+randomstr1,
                                        UserRoleId=role.Id,
                                        Username = 'userTest' + randomstr1 + '@SampleclassTest.com',
                                        EmployeeNumber = 'Emp' + randomstr1.substring(0,4));
                                    
    
            insert businessUser ;
            
            // fetch the Integration user profile
            Profile p = [Select UserType, UserLicenseId, Name From Profile where Name = 'XC Integration Profile' ];
            
            //generate Random String 
            String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
            integrationUser = new User(Alias = 'DA_' + randomstr.substring(0,4),
                                        Email = randomstr + 'userTest@SampleTest.com',
                                        LastName='Testing',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = p.Id,
                                        FederationIdentifier = 'FedId10'+randomstr,
                                        Username = 'userTest' + randomstr + '@SampleclassTest.com',
                                        UserRoleId=role.Id,
                                        EmployeeNumber = 'Emp' + randomstr.substring(0,4));
            insert integrationUser;
            
            Account partAcc = new Account();
            partAcc.Name = 'Test Partner Account';
            partAcc.Type = 'Partner';
            partAcc.ClaimEligibilityDuration__c = 240;
            partAcc.ClaimWaitDuration__c = 60;
            insert partAcc; 
        
            ld1 = new lead();
            ld1.ownerId = integrationUser.Id;
            ld1.Affiliate_Account__c = partAcc.Id;
            ld1.lastName = 'Anderson';
            ld1.Company = 'Anderson Home';
            ld1.Status = 'Contacted';
            ld1.LeadSource = 'Affiliate';
            insert ld1;
            
            //Create Account of Type Customer
            Account custAcc = new Account();
            custAcc.Name = 'Test Customer Account';
            custAcc.Type = 'Customer';
            insert custAcc;
            
            opp = new Opportunity();
            opp.Name = 'Test Opportunity'; 
            opp.AccountId = custAcc.Id; 
            opp.StageName='Open';
            opp.Affiliate_Account__c = partAcc.id;
            opp.CloseDate=Date.today()+30;
            opp.LeadSource = 'Affiliate';
            insert opp;
        }
        
        System.RunAs(businessUser){ 
            Test.startTest();
            // Insert Task in System of type Call Log on Lead 
            String RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Call').getRecordTypeId(); 
            Task tk4 = new Task();
            tk4.RecordTypeId = RecordTypeId;
            tk4.OwnerId = UserInfo.getUserId();
            tk4.whoId = ld1.Id;
            tk4.Subject = 'test';
            tk4.Status = 'Completed';
            tk4.Priority = 'Normal';
            tk4.ActivityDate = System.Today();
            insert tk4;
            
            //Verify Call Count is captured
            Lead contactedLead = [Select Id, Name, Call_Count__c, FirstModifiedDate__c, 
                                FirstModifiedBy__c from Lead where Id=:ld1.id];
           
            System.AssertEquals(contactedLead.Call_Count__c == 1, true);  
            
            // Delete task
            delete tk4;

            // Insert Task in System of type Call Log on Opportunity
            Task tk5 = new Task();
            tk5.RecordTypeId = RecordTypeId;
            tk5.OwnerId = UserInfo.getUserId();
            tk5.whatId = opp.Id;
            tk5.Subject = 'test';
            tk5.Status = 'Completed';
            tk5.Priority = 'Normal';
            tk5.ActivityDate = System.Today();
            insert tk5;
            
            //Verify Call Count is captured
            Opportunity contactedOppty = [Select Id, Call_Count__c from Opportunity where Id=:opp.id];
            System.AssertEquals(contactedOppty.Call_Count__c == 1, true);
            
            // Insert one more Task in System of type Call Log on Opportunity
            Task tk8 = new Task();
            tk8.RecordTypeId = RecordTypeId;
            tk8.OwnerId = UserInfo.getUserId();
            tk8.whatId = opp.Id;
            tk8.Subject = 'test';
            tk8.Status = 'Completed';
            tk8.Priority = 'Normal';
            tk8.ActivityDate = System.Today();
            insert tk8; 
            
            //Verify Call Count is increased
            contactedOppty = [Select Id, Call_Count__c from Opportunity where Id=:opp.id];
            System.AssertEquals(contactedOppty.Call_Count__c == 2, true); 
            
            // Delete task
            delete tk8;
            Test.stopTest();
        }
    }  
     
    
    /* This method is used for test coverage of Negative scenarios for countCallLogs method*/

    private static testMethod void callCountNegativeTest() {
    
        // setupData();
        //WorkTestDataUtility.createCustomSettingOtherRecords();
        
        //generate Random String & Crete Business Admin User
        // fetch the Integration user profile
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = True;
            triggerSettingsList.add(userTrigger);
        
            TriggerSettings__c leadTrigger = new TriggerSettings__c();
            leadTrigger.Name = 'LeadTrigger';
            leadTrigger.isActive__c = True;
            triggerSettingsList.add(leadTrigger);
            
            TriggerSettings__c taskTrigger = new TriggerSettings__c();
            taskTrigger.Name = 'TaskTrigger';
            taskTrigger.isActive__c = True;
            triggerSettingsList.add(taskTrigger);
            
        Database.insert(triggerSettingsList);
        
        GoalTemplateDates__c templateDates = new GoalTemplateDates__c();
        templateDates.Current_Period_Start_Date__c = Date.newinstance(2015, 6, 22);
        templateDates.Current_Period_Due_Date__c = Date.newinstance(2015, 7, 21);
        templateDates.Name = 'ActivityGoalCommissionCycle';
        Database.insert(templateDates);
        
        UserRole role=[Select Id From UserRole WHERE Name='Indirect Manager'];
        Profile p1 = [Select UserType, UserLicenseId, Name From Profile where Name = 'Business Administrator'];
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
        
        User currentUser1 = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
        System.runAs(currentUser1){  
            businessUser = new User(Alias = 'DA_' + randomstr1.substring(0,4),
                                        Email = randomstr1 + 'userTest@SampleTest.com',
                                        LastName='Testing',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = p1.Id,
                                        FederationIdentifier = 'FedId11'+randomstr1,
                                        UserRoleId=role.Id,
                                        Username = 'userTest' + randomstr1 + '@SampleclassTest.com',
                                        EmployeeNumber = 'Emp' + randomstr1.substring(0,4));
                                        
            insert businessUser ;
        } 
                //    User currentUser = [Select Id From User Where Id =: UserInfo.getUserId()];
        System.runAs(businessUser){
            //Create Account of Type Partner
            Account partAcc = new Account();
            partAcc.Name = 'Test Partner Account';
            partAcc.Type = 'Partner';
            partAcc.ClaimEligibilityDuration__c = 240;
            partAcc.ClaimWaitDuration__c = 60;
            insert partAcc; 
            
            //Create Account of Type Customer
            Account custAcc = new Account();
            custAcc.Name = 'Test Customer Account';
            custAcc.Type = 'Customer';
            insert custAcc;
            
            //Enable the account as partner
            partAcc.IsPartner = true;
            update partAcc;
            
            // Create a contact under the partner account
            Contact partContact = new Contact();
            partContact.AccountId = partAcc.Id;
            partContact.lastName = 'Test Contact';
            insert partContact;
            
            // fetch the Integration user profile
            Profile p = [Select UserType, UserLicenseId, Name From Profile where Name = 'XC Integration Profile' ];
            
            //generate Random String 
            String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
            integrationUser = new User(Alias = 'DA_' + randomstr.substring(0,4),
                                        Email = randomstr + 'userTest@SampleTest.com',
                                        LastName='Testing',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = p.Id,
                                        FederationIdentifier = 'FedId10'+randomstr,
                                        Username = 'userTest' + randomstr + '@SampleclassTest.com',
                                        UserRoleId=role.Id,
                                        EmployeeNumber = 'Emp' + randomstr.substring(0,4));
            insert integrationUser;
            

            //Insert Opportunity
            opp = new Opportunity();
            opp.Name = 'Test Opportunity'; 
            opp.AccountId = custAcc.Id; 
            opp.StageName='Open';
            opp.Affiliate_Account__c = partAcc.id;
            opp.CloseDate=Date.today()+30;
            opp.LeadSource = 'Affiliate';
            insert opp;
            
            //Insert Lead
            leadList = new List<Lead>();
            ld = new lead();
            ld.lastName = 'Jamerson';
            ld.Company = 'Jamerson Home';
            ld.Status = 'Contacted';
            ld.LeadSource = 'Comcast Internal';
            leadList.add(ld);
            
            ld1 = new lead();
            ld1.ownerId = integrationUser.Id;
            ld1.Affiliate_Account__c = partAcc.Id;
            ld1.lastName = 'Anderson';
            ld1.Company = 'Anderson Home';
            ld1.Status = 'Contacted';
            ld1.LeadSource = 'Affiliate';
            leadList.add(ld1);
            
            ld2 = new lead();
            ld2.lastName = 'Jackson';
            ld2.Company = 'Jackson Home';
            ld2.Status = 'Contacted';
            ld2.LeadSource = 'Comcast Internal';
            leadList.add(ld2);
            
            ld3 = new lead();
            ld3.lastName = 'Peterson';
            ld3.Company = 'Peterson Home';
            ld3.Status = 'Contacted';
            ld3.LeadSource = 'Comcast Internal';
            leadList.add(ld3);
            insert leadList;
        }
        Test.startTest();
        
        // Insert Task in System of type 'Task' on Opportunity
        String RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task').getRecordTypeId(); 
        
        User currentUser = [Select Id From User Where Id =: UserInfo.getUserId()];
        System.runAs(currentUser){
            Task tk6 = new Task();
            tk6.RecordTypeId = RecordTypeId;
            tk6.OwnerId = UserInfo.getUserId();
            tk6.whatId = opp.Id;
            tk6.Subject = 'test';
            tk6.Status = 'Completed';
            tk6.Priority = 'Normal';
            tk6.ActivityDate = System.Today();
            insert tk6;
        
            //Verify Call Count is not increased
            Opportunity contactedOppty = [Select Id, Call_Count__c from Opportunity where Id=:opp.id];
            System.AssertEquals(contactedOppty.Call_Count__c == 0, true); 
            
            // Insert Task in System of type 'Task' on Lead 
            Task tk7 = new Task();
            tk7.RecordTypeId = RecordTypeId;
            tk7.OwnerId = UserInfo.getUserId();
            tk7.whoId = ld1.Id;
            tk7.Subject = 'test';
            tk7.Status = 'Completed';
            tk7.Priority = 'Normal';
            tk7.ActivityDate = System.Today();
            insert tk7;
            //}
            //Verify Call Count is not increased
            Lead contactedLead = [Select Id, Name, Call_Count__c, FirstModifiedDate__c, 
                                FirstModifiedBy__c from Lead where Id=:ld1.id];
           
            System.AssertEquals(contactedLead.Call_Count__c == 0, true);  
            Test.stopTest(); 
        }  
    }
    
    
   private static testMethod void knockRecordRollUpTest() {
        
        WorkTestDataUtility.createCustomSettingRecords();
        
        GoalTemplateDates__c templateDates = new GoalTemplateDates__c();
        templateDates.Current_Period_Start_Date__c = Date.newinstance(2015, 6, 22);
        templateDates.Current_Period_Due_Date__c = Date.newinstance(2015, 7, 21);
        templateDates.Name = 'ActivityGoalCommissionCycle';
        Database.insert(templateDates);
        
        Division bigSouthRegion = [select id, name from Division where name ='Big South Region'];
        Customer_Address__c addr1 = new Customer_Address__c();
        
            addr1.Address__c = 'Test Address';
            addr1.State__c = 'Test State';
            addr1.City__c = 'Test City';
            addr1.Country__c = 'Test Country';
            addr1.PostalCode__c = '12345';
            addr1.Corp__c = '111111';
            addr1.Node__c = '1111';
            addr1.Route_Code__c = '1111111111';
            addr1.Region__c = 'BigSouthRegion';
            addr1.Division=bigSouthRegion .Id;
 
            insert addr1; 
       
        Test.StartTest();
        //list to insert the knock records.
        List<Task> taskList = new List<Task>();
        DateTime dt = system.now();
        //Create and insert Knock Records.
        
        Task task1 = WorkTestDataUtility.CreateTask();               
        task1.Disposition__c='No Knock';
        task1.Dwelling_Type__c='Single Family';
        task1.Knocked_Date__c = dt.addHours(-00);
        task1.Off_Turf__c = True;
        task1.whatId = addr1.Id;
        taskList.add(task1);
     
        Task task2 = WorkTestDataUtility.CreateTask();               
        task2.Disposition__c='No Answer';
        task2.Dwelling_Type__c='Bulk Billed Master';
        task2.Knocked_Date__c = dt.addHours(-01);
        task2.Off_Turf__c = True; 
        task2.whatId = addr1.Id;
        taskList.add(task2);
        
        Task task3 = WorkTestDataUtility.CreateTask();               
        task3.Disposition__c='Door Hanger';
        task3.Dwelling_Type__c='Commercial';
        task3.Knocked_Date__c = dt.addHours(-02); 
        task3.Off_Turf__c = True;
        task3.whatId = addr1.Id;
        taskList.add(task3);
        
        Task task4 = WorkTestDataUtility.CreateTask();               
        task4.Disposition__c='Contact';
        task4.Dwelling_Type__c='Bulk Billed MDU';
        task4.Knocked_Date__c = dt.addHours(-03);
        task4.Off_Turf__c = True; 
        task4.whatId = addr1.Id;
        taskList.add(task4);
        
        Task task5 = WorkTestDataUtility.CreateTask();               
        task5.Disposition__c='Engage';
        task5.Dwelling_Type__c='Non Bulk Billed MDU';
        task5.Knocked_Date__c = dt.addHours(-04);
        task5.Off_Turf__c = True;
        task5.whatId = addr1.Id;
        taskList.add(task5);
        
        Task task6 = WorkTestDataUtility.CreateTask();               
        task6.Disposition__c='Discover';
        task6.Dwelling_Type__c='Unknown';  
        task6.Knocked_Date__c = dt.addHours(-05);  
        task6.Off_Turf__c = True; 
        task6.whatId = addr1.Id;        
        taskList.add(task6);
        
        Task task7 = WorkTestDataUtility.CreateTask();               
        task7.Disposition__c='Position';
        task7.Dwelling_Type__c='Single Family Unit';
        task7.Knocked_Date__c = dt.addHours(-06);
        task7.Off_Turf__c = True;
        task7.whatId = addr1.Id;
        taskList.add(task7);
        
        Task task8 = WorkTestDataUtility.CreateTask();               
        task8.Disposition__c='Close';
        task8.Dwelling_Type__c='Multiple Dwelling Unit';      
        task8.Knocked_Date__c = dt.addHours(-07);
        task8.Off_Turf__c = True;
        task8.whatId = addr1.Id;
        taskList.add(task8);
    
        Task task9 = WorkTestDataUtility.CreateTask();               
        task9.Disposition__c='Start';
        task9.Dwelling_Type__c='Vacant';  
        task9.Knocked_Date__c = dt.addHours(-08);  
        task9.Off_Turf__c = True;
        task9.whatId = addr1.Id;
        taskList.add(task9);
     
        /*Task task10 = WorkTestDataUtility.CreateTask();               
        task10.Disposition__c='Non-Marketable Address';
        task10.Dwelling_Type__c='Non Bulk Billed';
        task10.Knocked_Date__c = dt.addHours(-09); 
        task10.Off_Turf__c = True;
        task10.whatId = addr1.Id;
        taskList.add(task10);*/
        
        Task task11 = WorkTestDataUtility.CreateTask();               
        task11.Disposition__c='No Knock';
        task11.Dwelling_Type__c='SFU';
        task11.Knocked_Date__c = dt.addHours(-10); 
        task11.Off_Turf__c = True; 
        task11.whatId = addr1.Id;
        taskList.add(task11);
        
        Task task12 = WorkTestDataUtility.CreateTask();               
        task12.Disposition__c='No Knock';
        task12.Dwelling_Type__c='MDU';      
        task12.Knocked_Date__c = dt.addHours(-11);
        task12.Off_Turf__c = True; 
        task12.whatId = addr1.Id;
        taskList.add(task12);
        
        Task task13 = WorkTestDataUtility.CreateTask();               
        task13.Disposition__c='No Knock';
        task13.Dwelling_Type__c='OTHER';      
        task13.Knocked_Date__c = dt.addHours(-12);
        task13.Off_Turf__c = True;
        task13.whatId = addr1.Id;
        taskList.add(task13);
        
        Task task14 = WorkTestDataUtility.CreateTask();               
        task14.Disposition__c='No Knock';
        task14.Dwelling_Type__c='EXCLUDE MAPPING';
        task14.Knocked_Date__c = dt.addHours(-13);  
        task14.Off_Turf__c = True; 
        task14.whatId = addr1.Id;
        taskList.add(task14);
        
        Task task15 = WorkTestDataUtility.CreateTask();               
        task15.Disposition__c='No Knock';
        task15.Dwelling_Type__c='MDU';      
        task15.Knocked_Date__c = dt.addHours(-14);
        task15.Off_Turf__c = True;
        task15.whatId = addr1.Id;
        taskList.add(task15);
        
        Task task16 = WorkTestDataUtility.CreateTask();               
        task16.Disposition__c='No Knock';
        task16.Dwelling_Type__c='MDU';      
        task16.Knocked_Date__c = dt.addHours(-15);
        task16.Off_Turf__c = True; 
        task16.whatId = addr1.Id;
        taskList.add(task16);
    
        Task task17 = WorkTestDataUtility.CreateTask();               
        task17.Disposition__c='No Knock';
        task17.Dwelling_Type__c='MDU';
        task17.Knocked_Date__c = dt.addHours(-16); 
        task17.Off_Turf__c = True; 
        task17.whatId = addr1.Id;
        taskList.add(task17);
     
        Task task18 = WorkTestDataUtility.CreateTask();               
        task18.Disposition__c='No Knock';
        task18.Dwelling_Type__c='MDU';
        task18.Knocked_Date__c = dt.addHours(-17); 
        task18.Off_Turf__c = True; 
        task18.whatId = addr1.Id;
        taskList.add(task18);
        
        Task task19 = WorkTestDataUtility.CreateTask();               
        task19.Disposition__c='No Knock';
        task19.Dwelling_Type__c='MDU';
        task19.Knocked_Date__c = dt.addHours(-18);    
        task19.Off_Turf__c = True;
        task19.whatId = addr1.Id;
        taskList.add(task19);
        
        Task task20 = WorkTestDataUtility.CreateTask();               
        task20.Disposition__c='No Knock';
        task20.Dwelling_Type__c='MDU';
        task20.Knocked_Date__c = dt.addHours(-19); 
        task20.Off_Turf__c = True;
        task20.whatId = addr1.Id;
        taskList.add(task20);
        
        Task task21 = WorkTestDataUtility.CreateTask();               
        task21.Disposition__c='No Knock';
        task21.Dwelling_Type__c='MDU';
        task21.Knocked_Date__c = dt.addHours(-20);  
        task21.Off_Turf__c = True;
        task21.whatId = addr1.Id;
        taskList.add(task21);
        
        Task task22 = WorkTestDataUtility.CreateTask();               
        task22.Disposition__c='No Knock';
        task22.Dwelling_Type__c='MDU';
        task22.Knocked_Date__c = dt.addHours(-21); 
        task22.Off_Turf__c = True;
        task22.whatId = addr1.Id;
        taskList.add(task22);
        
        Task task23 = WorkTestDataUtility.CreateTask();               
        task23.Disposition__c='No Knock';
        task23.Dwelling_Type__c='MDU';
        task23.Knocked_Date__c = dt.addHours(-22);  
        task23.Off_Turf__c = True;
        task23.whatId = addr1.Id;
        taskList.add(task23);
        
        Task task24 = WorkTestDataUtility.CreateTask();               
        task24.Disposition__c='No Knock';
        task24.Dwelling_Type__c='MDU';
        task24.Knocked_Date__c = dt.addHours(-23); 
        task24.Off_Turf__c = True;
        task24.whatId = addr1.Id;
        taskList.add(task24);

        insert taskList;
         Test.StopTest();
    }
    
    private static testMethod void getDistanceTest() {
    
    WorkTestDataUtility.createCustomSettingRecords();
    GoalTemplateDates__c templateDates = new GoalTemplateDates__c();
    templateDates.Current_Period_Start_Date__c = Date.newinstance(2015, 6, 22);
    templateDates.Current_Period_Due_Date__c = Date.newinstance(2015, 7, 21);
    templateDates.Name = 'ActivityGoalCommissionCycle';
    Database.insert(templateDates);
    
    Division bigSouthRegion = [select id, name from Division where name ='Big South Region'];
        Customer_Address__c addr2 = new Customer_Address__c();
        
            addr2.Address__c = 'Test Address';
            addr2.State__c = 'Test State';
            addr2.City__c = 'Test City';
            addr2.Country__c = 'Test Country';
            addr2.PostalCode__c = '12345';
            addr2.Corp__c = '111111';
            addr2.Node__c = '1111';
            addr2.Route_Code__c = '1111111111';
            addr2.Region__c = 'BigSouthRegion';
            addr2.Division=bigSouthRegion .Id;
 
            insert addr2; 
    
    //Creating task
    Task tsk = WorkTestDataUtility.CreateTask();
    tsk.Disposition__c='No Knock';
    tsk.Dwelling_Type__c='MDU';
    tsk.Off_Turf__c = True;
    tsk.Disposition_Location__Latitude__s= 44.240309 ;
    tsk.Disposition_Location__Longitude__s= -91.493619;
    tsk.whatId = addr2.Id;
    insert tsk;
     
     Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        // Create Compex Office Address
        Customer_Address__c addr = new Customer_Address__c();
        addr.Address__c = 'Test Address';
        addr.State__c = 'Test State';
        addr.City__c = 'Test City';
        addr.Country__c = 'Test Country';
        addr.PostalCode__c = '12345';
        addr.Node__c = '12345';
        addr.Division = freedomRegion.Id;
        addr.Complex_Office__c = true;
        insert addr;
        
        // Create Customer Addresses
        List<Customer_Address__c> addrList = new List<Customer_Address__c>();
        Customer_Address__c addr1;
            addr1 = new Customer_Address__c();
            addr1.Address__c = 'Test Address' ;
            addr1.State__c = 'Test State';
            addr1.City__c = 'Test City' ;
            addr1.Country__c = 'Test Country';
            addr1.PostalCode__c = '12345';
            addr1.Node__c = '1111';
            addr1.Corp__c = '11111111';
            addr1.Latitude__c =44.92057 ;
            addr1.Longitude__c =-93.44786 ;
            addr1.Route_Code__c = '1111111111';
            addr1.Division = freedomRegion.Id;
            addr1.Parent_Address__c = addr.Id;
            insert addr1;
        taskTriggerController.getDistance(tsk,addr1);
    }
    
    private static testMethod void processLocationDateTimeTest() {
        DateTime dtime = datetime.now();
        String dt = String.valueOf(dtime);
        taskTriggerController.processLocationDateTime(dt);
        
        WorkTestDataUtility.createCustomSettingRecords();
        
        RecordType propertyRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType='MDU_Property__c' AND Name = 'Xfinity Property Record Type' LIMIT 1];
        RecordType carActivityRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType='Task' AND Name = :Label.CARActivity LIMIT 1];
        RecordType taskRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType='Task' AND Name = 'Task' LIMIT 1];
        
        ConfigurableParameters__c knockMinutes = new ConfigurableParameters__c();
        knockMinutes.Name = 'KnockMinutes';
        knockMinutes.NumberValue__c = 2;
        insert knockMinutes;
        
        MDU_Property__c propertyObj = new MDU_Property__c();
        propertyObj.Name = 'Test Property';
        propertyObj.MDU_State__c = 'Indiana';
        propertyObj.System__c = '04 - Neptune Beach';
        propertyObj.RecordTypeId = propertyRecordType.Id;
        propertyObj.Contracting_Org_Type__c = 'None';
        propertyObj.Industry_Type__c = 'Commercial';
        insert propertyObj;
        
        Customer_Address__c address = new Customer_Address__c();
        address.Name = 'Test Address for Location';
        address.Latitude__c = 230.0500;
        address.Longitude__c = 300.0001;
        insert address;
        
        Location__c loc = new Location__c();
        loc.Latitude__c = address.Latitude__c;
        loc.Longitude__c = address.Longitude__c;
        loc.Geocode_TimeStamp__c = String.valueOf(System.Now());
        insert loc;
        
        List<Task> newTaskList = new List<Task>();
        Task tsk = new Task();
        tsk.Disposition__c='No Knock';
        tsk.Dwelling_Type__c='MDU';
        tsk.RecordTypeId = carActivityRecordType.Id;
        tsk.WhatId = propertyObj.Id;
        newTaskList.add(tsk);
        //insert tskList;
        
        Task locTask = new Task();
        locTask.Disposition__c='No Knock';
        locTask.Dwelling_Type__c='MDU';
        locTask.RecordTypeId = taskRecordType.Id;
        locTask.WhatId = address.Id;
        newTaskList.add(locTask);
        
        Database.insert(newTaskList,false);
        TaskTriggerController.updateDateCARField(newTaskList);
        TaskTriggerController.populateDispositionLocationandLocationDifference(newTaskList);

    }
  
    /*
    *  This method set permission set to user base on permissionSetName
    */ 
    static void AssignPermissionSet(String permissionSetName, Id userId){
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);
        
       
        
    }
      
      
      private static testMethod void metricUpdate(){
           WorkTestDataUtility.createCustomSettingRecords();
           String coachingRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('1:1 Coaching').getRecordTypeId();
           String teamHuddleRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Team Huddles').getRecordTypeId();
           String teamForumRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Team Forum').getRecordTypeId();
           String CarTeamHuddleRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CAR Team Huddle').getRecordTypeId();
           String CarTeamForumRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CAR Team Forum').getRecordTypeId();
           Profile xspProfile = [Select Id,UserType, UserLicenseId, Name From Profile where Name = 'XFINITY Sales Professional' LIMIT 1];
           Profile carManagerProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' LIMIT 1];
           List<GoalTemplateDates__c> goalDates = new List<GoalTemplateDates__c>();
           
            GoalTemplateDates__c templateDates1 = new GoalTemplateDates__c();
            templateDates1.Current_Period_Start_Date__c = Date.newinstance(2015, 6, 22);
            templateDates1.Current_Period_Due_Date__c = Date.newinstance(2015, 7, 21);
            templateDates1.Name = 'ActivityGoalCommissionCycle';
            goalDates.add(templateDates1);
            
            GoalTemplateDates__c templateDates2 = new GoalTemplateDates__c();
            templateDates2.Current_Period_Start_Date__c = Date.newinstance(2015, 6, 22);
            templateDates2.Current_Period_Due_Date__c = Date.newinstance(2015, 7, 21);
            templateDates2.Name = 'Property Lab CAR';
            goalDates.add(templateDates2);
            Database.insert(goalDates);
          
            //generate Random String 
            String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
            user xseUser = new User(Alias = 'DA_' + randomstr.substring(0,4),
                                        Email = randomstr + 'userTest@SampleTest.com',
                                        LastName='Testing',PERNR__c='10254424',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = xspProfile.Id,
                                        FederationIdentifier = 'FedId10'+randomstr,
                                        Username = 'userTest' + randomstr + '@SampleclassTest.com',EmployeeNumber = 'Emp' + randomstr.substring(0,4));
          insert xseUser;
          user sdmUser = WorkTestDataUtility.createDSSupervisorUserForCoaching(); 
          insert sdmUser;
          user xspUser = WorkTestDataUtility.createDSRepUserForCoaching();
          xspUser.ManagerId = sdmUser.Id;
          insert xspUser;
          
          user carDirUser =  new User(Alias = 'CAR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARDIR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = carManagerProfile.Id,
                                      Username = 'userTest1' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId1'+randomstr,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
                                        
         insert carDirUser;
          
         user carMgrUser = new User(Alias = 'CAR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest2@SampleTest.com',
                                      LastName='CARMGR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = carManagerProfile.Id,
                                      Username = 'userTest3' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId2'+randomstr, ManagerId = carDirUser.Id,
                                      EmployeeNumber = 'Emp2' + randomstr.substring(0,4));
          insert carMgrUser;
          
            
         User currentUser = [Select Id, ManagerId From User Where Id =: UserInfo.getUserId()];
          user xspUser2 = WorkTestDataUtility.createDSRepUserForCoaching();
          xspUser.ManagerId = currentUser.Id;
          insert xspUser2;
          
         System.runAs(currentUser){ 
             //AssignPermissionSet('Xfinity_Sales_Executive',xspUser.Id);
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Xfinity_Sales_Executive' ];
            PermissionSetAssignment psa1 = new PermissionSetAssignment();
            psa1.AssigneeId =  xspUser.Id;
            psa1.PermissionSetId = ps1.Id;
            Database.insert(psa1);
            AssignPermissionSet('SalesSpace_Coach_Access_XSP',xspUser.Id);
            AssignPermissionSet('SalesSpace_Coach_Access_SDM',sdmUser.Id);
            
    
           
            List<Goal> goalList = new List<Goal>();
            Goal goalObj1 = new Goal();
            goalObj1.Name = 'Test Goal1';
            goalObj1.OwnerId =  sdmUser.Id;
            goalObj1.Status = 'Published';
            goalObj1.StartDate =  templateDates1.Current_Period_Start_Date__c;
            goalObj1.DueDate = templateDates1.Current_Period_Due_Date__c;
            goalList.add(goalObj1);
            
            Goal goalObj2 = new Goal();
            goalObj2.Name = 'Test Goal2';
            goalObj2.OwnerId =  xspUser.Id;
            goalObj2.Status = 'Published';
            goalObj2.StartDate =  templateDates1.Current_Period_Start_Date__c;
            goalObj2.DueDate = templateDates1.Current_Period_Due_Date__c;
            goalList.add(goalObj2);
            
            Database.insert(goalList,false);
            
            List<Metric> metricList = new List<Metric>();
            Metric obj1 = new Metric();
            obj1.name = '1:1 Coaching';
            obj1.CurrentValue = 1;
            obj1.targetvalue = 4;
            obj1.goalId = goalObj1.id;
            obj1.ownerid = sdmUser.Id;
            metricList.add(obj1);
            
            Metric obj2 = new Metric();
            obj2.name = 'Team Huddles';
            obj2.CurrentValue = 1;
            obj2.targetvalue = 4;
            obj2.goalId = goalObj1.id;
            obj2.ownerid = sdmUser.Id;
            metricList.add(obj2);
            
            Metric obj3 = new Metric();
            obj3.name = 'Team Forums';
            obj3.CurrentValue = 1;
            obj3.targetvalue = 4;
            obj3.goalId = goalObj2.id;
            obj3.ownerid = xspUser.Id;
            metricList.add(obj3);
            
            Database.insert(metricList);
        }  
        List<Task> metricUpdateTaskList = new List<Task>();
        System.runAs(xspUser){
            Test.startTest();
            
            
            Task coachingTask = new Task();
            coachingTask.RecordTypeId = coachingRecordTypeId;
            coachingTask.OwnerId =xspUser.Id;
            coachingTask.Subject = 'test';
            coachingTask.Status = 'Completed';
            coachingTask.Priority = 'Normal';
            coachingTask.ActivityDate = System.Today();
            metricUpdateTaskList.add(coachingTask);
            
            Task teamHuddleTask = new Task();
            teamHuddleTask.RecordTypeId = teamHuddleRecordTypeId;
            teamHuddleTask.OwnerId =xspUser.Id;
            teamHuddleTask.Subject = 'test';
            teamHuddleTask.Status = 'Completed';
            teamHuddleTask.Priority = 'Normal';
            teamHuddleTask.ActivityDate = System.Today();
            metricUpdateTaskList.add(teamHuddleTask);
            
            Task teamForumTask = new Task();
            teamForumTask.RecordTypeId = teamForumRecordTypeId;
            teamForumTask.OwnerId =xseUser.Id;
            teamForumTask.Subject = 'test';
            teamForumTask.Status = 'Completed';
            teamForumTask.Priority = 'Normal';
            teamForumTask.ActivityDate = System.Today();
            metricUpdateTaskList.add(teamForumTask);
            
            Task carTeamHuddleTask = new Task();
            carTeamHuddleTask.RecordTypeId = CarTeamHuddleRecordTypeId;
            carTeamHuddleTask.OwnerId =xseUser.Id;
            carTeamHuddleTask.Subject = 'test';
            carTeamHuddleTask.Status = 'Completed';
            carTeamHuddleTask.Priority = 'Normal';
            carTeamHuddleTask.ActivityDate = System.Today();
            metricUpdateTaskList.add(carTeamHuddleTask);
            
             Task carTeamForumTask = new Task();
            carTeamForumTask.RecordTypeId = CarTeamForumRecordTypeId;
            carTeamForumTask.OwnerId =xseUser.Id;
            carTeamForumTask.Subject = 'test';
            carTeamForumTask.Status = 'Completed';
            carTeamForumTask.Priority = 'Normal';
            carTeamForumTask.ActivityDate = System.Today();
            metricUpdateTaskList.add(carTeamForumTask);
            
            Database.insert(metricUpdateTaskList,false);
        //taskTriggerController.createfeedpost(tkForum);
        Test.StopTest();
       }
       
            /*System.runAs(sdmUser){
            //Test.startTest();
            Task tkForum = new Task();
            tkForum.RecordTypeId = RecordTypeId2;
            tkForum.OwnerId =sdmUser.Id;
            tkForum.Subject = 'test';
            tkForum.Status = 'Completed';
            tkForum.Priority = 'Normal';
            tkForum.ActivityDate = System.Today();
            tkForum.Sales_Process__c = 'Other';
            tkForum.Comments__c = 'Test123';
            insert tkForum;
              Test.StopTest();   
            }*/
            
          
        
       
      }
       private static testMethod void metricUpdateForCarMgr(){
           WorkTestDataUtility.createCustomSettingRecords();
           String CarTeamHuddleRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CAR Team Huddle').getRecordTypeId();
           String CarTeamForumRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CAR Team Forum').getRecordTypeId();
           Profile carManagerProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' LIMIT 1];
           List<GoalTemplateDates__c> goalDates = new List<GoalTemplateDates__c>();
           
           
            GoalTemplateDates__c templateDates2 = new GoalTemplateDates__c();
            templateDates2.Current_Period_Start_Date__c = Date.newinstance(2015, 6, 22);
            templateDates2.Current_Period_Due_Date__c = Date.newinstance(2015, 7, 21);
            templateDates2.Name = 'Property Lab CAR';
            goalDates.add(templateDates2);
            Database.insert(goalDates);
          
            //generate Random String 
            String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
          user carDirUser =  new User(Alias = 'CAR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARDIR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = carManagerProfile.Id,
                                      Username = 'userTest1' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId1'+randomstr,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
                                        
         insert carDirUser;
          
         user carMgrUser = new User(Alias = 'CAR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest2@SampleTest.com',
                                      LastName='CARMGR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = carManagerProfile.Id,
                                      Username = 'userTest3' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId2'+randomstr, ManagerId = carDirUser.Id,
                                      EmployeeNumber = 'Emp2' + randomstr.substring(0,4));
          insert carMgrUser;
          
            
         User currentUser = [Select Id, ManagerId From User Where Id =: UserInfo.getUserId()];
         
          
         System.runAs(currentUser){ 
           
            AssignPermissionSet('SalesSpace_Coach_Access_CAR_Manager',carMgrUser.Id);
            AssignPermissionSet('Coach_CAR_Director_Manager',carDirUser.Id);
            
            List<Goal> goalList = new List<Goal>();
            Goal goalObj1 = new Goal();
            goalObj1.Name = 'Test Goal1';
            goalObj1.OwnerId =  carMgrUser.Id;
            goalObj1.Status = 'Published';
            goalObj1.StartDate =  templateDates2.Current_Period_Start_Date__c;
            goalObj1.DueDate = templateDates2.Current_Period_Due_Date__c;
            goalList.add(goalObj1);
            
           /*Goal goalObj2 = new Goal();
            goalObj2.Name = 'Test Goal2';
            goalObj2.OwnerId =  carMgrUser.Id;
            goalObj2.Status = 'Published';
            goalObj2.StartDate =  templateDates2.Current_Period_Start_Date__c;
            goalObj2.DueDate = templateDates2.Current_Period_Due_Date__c;
            goalList.add(goalObj2);*/
            
            Database.insert(goalList,true);
            
            List<Metric> metricList = new List<Metric>();
            Metric obj1 = new Metric();
            obj1.name = PL_Constants.METRIC_NAME_HUDDLES;
            obj1.CurrentValue = 1;
            obj1.targetvalue = 4;
            obj1.goalId = goalObj1.id;
            obj1.ownerid = carMgrUser.Id;
            metricList.add(obj1);
            
           /* Metric obj2 = new Metric();
            obj2.name = 'Team Huddles';
            obj2.CurrentValue = 1;
            obj2.targetvalue = 4;
            obj2.goalId = goalObj1.id;
            obj2.ownerid = sdmUser.Id;
            metricList.add(obj2);
            
            Metric obj3 = new Metric();
            obj3.name = 'Team Forums';
            obj3.CurrentValue = 1;
            obj3.targetvalue = 4;
            obj3.goalId = goalObj2.id;
            obj3.ownerid = xspUser.Id;
            metricList.add(obj3);
            */
            Database.insert(metricList);
        }  
        List<Task> metricUpdateTaskList = new List<Task>();
        System.runAs(carMgrUser){
            Test.startTest();
           
            Task carTeamHuddleTask = new Task();
            carTeamHuddleTask.CAR_Process__c = 'Create a Winning Strategy';
            carTeamHuddleTask.RecordTypeId = CarTeamHuddleRecordTypeId;
            carTeamHuddleTask.OwnerId =carMgrUser.Id;
            carTeamHuddleTask.Comments__c = 'test';
            carTeamHuddleTask.Description = 'test';
            carTeamHuddleTask.Subject = 'test';
            carTeamHuddleTask.Status = 'Completed';
            carTeamHuddleTask.Priority = 'Normal';
            carTeamHuddleTask.ActivityDate = System.Today();
            metricUpdateTaskList.add(carTeamHuddleTask);
            
             Task carTeamForumTask = new Task();
            carTeamForumTask.RecordTypeId = CarTeamForumRecordTypeId;
            carTeamForumTask.OwnerId =carMgrUser.Id;
            carTeamForumTask.Subject = 'test';
            carTeamForumTask.Comments__c = 'test123';
            carTeamForumTask.Description = 'test 123';
            carTeamForumTask.Status = 'Completed';
            carTeamForumTask.Priority = 'Normal';
            carTeamForumTask.ActivityDate = System.Today();
            metricUpdateTaskList.add(carTeamForumTask);
            
            Database.insert(metricUpdateTaskList,true);
        //taskTriggerController.createfeedpost(tkForum);
        Test.StopTest();
       }
       
      }
      
      private static testMethod void metricUpdateForCarDir(){
           WorkTestDataUtility.createCustomSettingRecords();
           String CarTeamHuddleRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CAR Team Huddle').getRecordTypeId();
           String CarTeamForumRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CAR Team Forum').getRecordTypeId();
           Profile carManagerProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' LIMIT 1];
           List<GoalTemplateDates__c> goalDates = new List<GoalTemplateDates__c>();
           
           
            GoalTemplateDates__c templateDates2 = new GoalTemplateDates__c();
            templateDates2.Current_Period_Start_Date__c = Date.newinstance(2015, 6, 22);
            templateDates2.Current_Period_Due_Date__c = Date.newinstance(2015, 7, 21);
            templateDates2.Name = 'Property Lab CAR';
            goalDates.add(templateDates2);
            Database.insert(goalDates);
          
            //generate Random String 
            String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1000)+'';
          user carDirUser =  new User(Alias = 'CAR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARDIR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = carManagerProfile.Id,
                                      Username = 'userTest1' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId1'+randomstr,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
                                        
         insert carDirUser;
          
         user carMgrUser = new User(Alias = 'CAR_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest2@SampleTest.com',
                                      LastName='CARMGR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = carManagerProfile.Id,
                                      Username = 'userTest3' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId2'+randomstr, ManagerId = carDirUser.Id,
                                      EmployeeNumber = 'Emp2' + randomstr.substring(0,4));
          insert carMgrUser;
          
            
         User currentUser = [Select Id, ManagerId From User Where Id =: UserInfo.getUserId()];
         
          
         System.runAs(currentUser){ 
           
            AssignPermissionSet('SalesSpace_Coach_Access_CAR_Manager',carMgrUser.Id);
            AssignPermissionSet('Coach_CAR_Director_Manager',carDirUser.Id);
            
            List<Goal> goalList = new List<Goal>();
            Goal goalObj1 = new Goal();
            goalObj1.Name = 'Test Goal1';
            goalObj1.OwnerId =  carDirUser.Id;
            goalObj1.Status = 'Published';
            goalObj1.StartDate =  templateDates2.Current_Period_Start_Date__c;
            goalObj1.DueDate = templateDates2.Current_Period_Due_Date__c;
            goalList.add(goalObj1);
            
           /*Goal goalObj2 = new Goal();
            goalObj2.Name = 'Test Goal2';
            goalObj2.OwnerId =  carMgrUser.Id;
            goalObj2.Status = 'Published';
            goalObj2.StartDate =  templateDates2.Current_Period_Start_Date__c;
            goalObj2.DueDate = templateDates2.Current_Period_Due_Date__c;
            goalList.add(goalObj2);*/
            
            Database.insert(goalList,true);
            
            List<Metric> metricList = new List<Metric>();
            Metric obj1 = new Metric();
            obj1.name = PL_Constants.METRIC_NAME_FORUM;
            obj1.CurrentValue = 1;
            obj1.targetvalue = 4;
            obj1.goalId = goalObj1.id;
            obj1.ownerid = carDirUser.Id;
            metricList.add(obj1);
            
           /* Metric obj2 = new Metric();
            obj2.name = 'Team Huddles';
            obj2.CurrentValue = 1;
            obj2.targetvalue = 4;
            obj2.goalId = goalObj1.id;
            obj2.ownerid = sdmUser.Id;
            metricList.add(obj2);
            
            Metric obj3 = new Metric();
            obj3.name = 'Team Forums';
            obj3.CurrentValue = 1;
            obj3.targetvalue = 4;
            obj3.goalId = goalObj2.id;
            obj3.ownerid = xspUser.Id;
            metricList.add(obj3);
            */
            Database.insert(metricList);
        }  
        List<Task> metricUpdateTaskList = new List<Task>();
        System.runAs(carDirUser){
            Test.startTest();
           
            Task carTeamHuddleTask = new Task();
            carTeamHuddleTask.CAR_Process__c = 'Create a Winning Strategy';
            carTeamHuddleTask.RecordTypeId = CarTeamHuddleRecordTypeId;
            carTeamHuddleTask.OwnerId =carDirUser.Id;
            carTeamHuddleTask.Comments__c = 'test';
            carTeamHuddleTask.Description = 'test';
            carTeamHuddleTask.Subject = 'test';
            carTeamHuddleTask.Status = 'Completed';
            carTeamHuddleTask.Priority = 'Normal';
            carTeamHuddleTask.ActivityDate = System.Today();
            metricUpdateTaskList.add(carTeamHuddleTask);
            
             Task carTeamForumTask = new Task();
            carTeamForumTask.RecordTypeId = CarTeamForumRecordTypeId;
            carTeamForumTask.OwnerId =carDirUser.Id;
            carTeamForumTask.Subject = 'test';
            carTeamForumTask.Comments__c = 'test123';
            carTeamForumTask.Description = 'test 123';
            carTeamForumTask.Status = 'Completed';
            carTeamForumTask.Priority = 'Normal';
            carTeamForumTask.ActivityDate = System.Today();
            metricUpdateTaskList.add(carTeamForumTask);
            
            Database.insert(metricUpdateTaskList,true);
        //taskTriggerController.createfeedpost(tkForum);
        Test.StopTest();
       }
       
      }
      
    
}