/**
* Trigger Name: PropertyEventTrigger 
* Author: Joognu Rao, Accenture
* Date: 25-January-2017 
* Requirement #: US898825 
* Description: To restrict users from deleting the Property evets that have property event items associated.
* Modified by: Shalaka Kadwade, Date:3-Feb-2017, US911767: calling createCalenderEvent.
               
*/

trigger PropertyEventTrigger on Property_Events__c (before delete, after insert) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('PropertyEventTrigger');
    if(triggerSetting != null && triggerSetting.isActive__c){
        if(trigger.isBefore) {           
              if(trigger.isDelete){
                  
                  PropertyEventValidation objValidation = new PropertyEventValidation();
                  objValidation.doNotDeleteWithItems(trigger.old); 
              }
        }
        else{
            if(Trigger.isInsert){
                PropertyEventValidation.createCalenderEvent(Trigger.new);
            }           
        }
    }
}