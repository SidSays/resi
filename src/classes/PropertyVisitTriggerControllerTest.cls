@isTest
public class PropertyVisitTriggerControllerTest {
    public static MDU_Property__c prop;
    public static Property_Visit__c propVisit1;

    static testMethod void PropertyVisitTriggerControllerTest (){
        List<Goal> goalList = new List<Goal>();
        List<Metric> metricList= new List<Metric>();
        
        TestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.createCustomSettingRecords();
        
        String goalPropertyLabRecordType = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(System.Label.PL_MonthlyGoalCreationBatchGolTempType).getRecordTypeId();   
       
        GoalTemplateDates__c templateDates = new GoalTemplateDates__c();
        templateDates.Current_Period_Start_Date__c = System.today().adddays(-3);
        templateDates.Current_Period_Due_Date__c = System.today().adddays(3);
        templateDates.Name = 'Property Lab CAR';
        Database.insert(templateDates,false);
        
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        
        User carUser = TestDataUtility.createXfinityCARUser();
        User carMgr = TestDataUtility.createXfinityCARManagerUser();
    
        
        System.runAs(user){       
            AssignPermissionSet('Coach_Goal_Metric_Edit',carUser.Id);
            AssignPermissionSet('Coach_Goal_Metric_Edit',carMgr.Id);
            
            carMgr.UserPermissionsWorkDotComUserFeature = true;
            carMgr.Terms_and_Conditions_Accepted__c = System.today();
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
            carGoal.StartDate = System.today().adddays(-3);
            carGoal.DueDate = System.today().adddays(3);
            carGoal.Status = 'Published';
            carGoal.Template_Type__c = 'Property Lab';       
            carGoal.OwnerId = carUser.Id;        
            carGoal.RecordTypeId = goalPropertyLabRecordType;
            goalList.add(carGoal);
            //Goal for CAR Manager
            Goal carMgrGoal = new Goal(); 
            carMgrGoal.Name ='CAR Mgr TEST GOAL';
            carMgrGoal.StartDate = System.today().adddays(-3);
            carMgrGoal.DueDate = System.today().adddays(3);
            carMgrGoal.Status = 'Published';
            carMgrGoal.Template_Type__c = 'Property Lab';       
            carMgrGoal.OwnerId = carMgr.Id;        
            carMgrGoal.RecordTypeId = goalPropertyLabRecordType;
            goalList.add(carMgrGoal);
            
            insert goalList;
            
            //"Total Property Visits per month" metric For CAR
            Metric carMetric = New Metric();        
            carMetric.Name = 'Total Property Visits per month';
            carMetric.OwnerId = carUser.Id ;
            carMetric.Status = 'NotStarted';                  
            carMetric.TargetValue = 80;
            carMetric.goalId = carGoal.Id;
            metricList.add(carMetric);
            //"Average Property Visits per day" metric For CAR 
            Metric carMetric1 = New Metric();        
            carMetric1.Name = 'Average Property Visits per day';
            carMetric1.OwnerId = carUser.Id ;
            carMetric1.Status = 'NotStarted';                 
            carMetric1.TargetValue = 4;
            carMetric1.goalId = carGoal.Id;
            metricList.add(carMetric1);
            
            
            //"Total Property Visits per month" metric For CAR Manager
            Metric carMgrMetric = New Metric();        
            carMgrMetric.Name = 'Total Property Visits per month';
            carMgrMetric.OwnerId = carMgr.Id ;
            carMgrMetric.Status = 'NotStarted';                  
            carMgrMetric.TargetValue = 80;
            carMgrMetric.goalId = carMgrGoal.Id;
            metricList.add(carMgrMetric);
            //"Average Property Visits per day" metric For CAR Manager
            Metric carMgrMetric1 = New Metric();        
            carMgrMetric1.Name = 'Average Property Visits per day';
            carMgrMetric1.OwnerId = carMgr.Id ;
            carMgrMetric1.Status = 'NotStarted';                   
            carMgrMetric1.TargetValue = 4;
            carMgrMetric1.goalId = carMgrGoal.Id;
            metricList.add(carMgrMetric1);
            
            Test.starttest();
            insert metricList;          
            
        }
        
        System.runAs(carUser){  
            propVisit1 = new Property_Visit__c();
            propVisit1.Name ='Test prop visit';
            propVisit1.Property__c = prop.Id;           
            insert propVisit1 ; 
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