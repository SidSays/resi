@isTest
private class CrossRegionGoalBatchTestNew {
    
    private static Profile CrossRegionalLeadProfile,XfinityCARProfile,XfinityManagerProfile;
    private static User XfinityCAR, XfinityManager,CrossRegionalLead;
    private static GoalTemplateDates__c gtXC, gtCAR;
    private static TriggerSettings__c  ts1, ts2,ts3;
    private static Goal goalXCObj, goalCARObj,goalCARObj1;
    private static Metric metricObj;
    private static User loggedInUser = [Select Id from User where Id=:UserInfo.getUserId()];
    
    @testSetup
    static void CreateTestData(){
        
        CrossRegionalLeadProfile = [SELECT Id,Name FROM Profile WHERE Name = 'CAR/XC Regional Lead' LIMIT 1];
        XfinityCARProfile = [SELECT Id,Name FROM Profile WHERE Name = 'Xfinity CAR' LIMIT 1];
        XfinityManagerProfile = [SELECT Id,Name FROM Profile WHERE Name = 'XC Manager' LIMIT 1];
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
          
        ts1 = new TriggerSettings__c();
        ts1.Name = 'UserTrigger';
        ts1.isActive__c = true;
          
        ts2 = new TriggerSettings__c();
        ts2.Name = 'GoalTrigger';
        ts2.isActive__c = true;
          
        ts3 = new TriggerSettings__c();
        ts3.Name = 'MetricTrigger';
        ts3.isActive__c = true;
          
        insert new List<TriggerSettings__c>{ts1, ts2,ts3};
        
        XfinityCAR = new User(Alias = 'CAR' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CAR', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = XfinityCARProfile.Id,
                                      Username = 'userTest1' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId1'+randomstr,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
                                      
        XfinityManager = new User(Alias = 'MGR' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest2@SampleTest.com',
                                      LastName='MGR', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = XfinityManagerProfile.Id,
                                      Username = 'userTest2' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId2'+randomstr,
                                      EmployeeNumber = 'Emp2' + randomstr.substring(0,4));
                                      
        CrossRegionalLead = new User(Alias = 'CR' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest3@SampleTest.com',
                                      LastName='CRLead', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CrossRegionalLeadProfile.Id,
                                      Username = 'userTest3' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId3'+randomstr,
                                      EmployeeNumber = 'Emp3' + randomstr.substring(0,4));
                                
        insert new List<User>{XfinityCAR,XfinityManager,CrossRegionalLead};
        
        
        System.runAs(loggedInUser){
            
            gtXC = new GoalTemplateDates__c();
            gtXC.Name = 'CrossRegionXCGoal';
            gtXC.Current_Period_Start_Date__c = Date.newinstance(2016, 02, 22);
            gtXC.Current_Period_Due_Date__c = Date.newinstance(2016, 03, 21);
            
            gtCAR = new GoalTemplateDates__c();
            gtCAR.Name = 'CrossRegionCARGoal';
            gtCAR.Current_Period_Start_Date__c = Date.newinstance(2016, 02, 22);
            gtCAR.Current_Period_Due_Date__c = Date.newinstance(2016, 03, 21); 
            
            insert new List<GoalTemplateDates__c>{gtXC,gtCAR};
            List<Goal> goalList = new List<Goal>();
            
            
            goalXCObj = new Goal();
            goalXCObj.Status = 'Draft';
            goalXCObj.Profile_Name__c = 'XC Manager';
            goalXCObj.OwnerId = loggedInUser.id;
            goalXCObj.Name = 'Cross Regional Lead - XC - Freedom Market';
            goalXCObj.recordtypeId = PL_Constants.XFINITY_COMMUNITIES_RECORD_TYPE_ID;
            goalXCObj.Template_Type__c = 'Xfinity Communities';
            goalXCObj.Region__c = 'Freedom Market';
            goalList.add(goalXCObj);
            
            goalCARObj = new Goal();
            goalCARObj.Status = 'Draft';
            goalCARObj.Profile_Name__c = 'Xfinity CAR';
            goalCARObj.OwnerId = loggedInUser.id;
            goalCARObj.Name = 'Cross Regional Lead - PL - Freedom Market';
            goalCARObj.recordtypeId = PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID;
            goalCARObj.Template_Type__c = 'Property Lab';
            goalCARObj.Region__c = 'Freedom Market';
            goalList.add(goalCARObj);
            
            goalCARObj1 = new Goal();
            goalCARObj1.Status = 'Completed';
            goalCARObj1.Profile_Name__c = 'Xfinity CAR';
            goalCARObj1.OwnerId = loggedInUser.id;
            goalCARObj1.Name = 'Cross Regional Lead - PL - Freedom Market';
            goalCARObj1.recordtypeId = PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID;
            goalCARObj1.Template_Type__c = 'Property Lab';
            goalCARObj1.Region__c = 'Freedom Market';
            goalList.add(goalCARObj1);
            
            Goal objGoal= new Goal ();               
            objGoal.Name= 'Cross Regional Lead Goal ';
            objGoal.Status = 'Published';
            objGoal.ownerId= XfinityCAR.Id;
            objGoal.Assigned_To__c = XfinityCAR.Id;
            objGoal.Template_Type__c = 'Property Lab';
            objGoal.RecordTypeId = PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID;
            objGoal.StartDate= gtXC.Current_Period_Start_Date__c;
            objGoal.DueDate= gtXC.Current_Period_Due_Date__c ;
            objGoal.Region__c = XfinityCAR.Region__c;
            objGoal.Profile_Name__c= XfinityCAR.profile.name;
            goalList.add(objGoal);
                            
            Database.insert(goalList,false);
            
           //insert new List<Goal>{goalXCObj,goalCARObj};
            
            List<Metric> merticList = new List<Metric>();
            for(Integer i=0;i<6;i++){
                metricObj = new Metric();
                metricObj.OwnerId = UserInfo.getUserId();
                if(i==0){
                    metricObj.Name = 'Units';
                    metricObj.TargetValue = 1;
                    metricObj.GoalId = goalXCObj.Id;
                    
                }
                else if(i==1){
                    metricObj.Name = 'New Business';
                    metricObj.TargetValue = 1;
                    metricObj.GoalId = goalXCObj.Id;
                }
                else if(i==2){
                    metricObj.Name = 'Total Property Visits Per Month';
                    metricObj.TargetValue = 80;
                    metricObj.GoalId = goalCARObj.Id;
                    //metricObj.Status__c ='Completed';
                }
                else if(i==3){
                    metricObj.Name = 'Profile Completion Percent'; 
                    metricObj.TargetValue = 100;
                    metricObj.GoalId = goalCARObj.Id; 
                    //metricObj.Status__c ='Completed';                 
                }
                else if(i==4){
                    metricObj.Name = 'Average Property Visits per day'; 
                    metricObj.TargetValue = 4;
                    metricObj.GoalId = goalCARObj1.Id;
                    metricObj.Status__c ='Completed';
                }
                else{
                    metricObj.Name = 'Sales Events';  
                    metricObj.TargetValue = 2;
                    metricObj.GoalId = goalCARObj1.Id;
                    metricObj.Status__c ='Completed';                   
                }
                merticList.add(metricObj);
            }
            Database.insert(merticList,false);
            
                
                
                
        }
    }
    
    /*@isTest
    static void Test_CrossRegionXCBatch(){
        Test.startTest();{
            String queryString = 'Select Id, Name,Profile.name,Region__c from User where IsActive = True AND Profile.Name IN: profileNameSet' 
            + ' and UserPermissionsWorkDotComUserFeature = true AND LastName = \'CRLead\''; 
            database.executebatch(new CrossRegionXCGoalBatch(queryString),1);
        Test.stopTest();
        }
    }*/
    
    @isTest
    static void Test_CrossRegionCARBatch(){
        Test.startTest();{
            String queryString = 'Select Id, Name,Profile.name,Region__c from User where IsActive = True AND Profile.Name IN: profileNameSet' 
            + ' and UserPermissionsWorkDotComUserFeature = true AND LastName = \'CRLead\''; 
            database.executebatch(new CrossRegionCARGoalBatch(queryString),1);
        Test.stopTest();
        }
    }
}