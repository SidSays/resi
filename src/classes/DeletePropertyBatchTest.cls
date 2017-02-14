@isTest
private class DeletePropertyBatchTest {
  static testmethod void TestDeletePropertyBatch () {
  String CRON_EXP = '0 0 0 3 9 ? 2022';
  WorkTestDataUtility.createCustomSettingRecords();      
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
  
 // Profile p = [ select id ,name from profile where name = 'XC SME'  limit 1];
         /*User user = new user();
         user.Sales_Rep_Type__c = 'Division';
         user.UserPermissionsWorkDotComUserFeature = true;
         user.ProfileId = p.Id;
         user.Email ='userTest@SampleclassTest.com';
         user.LastName='Testing';
         user.Username = 'userTest@SampleclassTest.com';
         user.FederationIdentifier = 'FedId1';
         user.TimeZoneSidKey='America/Los_Angeles';
         user.LocaleSidKey='en_US';
         user.EmailEncodingKey='UTF-8';
         user.Alias = 'DSR';
         user.LanguageLocaleKey='en_US';
         Database.insert(user);
*/
          //list<user> user1 = [select Id,profile.name,CreatedDate,Name,Region__c ,IsActive from user];
           MDU_Property__c prop = new MDU_Property__c();
           prop.name = 'TestProp';
           prop.Delete_Property__c = TRUE ;
           prop.MDU_State__c = 'Alaska';
           //Database.insert(prop);
             
           Test.startTest();
           DeletePropertyBatch deleteProp = new DeletePropertyBatch('SELECT Id,name,Delete_Property__c,RecordType.Name from MDU_Property__c where Delete_Property__c= true limit 5');
           database.executebatch(deleteProp);
           
           String scheduledJobId;
           DeletePropertyBatchSchedule scheduleObj = new DeletePropertyBatchSchedule();
           scheduledJobId = System.schedule('testScheduledApex', CRON_EXP, scheduleObj);
         Test.stopTest();
  }
}