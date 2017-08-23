/** **********************************************************************
* Name: PropertyTrigger
* Author: Ashish Sonawane
* User Story : 
* Description: Property trigger to manage various operations
    Date                 PRJ/DFCT/ENHC#            Summary of Changes 
  -------------         -----------------       ------------------------------
  19-December-2014        Comcast Resi              Initial Release 
* Last Modified By: Tejaswini Kasar
* Last Modified Date : 5th MAY 2017
* Desciption : Adding method "sendEmailForExpiredRiskStatusonProperty" of apex class PropertyTriggerOperations (after update) related US978557( XC - Workflow alerts for CARs, CAR manager an XC Analyst).
* Last Modified By: Deepika Jain
* Last Modified Date : 14th Aug 2017
* User story  : US1167685(XC - Wifi Ready Fields in Opportunity).
* Desciption : Adding method "updateOppFields" of apex class PropertyTriggerOperations (after update). This method is used to update the fields on Opportunity when the same fields on Property are updated.

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
                    PropertyTriggerSequencer.sendEmailForExpiredRiskStatusonProperty(Trigger.oldmap,Trigger.new);
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
                    PropertyTriggerOperations.updateOppFields(Trigger.new, Trigger.oldmap); // Added as part of US1167685. Added by Deepika Jain
                }
            }       
        } 
    }
    catch(Exception e){
        System.debug('>>>>>>>>>>>>>Error Message'+e.getMessage());
    }
}