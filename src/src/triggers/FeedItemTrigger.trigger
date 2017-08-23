/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : Chatter Post trigger that executes before and after insert to prevent non Admins from posting to or mentioning certain Chatter groups 
*
*---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER                     DATE                  REASON
*---------------------------------------------------------------------------------------------------------------------------------------
* Erin McGee               10/16/2013         - Original Version
*
* Erin McGee               01/14/2014         - Addition of after insert for Mentions                                            
*
  Erin McGee               07/11/2014         - Added Terms & Conditions Check                                           
*/
 trigger FeedItemTrigger on FeedItem(before insert, after insert,before delete){
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('FeedItemTrigger');
    if(triggerSetting != null && triggerSetting.isActive__c){
        if(ChatterTriggerHelper.hasAcceptedTermsAndConditions()){
            if(trigger.isBefore){
               if(trigger.isInsert){
               ChatterTriggerHelper.beforeInsertChatterPost(trigger.new);
               }
               if(trigger.isDelete){
               StoreDeletedChatter.storeDeletedFeeds(trigger.old);
               }
            }
            else if(trigger.isAfter){
                ChatterTriggerHelper.afterInsertChatterPost(trigger.new);
                
            }
           /* else if(trigger.isDelete)
            {
               ChatterTriggerHelper.storeDeletedFeeds(trigger.old);
            } */
        }
        else{
            trigger.new[0].addError(Label.Chatter_Post_Accept_Terms);
        }
    }
}