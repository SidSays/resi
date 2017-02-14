/**************************************************************************************************
Name : PL_CarMgrMonthlyGoalCreationBatchTest
Description : Test class for "PL_CarMgrMonthlyGoalCreationBatch". 
User Story : US760932
Date : 10 Sept 2016
Author : Amit Kumar Pradhan
***************************************************************************************************/

@isTest
private class PL_CarMgrMonthlyGoalCreationBatchTest 
{
    //Test method to code coverage for "PL_CarMgrMonthlyGoalCreationBatch" batch class
    static testmethod void testCarMgrMonthlyGoalCreationBatch() {
        WorkTestDataUtility.createCustomSettingRecords();      
        /*String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'CarMgrMonthlyGoalCreationBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';*/
        User user = [Select Id from User where Id=:UserInfo.getUserId()];       
        Profile p = [Select Id, Name From Profile where Name = 'Xfinity CAR Manager' limit 1];
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User carMgrUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    LastName='Testing1',
                                    EmailEncodingKey='UTF-8', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Los_Angeles',
                                    ProfileId = p.Id,
                                    Username = 'userTest1' + randomstr + '@SampleTest.com',
                                    Region__c = 'Freedom Market',
                                    UserPermissionsWorkDotComUserFeature = true,
                                    FederationIdentifier = 'FedId1'+randomstr,
                                    EmployeeNumber = 'Emp1' + randomstr.substring(0,4));
        database.insert(carMgrUser,false);      
          
        system.runAs(user){
            GoalTemplateDates__c  gt = new GoalTemplateDates__c();
            gt.Name = 'Property Lab CAR';
            gt.Current_Period_Start_Date__c = Date.newinstance(2014, 12, 22);
            gt.Current_Period_Due_Date__c = Date.newinstance(2015, 01, 21); 
            database.insert(gt,false);
            //queryString = 'Select Id, Name, ManagerId, Profile.Name, Manager.Profile.Name, ProfileId, Region__c, Sales_Rep_Type__c, UserPermissionsWorkDotComUserFeature from User where IsActive = True AND Profile.Name IN: profileNameSet and UserPermissionsWorkDotComUserFeature = true';
            Test.startTest();
                String queryString = '';
                if(System.Label.CarMgrMonthlyGoalCreationBatchQuery != Null){
                    queryString = System.Label.CarMgrMonthlyGoalCreationBatchQuery;
                }
                Integer batchSize=200;
                if(System.Label.CarMgrMonthlyGoalCreationBatchSize!=null && System.Label.CarMgrMonthlyGoalCreationBatchSize.isNumeric()){
                    batchSize=Integer.valueOf(System.Label.CarMgrMonthlyGoalCreationBatchSize);
                }
                PL_CarMgrMonthlyGoalCreationBatch inst= new PL_CarMgrMonthlyGoalCreationBatch(queryString); 
                database.executebatch(inst);
            Test.stopTest();
        }             
        
    }

}