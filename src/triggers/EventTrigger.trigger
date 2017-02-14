trigger EventTrigger on Event (before insert, after insert, before update, before delete) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('EventTrigger');
    
    if(triggerSetting.isActive__c){
        if(trigger.isUpdate){
            EventTriggerController.isDelete = false;
        }
        if(trigger.isBefore){
                if(trigger.isDelete){
                    if(EventTriggerController.isDelete){
                        EventTriggerController.restrictEventDelete(trigger.Old);
                    }
                }
                if(trigger.isInsert){
                    EventTriggerController.populateVisitStartDateAndDuration(trigger.new);
                }
                if(trigger.isUpdate){
                    EventTriggerController.populateVisitStartDateAndDuration(trigger.new);
                }
        }
        else {
            if(trigger.isInsert){
                EventTriggerController.identifyLeadTimeToTouch(trigger.NewMap);
                EventTriggerHelper.sendStoreVisitAlerts(trigger.New);
              //  EventTriggerController.countEvents(trigger.New);
            }
            
        }
                
    }
}