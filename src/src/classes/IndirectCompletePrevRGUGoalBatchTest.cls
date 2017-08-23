/**************************************************************************************************
Name : IndirectCompletePrevRGUGoalBatchTest
Description : This batch class created for Test coverage of IndirectCompletePreviousRGUGoalBatch apex class.
and insert Goals and Metrics on monthly basis for Indirect Users.
Date : 22/03/2017
Author : Tejaswini Kasar

***************************************************************************************************/
@isTest
public class IndirectCompletePrevRGUGoalBatchTest {
    
    public static testmethod void IndirectCompletePrevRGUGoalBatchTest(){        
        string goalIndirecttemplateRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Indirect Sales').getRecordTypeId();
        WorkTestDataUtility.createCustomSettingRecords();
        WorkTestDataUtility.createCustomSettingOtherRecords();
        
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string BATCH_JOB_NAME = 'IndirectCompletePreviousRGUGoalsBatch';
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
        userTrigger.isActive__c = true;
        triggerSettingsList.add(userTrigger);
            
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
                                    PERNR__c = '4321',
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    UserPermissionsWorkDotComUserFeature = true,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4),
                                    Terms_and_Conditions_Accepted__c = system.today()
          
                          );
        insert retailSalesRepUser;
        //Assign PermissionSet to Coresponding Profile user        
        System.runAs(new User(Id = UserInfo.getUserId())){
            GoalTemplateDates__c  indirectgoalStartAndEndCS = new GoalTemplateDates__c();
            indirectgoalStartAndEndCS.Name = 'IndirectPreviousRguGoalCycle';
            indirectgoalStartAndEndCS.Current_Period_Due_Date__c = System.Today().addMonths(-1).addDays(+2);
            indirectgoalStartAndEndCS.Current_Period_Start_Date__c = System.Today().addMonths(-1).addDays(-2);
            Database.insert(indirectgoalStartAndEndCS);
            assignPermissionSet('SalesSpace_Coach_Access_Retail_Rep',retailSalesRepUser.Id);  
    
        // Create  Goal record and related Metrics record for RGU
        
        //system.runas(new User(Id = UserInfo.getUserId())){
            Goal retailRGUGoalTemplate = WorkTestDataUtility.createGoal(); // Standard obj
            retailRGUGoalTemplate.Profile_Name__c = 'Retail Sales Rep';
            retailRGUGoalTemplate.OwnerId = retailSalesRepUser.id;
            retailRGUGoalTemplate.StartDate = System.Today().addDays(-2);
            retailRGUGoalTemplate.DueDate = System.Today().addDays(+2);
            retailRGUGoalTemplate.Status = 'Draft';
            retailRGUGoalTemplate.Template_Type__c = Indirect_Constants.RGU_STRING;
            retailRGUGoalTemplate.RecordTypeId = Indirect_Constants.INDIRECT_RECORD_TYPE_ID;
            Database.update(retailRGUGoalTemplate,true);
            
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
                MetricObj.GoalId = retailRGUGoalTemplate.Id;
                MetricObj.DueDate = retailRGUGoalTemplate.DueDate;
                merticListRGU.add(MetricObj);
            }
            MetricTriggerController.allowValidation = false;
            database.insert(merticListRGU,true);
            Test.startTest();
                String goalsQuery = 'Select Id, Name, profile.name, Region__c from User where IsActive = True AND profile.name IN: PROFILENAME and UserPermissionsWorkDotComUserFeature = true Limit 199';
                IndirectCompletePreviousRGUGoalsBatch goalMonthlyBatch = new IndirectCompletePreviousRGUGoalsBatch(goalsQuery);
                Database.executeBatch(goalMonthlyBatch,200);
            Test.stopTest();        
        }                       
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