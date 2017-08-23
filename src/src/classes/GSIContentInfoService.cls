/**
 * Name    : GSIContentInfoService
 * Usage  : GSI Application content information service
 *        Query all contenet required/available to download to return document information + URLs
 *
 * Created By     : Igor Androsov
 * Modified By     : Igor Androsov
 * Modified Date   : June 18, 2013
 */
 @RestResource(urlMapping='/gsicontent/*') 
 global with sharing class GSIContentInfoService {
       
       
  @HttpGet
    global static List<GSIContentLibrary> doGet() {
      //Get Request  from  rest Context 
        RestRequest req = RestContext.request;
        system.debug('********** APPIRIO: Request data = ' + req);
        String lastRefreshDateTime = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        system.debug('********** APPIRIO: lastRefreshDateTime = ' + lastRefreshDateTime);
        Datetime refreshDateTime = null;
        String baseUrl = getBaseContentUrl(); 
        if(lastRefreshDateTime != null && lastRefreshDateTime != 'gsicontent'){
          //Parameter for last refreshDate time is Pressent
          /**** A.I. Update new logic for refresh data to use Server time parameter
          try{
              if(lastRefreshDateTime.lastIndexOf(':') != 16){
                lastRefreshDateTime+=':00';
              }
              refreshDateTime = datetime.valueOf(lastRefreshDateTime);
          }catch(Exception ex){}
          ****/
          try{
              if(lastRefreshDateTime.lastIndexOf(':') != 16){
                 lastRefreshDateTime+=':00';
              }
              refreshDateTime = datetime.valueOf(lastRefreshDateTime);
              system.debug('::After lastRefreshDateTime:::'+lastRefreshDateTime);  
          }catch(Exception ex){
                  system.debug(':: Exception is ::'+ex);
          }
          
        }
        List<GSIContentLibrary> lst = new List<GSIContentLibrary>(); // List<amp_Content_Detail__c>();
    
    // Get erver timestamp for refresh data
    String refershTimestamp = Datetime.now().format('yyyy-MM-dd HH:mm:ss');
    
    Map<String, GSIContentLibrary>  contentCategoryMap = new Map<String, GSIContentLibrary>();
      for (amp_Content_Category__c contentCategory : [Select Name, Id From amp_Content_Category__c where Active__c  = true 
                                                           order by Category_Order__c ]) {
                                                           
        system.debug('********** contentCategory ' + contentCategory);
        GSIContentLibrary contentLibrary = new GSIContentLibrary();
        contentLibrary.Id = contentCategory.Id;
        contentLibrary.libraryName = contentCategory.Name;
        contentLibrary.refreshDate = refershTimestamp;
        
        /*
        *  Description in not There on amp_Content_Category__c
        */
        //contentLibrary.description = contentCategory.
        contentLibrary.content = new List<GSIContent>();
        // Build library map
        contentCategoryMap.put(contentCategory.Id, contentLibrary);
      }
      
      List<Id> contentVersions = new List<Id>();
      List<amp_Content_Category_Assignment__c> ccAssignments = [select Content_Category__c, Content_Detail__c, Content_Detail__r.Name, Content_Detail__r.Url__c 
                                from amp_Content_Category_Assignment__c where (Activation_Date__c = null  OR Activation_Date__c <= TODAY ) and (Expiration_Date__c = null OR Expiration_Date__c >= TODAY) AND Approval_Status__c = 'Approved' AND Content_Category__c in : contentCategoryMap.keySet()]; 
        
        for(amp_Content_Category_Assignment__c ccAssignment : ccAssignments){
         system.debug('********** ccAssignment ' + ccAssignment);
            contentVersions.add(ccAssignment.Content_Detail__r.Url__c);                                   
    }
    
    //Create a Map for Content Versions for Assigments
    Map<Id,ContentVersion> contentVersionMap = null; 
    system.debug('********** refreshDateTime ' +refreshDateTime);
    // find if there are documents out of date that may need a refresh.  If no value is specified, then ALL documents should be returned.
    if(refreshDateTime != null){
        contentVersionMap = new Map<Id,ContentVersion>([Select Id, VersionNumber, Title, PathOnClient, IsLatest, FileType, Content_Detail__c,ContentModifiedDate,
                                 ContentUrl, ContentSize, ContentDocumentId From ContentVersion where id in :contentVersions and isLatest = true
                                 and ContentModifiedDate >=: refreshDateTime]);
    }else{
      contentVersionMap = new Map<Id,ContentVersion>([Select Id, VersionNumber, Title, PathOnClient, IsLatest, FileType, Content_Detail__c,
                                 ContentUrl, ContentSize,ContentDocumentId From ContentVersion where id in :contentVersions and isLatest = true]);
    }

        system.debug('::: contentVersionMap :::'+contentVersionMap.size());
        /*
          Get The Base Url of current Org.  
        */
        //String server_Base_url = URL.getSalesforceBaseUrl().toExternalForm();
        
        //String server_Base_url = getBaseContentUrl();
      //  String contentDetailPageUrl = '/sfc/#version?selectedDocumentId=';
        
        // Loop Through all the Assignments To create the GSIContentLibrary List which 
        // Will be categorise / Group on Category basis 
        for(amp_Content_Category_Assignment__c ccAssignment : ccAssignments){
          String contentCategoryId = ccAssignment.Content_Category__c;
           system.debug('::: contentCategoryId :::'+contentCategoryId);
             //Check if Category Record Exist 
            if (contentCategoryMap.containsKey(contentCategoryId)){
              system.debug('::: containsKey :::'+contentCategoryId);
              //Get List of Category to Add the Content 
          GSIContentLibrary  contentLibrary = contentCategoryMap.get(contentCategoryId);
          system.debug('::: contentLibrary :::'+contentLibrary);
          String conVersionId = ccAssignment.Content_Detail__r.Url__c;
          //Check if Content Version is There 
          if(contentVersionMap.containsKey(conVersionId)){
           system.debug('::: containsKey conVersionId :::'+conVersionId);
            //Get The Content Version to Create the Content Details 
            ContentVersion  conVersion = contentVersionMap.get(conVersionId); 
            system.debug('::: conVersion  :::'+conVersion);
            if (contentLibrary != null){
              GSIContent  contentDetail = new GSIContent();
              // A.I. 07/17/2013 Change made to pass Content_Detail ID in document ID to make a link on MeeetingInfo data
              // save selected documents. Content version ID is not used by teh app context
              contentDetail.documentId = ccAssignment.Content_Detail__c; //conVersion.ContentDocumentId;
              contentDetail.contentSize = conVersion.ContentSize;
              contentDetail.fileType = conVersion.FileType;
              contentDetail.title = ccAssignment.Content_Detail__r.Name;
              // contentDetail.version = 
              contentDetail.fileName = conVersion.PathOnClient;
              contentDetail.url = baseUrl+conVersion.Id; 
              // A.I. 11/9/2015 Change made to pass Category ID and library name for document
              contentDetail.categoryId = contentLibrary.Id;
              contentDetail.categoryName = contentLibrary.libraryName;
                
              system.debug('********** contentDetail.url  ' +contentDetail.url );
              /*
               *For now 
               * Following Url will show the Content Detail Page Where user can get download button
               * need research to find the way to create download url link 
              */
             // contentDetail.url = server_Base_url+contentDetailPageUrl+conVersion.ContentDocumentId; // Find a way 
             //to reconstruct correct download URL here
              
              
              contentLibrary.content.add(contentDetail);
            }      
          }
        }                                
    }                                        
      return contentCategoryMap.values();
    }
   
   public static String getBaseContentUrl() {
    system.debug('********** sss ' + amp_Mobile_Settings__c.getInstance().Base_File_URL__c); 
        return (amp_Mobile_Settings__c.getInstance() != null && amp_Mobile_Settings__c.getInstance().Base_File_URL__c != null) ? 
            (amp_Mobile_Settings__c.getInstance().Base_File_URL__c ): ('/Exception');
    }


/**** A.I. Add POST version of this ervice to ensure parameter is defined adn working correctly *******/

  @HttpPost
    global static List<GSIContentLibrary> doPost(String refreshDate) { // refreshDate parameter is name passed by the APP
      //Get Request  from  rest Context 
       // RestRequest req = RestContext.request;
        String lastRefreshDateTime = refreshDate; //req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Datetime refreshDateTime = null;
        String baseUrl = getBaseContentUrl(); 
        if(lastRefreshDateTime != null && lastRefreshDateTime != 'gsicontent'){
          // Parameter for last refreshDate time is Pressent
          /**** A.I. Update new logic for refresh data to use Server time parameter
          try{
                  if(lastRefreshDateTime.lastIndexOf(':') != 16){
                    lastRefreshDateTime+=':00';
                  }
                  Datetime dt = datetime.valueOf(lastRefreshDateTime);
                  refreshDateTime = dt.addHours(-7); // Subtract 7 hours from given time for adjustment for GMT
                system.debug('::After lastRefreshDateTime:::'+lastRefreshDateTime);  
          }catch(Exception ex){
                  system.debug(':: Exception is ::'+ex);
          }
          *****/
          try{
              if(lastRefreshDateTime.lastIndexOf(':') != 16){
                 lastRefreshDateTime+=':00';
              }
              refreshDateTime = datetime.valueOf(lastRefreshDateTime);
              system.debug('::After lastRefreshDateTime:::'+lastRefreshDateTime);  
          }catch(Exception ex){
                  system.debug(':: Exception is ::'+ex);
          }
          
        }
        List<GSIContentLibrary> lst = new List<GSIContentLibrary>(); // List<amp_Content_Detail__c>();
    
    // This URL need to be in some Label settings or get it for server magic
    String server_url = 'https://cs8.salesforce.com/sfc/dist/version/downloadNoFlash';
    String doc_url = '?oid=00DL00000027INp&ids=068L0000000IM8t&d=/a/L00000004CZB/mHx96XNHGtYLCVhKRBjncKkFmhSrWSW4hcS41wBbMa4=';
    
    // Get erver timestamp for refresh data
    String refershTimestamp = Datetime.now().format('yyyy-MM-dd HH:mm:ss');
    
    Map<String, GSIContentLibrary>  contentCategoryMap = new Map<String, GSIContentLibrary>();
      for (amp_Content_Category__c contentCategory : [Select Name, Id From amp_Content_Category__c where Active__c  = true 
                                                           order by Category_Order__c ]) {
        GSIContentLibrary contentLibrary = new GSIContentLibrary();
        contentLibrary.Id = contentCategory.Id;
        contentLibrary.libraryName = contentCategory.Name;
        contentLibrary.refreshDate = refershTimestamp;
        /*
        *  Description in not There on amp_Content_Category__c
        */
        //contentLibrary.description = contentCategory.
        contentLibrary.content = new List<GSIContent>();
        // Build library map
        contentCategoryMap.put(contentCategory.Id, contentLibrary);
      }
      
      List<Id> contentVersions = new List<Id>();
      List<amp_Content_Category_Assignment__c> ccAssignments = [select Content_Category__c, Content_Detail__c, Content_Detail__r.Name, Content_Detail__r.Url__c, LastModifiedDate 
                                from amp_Content_Category_Assignment__c where (Activation_Date__c = null  OR Activation_Date__c <= TODAY ) and (Expiration_Date__c = null OR Expiration_Date__c >= TODAY) AND Approval_Status__c = 'Approved' AND Content_Category__c in : contentCategoryMap.keySet()]; 
        
        for(amp_Content_Category_Assignment__c ccAssignment : ccAssignments){
            contentVersions.add(ccAssignment.Content_Detail__r.Url__c);                                   
    }
    
    //Create a Map for Content Versions for Assigments
    Map<Id,ContentVersion> contentVersionMap = null; 
    
    // find if there are documents out of date that may need a refresh.  If no value is specified, then ALL documents should be returned.
/** A.I. 7/28 comment condition query insted return all documents for library with flags to download or not based on refresh date
    if(refreshDateTime != null){
      contentVersionMap = new Map<Id,ContentVersion>([Select Id, VersionNumber, Title, PathOnClient, IsLatest, FileType, Content_Detail__c,ContentModifiedDate,
                                 ContentUrl, ContentSize, ContentDocumentId From ContentVersion where id in :contentVersions and isLatest = true
                                 and ContentModifiedDate >=: refreshDateTime]);
    }else{
      contentVersionMap = new Map<Id,ContentVersion>([Select Id, VersionNumber, Title, PathOnClient, IsLatest, FileType, Content_Detail__c,ContentModifiedDate,
                                 ContentUrl, ContentSize,ContentDocumentId From ContentVersion where id in :contentVersions and isLatest = true]);
    }
**/    

    contentVersionMap = new Map<Id,ContentVersion>([Select Id, VersionNumber, Title, PathOnClient, IsLatest, FileType, Content_Detail__c, ContentModifiedDate,
                                 ContentUrl, ContentSize,ContentDocumentId From ContentVersion where id in :contentVersions and isLatest = true]);
    
    system.debug('::contentVersionMap:::'+contentVersionMap);
        /*
          Get The Base Url of current Org.  
        */
        //String server_Base_url = URL.getSalesforceBaseUrl().toExternalForm();
        
        //String server_Base_url = getBaseContentUrl();
        //String contentDetailPageUrl = '/sfc/#version?selectedDocumentId=';
        
        // Loop Through all the Assignments To create the GSIContentLibrary List which 
        // Will be categorise / Group on Category basis 
        for(amp_Content_Category_Assignment__c ccAssignment : ccAssignments){
          String contentCategoryId = ccAssignment.Content_Category__c;
             //Check if Category Record Exist 
            if (contentCategoryMap.containsKey(contentCategoryId)){
              //Get List of Category to Add the Content 
          GSIContentLibrary  contentLibrary = contentCategoryMap.get(contentCategoryId);
          String conVersionId = ccAssignment.Content_Detail__r.Url__c;
          //Check if Content Version is There 
          if(contentVersionMap.containsKey(conVersionId)){
            //Get The Content Version to Create the Content Details 
            ContentVersion  conVersion = contentVersionMap.get(conVersionId); 
            if (contentLibrary != null){
              GSIContent  contentDetail = new GSIContent();
              // A.I. 07/17/2013 Change made to pass Content_Detail ID in document ID to make a link on MeeetingInfo data
              // save selected documents. Content version ID is not used by teh app context
              contentDetail.documentId = ccAssignment.Content_Detail__c; //conVersion.ContentDocumentId;
              contentDetail.contentSize = conVersion.ContentSize;
              contentDetail.fileType = conVersion.FileType;
              contentDetail.title = ccAssignment.Content_Detail__r.Name;
              // contentDetail.version = 
              contentDetail.isLatest = true;
              if (refreshDateTime != null && conVersion.ContentModifiedDate >= refreshDateTime){
                  contentDetail.isLatest = false;
              }
              if (refreshDateTime == null){
                  contentDetail.isLatest = false; // IF no refresh date passed allways return file valid for downlaod FALSE
              }
              // Check if Category was updated and need to refresh the file
              system.debug('####### Category assignment  ' +contentDetail.url + ' Rec MOD: '+ccAssignment.LastModifiedDate +' Refresh: '+ refreshDateTime);
              if (refreshDateTime != null && ccAssignment.LastModifiedDate >= refreshDateTime){
                  contentDetail.isLatest = false;
              }
              
              contentDetail.fileName = conVersion.PathOnClient;
              contentDetail.url = baseUrl+conVersion.Id; 
              system.debug('********** contentDetail.url  ' +contentDetail.url );
                           
              contentLibrary.content.add(contentDetail);
            }      
          }
        }                                
    }                                        
      return contentCategoryMap.values();
    }

}