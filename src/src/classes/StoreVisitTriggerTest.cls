/**
*   Tests for store visit trigger
*
*   @author Sahil Grover    <sgrover@acumensolutions.com>
*/
@isTest
private class StoreVisitTriggerTest {
    
    @isTest static void testPopulateStore() {
        TriggerSettings__c userTriggerSettings = StoreTestUtility.createTriggerSettings('UserTrigger');
        insert userTriggerSettings;
        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;
        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User testUser = StoreTestUtility.createUser('testUser@test.comcast.com', p.Id, 'cTestUser');
        insert testUser;
        
        String str = 'Store';
        Account testStore = new Account();
        testStore.Name = 'Test Account';
        testStore.OwnerId = testUser.id;
        testStore.Store_Location__Latitude__s = 37.776114;
        testStore.Store_Location__Longitude__s = -122.417047;
        testStore.Store_Type__c = 'Best Buy';
        testStore.Parent_Account_Dropdown__c = 'Best Buy';
        testStore.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(str).getRecordTypeId();
        insert testStore;
        
       // Account testStore = StoreTestUtility.createAccount(testUser.Id);
        //insert testStore;
        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testStore.Id, testUser.Id);
        insert testStoreVisit;
        
        
        Store_Visit__c testStoreVisit1 = new Store_Visit__c();
        //testStoreVisit1.OwnerId = testUser.id;
        testStoreVisit1.Is_Auto_Check_Out__c = false;
        testStoreVisit1.Start_Date_Time__c = system.now().addHours(-2);
        testStoreVisit1.Completed_all_required_activities__c = false;
        testStoreVisit1.visit_cutoff_datetime__c = system.now();
        testStoreVisit1.End_Date_Time__c = testStoreVisit1.visit_cutoff_datetime__c;
        testStoreVisit1.Store__c = testStore.id;
        insert testStoreVisit1;
        
        Store_Activity__c testStoreActivity = StoreTestUtility.createStoreActivity(testStoreVisit.Id);

        Test.startTest();
            insert testStoreActivity;
        Test.stopTest();

