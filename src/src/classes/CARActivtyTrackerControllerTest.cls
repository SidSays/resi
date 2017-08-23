@isTest
private class CARActivtyTrackerControllerTest {

    private static MDU_Property__c propertyForTest;
    private static CARActivityTrackerController controllerInstance;

    private static void setupTestData() {
        propertyForTest = TestDataUtility.createProperty();
        database.insert(propertyForTest);
        controllerInstance = new CARActivityTrackerController(new ApexPages.StandardController(propertyForTest));
    }

    static testMethod void CARActivityTrackerControllerTest() {
        WorkTestDataUtility.createCustomSettingRecords();
        PageReference pageRef = Page.CARActivityTracker;
        Test.setCurrentPage(pageRef);

        TriggerSettings__c taskTrigger = new TriggerSettings__c();
        taskTrigger.Name = 'TaskTrigger';
        taskTrigger.isActive__c = true;
        insert taskTrigger;
        TriggerSettings__c feedTrigger = new TriggerSettings__c();
        feedTrigger.Name = 'FeedItemTrigger';
        feedTrigger.isActive__c = True;
        insert feedTrigger;
        /*
         *  Create Task Record's for CAR Activity Record Type 
         */

        GoalTemplateDates__c goalTemplateDateCS = new GoalTemplateDates__c();
        goalTemplateDateCS.Name = 'Property Lab CAR';
        goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
        goalTemplateDateCS.Current_Period_Start_Date__c = System.Today().addDays(-2);
        Database.insert(goalTemplateDateCS);

        Task taskObject = new Task();
        taskObject.recordtypeid = Schema.SObjectType.Task.getRecordTypeInfosByName().get('CAR Activity').getRecordTypeId();
        taskObject.OwnerId = UserInfo.getUserId();
        taskObject.Subject = 'Call';
        taskObject.Status = 'Completed';
        taskObject.Priority = 'Normal';
        insert taskObject;

        List < Task > taskObj = new List < Task > ();
        Task task1 = WorkTestDataUtility.CreateTask();
        task1.Subject = 'Sales Event';
        task1.Status = 'Completed';
        taskObj.add(task1);
        Database.insert(taskObj, false);

        List < Bulk_Service__c > bs = new List < Bulk_Service__c > ();
        MDU_Property__c prop = TestDataUtility.createProperty();
        database.insert(prop);
        CARActivityTrackerController controller = new CARActivityTrackerController(new ApexPages.StandardController(prop));

        CARActivityTrackerController.CARActivity objActivity = new CARActivityTrackerController.CARActivity();
        List < CARActivityTrackerController.CARActivity > ActObj = new List < CARActivityTrackerController.CARActivity > ();
        objActivity.activityType = 'TestActivity';
        objActivity.done = true;
        objActivity.notes = 'TestNotes';
        ActObj.add(objActivity);

        CARActivityTrackerController.Params obj = new CARActivityTrackerController.Params();
        List < CARActivityTrackerController.Params > paramsObj = new List < CARActivityTrackerController.Params > ();
        obj.propertyId = prop.id;
        obj.latitude = 12.0;
        obj.longitude = 12.0;
        obj.activities = ActObj;
        // paramsObj.add(obj);
        Property_Visit__c pv = CARActivityTrackerController.checkIn(prop.Id, obj.latitude, obj.longitude);
        CARActivityTrackerController.saveActivities(obj);
        CARActivityTrackerController.createChatterPost(obj);
        //CARActivityTrackerController.addTask(taskObj);
        List < Property_Visit__c > result = CARActivityTrackerController.getPropertyVisit(prop.id);

    }

