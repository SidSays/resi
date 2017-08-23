/**
 * Helper for Disable Chatter Deletes App
 * Author: Marcus Ericsson - mericsson@salesforce.com
   Modified by :Shivani Gautam - Accenture
 */
 
 public without sharing class DisableChatterDeleteDelegate
{
    
    private static final String FEED_ITEM_TYPE = 'TrackedChange';
    private static final String LEAD_OBJECT_KEY_PREFIX = '00Q';
    
    // checking for chater post/comment delete access
 public static void isAllowedToDeleteAndEditFeedItems(List<FeedItem> feedItemList){
      
        boolean isDelete = allowDeleteAndEdit();
        String profileName=[Select Id,Name from Profile where Id=:UserInfo.getProfileId()].Name;
            for(FeedItem f : feedItemList){
                if(!isDelete) {
                    if (((String)f.parentId).startsWith(LEAD_OBJECT_KEY_PREFIX) && f.type.equalsIgnoreCase(FEED_ITEM_TYPE)) {
                        // ok to ignore if parent is "Lead" object
                    }
                    else if(f.CreatedById != UserInfo.getUserId())
                    {
                    f.addError(Label.Feed_Post_Restriction_Error);
                    }
                    
                    else {
                        //f.addError(Label.Feed_Post_Restriction_Error); 
                    }
                } else if(Trigger.isUpdate && f.CreatedById != UserInfo.getUserId() && (Label.RSAandDirectorProfileNames.contains(profileName))) {
                    f.addError(Label.Feed_Post_Restriction_Error);
                }
                /*else if(Trigger.isDelete && f.CreatedById != UserInfo.getUserId() && (Label.DirectSalesProfileNames.contains(profileName))){
                    f.addError(Label.Feed_Post_Restriction_Error);
                
                }*/
                
                else{
                    
                }
        }
  }
  
  
  public static void isAllowedToDeleteAndEditFeedComments(List<FeedComment> feedCommentList){
      
        boolean isDelete = allowDeleteAndEdit();
        String profileName=[Select Id,Name from Profile where Id=:UserInfo.getProfileId()].Name;
        
            for(FeedComment f : feedCommentList){
                if(!isDelete){
                    if (((String)f.parentId).startsWith(LEAD_OBJECT_KEY_PREFIX)) {
                        // ok to ignore if parent is "Lead" object
                    }
                    else if(f.CreatedById != UserInfo.getUserId())
                    {
                    f.addError(Label.Feed_Comment_Restriction_Error);
                    }
                    else {
                       // f.addError(Label.Feed_Comment_Restriction_Error); 
                    }
            } else if(Trigger.isUpdate && f.CreatedById != UserInfo.getUserId() && (Label.RSAandDirectorProfileNames.contains(profileName))) {
                    
                    f.addError(Label.Feed_Comment_Restriction_Error);
                }
            
                else{
                    
                }
        }
  }
  
  // logic for allowing chatter post/comment delete
  public static  boolean allowDeleteAndEdit() {

      String profileId = UserInfo.getProfileId();
      String loggedInUserId = UserInfo.getUserId();
      Boolean hasChatterAdminPermSet = false;
      Boolean modifyAllData = false;
      Boolean moderateChatterAccess = false;//Animesh
      
      Chatter_Delete_Settings__c settings = Chatter_Delete_Settings__c.getInstance(profileId);
      if (settings == null || (settings != null && !settings.Allow_Feed_Post_and_Comment_deletes__c) ) {
         
          //Check if the user has Modify All data permisison
          modifyAllData = [select PermissionsModifyAllData from Profile where id = :profileId].PermissionsModifyAllData;
          
          //Check if the user's Profile has moderate chatter permission
          moderateChatterAccess = [select PermissionsModerateChatter from Profile where id = :profileId].PermissionsModerateChatter; //Animesh
          
          //Check if the user has Chatter Admin Permission set assigned
          List<PermissionSetAssignment> permSetAssignmentIdList = [SELECT AssigneeId FROM PermissionSetAssignment 
          WHERE PermissionSetId in (SELECT id from PermissionSet where Label =: 
          Label.Permission_Set_With_Modify_All_Data)];
          

          if(permSetAssignmentIdList != null && permSetAssignmentIdList.size() > 0){
              for(PermissionSetAssignment psa : permSetAssignmentIdList){
                  if(loggedInUserId.equals((String)psa.AssigneeId)){
                      hasChatterAdminPermSet = true;
                  }
              }
          }
          
          // If either is true return true else return false
          if (modifyAllData || hasChatterAdminPermSet || moderateChatterAccess)  {//Animesh - added moderateChatterAccess check
              return true;
          }
          else {
              return false;
          }
     }
     else {
          // use custom defined settings
             return settings.Allow_Feed_Post_and_Comment_deletes__c;
      }
  }
}