({
	    
    defaultCloseAction : function(component, event, helper) {  
        helper.defaultClose(component,event, helper);
    },
   
    SaveEvent : function(component, event ,helper) {
        var startDateTime= component.find("startDateTime"); 
        var stdate = startDateTime.get("v.value");       
        var subject =component.get("v.subject");
        var whatId=component.get("v.whatId") || null;
        if(stdate == null || stdate == ""){ 
            startDateTime.set("v.errors", [{message:"Please enter date" }]);
        }else{ 
            startDateTime.set("v.errors", null);
            var action = component.get("c.saveEvent");
            action.setParams({ 
                subject : subject,
                startDateTime : stdate,
                whatId :whatId });
    		helper.defaultClose(component,event, helper);	
            action.setCallback(this, function(response) {
                var state = response.getState();
                var toastEvent = $A.get("e.force:showToast");
                if (state === "SUCCESS") {   
                        $A.get('e.force:refreshView').fire();
                }
                else if (state === "ERROR") {
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": " Something has gone wrong."
                        });
                }
                toastEvent.fire();
            });
    
            $A.enqueueAction(action);
            
        } 
    }
})