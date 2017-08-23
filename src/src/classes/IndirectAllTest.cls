//This test class coverage all indirect user story test methods.
@isTest
public with Sharing class IndirectAllTest {
    private static final String StoreActivityRecType = Schema.SObjectType.Store_Activity__c.getRecordTypeInfosByName().get('Target Rep Review').getRecordTypeId();
    private static TestMethod void Testmethod1() {
        //Test Data Setup
        WorkTestDataUtility.createCustomSettingRecords();
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c LeadTrigger= new TriggerSettings__c();
        LeadTrigger.Name= 'LeadTrigger';
        LeadTrigger.isActive__c = True;
        triggerSettingsList.add(LeadTrigger);
        insert triggerSettingsList;
        
        //TriggerSettings__c taskTriggerSettings = StoreTestUtility.createTriggerSettings('TaskTrigger');
        //insert taskTriggerSettings;
        
        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
        insert eventTriggerSettings;
        
        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;
        
        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;

        Store_Settings__c  storeCustomSet = new Store_Settings__c ();   
        storeCustomSet.Scheduled_Visit_Alert_Template__c= 'Notify_Store_Contact_of_Visit';
        insert storeCustomSet;
        
        TriggerSettings__c rGUOrderTriggerSettings = StoreTestUtility.createTriggerSettings('RGUOrderTrigger');
        insert rGUOrderTriggerSettings;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        Profile managerProf = [SELECT Id FROM Profile WHERE Name='Retail Sales Manager']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE DeveloperName='Xfinity_Sales_Rep'];
        User testManager = StoreTestUtility.createUser('storetestmanager@comcast.mi.com', managerProf.Id, 'SNManager');
        testManager.UserRole = role;
        insert testManager;
        
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        testUser.ManagerId =  testManager.Id;
        insert testUser;
        
        
        List<String> lookUpStrList = new List<String>{'Name of Reps and Manager on Duty Engaged','Name of Rgnl Mgr. and what was reviewed?'};
        
        Account testAccount = new Account ();
        testAccount.Name = 'Test Account';
        testAccount.OwnerId = testUser.id;
        testAccount.Store_Type__c = 'Best Buy';
        testAccount.BillingStreet ='TestStreet';
        testAccount.BillingCity = 'TestCity';
        testAccount.BillingState ='TestState'; 
        testAccount.BillingPostalCode= '12345'; 
        testAccount.BillingCountry ='TestCountry';
        insert testAccount;

        Contact testContact = StoreTestUtility.createContact(testAccount.Id);        
        List<Contact> unselectContactList = new List<Contact> ();
        unselectContactList.add(testContact);
        database.insert(unselectContactList,false);
        
        Contact testContact1 = StoreTestUtility.createContact(testAccount.Id);
        testContact1.Email= 'test@testmail.com';      
        List<Contact> lstCon = new List<Contact> ();
        lstCon.add(testContact1);
        database.insert(lstCon,false);
        
        Contact testContact2 = StoreTestUtility.createContact(testAccount.Id);
        testContact2 .Email= 'test@testmail.com';      
        List<Contact> lstCon1 = new List<Contact> ();
        lstCon1.add(testContact2 );
        database.insert(lstCon1,false);
       
        

        Store_Visit_Activity_Category__c testActivityCategory = StoreTestUtility.createActivityCategory('Kiosk', 'Xfinity_Sales_Rep');
        insert testActivityCategory;
        
        List<Store_Visit_Activity_Category__c> testCategory = [SELECT Id, Number_Required__c,Record_Type_Name__c,
                                                        Store_Activity_Category__c, Email_Template__c,
                                                        Send_Mail_Check_Field__c, Store_Type__c,Record_Type_Id__c,New_Records__c 
                                                        FROM Store_Visit_Activity_Category__c
                                                        WHERE Id = :testActivityCategory.id];

        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        storeVisit.End_Date_Time__c = null;       
        insert storeVisit;
        
        
        /*Store_Visit__c storeVisit1 = StoreTestUtility.createStoreVisit(testAccount.Id, testUser.Id, Datetime.now());
        storeVisit.End_Date_Time__c = null;
        insert storeVisit1;*/
        
        List<Store_Visit__c> storeVisitList = [SELECT Id,Number_of_Completed_Activities__c,                                               
                                               Store_Visit_Name__c, Notes__c, Total_Activities__c,
                                               Store_Visit_Status__c, Owner.Name, Start_Date_Time__c, Time_Spent__c 
                                               FROM Store_Visit__c WHERE Id = :storeVisit.id AND Completed_Formula__c = TRUE];
        
        
        
        IndirectStoreVisitHistory.getStoreVisitWrapper(testCategory,storeVisit.Id); 
        IndirectStore.getStoreVisitWrapper2(testCategory);
        
        
        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);    
        sA1.Who_did_you_meet_with__c = testContact.Id;
        sA1.What_is_the_store_s_focus_this_month__c = 'Accessories';
        sA1.Engagement_level_of_manager__c = '3';
        sA1.What_did_you_review_with_the_manager__c = 'Commissions, Incentives';
        sA1.RecordTypeId=StoreActivityRecType;
        sA1.Store__c = testAccount.id;        
        sA1.LastModifiedById = userinfo.getuserid();
        sA1.Store_Visit__c = storeVisit.Id;
        //sA1.store__c= testAccount.name;
        insert sA1;       
       
        
        Store_Activity__c confirmActivity = [SELECT Id, Is_Activity_Complete__c,Activity_Type__c, Who_did_you_meet_with__c, What_did_you_review_with_the_manager__c, Engagement_level_of_manager__c,
                                                    What_is_the_store_s_focus_this_month__c
                                             FROM Store_Activity__c
                                             WHERE Id = :sA1.Id];

        List<Store_Activity__c> storeActivities = new List<Store_Activity__c>();
        storeActivities.add(confirmActivity);
        
        Event objEvent = new Event ();
        objEvent.Whatid = testAccount.Id;
        objEvent.StartDateTime = System.Now();
        objEvent.EndDateTime = System.Now();
        objEvent.Subject = 'Call';
        insert objEvent;
        
        RGU_Order__c testRGUOrder1 = new RGU_Order__c();
        testRGUOrder1.Store_ID__c = '123456';
        testRGUOrder1.Affiliate__c = 'Test Affiliate Store';
        testRGUOrder1.Order_Date__c = System.Today().addDays(-1);
        testRGUOrder1.Activation_Date__c = System.Today().addDays(-1);
        testRGUOrder1.Activation_Date__c = System.Today().addDays(-1);
        testRGUOrder1.Activity_Status__c = 'Activated';
        
        RGU_Order__c testRGUOrder2 = new RGU_Order__c();
        testRGUOrder2.Store_ID__c = '0123456';
        testRGUOrder2.Affiliate__c = 'Test Affiliate Store2';
        testRGUOrder2.Order_Date__c = System.Today().addDays(-2);
        testRGUOrder2.Activation_Date__c = System.Today().addDays(-2);
        testRGUOrder2.Activity_Status__c = 'Activated';
        
        RGU_Order__c testRGUOrder3 = new RGU_Order__c();
        testRGUOrder3.Store_ID__c = '0123456';
        testRGUOrder3.Affiliate__c = 'Test Affiliate Store2';
        testRGUOrder3.Order_Date__c = System.Today().addDays(-3);
        testRGUOrder3.Activation_Date__c = System.Today().addDays(-3);
        testRGUOrder3.Activity_Status__c = 'Activated';
        
        
        RGU_Order__c testRGUOrder4 = new RGU_Order__c();
        testRGUOrder4.Store_ID__c = '0123456';
        testRGUOrder4.Affiliate__c = 'Test Affiliate Store2';
        testRGUOrder4.Affiliate__c = 'Test Affiliate Store2';
        testRGUOrder4.Order_Date__c = System.Today().addDays(-4);
        testRGUOrder4.Activation_Date__c = System.Today().addDays(-4);
        testRGUOrder4.Activity_Status__c = 'Activated';
        
        RGU_Order__c testRGUOrder5 = new RGU_Order__c();
        testRGUOrder5.Store_ID__c = '0123456';
        testRGUOrder5.Affiliate__c = 'Test Affiliate Store2';
        testRGUOrder5.Order_Date__c = System.Today().addDays(-5);
        testRGUOrder5.Activation_Date__c = System.Today().addDays(-5);
        testRGUOrder5.Activity_Status__c = 'Activated';
        
        RGU_Order__c testRGUOrder6 = new RGU_Order__c();
        testRGUOrder6.Store_ID__c = '0123456';
        testRGUOrder6.Affiliate__c = 'Test Affiliate Store2';
        testRGUOrder6.Order_Date__c = System.Today().addDays(-6);
        testRGUOrder6.Activation_Date__c = System.Today().addDays(-6);
        testRGUOrder6.Activity_Status__c = 'Activated';
        
        RGU_Order__c testRGUOrder7 = new RGU_Order__c();
        testRGUOrder7.Store_ID__c = '0123456';
        testRGUOrder7.Affiliate__c = 'Test Affiliate Store2';
        testRGUOrder7.Order_Date__c = System.Today().addDays(-7);
        testRGUOrder7.Activation_Date__c = System.Today().addDays(-7);
        testRGUOrder7.Activity_Status__c = 'Activated';
               
        List<RGU_Order__c> rGUOrders = new List<RGU_Order__c>();
        rGUOrders.add(testRGUOrder1);
        rGUOrders.add(testRGUOrder2);
        rGUOrders.add(testRGUOrder3);
        rGUOrders.add(testRGUOrder4);
        rGUOrders.add(testRGUOrder5);
        rGUOrders.add(testRGUOrder6);
        rGUOrders.add(testRGUOrder7);
        

        insert rGUOrders;
        
        ContentNote cn = new ContentNote();
        cn.title = 'Test Note';
        cn.Content = Blob.valueOf('Sample Test Data');
        insert cn;
        
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=storevisit.id;
        insert attach;

        
        
        //end of test Data Setup

        //IndirectStoreController Apex Class code coverage calling method.
        IndirectStoreController.getAllUserData();
     objEvent.Whatid = null;
     update objEvent;
     IndirectStoreController.getAllUserData();
        IndirectStoreController.saveEvent(objEvent.Subject,objEvent.StartDateTime,testAccount.Id);
        IndirectStoreController.getRole();
        IndirectStoreController.getCompletedActivities(storeVisit.Id);
        try{
            IndirectStoreController.getRecommendedCategories(testAccount,role);
        }catch(exception e){}
        //IndirectStoreController.sendMailToUser(testUser,testAccount.Id,'Test1,Test2,Test3,Test4,Test5', storeVisit, storeActivities);
        IndirectStoreController.setCachedData('visits',storeVisit.Id,testCategory,'no email','test',sA1.Id,'Name of Sales Rep');
         IndirectStoreController.setCachedData(null,null,null,null,null,null,null);
        IndirectStoreController.getCachedData();
       
        //StoreQueryUtilityLight Apex Class code coverage calling method.
        StoreQueryUtilityLight.queryStore(testAccount.Id);
        StoreQueryUtilityLight.queryUserRole(role.Id);
        StoreQueryUtilityLight.queryActivityCategories('Propsect',role.Name);
        StoreQueryUtilityLight.queryStoreActivities(storeVisit.Id);
        StoreQueryUtilityLight.queryRecordTypes('Store_Activity__c');
        
        //IndirectOrdersChart Apex Class code coverage calling method.
        IndirectOrdersChart.SeventhDayOrderCount=7;
        IndirectOrdersChart.SeventhDayActivationCount=7;
        IndirectOrdersChart.SixthDayOrderCount=6;
        IndirectOrdersChart.SixthDayActivationCount=7;
        IndirectOrdersChart.FourthDayOrderCount=4;
        IndirectOrdersChart.FourthDayActivationCount =4;
        IndirectOrdersChart.ThirdDayOrderCount =3;
        IndirectOrdersChart.ThirdDayActivationCount =3;
        IndirectOrdersChart.SecondDayOrderCount=2;
        IndirectOrdersChart.SecondDayActivationCount =2;
        IndirectOrdersChart objIndriect = new IndirectOrdersChart(rGUOrders);
        objIndriect.FifthDayOrderCount = 5;
        objIndriect.FifthDayActivationCount = 5;
        objIndriect.FirstDayActivationCount = 1;
        IndirectOrdersChart.pastSevenDaysList();
        IndirectOrdersChart.isOrderActivated(rGUOrders[0]);
        
        //IndirectAddContact Apex Class code coverage calling method.
        IndirectAddContact.displayContacts(testAccount.id);
        
        //IndirectAddContactWrapper Apex Class code coverage calling method.
        IndirectAddContactWrapper.getContacts(testAccount.id,storeVisit.Id);
         Visit_Contacts__c vc = new Visit_Contacts__c(Store_Visit__c = storeVisit.Id, Contact__c = lstCon1[0].Id, Status__c = 'Existing');
        insert vc;
        IndirectAddContactWrapper.saveContacts(lstCon1,storeVisit.Id);
        IndirectAddContactWrapper.deleteContacts(lstCon,storeVisit.Id);
        IndirectAddContactWrapper.AddContacttoVisitContact(testAccount,storeVisit);
        IndirectAddContactWrapper.getRecordType();
        
        //IndirectRequiredActivties Apex Class code coverage calling method.
        //IndirectRequiredActivties.getCategories(testAccount.id,'3PL','Xfinity_Sales_Rep');
        
        //IndirectStoreGaugeController Apex Class code coverage calling method.
        IndirectStoreGaugeController.getPastSevenDaysChart(testAccount.id); 
        IndirectStoreGaugeController.getOrders(testAccount.id); 
        
        //IndirectDashboardController.runReport();
        
        IndirectStoreVisitHistory.StoreVisitWrapper iSVW = new IndirectStoreVisitHistory.StoreVisitWrapper();
        iSVW.stv = storeVisit;
        iSVW.check = true;
        iSVW.onRepeat  = true;
        iSVW.checkActivity  = true;
        iSVW.onRepeatActivity  = true;
        iSVW.activityCount = 10; 
        
        IndirectStoreVisitHistory.ChildStoreVisitWrapper iSC = new IndirectStoreVisitHistory.ChildStoreVisitWrapper();
        iSC.sta =confirmActivity;
        IndirectStore.StoreVisitWrapper2 iSVWC = new IndirectStore.StoreVisitWrapper2();
        iSVWC.sta = confirmActivity;
          
        IndirectStoreVisitHistory.getStoreVisits(testAccount,role);
        IndirectStoreVisitHistory.getActivityDetails(testActivityCategory.Id, storeVisit.Id);       
        //IndirectStoreVisitWrapper.getRole();
        
        /*IndirectAddTaskController.getTaskData(testAccount.id);
        Task newTask = new Task();
        newTask.Description='abcd';
        newTask.ActivityDate = System.Today();
        insert newTask;
        IndirectAddTaskController.CreateTask(newTask,testAccount.id,'Not Started','Normal');*/
        
        Test.startTest();
            //IndirectAddTaskController.getRecommendedCategories(testAccount.id,testCategory,testUser.Id);
            //IndirectStore iS = new IndirectStore();
            //iS.IsProspectVisit = True;
            IndirectStore.getRole();
            system.runAs(testUser){
                IndirectStore.queryActiveStoreVisit(testAccount.id,34.23,12.54);
                IndirectStore.getActiveVisit(testAccount.id);
                IndirectStore.setCompletedStatus(testAccount.id);
                //IndirectStore.IsVisitActive(storeVisit);                      
                //IndirectStore.stopVisit(storeVisit,10,10);
                IndirectStore.updateStoreVisit(storeVisit,'abc');
                IndirectStore.queryActivityCategoriesForHistory('3PL','Xfinity_Sales_Rep');
                IndirectStore.createStoreActivity(sA1.RecordTypeId,storeVisit);
                IndirectStore.displayContacts(testAccount.id,storeVisit.Id);
                IndirectStore.getCompletedActivities(storeVisit.Id);
               // IndirectStore.getLatestStoreActivity(testUser.id,testAccount.id);
                //IndirectStore.getRecommendedCategories(testAccount.id,'3PL','Xfinity_Sales_Rep');
                IndirectStore.getCategories(testAccount.id,testCategory,testUser.id);
                IndirectStore.getRecommendedCategories(testAccount.id,testCategory,testUser.id);
                IndirectStore.stopVisitAndGetInCompletedActivities(testUser,testAccount.id,'Test Address',storeVisit,34.23,12.54,testCategory,testAccount);
                IndirectStore.isAutoCompletedStoreVisit(storeVisit.Id);
                //IndirectStore.getLatestStoreActivity(testUser.Id,testAccount.id);
                IndirectStore.getStoreDetails('3PL','Xfinity_Sales_Rep');
                IndirectStore.saveTheFile(storeVisit.id,'test','Base64','Text');
                IndirectStore.saveTheChunk(storeVisit,'test','Base64','Text',attach.id);
                 IndirectStore.saveTheChunk(storeVisit,'test','Base64','Text',null);
                IndirectStore.activeVisitCheck(storeVisit);
                IndirectStore.getAttachmentName(storeVisit);
                
                IndirectStoreController.queryActiveStoreVisit(testAccount.id,testUser);
                IndirectStoreController.getContacts(testAccount.id);
                IndirectStoreController.getContactsWrap(lstCon,storeVisit,testCategory,testAccount);
                IndirectStoreController.insertActivityContact(lstCon,unselectContactList,sA1.Id,'Name of Reps and Manager on Duty Engaged');
                IndirectStoreController.insertActivityContact(lstCon,unselectContactList,sA1.Id,'Name of Rgnl Mgr. and what was reviewed?');
                IndirectStoreController.insertActivityContact(unselectContactList,lstCon,sA1.Id,'Name of Rgnl Mgr. and what was reviewed?');
        IndirectStoreController.insertActivityContact(lstCon,unselectContactList,sA1.Id,'Name of Rgnl Mgr. and what was reviewed?');
         IndirectStoreController.insertActivityContact(lstCon,unselectContactList,sA1.Id,'Name of Reps and Manager on Duty Engaged');
                IndirectStore.DoActivityContactsExist(sA1.Id,lookUpStrList );
                IndirectStoreController.getContactsWithActivity(testAccount.Id,sA1.Id,'Name of Reps and Manager on Duty Engaged');
            }   
            //IndirectStore.getLatestStoreActivity(testUser.id,testAccount.id);
            //Report rep = [SELECT Id, DeveloperName FROM Report WHERE DeveloperName = 'Keystone_Test_Contacts_or_Accounts' Limit 1];
            //String str1 = rep.Id;
            //IndirectDashboardController.runReport();
            IndirectAddNoteController.saveNote(cn,'Note test','Content Var Data',testAccount.id);
            //Reports.ReportResults results = Reports.ReportManager.runReport(str1 , true);
            IndirectStoreController.deleteEventObj(objEvent);
        IndirectStoreController.deleteEventObj(objEvent);
        Test.stopTest();
        
        //IndirectRequiredActivties.getCategories(testAccount.id,'3PL','Xfinity_Sales_Rep');
    }
 private static TestMethod void Testmethod2() {
  String StoreActivityRecType1 = Schema.SObjectType.Store_Activity__c.getRecordTypeInfosByName().get('Big Box Manager Review').getRecordTypeId();
  String StoreActivityRecType2 = Schema.SObjectType.Store_Activity__c.getRecordTypeInfosByName().get('Big Box/Dealer Floor Review').getRecordTypeId();
    System.debug('in testmethod2');
     User currentUser = [Select Id from User where Id = :UserInfo.getUserId()];
    List<TriggerSettings__c> allTriggerSettings = new List<TriggerSettings__c>();
    TriggerSettings__c taskTriggerSettings = StoreTestUtility.createTriggerSettings('TaskTrigger');
    TriggerSettings__c UserTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
    TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
    TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger'); 
  
        allTriggerSettings.add(taskTriggerSettings);
    allTriggerSettings.add(storeActivityTriggerSettings);
        allTriggerSettings.add(UserTriggerSettings);
        allTriggerSettings.add(storeVisitTriggerSettings);
        insert allTriggerSettings;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE DeveloperName='Xfinity_Sales_Rep'];
        
        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRole = role;
        insert testUser;
        Account testAccount = new Account ();
        testAccount.Name = 'Test Account';
        testAccount.OwnerId = testUser.id;
        testAccount.Store_Type__c = 'VZW Corporate';
        testAccount.BillingStreet ='TestStreet';
        testAccount.BillingCity = 'TestCity';
        testAccount.BillingState ='TestState'; 
        testAccount.BillingPostalCode= '12345'; 
        testAccount.BillingCountry ='TestCountry';
        insert testAccount;
     
        Store_Visit__c storeVisit = StoreTestUtility.createStoreVisit(testAccount.Id, currentUser.Id, Datetime.now());
        storeVisit.End_Date_Time__c = null;       
        insert storeVisit;
        
        
        Store_Visit_Activity_Category__c testCategory = StoreTestUtility.createActivityCategory('VZW Corporate', 'Xfinity_Sales_Rep');
        insert testCategory;
        List<Store_Visit_Activity_Category__c> testCategorylist = new List<Store_Visit_Activity_Category__c>();
        testCategorylist.add(testCategory);
         IndirectStoreController.getRecommendedCategories(testAccount,role);
         IndirectStore.createStoreActivity(StoreActivityRecType2,storeVisit);
    Contact testContact = StoreTestUtility.createContact(testAccount.Id);
        Store_Activity__c sA1 = StoreTestUtility.createStoreActivity(storeVisit.Id);    
        sA1.Who_did_you_meet_with__c = testContact.Id;
        sA1.What_is_the_store_s_focus_this_month__c = 'Accessories';
        sA1.Engagement_level_of_manager__c = '3';
        sA1.What_did_you_review_with_the_manager__c = 'Commissions, Incentives';
        sA1.RecordTypeId=StoreActivityRecType1;
        sA1.Store__c = testAccount.id;        
        sA1.LastModifiedById = userinfo.getuserid();
        sA1.Store_Visit__c = storeVisit.Id;
    sA1.Is_Activity_Completed_New__c = true;
        //sA1.store__c= testAccount.name;
        insert sA1;  
    IndirectStore.stopVisitAndGetInCompletedActivities(testUser,testAccount.id,'Test Address',storeVisit,34.23,12.54,testCategorylist,testAccount);  
     IndirectStore.getLatestStoreActivity(currentUser.id,testAccount.id);
     
    IndirectStore.setCompletedStatus(testAccount.id);
        
        IndirectAddTaskController.getTaskData(testAccount.id);
        Task newTask = new Task();
        newTask.Description='abcd';
        newTask.ActivityDate = System.Today();
        insert newTask;
        IndirectAddTaskController.CreateTask(newTask,testAccount.id,'Not Started','Normal');
        IndirectAddTaskController.getRecommendedCategories(testAccount.id,testCategorylist,testUser.Id);
        storeVisit.End_Date_Time__c = Datetime.now();
        update storeVisit;
        System.debug('storeVisit.End_Date_Time__c'+storeVisit.End_Date_Time__c);
        Store_Visit__c oldStoreVisit = [SELECT Id, Store_Visit_Status__c
                                      FROM Store_Visit__c
                                      WHERE Store__c = :testAccount.Id                                       
                                      AND OwnerId = :currentUser.Id
                                      ORDER by LastModifiedDate Desc
                                      LIMIT 1];
                                      
                                      System.debug('oldStoreVisit in test class'+oldStoreVisit);
     testAccount.BillingPostalCode= '123456';
     update testAccount;
     
    //IndirectStore.stopVisitAndGetInCompletedActivities(testUser,testAccount.id,'Test Address',storeVisit,34.23,12.54,testCategory,testAccount);
      
 
 }
}