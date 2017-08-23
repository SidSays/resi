/**************************************************************************************************
Name : CreateSdmAsmActivityGoalBatchTest
Description : This batch class created to test CreateSdmAsmActivityGoalBatch
User Story : US573830,US573832.
Date : 7th December 2015
Author : Laxman Raj
***************************************************************************************************/

@isTest
private class CreateSdmAsmActivityGoalBatchTest 
{
   
    static testmethod void testCreateSdmAsmActivityGoalBatch() {
        
        List<Goal> newGoalList = new List<Goal>();
        string goalGoaltemplateRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId(); 
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.ActivityGoalCommissionCycle();
        User ManagerUser = WorkTestDataUtility.createDSManagerUser();
        
        //User SupervisorUser = WorkTestDataUtility.createDSSupervisorUser();
             Profile p = [Select Id, Name From Profile where Name = :system.label.DS_Supervisor limit 1];
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User SupervisorUser = new User(Alias = 'DSR_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    PERNR__c = '87698321',
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
        insert SupervisorUser;        
        Supervisoruser.ManagerId=ManagerUser.Id;
        update SupervisorUser;
        
        TriggerSettings__c metricTrigger = new TriggerSettings__c();
        metricTrigger.Name = 'MetricTrigger';
        metricTrigger.isActive__c = false;
        insert metricTrigger ;
            
        User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
        System.runAs(currentUser){            
            AssignPermissionSet('SalesSpace_Coach_Access_ASM',ManagerUser.Id);   
            AssignPermissionSet('SalesSpace_Coach_Access_SDM',SupervisorUser.Id);
        
        
         // Create  Goal record and related Metrics record for Activity
           GoalTemplateDates__c  gt = new GoalTemplateDates__c();
            gt.Name = 'ActivityGoalCommissionCycle';
            gt.Current_Period_Start_Date__c = Date.newinstance(2014, 12, 22);
            gt.Current_Period_Due_Date__c = Date.newinstance(2015, 01, 21); 
            insert gt;
        Goal g = new Goal();
        g.Name='Activity';
        g.Status = 'Published';
        g.Profile_Name__c = System.Label.DS_Supervisor;
        //WorkTestDataUtility.getDSManagerProfile().Name;
        g.Region__c = 'Freedom Market';
        g.StartDate = gt.Current_Period_Start_Date__c;
        g.DueDate = gt.Current_Period_Due_Date__c;
        g.Status='Published';
        g.Template_Type__c = 'Activity';
        g.Sales_Rep_Type__c = 'Winback';
        g.OwnerId=SupervisorUser.id;
        //SupervisorUser.Id;
        //g.Level__c= 'Xfinity Sales Associate';
        g.RecordTypeId = goalGoaltemplateRecordTypeId;
        insert g;
        system.debug('+++'+g);
        newGoalList.add(g);
           List<Metric> newmetrics = WorkTestDataUtility.CreateMetric();
        List<Metric> updatedNewMetrics = new List<Metric>();
        for(Metric m : newmetrics ){
            m.GoalId  = newGoalList[0].Id;
            m.OwnerId = newGoalList[0].OwnerId;
            m.Status = 'Completed';
            updatedNewMetrics.add(m);
        }
          update updatedNewMetrics;
     
   }    
    System.runAs(currentUser){
            test.startTest();
           CreateSdmAsmActivityGoalBatch cPPB = new CreateSdmAsmActivityGoalBatch('Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c, ManagerId from User where UserPermissionsWorkDotComUserFeature = true and isActive = true and firstname like \'Testing1\'');
           database.executebatch(cPPB );
         Test.stopTest(); 
         System.schedule('Scheduled Job 1', '0 0 * * * ?', new CreateSdmAsmActivityGoalBatchSchedule());
        }
      }             
        
     static void AssignPermissionSet(String permissionSetName, Id userId){
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        
        Database.insert(psa);
        
    }

}