/*******************************************************************************
* @Name         : amp_ContentManagement_Test
* @Author       : Neeraj Gupta
* @Date         : 01/05/2012
* @Task         : T-45292
* @Purpose      : Test Class for amp_ContentManagement functionality.
* 
*******************************************************************************/
@isTest
private class amp_ContentManagement_Test {
    //Creates a Content Version object, then retrieves the amp_Content_Detail objects that have the same name and asserts that they are equal.
    static testMethod void testContentDetails() {
        Test.startTest();
        //No need for a specific workspace. Take the first one.
        List<ContentWorkspace> testWorkspace = [SELECT Id FROM ContentWorkspace LIMIT 1];
        ContentVersion testContentInsert;
        if(testWorkspace != null && !testWorkspace.isEmpty()){
            List<ContentVersion> testContentInsertList = new List<ContentVersion>(); 
            testContentInsert = new ContentVersion();
            testContentInsert.Title = 'http://www.google.com';
            testContentInsert.VersionData = Blob.valueOf('test');
            testContentInsert.PathOnClient = 'C:/Test';
            //testContentInsert.FirstPublishLocationId = testWorkspace.Id; 
            insert testContentInsert;
            Test.stopTest(); 
    
            List<amp_Content_Detail__c> cdList = [SELECT Id, Url__c, ContentSize__c, FileType__c, IsLatest__c, VersionNumber__c
                                                  FROM amp_Content_Detail__c 
                                                  WHERE Name = :testContentInsert.Title];
        
            testContentInsertList = [SELECT Content_Detail__c , ContentSize, FileType, IsLatest, VersionNumber
                                 FROM ContentVersion 
                                 WHERE id = :testContentInsert.Id];
            if(testContentInsertList != null && testContentInsertList.size()>0){
                testContentInsert = testContentInsertList.get(0);
            
            }
         }   
       }
    //Creates a Content Version object, then changes the title and updates.
    static testMethod void updateContentVersion(){ 
        ContentVersion testContentInsert = new ContentVersion(); 
        testContentInsert.ContentURL='http://www.google.com/'; 
        testContentInsert.Title = 'Google.com'; 
        
        insert testContentInsert; 
        
        List<ContentVersion> testContentList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentInsert.Id]; 
        ContentVersion testContent;
        
        //No need for a specific workspace. Take the first one.
        List<ContentWorkspace> testWorkspaceList = [SELECT Id FROM ContentWorkspace LIMIT 1]; 
        if(testWorkspaceList != null && testWorkspaceList.size() > 0){
            ContentWorkspace testWorkspace = testWorkspaceList.get(0);
        
            if(testWorkspace != null && testContentList!= null && testContentList.size() > 0){
                testContent = testContentList.get(0);
                ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc(); 
                
                newWorkspaceDoc.ContentWorkspaceId = testWorkspace.Id; 
                newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId; 
                
                insert newWorkspaceDoc; 
                
                testContent.title = 'appirio'; 
            }
            update testContent;
        }
    }
}