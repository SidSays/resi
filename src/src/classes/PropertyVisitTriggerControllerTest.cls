/*
Author:
Last Modified By: Animesh - 20 - July - 2017. US1137734(XC DT - Only count completed visits). Considering only completed Visits for Metric Update 
*/
@isTest
public class PropertyVisitTriggerControllerTest {
    public static MDU_Property__c prop;
    public static Property_Visit__c propVisit1;
    
    /*
    Author:
    Last Modified By: Animesh - 20 - July - 2017. US1137734(XC DT - Only count completed visits). Considering only completed Visits for Metric Update 
    */
    static testMethod void PropertyVisitTriggerControllerTest (){
        List<Goal> goalList = new List<Goal>();
        List<Metric> metricList= new List<Metric>();
        VariableSettingTestUtility.variableSettingsData();
        TestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.createCustomSettingRecords();
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = false;
        triggerSettingsList.add(userTrigger);
        Database.insert(triggerSettingsList,false);
         
        String goalPropertyLabRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(System.Label.PL_MonthlyGoalCreationBatchGolTempType).getRecordTypeId();   
       
        GoalTemplateDates__c templateDates = new GoalTemplateDates__c();
        templateDates.Current_Period_Start_Date__c = System.today().adddays(-3);
        templateDates.Current_Period_Due_Date__c = System.today().adddays(3);
        templateDates.Name = 'Property Lab CAR';
        Database.insert(templateDates,false);
        Date preGoalStartDate = null,preGoalDueDate = null,todayDate = Date.Today();
        //Start - added by Animesh - In PropertyVisitTriggerController class, start date and end date is not used date given in GoalTemplates custom settings. So implementing test class same way to cover uncovered lines
        if(todayDate.Day()>=22){              
            preGoalStartDate = Date.newInstance(todayDate.Year(), todayDate.Month(), 22);  
        }else if(todayDate.Day() >= 1 && todayDate.Day() <= 21){
            preGoalStartDate = Date.newInstance(todayDate.Year(), todayDate.Month()-1, 22); 
        }                       
        preGoalDueDate =  preGoalStartDate.addMonths(1).AddDays(-1);
        //End - added by Animesh - In PropertyVisitTriggerController class, start date and end date is not used date given in GoalTemplates custom settings. So implementing test class same way to cover uncovered lines
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        
        User carUser = TestDataUtility.createXfinityCARUser();
        User carMgr = TestDataUtility.createXfinityCARManagerUser();
        User SrcarMgr = TestDataUtility.createXfinityCARManagerUser();
        
        System.runAs(user){       
            AssignPermissionSet('SalesSpace_Coach_Access_CAR',carUser.Id);
            AssignPermissionSet('SalesSpace_Coach_Access_CAR_Manager',carMgr.Id);
            //AssignPermissionSet('SalesSpace_Coach_Access_CAR_Manager',SrcarMgr.Id);
            AssignPermissionSet('Coach_CAR_Director_Manager',SrcarMgr.Id);
            
            SrcarMgr.UserPermissionsWorkDotComUserFeature = true;
            SrcarMgr.Terms_and_Conditions_Accepted__c = System.today();
            //SrcarMgr.ManagerId = SrcarMgr.Id;
            update SrcarMgr;
            
            carMgr.UserPermissionsWorkDotComUserFeature = true;
            carMgr.Terms_and_Conditions_Accepted__c = System.today();
            carMgr.ManagerId = SrcarMgr.Id;
            update carMgr;
      
            carUser.UserPermissionsWorkDotComUserFeature = true;
            carUser.Terms_and_Conditions_Accepted__c = System.today();
            carUser.ManagerId = carMgr.Id;
            update carUser ;
            
            prop = new MDU_Property__c();
            prop = TestDataUtility.createProperty();            
            prop.Assigned_CAR__c = carUser.Id;
            prop.ownerId = carUser.Id;
            insert prop;
            
            MDU_Property__Share propShare = new MDU_Property__Share();
            propShare.AccessLevel = 'Edit';
            propShare.UserOrGroupId = carUser.Id;
            propShare.RowCause = 'Manual';
            propShare.ParentId = prop.Id;
           
            //Goal for CAR
            Goal carGoal = new Goal(); 
            carGoal.Name='CAR TEST GOAL';
            carGoal.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carGoal.DueDate = preGoalDueDate;//System.today().adddays(3);
            carGoal.Status = 'Published';
            carGoal.Template_Type__c = 'Property Lab';       
            carGoal.OwnerId = carUser.Id;        
            carGoal.RecordTypeId = goalPropertyLabRecordType;
            goalList.add(carGoal);
            //Goal for CAR Manager
            Goal carMgrGoal = new Goal(); 
            carMgrGoal.Name ='CAR Mgr TEST GOAL';
            carMgrGoal.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carMgrGoal.DueDate = preGoalDueDate;//System.today().adddays(3);
            carMgrGoal.Status = 'Published';
            carMgrGoal.Template_Type__c = 'Property Lab';       
            carMgrGoal.OwnerId = carMgr.Id;        
            carMgrGoal.RecordTypeId = goalPropertyLabRecordType;
            goalList.add(carMgrGoal);
            //Goal for CAR Director
            Goal carDirGoal = new Goal(); 
            carDirGoal.Name ='CAR Dir TEST GOAL';
            carDirGoal.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carDirGoal.DueDate = preGoalDueDate;//System.today().adddays(3);
            carDirGoal.Status = 'Published';
            carDirGoal.Template_Type__c = 'Property Lab';       
            carDirGoal.OwnerId = SrcarMgr.Id;        
            carDirGoal.RecordTypeId = goalPropertyLabRecordType;
            goalList.add(carDirGoal);
            
            insert goalList;
            
            //"Total Property Visits per month" metric For CAR
            Metric carMetric = New Metric();        
            carMetric.Name = 'Total Property Visits per month';
            carMetric.OwnerId = carUser.Id ;
            carMetric.Status = 'NotStarted';                  
            carMetric.TargetValue = 80;
            carMetric.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carMetric.DueDate = preGoalDueDate;//System.today().adddays(3);
            carMetric.goalId = carGoal.Id;
            metricList.add(carMetric);
            //"Average Property Visits per day" metric For CAR 
            Metric carMetric1 = New Metric();        
            carMetric1.Name = 'Average Property Visits per day';
            carMetric1.OwnerId = carUser.Id ;
            carMetric1.Status = 'NotStarted';                 
            carMetric1.TargetValue = 4;
            carMetric1.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carMetric1.DueDate = preGoalDueDate;//System.today().adddays(3);
            carMetric1.goalId = carGoal.Id;
            metricList.add(carMetric1);
            
            
            //"Total Property Visits per month" metric For CAR Manager
            Metric carMgrMetric = New Metric();        
            carMgrMetric.Name = 'Total Property Visits per month';
            carMgrMetric.OwnerId = carMgr.Id ;
            carMgrMetric.Status = 'NotStarted';                  
            carMgrMetric.TargetValue = 80;
            carMgrMetric.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carMgrMetric.DueDate = preGoalDueDate;//System.today().adddays(3);
            carMgrMetric.goalId = carMgrGoal.Id;
            metricList.add(carMgrMetric);
            //"Average Property Visits per day" metric For CAR Manager
            Metric carMgrMetric1 = New Metric();        
            carMgrMetric1.Name = 'Average Property Visits per day';
            carMgrMetric1.OwnerId = carMgr.Id ;
            carMgrMetric1.Status = 'NotStarted';                   
            carMgrMetric1.TargetValue = 4;
            carMgrMetric1.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carMgrMetric1.DueDate = preGoalDueDate;//System.today().adddays(3);
            carMgrMetric1.goalId = carMgrGoal.Id;
            metricList.add(carMgrMetric1);
            
            //"Total Property Visits per month" metric For CAR Director
            Metric carDirMetric = New Metric();        
            carDirMetric.Name = 'Total Property Visits per month';
            carDirMetric.OwnerId = SrcarMgr.Id ;
            carDirMetric.Status = 'NotStarted';                  
            carDirMetric.TargetValue = 80;
            carDirMetric.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carDirMetric.DueDate = preGoalDueDate;//System.today().adddays(3);
            carDirMetric.goalId = carDirGoal.Id;
            metricList.add(carDirMetric);
            //"Average Property Visits per day" metric For CAR Director
            Metric carDirMetric1 = New Metric();        
            carDirMetric1.Name = 'Average Property Visits per day';
            carDirMetric1.OwnerId = SrcarMgr.Id ;
            carDirMetric1.Status = 'NotStarted';                   
            carDirMetric1.TargetValue = 4;
            carDirMetric1.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carDirMetric1.DueDate = preGoalDueDate;//System.today().adddays(3);
            carDirMetric1.goalId = carDirGoal.Id;
            metricList.add(carDirMetric1);
            
            Test.starttest();
            insert metricList;          
            
        }
        
        System.runAs(carUser){  
            propVisit1 = new Property_Visit__c();
            propVisit1.Name ='Test prop visit';
            propVisit1.Property__c = prop.Id;           
            insert propVisit1 ;
            propVisit1.Status__c = 'Completed';
            propVisit1.End_Date_Time__c = system.now();
            update propVisit1;          
            Test.stoptest();
        }
    }
    