        Store_Activity__c confirmStoreActivity = [SELECT Store__c FROM Store_Activity__c WHERE Id = :testStoreActivity.Id];
        System.assertEquals(testStore.Id, confirmStoreActivity.Store__c, 'The Store lookup was not set properly on the Store Activity record.');
    }

    @isTest static void testRemoveEventOnInsert() {
       
        TriggerSettings__c eventTriggerSettings = StoreTestUtility.createTriggerSettings('EventTrigger');
        insert eventTriggerSettings;
        TriggerSettings__c storeVisitTriggerSettings = StoreTestUtility.createTriggerSettings('StoreVisitTrigger');
        insert storeVisitTriggerSettings;
        TriggerSettings__c storeActivityTriggerSettings = StoreTestUtility.createTriggerSettings('StoreActivityTrigger');
        insert storeActivityTriggerSettings;
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
          
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = false;
        triggerSettingsList.add(userTrigger);
         
        TriggerSettings__c metricTrigger = new TriggerSettings__c();
        metricTrigger.Name = 'MetricTrigger';
        metricTrigger.isActive__c = false;
        triggerSettingsList.add(metricTrigger);
        
        TriggerSettings__c goalTrigger = new TriggerSettings__c();
        goalTrigger.Name = 'GoalTrigger';
        goalTrigger.isActive__c = false;
        triggerSettingsList.add(goalTrigger);
        
        Database.insert(triggerSettingsList,false);
        
        
        GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
             goalTemplateDateCS.Name = 'IndirectActivityGoalCycle';
             goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(2);
             goalTemplateDateCS.Current_Period_Start_Date__c = System.Today();
             Database.insert(goalTemplateDateCS);

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
		Profile p1 = [SELECT Id FROM Profile WHERE Name='Retail Sales Rep']; 
		Profile p2 = [SELECT Id FROM Profile WHERE Name='Retail Sales Manager']; 
		List<User> userList = new List<User>();
		User testUser = StoreTestUtility.createUser('testUser@test.comcast.com', p.Id, 'cTestUser');
		userList.add (testUser);
        
		User RetailSalesManager = StoreTestUtility.createUser('RetailSalesManager@test.comcast.com', p2.Id, 'cRetailSalesManager');
        RetailSalesManager.UserPermissionsWorkDotComUserFeature = true;
        RetailSalesManager.IsActive = true;
        userList.add (RetailSalesManager);
        
		User RetailSalesRep = StoreTestUtility.createUser('RetailSalesRep@test.comcast.com', p1.Id, 'cRetailSalesRep');
        RetailSalesRep.ManagerId = RetailSalesManager.Id;
        RetailSalesRep.UserPermissionsWorkDotComUserFeature = true;
        RetailSalesRep.IsActive = true;
        userList.add (RetailSalesRep);
		
		database.insert (userList);
		
		Variable_Setting__c objvariable = new Variable_Setting__c();
        objvariable.Name ='RetailSalesRepProfileId' ;
        objvariable.Description__c = 'Custom setting for Retail Sales Rep profile';
        objvariable.Value__c = '00eG0000000GfdaIAC';
        database.insert (objvariable);
		
		system.runAs(new User(id = UserInfo.getUserId())){
		PermissionSet rsp = [SELECT Id FROM PermissionSet where Name = 'SalesSpace_Coach_Access_Retail_Rep'];
		PermissionSet rsm = [SELECT Id FROM PermissionSet where Name = 'SalesSpace_Coach_Access_Retail_Sales_Manager'];
		
		List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
		PermissionSetAssignment psa1 = new PermissionSetAssignment();
		psa1.AssigneeId = RetailSalesRep.Id;
		psa1.PermissionSetId = rsp.Id;
		psaList.add (psa1);
		PermissionSetAssignment psa2 = new PermissionSetAssignment();
		psa2.AssigneeId = RetailSalesManager.Id;
		psa2.PermissionSetId = rsm.Id;
		psaList.add (psa2);
		
		database.insert(psaList);
		
		Goal goalObjectRepTest = WorkTestDataUtility.createGoal();
         goalObjectRepTest.OwnerId = RetailSalesRep.Id;
         goalObjectRepTest.RecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Indirect Sales').getRecordTypeId();
         goalObjectRepTest.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
         goalObjectRepTest.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c;
         goalObjectRepTest.status = 'Published';
            
         update goalObjectRepTest;
            
        Goal goalObjectMgrTest = WorkTestDataUtility.createGoal();
         goalObjectMgrTest.OwnerId = RetailSalesManager.Id;
         goalObjectMgrTest.RecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Indirect Sales').getRecordTypeId();
         goalObjectMgrTest.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
         goalObjectMgrTest.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c;
         goalObjectMgrTest.status = 'Published';
         
         update goalObjectMgrTest;

        List<Metric> merticListRep = new List<Metric>();
        List<Metric> merticListMgr = new List<Metric>();
        for(integer i=0; i<2; i++){
            Metric MetricObj = new Metric();
            Metric MetricMgrObj = new Metric();
            MetricObj.goalId = goalObjectRepTest.id;
            MetricObj.Ownerid = RetailSalesRep.Id;
            MetricMgrObj.goalId = goalObjectMgrTest.id;
            MetricMgrObj.Ownerid = RetailSalesManager.Id;
            if(i==0){
                MetricObj.Name = 'Total Number of Store Visits'; 
                MetricObj.TargetValue = 40;
                MetricObj.Currentvalue = 1;
                MetricMgrObj.Name = 'Total Number of Store Visits';
                MetricMgrObj.TargetValue = 40;
                MetricMgrObj.Currentvalue = 1;
            }
            else if(i==1){
                MetricObj.Name = 'Average Store Visit Duration';
                MetricObj.TargetValue = 60;
                MetricObj.Currentvalue = 60;  
                MetricMgrObj.Name = 'Average Store Visit Duration';
                MetricMgrObj.TargetValue = 60;
                MetricMgrObj.Currentvalue = 60;
            }
            
            merticListRep.add(MetricObj);
            merticListMgr.add(MetricMgrObj);
        }
        Database.Insert(merticListRep);
        Database.Insert(merticListMgr);
		
		List <Account> storeList = new List<Account> ();
        Account testStore = StoreTestUtility.createAccount(testUser.Id);
        storeList.add (testStore);
        Account testStore1 = StoreTestUtility.createAccount(RetailSalesRep.Id);
        storeList.add (testStore1);
        
        database.insert(storeList);
        
        Store_Settings__c storeSettings = Store_Settings__c.getInstance();
        storeSettings.Scheduled_Visit_Alert_Template__c = 'TestVisitAlert';
        insert storeSettings;
        
            Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Retail_Sales_Emails'];
            //EmailTemplate alertTemplate = StoreTestUtility.createEmailTemplate(storeSettings, folder.Id);
            EmailTemplate testEmailTemplate = new EmailTemplate();
            testEmailTemplate.DeveloperName = storeSettings.Scheduled_Visit_Alert_Template__c;
            testEmailTemplate.Name ='TestEmailTemplate';
            testEmailTemplate.FolderId = folder.Id;
            testEmailTemplate.TemplateType ='text';
            testEmailTemplate.Body = 'Test Email Body';
            testEmailTemplate.HtmlValue = 'Test HTML Email Body';
            insert testEmailTemplate;
            
        Event event = StoreTestUtility.createEvent(testUser.Id, testStore.Id, Datetime.now());
        insert event;
        
        Store_Visit__c testStoreVisit = StoreTestUtility.createStoreVisit(testStore.Id, testUser.Id, DateTime.now());
        testStoreVisit.End_Date_Time__c = null;
        
        List<Event> confirmEvent = [SELECT Id, Is_Visit_Complete__c FROM EVENT WHERE AccountId = :testStore.Id];
        //System.assert(confirmEvent.Is_Visit_Complete__c, 'Event status should be complete');
        
        Store_Visit__c testStoreVisit2 = StoreTestUtility.createStoreVisit(testStore1.Id, RetailSalesRep.Id, DateTime.now());
        testStoreVisit2.End_Date_Time__c = null;
        testStoreVisit2.CreatedById = RetailSalesRep.id;
        insert testStoreVisit2;
        testStoreVisit2 = [Select Id, OwnerId, CreatedById, CreatedBy.ManagerId, Is_Auto_Check_Out__c, Start_Date_Time__c,
                          End_Date_Time__c, Visit_Type__c from Store_Visit__c where OwnerId = :RetailSalesRep.id];
        testStoreVisit2.End_Date_Time__c = system.now().addHours(+2);
        testStoreVisit2.CreatedBy.ManagerId = RetailSalesRep.id;
        update testStoreVisit2;
       }
      
      Test.startTest();
       system.runAs (RetailSalesRep){
        List<Store_Visit__c> storeVisitList = new List<Store_Visit__c>();
        Store_Visit__c testStoreVisit1 = new Store_Visit__c();
        testStoreVisit1.OwnerId = RetailSalesRep.id;
        testStoreVisit1.CreatedById = RetailSalesRep.id;
        //testStoreVisit1.CreatedBy.ManagerId = RetailSalesManager.Id;
        testStoreVisit1.Is_Auto_Check_Out__c = false;
        testStoreVisit1.Start_Date_Time__c = system.now().addHours(-2);
        testStoreVisit1.End_Date_Time__c = system.now();
        testStoreVisit1.Visit_Type__c = 'Training';
        storeVisitList.add(testStoreVisit1);
        
        database.insert (storeVisitList);
       
       }

      Test.stopTest();
	}
 }