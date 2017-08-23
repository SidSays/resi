({
	helperMethod : function() {
		
	},
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
    
    showAlertBox : function(component, event, helper, title, confirm) {     
        var OkBox = false;
        var checkErrorsOnEndVisit = false;
        if(confirm == false){
            var OkBox = true;
        }
        else{
            checkErrorsOnEndVisit = true;
        }
		var title = title;   
        $A.createComponent(
            "c:IndirectShowAlert",{ 
                "title" : title,
                "confirmBox" : confirm,
                "OkBox" : OkBox,
                "checkErrorsOnEndVisit" :checkErrorsOnEndVisit
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