    public static testMethod void testGetTypeOptions() {

        setupTestData();
        List < CarActivitySettings__c > activitySettings = new List < CarActivitySettings__c > ();
        List < SelectOption > optionsDisplayed = null;
        CarActivitySettings__c value1 = new CarActivitySettings__c();
        value1.ActivityType__c = 'Customer Education (Non-Sales)';
        value1.CarActivityType__c = 'Event';
        value1.name = 'Value1';
        activitySettings.add(value1);

        value1 = new CarActivitySettings__c();
        value1.ActivityType__c = 'Sales';
        value1.CarActivityType__c = 'Event';
        value1.name = 'Value2';
        activitySettings.add(value1);

        value1 = new CarActivitySettings__c();
        value1.ActivityType__c = 'Scheduled';
        value1.CarActivityType__c = 'Visit';
        value1.name = 'Value3';
        activitySettings.add(value1);

        value1 = new CarActivitySettings__c();
        value1.ActivityType__c = 'Unscheduled';
        value1.CarActivityType__c = 'Visit';
        value1.name = 'Value4';
        activitySettings.add(value1);
        insert activitySettings;

        Test.startTest();
        controllerInstance.selectedCarActivityType = 'Event';
        optionsDisplayed = controllerInstance.getTypeOptions();
        System.assert(optionsDisplayed.size() == 3);

        controllerInstance.selectedCarActivityType = 'Visit';
        optionsDisplayed = controllerInstance.getTypeOptions();
        Test.stopTest();
        System.assert(optionsDisplayed.size() == 3);

    }

    public static testMethod void testGetCARActivityTypeOptions() {

        setupTestData();

        List < SelectOption > optionsDisplayed = null;
        Schema.DescribeFieldResult dfr = Task.CAR_Activity_Type__c.getDescribe();
        List < Schema.PicklistEntry > entries = dfr.getPickListValues();
        Test.startTest();
        optionsDisplayed = controllerInstance.getCARActivityTypeOptions();
        Test.stopTest();
        System.assert(optionsDisplayed.size() == entries.size() + 1);

    }

    public static testMethod void testGetVisitPlanOptions() {

        setupTestData();
        List < SelectOption > optionsDisplayed = null;
        Schema.DescribeFieldResult dfr = Property_Visit__c.Visit_Plan__c.getDescribe();
        List < Schema.PicklistEntry > entries = dfr.getPickListValues();
        optionsDisplayed = controllerInstance.getVisitPlanOptions();
        System.assert(optionsDisplayed.size() == entries.size());

    }

    public static testMethod void testPopulateExistingVisitForProperty() {
        TriggerSettings__c taskTrigger = new TriggerSettings__c();
        taskTrigger.Name = 'PropertyTrigger';
        taskTrigger.isActive__c = false;
        insert taskTrigger;

        taskTrigger = new TriggerSettings__c();
        taskTrigger.Name = 'PropertyVisitTrigger';
        taskTrigger.isActive__c = false;
        insert taskTrigger;

        setupTestData();
        User carUser = TestDataUtility.createXfinityCARUser();

        taskTrigger = new TriggerSettings__c();
        taskTrigger.Name = 'EventTrigger';
        taskTrigger.isActive__c = false;
        insert taskTrigger;

        Property_Visit__c propVisit1 = new Property_Visit__c();
        propVisit1.Name = 'Test prop visit';
        propVisit1.Property__c = propertyForTest.Id;
        propVisit1.CreatedById = carUser.Id;
        propVisit1.Start_Date_Time__c = DateTime.now();
        insert propVisit1;

        Event event = new Event();
        event.WhatId = propertyForTest.Id;
        event.subject = 'Test Event';
        event.StartDateTime = System.now();
        event.EndDateTime = System.now() + 10;
        event.Property_Visit__c = propVisit1.id;
        event.OwnerId = carUser.Id;
        event.CAR_Activity_Type__c = 'Visit';
        insert event;


        Test.startTest();
        system.runAs(carUser) {
            controllerInstance.populateExistingVisitForProperty();
        }

        Test.stopTest();
    }

    public static testMethod void testCheckInWithPropertyVisit() {
        User carUser = TestDataUtility.createXfinityCARUser();
        system.runAs(carUser) {
            MDU_Property__c prop = TestDataUtility.createProperty();
            database.insert(prop);

            Property_Visit__c propVisit1 = new Property_Visit__c();
            propVisit1.Name = 'Test prop visit';
            propVisit1.Property__c = prop.Id;
            propVisit1.CreatedById = carUser.Id;
            propVisit1.Start_Date_Time__c = DateTime.now();
            insert propVisit1;

            Test.startTest();
            Property_Visit__c pv = CARActivityTrackerController.checkIn(prop.Id, 12, 12);
            Test.stopTest();

        }
    }

