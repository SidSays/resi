/*
* Name: UserTrigger 
* Description: All User Trigger execution is managed from here using controller class call.
*/
trigger UserTrigger on User (before insert, after insert, before update, after update) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('UserTrigger');    

    if(triggerSetting != null && triggerSetting.isActive__c ){
        if(trigger.isBefore){
            if(trigger.isInsert){
                UserTriggerController.setUserRegion(Trigger.new, Trigger.oldMap);   
                UserTriggerController.changeMgrForAE(Trigger.new, Trigger.oldMap);
                UserTriggerController.updateEmailEncodingField(trigger.new);
                UserTriggerController.userTriggerForFederationID();
                UserTriggerController.updateMonthlyCARGoals(Trigger.oldMap, Trigger.New);
                UserTriggerController.updateNTID(Trigger.New); //  US1049770: Update NTID for the User
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
                UserTriggerController.updateNTID(Trigger.New); //  US1049770: Update NTID for the User
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
                //Start - US1027533 - Animesh - 03-May-2017 Commenting method ManageChangeFeedbackRequest and added new method shareFeedbackRequestWithNewMgr
                //UserTriggerController.ManageChangeFeedbackRequest(trigger.new,trigger.oldmap);
                UserTriggerController.shareFeedbackRequestWithNewMgr(trigger.new,trigger.oldmap);
                //End - US1027533 - Animesh - 03-May-2017
                UserTriggerController.waveAccessToNewXCUsers(trigger.new,trigger.oldmap);
                UserTriggerController.assignCarCarManagerPerSet(trigger.new, trigger.oldMap);
                UserTriggerController.updateGoalForAE(trigger.oldMap,trigger.new);
                UserTriggerController.addUsersToChatterGroup(trigger.oldMap,trigger.new);
                //Part of US1086728 - Start(Added By Amit Kumar Pradhan)
                UserTriggerController.insertCoachingSharingForReactivedUser(trigger.oldMap,trigger.new);
                //Part of US1086728 - End
            }
        } 
    }
}