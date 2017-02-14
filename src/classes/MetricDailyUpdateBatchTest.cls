/**************************************************************************************************
Name : MetricDailyUpdateBatchTest
Description : This batch class created to test MetricDailyUpdateBatch
User Story : US491510
Date : 4 Augest 2015
Author : Ashish Sonawane
***************************************************************************************************/
@isTest
public class MetricDailyUpdateBatchTest{
   
   /*
    *  This test method use to cover MetricDailyUpdateBatch having logic to update bothe RGU and Activity     
    *  goal metric records
    */   
    static testmethod void MetricDailyUpdate(){
        
        WorkTestDataUtility.createCustomSettingRecords();       
        WorkTestDataUtility.setMatricDailyUpdateTimeZoneCS();
        WorkTestDataUtility.setGoalTemplateDateCS();
        WorkTestDataUtility.setGoalTemplateBiWeeklyDateCS();
        List<Metric> newMerticList = new List<Metric>();               
        List<Task> taskList = new List<Task>(); 
        string goalDirectsaleRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();  
        string knockRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Knock').getRecordTypeId();
        Division freedomRegion = [select id, name from Division where name ='Freedom Market'];
        User ManagerUser = WorkTestDataUtility.createDSManagerUser();
            
        User currentUser = [Select ContactId, Id from User where Id =: userInfo.getUserId()];
        /* Create Manager User And Mertic Data */
        System.runAs(currentUser){
            AssignPermissionSet('SalesSpace_Coach_Access_ASM',ManagerUser.Id);                  
            Goal GoalByManager = WorkTestDataUtility.createGoal();
            GoalByManager.Name = 'Test RGU 1';
            GoalByManager.RecordTypeId = goalDirectsaleRecordTypeId;
            GoalByManager.OwnerId = ManagerUser.Id;
            Database.Update(GoalByManager);        
            List<Metric> merticList = WorkTestDataUtility.CreateMetric();        
            for(Metric metric : merticList){
                metric.GoalId = GoalByManager.id;               
                newMerticList.add(metric);
            }
            
        }
        
        /* Create Superviser User And Mertic Data */
        
        User SupervisorUser = WorkTestDataUtility.createDSSupervisorUser();
        System.runAs(currentUser){            
            AssignPermissionSet('SalesSpace_Coach_Access_SDM',SupervisorUser.Id);
        }
        Goal GoalBySupervisor = WorkTestDataUtility.createGoal();
        GoalBySupervisor.Name = 'Test RGU 2';
        GoalBySupervisor.RecordTypeId = goalDirectsaleRecordTypeId;
        GoalBySupervisor.OwnerId = SupervisorUser.id;
        Database.Update(GoalBySupervisor);        
        SupervisorUser.ManagerId = ManagerUser.Id;
        Database.Update(SupervisorUser);
        List<Metric> merticSuperviserList = WorkTestDataUtility.CreateMetric(); 
        for(Metric metric : merticSuperviserList){
            metric.GoalId = GoalBySupervisor.id;           
            newMerticList.add(metric);
        }      
        
        // Create Representive User And Rgu Mertic Data 
        /*
        User RepUser = WorkTestDataUtility.createDSRepUser();
        System.runAs(currentUser){            
            AssignPermissionSet('SalesSpace_Coach_Access_XSP',RepUser.Id);
        }
        Goal GoalByRep = WorkTestDataUtility.createGoal();
        GoalByRep.RecordTypeId = goalDirectsaleRecordTypeId;
        GoalByRep.Name = 'Test RGU 3';
        GoalByRep.OwnerId = RepUser.id;
        Database.Update(GoalByRep);        
        RepUser.ManagerId = SupervisorUser.Id;
        Database.Update(RepUser);        
        List<Metric> merticRepresentList = WorkTestDataUtility.CreateMetric();  
        for(Metric metric : merticRepresentList){
            metric.GoalId = GoalByRep.id;           
            newMerticList.add(metric);
        }   */     
                                     
        /* Create Goal and Activity Metric for Representative   */
        /*Goal activityGoalByRep = WorkTestDataUtility.createGoal();
        activityGoalByRep.RecordTypeId = goalDirectsaleRecordTypeId;
        activityGoalByRep.Name = 'Test Activity 1';
        activityGoalByRep.OwnerId = RepUser.id;
        Database.Update(activityGoalByRep);        
        List<Metric> merticActivityList = WorkTestDataUtility.CreateActivityMetric();  
        for(Metric metric : merticActivityList){
            metric.GoalId = activityGoalByRep.id;           
            newMerticList.add(metric);
        }        
                
        Database.Upsert(newmerticList);    */                
        /* Start test execution */
                              
        /* Create plan and Address for DSR User  */
        /*Customer_Address__c addr = new Customer_Address__c();
        Plan__c pln = new Plan__c();
        System.runAs(RepUser){
            pln.Name = 'TestPlan';
            pln.Plan_Level__c = 'Turf';
            pln.Plan_Status__c = 'Draft';
            pln.No_of_No_Knock__c = 1;
            pln.No_of_No_Answer__c = 1;
            pln.No_of_Knock__c = 2;
            pln.User__c = RepUser.Id;
            ApexPages.StandardController controller1 = new ApexPages.StandardController(pln);
            PlanEditExtn extnObj1 = new PlanEditExtn(controller1);
            
            extnObj1.quickSave();
            
            addr.Address__c = 'Test Address';
            addr.State__c = 'Test State';
            addr.City__c = 'Test City';
            addr.Country__c = 'Test Country';
            addr.PostalCode__c = '12345';
            addr.Node__c = '1111';
            addr.Corp__c = '11111111';
            addr.Route_Code__c = '1111111111';
            addr.Region__c = 'Freedom Market';
            addr.Division = freedomRegion.Id;
           
            addr.plan__c = pln.Id;
            Database.insert(addr);
            pln.User__c = RepUser.Id;
            extnObj1.Save();
        }
      
       // Create Task Object and Set Owner as Representative, associate this task to adsress created above 
       for(Integer i=0 ; i<7;i++){          
            Task taskObj = WorkTestDataUtility.CreateTask();         
            taskObj.whatId = addr.Id;
            taskObj.Dwelling_Type__c='MDU';  
            taskObj.OwnerId = RepUser.Id;   
            taskObj.HSI_Sold__c = true;
            taskObj.Video_Sold__c = true;
            taskObj.Voice_Sold__c = true;
            taskObj.XH_Sold__c = true;    
            taskObj.RecordTypeId = knockRecordTypeId;  
         if(i==0){
            taskObj.Disposition__c='No Knock';
         }else if(i==1){
            taskObj.Disposition__c='Contact'; 
         }else if(i==2){
             taskObj.Disposition__c='Engage';
         }else if(i==3){
             taskObj.Disposition__c='Discover';
         }else if(i==4){
             taskObj.Disposition__c='Position';
         }else if(i==5){
             taskObj.Disposition__c='Close';
         }else if(i==6){
             taskObj.Disposition__c='Start';                         
         }
         taskList.add(taskObj);
           
       }                     
       Database.Insert(taskList);    */    
       Test.startTest();    
       Database.executeBatch(New MetricDailyUpdateBatch(WorkTestDataUtility.metricDailyqueryString), 100);                   
       
       Test.stopTest();
        
       List<Metric> metricList  = (List<Metric>) [Select currentValue,Goal.OwnerId From Metric];
       /* Current value will change from 0 to 1 */
       System.assertEquals(0,metricList[0].currentValue);
                
    }
    
    /*
    *  This method set permission set to user base on permissionSetName
    */ 
    static void AssignPermissionSet(String permissionSetName, Id userId){
        
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: permissionSetName];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = userId;
        psa.PermissionSetId = ps.Id;
        Database.insert(psa);
        
    }
}