/**************************************************************************************************
Name : WorkTestDataUtility
Description : This is Utility class created to create Test data for Work.com Implementation
User Story : US491510
Date : 4 Augest 2015
Author : Ashish Sonawane
***************************************************************************************************/
@isTest
public class WorkTestDataUtility{


           
   public static String createGoalquery='Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c, ManagerId,Manager.ManagerId  from User where  IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true';    
   public static String metricDailyqueryString = 'SELECT Timestamp__c, Knocked_Date__c , Id, CreatedDate, Hour_of_Day__c, Off_Turf__c, '+
                 ' Disposition__c, HSI_Sold__c, Video_Sold__c, Voice_Sold__c, XH_Sold__c, OwnerId, Owner.ProfileId FROM Task WHERE  (Video_Sold__c = true OR HSI_Sold__c = true OR Voice_Sold__c = true OR XH_Sold__c = true)  AND  Owner.ProfileId =: DIRECT_SALES_REPR_PROFILE_ID AND RecordTypeId =: knockRecordTypeId AND CreatedDate >= :BYWEEK_COMMISION_START_DATE AND CreatedDate <= :BYWEEK_COMMISION_END_DATE ';  
    
   public static String QmQuotaAnnualBaselineQuery =  'Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND Profile.Name IN: profileNameSet and UserPermissionsWorkDotComUserFeature = true and PERNR__c = \'testwe16\' LIMIT 1' ;
   public static String ASMSDMQueryString ='Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c, ManagerId,Manager.ManagerId from User where  IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true limit 50';
   public static String communitiesForecastUpdateBatchString = 'Select id,name,profile.Name from User where profile.Name = \'XC Account Executive\' and IsActive = True and UserPermissionsWorkDotComUserFeature = true LIMIT 1'; 
   public static String RegionalBaselineQuotaBatchString='Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND  Sales_Rep_Type__c = \'Region\' and UserPermissionsWorkDotComUserFeature = true LIMIT 1';
   public static String NEDQuotaBatchString='Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND  Sales_Rep_Type__c = \'NED\' and UserPermissionsWorkDotComUserFeature = true and PERNR__c = \'testwe16\' LIMIT 1';
   public static String NAMQuotaBatchString='Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND  Sales_Rep_Type__c = \'NAM\' and UserPermissionsWorkDotComUserFeature = true and PERNR__c = \'testwe16\' LIMIT 1';
   public static String PortfolioAEQuotaBatchString ='Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND  Sales_Rep_Type__c = \'Division\' and UserPermissionsWorkDotComUserFeature = true LIMIT 1';
   /*
    *  Create Task Record's
    */
    Public static Task CreateTask(){
        Task task = new Task();
        task.recordtypeid= Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();
        task.OwnerId = UserInfo.getUserId();
        return task;
    }
    
    
    /*
    *  Create Goal Record's
    */
    Public static Goal createGoal(){
        Goal goalObject = new Goal();
        goalObject.Name = 'Test Goal';
        goalObject.Status = 'Published';
        goalObject.StartDate = System.Today().addDays(-2);
        goalObject.DueDate = System.Today().addDays(+2);
        insert goalObject;
        return goalObject; 
    }
    /*
    *  Create Metric Record's
    */
    Public static List<Metric> CreateMetric(){
        List<Metric> merticList = new List<Metric>();
        for(integer i=0; i<4; i++){
            Metric MetricObj = new Metric();
            if(i==0){
                MetricObj.Name = 'Video';                               
            }
            else if(i==1){
                MetricObj.Name = 'Voice';               
            }
            else if(i==2){
                MetricObj.Name = 'HSD';               
            }
            else{
                MetricObj.Name = 'XH';               
            }
            MetricObj.TargetValue = 100;
            //MetricObj.Status = 'Not Started';
            merticList.add(MetricObj);
        }
        Database.Insert(merticList);
        return merticList;  
    }
    
