({
    
    init : function(component, event, helper) {
        
        var action = component.get('c.init');
        action.setParams({ eventId : component.get('v.recordId') });
        action.setCallback(this, function(a) {
            var event = a.getReturnValue(); 
            component.set('v.event', event);
            if(event.showValidation)
            {
            	component.set('v.validationMessage', event.showThisMessage);
            	var dismissActionPanel = $A.get('e.force:closeQuickAction');
    	        dismissActionPanel.fire();
            	this.fireValidationMessage(component);            
            }          
            else
            {
            	this.createOrLoadPropertyEvent(component);    
            }
        });
        $A.enqueueAction(action);

    },
   
    createOrLoadPropertyEvent : function(component, event, helper) {

        var event = component.get('v.event');
        var dismissActionPanel = $A.get('e.force:closeQuickAction');
        if(event.createNewProperty)
        {     
        	dismissActionPanel.fire();
            var createRecordEvent = $A.get('e.force:createRecord');
            createRecordEvent.setParams({
                'entityApiName': 'Property_Events__c',
                'defaultFieldValues': {
					'EventId__c':component.get('v.recordId'),
					'Property__c': event.selectedProperty,
					// US1141720 - Prefill Date on Event - default the start date and end date 
					'Start_Time__c': event.eventStartDate,
					'End_Time__c': event.eventEndDate,
                    // US1141720 _ End
                    // US1169976*******************START*****Added the code to prepopulate the name of the Property Event
                	'Name': event.eventSubject
                    // US1169976*******************END*****Added the code to prepopulate the name of the Property Event
                }});
            createRecordEvent.fire();              
        } 
        else
        {
            dismissActionPanel.fire();
            var showRecordEvent = $A.get("e.force:navigateToSObject");
            showRecordEvent.setParams({
            	"recordId": event.selectedEvent.Property_Event__c
            });
            showRecordEvent.fire();
        }
    },
    
     fireValidationMessage : function(component, event, helper) {

        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'title': 'Error!',
            'message': component.get('v.validationMessage'),
            'type': 'Error'
        });
        toastEvent.fire();
        
    }   
    

})