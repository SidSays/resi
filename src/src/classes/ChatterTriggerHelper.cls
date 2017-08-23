/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : Helper class for Chatter Post and Comment Triggers 
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                     DATE                  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Erin McGee               01/14/2014         - Original Version  
*
* Erin McGee               07/11/2014         - Added hasAcceptedTermsAndConditions check                                       
*
* Pranjal Singh            07/13/2015         - Added a code in afterInsertChatterPost to set 'Profile_Photo_uploaded__c' as 'yes' in 'MDU_Property__c' object when propertyphoto is uploaded 
*/
public with sharing class ChatterTriggerHelper
{

  public static Boolean hasAcceptedTermsAndConditions()
  {
      User currentUser=[Select Id, Terms_and_Conditions_Accepted__c From User Where Id=:UserInfo.getUserId()];

      if(currentUser.Terms_and_Conditions_Accepted__c!=null){
          return true;
      }
      else{
          return false;
      }
  }

  public static void beforeInsertChatterPost(List < FeedItem > newPosts)
  {
    Map < String, Chatter_Group_Restriction__c > chatterGroupRestrictionsByName = new Map < String, Chatter_Group_Restriction__c > ();
    Set < Id > parentIds = new Set < Id > ();

    for (FeedItem FI: newPosts)
    {
      parentIds.add(FI.ParentId);
    }
    Set < String > chatterGroups = new Set < String > ();
    List < Chatter_Group_Restriction__c > cgList = [Select Name, Restriction_Type__c, Restriction_Message__c, Mention_Restriction_Message__c From Chatter_Group_Restriction__c];
    if (!cgList.isEmpty())
    {
      for (Chatter_Group_Restriction__c cg: cgList)
      {
        chatterGroups.add(cg.Name);
        chatterGroupRestrictionsByName.put(cg.Name, cg);
      }

      List < CollaborationGroupMember > cgmList = [SELECT collaborationGroupId, memberId, collaborationGroup.Name FROM CollaborationGroupMember WHERE CollaborationRole = 'Admin'
                AND collaborationGroup.Name IN: chatterGroups AND collaborationGroupId IN: parentIds];

      for (FeedItem FI: newPosts)
      {
        String thisFIpID = FI.ParentId;
        String thisFIprefix = thisFIpID.substring(0, 3);
        String chatterGroupName = '';
        if (thisFIprefix == CollaborationGroup.sObjectType.getDescribe().getKeyPrefix())
        {
          Boolean isAuthorizedGroupMember = false;
          if (!cgmList.isEmpty())
          {
            for (CollaborationGroupMember cgm: cgmList)
            {
              if ((cgm.collaborationGroupId == FI.ParentId && cgm.memberId == userinfo.getUserId()) || (cgm.collaborationGroupId != FI.ParentId))
              {
                isAuthorizedGroupMember = true;
                break;
              }
              else
              {
                chatterGroupName = cgm.collaborationGroup.Name;
              }
            }
          }

          if (!isAuthorizedGroupMember && chatterGroupName != '')
          {
            // Not Authorized CollaborationGroup Member
            FI.addError(chatterGroupRestrictionsByName.get(chatterGroupName).Restriction_Message__c.replace('[group]', chatterGroupName));
          }
        }
      }
    }

  }

  public static void afterInsertChatterPost(List < FeedItem > newPosts)
  {
    Map < String, Chatter_Group_Restriction__c > chatterGroupRestrictionsByName = new Map < String, Chatter_Group_Restriction__c > ();
    Set < String > chatterGroups = new Set < String > ();
    List < Chatter_Group_Restriction__c > cgList = [Select Name, Restriction_Type__c, Restriction_Message__c, Mention_Restriction_Message__c From Chatter_Group_Restriction__c];
    List<ID> propertyId=new List<ID>();
    List<MDU_Property__c> property=new List<MDU_Property__c>();
     // User Story: US482898 , Sprint 6 Change, Date : 7/13/2015, Author : Pranjal Singh
     // inserted below code block to check if there is a file upload with #PropertyPhoto in body then update 'Profile_Photo_uploaded__c' as 'yes' in 'MDU_Property__c' 
       for (FeedItem FI: newPosts)
        {
            if(FI.ContentType!=NULL && FI.Body!=NULL){
                if(FI.Body.contains('#PropertyPhoto')){
                 propertyId.add(FI.ParentId);
                     }
                }
        }
        
           property=[SELECT ID, Profile_Photo_uploaded__c  FROM MDU_Property__c WHERE ID IN: propertyId ];
           for(MDU_Property__c prop: property){
                prop.Profile_Photo_uploaded__c='Yes';
              }
            database.update(property,false);
        
    if (!cgList.isEmpty())
    {
      for (Chatter_Group_Restriction__c cg: cgList)
      {
        chatterGroups.add(cg.Name);
        chatterGroupRestrictionsByName.put(cg.Name, cg);
      }

      Boolean isAuthorizedGroupMember = false;

      List < CollaborationGroupMember > cgmList = [SELECT collaborationGroupId, memberId, collaborationGroup.Name FROM CollaborationGroupMember WHERE CollaborationRole = 'Admin'
                AND collaborationGroup.Name IN: chatterGroups];

      Id communityId = null;
      if (!cgmList.isEmpty())
      {
        Id feedItemId = null;
        for (FeedItem FI: newPosts)
        {

          for (CollaborationGroupMember cgm: cgmList)
          {
            if (cgm.memberId == userinfo.getUserId())
            {
              isAuthorizedGroupMember = true;
              break;
            }
          }
          try
          {
            ConnectApi.FeedItem feedItem = ConnectApi.ChatterFeeds.getFeedItem(communityId, FI.id);
            if(feedItem!=null){
              if(feedItem.body!=null){
                if(feedItem.body.text!=null){
                  if (feedItem.body.text.contains('@')){
                    for (String chatterGroupName: chatterGroups){
                      if (feedItem.body.text.contains('@' + chatterGroupName) && !isAuthorizedGroupMember){
                        feedItemId = FI.Id;
                        FI.addError(chatterGroupRestrictionsByName.get(chatterGroupName).Mention_Restriction_Message__c.replace('[group]', chatterGroupName));
                        break;
                      }
                    }
                  }
                }
              }
            }
            if (feedItemId != null)
            {
              break;
            }
          }
          catch (ConnectApi.NotFoundException ex)
          {
            system.debug(ex);
          }
        }
        if (feedItemId != null)
        {
          FeedItem feedItem = new FeedItem(Id = feedItemId);
          delete feedItem;
        }
      }

    }
  }

  public static void beforeInsertChatterComment(List < FeedComment > newComments)
  {
    Map < String, Chatter_Group_Restriction__c > chatterGroupRestrictionsByName = new Map < String, Chatter_Group_Restriction__c > ();

    Set < Id > parentIds = new Set < Id > ();
    for (FeedComment FC: newComments)
    {
      parentIds.add(FC.ParentId);
    }
    Set < String > chatterGroups = new Set < String > ();
    List < Chatter_Group_Restriction__c > cgList = [Select Name, Restriction_Type__c, Restriction_Message__c, Mention_Restriction_Message__c From Chatter_Group_Restriction__c WHERE Restriction_Type__c = 'Cannot Post or Comment'];
    if (!cgList.isEmpty())
    {
      for (Chatter_Group_Restriction__c cg: cgList)
      {
        chatterGroups.add(cg.Name);
        chatterGroupRestrictionsByName.put(cg.Name, cg);
      }

      List < CollaborationGroupMember > cgmList = [SELECT collaborationGroupId, memberId, collaborationGroup.Name FROM CollaborationGroupMember WHERE CollaborationRole = 'Admin'
                AND collaborationGroup.Name IN: chatterGroups AND collaborationGroupId IN: parentIds];

      for (FeedComment FC: newComments)
      {
        String thisFIpID = FC.ParentId;
        if (thisFIpID != null)
        {
          String thisFIprefix = thisFIpID.substring(0, 3);
          String chatterGroupName = '';
          if (thisFIprefix == CollaborationGroup.sObjectType.getDescribe().getKeyPrefix())
          {
            Boolean isAuthorizedGroupMember = false;
            if (!cgmList.isEmpty())
            {
              for (CollaborationGroupMember cgm: cgmList)
              {
                if ((cgm.collaborationGroupId == FC.ParentId && cgm.memberId == userinfo.getUserId()) || (cgm.collaborationGroupId != FC.ParentId))
                {
                  isAuthorizedGroupMember = true;
                  break;
                }
                else
                {
                  chatterGroupName = cgm.collaborationGroup.Name;
                }
              }
            }

            if (!isAuthorizedGroupMember && chatterGroupName != '')
            {
              // Not Authorized CollaborationGroup Member
              FC.addError(chatterGroupRestrictionsByName.get(chatterGroupName).Restriction_Message__c.replace('[group]', chatterGroupName));
            }
          }
        }
      }
    }
  }

  public static void afterInsertChatterComment(List < FeedComment > newComments)
  {
    Map < String, Chatter_Group_Restriction__c > chatterGroupRestrictionsByName = new Map < String, Chatter_Group_Restriction__c > ();
    Set < String > chatterGroups = new Set < String > ();
    List < Chatter_Group_Restriction__c > cgList = [Select Name, Restriction_Type__c, Restriction_Message__c, Mention_Restriction_Message__c From Chatter_Group_Restriction__c];

    if (!cgList.isEmpty())
    {
      for (Chatter_Group_Restriction__c cg: cgList)
      {
        chatterGroups.add(cg.Name);
        chatterGroupRestrictionsByName.put(cg.Name, cg);
      }

      List < CollaborationGroupMember > cgmList = [SELECT collaborationGroupId, memberId, collaborationGroup.Name FROM CollaborationGroupMember WHERE CollaborationRole = 'Admin'
                AND collaborationGroup.Name IN: chatterGroups];

      Id communityId = null;
      Boolean isAuthorizedGroupMember = false;
      Id feedCommentId = null;
      if (!cgmList.isEmpty())
      {
        for (FeedComment FC: newComments)
        {
          try
          {
            ConnectApi.Comment feedComment = ConnectApi.ChatterFeeds.getComment(communityId, FC.id);

            for (CollaborationGroupMember cgm: cgmList)
            {
              if (cgm.memberId == userinfo.getUserId())
              {
                isAuthorizedGroupMember = true;
                break;
              }
            }

            if (feedComment.body.text.contains('@'))
            {
              for (String chatterGroupName: chatterGroups)
              {

                if (feedComment.body.text.contains('@' + chatterGroupName) && !isAuthorizedGroupMember)
                {

                  feedCommentId = FC.Id;
                  FC.addError(chatterGroupRestrictionsByName.get(chatterGroupName).Mention_Restriction_Message__c.replace('[group]', chatterGroupName));
                  break;
                }
              }
            }
            if (feedCommentId != null)
            {
              break;
            }
          }
          catch (ConnectApi.NotFoundException ex)
          {
            system.debug(ex);
          }
        }
        if (feedCommentId != null)
        {
          FeedComment feedComment = new FeedComment(Id = feedCommentId);
          delete feedComment;
        }
      }
    }
  }
}