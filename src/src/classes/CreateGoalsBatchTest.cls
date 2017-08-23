@isTest(SeeAllData=false)
public class CreateGoalsBatchTest {  
    public static testmethod void testCreateGoalsBatch(){        
        string goalGoaltemplateRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId(); 
        string goalDirecttemplateRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.createCustomSettingOtherRecords();
        WorkTestDataUtility.setGoalTemplateBiWeeklyDateCS();
        
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'DeletePropertyBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
        integer count = 0; 
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();            
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = false;
        triggerSettingsList.add(userTrigger );
            
        TriggerSettings__c goalTrigger = new TriggerSettings__c();
        goalTrigger.Name = 'GoalTrigger';
        goalTrigger.isActive__c = false;
        triggerSettingsList.add(goalTrigger);            
        database.insert(triggerSettingsList,true) ;
        
        Profile directorProfile = [Select Id, Name From Profile where Name = 'Direct Sales Director' limit 1];
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User directorUser = new User(Alias = 'C_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = directorProfile.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'California Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
          
                          );
        insert directorUser;
        
        User ManagerUser = WorkTestDataUtility.createDSManagerUser();
        User SupervisorUser = WorkTestDataUtility.createDSSupervisorUser();         
        User RepUser = WorkTestDataUtility.createDSRepUser();
            
        List<User> usersToUpdate = new List<User>();        
        RepUser.managerid = SupervisorUser.id;
        RepUser.Sales_Rep_Type__c = 'Winback';
        RepUser.level__c = 'Xfinity Sales Associate';
        usersToUpdate.add(RepUser);
        
        SupervisorUser.managerid = ManagerUser.id;
        usersToUpdate.add(SupervisorUser);
                
        ManagerUser.managerid = directorUser.id;
        usersToUpdate.add(ManagerUser);
        
        Database.update(usersToUpdate,true);
       
        //Assign PermissionSet to Coresponding Profile user        
        System.runAs(new User(Id=userInfo.getUserId())){
            assignPermissionSet('SalesSpace_Coach_Access_Director',directorUser.Id);            
            assignPermissionSet('SalesSpace_Coach_Access_ASM',ManagerUser.Id);   
            assignPermissionSet('SalesSpace_Coach_Access_SDM',SupervisorUser.Id);
            assignPermissionSet('SalesSpace_Coach_Access_XSP',RepUser.Id);
        }
              
        //Create  Goal record and related Metrics record for RGU
        Goal xspRGUGoalTemplate = WorkTestDataUtility.createGoal(); // Standard obj
        xspRGUGoalTemplate.Profile_Name__c = WorkTestDataUtility.getDSRepProfile().Name;
        xspRGUGoalTemplate.Region__c = RepUser.Region__c;
        xspRGUGoalTemplate.StartDate = Date.newinstance(2015, 6, 22);
        xspRGUGoalTemplate.DueDate = Date.newinstance(2015, 7, 21);
        xspRGUGoalTemplate.Status='Draft';
        xspRGUGoalTemplate.Template_Type__c = 'RGU';
        xspRGUGoalTemplate.Sales_Rep_Type__c = 'Winback';
        xspRGUGoalTemplate.Level__c = 'Xfinity Sales Associate';      
        xspRGUGoalTemplate.RecordTypeId = goalGoaltemplateRecordTypeId;
        
        Database.update(xspRGUGoalTemplate);
        
        List<Metric> metricUpdateList = new List<Metric>(); 
        List<Metric> rguMetrics= WorkTestDataUtility.CreateMetric();
        for(Metric m : rguMetrics){ 
            m.GoalId = xspRGUGoalTemplate.Id;                       
            m.DueDate = Date.newinstance(2015, 8, 21);
            metricUpdateList.add(m);
        }   
                
        Goal xspRGUGoal= new Goal(); // Standard obj               
        xspRGUGoal.DueDate = System.Today().addDays(-5);
        xspRGUGoal.Status= 'Published';         
        xspRGUGoal.RecordTypeId = goalDirecttemplateRecordTypeId;      
        xspRGUGoal.name = 'RGUTest' ;
        xspRGUGoal.OwnerId = Repuser.id;
        insert xspRGUGoal;
        
        Metric xspMetric = new Metric();
        xspMetric.name = 'xspMetric';
        xspMetric.ownerId = repuser.Id;
        xspMetric.DueDate = System.Today().addDays(-5);
        xspMetric.Status = 'Critical';
        xspMetric.Sort_Order__c = 1;
        xspMetric.goalId = xspRGUGoal.Id;
        insert xspMetric;
                  
        // Create  Goal record and related Metrics record for Activity
        Goal xspActivityGoalTemplate = WorkTestDataUtility.createGoal(); // Standard obj
        xspActivityGoalTemplate.Profile_Name__c = WorkTestDataUtility.getDSRepProfile().Name;
        xspActivityGoalTemplate.Region__c = RepUser.Region__c;
        xspActivityGoalTemplate.StartDate = Date.newinstance(2015, 6, 22);
        xspActivityGoalTemplate.DueDate = Date.newinstance(2015, 7, 21);
        xspActivityGoalTemplate.Status='Draft';
        xspActivityGoalTemplate.Template_Type__c = 'Activity';
        xspActivityGoalTemplate.Sales_Rep_Type__c = 'Winback';       
        xspActivityGoalTemplate.Level__c= 'Xfinity Sales Associate';
        xspActivityGoalTemplate.RecordTypeId = goalGoaltemplateRecordTypeId;
        
        Database.update(xspActivityGoalTemplate);
        
        List<Metric> activityMetrics= WorkTestDataUtility.CreateActivityMetric();
        database.insert(activityMetrics,true);
        List<Metric> xspActivityMetricTemplate= new List<Metric>();
        for(Metric m : activityMetrics){ 
            m.GoalId = xspActivityGoalTemplate.Id;              
            m.DueDate = Date.newinstance(2015, 8, 21);
            metricUpdateList.add(m);
        }
        Database.update(metricUpdateList,true);
                
        Test.startTest();
        Boolean isWest = false;
        String goalsQuery = 'Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId from User where IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true limit 199';
        CreateGoalsBatch goalMonthlyBatch = new CreateGoalsBatch(goalsQuery,isWest);
        Database.executeBatch(goalMonthlyBatch,200);    
        Test.StopTest();                        
    }
    