     /*
    *  Create Activity Metric Record's
    */    
    Public static List<Metric> CreateActivityMetric(){
        List<Metric> merticList = new List<Metric>();
        for(integer i=0; i<12; i++){
            Metric MetricObj = new Metric();
            if(i==0){
                MetricObj.Name = 'Average closes per day';                               
            }else if(i==1){
                MetricObj.Name = 'Average contacts per day';               
            }
            else if(i==2){
                MetricObj.Name = 'Average discovers per day';               
            }else if(i==3){
                MetricObj.Name = 'Average engages per day';               
            }else if(i==4){
                MetricObj.Name = 'Average Dispositions Between 4-9pm';               
            }else if(i==5){
                MetricObj.Name = 'Average Knocks per day';               
            }else if(i==6){
                MetricObj.Name = 'Average positions per day';               
            }else if(i==7){
                MetricObj.Name = 'Average start to contact rate';               
            }else if(i==8){
                MetricObj.Name = 'On Turf Contacts%';               
            }else if(i==9){
                MetricObj.Name = 'On Turf Knocks';               
            }else if(i==10){
                MetricObj.Name = 'On Turf Start%';               
            }else if(i==11){
                MetricObj.Name =  'Average starts per day';               
            }
            MetricObj.TargetValue = 100;
            merticList.add(MetricObj);
        }
        return merticList;  
    }    
     /*
    *  Create Goal Record's
       Author: Laxman Raj, Accenture
    */
    Public static GoalShare CreateGoalShare(){
    Goal goal = createGoal();
        GoalShare WGRecord = new GoalShare();                   
                                    //WGRecord.userorgroupId = userGroupMap.get(user.Id);
                                    WGRecord.AccessLevel = 'Edit';
                                    WGRecord.rowCause = Schema.GoalShare.rowCause.Manual;
                                    WGRecord.ParentId = goal.Id; 
                                    insert WGRecord;
                                    return WGRecord;
    }    
  
  /*
    * Get Perm Set for Coach Access for CARs
    */
    public static PermissionSet getCoachAccessForCAR(){
    return [SELECT Id FROM PermissionSet WHERE Name = 'SalesSpace_Coach_Access_CAR' LIMIT 1] ;
  }
  
  /*
    * Get Perm Set for Coach Access for XSPs
    */
    public static PermissionSet getCoachAccessForXSP(){
    return [SELECT Id FROM PermissionSet WHERE Name = 'SalesSpace_Coach_Access_XSP' LIMIT 1] ;
  }
  
  /*
    * Get Perm Set for Coach Access for CARManagers
    */
    public static PermissionSet getCoachAccessForCARManager(){
    return [SELECT Id FROM PermissionSet WHERE Name = 'SalesSpace_Coach_Access_CAR_Manager' LIMIT 1] ;
  }
  
  /*
    * Get Perm Set for Coach Access for SDMs
    */
    public static PermissionSet getCoachAccessForSDM(){
    return [SELECT Id FROM PermissionSet WHERE Name = 'SalesSpace_Coach_Access_SDM' LIMIT 1] ;
  }
    
    /*
    * Get Perm Set for Coach Access for ASMs
    */
    public static PermissionSet getCoachAccessForASM(){
    return [SELECT Id FROM PermissionSet WHERE Name = 'SalesSpace_Coach_Access_ASM' LIMIT 1] ;
  }
  
    /*
    * Get XFINITY Sales Professional Profile
    */
    public static Profile getDSRepProfile(){
        return [Select Id, Name From Profile where Name = :system.label.DSRProfileName limit 1];
        
    }
    
