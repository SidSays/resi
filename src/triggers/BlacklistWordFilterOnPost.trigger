/**
 * Filter Feed Items for blacklisted words
 * Author: Quinton Wall - qwall@salesforce.com
 */
trigger BlacklistWordFilterOnPost on FeedItem (before insert,after insert) 
{
     if(trigger.isBefore){
            if(trigger.isInsert){
              new BlacklistFilterDelegate().filterFeedItems(trigger.new);
            }
     }else if(trigger.isInsert){
          new BlacklistFilterDelegate().filterafterFeedItems(trigger.new);
     }
}