/***********************************************
* Trigger Name: ApplicationLogTrigger 
* Author: Deepika Jain
* Description: Trigger to delete opportunity after Contracts are deleted from MCAT
* User Story: US1107249 - XC MCAT - Delete contract in MCAT
***********************************************/
trigger ApplicationLogTrigger on Application_Log__c (after update) {
    public static final String APPLICATION_LOG_TRIGGER = 'ApplicationLogTrigger';
        if(TriggerSettings__c.getValues(APPLICATION_LOG_TRIGGER)!=null && TriggerSettings__c.getValues(APPLICATION_LOG_TRIGGER).IsActive__c){
            if(trigger.isAfter){
                if(trigger.isUpdate){
                    ApplicationLogTriggerHelper.deleteOppFromAppLog(Trigger.New);
            }
        }
    }
}