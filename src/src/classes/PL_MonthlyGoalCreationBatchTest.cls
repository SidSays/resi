@isTest
private class PL_MonthlyGoalCreationBatchTest 
{
  private static User xfinityCARUser1,xfinityCARUser2,xfinityCARUser3,xfinityCARManager1,xfinityCARManager2, CARDir1, CARDir2;
  private static Profile CARProfile, CARManagerProfile;
  private static PermissionSet ps,ps1;
  private static PermissionSetAssignment psa1,psa2,psa3,psa4;
  private static GoalTemplateDates__c  gt,gt1;
  private static TriggerSettings__c  ts1, ts2,ts3;
  private static Goal goalTemplate, oldGoal1,oldGoal2;
    private static Metric MetricObj, oldMetric;
    private static User loggedInUser = [Select Id from User where Id=:UserInfo.getUserId()];
    
    @testSetup
    static void CreateTestData () {          
                
          CARProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR' limit 1];
          CARManagerProfile = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' limit 1];
          
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
          
          CARDir1 = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARDIR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARManagerProfile.Id,
                                      Username = 'userTest1' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId1'+randomstr,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
                                      
          CARDir2 = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARDIR2', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARManagerProfile.Id,
                                      Username = 'userTest2' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId2'+randomstr,
                                      EmployeeNumber = 'Emp2' + randomstr.substring(0,4));                        
          
          insert new List<User>{CARDir1,CARDir2};
          
          randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
          
          xfinityCARManager1 = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARMGR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARManagerProfile.Id,
                                      Username = 'userTest3' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId1'+randomstr, ManagerId = CARDir1.Id,
                                      EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
                                      
      randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
      
