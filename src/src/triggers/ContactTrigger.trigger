/********************************************** 
 * @Last modified By: Deepika Jain, Accenture
 * @Last modified Date: 12-July-2017 
 * @Description : When a contact is deleted then that contact has to be removed from team member.
 * @User Story : US1117746(XC Property Event - Delete Contacts)
 ***************************************************************************************************************************************/
trigger ContactTrigger on Contact (after insert, after update, before insert, before update, after delete, before delete) {
    public static final String CONTACT_TRIGGER = 'ContactTrigger';
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues(CONTACT_TRIGGER);
    /*if(triggerSetting.isActive__c){
        if(trigger.isAfter){
            if(trigger.isInsert){
                ContactTriggerController.populateContactOnAccount();
            }
            else if(trigger.isUpdate){
                ContactTriggerController.updateAccountName();
            }  
        }
    }*/
    
   if(triggerSetting != null && triggerSetting.isActive__c){
        if(trigger.isBefore){
            ContactTriggerController.updateBirthdate(Trigger.New);
            if(trigger.isDelete){ //calling method to delete the team member if contact is deleted.
                ContactTriggerController.deleteTeamMemberIfContactDeleted(Trigger.Old);
            }
        }
    }
}