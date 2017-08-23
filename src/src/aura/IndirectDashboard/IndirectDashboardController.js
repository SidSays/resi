({
	goToStoreDetail: function(component,event,helper){
         var selectedItem = event.currentTarget; // Get the target object
         var index = selectedItem.dataset.record; // Get its value i.e. the index
         var selectedStoreVisit = component.get("v.storevisits")[index]; // Use it retrieve the store record
         var appEvt = $A.get("e.c:IndirectNavigateToStoreDetails");
         	 appEvt.setParams({"storeId" : selectedStoreVisit.WhatId,
                           "bodyToRender" : "storedetail"}).fire();
        
        /*var action = component.get("c.getRelatedStore");
         action.setParams({
            "storeId" : selectedStoreVisit.WhatId
        });
         action.setCallback(this, function(a){ 
             var store = a.getReturnValue();
             var appEvt = $A.get("e.c:IndirectNavigateToStoreDetails");
         	 appEvt.setParams({"store" : store,
                           "bodyToRender" : "storedetail"}).fire();
         });
       $A.enqueueAction(action);  */
    },
    
    goToEventDetail: function(component,event,helper){
        var selectedItem = event.currentTarget; // Get the target object
        var index = selectedItem.dataset.record; // Get its value i.e. the index
        var selectedStoreVisit = component.get("v.upcomingEvents")[index];
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          "url": "/"+selectedStoreVisit.Id
        });
        urlEvent.fire();
    },
    
    deleteEvent : function(component,event,helper){
        var selectedItem = event.currentTarget; // Get the target object
        var index = selectedItem.dataset.record; // Get its value i.e. the index
        var selectedEvent = component.get("v.upcomingEvents")[index];        
        //var result = confirm("Are you sure you want to delete this Event?");
        var title = "Are you sure you want to delete this Event?";
		helper.showAlertBox(component, event, helper,title, true, selectedEvent); 
    },
    
    deleteScheduleEvent: function(component,event,helper){
     console.log('in deleteScheduleEvent');
        var selectedEvent = event.getParam("selectedEvent");
       console.log("selectedEvent"+ selectedEvent);
        var action = component.get("c.deleteEventObj");
       
            action.setParams({
                "eventObj" : selectedEvent
            });
            action.setCallback(this, function(a){
                	var deletedEvent = a.getReturnValue();
                    //console.log('Deleted Event Object' +  deletedEvent);
                    var items = [];
                    var upcomingEvents = component.get("v.upcomingEvents");
                    for(i=0; i<upcomingEvents.length; i++){
                        if(upcomingEvents[i] !== deletedEvent){
                            items.push(upcomingEvents[i]);
                        }
                    }
                    component.set("v.upcomingEvents",items);
                	$A.get('e.force:refreshView').fire();
                	//component.rerender();
                	//var navigateEvent = $A.get("e.c:IndirectNavigateToDashboard");
            		//navigateEvent.setParams({"bodyToRender" : "visits"}).fire();
            })
            $A.enqueueAction(action);
        
    
    }
})