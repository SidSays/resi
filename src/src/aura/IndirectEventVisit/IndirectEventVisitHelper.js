({
	    
    getInitLocation: function(component,event,helper){
        var lat; 
        var longi;
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
            lat = position.coords.latitude; 
            longi = position.coords.longitude;
            component.set("v.lat", lat);
            component.set("v.longi", longi);
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
        
    },
   
    createEvent: function(component){
  
    var action = component.get("c.createEventVisit");
            action.setParams({
                "lat" : component.get("v.lat"),
                "longi" : component.get("v.longi")
            });
            action.setCallback(this,function(a){               
                var storeVisitObj = a.getReturnValue();
                component.set("v.StoreVisitObj",storeVisitObj);                
                component.set("v.startVisit", true);                
                component.set("v.endVisit", false);               
                component.set("v.notesVisibility",false);
                var startDateTime = storeVisitObj.Start_Date_Time__c;
                component.set("v.StartDateTime",startDateTime);               
                component.set("v.visitId",storeVisitObj.Id);
            });
            $A.enqueueAction(action);
   
    },
    
    showAlertBox : function(component, event, helper, title, confirm) { 
        var OkBox = false;
        var checkErrorsOnEventEndVisit = false;
        if(confirm == false){
            var OkBox = true;
        }
       else{
            checkErrorsOnEventEndVisit = true;
        }
		var title = title;        
        $A.createComponent(
            "c:IndirectShowAlert",{ 
                "title" : title,
                "confirmBox" : confirm,
                "OkBox" : OkBox,
                "checkErrorsOnEventEndVisit" :checkErrorsOnEventEndVisit               
            },
            function(msgBox){
                if (component.isValid()) {
                    var targetCmp = component.find('optionalModalDialog');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                }
            }
        );
        
    },

})