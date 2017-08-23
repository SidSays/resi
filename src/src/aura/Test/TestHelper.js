({


    
    doesPropertyEventExist : function(component) {

        var action = component.get("c.checkForExistingPropertyVisit");
        action.setParams({ eventId : component.get('v.recordId') });
        action.setCallback(this, function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var propertyEventId = a.getReturnValue();              
                if(propertyEventId.length > 0)
                {
                    component.set("v.edit", true);               	
                    component.set("v.propertyEventId", propertyEventId);
					alert(component.get("v.propertyEventId"));                   
                } 
                else
                {
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams({
                        "entityApiName": "Property_Events__c",
                        "defaultFieldValues": {
      						"EventId__c":component.get("v.recordId")
                        }});
                    createRecordEvent.fire();
                }
            }            
        }); 
        $A.enqueueAction(action);
    },
    
    
})