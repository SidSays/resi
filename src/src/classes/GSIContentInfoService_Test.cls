/**
 * Name     : GSIContentInfoService_Test
 * Usage    : Test Class for GSIContentInfoService.
 *  
 * Created By      : Virendra
 * Modified By     : Virendra
 * Modified Date   : July 9, 2013
 */
@isTest(seeAllData=true)
private class  GSIContentInfoService_Test {
    
    static testmethod void testGSIContentInfoService() {
       test.startTest();
       
        
        amp_Content_Detail__c contDetail = GSI_TestDataUtility.getContentDetails();
         
        List<amp_Content_Detail__c> cdList = [SELECT Id, Url__c, ContentSize__c, FileType__c, IsLatest__c, 
        									  VersionNumber__c  FROM amp_Content_Detail__c 
                                              WHERE id =:contDetail.Id];
    
        //ContentVersion testContentInsert = [SELECT Content_Detail__c , ContentSize, FileType, IsLatest, VersionNumber
        //                     FROM ContentVersion 
        //                     WHERE id = :cdList[0].Url__c];
        
        //System.assertEquals(testContentInsert.Id, cdList[0].Url__c);
         
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        String baseUrl = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());
        system.debug('::Base Url is ::'+baseUrl); 
        req.requestURI = baseUrl+'/services/apexrest/gsicontent/';  
         
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        List<GSIContentLibrary> gsiContentLibraries  = GSIContentInfoService.doGet();
          
        system.debug(':: 11 gsiContentLibraries A :::'+gsiContentLibraries);
        for(GSIContentLibrary gsiContentLibrary : gsiContentLibraries) {
           system.debug('********** gsiContentLibrary Case A ' +gsiContentLibrary);
          for(GSIContent content :gsiContentLibrary.content) {
              system.debug('******** content Case A ' + content.fileName);
          }
        }
          
          
        req = new RestRequest(); 
        res = new RestResponse();
    
        Datetime refreshDateTime = system.now().addDays(-3);
          
        req.requestURI = baseUrl+'/services/apexrest/gsicontent/'+refreshDateTime;  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        amp_Mobile_Settings__c settings = amp_Mobile_Settings__c.getInstance( );
   
        settings.Base_File_URL__c = 'https://c.cs8.content.force.com/sfc/servlet.shepherd/version/download/';
        upsert settings;
          
        system.debug('***********amp_Mobile_Settings__c.getInstance().Base_File_URL__c ' +amp_Mobile_Settings__c.getInstance().Base_File_URL__c);
          
        
        gsiContentLibraries  = GSIContentInfoService.doGet();
        system.debug(':: 22 gsiContentLibraries:::'+gsiContentLibraries);
        for(GSIContentLibrary gsiContentLibrary : gsiContentLibraries) {
            
        }
        gsiContentLibraries  = GSIContentInfoService.doPost(String.valueOf(refreshDateTime));
        system.debug(':: 22 gsiContentLibraries post req:::'+gsiContentLibraries);
        for(GSIContentLibrary gsiContentLibrary : gsiContentLibraries) {
           system.debug('********** gsiContentLibrary Case B ' +gsiContentLibrary);
          for(GSIContent content :gsiContentLibrary.content) {
              system.debug('******** content Case B ' + content.fileName);
          }
        }
           
      test.stopTest();
   }    
   
  /*  
  static testmethod void testGSIContentInfoService_BSD_Profile() {
        
       
        Profile BSDProfile =  [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            
        User BSDUser = new User(
             alias = 'standt', 
             email='standarduser@testorg.com',
             emailEncodingKey='ISO-8859-1', 
             lastname='Testing',
             ProfileId= BSDProfile.Id,
             languagelocalekey='en_US', 
             localesidkey='en_US',
             timezonesidkey='America/Los_Angeles', 
             username='standardBSDuser@testorg.com');
         insert BSDUser;
        
        Test.startTest();
            
            
    
        amp_Content_Detail__c contDetail = GSI_TestDataUtility.getContentDetails();
         
        List<amp_Content_Detail__c> cdList = [SELECT Id, Url__c, ContentSize__c, FileType__c, IsLatest__c, 
        									  VersionNumber__c  FROM amp_Content_Detail__c 
                                              WHERE id =:contDetail.Id];
    
        ContentVersion testContentInsert = [SELECT Content_Detail__c , ContentSize, FileType, IsLatest, VersionNumber
                             FROM ContentVersion 
                             WHERE id = :cdList[0].Url__c];
        
        System.assertEquals(testContentInsert.Id, cdList[0].Url__c);
        
        System.runAs(BSDUser) { 
    
         
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
    
        String baseUrl = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());
        system.debug('::Base Url is ::'+baseUrl); 
        req.requestURI = baseUrl+'/services/apexrest/gsicontent/';  
         
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        List<GSIContentLibrary> gsiContentLibraries  = GSIContentInfoService.doGet();
          
        system.debug(':: gsiContentLibraries Case I:::'+gsiContentLibraries);
        for(GSIContentLibrary gsiContentLibrary : gsiContentLibraries) {
          system.debug('********** gsiContentLibrary Case I ' +gsiContentLibrary);
          for(GSIContent content :gsiContentLibrary.content) {
             system.debug('******** content Case I ' + content.fileName);
          }
        }
          
          
        req = new RestRequest(); 
        res = new RestResponse();
    
        
        Datetime refreshDateTime = system.now().addDays(-3);
          
        req.requestURI = baseUrl+'/services/apexrest/gsicontent/'+refreshDateTime;  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        amp_Mobile_Settings__c settings = amp_Mobile_Settings__c.getInstance( );
   
        settings.Base_File_URL__c = 'https://c.cs8.content.force.com/sfc/servlet.shepherd/version/download/';
        upsert settings;
          
        system.debug('***********amp_Mobile_Settings__c.getInstance().Base_File_URL__c ' +amp_Mobile_Settings__c.getInstance().Base_File_URL__c);
          
        
        gsiContentLibraries  = GSIContentInfoService.doGet();
        system.debug(':: 22 gsiContentLibraries:::'+gsiContentLibraries);
        system.debug('::: refreshDateTime:::'+refreshDateTime);
        gsiContentLibraries  = GSIContentInfoService.doPost(String.valueOf(refreshDateTime));
        system.debug(':: 22 gsiContentLibraries post req:::'+gsiContentLibraries);
        for(GSIContentLibrary gsiContentLibrary : gsiContentLibraries) {
             system.debug('******* cccccccccgsiContentLibrary  '+gsiContentLibrary );
            for(GSIContentLibrary gsiContentLibrary2 : gsiContentLibraries) {
                 system.debug('********** ccccccccc gsiContentLibrary2 ' +gsiContentLibrary2);
            	for(GSIContent content2 :gsiContentLibrary2.content) {
                	system.debug('********xxxxxx content ' + content2.fileName);
            	}
            }
          
        }

       test.stopTest();
    
    }

	}
*/
    
}