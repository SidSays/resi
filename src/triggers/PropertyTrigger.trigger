/** **********************************************************************
* Name: PropertyTrigger
* Author: Ashish Sonawane
* User Story : 
* Description: Property trigger to manage various operations
    Date                 PRJ/DFCT/ENHC#            Summary of Changes 
  -------------         -----------------       ------------------------------
  19-December-2014        Comcast Resi              Initial Release 
**************************************************************************/
trigger PropertyTrigger on MDU_Property__c(before insert, before update,after update, before delete, after insert) {
    try{
        TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('PropertyTrigger');
        if(triggerSetting.isActive__c){
                    
            //Call to update video,voice,data unit's on contract(child) and Opportunity Property junction object record after updatation of #unit field on property(parent)            
            if(trigger.isAfter) {           
                if(trigger.isUpdate){
                    //Call sequencer method
                    //Change unit on Contract Object
                    PropertyTriggerSequencer.afterUpdate();
                    //Change unit on Opportunity Property Object
                    PropertyTriggerSequencer.changeUnitsOnOpportunityProperty();
                }               
            }
            else {
                if(trigger.isUpdate ||trigger.isInsert){
                    PropertyTriggerSequencer.beforeInsertUpdate();
                    PropertyTriggerSequencer.OldNewRegionUpdate();
                    PropertyTriggerSequencer.deletePropertyCheck(Trigger.new);
                }
            }
            
            /* 
            * Call to delete the property record based on conditions -
            * -No Open Opportunities 
            * -No Active New Builds (Based on Status!= Complete) 
            * The system shall require confirmation of deletion and a deleted reason when a user Deletes the record.
            */
            if(trigger.isBefore && trigger.isDelete){
                PropertyTriggerSequencer.beforeDelete();//Call sequencer method
            }
            if(trigger.isAfter) {
                if(trigger.isUpdate || trigger.isInsert){
                    PropertyTriggerOperations.profilepercentmetricupdate(Trigger.new , Trigger.oldmap);
                    PropertyTriggerOperations.CarChangeOnProperty(Trigger.new , Trigger.oldmap);
                }
            }       
        } 
    }
    catch(Exception e){
        System.debug('>>>>>>>>>>>>>Error Message'+e.getMessage());
    }
}