    /*
    Author:
    Last Modified By: Animesh - 20 - July - 2017. US1137734(XC DT - Only count completed visits). Considering only completed Visits for Metric Update 
    */
    static testMethod void PropertyVisitTriggerControllerTest1 (){
        List<Goal> goalList = new List<Goal>();
        List<Metric> metricList= new List<Metric>();
        VariableSettingTestUtility.variableSettingsData();
        TestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.createCustomSettingRecords();
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = false;
        triggerSettingsList.add(userTrigger);
        Database.insert(triggerSettingsList,false);
         
        String goalPropertyLabRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(System.Label.PL_MonthlyGoalCreationBatchGolTempType).getRecordTypeId();   
       
        GoalTemplateDates__c templateDates = new GoalTemplateDates__c();
        templateDates.Current_Period_Start_Date__c = System.today().adddays(-3);
        templateDates.Current_Period_Due_Date__c = System.today().adddays(3);
        templateDates.Name = 'Property Lab CAR';
        Database.insert(templateDates,false);
        Date preGoalStartDate = null,preGoalDueDate = null,todayDate = Date.Today();
        
        //Start - added by Animesh - In PropertyVisitTriggerController class, start date and end date is not used date given in GoalTemplates custom settings. So implementing test class same way to cover uncovered lines
        if(todayDate.Day()>=22){              
            preGoalStartDate = Date.newInstance(todayDate.Year(), todayDate.Month(), 22);  
        }else if(todayDate.Day() >= 1 && todayDate.Day() <= 21){
            preGoalStartDate = Date.newInstance(todayDate.Year(), todayDate.Month()-1, 22); 
        }                       
        preGoalDueDate =  preGoalStartDate.addMonths(1).AddDays(-1);
        //End - added by Animesh - In PropertyVisitTriggerController class, start date and end date is not used date given in GoalTemplates custom settings. So implementing test class same way to cover uncovered lines
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        User carUser = TestDataUtility.createXfinityCARUser();
        User SrcarMgr = TestDataUtility.createXfinityCARManagerUser();
        
        System.runAs(user){       
            AssignPermissionSet('SalesSpace_Coach_Access_CAR',carUser.Id);
            AssignPermissionSet('Coach_CAR_Director_Manager',SrcarMgr.Id);
            
            SrcarMgr.UserPermissionsWorkDotComUserFeature = true;
            SrcarMgr.Terms_and_Conditions_Accepted__c = System.today();
            update SrcarMgr;
      
            carUser.UserPermissionsWorkDotComUserFeature = true;
            carUser.Terms_and_Conditions_Accepted__c = System.today();
            carUser.ManagerId = SrcarMgr.Id;
            update carUser ;
            
            prop = new MDU_Property__c();
            prop = TestDataUtility.createProperty();            
            prop.Assigned_CAR__c = carUser.Id;
            prop.ownerId = carUser.Id;
            insert prop;
            
            MDU_Property__Share propShare = new MDU_Property__Share();
            propShare.AccessLevel = 'Edit';
            propShare.UserOrGroupId = carUser.Id;
            propShare.RowCause = 'Manual';
            propShare.ParentId = prop.Id;
           
            //Goal for CAR
            Goal carGoal = new Goal(); 
            carGoal.Name='CAR TEST GOAL';
            carGoal.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carGoal.DueDate = preGoalDueDate;//System.today().adddays(3);
            carGoal.Status = 'Published';
            carGoal.Template_Type__c = 'Property Lab';       
            carGoal.OwnerId = carUser.Id;        
            carGoal.RecordTypeId = goalPropertyLabRecordType;
            goalList.add(carGoal);
           
            //Goal for CAR Director
            Goal carDirGoal = new Goal(); 
            carDirGoal.Name ='CAR Dir TEST GOAL';
            carDirGoal.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carDirGoal.DueDate = preGoalDueDate;//System.today().adddays(3);
            carDirGoal.Status = 'Published';
            carDirGoal.Template_Type__c = 'Property Lab';       
            carDirGoal.OwnerId = SrcarMgr.Id;        
            carDirGoal.RecordTypeId = goalPropertyLabRecordType;
            goalList.add(carDirGoal);
            
            insert goalList;
            
            //"Total Property Visits per month" metric For CAR
            Metric carMetric = New Metric();        
            carMetric.Name = 'Total Property Visits per month';
            carMetric.OwnerId = carUser.Id ;
            carMetric.Status = 'NotStarted';                  
            carMetric.TargetValue = 80;
            carMetric.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carMetric.DueDate = preGoalDueDate;//System.today().adddays(3);
            carMetric.goalId = carGoal.Id;
            metricList.add(carMetric);
            //"Average Property Visits per day" metric For CAR 
            Metric carMetric1 = New Metric();        
            carMetric1.Name = 'Average Property Visits per day';
            carMetric1.OwnerId = carUser.Id ;
            carMetric1.Status = 'NotStarted';                 
            carMetric1.TargetValue = 4;
            carMetric1.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carMetric1.DueDate = preGoalDueDate;//System.today().adddays(3);
            carMetric1.goalId = carGoal.Id;
            metricList.add(carMetric1);
            
            //"Total Property Visits per month" metric For CAR Director
            Metric carDirMetric = New Metric();        
            carDirMetric.Name = 'Total Property Visits per month';
            carDirMetric.OwnerId = SrcarMgr.Id ;
            carDirMetric.Status = 'NotStarted';                  
            carDirMetric.TargetValue = 80;
            carDirMetric.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carDirMetric.DueDate = preGoalDueDate;//System.today().adddays(3);
            carDirMetric.goalId = carDirGoal.Id;
            metricList.add(carDirMetric);
            //"Average Property Visits per day" metric For CAR Director
            Metric carDirMetric1 = New Metric();        
            carDirMetric1.Name = 'Average Property Visits per day';
            carDirMetric1.OwnerId = SrcarMgr.Id ;
            carDirMetric1.Status = 'NotStarted';                   
            carDirMetric1.TargetValue = 4;
            carDirMetric1.StartDate = preGoalStartDate;//System.today().adddays(-3);
            carDirMetric1.DueDate = preGoalDueDate;//System.today().adddays(3);
            carDirMetric1.goalId = carDirGoal.Id;
            metricList.add(carDirMetric1);
            
            Test.starttest();
            insert metricList;          
            
        }
        
        System.runAs(carUser){  
            propVisit1 = new Property_Visit__c();
            propVisit1.Name ='Test prop visit';
            propVisit1.Property__c = prop.Id;           
            insert propVisit1 ;
            propVisit1.Status__c = 'Completed';
            propVisit1.End_Date_Time__c = system.now();
            update propVisit1;
            Test.stoptest();
        }
    }
   /*
    *  This method set permission set to user base on permissionSetName
    */ 
       public static void AssignPermissionSet(String permissionSetName, Id userId){
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);
        
       }
        
  }