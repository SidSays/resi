trigger TaskTrigger on Task (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('TaskTrigger');
    if(triggerSetting.isActive__c){
        if(trigger.isBefore){
            if(trigger.isInsert){
                KnockTriggerController.checkKnockCreatePermissions(Trigger.New);
                TaskTriggerController.populateDispositionLocationandLocationDifference(Trigger.New);
                KnockTriggerController.populateSubjectForKnocks(Trigger.New);
                KnockTriggerController.captureTurfIdAndRegion(Trigger.New);
                KnockTriggerController.updateCustomerAddressKnockTask(Trigger.New);
                KnockTriggerController.populateOffTurf(Trigger.new);
                KnockTriggerController.populateOrangeAndTerritoryOnKnocks(Trigger.New);
                KnockTriggerController.settingOfHSIOnlyFlag(Trigger.New);
                //TaskTriggerController.oneAsonecoachingvalidation(Trigger.New);
            }
            else if(trigger.isDelete){
                TaskTriggerController.restrictTaskDelete(Trigger.Old);
            }else if(trigger.isUpdate){
                KnockTriggerController.populateOffTurf(Trigger.new);
                KnockTriggerController.updateCustomerAddressKnockTask(Trigger.New);
                KnockTriggerController.populateOrangeAndTerritoryOnKnocks(Trigger.New);
            }
        }
        else {
            if(trigger.isInsert){
              //  TaskTriggerController.updateDateCARField(Trigger.New);
                TaskTriggerController.identifyLeadTimeToTouch(Trigger.NewMap, Trigger.OldMap);
                TaskTriggerController.countCallLogs(Trigger.NewMap, Trigger.oldMap);
                KnockTriggerController.rollupKnockCount(Trigger.Old, Trigger.New);
                KnockTriggerController.populateKnockDateOnAddress(Trigger.New);
                KnockTriggerController.populateWorkedDateOnAddress(Trigger.New);
                KnockTriggerController.updateTurfStatistics(Trigger.Old, Trigger.New);
                KnockTriggerController.createiKnockRecords(Trigger.New);
                TaskTriggerController.metricUpdate(Trigger.New);
                TaskTriggerController.createfeedpost(Trigger.New);
                KnockTriggerController.populateKnockCreatedDateOnAddress(Trigger.New);
                KnockTriggerController.updatePropertyEvent(Trigger.New,Trigger.oldMap);
                //KnockTriggerController.populateTerritoryForAssignedAddress(Trigger.New);
                
                //TaskTriggerController.newKnockRollUpData(trigger.new);
                //CARActivityTrackerController.addTask(Trigger.new);
            }
            else if(trigger.isUpdate){
             //   TaskTriggerController.updateDateCARField(Trigger.New);
                TaskTriggerController.identifyLeadTimeToTouch(Trigger.NewMap, Trigger.OldMap);
                KnockTriggerController.rollupKnockCount(Trigger.Old, Trigger.New);
                KnockTriggerController.populateKnockDateOnAddress(Trigger.New);
                KnockTriggerController.updatePropertyEventOnKnockChange(Trigger.New,Trigger.oldMap);
                KnockTriggerController.updatePropertyEvent(Trigger.New,Trigger.oldMap);
                KnockTriggerController.updatePropertyEventWhenNoEventAdded(Trigger.New,Trigger.oldMap);
                //KnockTriggerController.populateTerritoryForAssignedAddress(Trigger.New);
            }
            else if(trigger.isDelete || trigger.isUndelete){
                TaskTriggerController.countCallLogs(Trigger.newMap, Trigger.oldMap);
            }
        }
        
    }
        
}