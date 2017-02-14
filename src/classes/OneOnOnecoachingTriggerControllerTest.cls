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
    
      TriggerSettings__c taskTrigger = new TriggerSettings__c();
    taskTrigger.Name = 'TaskTrigger ';
    taskTrigger.isActive__c = False;
    insert taskTrigger;
    
    TriggerSettings__c OneOnOnecoachingTrigger= new TriggerSettings__c();
    OneOnOnecoachingTrigger.Name = 'OneOnOnecoachingTrigger';
    OneOnOnecoachingTrigger.isActive__c = False;
    insert OneOnOnecoachingTrigger;
            
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
     insert dsrUser;
     
    /* 
    User dsrUser = [Select Id,ManagerId from User where isActive = true AND UserPermissionsWorkDotComUserFeature = true AND Terms_and_Conditions_Accepted__c != null AND ManagerID != null AND Manager.profileId = '00eG0000000FqAM' AND Manager.UserPermissionsWorkDotComUserFeature = true AND Chatter_Enabled__c = true ];
    User sdmUser = [Select Id from User where ID = :dsrUser.ManagerId AND profileId = '00eG0000000FqAM'  AND Terms_and_Conditions_Accepted__c != null AND isActive = true AND UserPermissionsWorkDotComUserFeature = true ];*/
    
        if(sdmUser!=null && dsrUser!=null){
         User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
            System.runAs(currentUser){            
               AssignPermissionSet('SalesSpace_Coach_Access_SDM',sdmUser.Id);   
               AssignPermissionSet('SalesSpace_Coach_Access_XSP',dsrUser.Id);
         
       
   
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
        
        OneOnOnecoachingTriggerController.OneOnOneCoachingValidation(OneonOnelist);
        OneOnOnecoachingTriggerController.coachingTaskMapping(OneonOnelist) ;
    }
}