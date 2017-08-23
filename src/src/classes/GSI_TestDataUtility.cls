/**
 * Name    : GSI_TestDataUtility
 * Usage  : Utility Methods to create Test data to be used by Test Classes 
 *  
 * Created By     : Virendra
 * Modified By     : Igor Androsov
 * Modified Date   : Nov 6, 2015
 */
public with sharing class GSI_TestDataUtility {
 
  /* COMMENT 2015/11/06  
  public static GSI_Node__c gsiNode1 = new GSI_Node__c (); 
  public static GSI_Node__c gsiNode2 = new GSI_Node__c ();

  public static GSI_Node_Item__c nodeItem;
**/
  private static String  gpsMobileLibrary  = null;
/*  
  public static GSI_Node_Item__c createGSINodeItem(boolean isInsert,String title,Integer sortOrder,String itemType){
    GSI_Node_Item__c gsiNodeItem = new GSI_Node_Item__c();
    gsiNodeItem.Title__c = title;
    gsiNodeItem.Content_Detail__c =  getContentDetails().id;
    gsiNodeItem.Description__c = title+' Description';
    gsiNodeItem.GSI_Node__c = createGSINode(true,title,'Industries',1).id;
    gsiNodeItem.Capability_Question__c = 'Question for ::'+title+'::';
    gsiNodeItem.Item_Type__c = itemType;
    gsiNodeItem.Sort_Order__c = sortOrder;
     if(isInsert)
        insert gsiNodeItem;
     return gsiNodeItem; 
  }
  
  public static GSI_Node__c createGSINode(boolean isInsert,String name,String cat,Integer sortOrder){
    GSI_Node__c gsiNode = new GSI_Node__c();
    gsiNode.Category__c = cat;
    gsiNode.Color__c = 'Blue';
    gsiNode.Description__c = name+' Description';
    gsiNode.Enabled__c = true;
    gsiNode.Image_Name__c = 'Construction';
    gsiNode.Item_1__c = gsiNode1.id;
    gsiNode.Item_2__c = gsiNode2.id;
    gsiNode.Learn_More_Info__c = true;
    gsiNode.Sort_Order__c = sortOrder;
    if(isInsert)
      insert gsiNode;
      
    return gsiNode;
  }
  
  public static List<GSI_Node__c> getGSINodeList(Integer totalNo){
    List<GSI_Node__c> nodeList = new  List<GSI_Node__c>();
    for(Integer i =1; i<=totalNo;i++) {
        GSI_Node__c gsiNode = new GSI_Node__c();
        gsiNode.Name ='N-'+ i;
        gsiNode.Category__c = 'Solutions/Services';
        gsiNode.Color__c = 'Blue';
        gsiNode.Description__c = 'Node ' + i;
        gsiNode.Enabled__c = true;
        gsiNode.Image_Name__c = 'Construction';
        gsiNode.Item_1__c = gsiNode1.id;
        gsiNode.Item_2__c = gsiNode2.id;
        gsiNode.Learn_More_Info__c = true;
        gsiNode.Sort_Order__c = i;
        nodeList.add(gsiNode);
    }
    
    return nodeList;
  }
  
   public static List<GSI_Node_Item__c> getNodeItems(Integer count , String itemType,GSI_Node__c node,amp_Content_Detail__c contentDetails){
        List<GSI_Node_Item__c> nodeItemList = new  List<GSI_Node_Item__c>();
        for(Integer i =1; i<=count;i++) {
            GSI_Node_Item__c gsiNodeItem = new GSI_Node_Item__c();
            gsiNodeItem.Title__c = 'NodeItem ' +i;
            gsiNodeItem.Content_Detail__c =  contentDetails.id;
            gsiNodeItem.Description__c = 'NodeItem '+' Description' +i;
            gsiNodeItem.GSI_Node__c = node.Id;
            gsiNodeItem.Capability_Question__c = 'Question for ::'+gsiNodeItem.Title__c +'::';
            gsiNodeItem.Item_Type__c = itemType;
            gsiNodeItem.Sort_Order__c = i;
            gsiNodeItem.Active__c = true;
            nodeItemList.add(gsiNodeItem);
        }
        return nodeItemList; 
  }
**/
    
  public static amp_Content_Detail__c getContentDetails(){
    //No need for a specific workspace. Take the first one.
    //ContentWorkspace testWorkspace = [SELECT Id FROM ContentWorkspace LIMIT 1];
    
    ContentVersion testContentInsert = new ContentVersion(); 
    testContentInsert.Title = 'ContentTitle';
    testContentInsert.VersionData = Blob.valueOf('test');
    testContentInsert.PathOnClient = 'C:/Test';
    //testContentInsert.FirstPublishLocationId = getGPSMobileLibraryId(); 
    insert testContentInsert;
    
    List<amp_Content_Detail__c> cdList = [SELECT Id, Url__c, ContentSize__c, FileType__c, IsLatest__c, VersionNumber__c
                                           FROM amp_Content_Detail__c 
                                            WHERE Name = :testContentInsert.Title];
    system.debug('::cdList::'+cdList);                                            
    if(cdList != null && !cdList.isEmpty()){
           associateMultipleContentToCatTest(testContentInsert,cdList.get(0).id);                                            
           return cdList.get(0);
    }else{
       amp_Content_Detail__c cont = createContent('ContentTitle', testContentInsert.Id);     
       amp_Content_Category__c category = createCategory();
       amp_Content_Category_Assignment__c conCatAssignment = new amp_Content_Category_Assignment__c(Content_Category__c=category.id,
                                                                                                            Content_Detail__c=cont.id);
       return cont;                                                                                                            
    }
  }
  /* COMMENT 2014/10/07
  public static String getGPSMobileLibraryId() {
        if(gpsMobileLibrary == null ){
            system.debug('********** sss ' + amp_Mobile_Settings__c.getInstance().GPS_Mobile_Library__c); 
            gpsMobileLibrary = (amp_Mobile_Settings__c.getInstance() != null && amp_Mobile_Settings__c.getInstance().GPS_Mobile_Library__c != null) ? 
                (amp_Mobile_Settings__c.getInstance().GPS_Mobile_Library__c ): ('GPS Mobile Library');
            system.debug(':: gpsMobileLibrary::'+gpsMobileLibrary);
                
            for(ContentWorkspace lib:[select id from ContentWorkspace where name=:gpsMobileLibrary]){
                gpsMobileLibrary = lib.Id;
                system.debug('::gpsMobileLibrary:::'+gpsMobileLibrary);
                break;
            }   
        }
        system.debug(':: gpsMobileLibrary 058L00000000EL3:::'+gpsMobileLibrary);
        return gpsMobileLibrary;
        //return '058M00000006srf';
        
   }
  */
  /* COMMENT 2015/11/06  
  public static List<GSI_Team_Member__c> getGSITeamMembers(List<GSI_Node_Item__c> nodeItems){
        List<GSI_Team_Member__c> gsiTeamMemberList = new  List<GSI_Team_Member__c>();
        for(GSI_Node_Item__c gsiNodeItem : nodeItems) {
            GSI_Team_Member__c gsiTeamMember = new GSI_Team_Member__c();
            gsiTeamMember.GSI_Node_Item__c = gsiNodeItem.id;
            gsiTeamMember.User_Team_Member__c = gsiUserTeamMember.id;
            gsiTeamMemberList.add(gsiTeamMember);
        }
        return gsiTeamMemberList; 
  }
  */
  /* COMMENT 2014/10/07
  public static GSI_Team_Member__c createGSITeamMember(String name,String itemType,boolean useExistingNodeItem){
    GSI_Team_Member__c gsiTeamMember = new GSI_Team_Member__c();
    if(useExistingNodeItem)
       gsiTeamMember.GSI_Node_Item__c = nodeItem.id;
    else
       gsiTeamMember.GSI_Node_Item__c = createGSINodeItem(true, name, 1, itemType).id;
       gsiTeamMember.User_Team_Member__c = gsiUserTeamMember.id;
    insert gsiTeamMember;
    return gsiTeamMember;
  }
  */
  
  /* COMMENT 2015/11/06
  public static User createGSITeamMemberUser(String name){
    Profile gsiProfile =  [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    User gsiTeamMemberUser = new User(
          alias = name, 
          email=name+'gsiTemMember@testorg.com',
          emailEncodingKey='ISO-8859-1', 
              lastname='gsi'+name,
              ProfileId= gsiProfile.Id,
              languagelocalekey='en_US', 
              localesidkey='en_US',
              timezonesidkey='America/Los_Angeles', 
              username=name+'GSIuser@testorg.com');
      insert gsiTeamMemberUser;
    return gsiTeamMemberUser;  
  }
  */
    
   /* Create Category */
    public static  amp_Content_Category__c createCategory(){
        amp_Content_Category__c category = new amp_Content_Category__C(name='Costruction',Active__c=true);
        insert category;
        return category;
    }
    
    /* Create Content */
    public static amp_Content_Detail__c createContent(String conName){
        amp_Content_Detail__c content= new amp_Content_Detail__C(name=conName);
        insert content;
        return content;
    }
    public static amp_Content_Detail__c createContent(String conName, String url){
        amp_Content_Detail__c content= new amp_Content_Detail__C(name=conName,Url__c=url);
        insert content;
        return content;
    }
     /* Test associateMultipleContentToCat functionality */
    public static void associateMultipleContentToCatTest(ContentVersion testContentInsert,Id contentVersionId){
       amp_Content_Category__c category = createCategory();
       amp_Content_Category_Assignment__c conCatAssignment = new amp_Content_Category_Assignment__c(Content_Category__c=category.id,
                                                                                                            Content_Detail__c=contentVersionId);
       insert conCatAssignment;
    }
    /* COMMENT 2014/10/07
        Test associateMultipleContentToCat functionality 
    public static void associateMultipleContentToCatTest(ContentVersion testContentInsert){
       List<String> lstContent = new List<String>();
       lstContent.add(createContent('Test1').id);
       lstContent.add(createContent('Test2').id);  
       amp_Content_Detail__c cont = createContent('Test3', testContentInsert.Id);     
       amp_Content_Category__c category = createCategory();
       amp_Content_Category_Assignment__c conCatAssignment = new amp_Content_Category_Assignment__c(Content_Category__c=category.id,
                                                                                                            Content_Detail__c=cont.id);
       insert conCatAssignment;
    }
    */
    
    
    public static id addAttachmentToParent(Id parentId) {  
        Blob b = Blob.valueOf('Test Data');  
        Attachment attachment = new Attachment();  
        attachment.ParentId = parentId;  
        attachment.Name = 'Test Attachment for Parent';  
        attachment.Body = b;  
        insert(attachment);
        system.debug(':::attachment Inserted For parent id ::'+parentId);
        return attachment.id;  
    }  

}