    public static testMethod void testCreateGoalsBatchWest(){
        string goalGoaltemplateRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId(); 
        string goalDirecttemplateRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.createCustomSettingOtherRecords();
        WorkTestDataUtility.setGoalTemplateMonthlyDateCS();
        
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'DeletePropertyBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
        integer count = 0; 
        
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();            
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = false;
        triggerSettingsList.add(userTrigger );
            
        TriggerSettings__c goalTrigger = new TriggerSettings__c();
        goalTrigger.Name = 'GoalTrigger';
        goalTrigger.isActive__c = false;
        triggerSettingsList.add(goalTrigger);            
        database.insert(triggerSettingsList,true) ;
        
        Profile directorProfile = [Select Id, Name From Profile where Name = 'Direct Sales Director' limit 1];
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User directorUser = new User(Alias = 'C_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = directorProfile.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'California Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
          
                          );
        insert directorUser;
        
        User ManagerUser = WorkTestDataUtility.createDSManagerUser();
        User SupervisorUser = WorkTestDataUtility.createDSSupervisorUser();         
        User RepUser = WorkTestDataUtility.createDSRepUser();
            
        List<User> usersToUpdate = new List<User>();        
        RepUser.managerid = SupervisorUser.id;
        RepUser.Sales_Rep_Type__c = 'Winback';
        RepUser.level__c = 'Xfinity Sales Associate';
        usersToUpdate.add(RepUser);
        
        SupervisorUser.managerid = ManagerUser.id;
        usersToUpdate.add(SupervisorUser);
                
        ManagerUser.managerid = directorUser.id;
        usersToUpdate.add(ManagerUser);
        
        Database.update(usersToUpdate,true);
       
        //Assign PermissionSet to Coresponding Profile user        
        System.runAs(new User(Id=userInfo.getUserId())){
            assignPermissionSet('SalesSpace_Coach_Access_Director',directorUser.Id);            
            assignPermissionSet('SalesSpace_Coach_Access_ASM',ManagerUser.Id);   
            assignPermissionSet('SalesSpace_Coach_Access_SDM',SupervisorUser.Id);
            assignPermissionSet('SalesSpace_Coach_Access_XSP',RepUser.Id);
        }
              
        //Create  Goal record and related Metrics record for RGU
        Goal xspRGUGoalTemplate = WorkTestDataUtility.createGoal(); // Standard obj
        xspRGUGoalTemplate.Profile_Name__c = WorkTestDataUtility.getDSRepProfile().Name;
        xspRGUGoalTemplate.Region__c = RepUser.Region__c;
        xspRGUGoalTemplate.StartDate = Date.newinstance(2015, 6, 22);
        xspRGUGoalTemplate.DueDate = Date.newinstance(2015, 7, 21);
        xspRGUGoalTemplate.Status='Draft';
        xspRGUGoalTemplate.Template_Type__c = 'RGU';
        xspRGUGoalTemplate.Sales_Rep_Type__c = 'Winback';
        xspRGUGoalTemplate.Level__c = 'Xfinity Sales Associate';      
        xspRGUGoalTemplate.RecordTypeId = goalGoaltemplateRecordTypeId;
        
        Database.update(xspRGUGoalTemplate);
        
        List<Metric> metricUpdateList = new List<Metric>(); 
        List<Metric> rguMetrics= WorkTestDataUtility.CreateMetric();
        for(Metric m : rguMetrics){ 
            m.GoalId = xspRGUGoalTemplate.Id;                       
            m.DueDate = Date.newinstance(2015, 8, 21);
            metricUpdateList.add(m);
        }   
                
        Goal xspRGUGoal= new Goal(); // Standard obj               
        xspRGUGoal.DueDate = System.Today().addDays(-5);
        xspRGUGoal.Status= 'Published';         
        xspRGUGoal.RecordTypeId = goalDirecttemplateRecordTypeId;      
        xspRGUGoal.name = 'RGUTest' ;
        xspRGUGoal.OwnerId = Repuser.id;
        insert xspRGUGoal;
        
        Metric xspMetric = new Metric();
        xspMetric.name = 'xspMetric';
        xspMetric.ownerId = repuser.Id;
        xspMetric.DueDate = System.Today().addDays(-5);
        xspMetric.Status = 'Critical';
        xspMetric.Sort_Order__c = 1;
        xspMetric.goalId = xspRGUGoal.Id;
        insert xspMetric;
                  
        // Create  Goal record and related Metrics record for Activity
        Goal xspActivityGoalTemplate = WorkTestDataUtility.createGoal(); // Standard obj
        xspActivityGoalTemplate.Profile_Name__c = WorkTestDataUtility.getDSRepProfile().Name;
        xspActivityGoalTemplate.Region__c = RepUser.Region__c;
        xspActivityGoalTemplate.StartDate = Date.newinstance(2015, 6, 22);
        xspActivityGoalTemplate.DueDate = Date.newinstance(2015, 7, 21);
        xspActivityGoalTemplate.Status='Draft';
        xspActivityGoalTemplate.Template_Type__c = 'Activity';
        xspActivityGoalTemplate.Sales_Rep_Type__c = 'Winback';       
        xspActivityGoalTemplate.Level__c= 'Xfinity Sales Associate';
        xspActivityGoalTemplate.RecordTypeId = goalGoaltemplateRecordTypeId;
        
        Database.update(xspActivityGoalTemplate);
        
        List<Metric> activityMetrics= WorkTestDataUtility.CreateActivityMetric();
        database.insert(activityMetrics,true);
        List<Metric> xspActivityMetricTemplate= new List<Metric>();
        for(Metric m : activityMetrics){ 
            m.GoalId = xspActivityGoalTemplate.Id;              
            m.DueDate = Date.newinstance(2015, 8, 21);
            metricUpdateList.add(m);
        }
        Database.update(metricUpdateList,true);
                
        Test.startTest();
        Boolean isWest = true;
        String goalsQuery = 'Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c, ManagerId, Manager.ManagerId, Manager.Manager.ManagerId from User where IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true limit 199';
        CreateGoalsBatch goalMonthlyBatch = new CreateGoalsBatch(goalsQuery,isWest);
        Database.executeBatch(goalMonthlyBatch,200);   
        Test.StopTest();
    }
    /*
    *  This method set permission set to user base on permissionSetName 
    */     
    static void assignPermissionSet(String permissionSetName, Id userId){        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);        
    } 
}