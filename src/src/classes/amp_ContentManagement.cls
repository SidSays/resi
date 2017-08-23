/*******************************************************************************
* @Name         : ContentManagement
* @Author   :   Neeraj Gupta
* @Date         :   01/05/2012
* @Task         : T-45292
* @Purpose  :   Management Class for Content Trigger
* @Edits
*          : 07/19/2012 - Tony Pederson - added "Only run if Origin == 'C'" (non chatter file) logic
*          : 08/02/2012 - Tony Pederson - added "Only run if PublishStatus == 'P'" (in public libraries only) logic
*          : 09/13/2012 - Virendra Naruka - added "Only run run for non-Chatter files" logic on Before Insert
*
*******************************************************************************/
public without sharing class amp_ContentManagement {
    //----------------------------------------------------------------------------
    // Executes before insert of ContentVersion
    //----------------------------------------------------------------------------
    private static boolean isCreateContentDetail = false;
    public static void beforeContentInsert(List<ContentVersion> lstContentVersion) {
            
        List<amp_Content_Detail__c> lstContentDetails = new List<amp_Content_Detail__c>();
        List<ContentWrapper> lstContentWrapper = new List<ContentWrapper>();
        List<ContentVersion> updateNewContentDetails = new List<ContentVersion>();
        Set<String> conVersionDocuments = new Set<String>();
        list<String> documentIds = new list<String> (); 
        for (ContentVersion conVersion :lstContentVersion) {
            system.debug(':::Before Insert Publish STatus >>> ::'+conVersion.PublishStatus);
            documentIds.add(conVersion.ContentDocumentId);
        }
        String contentVersionOldName = null;
        for(ContentVersion conVersion:[select id,Title,ContentDocumentId,Origin from contentversion where ContentDocumentId in :documentIds order by LastModifiedDate desc]){
            if(conVersion.Origin == 'C'){
              conVersionDocuments.add(conVersion.ContentDocumentId);
            }
            if(contentVersionOldName == null){
                contentVersionOldName = conVersion.Title;
            }
        }
        for (ContentVersion conVersion : lstContentVersion) {
            //Updated for the personal Library issue fixes 
            //Dated :: 31/07/2012 
            if(conVersion.PublishStatus != 'R'){
                
                if(isCreateContentDetail ||conVersion.ContentDocumentId == null || (conVersion.ContentDocumentId != null && !conVersionDocuments.contains(conVersion.ContentDocumentId))){
                    System.debug(':: Content Version Title is >>>>::'+conVersion.Title);
                    amp_Content_Detail__c contentDetail = createContentDetail(conVersion);
                    if(contentDetail.Name == null && contentVersionOldName != null){
                        contentDetail.Name = contentVersionOldName;
                    }
                    if(contentDetail.Name.length() > 80){
                        contentDetail.Name = contentDetail.Name.substring(0,79);
                    }
                    lstContentDetails.add(contentDetail);
                    //We need to link Content Version with Content Detail 
                    //so Creating Wrapper record for later Reference
                
  
                   lstContentWrapper.add(new ContentWrapper(conVersion, contentDetail));
                
                }
                else if (trigger.isUpdate){
                    updateNewContentDetails.add(conVersion);
                }
            }
        }
        //insert content detail records
        if(!lstContentDetails.isEmpty()) {
           insert lstContentDetails;
           //update content detail field on content version.
           linkContentVerWithDetail(lstContentWrapper);
        }
        
        if(!updateNewContentDetails.isEmpty()){
            updateContentDetailUrl(updateNewContentDetails);
        }
    }
    
    
    //----------------------------------------------------------------------------
    // Executes after insert of ContentVersion
    //----------------------------------------------------------------------------
    public static void afterContentInsert(List<ContentVersion> lstContentVersion) {
           
        updateContentDetailUrl(lstContentVersion);
    }

    //----------------------------------------------------------------------------
    // Executes after update of ContentVersion
    //----------------------------------------------------------------------------
    public static void afterContentUpdate(List<ContentVersion> lstContentVersion) {
        updateContentDetailUrl(lstContentVersion);
    }   
    
    
    //----------------------------------------------------------------------------
    //Update URL field value on Content Detail record with the content DocumentURL 
    //----------------------------------------------------------------------------
    private static void updateContentDetailUrl(List<ContentVersion> lstContentVersion) {
        
        List<amp_Content_Detail__c> contentDetailsToUpdt = new List<amp_Content_Detail__c>();
        List<ContentVersion> createNewContentDetails = new List<ContentVersion>();
        for (ContentVersion cv : lstContentVersion) {
             system.debug(':::After  Insert Publish STatus >>> ::'+cv.PublishStatus);
            if(cv.Origin == 'C' && cv.PublishStatus != 'R'){
                if(cv.Content_Detail__c != null) {
                    amp_Content_Detail__c cDetail = new amp_Content_Detail__c(id = cv.Content_Detail__c);
                    cDetail.Url__c = cv.Id; 
                    cDetail.ContentSize__c = (cv.ContentSize == null ? null : string.valueOf(cv.ContentSize));
                    cDetail.FileType__c = cv.FileType;
                    cDetail.IsLatest__c = cv.IsLatest;
                    cDetail.VersionNumber__c = cv.VersionNumber;
                    contentDetailsToUpdt.add(cDetail);
                }
                else if(trigger.isUpdate){
                    createNewContentDetails.add(cv);
                }
            }
        }
        if(!createNewContentDetails.isEmpty()){
           isCreateContentDetail = true;    
           beforeContentInsert(createNewContentDetails);    
           isCreateContentDetail = false;
        }
        update contentDetailsToUpdt;
    }
    
    //----------------------------------------------------------------------------
    // Link Content Detail Object with Content Version
    //----------------------------------------------------------------------------
    private static void linkContentVerWithDetail(List<ContentWrapper> lstContentWrapper) {
        if(trigger.isBefore){
            for(ContentWrapper wrapObj : lstContentWrapper) {
                wrapObj.contentVersion.Content_Detail__c = wrapObj.contentDetail.Id;
            } 
        }
        else{
             Map<Id,String> lstVersions = new Map<Id,String>();
             for(ContentWrapper wrapObj : lstContentWrapper) {
                  lstVersions.put(wrapObj.contentVersion.Id,wrapObj.contentDetail.Id);
             }  
             list<ContentVersion> updateConversions = new  list<ContentVersion>();
             for(ContentVersion conver:[select id,Content_Detail__c from ContentVersion where id in :lstVersions.keySet() and IsLatest = true AND Origin = 'C' AND PublishStatus != 'R']){
                 if(lstVersions.containsKey(conver.Id)){
                     conver.Content_Detail__c = lstVersions.get(conver.Id);
                     updateConversions.add(conver);
                 }
             }
             if(!updateConversions.isEmpty()){
                update updateConversions;
             }
        }
    }
    
    //----------------------------------------------------------------------------
    // Contains Content Version along with related Content Detail 
    //----------------------------------------------------------------------------
    private Class ContentWrapper {
        public ContentVersion contentVersion;
        public amp_Content_Detail__c contentDetail;
        
        //Constructor       
        public ContentWrapper(ContentVersion cVersion,amp_Content_Detail__c contentDetail) {
                
            this.contentVersion = cVersion;
            this.contentDetail = contentDetail;
        }
    }
    
    //----------------------------------------------------------------------------
    //Creates Content Detail record 
    //---------------------------------------------------------------------------- 
    private static amp_Content_Detail__c createContentDetail(ContentVersion contentVer) {
        amp_Content_Detail__c contentDetail = new amp_Content_Detail__c();
        contentDetail.Name = contentVer.Title;
        return contentDetail;
    }
    
}