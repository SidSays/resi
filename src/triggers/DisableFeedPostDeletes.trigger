/**
 * Author: Marcus Ericsson - mericsson@salesforce.com
 * Modified by : Mandeep Singh - Accenture
 */
trigger DisableFeedPostDeletes on FeedItem (before delete, before update) 
{
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            DisableChatterDeleteDelegate.isAllowedToDeleteAndEditFeedItems(Trigger.Old);        
        } else if(Trigger.isUpdate){
            DisableChatterDeleteDelegate.isAllowedToDeleteAndEditFeedItems(Trigger.New);
        }
    }
    
    
}