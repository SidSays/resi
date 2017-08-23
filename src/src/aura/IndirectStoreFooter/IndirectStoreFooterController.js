({
	goToMyStores : function(component) {
		var navigateEvent = $A.get("e.c:IndirectNavigateToMyStores");
        navigateEvent.setParams({"currentuser" : component.get("v.loggedInUser"),
                                 "hisstores":component.get("v.stores"),
                                 "hisvisits":component.get("v.storevisits")});
        navigateEvent.fire();
	},
    
    goToMyDashboard : function(component) {
		var navigateEvent = $A.get("e.c:IndirectNavigateToDashboard");
        navigateEvent.setParams({"currentuser" : component.get("v.loggedInUser"),
                                 "hisstores":component.get("v.stores"),
                                 "hisvisits":component.get("v.storevisits")});
        navigateEvent.fire();
	},
})