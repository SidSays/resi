/***********************************************
* Trigger Name: PropertyEventTeamMemberTrigger 
* Author: Malay Desai 
* Description: Sharing Property Event with Team Member
* Modified by: Shalaka Kadwade, Date:3-Feb-2017, US911767: calling createCalenderEvent,updateCalenderEvent,deleteCalenderEvent.
* @Last Modified By: Amit Kumar Pradhan
* @Last Modified Data:8th June 2017
* @Description: Code commented as we are removing the creation of calender Event functionality
* @User Store: US1117802(XC Property Event - Remove Event Creation)
* @Last Modified By : Amit Kumar Pradhan
* @Last Modified Data : 14th June 2017
* @Description : Team member needs to be added/removed as attendees to the salesforce Event when team member is added/removed.
* @User Story : US1119205(XC Property Event - add/remove team memebr) 
* @Last Modified By : Deepika Jain Naresh, Accenture
* @Last Modified Date : 11th July 2017
* @Description : When Team member phone number is updated in team member page then the phone number need to be updated in the respective user or contact record.
* @User Story : US1141203(XC Property Event - Team Member phone)              
***********************************************/
trigger PropertyEventTeamMemberTrigger on Property_Event_Team_Member__c (before insert, before update, after insert,after update, before delete, after delete){
    /************
    * Description: Replacing hardcoding value with constant.(Modified By:Amit Kumar Pradhan)
    *************/
    public static final String PROP_EVENT_TEAM_MEMBER_TRIGGER = 'PropertyEventTeamMemberTrigger';
    public static boolean ranOnce = false;
    if(TriggerSettings__c.getValues(PROP_EVENT_TEAM_MEMBER_TRIGGER)!=null && TriggerSettings__c.getValues(PROP_EVENT_TEAM_MEMBER_TRIGGER).IsActive__c){
        if(Trigger.isBefore){
            if(Trigger.isDelete){
                /************
                * @Last Modified By: Amit Kumar Pradhan
                * @Last Modified Data:8th June 2017
                * @Description: Code commented as we are removing the creation, updation and deletion of calender Event functionality
                * @User Store: US1117802(XC Property Event - Remove Event Creation)--Start
                *************/
                //PropertyEventTeamMemberTriggerController.deleteCalenderEvent(Trigger.old);
                /************
                 * @User Store: US1117802(XC Property Event - Remove Event Creation)--End
                *************/
            }
            if(Trigger.isUpdate){
            	PropertyEventTeamMemberTriggerController.validatePhoneNumber(Trigger.new);
            }
            if(Trigger.isInsert){
            	PropertyEventTeamMemberTriggerController.validatePhoneNumber(Trigger.new);
            }
        }else{ //Trigger.isAfter
            if(Trigger.isInsert){
                PropertyEventTeamMemberTriggerController.sharePropertyEventsWithTeamMembers(Trigger.new, null);
                /************
                * @Last Modified By : Amit Kumar Pradhan
                * @Last Modified Data : 14th June 2017
                * @Description : calling PropertyEventTeamMemberTriggerController.addAttendeesToCalenderEvent while inserting team member
                * @User Story : US1119205(XC Property Event - add/remove team memebr)--Start
                *************/
                PropertyEventTeamMemberTriggerController.addAttendeesToCalenderEvent(Trigger.new);
                /************
                @User Story : US1119205(XC Property Event - add/remove team memebr)--End
                *************/
                
                /************
                * @Last Modified By: Amit Kumar Pradhan
                * @Last Modified Data:8th June 2017
                * @Description: Code commented as we are removing the creation, updation and deletion of calender Event functionality
                * @User Store: US1117802(XC Property Event - Remove Event Creation)--Start
                *************/
                //PropertyEventTeamMemberTriggerController.createCalenderEvent(Trigger.new);
                /************
                 * @User Store: US1117802(XC Property Event - Remove Event Creation)--End
                *************/
            }
            if(Trigger.isUpdate){
                /************
                * @Last Modified By: Amit Kumar Pradhan
                * @Last Modified Data:8th June 2017
                * @Description: Code commented as we are removing the creation, updation and deletion of calender Event functionality
                * @User Store: US1117802(XC Property Event - Remove Event Creation)--Start
                *************/
                /*
                if(CheckRecursive.runOnce()){                   
                    PropertyEventTeamMemberTriggerController.updateCalenderEvent(Trigger.new, Trigger.oldMap);
                }*/
                /************
                 * @User Store: US1117802(XC Property Event - Remove Event Creation)--End
                *************/
                /************
                * @User Story : US1141203(XC Property Event - Team Member phone)--Start
                *************/
                if(!ranOnce){
                //Adding as part of US1141203- Added By Deepika Jain Naresh
                //Method to update the user or contact phone when the phone is changed in team member page.
                	PropertyEventTeamMemberTriggerController.updateTeamMemberPhone(Trigger.new, Trigger.oldMap);
                	ranOnce=true;
                }
                /************
                * @User Story : US1141203(XC Property Event - Team Member phone)--End
                *************/
            }
            /************
            * @Last Modified By : Amit Kumar Pradhan
            * @Last Modified Data : 14th June 2017
            * @Description : calling PropertyEventTeamMemberTriggerController.deleteAttendeesFromEvent when deleting team member
            * @User Story : US1119205(XC Property Event - add/remove team memebr)--Start
            *************/
            if(Trigger.isDelete){
                PropertyEventTeamMemberTriggerController.deleteAttendeesFromEvent(Trigger.old);
            }
            /************
            @User Story : US1119205(XC Property Event - add/remove team memebr)--End
            *************/
        }
    }
}