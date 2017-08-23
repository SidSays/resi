/***********************************************
* @Trigger Name: EventTrigger 
* @Author: Accenture
* @Last Modified By : Amit Kumar Pradhan
* @Last Modified Data : 22nd June 2017
* @Description : Calling updatePropertyEvents method to update Property Event when Event is updated.
* @User Story : US1104342(XC Property Events: Bidirectional Sync between Property Events & Events)             
***********************************************/
trigger EventTrigger on Event (before insert, after insert, before update, before delete, after update){    
    public static final String EVENT_TRIGGER = 'EventTrigger';//Added by Amit Kumar Pradhan
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues(EVENT_TRIGGER);    
    if(triggerSetting != null && triggerSetting.isActive__c){
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
                //EventTriggerController.countEvents(trigger.New);
            }
            if(trigger.isUpdate){
                /************
                * @Last Modified By : Amit Kumar Pradhan
                * @Last Modified Data : 22nd June 2017
                * @Description : Calling updatePropertyEvents method to update Property Event when Event is updated.
                * @User Story : US1104342(XC Property Events: Bidirectional Sync between Property Events & Events)--Start
                *************/
                EventTriggerController.updatePropertyEvents(Trigger.new,Trigger.oldMap);
                /************
                @ User Story : US1104342(XC Property Events: Bidirectional Sync between Property Events & Events)--End
                *************/
            }
        }                
    }
}