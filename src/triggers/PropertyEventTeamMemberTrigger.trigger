trigger PropertyEventTeamMemberTrigger on Property_Event_Team_Member__c (before insert, before update, after insert,after update, before delete, after delete) {
    
    if(TriggerSettings__c.getValues('PropertyEventTeamMemberTrigger')!=null && TriggerSettings__c.getValues('PropertyEventTeamMemberTrigger').IsActive__c){
        if(Trigger.isBefore){
            if(Trigger.isDelete){               
                PropertyEventTeamMemberTriggerController.deleteCalenderEvent(Trigger.old);
            }
        }else{ //Trigger.isAfter
            if(Trigger.isInsert){
                PropertyEventTeamMemberTriggerController.sharePropertyEventsWithTeamMembers(Trigger.new, null);
                PropertyEventTeamMemberTriggerController.createCalenderEvent(Trigger.new);
            }
            if(Trigger.isUpdate){
                if(CheckRecursiveForPropEventTeamMemb.runOnce()){
                    PropertyEventTeamMemberTriggerController.updateCalenderEvent(Trigger.new, Trigger.oldMap);
                }
            }            
        }
    }
}