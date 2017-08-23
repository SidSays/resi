/****************************************************************************************************************************************************
Name: PropertyEventTriggerOperationTest
Description: This class is used to test PropertyEventTriggerOperation Class
Author: Amit Kumar(Accenture)
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------

*************************************************************************************************************************************************************/
@isTest                        
private class PropertyEventTriggerOperationTest{
 //Test Method to test the class   
    static testmethod void testCAREventmetricupdate(){
        
        List<User> userList = new List<User>();
        List<Task> taskList = new List<Task>();
        List<Task> taskList1 = new List<Task>();
        List<Goal> goalList = new List<Goal>();
        List<Metric> metricList = new List<Metric>();
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>(); 
        List<Property_Events__c> propEventList = new List<Property_Events__c>();
        List<Event> standardEventList = new List<Event>();
        List<Property_Event_Item__c> proeventitemList = new List<Property_Event_Item__c>();
        List<MDU_Property__c> propList = new List<MDU_Property__c>();
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = true;
        triggerSettingsList.add(userTrigger);
        
                
        TriggerSettings__c metricTrigger = new TriggerSettings__c();
        metricTrigger.Name = 'MetricTrigger';
        metricTrigger.isActive__c = true;
        triggerSettingsList.add(metricTrigger);
        
        TriggerSettings__c goalTrigger = new TriggerSettings__c();
        goalTrigger.Name = 'GoalTrigger';
        goalTrigger.isActive__c = true;
        triggerSettingsList.add(goalTrigger);
        
        TriggerSettings__c propEventTrigger = new TriggerSettings__c();
        propEventTrigger.Name = 'PropertyEventTrigger';
        propEventTrigger.isActive__c = True;
        triggerSettingsList.add(propEventTrigger);
        
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        triggerSettingsList.add(eventTrigger);
        TriggerSettings__c peventTrigger = new TriggerSettings__c();
        peventTrigger.Name = 'PropertyTrigger';
        peventTrigger.isActive__c = false;
        triggerSettingsList.add(peventTrigger);
        TriggerSettings__c ppeventTrigger = new TriggerSettings__c();
        ppeventTrigger.Name = 'PropertyInsertUpdateTrigger';
        ppeventTrigger.isActive__c = false;
        triggerSettingsList.add(ppeventTrigger);
        Database.insert(triggerSettingsList,false);
         VariableSettingTestUtility.variableSettingsData();
         GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
             goalTemplateDateCS.Name = 'Property Lab CAR';
             goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+7);
             goalTemplateDateCS.Current_Period_Start_Date__c = System.Today();
             Database.insert(goalTemplateDateCS);

        
        String RecordtypeProgress = Schema.SObjectType.Metric.getRecordTypeInfosByName().get(system.label.MetricProgress).getRecordTypeId();
        String propertyLabRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Property Lab').getRecordTypeId(); 
        User currentUser = [Select Id,ManagerId,Manager.IsActive, Manager.ManagerId, Manager.Manager.IsActive From User Where Id =: UserInfo.getUserId()];
        
        User carUser = TestDataUtility.createXfinityCARUser();
        User carMgr = TestDataUtility.createXfinityCARManagerUser();
        User SrcarMgr = TestDataUtility.createXfinityCARManagerUser();
        Event evnt;
        Property_Events__c propEvent;
        Property_Event_Item__c proeventitem;
        MDU_Property__c prop;
        for(integer i=0; i<2; i++){
            prop = new MDU_Property__c();
            prop = TestDataUtility.createProperty();
            prop.Assigned_CAR__c = carUser.id;
            prop.ownerid = carUser.id;
            propList.add(prop);
        }
        Database.insert(propList);
       
