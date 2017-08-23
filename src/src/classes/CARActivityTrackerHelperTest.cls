/*Description: Test class for "CARActivityTrackerHelper" apex clas*/

@isTest
private class CARActivityTrackerHelperTest{ 
    static testmethod void testCARActivityTrackerHelper(){
        
        List<User> userList = new List<User>();
        List<Task> taskList = new List<Task>();
        List<Task> taskList1 = new List<Task>();
        List<Goal> goalList = new List<Goal>();
        List<Metric> metricList = new List<Metric>();
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>(); 
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = true;
        triggerSettingsList.add(userTrigger);
        
        TriggerSettings__c taskTrigger = new TriggerSettings__c();
        taskTrigger.Name = 'TaskTrigger';
        taskTrigger.isActive__c = true;
        triggerSettingsList.add(taskTrigger);
        
        TriggerSettings__c metricTrigger = new TriggerSettings__c();
        metricTrigger.Name = 'MetricTrigger';
        metricTrigger.isActive__c = true;
        triggerSettingsList.add(metricTrigger);
        
        TriggerSettings__c goalTrigger = new TriggerSettings__c();
        goalTrigger.Name = 'GoalTrigger';
        goalTrigger.isActive__c = true;
        triggerSettingsList.add(goalTrigger);
        
        Database.insert(triggerSettingsList,false);
        
         GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
             goalTemplateDateCS.Name = 'Property Lab CAR';
             goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
             goalTemplateDateCS.Current_Period_Start_Date__c = System.Today();
             Database.insert(goalTemplateDateCS);

        
        String RecordtypeProgress = Schema.SObjectType.Metric.getRecordTypeInfosByName().get(system.label.MetricProgress).getRecordTypeId();
        String propertyLabRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Property Lab').getRecordTypeId(); 
        User currentUser = [Select Id,ManagerId,Manager.IsActive, Manager.ManagerId, Manager.Manager.IsActive From User Where Id =: UserInfo.getUserId()];
        
        User carUser = TestDataUtility.createXfinityCARUser();
        User carMgr = TestDataUtility.createXfinityCARManagerUser();
        User SrcarMgr = TestDataUtility.createXfinityCARManagerUser();
    
        
        System.runAs(currentUser){  
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SalesSpace_Coach_Access_CAR'];
            PermissionSetAssignment psaCar = new PermissionSetAssignment();
            psaCar.AssigneeId = carUser.Id;
            psaCar.PermissionSetId = ps.Id;            
            permissionList.add(psaCar);
            
            PermissionSetAssignment psaCurrentUser = new PermissionSetAssignment();
            psaCurrentUser.AssigneeId = currentUser.Id;
            psaCurrentUser.PermissionSetId = ps.Id;            
            permissionList.add(psaCurrentUser);
            
            PermissionSet psCarMgr = [SELECT Id FROM PermissionSet WHERE Name = 'SalesSpace_Coach_Access_CAR_Manager'];
            PermissionSetAssignment psaCarMgr = new PermissionSetAssignment();
            psaCarMgr.AssigneeId = carMgr.Id;
            psaCarMgr.PermissionSetId = psCarMgr.Id;            
            permissionList.add(psaCarMgr);
            
            PermissionSet psSrCar = [SELECT Id FROM PermissionSet WHERE Name = 'Coach_CAR_Director_Manager'];
            PermissionSetAssignment psaCarSr = new PermissionSetAssignment();
            psaCarSr.AssigneeId = SrcarMgr.Id; 
            psaCarSr.PermissionSetId = psSrCar.Id;            
            permissionList.add(psaCarSr);
            
            Database.insert(permissionList,true);
            
            SrcarMgr.UserPermissionsWorkDotComUserFeature = true;
            SrcarMgr.Terms_and_Conditions_Accepted__c = Date.newinstance(2017, 2, 22);
            update SrcarMgr;
        
            carMgr.UserPermissionsWorkDotComUserFeature = true;
            carMgr.Terms_and_Conditions_Accepted__c = Date.newinstance(2017, 2, 22);
            carMgr.ManagerId = SrcarMgr.Id;
            update carMgr;
            
            
            carUser.UserPermissionsWorkDotComUserFeature = true;
            carUser.Terms_and_Conditions_Accepted__c = Date.newinstance(2017, 2, 22);
            carUser.ManagerId = carMgr.Id;
            userList.add(carUser);    
            
            currentUser.UserPermissionsWorkDotComUserFeature = true;
            currentUser.Terms_and_Conditions_Accepted__c = Date.newinstance(2017, 2, 22);
            currentUser.ManagerId = carMgr.Id;
            userList.add(currentUser);          
           
            Database.update(userList,true);
        
            
            Goal carGoal = new Goal(); // Standard obj
            carGoal.Name='CAR TEST GOAL';
            carGoal.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
            carGoal.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;
            carGoal.Status = 'Published';
            carGoal.Template_Type__c = 'Property Lab';       
            carGoal.OwnerId = carUser.Id;        
            carGoal.RecordTypeId = propertyLabRecordTypeId;
            goalList.add(carGoal);
            
            Metric carMetric = New Metric();        
            carMetric.Name = 'Sales Event';
            carMetric.OwnerId = carUser.Id ;
            carMetric.Status = 'NotStarted';
            carMetric.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
            carMetric.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;
            carMetric.CurrentValue = 1;          
            carMetric.TargetValue = 2;
            carMetric.goalId = carGoal.Id;
            
            metricList.add(carMetric);
            
            
            Goal usrgoal = new Goal(); // Standard obj
            usrgoal.Name ='CAR Mgr TEST GOAL1';
            usrgoal.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
            usrgoal.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;
            usrgoal.Status = 'Published';
            usrgoal.Template_Type__c = 'Property Lab';       
            usrgoal.OwnerId = currentUser.Id;        
            usrgoal.RecordTypeId = propertyLabRecordTypeId;
            goalList.add(usrgoal);
            
            Goal carMgrGoal = new Goal(); // Standard obj
            carMgrGoal.Name ='carMgr- PL - Freedom Market';
            carMgrGoal.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
            carMgrGoal.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;
            carMgrGoal.Status = 'Published';
            carMgrGoal.Template_Type__c = 'Property Lab';       
            carMgrGoal.OwnerId = carMgr.Id;        
            carMgrGoal.RecordTypeId = propertyLabRecordTypeId;
            goalList.add(carMgrGoal);
            
            Goal SrcarMgrGoal = new Goal(); // Standard obj
            SrcarMgrGoal.Name ='Sr CAR Mgr TEST GOAL';
            SrcarMgrGoal.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
            SrcarMgrGoal.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;
            SrcarMgrGoal.Status = 'Published';
            SrcarMgrGoal.Template_Type__c = 'Property Lab';       
            SrcarMgrGoal.OwnerId = SrcarMgr.Id;        
            SrcarMgrGoal.RecordTypeId = propertyLabRecordTypeId;
            goalList.add(SrcarMgrGoal);
            
            Test.starttest();   
            insert goalList;
            
             Metric usrMetric = New Metric();        
            usrMetric.Name = 'Sales Event';
            usrMetric.OwnerId = currentUser.Id ;
            usrMetric.Status = 'NotStarted';
            usrMetric.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
            usrMetric.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;  
            usrMetric.CurrentValue = 2;         
            usrMetric.TargetValue = 2;
            usrMetric.goalId = usrgoal.Id;
            metricList.add(usrMetric);
            
            Metric carMgrMetric = New Metric();        
            carMgrMetric.Name = 'Sales Event';
            carMgrMetric.OwnerId = carMgr.Id ;
            carMgrMetric.Status = 'NotStarted';
            carMgrMetric.StartDate =goalTemplateDateCS.Current_Period_Start_Date__c;
            carMgrMetric.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;  
            carMgrMetric.CurrentValue = 2;          
            carMgrMetric.TargetValue = 2;
            carMgrMetric.goalId = carMgrGoal.Id;
            metricList.add(carMgrMetric);
            
            Metric SrcarMgrMetric = New Metric();        
            SrcarMgrMetric.Name = 'Sales Event';
            SrcarMgrMetric.OwnerId = SrcarMgr.Id ;
            SrcarMgrMetric.Status = 'NotStarted';
            SrcarMgrMetric.CurrentValue = 2;
            SrcarMgrMetric.StartDate =goalTemplateDateCS.Current_Period_Start_Date__c;
            SrcarMgrMetric.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;        
            SrcarMgrMetric.TargetValue = 2;
            SrcarMgrMetric.goalId = SrcarMgrGoal.Id;
            metricList.add(SrcarMgrMetric);
            
            insert metricList;
        }
            system.runas(carUser){
            Task taskObj = new Task();
            taskObj.OwnerId = carUser.Id;            
            taskObj.Subject = 'test';
            taskObj.Status = 'Completed';
            taskObj.Priority = 'Normal';
            taskObj.ActivityDate = System.Today();
            taskObj.CAR_Activity_Type__c = 'Sales Event';
            taskList.add(taskObj);
            insert taskList;
                CARActivityTrackerHelper.updateMetrics(taskList);
                }
                Test.stoptest(); 
    }
}