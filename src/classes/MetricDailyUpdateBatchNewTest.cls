@isTest
private class MetricDailyUpdateBatchNewTest{ 

     private static testMethod void createMetrics()
     {
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.setGoalTemplateBiWeeklyDateCS();
        WorkTestDataUtility.setMatricDailyUpdateTimeZoneCS();
        List<Metric> newMerticList = new List<Metric>();  
        List<Goal> newGoalList = new List<Goal>();
        List<User> userList = new List<User>();
        
        String DIRECT_SALES_REPR_PROFILE_ID = '00eG0000000FqAL';
        string goalDirectsaleRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();  
        string knockRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();       
        User repUser = WorkTestDataUtility.createDSRepUser();
        User SupervisorUser = WorkTestDataUtility.createDSSupervisorUser(); 
        User ManagerUser = WorkTestDataUtility.createDSManagerUser();
        repUser.ManagerId=SupervisorUser.Id;
        userList.add(repUser);
        SupervisorUser.ManagerId=ManagerUser.Id;
        userList.add(SupervisorUser);
        
        system.runAs(new User(Id=UserInfo.getUserId())){
            MetricTriggerController.allowValidation = false;
            database.update(userList,false);
            AssignPermissionSet('SalesSpace_Coach_Access_XSP',repUser.Id);
            AssignPermissionSet('SalesSpace_Coach_Access_SDM',SupervisorUser.Id); 
            AssignPermissionSet('SalesSpace_Coach_Access_ASM',SupervisorUser.Id); 
        
            Goal xspRGUGoal = WorkTestDataUtility.createGoal();
            xspRGUGoal.Name = 'Test RGU 1';
            xspRGUGoal.RecordTypeId = goalDirectsaleRecordTypeId;
            xspRGUGoal.OwnerId = repUser.Id;
            newGoalList.add(xspRGUGoal);           
            
            Goal xspACTGoal = WorkTestDataUtility.createGoal();
            xspACTGoal.Name = 'Test Activity 1';
            xspACTGoal.RecordTypeId = goalDirectsaleRecordTypeId;
            xspACTGoal.OwnerId = repUser.Id;
            newGoalList.add(xspACTGoal);
            
            Goal goalForSupervisor = WorkTestDataUtility.createGoal();
            goalForSupervisor.Name = 'Test RGU 2';
            goalForSupervisor.RecordTypeId = goalDirectsaleRecordTypeId;
            goalForSupervisor.OwnerId = SupervisorUser.id;
            newGoalList.add(goalForSupervisor);
            
            Database.update(newGoalList,false); 
            
            List<Metric> rGUmerticList = WorkTestDataUtility.CreateMetric();            
            List<Metric> activitymetrList = WorkTestDataUtility.CreateActivityMetric(); 
            List<Metric> merticSuperviserList = WorkTestDataUtility.CreateMetric();
            Database.insert(activitymetrList,false);
            
            for(Metric metric : rGUmerticList){
                metric.GoalId = xspRGUGoal.id;              
                newMerticList.add(metric);
            }
            
            for(Metric metric1 : activitymetrList){
                metric1.GoalId = xspACTGoal.id;  
                newMerticList.add(metric1);
            }
            
            for(Metric metric : merticSuperviserList){
                metric.GoalId = goalForSupervisor.id;           
                newMerticList.add(metric);
            } 
        }   
        
        Customer_Address__c addr = new Customer_Address__c();
        addr.Address__c = 'Test Address';
        addr.State__c = 'Test State';
        addr.City__c = 'Test City';
        addr.Country__c = 'Test Country';
        addr.PostalCode__c = '12345';
        addr.Node__c = '1111';
        addr.Corp__c = '11111111';
        addr.Route_Code__c = '1111111111';
        addr.Region__c = 'Freedom Market';
        addr.Latitude__c=41.405556;
        addr.Longitude__c=-81.664167;
        Database.insert(addr,false);
        List<Task> knockList = new List<Task>();
        //system.runAs(repUser){
        // Create & insert Knocks 
        for(Integer i=0;i<=8;i++){
            Task knock = new Task(); 
            knock.RecordTypeId = knockRecordTypeId;
            knock.WhatId = addr.Id;         
            knock.Event_Category__c = 'Fair';
            knock.Knocked_Date__c = system.Now();
            knock.OwnerId= repUser.Id;
            knock.status = 'Completed';
            knock.Created_Date_Custom__c = System.Today();
            if(i==0){
                knock.Disposition__c = 'No Answer';
            }
            if(i==1){
                knock.Disposition__c = 'No Knock';
            }
            if(i==2){
                knock.Disposition__c = 'Door Hanger';
            }
            if(i==3){
                knock.Disposition__c = 'Contact';
            }
            if(i==4){
                knock.Disposition__c = 'Engage';
            }
            if(i==5){
                knock.Disposition__c = 'Discover';
            }
            if(i==6){
                knock.Disposition__c = 'Start';
            }
            if(i==7){
                knock.Disposition__c = 'Close';
            }
            if(i==8){
                knock.Disposition__c = 'Position';
            }
            knockList.add(knock);
         }
         
        test.startTest();
            Database.insert(userList,false);
            database.update(newMerticList,false); 
            database.insert(knockList,false);
        Boolean isWest = false;
        String query1= 'SELECT Id From User WHERE IsActive = True AND ProfileId =: DIRECT_SALES_REPR_PROFILE_ID AND UserPermissionsWorkDotComUserFeature = true AND Region__c IN (\'Freedom Market\')';
        MetricDailyUpdateBatchNew metrBatchObj = new MetricDailyUpdateBatchNew(query1,isWest);       
        database.executeBatch(metrBatchObj,20);
       test.stopTest();
    }
    
