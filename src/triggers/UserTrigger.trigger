/*
* Name: UserTrigger 
* Description: All User Trigger execution is managed from here using controller class call.
*/
trigger UserTrigger on User (before insert, after insert, before update, after update) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('UserTrigger');    

    if(triggerSetting.isActive__c ){
        if(trigger.isBefore){
            if(trigger.isInsert){
                UserTriggerController.setUserRegion(Trigger.new, Trigger.oldMap);   
                UserTriggerController.changeMgrForAE(Trigger.new, Trigger.oldMap);
                UserTriggerController.updateEmailEncodingField(trigger.new);
                UserTriggerController.userTriggerForFederationID();
                UserTriggerController.updateMonthlyCARGoals(Trigger.oldMap, Trigger.New);
                if(System.isBatch() != true){
                   UserTriggerController.UserActiveDeActiveUpadte(trigger.new);
                }            
            }
            else if(trigger.isUpdate){
                UserTriggerController.setUserRegion(trigger.new, Trigger.oldMap);
                UserTriggerController.changeMgrForAE(Trigger.new, Trigger.oldMap);                                           
                UserTriggerController.changeManagerForCoaching(Trigger.new,Trigger.oldMap);
                UserTriggerController.updateEmailEncodingField(trigger.new);
                UserTriggerController.userTriggerForFederationID();
                UserTriggerController.updateMonthlyCARGoals(Trigger.oldMap, Trigger.New);
                if(System.isBatch() != true){
                   UserTriggerController.UserActiveDeActiveUpadte(trigger.new);
                }
            }
        }
        else {
            if(trigger.isInsert){
                UserTriggerController.addClaimsUsersToGroups(trigger.new);
                UserTriggerController.addUsersToGroup(trigger.new, trigger.oldMap);
                UserTriggerController.CreateNewAE();
                UserTriggerController.assignPermissionSet(trigger.new, trigger.old);
                UserTriggerController.assignCarCarManagerPerSet(trigger.new, trigger.oldMap);
                UserTriggerController.waveAccessToNewXCUsers(trigger.new,trigger.oldmap);
                UserTriggerController.addUsersToChatterGroup(trigger.oldMap,trigger.new);
            }
            else if(trigger.isUpdate){
                UserTriggerController.removeFromOldpublicGroup(trigger.oldMap,trigger.new);
                UserTriggerController.addClaimsUsersToGroups(trigger.new);
                UserTriggerController.addUsersToGroup(trigger.new, trigger.oldMap);
                UserTriggerController.CreateNewAE();
                UserTriggerController.assignPermissionSet(trigger.new, trigger.old);
                UserTriggerController.ManageChangeFeedbackRequest(trigger.new,trigger.oldmap);
                UserTriggerController.waveAccessToNewXCUsers(trigger.new,trigger.oldmap);
                UserTriggerController.assignCarCarManagerPerSet(trigger.new, trigger.oldMap);
                UserTriggerController.updateGoalForAE(trigger.oldMap,trigger.new);
                UserTriggerController.addUsersToChatterGroup(trigger.oldMap,trigger.new);
              }
            } 
        }
}