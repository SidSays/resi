({
	createHuddle : function(component, event, helper) {
       
		var appEvent = $A.get("e.c:huddleEvent");
        console.log('inside Event'+appEvent);
        appEvent.setParams({            
            "Amit" : "AAAAAA"
        });        
        appEvent.fire();
         console.log('After Fire');
        /*var appEvent = $A.get("e.c:IndirectAddButtonEvent");
        console.log('inside Event'+appEvent);
            appEvent.setParams({
                "storeActivities" : "AAA",
                "edit" : false,
                "readOnly" : true
            });
            appEvent.fire();*/
	}
})