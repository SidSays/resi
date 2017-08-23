({
    doInit : function(component, event, helper) {
        var action = component.get("c.getVisitTypeValue");       
        action.setCallback(this, function(a){
            var opts= [];  var types = [];
            types = a.getReturnValue();
            opts.push({ class: "optionClass", label: "--Select Type of Visit--", value: "--Select Type of Visit--", selected: "true" });
            for(var i =0; i< types.length; i++){
                if(types[i] == 'Event') 
                { opts.push({ class: "optionClass", label: types[i], value: types[i]});}
                
                else if(types[i] == 'Prospect')
                {
                    if(component.get("v.loggedInUser").Sales_Rep_Type__c == 'Dealer AE')
                        opts.push({ class: "optionClass", label: types[i], value: types[i] });
                }                
                else 
                {
                    opts.push({ class: "optionClass", label: types[i], value: types[i] }); 
                }  
            }
            
            component.find("visitList").set("v.options", opts);
        });
            $A.enqueueAction(action);
         helper.getInitLocation(component);
    },
    
    onSelectChange : function(component, event, helper) {
        var selected = component.find("visitList").get("v.value");
        component.set("v.selectedvisit",selected);
        var message = component.find("messagebox");
        message.set("v.class","slds-hide"); 
       
    },
    
    saveVisit : function(component, event, helper) {    
        if (!navigator.geolocation){
            //alert('Geolocation is not supported by your browser');
          
            var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        "title": "Error!",
					        "message": "Geolocation is not supported by your browser"
					    });
					    toastEvent.fire();
        }
        navigator.geolocation.getCurrentPosition(success, error);
        function success(position) {
            component.set("v.lat",position.coords.latitude); 
            component.set("v.longi",position.coords.longitude); 
        }
        function error() {
            //alert('Unable to retrieve your location');
           
             var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        "title": "Error!",
					        "message": "Unable to retrieve your location"
					    });
					    toastEvent.fire(); 
        }
        //var result =  confirm("Are you sure that you want to end this visit?");
        var title = "Are you sure that you want to end this visit?";
		var confirm = true;
		helper.showAlertBox(component, event, helper, title ,confirm); 
	},
	
	checkErrorsOnEndVisit : function(component, event, helper){
		
		var result = event.getParam("checkErrorsOnEndVisit");
        if(result == true){
        var lat = component.get("v.lat");
        var longi = component.get("v.longi");  
        var startDateTime = component.find("startdate").get("v.value");
        var endDateTime = component.find("enddate").get("v.value");
        var notes = component.find("notes").get("v.value");
        var message = component.find("messagebox");
        var outputText = message.get("v.body")[0];        
        if(startDateTime == null || endDateTime == null){
            
            message.set("v.class","slds-show");
            outputText.set("v.value","Fields marked with an asterisk ( * ) are mandatory.");
            
        } else if(startDateTime > endDateTime){
            message.set("v.class","slds-show");
            outputText.set("v.value","Start Date/Time must not be later than the End Date/Time");
        } else{
            message.set("v.class","slds-hide");
            var action = component.get("c.saveOtherVisitAndSendEmail");
            action.setParams({
                "startDateTime" : startDateTime,           
                "endDateTime" : endDateTime,
                "notes" : notes,
                "lat" : lat,
                "longi" : longi,  
                "type": component.get("v.selectedvisit"),
                "repUser": component.get("v.loggedInUser")
            });
            
            action.setCallback(this, function(a){ 
                var returnString = a.getReturnValue().split("##");
                if(returnString[0] === "Success"){
                    
                    var appEvent = $A.get("e.c:IndirectSendSummaryEvent");
                    
                    appEvent.setParams({ 
                        "bodyToRender" : "sendsummary",
                        "emailSummaryForOtherVisits" : returnString[1]
                    });
                    appEvent.fire();
                    
                    var toastEvent = $A.get("e.force:showToast");
                    if(a.getState() === "SUCCESS"){
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Email sent successfully."
                        });
                        toastEvent.fire();
                    }
                } else{                   
                    message.set("v.class","slds-show");
                    outputText.set("v.value",returnString[1]);
                }            
                
            });
            $A.enqueueAction(action);  
        }
    }

}
           
})