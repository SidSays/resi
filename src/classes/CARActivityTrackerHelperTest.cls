@isTest
private class CARActivityTrackerHelperTest{ 
    static testmethod void testCARActivityTrackerHelper(){
        
        
        List<User> userList = new List<User>();
        List<Task> taskList = new List<Task>();
        List<Goal> goalList = new List<Goal>();
        List<Metric> metricList = new List<Metric>();
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>(); 
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);
        
        TriggerSettings__c taskTrigger = new TriggerSettings__c();
        taskTrigger.Name = 'TaskTrigger';
        taskTrigger.isActive__c = True;
        triggerSettingsList.add(taskTrigger);
        
        TriggerSettings__c metricTrigger = new TriggerSettings__c();
        metricTrigger.Name = 'MetricTrigger';
        metricTrigger.isActive__c = True;
        triggerSettingsList.add(metricTrigger);
        
        TriggerSettings__c goalTrigger = new TriggerSettings__c();
        goalTrigger.Name = 'GoalTrigger';
        goalTrigger.isActive__c = True;
        triggerSettingsList.add(goalTrigger);
        
        Database.insert(triggerSettingsList,false);
        
        GoalTemplateDates__c templateDates = new GoalTemplateDates__c();
        templateDates.Current_Period_Start_Date__c = Date.newinstance(2015, 6, 22);
        templateDates.Current_Period_Due_Date__c = Date.newinstance(2015, 7, 21);
        templateDates.Name = 'Property Lab CAR';
        Database.insert(templateDates,false);
        
        String RecordtypeProgress = Schema.SObjectType.Metric.getRecordTypeInfosByName().get(system.label.MetricProgress).getRecordTypeId();
        String propertyLabRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Property Lab').getRecordTypeId(); 
        User currentUser = [Select Id From User Where Id =: UserInfo.getUserId()];
        User carUser = TestDataUtility.createXfinityCARUser();
        User carMgr = TestDataUtility.createXfinityCARManagerUser();
        
        
        
        System.runAs(currentUser){  
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Coach_Goal_Metric_Edit'];
            PermissionSetAssignment psaCar = new PermissionSetAssignment();
            psaCar.AssigneeId = carUser.Id;
            psaCar.PermissionSetId = ps.Id;            
            permissionList.add(psaCar);
            
            PermissionSetAssignment psaCarMgr = new PermissionSetAssignment();
            psaCarMgr.AssigneeId = carMgr.Id;
            psaCarMgr.PermissionSetId = ps.Id;            
            permissionList.add(psaCarMgr);
            
            Database.insert(permissionList,true);
        
            carMgr.UserPermissionsWorkDotComUserFeature = true;
            carMgr.Terms_and_Conditions_Accepted__c = Date.newinstance(2015, 6, 22);
            update carMgr;
            
            carUser.UserPermissionsWorkDotComUserFeature = true;
            carUser.Terms_and_Conditions_Accepted__c = Date.newinstance(2015, 6, 22);
            carUser.ManagerId = carMgr.Id;
            userList.add(carUser);                 
           
            Database.update(userList,true);
            
            Goal carGoal = new Goal(); // Standard obj
            carGoal.Name='CAR TEST GOAL';
            carGoal.StartDate = Date.newinstance(2015, 6, 22);
            carGoal.DueDate = Date.newinstance(2015, 7, 21);
            carGoal.Status = 'Published';
            carGoal.Template_Type__c = 'Property Lab';       
            carGoal.OwnerId = carUser.Id;        
            carGoal.RecordTypeId = propertyLabRecordTypeId;
            goalList.add(carGoal);
            
            Goal carMgrGoal = new Goal(); // Standard obj
            carMgrGoal.Name ='CAR Mgr TEST GOAL';
            carMgrGoal.StartDate = Date.newinstance(2015, 6, 22);
            carMgrGoal.DueDate = Date.newinstance(2015, 7, 21);
            carMgrGoal.Status = 'Published';
            carMgrGoal.Template_Type__c = 'Property Lab';       
            carMgrGoal.OwnerId = carMgr.Id;        
            carMgrGoal.RecordTypeId = propertyLabRecordTypeId;
            goalList.add(carMgrGoal);
            
            insert goalList;
            
            
            Metric carMetric = New Metric();        
            carMetric.Name = 'Events';
            carMetric.OwnerId = carUser.Id ;
            carMetric.Status = 'NotStarted';
            carMetric.StartDate = Date.newinstance(2015, 6, 22);
            carMetric.DueDate = Date.newinstance(2015, 7, 21);        
            carMetric.TargetValue = 2;
            carMetric.goalId = carGoal.Id;
            metricList.add(carMetric);
            
            
            Metric carMgrMetric = New Metric();        
            carMgrMetric.Name = 'Events';
            carMgrMetric.OwnerId = carMgr.Id ;
            carMgrMetric.Status = 'NotStarted';
            carMgrMetric.StartDate = Date.newinstance(2015, 6, 22);
            carMgrMetric.DueDate = Date.newinstance(2015, 7, 21);        
            carMgrMetric.TargetValue = 2;
            carMgrMetric.goalId = carMgrGoal.Id;
            metricList.add(carMgrMetric);
            
        Test.starttest();    
            insert metricList;
        }
        
        System.runAs(carUser){
            
            Task taskObj = new Task();
            taskObj.OwnerId = carUser.Id;            
            taskObj.Subject = 'test';
            taskObj.Status = 'Completed';
            taskObj.Priority = 'Normal';
            taskObj.ActivityDate = System.Today();
            taskObj.CAR_Activity_Type__c = 'Sales Event';
            taskList.add(taskObj);
            
                CARActivityTrackerHelper.updateMetricForCarANDMgr(taskList);
            Test.stoptest();    
        }
    }
}