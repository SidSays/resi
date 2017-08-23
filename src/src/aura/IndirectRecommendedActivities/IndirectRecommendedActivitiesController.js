({
    doInit : function(component, event, helper) {
        if(component.get("v.storeVisitCategory") != null){
            var action = component.get("c.getCategories");
            action.setParams({
                "storeId": component.get("v.storeId"),           
                "categories": component.get("v.storeVisitCategory"),
                "loggedInUserId": component.get("v.loggedInUserId")
            });
            action.setCallback(this, function(a){
                component.set("v.activities", a.getReturnValue());            
            });
            $A.enqueueAction(action);
        }
    },
    getShowHide: function(component, event, helper) {
        var show = component.get("v.show");        
        if(show == false)
        {
            component.set("v.show", true);          
        }
        else
        {
            component.set("v.show", false);          
        }
        console.log('after'+ component.get("v.show"));
    },
    
    navigateToActivityScreen: function(component, event, helper) {
        var categories = component.get("v.storeVisitCategory");
        var storeId = component.get("v.storeId");
	 	var navigateEvent = $A.get("e.c:IndirectNavigateToStoreVisit");
                    navigateEvent.setParams({"storeId" : storeId,
                                             "bodyToRender" : "storevisit",
                                             "storeVisitCategory" : categories}).fire(); 
	}
})