    /*
    * Create XFINITY Sales Professional Profile User
    */
    public static User createDSRepUserForCoaching(){
        Profile p = getDSRepProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User DSRepUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    PERNR__c='10254424',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
                 
        return DSRepUser;
    }
        /*
    * Create Area Sales Manager Profile User
    */
    public static User createDSManagerUserForCoaching(){
        Profile p = getDSManagerProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User DSManagerUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    PERNR__c='78654424',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
                                    );                                      
        return DSManagerUser;       
    }
        
    /*
    * Create Sales Development Manager Profile User
    */
    public static User createDSSupervisorUserForCoaching(){
        Profile p = getDSSupervisorProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User DSSupervisorUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    PERNR__c='12428431',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());        
        return DSSupervisorUser;        
    }
    
    /*
    * Create XFINITY Sales Professional Profile User
    */
    public static User createDSRepUser(){
        Profile p = getDSRepProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User DSRepUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    PERNR__c='10254424',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4), 
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level',                                  
                                    Terms_and_Conditions_Accepted__c = system.today());
        database.insert(DSRepUser,false);              
        return DSRepUser;
    }
    
     /*
    * Get XC Manager Profile
    */
    public static Profile getXCManagerProfile(){
        return [Select Id, Name From Profile where Name = 'XC Manager' limit 1];
    }
    
    /*
    * Create Area Sales Manager Profile User
    */
    public static User createXCManagerUser(){
        Profile p = getXCManagerProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User XCManagerUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    PERNR__c = '76567657',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
                                    );
                                    
        database.insert(XCManagerUser);       
        return XCManagerUser;       
    }
    
     /*
    * Get XFINITY Sales Executive Profile
    */
    public static Profile getDSSalesExecutiveProfile(){
        return [Select Id, Name From Profile where Name = :system.label.DSExecutive_Profile_NAme limit 1];
    }
    /*
    * Getting a user who can change the opportunity stage to the previous value.
    */
    public static User getDivManagerProfile(){
        Profile p = getDSSalesExecutiveProfile();
        //return [Select Id, Name From User where Id = :'005G0000005ZOaj' limit 1];
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User xcUser = new user (Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
        
              
        database.insert(xcUser);
                
        //return setting;
        return xcUser;
    }
    
    
    /*
    * Get Area Sales Manager Profile
    */
    public static Profile getDSManagerProfile(){
        return [Select Id, Name From Profile where Name = :system.label.ASM_Profile_Name limit 1];
    }
    
    /*
    * Create Area Sales Manager Profile User
    */
    public static User createDSManagerUser(){
        Profile p = getDSManagerProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User DSManagerUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    PERNR__c='65658798',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
                                    );
                                    
        database.insert(DSManagerUser);       
        return DSManagerUser;       
    }
    /*
    * Get Sales Development Manager Profile
    */
    public static Profile getDSSupervisorProfile(){
        return [Select Id, Name From Profile where Name = :system.label.DS_Supervisor limit 1];
    }
    
    /*
    * Create Sales Development Manager Profile User
    */
    public static User createDSSupervisorUser(){
        Profile p = getDSSupervisorProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User DSSupervisorUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    PERNR__c='98644231',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
        insert DSSupervisorUser;        
        return DSSupervisorUser;        
    }
    
    /*
        Create Custom setting Record for Trigger use in Work.com application
    */ 
    public static void createCustomSettingRecords() {
    
        User user = [Select Id from User where Id=:UserInfo.getUserId()];
        System.runAs(user) { 
            
            List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
            
            TriggerSettings__c userTrigger = new TriggerSettings__c();
            userTrigger.Name = 'UserTrigger';
            userTrigger.isActive__c = True;
            triggerSettingsList.add(userTrigger);
          
            
            TriggerSettings__c taskTrigger = new TriggerSettings__c();
            taskTrigger.Name = 'TaskTrigger';
            taskTrigger.isActive__c = True;
            triggerSettingsList.add(taskTrigger);
            
            TriggerSettings__c feedTrigger = new TriggerSettings__c();
            feedTrigger.Name = 'FeedItemTrigger';
            feedTrigger.isActive__c = True;
            triggerSettingsList.add(feedTrigger);
            
            TriggerSettings__c addressTrigger = new TriggerSettings__c();
            addressTrigger.Name = 'AddressTrigger';
            addressTrigger.isActive__c = True;
            triggerSettingsList.add(addressTrigger);
            
            TriggerSettings__c planTrigger = new TriggerSettings__c();
            planTrigger.Name = 'PlanTrigger';
            planTrigger.isActive__c = True;
            triggerSettingsList.add(planTrigger);
            
              
            TriggerSettings__c metricTrigger = new TriggerSettings__c();
            metricTrigger.Name = 'MetricTrigger';
            metricTrigger.isActive__c = True;
            triggerSettingsList.add(metricTrigger);
             
            TriggerSettings__c goalTrigger = new TriggerSettings__c();
            goalTrigger.Name = 'GoalTrigger';
            goalTrigger.isActive__c = True;
            triggerSettingsList.add(goalTrigger);
                                                
            Database.insert(triggerSettingsList);
        }       
    } 
    
    /*
        Create Custom setting Record for Trigger use in Work.com application other than Current Context User.
    */ 
    public static void createCustomSettingOtherRecords() {
        List<TriggerSettings__c> triggerSettingsList = new List<TriggerSettings__c>();
        
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = True;
        triggerSettingsList.add(userTrigger);  
        
        Database.insert(triggerSettingsList); 
    }
   
    
    // Create Test Data for CreateGoalsBatch
    // Author: Malay Desai, Accenture;
    public static void populateTestDataForCreateGoalBatch(){
        User dsr = createDSRepUser();
        
        // Create GoalTemplate CustomSetting
        GoalTemplateDates__c  gt = new GoalTemplateDates__c();
        gt.Name = 'Default';
        gt.Current_Period_Due_Date__c = Date.newinstance(2015, 8, 21);
        gt.Current_Period_Start_Date__c = Date.newinstance(1960, 8, 5);
        insert gt;
        
        // Create expired Goal record and related Metrics record
        Goal expiredGoal = createGoal(); // Standard obj
        expiredGoal .Profile_Name__c = getDSRepProfile().Name;
        expiredGoal .Region__c = dsr.Region__c;
        expiredGoal .StartDate = Date.newinstance(2015, 6, 22);
        expiredGoal .DueDate = Date.newinstance(2015, 7, 21);
        expiredGoal.Status='Draft';
        expiredGoal.Name='RGU';
        expiredGoal.OwnerId=dsr.Id;
        
        update expiredGoal;
        
        List<Metric> metrics = CreateMetric();
        List<Metric> updatedMetrics = new List<Metric>();
        for(Metric m : metrics){ 
            m.GoalId = expiredGoal.Id;  
            m.OwnerId = expiredGoal.OwnerId;
            m.Status = 'Behind';
            m.DueDate = Date.newinstance(2015, 7, 21);
            updatedMetrics.add(m);
        }
        
        update updatedMetrics;
       
        // Create New Goal Template records
        Goal g = createGoal(); // Standard obj
        g.Profile_Name__c = getDSRepProfile().Name;
       
        g.Region__c = dsr.Region__c;
        g.StartDate = gt.Current_Period_Start_Date__c;
        g.DueDate = gt.Current_Period_Due_Date__c;
        g.Level__c=dsr.Level__c;
        g.Sales_Rep_Type__c =dsr.Sales_Rep_Type__c;
        update g;
        
        List<Metric> newmetrics = CreateMetric();
        List<Metric> updatedNewMetrics = new List<Metric>();
        for(Metric m : newmetrics ){ 
            m.GoalId = g.Id;   
          
            m.TargetValue = 100;
            m.DueDate = gt.Current_Period_Due_Date__c;
            m.LastComment ='new';
            m.CurrentValue = 10;
            m.Status = 'Behind';
            updatedNewMetrics.add(m);
            
        }
        update updatedNewMetrics;
        
        // Create Goal__c custom setting record
        /*List<Goal__c> goals = new List<Goal__c>();
        Goal__c goal = new Goal__c(); //Custom Setting
        goal.Name= 'Test';
        goal.goalId__c = g.Id;  
          
        goal.ProfileName__c= getDSRepProfile().Name;
        goal.Region_Name__c = dsr.Region__c;
        goal.RepType__c= dsr.Sales_Rep_Type__c;
        goal.Goal_Template_Type__c = 'RGU';
        goals.add(goal);
        insert goals;   */
   }            
    // Create Test Data for QM_QuotaAnnualBaselineBatch
    // Author: Suchita Sharma, Accenture;
     /*
    *  Create Quota Goal Record's
    */
    Public static Goal createQuotaGoal(){
        Goal goalObject = new Goal();
        goalObject.Name = 'Test Goal';
        goalObject.Status = 'Draft';
        goalObject.RecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId(); 
        goalObject.OwnerId = UserInfo.getUserId();
        insert goalObject;
        return goalObject; 
    }
    
    /*
    *  Create Quota Metric Record's
    */
    Public static List<Metric> createQuotaMetric(){
        List<Metric> merticList = new List<Metric>();
        for(integer i=0; i<3; i++){
            Metric MetricObj = new Metric();
            MetricObj.OwnerId = UserInfo.getUserId();
            if(i==0){
                MetricObj.Name = 'Winback';                               
            }
            else if(i==1){
                MetricObj.Name = 'New Build';               
            }
            else{
                MetricObj.Name = 'Renewal';               
            }
            MetricObj.TargetValue = 100;
            
            merticList.add(MetricObj);
        }
        Database.Insert(merticList);
        return merticList;  
    }
    // Create Test Data for QM_NEDQuotaBath
    // Author: Sucheta Verma, Accenture;
     /*
    *  Create Quota Goal Record's
    */
    Public static Goal createNEDQuotaGoal(){
        Goal goalObject = new Goal();
        goalObject.Name = 'Test Goal';
        goalObject.Status = 'Draft';
        goalObject.RecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId(); 
        goalObject.OwnerId = UserInfo.getUserId();
        insert goalObject;
        return goalObject; 
    }
    /*
    *  Create NEDQuota Metric Record's
    */
    Public static List<Metric> createNEDQuotaMetric(){
        List<Metric> merticList = new List<Metric>();
            Metric MetricObj = new Metric();
            MetricObj.OwnerId = UserInfo.getUserId();
            MetricObj.Name = 'Units';                               
            MetricObj.TargetValue = 100;
            merticList.add(MetricObj);
            Database.Insert(merticList);
          return merticList;  
    }
    
     // Create Test Data for RegionalBaselineQuotaBatch
    // Author: Sucheta Verma, Accenture;
     /*
    *  Create Quota Goal Record's for Regional Baseline
    */
    Public static Goal createRegionalQuotaGoal(){
        Goal goalObject = new Goal();
        goalObject.Name = 'Test Goal';
        goalObject.Status = 'Draft';
        goalObject.RecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId(); 
        goalObject.OwnerId = UserInfo.getUserId();
        insert goalObject;
        return goalObject; 
    }
    
    /*
    *  Create Quota Metric Record's
    */
    Public static List<Metric> createRegionalQuotaMetric(){
        List<Metric> merticList = new List<Metric>();
        for(integer i=0; i<3; i++){
            Metric MetricObj = new Metric();
            MetricObj.OwnerId = UserInfo.getUserId();
            if(i==0){
                MetricObj.Name = 'Units';                               
            }
            else if(i==1){
                MetricObj.Name = 'New Business';               
            }
            else{
                MetricObj.Name = 'XoC';               
            }
            MetricObj.TargetValue = 100;
            
            merticList.add(MetricObj);
        }
        Database.Insert(merticList);
        return merticList;  
    }
    /* Get XC Account Executive  Profile
    */
    public static Profile getAEProfile(){
        return [Select Id, Name From Profile where Name = 'XC Account Executive' limit 1];
    }
    
    /*
    * Create XC Account Executive Profile User
    */
    public static User createAEUser(){
        Profile p = getAEProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User AEUser = new User(Alias = 'AE_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    PERNR__c = 'testwe16',
                                    Terms_and_Conditions_Accepted__c = system.today());
                 
        return AEUser;
    }
     
     /* Get System ADministrator  Profile
    */
    public static Profile getSAdminProfile(){
        return [Select Id, Name From Profile where Name = 'System Administrator' limit 1];
    }      
     /*
    * Create System Administrator Profile User
    */
    public static User createSAdminUser(){
        Profile p = getSAdminProfile();
        //generate Random String 
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User AdminUser = new User(Alias = 'AE_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',                                    
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    IsActive = true,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today());
                 
        return AdminUser;
    }
    /*
     *  This method create custom setting record for MatricDailyUpdateTimeZone custom setting
     *  Author : Ashish Sonawane 
    */   
    public static void setMatricDailyUpdateTimeZoneCS(){
         MatricDailyUpdateTimeZone__c timeZoneCS = new MatricDailyUpdateTimeZone__c();
         timeZoneCS.Name = 'KnockTimeZone';
         timeZoneCS.DispPmStartTime__c = 16;
         timeZoneCS.DispPmEndTime__c = 21;
         Database.insert(timeZoneCS);
    }
    
    
     /*
      * This method create custom setting record for GoalTemplateDates custom setting
      * Author : Ashish Sonawane
      */       
    public static void setGoalTemplateDateCS(){
        GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
        goalTemplateDateCS.Name = 'Default';
        goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
        goalTemplateDateCS.Current_Period_Start_Date__c = System.Today().addDays(-2);
        Database.insert(goalTemplateDateCS);
    }
    
      /*
      * This method create custom setting record for ByWeeklyStartAndEndDate custom setting use in dailyupdate and monthly batch
      * Author : Ashish Sonawane
      */       
    public static void setGoalTemplateBiWeeklyDateCS(){
        GoalTemplateDates__c  goalBiWeeklyStartAndEndCS = new GoalTemplateDates__c();
        goalBiWeeklyStartAndEndCS.Name = 'ByWeeklyStartAndEndDate';
        goalBiWeeklyStartAndEndCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
        goalBiWeeklyStartAndEndCS.Current_Period_Start_Date__c = System.Today().addDays(-2);
        Database.insert(goalBiWeeklyStartAndEndCS);
    }
    /*
      * This method create custom setting record for MonthlyStartAndEndDateDS custom setting use in dailyupdate and monthly batch
      * Author : Ashish Srivastava
      */       
    public static void setGoalTemplateMonthlyDateCS(){
        GoalTemplateDates__c  goalMonthlyStartAndEndCS = new GoalTemplateDates__c();
        goalMonthlyStartAndEndCS.Name = 'MonthlyStartAndEndDateDS';
        goalMonthlyStartAndEndCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
        goalMonthlyStartAndEndCS.Current_Period_Start_Date__c = System.Today().addDays(-2);
        Database.insert(goalMonthlyStartAndEndCS);
    }
     /*
      * This method create custom setting record for ActivityGoalCommissionCycle custom setting use in dailyupdate and monthly batch
      * Author : Laxman Raj
      */       
    public static void ActivityGoalCommissionCycle(){
        GoalTemplateDates__c  ActivityGoalCommissionCycleCS = new GoalTemplateDates__c();
        ActivityGoalCommissionCycleCS .Name = 'ActivityGoalCommissionCycle';
        ActivityGoalCommissionCycleCS .Current_Period_Due_Date__c = System.Today().addDays(+2);
        ActivityGoalCommissionCycleCS .Current_Period_Start_Date__c = System.Today().addDays(-2);
        Database.insert(ActivityGoalCommissionCycleCS);
    }
    
    
    /*
     * This method create custom setting record for MDU_UserAccessToChangeOpptyStage__c
     * Author : Lalit Singh
    */  
    public static void userAccessOppyCS(Id xcUserId){
        MDU_UserAccessToChangeOpptyStage__c setting = new MDU_UserAccessToChangeOpptyStage__c();
        setting.Name = 'Test Setting';
        setting.Disable_Validation_Rule__c = True;
        setting.SetupOwnerId = xcUserId;
        insert setting;        
    }
    public static User createCARUser(){
    Profile profile1 = [Select Id, Name From Profile where Name = 'Xfinity CAR' limit 1];
        
        //generate Random String 
       String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User CARuser1 = new User(Alias = 'CAR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = profile1.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4), 
                                    IsActive =True,
                                    Level__c='Level',                
                                   Terms_and_Conditions_Accepted__c = system.today());
                   insert CARuser1 ;
        return CARuser1 ;
    }
     public static User createCARManagerUser(){
      Profile profile2 = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' limit 1];
        
        //generate Random String 
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User CARmanager1 = new User(Alias = 'CAR_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest1@SampleTest.com',
                                    FirstName='Testing2',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = profile2.Id,
                                    Username = 'userTest1' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'Freedom',
                                    FederationIdentifier = 'FedId1'+randomstr1,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4), 
                                    IsActive =True,
                                    Level__c='Level',                
                                   Terms_and_Conditions_Accepted__c = system.today());
                    insert CARmanager1 ; 
                    return CARmanager1 ;
         }
         
          
     /*
      * This method create custom setting record for GoalTemplateDates custom setting for property lab 
      * Author : Ashish Sonawane
      */       
    public static void setGoalTemplateDateForPropertyLabCS(){
        GoalTemplateDates__c  goalTemplateDateCS = new GoalTemplateDates__c();
        goalTemplateDateCS.Name = 'Property Lab CAR';
        goalTemplateDateCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
        goalTemplateDateCS.Current_Period_Start_Date__c = System.Today().addDays(-2);
        Database.insert(goalTemplateDateCS);
    }    
}