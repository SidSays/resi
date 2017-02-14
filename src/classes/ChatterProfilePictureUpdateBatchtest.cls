@isTest
private class ChatterProfilePictureUpdateBatchtest
{
 public static String CRON_EXP = '0 0 0 3 9 ? 2022';
     static testmethod void testChatterProfilePictureUpdateBatch () {
     
        WorkTestDataUtility.createCustomSettingRecords();      
        String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
        String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
        string BATCH_JOB_NAME = 'ChatterProfilePictureUpdateBatch';
        string GOAL_STATUS_COMPLETE = 'Completed';
        string JOB_STATUS = 'Draft';
        string NEW_LINE = '\n';
        string SYSTEM_EXCEPTION = 'System Exception - ';    
        string RECORD_TYPE_SEPERATION = ';';
        string JOB_COMMENT = ' ';
        string JOB_NAME_SPACE =  ' - ';
  integer count = 0; 
   String HTML_HEAD ='<html><head></head><body>';
   String HI_STRING = 'Hi,';
   String HTML_DESCRIPTION ='<br><br>It has been over 60 days since the following users have been created but have not updated their chatter profile picture.<br><br></body></html>';
  String SUBJECT_STRING ='Chatter Profile picture has not been updated ';
    String HREF = '<a href=';
  String BODY_END ='</a><br><br> \n\n </body></html>';
  String REGARDS = 'With best regards';
         Profile p = [ select id ,name from profile where name = 'XC Manager'  limit 1];
         User user = new user();
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
         //user.CreatedDate = system.today();
         Database.insert(user);
         // list<user> user1 = [select Id,profile.name,CreatedDate,Name,Region__c ,IsActive from user where id =: user.id];
         test.startTest();
           ChatterProfilePictureUpdateBatch cPPB = new ChatterProfilePictureUpdateBatch('select Id,profile.name,CreatedDate,Name,Region__c ,IsActive from user  limit 5');
           database.executebatch(cPPB );
         Test.stopTest(); 
         System.schedule('Scheduled Job 1', '0 0 * * * ?', new ChatterProfilePictureUpdateBatchSchedule());
 }
}