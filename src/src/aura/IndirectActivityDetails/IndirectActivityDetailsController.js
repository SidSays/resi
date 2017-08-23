({
	showActivityDetails : function(component, event, helper) {
        console.log('inside show activity details');
		var selectedItem = event.currentTarget;
        var storevisitCategoryRecordId = selectedItem.dataset.record;
       
        component.set("v.iconDown" , "slds-hide");
        component.set("v.iconUp" , "slds-show");
        var storeVisit = component.get("v.storeVisit");
        
        var storeAct = component.get("c.getActivityDetails");
        storeAct.setParams({
            "storevisitCategoryRecordId" : storevisitCategoryRecordId,
            "storeVisitId" : storeVisit
        });
        storeAct.setCallback(this, function(a){
            var appEvent = $A.get("e.c:IndirectAddButtonEvent");
			appEvent.setParams({"storeActivities" : a.getReturnValue()});
			appEvent.fire();
		});
        $A.enqueueAction(storeAct);
	},
    
    toggle: function(component){
        component.set("v.iconDown" , "slds-show");
        component.set("v.iconUp" , "slds-hide");
        var closeEvent = $A.get("e.c:IndirectAccordionCloseEvent");
        closeEvent.setParams({"close" : "true" });
		closeEvent.fire();
    }
    

    
})