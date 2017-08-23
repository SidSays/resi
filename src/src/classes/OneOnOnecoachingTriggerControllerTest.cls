@isTest
private class OneOnOnecoachingTriggerControllerTest{
    
    
    User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()]; 
    
    static void AssignPermissionSet(String permissionSetName, Id userId){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);      
    }
    
    static testMethod void createCoaching(){ 
    
        TriggerSettings__c userTrigger = new TriggerSettings__c();
        userTrigger.Name = 'UserTrigger';
        userTrigger.isActive__c = False;
        insert userTrigger;
        TriggerSettings__c goalTrigger = new TriggerSettings__c();
        goalTrigger.Name = 'GoalTrigger';
        goalTrigger.isActive__c = False;
        insert goalTrigger;
        TriggerSettings__c metricTrigger = new TriggerSettings__c();
        metricTrigger.Name = 'MetricTrigger';
        metricTrigger.isActive__c = False;
        insert metricTrigger;
    
        TriggerSettings__c taskTrigger = new TriggerSettings__c();
        taskTrigger.Name = 'TaskTrigger ';
        taskTrigger.isActive__c = False;
        insert taskTrigger;
        
        TriggerSettings__c OneOnOnecoachingTrigger= new TriggerSettings__c();
        OneOnOnecoachingTrigger.Name = 'OneOnOnecoachingTrigger';
        OneOnOnecoachingTrigger.isActive__c = true;
        insert OneOnOnecoachingTrigger;
        TriggerSettings__c FeedItemsTrigger= new TriggerSettings__c();
        FeedItemsTrigger.Name = 'FeedItemTrigger';
        FeedItemsTrigger.isActive__c = False;
        insert FeedItemsTrigger;
        list<Variable_Setting__c> lstvariable = new list<Variable_Setting__c>();
        Variable_Setting__c objvariable;
        objvariable = new Variable_Setting__c();
        objvariable.Name ='CARManagerPermissionSet' ;
        objvariable.Description__c = 'CAR Manager permission set';
        objvariable.Value__c = 'SalesSpace Coach Access- CAR Manager';
        lstvariable.add(objvariable);
        objvariable = new Variable_Setting__c();
        objvariable.Name ='goalstatus' ;
        objvariable.Description__c = 'Goal Status for Metric update ';
        objvariable.Value__c = 'Published';
        lstvariable.add(objvariable);
        objvariable = new Variable_Setting__c();
        objvariable.Name ='metricincreasecounter' ;
        objvariable.Description__c = '1:1 Metric update based on creation of new 1:1 coaching record.';
        objvariable.Value__c = '1';
        lstvariable.add(objvariable);
        objvariable = new Variable_Setting__c();
        objvariable.Name ='OneonOneMetricName' ;
        objvariable.Description__c = 'Metric Name for Actual Update for Property Lab channel';
        objvariable.Value__c = '1:1 Coaching';
        /*objvariable = new Variable_Setting__c();
        objvariable.Name ='RetailStoreManagerProfileId' ;
        objvariable.Description__c = 'Profile id for retail sales manager';
        objvariable.Value__c = '00ec0000000HyPhAAK';*/
        lstvariable.add(objvariable);

        insert(lstvariable);
        WorkTestDataUtility.setGoalTemplateDateForPropertyLabCS();      
        Id recordTypeId_1_1 = Schema.SObjectType.Task.getRecordTypeInfosByName().get('1:1 Coaching').getRecordTypeId();
        List<one_one_Coaching__c> OneonOnelist = new List<one_one_Coaching__c>();
     
        User sdmUser = WorkTestDataUtility.createDSSupervisorUserForCoaching();
        sdmUser.UserPermissionsWorkDotComUserFeature = true;
        sdmUser.Terms_and_Conditions_Accepted__c = System.today();
        insert sdmUser;

        WorkCoaching coachingRecord= new WorkCoaching();
        user  dsrUser= WorkTestDataUtility.createDSRepUserForCoaching();
        dsrUser.UserPermissionsWorkDotComUserFeature = true;
        //dsrUser.Chatter_Enabled__c = true;
        dsrUser.ManagerId= sdmUser.Id;
        dsrUser.Terms_and_Conditions_Accepted__c = System.today();
        dsrUser.PERNR__c= '10254428';
        insert dsrUser;
     
     
    /* 
    User dsrUser = [Select Id,ManagerId from User where isActive = true AND UserPermissionsWorkDotComUserFeature = true AND Terms_and_Conditions_Accepted__c != null AND ManagerID != null AND Manager.profileId = '00eG0000000FqAM' AND Manager.UserPermissionsWorkDotComUserFeature = true AND Chatter_Enabled__c = true ];
    User sdmUser = [Select Id from User where ID = :dsrUser.ManagerId AND profileId = '00eG0000000FqAM'  AND Terms_and_Conditions_Accepted__c != null AND isActive = true AND UserPermissionsWorkDotComUserFeature = true ];*/
    
        if(sdmUser!=null && dsrUser!=null){
            User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
            System.runAs(currentUser){            
                AssignPermissionSet('SalesSpace_Coach_Access_SDM',sdmUser.Id);   
                AssignPermissionSet('SalesSpace_Coach_Access_XSP',dsrUser.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_CAR_Manager',sdmUser.Id);
                AssignPermissionSet('SalesSpace_Coach_Access_CAR',dsrUser.Id);
                Goal goalObject = new Goal();
                goalObject.Name = 'Test Goal';
                goalObject.Status = 'Published';
                goalObject.StartDate = System.Today().addDays(-2);
                goalObject.DueDate = System.Today().addDays(+2);
                goalObject.ownerId = sdmUser.Id;
                goalObject.RecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Property Lab').getRecordTypeId();
                insert goalObject;
                List<Metric> merticList = new List<Metric>();
                for(integer i=0; i<4; i++){
                    Metric MetricObj = new Metric();
                    if(i==0){
                        MetricObj.Name = '1:1 Coaching';                               
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
                    MetricObj.goalid = goalObject.id;
                    
                    //MetricObj.Status = 'Not Started';
                    merticList.add(MetricObj);
                
                }
                Database.Insert(merticList);
       
   
                coachingRecord.CoachId = sdmUser.Id;
                coachingRecord.CoachedId = dsrUser.Id;
                insert coachingRecord;
                system.debug('1'+coachingRecord.id); 
            
        
                one_one_Coaching__c coach = new one_one_Coaching__c();   
                coach.coaching__c = coachingRecord.id;
                coach.Action_Plan__c = 'TEST';
                coach.Manager_Comments__c='Test Comments';
                coach.Opportunities__c='Test Opportunity';
                coach.Strengths__c='Test strenght';
                OneonOnelist.add(coach);
                insert OneonOnelist;
             
                Task tsk = new Task();
                tsk.Ownerid = UserInfo.getUserId();
                tsk.Status ='Completed';
                tsk.Subject ='1:1 Coaching';
                tsk.RecordTypeId = recordTypeId_1_1;
                tsk.ActivityDate= System.Today();
                tsk.WhatId = coach.Coaching__c;
                insert tsk;
            }
        }  
        list<one_one_Coaching__c> lstoneone = [Select id, Name, Coach_Id__c,coaching__c,Action_Plan__c,
                                            Manager_Comments__c,Opportunities__c,Strengths__c from one_one_Coaching__c
                                            where id=:OneonOnelist[0].id];
                                            system.debug('lstoneone-->'+lstoneone);
        OneOnOnecoachingTriggerController.OneOnOneCoachingValidation(OneonOnelist);
        OneOnOnecoachingTriggerController.coachingTaskMapping(OneonOnelist) ;
        OneOnOnecoachingTriggerController.updatemetricsrecord(lstoneone);
    }
    
    public static testmethod void updateRetailManagerMetricTest(){        
        string goalGoaltemplateRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId(); 
        string goalIndirecttemplateRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Indirect Sales').getRecordTypeId();
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.createCustomSettingOtherRecords();
        
        GoalTemplateDates__c  indirectgoalStartAndEndCS = new GoalTemplateDates__c();
        indirectgoalStartAndEndCS.Name = 'IndirectActivityGoalCommissionCycle';
        indirectgoalStartAndEndCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
        indirectgoalStartAndEndCS.Current_Period_Start_Date__c = System.Today().addDays(-2);
        Database.insert(indirectgoalStartAndEndCS);
               
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
        
        Profile retailSalesRepMgr = [Select Id, Name From Profile where Name = 'Retail Sales Manager' limit 1];
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1151)+'';
        User retailSalesRepMgrUser = new User(Alias = 'C_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = retailSalesRepMgr.Id,
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
        insert retailSalesRepMgrUser;
        Profile retailSalesRep = [Select Id, Name From Profile where Name = 'Retail Sales Rep' limit 1];
        String randomstr1 = Math.round(Math.random()*Math.pow(10, 7)+1153)+'';
        User retailSalesRepUser = new User(Alias = 'C_' + randomstr1.substring(0,4),
                                    Email = randomstr1 + 'userTest11@SampleTest.com',
                                    FirstName='Testing11',
                                    LastName='Testing21',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = retailSalesRep.Id,
                                    Username = 'userTest11' + randomstr1 + '@SampleTest.com',
                                    Region__c = 'California Market',
                                    Sales_Rep_Type__c='RepType',
                                    IsActive =True,
                                    Level__c='Level', 
                                    FederationIdentifier = 'FedId1'+randomstr1,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr1.substring(0,4),
                                    ManagerId= retailSalesRepMgrUser.Id,
                                    Terms_and_Conditions_Accepted__c = system.today()
                  
                          );
        insert retailSalesRepUser;
        //Assign PermissionSet to Coresponding Profile user        
        System.runAs(new User(Id=userInfo.getUserId())){
            assignPermissionSet('SalesSpace_Coach_Access_Retail_Sales_Manager',retailSalesRepMgrUser.Id);            
            assignPermissionSet('SalesSpace_Coach_Access_Retail_Rep',retailSalesRepUser.Id);   
        }
        List<Metric> metricUpdateList = new List<Metric>(); 
                  
        // Create  Goal record and related Metrics record for Activity
        Goal retailActivityGoalTemplate = WorkTestDataUtility.createGoal(); // Standard obj
        retailActivityGoalTemplate.Profile_Name__c = System.Label.Retail_Sales_Manager_ProfileName;
        retailActivityGoalTemplate.Region__c = retailSalesRepMgrUser.Region__c;
        retailActivityGoalTemplate.StartDate = System.Today().addDays(-2);
        retailActivityGoalTemplate.DueDate = System.Today().addDays(+2);
        retailActivityGoalTemplate.Status='Published';
        retailActivityGoalTemplate.Template_Type__c = 'Activity';
        retailActivityGoalTemplate.RecordTypeId = goalGoaltemplateRecordTypeId;
        
        Database.update(retailActivityGoalTemplate);
        
        List<Metric> merticList = new List<Metric>();
        for(integer i=0; i<1; i++){
            Metric MetricObj = new Metric();
            if(i==0){
                MetricObj.Name = 'Total Number of Store Visits';
                MetricObj.TargetValue = 40;             
            }else if(i==1){
                MetricObj.Name = 'Average Store Visit Duration';
                MetricObj.TargetValue = 60;             
            }else if(i==2){
                MetricObj.Name = 'Completed Observations';
                MetricObj.TargetValue = 4;
            }else if(i==3)  {
                MetricObj.Name = 'Number of 1:1s';
                MetricObj.TargetValue = 3;
            }           
            merticList.add(MetricObj);
        }
        database.insert(merticList,true);
        for(Metric m : merticList){ 
            m.GoalId = retailActivityGoalTemplate.Id;              
            m.DueDate = Date.newinstance(2015, 8, 21);
            metricUpdateList.add(m);
        }
        Database.update(metricUpdateList,true);
    
        List<one_one_Coaching__c> OneonOnelist = new List<one_one_Coaching__c>();
        WorkCoaching coachingRecord= new WorkCoaching();
        coachingRecord.CoachId = retailSalesRepMgrUser.Id;
        coachingRecord.CoachedId = retailSalesRepUser.Id;
        insert coachingRecord;

        one_one_Coaching__c coach = new one_one_Coaching__c();   
        coach.coaching__c = coachingRecord.id;
        coach.Action_Plan__c = 'TEST';
        coach.Manager_Comments__c='Test Comments';
        coach.Opportunities__c='Test Opportunity';
        coach.Strengths__c='Test strenght';
        coach.Status__c='Draft';
        OneonOnelist.add(coach);
        insert OneonOnelist;
    
        list<one_one_Coaching__c> lstoneone = [Select id, Name, Coach_Id__c,coaching__c,Action_Plan__c,
                                            Manager_Comments__c,Opportunities__c,Strengths__c from one_one_Coaching__c
                                            where id=:OneonOnelist[0].id];
        OneOnOnecoachingTriggerController.updateRetailManagerMetric(lstoneone);
    }
}