        system.runAs(carUser){
            for(integer i=0; i<2; i++){
                evnt = new Event();
                evnt.StartDateTime = System.Today()+1;
                evnt.EndDateTime = System.Today()+2;
                evnt.Subject = 'SUBJECT';
                evnt.CAR_Activity_Type__c = 'Event';
                evnt.WhatId = propList[i].id;
                evnt.Event_Status__c = 'In Progress';
                evnt.Activity__c = 'Sales';
                standardEventList.add(evnt);
            }
            Database.insert(standardEventList);
            for(integer i=0; i<2; i++){
                propEvent = new Property_Events__c();
                propEvent.name = 'TestPropertyEvent';
                propEvent.Property__c = propList[i].id;
                propEvent.Start_Time__c = System.Today()+1;
                propEvent.End_Time__c = System.Today()+2;
                propEvent.Type__c = 'Other';
                propEvent.EventId__c = standardEventList[i].id;
                propEvent.Goal_Comments__c = 'Test GOAL Comment';
                propEvent.Sales_Channel__c = 'Xfinity Communities';
                propEvent.Sponsor__c = 'CAR Sponsored';
                propEvent.Total_RGU_Goal__c = 10.0;
                propEvent.Billing_Type__c = 'Retail';
                propEvent.Property_Life_cycle__c = 'New Build';
                propEvent.Number_of_Attendees__c = 10;
                propEventList.add(propEvent);
            }
            Database.insert(propEventList);
            for(integer i=0; i<2; i++){
                proeventitem = new Property_Event_Item__c();
                proeventitem.Name = 'testing';
                proeventitem.Cost_per_Unit__c = 110.2;
                proeventitem.Property_Event__c = propEventList[i].id;
                proeventitem.Quantity__c = 10;
                proeventitem.Category__c = 'Beverage';
                proeventitemList.add(proeventitem);
            }
            Database.insert(proeventitemList);
            
    
        }
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
           system.debug('userlist update--->'+userList);
            
            
            Goal usrgoal = new Goal(); // Standard obj
            usrgoal.Name ='CAR Mgr TEST GOAL1';
            usrgoal.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
            usrgoal.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;
            usrgoal.Status = 'Published';
            usrgoal.Template_Type__c = 'Property Lab';       
            usrgoal.OwnerId = carUser.Id;        
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
            system.debug('goalList---->'+goalList);
            
             Metric usrMetric = New Metric();        
            usrMetric.Name = 'Sales Event';
            usrMetric.OwnerId = carUser.Id ;
            usrMetric.Status = 'NotStarted';
            usrMetric.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
            usrMetric.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;  
            usrMetric.CurrentValue = 0;         
            usrMetric.TargetValue = 2;
            usrMetric.goalId = usrgoal.Id;
            metricList.add(usrMetric);
            
            Metric carMgrMetric = New Metric();        
            carMgrMetric.Name = 'Sales Event';
            carMgrMetric.OwnerId = carMgr.Id ;
            carMgrMetric.Status = 'NotStarted';
            carMgrMetric.StartDate =goalTemplateDateCS.Current_Period_Start_Date__c;
            carMgrMetric.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;  
            carMgrMetric.CurrentValue = 0;          
            carMgrMetric.TargetValue = 2;
            carMgrMetric.goalId = carMgrGoal.Id;
            metricList.add(carMgrMetric);
            
            Metric SrcarMgrMetric = New Metric();        
            SrcarMgrMetric.Name = 'Sales Event';
            SrcarMgrMetric.OwnerId = SrcarMgr.Id ;
            SrcarMgrMetric.Status = 'NotStarted';
            SrcarMgrMetric.CurrentValue = 0;
            SrcarMgrMetric.StartDate =goalTemplateDateCS.Current_Period_Start_Date__c;
            SrcarMgrMetric.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;        
            SrcarMgrMetric.TargetValue = 2;
            SrcarMgrMetric.goalId = SrcarMgrGoal.Id;
            metricList.add(SrcarMgrMetric);
            
