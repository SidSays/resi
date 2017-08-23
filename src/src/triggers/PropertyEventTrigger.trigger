/***********************************************
* Trigger Name: PropertyEventTrigger 
* Author: Joognu Rao, Accenture
* Date: 25-January-2017 
* Requirement #: US898825 
* Description: To restrict users from deleting the Property evets that have property event items associated.
* Modified by: Shalaka Kadwade, Date:3-Feb-2017, US911767: calling createCalenderEvent.
* @Last Modified By: Amit Kumar Pradhan
* @Last Modified Data:8th June 2017
* @Description: Code commented as we are removing the creation of calender Event functionality
* @User Store: US1117802(XC Property Event - Remove Event Creation)
* @Last Modified By : Amit Kumar Pradhan
* @Last Modified Data : 14th June 2017
* @Description : calling PropertyEventTriggerController.updateCalenderEventStatus to update status.
* @User Story : US1110746(XC DT - Property Event Status)
* @Last Modified By : Amit Kumar Pradhan
* @Last Modified Data : 22nd June 2017
* @Description : Calling updateCalenderEvent method to update Event when Property Event is updated.
* @User Story : US1104342(XC Property Events: Bidirectional Sync between Property Events & Events)  
* @Last Modified By : Sagarika 
* @Last Modified Date : 22nd June 2017
* @Description : On Deletion of property event create and send a cancelation email for the event to all invitees
* @User Story :  US1117736(XC Property Event - Delete Events)    
* @Last Modified By : Sagarika 
* @Last Modified Date : 12th July 2017
* @Description : When property event is created by the quick action on Standard Event Page, Link Standard Event to Property Event
* @User Story :  US1139296(XC DT - Create Property Event from Event)  
* @Last Modified Date : 21st July 2017
* @Description : Update the Metric 'Sales Event' for Property Lab user for each Property event completion
* @User Story :  US1143300(XC DT - Update Sale Event Metrics)  
*         
***********************************************/
trigger PropertyEventTrigger on Property_Events__c (before delete, after insert, after update, before update){
    /************
    * Description: Replacing hardcoding value with constant.(Modified By:Amit Kumar Pradhan)
    *************/
    public static final String PROPERTY_EVENT_TRIGGER = 'PropertyEventTrigger';
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues(PROPERTY_EVENT_TRIGGER);
    if(triggerSetting != null && triggerSetting.isActive__c){
        if(trigger.isBefore) {           
            if(trigger.isDelete){                  
                PropertyEventTriggerController objValidation = new PropertyEventTriggerController();
                objValidation.doNotDeleteWithItems(trigger.old); 
                //User Story : US1117736(XC Property Event - Delete Events)--Start
                PropertyEventTriggerController.sendEventCancelationAndDeleteTeamMembers(trigger.old);
                //User Story : US1117736(XC Property Event - Delete Events)--End
            }              
        }
        else{
            if(Trigger.isInsert){
                /************
                * @Last Modified By: Amit Kumar Pradhan
                * @Last Modified Data:8th June 2017
                * @Description: Code commented as we are removing the creation of calender Event functionality
                * @User Store: US1117802(XC Property Event - Remove Event Creation)--Start
                *************/
                //PropertyEventTriggerController.createCalenderEvent(Trigger.new);
                /************
                 * @User Store: US1117802(XC Property Event - Remove Event Creation)--End
                *************/
                
                //User Story : US1139296(XC DT - Create Property Event from Event)--Start
                PropertyEventTriggerController.updatePropertyEventOnStandardEvent(trigger.new);
                //User Story : US1139296(XC DT - Create Property Event from Event)--End
                
            }
           
            if(Trigger.isUpdate){
                /************
                * @Last Modified By : Amit Kumar Pradhan
                * @Last Modified Data : 14th June 2017
                * @Description : calling PropertyEventTriggerController.updateCalenderEventStatus while updating property Event
                * @User Story : US1110746(XC DT - Property Event Status)--Start
                *************/
                PropertyEventTriggerController.updateCalenderEventStatus(Trigger.new,Trigger.oldMap);
                //Added by AK on 21 July2017 for US1143300  **************************   START   *******************************
                PropertyEventTriggerController.updatesalemetric(Trigger.new,Trigger.oldMap);
                //Added by AK on 21 July2017 for US1143300  **************************   END   *******************************
                /************
                @User Story : US1110746(XC DT - Property Event Status)--End
                *************/
                
                /************
                * @Last Modified By : Amit Kumar Pradhan
                * @Last Modified Data : 22nd June 2017
                * @Description : Calling updateCalenderEvent method to update Property Event when Event is updated.
                * @User Story : US1104342(XC Property Events: Bidirectional Sync between Property Events & Events)--Start
                *************/
                PropertyEventTriggerController.updateCalenderEvent(Trigger.new,Trigger.oldMap);
                /************
                @ User Story : US1104342(XC Property Events: Bidirectional Sync between Property Events & Events)--End
                *************/
            }
            
        }
    }
}