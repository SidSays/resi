/**
 * Author: Marcus Ericsson - mericsson@salesforce.com
 * Modified by : Mandeep Singh - Accenture
 */
trigger DisableFeedCommentDeletes on FeedComment (before delete, before update) 
{
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            DisableChatterDeleteDelegate.isAllowedToDeleteAndEditFeedComments(Trigger.Old);        
        } else if(Trigger.isUpdate){
            DisableChatterDeleteDelegate.isAllowedToDeleteAndEditFeedComments(Trigger.New);
        }
    }
}