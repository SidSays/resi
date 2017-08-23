({
    doInit : function(component, event, helper) {
        var action = component.get("c.getVisitStatus");
        action.setParams({
            "usr" : component.get("v.loggedInUser")
        });
        action.setCallback(this,function(a){
            var storeVisitObj = a.getReturnValue();
            if(storeVisitObj != null){
                component.set("v.startVisit", true);
                component.set("v.endVisit", false);
                component.set("v.notesVisibility",false);
                component.set("v.StartDateTime",storeVisitObj.Start_Date_Time__c);
                component.set("v.visitId",storeVisitObj.Id);
            }
        });
        $A.enqueueAction(action);
        helper.getInitLocation(component);
    },
    
    startVisit : function(component,event,helper){
        helper.createEvent(component);
    },
    
    endVisit : function(component, event, helper){
        var isTrueString='';
        var emailSummary='';
        var message = component.find("messagebox");
        var outputText = message.get("v.body")[0];
        var title = component.find("Title").get("v.value");
        //var result =  confirm("Are you sure that you want to end this visit?");
		var title2= "Are you sure that you want to end this visit?";
		var confirm = true;
		helper.showAlertBox(component, event, helper,title2, confirm); 
        
    },
    
	checkErrorsOnEventEndVisit : function(component, event, helper){

	 var isTrueString='';
        var emailSummary='';
        var message = component.find("messagebox");
        var outputText = message.get("v.body")[0];
        var title = component.find("Title").get("v.value");
		var result = event.getParam("checkErrorsOnEventEndVisit");
		if(result == true){
        	if(title == null || title == ""){
            message.set("v.class","slds-show");
            outputText.set("v.value","Fields marked with an asterisk ( * ) are mandatory.");
            
        } else {
            message.set("v.class","slds-hide");
            var act = component.get("c.isAutoCompletedANDEmailSummary");
            act.setParams({
                "visitId" : component.get("v.visitId"),               
                "repUser" : component.get("v.loggedInUser")
            });
            act.setCallback(this,function(a){
                var returnString = a.getReturnValue().split("##");
                isTrueString = returnString[0];
                emailSummary = returnString[1];
                
                if(isTrueString == 'true'){                    
                    //alert("This visit has already ended.");
                  
                      var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        "title": "Error!",
					        "message": "This visit has already ended."
					    });
					    toastEvent.fire();
                      var appEvent = $A.get("e.c:IndirectSendSummaryEvent");
                    
                    appEvent.setParams({ 
                        "bodyToRender" : "sendsummary",
                        "emailSummaryForOtherVisits" : returnString[1]
                    });
                    appEvent.fire();
                    
                }else{
                    
                    if (!navigator.geolocation){
                       // alert('Geolocation is not supported by your browser');
                     
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
                        var lat = component.get("v.lat");
                        var longi = component.get("v.longi");
                        var notes = component.find("notesId").get("v.value");
                        var visitId = component.get("v.visitId");
                        var action = component.get("c.saveEventVisitAndSendEmail");
                        action.setParams({
                            "visitId" : visitId,
                            "notes" : notes,
                            "title" : title,
                            "lat" : lat,
                            "longi" : longi,
                            "repUser" : component.get("v.loggedInUser")
                        });
                        action.setCallback(this,function(a){
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
                            }
                            
                        });
                        $A.enqueueAction(action);
                }		
                
            });
            $A.enqueueAction(act);      
        }
	}
	}
})