    public static testMethod void testSaveActivitesForExistingPropVisit() {
        User carUser = TestDataUtility.createXfinityCARUser();
        system.runAs(carUser) {
            MDU_Property__c prop = TestDataUtility.createProperty();
            database.insert(prop);

            Property_Visit__c propVisit1 = new Property_Visit__c();
            propVisit1.Name = 'Test prop visit';
            propVisit1.Property__c = prop.Id;
            propVisit1.CreatedById = carUser.Id;
            propVisit1.Start_Date_Time__c = DateTime.now();
            insert propVisit1;

            CARActivityTrackerController.CARActivity objActivity = new CARActivityTrackerController.CARActivity();
            CARActivityTrackerController.CARActivity objActivity1 = new CARActivityTrackerController.CARActivity();
            List < CARActivityTrackerController.CARActivity > ActObj = new List < CARActivityTrackerController.CARActivity > ();
            objActivity.activityType = 'Drop Off Materials';
            objActivity.done = true;
            objActivity.notes = 'TestNotes';
            objActivity.qtyCount = 2;
            ActObj.add(objActivity);

            objActivity1.activityType = 'Education';
            objActivity1.done = true;
            objActivity1.notes = 'TestNotes';
            objActivity1.lunchAndLearnDone = true;
            ActObj.add(objActivity1);

            CARActivityTrackerController.Params obj = new CARActivityTrackerController.Params();
            obj.propertyId = prop.id;
            obj.latitude = 12.0;
            obj.longitude = 12.0;
            obj.activities = ActObj;
            obj.propertyVisitId = propVisit1.Id;

            Test.startTest();
            Property_Visit__c pv = CARActivityTrackerController.checkIn(prop.Id, obj.latitude, obj.longitude);
            CARActivityTrackerController.saveActivities(Obj);

            Test.stopTest();

        }
    }
    
    public static testMethod void testValidation() {
        User carUser = TestDataUtility.createXfinityCARUser();
        system.runAs(carUser) {
            MDU_Property__c prop = TestDataUtility.createProperty();
            database.insert(prop);
            
            CARActivityTrackerController.CARActivity objActivity = new CARActivityTrackerController.CARActivity();
            CARActivityTrackerController.CARActivity objActivity1 = new CARActivityTrackerController.CARActivity();
            List < CARActivityTrackerController.CARActivity > ActObj = new List < CARActivityTrackerController.CARActivity > ();
            objActivity.activityType = 'Drop Off Materials';
            objActivity.done = true;
            objActivity.notes = 'TestNotes';
            objActivity.qtyCount = 2;
            ActObj.add(objActivity);

            objActivity1.activityType = 'Education';
            objActivity1.done = true;
            objActivity1.notes = 'TestNotes';
            objActivity1.lunchAndLearnDone = true;
            ActObj.add(objActivity1);

            CARActivityTrackerController.Params obj = new CARActivityTrackerController.Params();
            obj.propertyId = prop.id;
            obj.latitude = 12.0;
            obj.longitude = 12.0;
            obj.activities = ActObj;
            obj.propertyVisitId = null;

            Test.startTest();
            Property_Visit__c pv = CARActivityTrackerController.checkIn(prop.Id, obj.latitude, obj.longitude);
            CARActivityTrackerController.saveActivities(Obj);

            Test.stopTest();

        }
    }


    public static testMethod void testcheckScheduledVisit() {

        setupTestData();

        controllerInstance.selectedCarActivityType = 'Visit';
        controllerInstance.selectedTypeOption = 'Scheduled';

        Test.startTest();
        controllerInstance.checkScheduledVisit();
        controllerInstance.visitDetailOptionValue();
        Test.stopTest();

    }

}