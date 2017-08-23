trigger OneOnOnecoachingTrigger on one_one_Coaching__c (before insert, after insert, before update) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('OneOnOnecoachingTrigger');
        if(triggerSetting != null && triggerSetting.isActive__c){
            if(trigger.isBefore){
                if(trigger.isInsert){
                    OneOnOnecoachingTriggerController.OneOnOneCoachingValidation(Trigger.New);
                }
            }else{
                if(trigger.isInsert){
                    if(OneOnOnecoachingTriggerController.validationFlag ){
                        OneOnOnecoachingTriggerController.coachingTaskMapping(Trigger.New);
                        OneOnOnecoachingTriggerController.updatemetricsrecord(Trigger.New); //Added as a part of US1051006 - Update metric recods based on creation of 1-1 Coaching record
                        OneOnOnecoachingTriggerController.updateRetailManagerMetric(Trigger.New);//Addded as part of US1041357
                    }
                }
                
            }
        }
    
}