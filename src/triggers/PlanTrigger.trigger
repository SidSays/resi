trigger PlanTrigger on Plan__c (before insert, after insert, before update, before delete, after delete) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('PlanTrigger');
    if(triggerSetting.isActive__c){
        if(trigger.isBefore){
            if(trigger.isInsert){
            
                 if(RecursiveTriggerHandler.isFirstTimePlanTriggerBeforeInsert){
                     RecursiveTriggerHandler.isFirstTimePlanTriggerBeforeInsert  = false;                  
                     PlanTriggerController.updatePlaylistStatus(Trigger.New);
                 }
            }
            else if(trigger.isUpdate){
            
                if(RecursiveTriggerHandler.isFirstTimePlanTriggerBeforeUpdate){
                        RecursiveTriggerHandler.isFirstTimePlanTriggerBeforeUpdate = false;   
                       // if(System.isBatch()){                 
                            PlanTriggerController.validateAssignment(Trigger.New, Trigger.OldMap);
                       // }
                        PlanTriggerController.updateNumberOfAddressOnPlan(Trigger.New, trigger.oldMap);
                        PlanTriggerController.setFieldsForAddressStatsSearch(Trigger.New);                               
                }
                
                PlanTriggerController.updateAssociatedPlaylists(Trigger.New, Trigger.OldMap);
            }
            else if(trigger.isDelete){
                //PlanTriggerController.restrictDelete();
                PlanTriggerController.deleteAssociatedPlaylists(Trigger.old);
                PlanTriggerController.attachAddressToTurf(Trigger.old);
            }
        }
        else {
            if(trigger.isInsert){
            
                if(RecursiveTriggerHandler.isFirstTimePlanTriggerAfterInsert ){
                    RecursiveTriggerHandler.isFirstTimePlanTriggerAfterInsert = false;                   
                    PlanTriggerController.moveTurfAddressCountToPlaylist(Trigger.new);
                    //PlanTriggerController.updateTurfAddressCountToPlaylist(Trigger.new);                  
                }
            } else if(trigger.isDelete){
            
                if(RecursiveTriggerHandler.isFirstTimePlanTriggerAfterDelete ){
                   RecursiveTriggerHandler.isFirstTimePlanTriggerAfterDelete = false;                   
                   PlanTriggerController.movePlaylistAddressCountToParent(Trigger.old);                                
                }
            }
            else if(trigger.isUpdate){
            
                if(RecursiveTriggerHandler.isFirstTimePlanTriggerAfterUpdate ){
                   RecursiveTriggerHandler.isFirstTimePlanTriggerAfterUpdate = false;               
                   //PlanTriggerController.updateAddressCountToPlaylist(Trigger.new);
                }            
            }            
        }
    }
}