            insert metricList;
        }
        system.debug('metricList---->'+metricList);
            system.runas(carUser){
            
            propEventList[0].status__c = 'Completed';
            propEventList[1].status__c = 'Completed';
            update propEventList;
            }
                Test.stoptest(); 
    }
    static testmethod void testCAREventmetricupdateForDirector(){ 
        List<User> userList = new List<User>();
        List<Goal> goalList = new List<Goal>();
        List<Metric> metricList = new List<Metric>();
        List<PermissionSetAssignment> permissionList = new List<PermissionSetAssignment>(); 
        List<Property_Events__c> propEventList = new List<Property_Events__c>();
        List<Event> standardEventList = new List<Event>();
        List<Property_Event_Item__c> proeventitemList = new List<Property_Event_Item__c>();
        List<MDU_Property__c> propList = new List<MDU_Property__c>();
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = true;
        triggerSettingsList.add(userTrigger);
        
                
        TriggerSettings__c metricTrigger = new TriggerSettings__c();
        metricTrigger.Name = 'MetricTrigger';
        metricTrigger.isActive__c = true;
        triggerSettingsList.add(metricTrigger);
        
        TriggerSettings__c goalTrigger = new TriggerSettings__c();
        goalTrigger.Name = 'GoalTrigger';
        goalTrigger.isActive__c = true;
        triggerSettingsList.add(goalTrigger);
        
        TriggerSettings__c propEventTrigger = new TriggerSettings__c();
        propEventTrigger.Name = 'PropertyEventTrigger';
        propEventTrigger.isActive__c = True;
        triggerSettingsList.add(propEventTrigger);
        
        TriggerSettings__c eventTrigger = new TriggerSettings__c();
        eventTrigger.Name = 'EventTrigger';
        eventTrigger.isActive__c = false;
        triggerSettingsList.add(eventTrigger);
        TriggerSettings__c peventTrigger = new TriggerSettings__c();
        peventTrigger.Name = 'PropertyTrigger';
        peventTrigger.isActive__c = false;
        triggerSettingsList.add(peventTrigger);
        TriggerSettings__c ppeventTrigger = new TriggerSettings__c();
        ppeventTrigger.Name = 'PropertyInsertUpdateTrigger';
        ppeventTrigger.isActive__c = false;
        triggerSettingsList.add(ppeventTrigger);
        Database.insert(triggerSettingsList,false);
         VariableSettingTestUtility.variableSettingsData();
         GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
             goalTemplateDateCS.Name = 'Property Lab CAR';
             goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+7);
             goalTemplateDateCS.Current_Period_Start_Date__c = System.Today();
             Database.insert(goalTemplateDateCS);
        String RecordtypeProgress = Schema.SObjectType.Metric.getRecordTypeInfosByName().get(system.label.MetricProgress).getRecordTypeId();
        String propertyLabRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Property Lab').getRecordTypeId(); 
        User currentUser = [Select Id,ManagerId,Manager.IsActive, Manager.ManagerId, Manager.Manager.IsActive From User Where Id =: UserInfo.getUserId()];
        
        User carUser = TestDataUtility.createXfinityCARUser();
        User SrcarMgr = TestDataUtility.createXfinityCARManagerUser();
        Event evnt;
        Property_Events__c propEvent;
        Property_Event_Item__c proeventitem;
        MDU_Property__c prop;
        for(integer i=0; i<2; i++){
            prop = new MDU_Property__c();
            prop = TestDataUtility.createProperty();
            prop.Assigned_CAR__c = carUser.id;
            prop.ownerid = carUser.id;
            propList.add(prop);
        }
        Database.insert(propList);
       
        system.runAs(carUser){
            for(integer i=0; i<2; i++){
                evnt = new Event();
                evnt.StartDateTime = System.Today()+1;
                evnt.EndDateTime = System.Today()+2;
                evnt.Subject = 'SUBJECT';
                evnt.CAR_Activity_Type__c = 'Event';
                evnt.WhatId = propList[i].id;
                evnt.Event_Status__c = 'In Progress';
                evnt.Activity__c = 'Sales';
                standardEventList.add(evnt);
            }
            Database.insert(standardEventList);
            for(integer i=0; i<2; i++){
                propEvent = new Property_Events__c();
                propEvent.name = 'TestPropertyEvent';
                propEvent.Property__c = propList[i].id;
                propEvent.Start_Time__c = System.Today()+1;
                propEvent.End_Time__c = System.Today()+2;
                propEvent.Type__c = 'Other';
                propEvent.EventId__c = standardEventList[i].id;
                propEvent.Goal_Comments__c = 'Test GOAL Comment';
                propEvent.Sales_Channel__c = 'Xfinity Communities';
                propEvent.Sponsor__c = 'CAR Sponsored';
                propEvent.Total_RGU_Goal__c = 10.0;
                propEvent.Billing_Type__c = 'Retail';
                propEvent.Property_Life_cycle__c = 'New Build';
                propEvent.Number_of_Attendees__c = 10;
                propEventList.add(propEvent);
            }
            Database.insert(propEventList);
            for(integer i=0; i<2; i++){
                proeventitem = new Property_Event_Item__c();
                proeventitem.Name = 'testing';
                proeventitem.Cost_per_Unit__c = 110.2;
                proeventitem.Property_Event__c = propEventList[i].id;
                proeventitem.Quantity__c = 10;
                proeventitem.Category__c = 'Beverage';
                proeventitemList.add(proeventitem);
            }
            Database.insert(proeventitemList);
            
    
        }
        System.runAs(currentUser){  
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SalesSpace_Coach_Access_CAR'];
            PermissionSetAssignment psaCar = new PermissionSetAssignment();
            psaCar.AssigneeId = carUser.Id;
            psaCar.PermissionSetId = ps.Id;            
            permissionList.add(psaCar);
            
            PermissionSet psSrCar = [SELECT Id FROM PermissionSet WHERE Name = 'Coach_CAR_Director_Manager'];
            PermissionSetAssignment psaCarSr = new PermissionSetAssignment();
            psaCarSr.AssigneeId = SrcarMgr.Id; 
            psaCarSr.PermissionSetId = psSrCar.Id;            
            permissionList.add(psaCarSr);
            
            Database.insert(permissionList,true);
            
            SrcarMgr.UserPermissionsWorkDotComUserFeature = true;
            SrcarMgr.Terms_and_Conditions_Accepted__c = Date.newinstance(2017, 2, 22);
            update SrcarMgr;
            
            carUser.UserPermissionsWorkDotComUserFeature = true;
            carUser.Terms_and_Conditions_Accepted__c = Date.newinstance(2017, 2, 22);
            carUser.ManagerId = SrcarMgr.Id;
            userList.add(carUser);          
           
            Database.update(userList,true);
           system.debug('userlist update--->'+userList);
            
            
            Goal usrgoal = new Goal(); // Standard obj
            usrgoal.Name ='CAR Mgr TEST GOAL1';
            usrgoal.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
            usrgoal.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;
            usrgoal.Status = 'Published';
            usrgoal.Template_Type__c = 'Property Lab';       
            usrgoal.OwnerId = carUser.Id;        
            usrgoal.RecordTypeId = propertyLabRecordTypeId;
            goalList.add(usrgoal);
            
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
            system.debug('goalList---->'+goalList);
            
            Metric usrMetric = New Metric();        
            usrMetric.Name = 'Sales Event';
            usrMetric.OwnerId = carUser.Id ;
            usrMetric.Status = 'NotStarted';
            usrMetric.StartDate = goalTemplateDateCS.Current_Period_Start_Date__c;
            usrMetric.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;  
            usrMetric.CurrentValue = 0;         
            usrMetric.TargetValue = 2;
            usrMetric.goalId = usrgoal.Id;
            metricList.add(usrMetric);
            
            Metric SrcarMgrMetric = New Metric();        
            SrcarMgrMetric.Name = 'Sales Event';
            SrcarMgrMetric.OwnerId = SrcarMgr.Id ;
            SrcarMgrMetric.Status = 'NotStarted';
            SrcarMgrMetric.CurrentValue = 0;
            SrcarMgrMetric.StartDate =goalTemplateDateCS.Current_Period_Start_Date__c;
            SrcarMgrMetric.DueDate = goalTemplateDateCS.Current_Period_Due_Date__c ;        
            SrcarMgrMetric.TargetValue = 2;
            SrcarMgrMetric.goalId = SrcarMgrGoal.Id;
            metricList.add(SrcarMgrMetric);
            
            insert metricList;
        }
        system.debug('metricList---->'+metricList);
            system.runas(carUser){
            
            propEventList[0].status__c = 'Completed';
            propEventList[1].status__c = 'Completed';
            update propEventList;
            }
                Test.stoptest(); 
    }
}