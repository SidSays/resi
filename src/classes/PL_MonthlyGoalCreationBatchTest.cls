@isTest
private class PL_MonthlyGoalCreationBatchTest 
{
     static testmethod void testMonthlyGoalCreationBatchTest () {
        WorkTestDataUtility.createCustomSettingRecords();      
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'QM_QuotaAnnualBaselineBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
        User user = [Select Id from User where Id=:UserInfo.getUserId()];       
        Profile p = [Select Id, Name From Profile where Name = 'Xfinity CAR' limit 1];
        String randomstr = Math.round(Math.random()*Math.pow(10, 7)+1150)+'';
        User XfinityCARUser = new User(Alias = 'MDU_' + randomstr.substring(0,4),
                                    Email = randomstr + 'userTest1@SampleTest.com',
                                    LastName='Monthly1',
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
        insert XfinityCARUser; 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SalesSpace_Coach_Access_CAR' LIMIT 1] ;  
        
        PermissionSetAssignment psa = new PermissionSetAssignment(assigneeId=XfinityCARUser.id,PermissionSetId = ps.Id);
        insert psa;
        
        system.runAs(user){
            GoalTemplateDates__c  gt = new GoalTemplateDates__c();
            gt.Name = 'Property Lab CAR';
            gt.Current_Period_Start_Date__c = Date.newinstance(2014, 12, 22);
            gt.Current_Period_Due_Date__c = Date.newinstance(2015, 01, 21); 
            insert gt;
            Goal goalObject = new Goal();
            goalObject.Status = 'Draft';
            goalObject.Profile_Name__c = 'Xfinity CAR';
            goalObject.OwnerId = user.id;
            goalObject.Name = 'Xfinity CAR - PL - Freedom Market';
            goalObject.recordtypeId = PL_Constants.GOAL_TEMPLATE_RECORD_TYPE_ID;
            goalObject.Template_Type__c = 'Property Lab';
            goalObject.Region__c = 'Freedom Market';
            insert goalObject;
            List<Metric> merticList = new List<Metric>();
            for(integer i=0; i<5; i++){
                Metric MetricObj = new Metric();
                MetricObj.OwnerId = UserInfo.getUserId();
                if(i==0){
                    MetricObj.Name = 'Total Property Visits Per Month'; 
                    MetricObj.TargetValue = 80;                          
                }
                else if(i==1){
                    MetricObj.Name = 'Profile Completion Percent'; 
                    MetricObj.TargetValue = 100;              
                }
                else if(i==2){
                    MetricObj.Name = 'Sales Events';  
                    MetricObj.TargetValue = 2;            
                }                
                else{
                    MetricObj.Name = 'Average Property Visits per day'; 
                    MetricObj.TargetValue = 4;              
                }
                    MetricObj.GoalId = goalObject.id;
                    merticList.add(MetricObj);
            }
            Database.Insert(merticList);

        }             
         Test.startTest();
          
         system.runAs(user){
            //System.schedule('Scheduled Job 1', '0 0 * * * ?', new  PL_MonthlyGoalCreationBatchSchedule());
            String queryString = 'Select Id, Name, ManagerId,Profile.name,Region__c from User where IsActive = True AND Profile.Name IN: profileNameSet' 
            					+ ' and UserPermissionsWorkDotComUserFeature = true AND LastName = \'Monthly1\''; 
            PL_MonthlyGoalCreationBatch plMonthlyGoalBatch = new PL_MonthlyGoalCreationBatch(queryString); 
            database.executebatch(plMonthlyGoalBatch,1);
         Test.stopTest(); 
         }
        
     }

}