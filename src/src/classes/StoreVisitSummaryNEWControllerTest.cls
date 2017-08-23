@isTest 
    public class StoreVisitSummaryNEWControllerTest
    {
        private static final String StoreActivityRecType = Schema.SObjectType.Store_Activity__c.getRecordTypeInfosByName().get('Best Buy Manager Review New').getRecordTypeId();
        private static final String AccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId();
       static testMethod void StoreVisitMethod()
        {
           
            WorkTestDataUtility.createCustomSettingRecords();
            List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
            TriggerSettings__c LeadTrigger= new TriggerSettings__c();
            LeadTrigger.Name= 'LeadTrigger';
            LeadTrigger.isActive__c = True;
            
            TriggerSettings__c conTrigger= new TriggerSettings__c();
            conTrigger.Name= 'ContactTrigger';
            conTrigger.isActive__c = True;
            triggerSettingsList.add(conTrigger);
            insert triggerSettingsList;
            
            TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
            insert eventTriggerSettings;
            
            TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
            insert userTriggerSettings;
            
            TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
            insert storeVisitTriggerSettings;
    
            TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
            insert storeActivityTriggerSettings;
    
            Store_Settings__c  storeCustomSet = new Store_Settings__c ();   
            storeCustomSet .Scheduled_Visit_Alert_Template__c= 'Notify_Store_Contact_of_Visit';
            //insert storeCustomSet;
            
            TriggerSettings__c rGUOrderTriggerSettings = StoreTestUtility.createTriggerSettings('RGUOrderTrigger');
            insert rGUOrderTriggerSettings;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE DeveloperName='Xfinity_Sales_Rep'];
    
            User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
            testUser.UserRole = role;
            testUser.managerId = null;
            //testUser.Sales_Rep_Type__c = 'Dealer AE';
            insert testUser;
    
            Account testAccount = new Account ();
            testAccount.Name = 'Test Account';
            testAccount.OwnerId = testUser.id;
            testAccount.Store_Type__c = 'Best Buy';
            testAccount.BillingStreet ='TestStreet';
            testAccount.BillingCity = 'TestCity';
            testAccount.BillingState ='TestState'; 
            testAccount.BillingPostalCode= '12345'; 
            testAccount.BillingCountry ='TestCountry';
            testaccount.recordtypeId= AccountRecType ;
            testAccount.Is_Parent_Store__c = true;
            testAccount.Store_Location__Latitude__s = 41.175154;
            testAccount.Store_Location__Longitude__s = -85.143841;
            insert testAccount;
           
           
            Store_Visit__c storeVisit1 = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
            storeVisit1.End_Date_Time__c = system.now();
            storeVisit1.Store__c  = null;
            storeVisit1.Visit_Type__c = 'Training';
            //storeVisit1.Is_Auto_Check_Out__c = true;  
            insert storeVisit1;

            
            Store_Visit__c storeVisit2 = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
            TriggerSettings__c goaltriggerSetting = new TriggerSettings__c();
            goaltriggerSetting.name = 'StoreVisitTrigger';
            goaltriggerSetting.isActive__c= false;
            insert goaltriggerSetting;
            storeVisit2.Store__c  = testAccount.Id;  
            storeVisit2.Start_Date_Time__c = system.now();
            storeVisit2.End_Date_Time__c = null;
            //storeVisit2.Is_Auto_Check_Out__c = true; 
            insert storeVisit2;
                       
            List<Store_Visit__c> StoresVisitList = new List<Store_Visit__c> ();
            StoresVisitList.add(storeVisit1);
            StoresVisitList.add(storeVisit2);
            
            Contact testContact = StoreTestUtility.createContact(testAccount.Id);
        insert testContact;
        Contact testContact1 = StoreTestUtility.createContact(testAccount.Id);
        List<Contact>lstCon = new List<Contact> ();
        lstCon.add(testContact1);
        insert lstCon;
        
        Store_Visit_Activity_Category__c activityCategory = new Store_Visit_Activity_Category__c();
        activityCategory.Name = '140';
        activityCategory.Number_Required__c = 1;
        activityCategory.Record_Type_Name__c = 'Best_Buy_Manager_Review_New';
        activityCategory.Store_Activity_Category__c = 'Manager Review';
        activityCategory.Store_Type__c = 'Best Buy';
        activityCategory.User_Role__c = 'Xfinity_Sales_Rep';
        activityCategory.New_Records__c = True;
        insert activityCategory;
        
        Store_Activity__c sA1 = new Store_Activity__c();
        sA1.What_KPIs_did_you_review_with_the_Mgr__c = 'Nothing special';
        sA1.Any_feedback_concerns_from_the_Mgr__c = 'Accessories';
        sA1.RecordTypeId=StoreActivityRecType;
        sA1.store__c= testAccount.Id;
        sA1.Store_Visit__c = storeVisit2.Id;
        //sA1.Is_Activity_Complete__c = true;
        insert sA1;
        
        /*Visit_Contacts__c objVisitContact = new Visit_Contacts__c ();
        objVisitContact.Contact__c = testContact.Id;
        objVisitContact.Status__c = 'New';
        objVisitContact.Store_Visit__c = storeVisit2.Id;
        insert objVisitContact;*/

        Store_Activity__c confirmActivity = [SELECT Id, Is_Activity_Complete__c,Activity_Type__c
                                             FROM Store_Activity__c
                                             WHERE Id = :sA1.Id];

        List<Store_Activity__c> storeActivities = new List<Store_Activity__c>();
        storeActivities.add(confirmActivity);
        //insert storeActivities;
        
        storeVisit2.End_Date_Time__c = system.now();
        update storeVisit2;
        
               /* List<Store_Visit_Activity_Category__c> testCategory = [SELECT Id, Number_Required__c,Record_Type_Name__c,
                                                        Store_Activity_Category__c,New_Records__c,
                                                        Record_Type_Id__c
                                                        FROM Store_Visit_Activity_Category__c
                                                        WHERE Store_Type__c = 'Best Buy' AND User_Role__c = 'Xfinity_Sales_Rep' 
                                                        AND New_Records__c = true ORDER BY Number_Required__c DESC];*/
                                                        
            ApexPages.StandardController controller1 = new ApexPages.StandardController(storeVisit2); 
            StoreVisitSummaryNEWController mycls1 = new StoreVisitSummaryNEWController(controller1);
           // StoreVisitSummaryNEWController.finaldate = string.valueOf(system.today()+4);  
            StoreVisitSummaryNEWController.sendingTo =string.valueOf(system.today()+4).split('/');        
          //  StoreVisitSummaryNEWController.sendingEmail(StoresVisitList);
          //StoreVisitSummaryNEWController.automaticEmailAtMidnight(StoresVisitList);
            StoreVisitSummaryNEWController.ResendEmail();
            
            
            ApexPages.StandardController controller2 = new ApexPages.StandardController(storeVisit1); 
            StoreVisitSummaryNEWController mycls2 = new StoreVisitSummaryNEWController(controller2);
            mycls2.popupFlag = true;
            mycls2.displayPopup = true;
          //  StoreVisitSummaryNEWController.finaldate = string.valueOf(system.today()+4);  
            StoreVisitSummaryNEWController.sendingTo =string.valueOf(system.today()+4).split('/');        
          //  StoreVisitSummaryNEWController.sendingEmail(StoresVisitList);
            StoreVisitSummaryNEWController.ResendEmail();
            
        }
    }