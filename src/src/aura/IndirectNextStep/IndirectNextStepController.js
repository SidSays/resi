({
    doInit : function(component, event, helper){
        if(component.get("v.recommendedCategory") == null || 
           component.get("v.recommendedCategory") == '')
        {
            var action = component.get("c.getRecommendedCategories");
            action.setParams({
                storeId : component.get("v.store.Id"),
                categories : component.get("v.storeVisitCategory"),
                loggedInUserId : component.get("v.loggedInUser.Id")
            });
            action.setCallback(this, function(a){
                component.set("v.recommendedCategory", a.getReturnValue());
            });
            $A.enqueueAction(action);
        }
    },   
    
    AddItems : function (component,event,helper){      
        helper.getData(component, event, helper);
    },
    
    navigateToActivityScreen: function(component, event, helper) {
        var categories = component.get("v.storeVisitCategory");
        var storeId = component.get("v.store.Id");
	 	var navigateEvent = $A.get("e.c:IndirectNavigateToStoreVisit");
                    navigateEvent.setParams({"storeId" : storeId,
                                             "bodyToRender" : "storevisit",
                                             "storeVisitCategory" : categories}).fire(); 
	}
})