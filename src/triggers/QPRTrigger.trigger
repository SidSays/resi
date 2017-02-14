/**
* Trigger Name: QPRTrigger
* Author: Animesh Datta, Accenture
* Date: 03-February-2017
* Requirement # US932271 #US932272
* Description: Do not allow user to delete 'Completed' QPR record.
               Allow only to create one QPR per CAR per fiscal quater
* Last Modified : Suchita Sharma
*/

trigger QPRTrigger on Quarterly_Portfolio_Review__c (before delete,before insert,before update) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('QPRTrigger');
    if(triggerSetting != null && triggerSetting.isActive__c){
        if(trigger.isBefore){            
            if(trigger.isInsert){
                QPRTriggerController.validationOnQPRPerFiscalYear(Trigger.new);   
                QPRTriggerController.duplicatePropertyCheck(Trigger.new);
                QPRTriggerController.isPropertyAssignedToCAR(Trigger.new);                
            }
            if(trigger.isDelete){
                QPRTriggerController.doNotDeleteCompletedQPR(Trigger.old,Trigger.oldMap);
            }
            if(trigger.isUpdate){
                QPRTriggerController.duplicatePropertyCheck(Trigger.new);
                QPRTriggerController.isUpdatePropertyAssignedToCAR(Trigger.new, Trigger.oldMap); 
            }
        }
        else{
            //future code
        }   
    }
}