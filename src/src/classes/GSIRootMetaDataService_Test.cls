/**
 * Name     : GSIRootMetaDataService_Test
 * Usage    : Test Class for GSIRootMetaDataService.
 *  
 * Created By      : A.I.
 * Modified By     : A.I.
 * Modified Date   : Nov 6, 2015
 */
@isTest
private class GSIRootMetaDataService_Test {

   static testmethod void testGSIRootMetaDataService_Bulk() {
    test.startTest();
        GSIRootMetadata rm = new GSIRootMetadata();
        amp_Content_Detail__c contentDetail = GSI_TestDataUtility.getContentDetails();
           
         
        // Add Root nodes here
        GSI_Root_Node__c rn = new GSI_Root_Node__c();
        rn.Name = 'By industry';
        rn.Enabled__c = true;
        rn.Color__c = 'Purple';
        rn.Image_Name__c = 'Energy Oil Gas';
        rn.Node_Type__c = 'Idustry';
        insert rn;
               
      RestRequest req = new RestRequest(); 
      RestResponse res = new RestResponse();

      Date  refreshDate = system.today();
      String baseUrl = String.valueof(URL.getSalesforceBaseUrl().toExternalForm());
      system.debug('::Base Url is ::'+baseUrl); 
      req.requestURI = baseUrl+'/services/apexrest/gsiroot/'+refreshDate;  
     
      req.httpMethod = 'GET';
      RestContext.request = req;
      RestContext.response = res;
    
       system.debug('************* calling service get method '); 
      List<GSIRootMetadata> gsiMetadataList = GSIRootMetaDataService.doGet();
      for(GSIRootMetadata gsiMetadata : gsiMetadataList) {
          gsiMetadata.toStr();
      }
      test.stopTest();
      
    
   }
 
}