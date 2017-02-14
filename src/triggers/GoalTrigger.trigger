trigger GoalTrigger on Goal (before update,after insert,after update) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('GoalTrigger'); 
        if(triggerSetting.isActive__c){
            if(trigger.isBefore){
            
                 if(trigger.isUpdate){
                    GoalTriggerController.aeContractorAndMgrValidation(Trigger.new,Trigger.oldMap);
                }
                
            }else{ 
                        
                if(trigger.isInsert){
                    GoalTriggerController.goalContractorSharingMgrGrp(Trigger.New); 
                    GoalTriggerController.goalSharingMgrGrp(Trigger.New);                   
                }
                if(trigger.isUpdate){                    
                   GoalTriggerController.updategoalContractorSharingMgrGrp(Trigger.new,Trigger.oldMap);
                   GoalTriggerController.goalSharingMgrGrp(Trigger.New); 
                   
                }
            }
        }

}