      xfinityCARManager2 = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest1@SampleTest.com',
                                      LastName='CARMGR2', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARManagerProfile.Id,
                                      Username = 'userTest4' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId2'+randomstr,ManagerId = CARDir2.Id,
                                      EmployeeNumber = 'Emp2' + randomstr.substring(0,4));
                                                                            
          
          insert new List<User>{xfinityCARManager1,xfinityCARManager2};
          
          randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
          
          xfinityCARUser1 = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest3@SampleTest.com',
                                      LastName='CAR1', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARProfile.Id,
                                      Username = 'userTest5' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId3'+randomstr, ManagerId = xfinityCARManager1.Id,
                                      EmployeeNumber = 'Emp3' + randomstr.substring(0,4));
          
          randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
          
          xfinityCARUser2 = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest4@SampleTest.com',
                                      LastName='CAR2', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARProfile.Id,
                                      Username = 'userTest6' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = true,
                                      FederationIdentifier = 'FedId4'+randomstr, ManagerId = CARDir1.Id,
                                      EmployeeNumber = 'Emp4' + randomstr.substring(0,4));
      
      randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
      
      xfinityCARUser3 = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                      Email = randomstr + 'userTest5@SampleTest.com',
                                      LastName='CAR3', EmailEncodingKey='UTF-8', 
                                      LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                                      TimeZoneSidKey='America/Los_Angeles', ProfileId = CARProfile.Id,
                                      Username = 'userTest7' + randomstr + '@SampleTest.com',
                                      Region__c = 'Freedom Market', UserPermissionsWorkDotComUserFeature = false,
                                      FederationIdentifier = 'FedId5'+randomstr, ManagerId = CARDir2.Id,
                                      EmployeeNumber = 'Emp5' + randomstr.substring(0,4));                                      
          
          insert new List<User>{xfinityCARUser1,xfinityCARUser2,xfinityCARUser3};
                                     
          ps = [SELECT Id FROM PermissionSet WHERE Name = 'SalesSpace_Coach_Access_CAR' LIMIT 1] ;  
          ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Coach_CAR_Director_Manager' LIMIT 1] ;
          
          System.runAs(loggedInUser){
            psa1 = new PermissionSetAssignment(assigneeId=xfinityCARUser1.id,PermissionSetId = ps.Id);
            psa2 = new PermissionSetAssignment(assigneeId=xfinityCARManager1.id,PermissionSetId = ps.Id);
            psa3 = new PermissionSetAssignment(assigneeId=CARDir1.id,PermissionSetId = ps1.Id);
            psa4 = new PermissionSetAssignment(assigneeId=CARDir2.id,PermissionSetId = ps1.Id);
            insert new List<PermissionSetAssignment>{psa1,psa2,psa3,psa4};
            
              gt = new GoalTemplateDates__c();
              gt.Name = 'Property Lab CAR';
              gt.Current_Period_Start_Date__c = Date.newinstance(2015, 02, 22);
              gt.Current_Period_Due_Date__c = Date.newinstance(2015, 03, 21); 
              insert gt;
              
              gt1 = new GoalTemplateDates__c();
              gt1.Name = 'Property Lab CAR Director';
              gt1.Current_Period_Start_Date__c = Date.newinstance(2014, 12, 22);
              gt1.Current_Period_Due_Date__c = Date.newinstance(2015, 03, 21); 
              insert gt1;
              
              oldGoal1 = new Goal();
              oldGoal1.Status = 'Published';
              oldGoal1.Profile_Name__c = 'Xfinity CAR';
              oldGoal1.OwnerId = loggedInUser.id;
              oldGoal1.Name = 'Xfinity CAR - PL - Freedom Market';
              oldGoal1.RecordTypeId = PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID;
              oldGoal1.Template_Type__c = 'Property Lab';
              oldGoal1.DueDate = Date.newinstance(2014, 12, 21);
              
              oldGoal2 = new Goal();
              oldGoal2.Status = 'Published';
              oldGoal2.Profile_Name__c = 'Xfinity CAR';
              oldGoal2.OwnerId = loggedInUser.id;
              oldGoal2.Name = 'Xfinity CAR - PL - Freedom Market';
              oldGoal2.RecordTypeId = PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID;
              oldGoal2.Template_Type__c = 'Property Lab';
              oldGoal2.DueDate = Date.newinstance(2014, 12, 21);
              insert new List<Goal>{oldGoal1,oldGoal2};
              
                oldMetric = new Metric();
                oldMetric.OwnerId = UserInfo.getUserId();
                oldMetric.Name = 'Total Property Visits Per Month'; 
                oldMetric.TargetValue = 80;                          
                oldMetric.GoalId = oldGoal1.id;
                oldMetric.DueDate = Date.newinstance(2014, 12, 21);
              Database.insert(oldMetric);
              
              goalTemplate = new Goal();
              goalTemplate.Status = 'Draft';
              goalTemplate.Profile_Name__c = 'Xfinity CAR';
              goalTemplate.OwnerId = loggedInUser.id;
              goalTemplate.Name = 'Xfinity CAR - PL - Freedom Market - Monthly/Quaterly';
              goalTemplate.recordtypeId = PL_Constants.GOAL_TEMPLATE_RECORD_TYPE_ID;
              goalTemplate.Template_Type__c = 'Property Lab';
              goalTemplate.Region__c = 'Freedom Market';
              insert goalTemplate;
              
              List<Metric> merticList = new List<Metric>();
              for(integer i=0; i<9; i++){
                  metricObj = new Metric();
                  metricObj.OwnerId = UserInfo.getUserId();
                  if(i==0){
                      metricObj.Name = 'Total Property Visits Per Month'; 
                      metricObj.TargetValue = 80;                          
                  }
                  else if(i==1){
                      metricObj.Name = 'Profile Completion Percent'; 
                      metricObj.TargetValue = 100;              
                  }
                  else if(i==2){
                      metricObj.Name = 'Sales Events';  
                      metricObj.TargetValue = 2;            
                  }                
                  else if(i==3){
                      metricObj.Name = 'Average Property Visits per day'; 
                      metricObj.TargetValue = 4;              
                  }
                  else if(i==4){
                      metricObj.Name = '1:1 Coaching'; 
                      metricObj.TargetValue = 1;
                  }
                  else if(i==5){
                      metricObj.Name = '1:1 Super Coach Observation'; 
                      metricObj.TargetValue = 1;
                  }
                  else if(i==6){
                      metricObj.Name = 'Forum'; 
                      metricObj.TargetValue = 1;
                  }
                  else if(i==7){
                      metricObj.Name = 'Huddle Observation'; 
                      metricObj.TargetValue = 1;
                  }
                  else{
                      metricObj.Name = 'Field Observation Super Coach'; 
                      metricObj.TargetValue = 1;
                  }
                      MetricObj.GoalId = goalTemplate.id;
                      merticList.add(metricObj);
              }
              Database.insert(merticList);

          }    
     }         
     
     @isTest static void TestPL_MonthlyGoalCreationBatch1 (){    
       Test.startTest();
         system.runAs(loggedInUser){
            String queryString = 'Select Id, Name, ManagerId,Profile.name,Region__c from User where IsActive = True AND Profile.Name IN: profileNameSet' 
                      + ' and UserPermissionsWorkDotComUserFeature = true AND LastName = \'CAR1\''; 
            database.executebatch(new PL_MonthlyGoalCreationBatch(queryString),1);
         Test.stopTest(); 
         }
     }
     
     @isTest static void TestPL_MonthlyGoalCreationBatch2 (){    
       Test.startTest();
         system.runAs(loggedInUser){
            String queryString = 'Select Id, Name, ManagerId,Profile.name,Region__c from User where IsActive = True AND Profile.Name IN: profileNameSet' 
                      + ' and UserPermissionsWorkDotComUserFeature = false AND LastName = \'CAR2\''; 
            database.executebatch(new PL_MonthlyGoalCreationBatch(queryString),1);
         Test.stopTest(); 
         }
     }
     
     @isTest static void TestPL_CarMgrMonthlyGoalCreation1 (){    
       Test.startTest();
         system.runAs(loggedInUser){
            String queryString = 'Select Id, Name, ManagerId,Profile.name,Region__c from User where IsActive = True AND Profile.Name IN: profileNameSet' 
                      + ' and UserPermissionsWorkDotComUserFeature = true AND LastName = \'CARMGR1\''; 
            database.executebatch(new PL_CarMgrMonthlyGoalCreationBatch(queryString),1);
         Test.stopTest(); 
         }
     }
     
     @isTest static void TestPL_CarMgrMonthlyGoalCreation2 (){    
       Test.startTest();
         system.runAs(loggedInUser){
            String queryString = 'Select Id, Name, ManagerId,Profile.name,Region__c from User where IsActive = True AND Profile.Name IN: profileNameSet' 
                      + ' and UserPermissionsWorkDotComUserFeature = true AND LastName = \'CARMGR2\''; 
            database.executebatch(new PL_CarMgrMonthlyGoalCreationBatch(queryString),1);
         Test.stopTest(); 
         }
     }
     
     @isTest static void TestPL_CarDirMonthlyGoalCreation1 (){    
       Test.startTest();
         system.runAs(loggedInUser){
            String queryString = 'SELECT Id, Name, Profile.Name, Region__c FROM User WHERE Id IN :CARDirectorOrSrManagersIds AND UserPermissionsWorkDotComUserFeature = true' 
                      + ' AND LastName = \'CARDIR1\''; 
            database.executebatch(new PL_CARDirectorMonthlyGoalCreationBatch(queryString),1);
         Test.stopTest(); 
         }
     }
}