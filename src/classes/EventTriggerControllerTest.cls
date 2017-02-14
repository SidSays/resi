@isTest
/***********************************************************
* Class Name: EventTriggerControllerTest
* Author: Amitkumar Bangad, Accenture
* Date: 27-Dec-2012 
* * Description: This class does the test coverage
*              for EventTriggerController class.
***********************************************************/
private class EventTriggerControllerTest{
    static Opportunity opp;
    static Lead ld,ld1;
    static List<Lead> leadList;
    Static user integrationUser;
     
            
    /* This method is creates data for code coverage*/
    private static void setupData() {
        
        
        
            WorkTestDataUtility.createCustomSettingRecords();
        
            List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
            
            TriggerSettings__c LeadTrigger= new TriggerSettings__c();
            LeadTrigger.Name= 'LeadTrigger';
            LeadTrigger.isActive__c = True;
            triggerSettingsList.add(LeadTrigger);
            insert triggerSettingsList;
            
            TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
             insert eventTriggerSettings;

            Store_Settings__c  storeCustomSet = new Store_Settings__c ();   
            storeCustomSet .Scheduled_Visit_Alert_Template__c= 'Notify_Store_Contact_of_Visit';
            insert storeCustomSet  ;
            
            
            TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
            insert storeVisitTriggerSettings;
            
            String FolId = UserInfo.getOrganizationId();
            
            EmailTemplate e = new EmailTemplate (Name = 'EmailTemplateForEvent', DeveloperName = 'EmailTemplateForEvent',FolderId = FolId, Subject='Meeting',
            TemplateType= 'Text'); 
            insert(e);  
            system.debug('****** email template *****'+e);
            
            
            GoalTemplateDates__c obj = new GoalTemplateDates__c();
            obj.Name = 'Property Lab CAR';
            obj.Current_Period_Due_Date__c = Date.parse('4/21/2016');
            obj.Current_Period_Start_Date__c = date.parse('3/22/2016');
            insert obj;
            
                            
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
       /**     Contact partContact = new Contact();
            partContact.AccountId = partAcc.Id;
            partContact.lastName = 'Test Contact';
            insert partContact; **/

            // fetch the Integration user profile
            List<Profile> p = [Select id,UserType, UserLicenseId, Name From Profile where Name like '%Integration%' ];
            UserRole role=[Select Id From UserRole WHERE Name='Comcast: Residential'];

            //generate Random String 
            User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
            system.runAs(currentUser){
            String randomstr = Math.round(Math.random()*Math.pow(10, 7))+'';
            integrationUser = new User(Alias = 'DA_' + randomstr.substring(0,4),
                                        Email = randomstr + 'userTest@SampleTest.com',
                                        LastName='Testing',
                                        EmailEncodingKey='UTF-8', 
                                        LanguageLocaleKey='en_US', 
                                        LocaleSidKey='en_US', 
                                        TimeZoneSidKey='America/Los_Angeles',
                                        ProfileId = p[0].Id,
                                        FederationIdentifier = 'FedId1'+randomstr,
                                        Username = 'userTest' + randomstr + '@SampleclassTest.com',
                                        UserRoleId=role.Id,
                                        EmployeeNumber = 'Emp' + randomstr.substring(0,4));
            insert integrationUser;
            }

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
            insert leadList;
            system.debug('gggggggggg' +ld.Id);
    }
    
     /* This method is used for test coverage of Positive scenarios EventTriggerController class*/

    private static testMethod void eventTriggerControllerPositiveTest() {
    
        
        
        User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
        system.runAs(currentUser)
        {
        setupData();
        Test.startTest();
        
        // Insert Event in System on Lead Generated by Comcast Internal
        List<Event> eveList = new List<Event>();
        Event ev = new Event();
        ev.OwnerId = UserInfo.getUserId();
        ev.whoId = ld.Id;
        ev.Subject = 'test';
        ev.StartDateTime = System.now();
        ev.EndDateTime = System.now() + 10;
        insert ev;
        eveList.add(ev);
        
        EventTriggerController.restrictEventDelete(eveList);
        
        

        //Verify that time to touch is captured
        lead touchedLead = [Select Id, Name, Time_To_Touch__c, FirstModifiedDate__c, 
                            FirstModifiedBy__c from Lead where Id=:ld.id];
       
        System.AssertEquals(touchedLead.Time_To_Touch__c == 0, true);  
        System.AssertEquals(touchedLead.FirstModifiedDate__c == null, false);  
        System.AssertEquals(touchedLead.FirstModifiedBy__c == null, false);               
        Test.stopTest();
        }
    }
    /* This method is used for test coverage of Negative scenarios EventTriggerController class*/

    private static testMethod void eventTriggerControllerNegativeTest() {
    
    
        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
         insert eventTriggerSettings;

        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;

        String FolId = UserInfo.getOrganizationId();

        EmailTemplate e = new EmailTemplate (Name = 'EmailTemplateForEvent', DeveloperName = 'EmailTemplateForEvent',FolderId = FolId, Subject='Meeting',
        TemplateType= 'Text'); 
        Database.Insert(e,false);

        User currentUser=[Select Id From User WHERE Id=:UserInfo.getUserId()];
        system.runAs(currentUser){
        setupData();
      
      Test.startTest();
        
        // Insert Event in System on Lead Generated by Affiliate & Ownership not yet transfered
        List<Event> evList1 = new List<Event>();
        Event ev1 = new Event();
        ev1.OwnerId = UserInfo.getUserId();
        ev1.whoId = ld1.Id;
        ev1.Subject = 'test';
        ev1.Event_Status__c='Completed';
        ev1.StartDateTime = System.now();
        ev1.EndDateTime = System.now() + 10;
        insert ev1;
        evList1.add(ev1);
        
        EventTriggerController.restrictEventDelete(evList1);
        
        
        //Verify time to touch is not captured
        lead touchedLead = [Select Id, Name, Time_To_Touch__c, FirstModifiedDate__c, 
                            FirstModifiedBy__c from Lead where Id=:ld.id];
       
        System.AssertEquals(touchedLead.Time_To_Touch__c == null, true);  
        System.AssertEquals(touchedLead.FirstModifiedDate__c == null, true);  
        System.AssertEquals(touchedLead.FirstModifiedBy__c == null, true); 
        
        Test.stopTest(); 
        
     }
    }  
}