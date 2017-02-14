/*
* Author : Tejaswini Datta Kasar
*/

trigger PropertyVisitTrigger on Property_Visit__c (after insert) {
    
    try{
        TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('PropertyVisitTrigger');
        if(triggerSetting.isActive__c){
            if(Trigger.isafter){
                if(Trigger.isInsert){
                    PropertyVisitTriggerController.propertyVisitCountGoal(Trigger.new);
                }    
            }
        }
    }
    catch(Exception e){
        System.debug('>>>>>>>>>>>>>Error Message'+e.getMessage());
    }    
        
    
    
}