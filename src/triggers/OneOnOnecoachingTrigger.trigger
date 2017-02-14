trigger OneOnOnecoachingTrigger on one_one_Coaching__c (before insert, after insert) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('OneOnOnecoachingTrigger');
        if(triggerSetting.isActive__c){
            if(trigger.isBefore){
                if(trigger.isInsert){
                    OneOnOnecoachingTriggerController.OneOnOneCoachingValidation(Trigger.New);
                }
            }else{
                if(trigger.isInsert){
                    if(OneOnOnecoachingTriggerController.validationFlag ){
                    OneOnOnecoachingTriggerController.coachingTaskMapping(Trigger.New);
                    }
                }
                
                 
            }
        }
    
}