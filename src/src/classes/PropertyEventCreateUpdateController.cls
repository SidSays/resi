/********************************************** 
* @Class Name : PropertyEventCreateUpdateController 
* @Description : This class is used as the server side controller for Property Event Aura Component
* @Author : Sagarika Somasundaram
* @User Story : US1139296
* @Last modified Date: 14 July 2017 
* Modified By: Amit Kumar on 16 Aug 2017
* Modification Reason: US1169976: Added the code to prepopulate the name of the Property Event
**********************************************/
public without sharing class PropertyEventCreateUpdateController {
	
    private static String EVENT = 'Event';
    
    /*
	* @Created By : Sagarika
	* @Created Data : 14th July 2017
	* @Description : Initialize data for Property Event Quick Action Lightning Component
	* @Param: eventId
	* @Return: EventWrapper
	* @User Story : US1139296(XC DT - Create Property Event from Event)
	*/   
    @AuraEnabled
    public static EventWrapper init(String eventId) {   
    	EventWrapper eventWrapper = new  EventWrapper();
    	eventWrapper.createNewProperty = true;
    	eventWrapper.showValidation = false;
        try
        {
        	if(!String.isBlank(eventId))
		 	{   //US1169976: Modified the query to add subject.
		 		List<Event> eventList = [Select CAR_Activity_Type__c, WhatId, Property_Event__c, StartDateTime, EndDateTime,subject   from Event WHERE id =: eventId];
		 		if(!eventList.isEmpty())
		 		{			
		 			Event selectedEvent = eventList[0];
		 			eventWrapper.selectedEvent = selectedEvent;
		 			if(!String.isBlank(selectedEvent.CAR_Activity_Type__c) && !EVENT.equalsIgnoreCase(selectedEvent.CAR_Activity_Type__c))
		 			{
						eventWrapper.isEventCarActivityType = true;
						eventWrapper.showThisMessage = System.Label.CARActivityTypeShouldBeEvent;
						eventWrapper.showValidation = true;
		 			}
		 			if(!String.isBlank(selectedEvent.WhatId))
		 			{
		 				if(MDU_Property__c.getSObjectType().getDescribe().getName().equals(selectedEvent.WhatId.getSobjectType().getDescribe().getName()))
		 				{
							eventWrapper.selectedProperty = selectedEvent.WhatId;
							eventWrapper.eventStartDate = selectedEvent.StartDateTime;
							eventWrapper.eventEndDate = selectedEvent.EndDateTime;
                            eventWrapper.eventSubject = selectedEvent.subject; //US1169976: Added the subject to pre-populate the Event Name
		 				}
		 			}
		 			if(!String.isBlank(selectedEvent.Property_Event__c))
		 			{
		 				eventWrapper.createNewProperty = false;
		 			}
		 		}
		 	}
        }
        catch(Exception e)
        {
        	ApplicationLogUtil.insertApplogforexceptions(e, ConstantHandler.STR_CLASS, PropertyEventCreateUpdateController.class.getName(), Property_Events__c.getSObjectType().getDescribe().getName(), false, null, ConstantHandler.nonintegrationRTypeId);
        }
        return eventWrapper;        
    }

      
    /*
	* @Created By : Sagarika
	* @Created Data : 14th July 2017
	* @Description : Wrapper to use on the Property Event Quick Action and for displaying data on the Property Event Page
	* @Param: eventId
	* @Return: EventWrapper
	* @User Story : US1139296(XC DT - Create Property Event from Event)
	*/  
    public without sharing class  EventWrapper {
    	@AuraEnabled public boolean showValidation {get; set;}
        @AuraEnabled public boolean isEventCarActivityType {get; set;}
        @AuraEnabled public String showThisMessage {get; set;}
        @AuraEnabled public Event selectedEvent {get; set;}
        @AuraEnabled public String selectedProperty {get; set;}
        @AuraEnabled public Datetime eventStartDate {get; set;}
        @AuraEnabled public Datetime eventEndDate {get; set;}
        @AuraEnabled public boolean createNewProperty {get; set;}
        @AuraEnabled public String eventSubject {get; set;}   //US1169976: Added the subject to pre-populate the Event Name
    }
    
   

}