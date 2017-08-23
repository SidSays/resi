/*
* Name: NewBuildTrigger
* Description: All NewBuild Triggers execution is managed from here using Sequencer & Operations class call.
*/
trigger NewBuildTrigger on New_Build__c(after update, after insert, after delete) {

    try{
        TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('NewBuildTrigger');
        if(triggerSetting.isActive__c){
            if(Trigger.IsAfter && Trigger.IsUpdate){
                NewBuildTriggerSequencer.afterUpdateOperation();
            }else if(Trigger.IsAfter && Trigger.IsInsert){             
                NewBuildTriggerSequencer.afterInsertOperation();
            }else if(Trigger.IsAfter && Trigger.IsDelete){
                NewBuildTriggerSequencer.afterDeleteOperation();
            } else {}   
        }
    }   
    catch(Exception e){
        System.debug('>>>>>>>Error Message'+e.getMessage());
    }
}