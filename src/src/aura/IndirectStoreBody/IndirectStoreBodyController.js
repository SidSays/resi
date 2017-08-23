({
	doInit : function(component, event, helper) {
		var action = component.get("c.getStoreDetails");
        action.setParams({
            "storeType" : component.get("v.store.Store_Type__c"),
            "userRoleName" : component.get("v.role.DeveloperName")
        });
        action.setCallback(this, function(a){
            var storeDetails = a.getReturnValue();
            component.set("v.storeVisitCategory", storeDetails.categories);
            component.set("v.store",storeDetails.storeMap[component.get("v.store.Id")]);
            var getRelatedListEvent = $A.get("e.c:IndirectGetStoreRelatedData");
                getRelatedListEvent.setParams({"storeVisitCategory" : storeDetails.categories,
                                               "bodyToRender" : "storedetail",
                                               "storeMap" : storeDetails.storeMap,
                                               "storeId" : component.get("v.store.Id")}).fire();
        });
        $A.enqueueAction(action);
       
	}
})