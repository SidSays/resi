/*
* Name: PhaseStatsTrigger
* Description: All PhaseStats Triggers execution is managed from here using Sequencer & Operations class call.
*/
trigger PhaseStatsTrigger on Phase_Stats__c (after update, after insert, after delete) {

    try{
        TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('PhaseStatsTrigger');
        if(triggerSetting.isActive__c){
            if(Trigger.IsAfter && Trigger.IsUpdate){
                PhaseStatsTriggerSequencer.afterUpdateOperation();
            }else if(Trigger.IsAfter && Trigger.IsInsert){             
                PhaseStatsTriggerSequencer.afterInsertOperation();
            }else if(Trigger.IsAfter && Trigger.IsDelete){
                PhaseStatsTriggerSequencer.afterDeleteOperation();
            }    
        }
    }
    catch(Exception e)
    {
        System.debug('>>>>>>>Error Message'+e.getMessage());
    }
}