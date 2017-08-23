/************************************* MODIFICATION LOG ********************************************************************************
*
* DESCRIPTION : Chatter Comment trigger that executes before and after insert to prevent non Admins from commenting to or mentioning certain Chatter groups 
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
trigger FeedCommentTrigger on FeedComment(before insert, after insert , before delete) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('FeedCommentTrigger');
    if(triggerSetting.isActive__c){
        if(ChatterTriggerHelper.hasAcceptedTermsAndConditions()){
            if(trigger.isBefore){
               if(trigger.isinsert){
                ChatterTriggerHelper.beforeInsertChatterComment(trigger.new);
                }
               if(trigger.isdelete) {
                StoreDeletedChatter.storeDeletedComments(trigger.old);
               }
            }
            else if(trigger.isAfter){
                ChatterTriggerHelper.afterInsertChatterComment(trigger.new);
            } 
        }
        else{
            trigger.new[0].addError(Label.Chatter_Comment_Accept_Terms);
        }
    }
}