    private static testMethod void createMetricsWest()
     {
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.setGoalTemplateMonthlyDateCS();
        WorkTestDataUtility.setMatricDailyUpdateTimeZoneCS();
        List<Metric> newMerticList = new List<Metric>();  
        List<Goal> newGoalList = new List<Goal>();
        List<User> userList = new List<User>();
        
        String DIRECT_SALES_REPR_PROFILE_ID = '00eG0000000FqAL';
        string goalDirectsaleRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();  
        string knockRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();       
        User repUser = WorkTestDataUtility.createDSRepUser();
        User SupervisorUser = WorkTestDataUtility.createDSSupervisorUser(); 
        User ManagerUser = WorkTestDataUtility.createDSManagerUser();
        repUser.ManagerId=SupervisorUser.Id;
        userList.add(repUser);
        SupervisorUser.ManagerId=ManagerUser.Id;
        userList.add(SupervisorUser);
      
        
        system.runAs(new User(Id=UserInfo.getUserId())){
            MetricTriggerController.allowValidation = false;
            database.update(userList,false);
            AssignPermissionSet('SalesSpace_Coach_Access_XSP',repUser.Id);
            AssignPermissionSet('SalesSpace_Coach_Access_SDM',SupervisorUser.Id); 
            AssignPermissionSet('SalesSpace_Coach_Access_ASM',SupervisorUser.Id); 
        
            Goal xspRGUGoal = WorkTestDataUtility.createGoal();
            xspRGUGoal.Name = 'Test RGU 1';
            xspRGUGoal.RecordTypeId = goalDirectsaleRecordTypeId;
            xspRGUGoal.OwnerId = repUser.Id;
            newGoalList.add(xspRGUGoal);           
            
            Goal xspACTGoal = WorkTestDataUtility.createGoal();
            xspACTGoal.Name = 'Test Activity 1';
            xspACTGoal.RecordTypeId = goalDirectsaleRecordTypeId;
            xspACTGoal.OwnerId = repUser.Id;
            newGoalList.add(xspACTGoal);
            
            Goal goalForSupervisor = WorkTestDataUtility.createGoal();
            goalForSupervisor.Name = 'Test RGU 2';
            goalForSupervisor.RecordTypeId = goalDirectsaleRecordTypeId;
            goalForSupervisor.OwnerId = SupervisorUser.id;
            newGoalList.add(goalForSupervisor);
            
            Database.update(newGoalList,false); 
            
            List<Metric> rGUmerticList = WorkTestDataUtility.CreateMetric();            
            List<Metric> activitymetrList = WorkTestDataUtility.CreateActivityMetric(); 
            List<Metric> merticSuperviserList = WorkTestDataUtility.CreateMetric();
            Database.insert(activitymetrList,false);
            
            for(Metric metric : rGUmerticList){
                metric.GoalId = xspRGUGoal.id;              
                newMerticList.add(metric);
            }
            
            for(Metric metric1 : activitymetrList){
                metric1.GoalId = xspACTGoal.id;  
                newMerticList.add(metric1);
            }
            
            for(Metric metric : merticSuperviserList){
                metric.GoalId = goalForSupervisor.id;           
                newMerticList.add(metric);
            } 
        }   
        
        Customer_Address__c addr = new Customer_Address__c();
        addr.Address__c = 'Test Address';
        addr.State__c = 'Test State';
        addr.City__c = 'Test City';
        addr.Country__c = 'Test Country';
        addr.PostalCode__c = '12345';
        addr.Node__c = '1111';
        addr.Corp__c = '11111111';
        addr.Route_Code__c = '1111111111';
        addr.Region__c = 'Freedom Market';
        addr.Latitude__c=41.405556;
        addr.Longitude__c=-81.664167;
        Database.insert(addr,false);
        List<Task> knockList = new List<Task>();
        //system.runAs(repUser){
        // Create & insert Knocks 
        for(Integer i=0;i<=8;i++){
            Task knock = new Task(); 
            knock.RecordTypeId = knockRecordTypeId;
            knock.WhatId = addr.Id;         
            knock.Event_Category__c = 'Fair';
            knock.Knocked_Date__c = system.Now();
            knock.OwnerId= repUser.Id;
            knock.status = 'Completed';
            knock.Timestamp__c = 'Null';
            knock.Knocked_Date__c = System.Today();
            knock.Created_Date_Custom__c = System.Today();
            if(i==0){
                knock.Disposition__c = 'No Answer';
                knock.Off_Turf__c = false;
                knock.HSI_Sold__c = true;
                knock.Video_Sold__c = false;
                knock.Voice_Sold__c = false;
                knock.XH_Sold__c = true;
            }
            if(i==1){
                knock.Disposition__c = 'No Knock';
                knock.Off_Turf__c = false;
                knock.HSI_Sold__c = false;
                knock.Video_Sold__c = true;
                knock.Voice_Sold__c = true;
                knock.XH_Sold__c = false;
            }
            if(i==2){
                knock.Disposition__c = 'Door Hanger';
                knock.Off_Turf__c = true;
                knock.HSI_Sold__c = false;
                knock.Video_Sold__c = true;
                knock.Voice_Sold__c = true;
                knock.XH_Sold__c = false;
            }
            if(i==3){
                knock.Disposition__c = 'Contact';
                knock.Off_Turf__c = true;
                knock.HSI_Sold__c = true;
                knock.Video_Sold__c = false;
                knock.Voice_Sold__c = false;
                knock.XH_Sold__c = true;
            }
            if(i==4){
                knock.Disposition__c = 'Engage';
                knock.Off_Turf__c = true;
                knock.HSI_Sold__c = false;
                knock.Video_Sold__c = true;
                knock.Voice_Sold__c = true;
                knock.XH_Sold__c = false;
            }
            if(i==5){
                knock.Disposition__c = 'Discover';
                knock.Off_Turf__c = true;
                knock.HSI_Sold__c = true;
                knock.Video_Sold__c = false;
                knock.Voice_Sold__c = false;
                knock.XH_Sold__c = true;
            }
            if(i==6){
                knock.Disposition__c = 'Start';
                knock.Off_Turf__c = false;
                knock.HSI_Sold__c = false;
                knock.Video_Sold__c = true;
                knock.Voice_Sold__c = true;
                knock.XH_Sold__c = false;
            }
            if(i==7){
                knock.Disposition__c = 'Close';
                knock.Off_Turf__c = false;
                knock.HSI_Sold__c = true;
                knock.Video_Sold__c = false;
                knock.Voice_Sold__c = false;
                knock.XH_Sold__c = true;
            }
            if(i==8){
                knock.Disposition__c = 'Position';
                knock.Off_Turf__c = false;
                knock.HSI_Sold__c = false;
                knock.Video_Sold__c = false;
                knock.Voice_Sold__c = false;
                knock.XH_Sold__c = false;
            }
            knockList.add(knock);
        }
    
        test.startTest();
            database.insert(userList,false);
            database.update(newMerticList,false); 
            database.insert(knockList,false);
        Boolean isWest = true;
        String query1= 'SELECT Id From User WHERE IsActive = True AND ProfileId =: DIRECT_SALES_REPR_PROFILE_ID AND UserPermissionsWorkDotComUserFeature = true AND Region__c IN (\'Freedom Market\')';
        MetricDailyUpdateBatchNew metrBatchObj = new MetricDailyUpdateBatchNew(query1,isWest);       
        database.executeBatch(metrBatchObj,20);
       test.stopTest();
    }  
   /*
    *  This method set permission set to user base on permissionSetName
    */ 
    public static void AssignPermissionSet(String permissionSetName, Id userId)
    {
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);
        
    }  
 
}