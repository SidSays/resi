/**************************************************************************************************
Name : IndirectMonthlyGoalCreationBatchTest
Description : This batch class created for Test coverage of IndirectMonthlyGoalCreationBatchTest apex class.
and insert Goals and Metrics on monthly basis for Indirect Users.
Date : 22/03/2017
Author : Tejaswini Kasar

***************************************************************************************************/
@isTest
public class IndirectMonthlyGoalCreationBatchTest {  
    public static testmethod void testIndirectMonthlyGoalCreationBatch(){        
        string goalGoaltemplateRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId(); 
        string goalIndirecttemplateRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Indirect Sales').getRecordTypeId();
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.createCustomSettingOtherRecords();
        
        GoalTemplateDates__c  indirectgoalStartAndEndCS = new GoalTemplateDates__c();
        indirectgoalStartAndEndCS.Name = 'IndirectActivityGoalCycle';
        indirectgoalStartAndEndCS.Current_Period_Due_Date__c = System.Today().addDays(+2);
        indirectgoalStartAndEndCS.Current_Period_Start_Date__c = System.Today().addDays(-2);
        Database.insert(indirectgoalStartAndEndCS);
        
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
        
        Profile retailSalesRep = [Select Id, Name From Profile where Name = 'Retail Sales Rep' limit 1];
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User retailSalesRepUser = new User(Alias = 'C_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    FirstName='Testing1',
                                    LastName='Testing2',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = retailSalesRep.Id,
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
        insert retailSalesRepUser;
        //Assign PermissionSet to Coresponding Profile user        
        System.runAs(new User(Id=userInfo.getUserId())){
            assignPermissionSet('SalesSpace_Coach_Access_Retail_Rep',retailSalesRepUser.Id);            
            
        }
          List<Metric> metricUpdateList = new List<Metric>(); 
                  
        // Create  Goal record and related Metrics record for Activity
        Goal retailActivityGoalTemplate = WorkTestDataUtility.createGoal(); // Standard obj
        retailActivityGoalTemplate.Profile_Name__c = 'Retail Sales Rep';
        retailActivityGoalTemplate.Region__c = retailSalesRepUser.Region__c;
        retailActivityGoalTemplate.StartDate = Date.newinstance(2015, 6, 22);
        retailActivityGoalTemplate.DueDate = Date.newinstance(2015, 7, 21);
        retailActivityGoalTemplate.Status='Draft';
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
        
        Goal retailRGUGoalTemplate = WorkTestDataUtility.createGoal(); // Standard obj
        retailRGUGoalTemplate.Profile_Name__c = 'Retail Sales Rep';
        retailRGUGoalTemplate.Region__c = retailSalesRepUser.Region__c;
        retailRGUGoalTemplate.StartDate = Date.newinstance(2015, 6, 22);
        retailRGUGoalTemplate.DueDate = Date.newinstance(2015, 7, 21);
        retailRGUGoalTemplate.Status='Draft';
        retailRGUGoalTemplate.Template_Type__c = 'RGU';
        retailRGUGoalTemplate.RecordTypeId = goalGoaltemplateRecordTypeId;
        Database.update(retailRGUGoalTemplate);
        
         List<Metric> merticListRGU = new List<Metric>();
        for(integer i=0; i<4; i++){
            Metric MetricObj = new Metric();
            if(i==0){
                MetricObj.Name = 'Voice';
                MetricObj.TargetValue = 1;             
            }else if(i==1){
                MetricObj.Name = 'Video';
                MetricObj.TargetValue = 1;             
            }
            else if(i==2){
                MetricObj.Name = 'HSD';
                MetricObj.TargetValue = 1;             
            }else if(i==3){
                MetricObj.Name = 'Total Units';
                MetricObj.TargetValue = 1;             
            }else if(i==4){
                MetricObj.Name = 'XH';
                MetricObj.TargetValue = 1;             
            }
            merticListRGU.add(MetricObj);
        }
        database.insert(merticListRGU,true);
        for(Metric m : merticListRGU){ 
            m.GoalId = retailRGUGoalTemplate.Id;              
            m.DueDate = Date.newinstance(2015, 8, 21);
            metricUpdateList.add(m);
        }
        Database.update(metricUpdateList,true);
        
        
        
        Goal retailSalesRepActivityGoal= new Goal(); // Standard obj               
        retailSalesRepActivityGoal.DueDate = System.Today().addDays(-5);
        retailSalesRepActivityGoal.Status= 'Published';         
        retailSalesRepActivityGoal.RecordTypeId = goalIndirecttemplateRecordTypeId;      
        retailSalesRepActivityGoal.name = 'ActTest' ;
        retailSalesRepActivityGoal.OwnerId = retailSalesRepUser.id;
        retailSalesRepActivityGoal.Template_Type__c = 'Activity';
        insert retailSalesRepActivityGoal;
        
        
        Metric retailSalesRepActivityMetric = new Metric();
        retailSalesRepActivityMetric.name = 'repMetric';
        retailSalesRepActivityMetric.ownerId = retailSalesRepUser.Id;
        retailSalesRepActivityMetric.DueDate = System.Today().addDays(-5);
        retailSalesRepActivityMetric.Status = 'Critical';
        retailSalesRepActivityMetric.Sort_Order__c = 1;
        retailSalesRepActivityMetric.goalId = retailSalesRepActivityGoal.Id;
        insert retailSalesRepActivityMetric;
        
        retailSalesRepActivityGoal.Status= 'Completed'; 
        update retailSalesRepActivityGoal;
                
        Test.startTest();
        String goalsQuery = 'Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c from User where IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true limit 199';
        IndirectMonthlyGoalCreationBatch goalMonthlyBatch = new IndirectMonthlyGoalCreationBatch(goalsQuery);
        Database.executeBatch(goalMonthlyBatch,200); 
        // Schedular Test
        //IndirectMonthlyGoalCreationBatchSchedule sc = new IndirectMonthlyGoalCreationBatchSchedule();
        
        datetime currentDateTime = datetime.now();
        String min = String.valueOf(math.mod((currentDateTime.minute() + 2),60));     
        String schExp = '0 '+min+' * * * ? ';

        //system.schedule('Schedular Test :'+datetime.now(), schExp, sc);
                        
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