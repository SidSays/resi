@isTest
private class CARActivtyTrackerControllerTest {
    static testMethod void CARActivityTrackerControllerTest(){
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
        
        GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
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
        
        List<Task> taskObj = new List<Task>();
             Task task1 = WorkTestDataUtility.CreateTask();
             task1.Subject= 'Sales Event';
             task1.Status= 'Completed';
             taskObj.add(task1);
             Database.insert(taskObj,false);

        List<Bulk_Service__c> bs = new List<Bulk_Service__c>();
             MDU_Property__c prop = TestDataUtility.createProperty();
             database.insert(prop);
             CARActivityTrackerController controller = new CARActivityTrackerController(new ApexPages.StandardController(prop));
  
        CARActivityTrackerController.CARActivity objActivity = new CARActivityTrackerController.CARActivity();
        List<CARActivityTrackerController.CARActivity> ActObj = new List<CARActivityTrackerController.CARActivity>();
             objActivity.activityType = 'TestActivity';
             objActivity.done = true;
             objActivity.notes = 'TestNotes';
             ActObj.add(objActivity);
        
        CARActivityTrackerController.Params obj = new CARActivityTrackerController.Params();   
        List<CARActivityTrackerController.Params> paramsObj = new List<CARActivityTrackerController.Params>();
             obj.propertyId = prop.id;
             obj.latitude= 12.0;
             obj.longitude= 12.0;
             obj.activities = ActObj;
       // paramsObj.add(obj);
        Property_Visit__c pv=CARActivityTrackerController.checkIn(prop.Id, obj.latitude, obj.longitude);
             CARActivityTrackerController.saveActivities(obj);
             CARActivityTrackerController.createChatterPost(obj);
             //CARActivityTrackerController.addTask(taskObj);
             List<Property_Visit__c> result=CARActivityTrackerController.getPropertyVisit(prop.id);
     }

 }