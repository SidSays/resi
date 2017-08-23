({
    goToMyStores : function(component) {
        if(component.get("v.bodyToRender") != "stores"){ 
            var navigateEvent = $A.get("e.c:IndirectNavigateToMyStores");
            navigateEvent.setParams({"bodyToRender" : "stores"}).fire();
        }
    },
    
    goToDashboard : function(component) {
        if(component.get("v.bodyToRender") != "visits"){ 
            var navigateEvent = $A.get("e.c:IndirectNavigateToDashboard");
            navigateEvent.setParams({"bodyToRender" : "visits"}).fire();        
        }
    },
    
    goToOtherVisits : function(component) {
        if(component.get("v.bodyToRender") != "other"){ 
            var navigateEvent = $A.get("e.c:IndirectNavigateToOtherVisits");
            navigateEvent.setParams({"bodyToRender" : "other"}).fire();        
        }
    },
    goToOtherVisitHistory : function(component,event) {
        if(component.get("v.bodyToRender") != "otherHistory"){ 
            var navigateEvent = $A.get("e.c:IndirectOtherHistory");
            navigateEvent.setParams({"bodyToRender" : "otherHistory"}).fire();        
        }
    },
    
    /*goToOtherVisits2 : function(component) {
        if(component.get("v.bodyToRender") != "other2"){ 
            var navigateEvent = $A.get("e.c:IndirectNavigateToOtherVisits");
            navigateEvent.setParams({"bodyToRender" : "other2"}).fire();        
        }
    },*/
    
    goToVisitHistory : function(component, event, helper) {
        if(component.get("v.bodyToRender") != "visithistory"){ 
            var categories = component.get("v.storeVisitCategory");
            var action = component.get("c.queryActivityCategoriesForHistory");
            action.setParams({
                "storeType" : component.get("v.store.Store_Type__c"),
                "userRoleName" : component.get("v.role.DeveloperName")
            });
            action.setCallback(this, function(a){
                var allCategories = a.getReturnValue();
                var navigateEvent = $A.get("e.c:IndirectNavigateToVisitHistory");
                navigateEvent.setParams({"storeVisitCategory" : categories,
                                         "storeId" : component.get("v.store.Id"),
                                         "bodyToRender" : "visithistory",
                                         "allCategories" : allCategories}).fire();
            });            
            $A.enqueueAction(action);
            
        }
    },
    
    goToVisitHistory2 : function(component, event, helper) {
        if(component.get("v.bodyToRender") != "visithistory2"){ 
            var categories = component.get("v.storeVisitCategory");
            var action = component.get("c.queryActivityCategoriesForHistory");
            action.setParams({
                "storeType" : component.get("v.store.Store_Type__c"),
                "userRoleName" : component.get("v.role.DeveloperName")
            });
            action.setCallback(this, function(a){
                var allCategories = a.getReturnValue();
                var navigateEvent = $A.get("e.c:IndirectNavigateToVisitHistory");
                navigateEvent.setParams({"storeVisitCategory" : categories,
                                         "storeId" : component.get("v.store.Id"),
                                         "bodyToRender" : "visithistory2",
                                         "allCategories" : allCategories}).fire();
            });            
            $A.enqueueAction(action);
            
        }            
    },
    
    goToStoreVisit : function(component,event,helper) { 
        if(component.get("v.bodyToRender") != "storevisit"){ 
            var categories = component.get("v.storeVisitCategory");        
            var action = component.get("c.getActiveVisit");
            var storeId = component.get("v.store.Id");
            var user = component.get("v.loggedInUser");
            var role = component.get("v.role");
            var currentStoreName = component.get("v.store.Name"); 
            action.setParams({
                "StoreId" : storeId
            });
            action.setCallback(this, function(a){ 
                var state = a.getState();
                var storeName = a.getReturnValue();
                var store = component.get("v.store");
                
                if(storeName != null){
                    var title = "You are checked into "+ storeName +". By clicking “OK” you will be checked out of "+ storeName + " and checked into "
                    + currentStoreName + ". By clicking “Cancel” you will remain checked into "+ storeName +".";
                    var endPreviousStore = true;
                    helper.showAlertBox(component, event, helper, title,endPreviousStore); 
                    /* var r =  confirm("You are checked into "+ storeName +"\". By clicking “OK” you will be checked out of "+ storeName + " and checked into "
                                     + currentStoreName + ". By clicking “Cancel” you will remain checked into "+ storeName +".");
                    if( r == true){
                        var action1 = component.get("c.setCompletedStatus");
                        
                        action1.setParams({
                            "storeId" : store.Id
                        });
                        action1.setCallback(this, function(a){
                            var state2 = a.getState();
                            if(state2 == "SUCCESS"){
                                var navigateEvent = $A.get("e.c:IndirectNavigateToStoreVisit");
                                navigateEvent.setParams({"storeId" : store.Id,
                                                         "bodyToRender" : "storevisit",
                                                         "storeVisitCategory" : categories}).fire(); 
                            } else if (state2 === "ERROR") {
                                var errors = a.getError();
                                if (errors) {
                                    if (errors[0] && errors[0].message) {
                                        console.log("Error message: " + 
                                                    errors[0].message);
                                    }
                                } else {
                                    console.log("Unknown error");
                                }
                            }
                        });
                        $A.enqueueAction(action1);
                    }*/
                }
                else{
                    console.log('in else of footer');
                    
                    var navigateEvent = $A.get("e.c:IndirectNavigateToStoreVisit");
                    navigateEvent.setParams({"storeId" : store.Id,
                                             "bodyToRender" : "storevisit",
                                             "storeVisitCategory" : categories}).fire(); 
                }   
            }); 
            $A.enqueueAction(action);
        }
    },
    
    IndirectShowAlert: function(component, event, helper){
        
        if(event.getParam("endPreviousStore") == true){
            var store = component.get("v.store");
            var action1 = component.get("c.setCompletedStatus");
            var categories = component.get("v.storeVisitCategory");   
            action1.setParams({
                "storeId" : store.Id
            });
            action1.setCallback(this, function(a){
                var state2 = a.getState();
                if(state2 == "SUCCESS"){
                    var navigateEvent = $A.get("e.c:IndirectNavigateToStoreVisit");
                    navigateEvent.setParams({"storeId" : store.Id,
                                             "bodyToRender" : "storevisit",
                                             "storeVisitCategory" : categories}).fire(); 
                    var navigateEvent = $A.get("e.c:IndirectNavigateToStoreVisit");
                    navigateEvent.setParams({"storeId" : store.Id,
                                             "bodyToRender" : "storevisit",
                                             "storeVisitCategory" : categories}).fire(); 
                } else if (state2 === "ERROR") {
                    var errors = a.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action1); 
        }
    },
    
    goToNotes  : function(component) {
        if(component.get("v.bodyToRender") != "addnotes"){
            var categories = component.get("v.storeVisitCategory");
            var navigateEvent = $A.get("e.c:IndirectAddNoteEvent");
            navigateEvent.setParams({"storeId" : component.get("v.store.Id"),
                                     "bodyToRender" : "addnotes",
                                     "storeVisitCategory" : categories}).fire();
        }
    },
    
    goToOverview : function(component) {
        if(component.get("v.bodyToRender") != "storedetail"){
            var appEvt = $A.get("e.c:IndirectNavigateToStoreDetails");
            appEvt.setParams({"storeId" : component.get("v.store.Id"),
                              "bodyToRender" : "storedetail"}).fire();
        }
    },
    goToNextStep : function(component){
        if(component.get("v.bodyToRender") != "nextsteps"){
            var categories = component.get("v.storeVisitCategory");
            var action = component.get("c.getRecommendedCategories");
            console.log('Inside footer goToNextStep '+categories);
            action.setParams({
                "storeId" : component.get("v.store.Id"),
                "categories":categories,
                "loggedInUserId":component.get("v.loggedInUser.Id")           
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var recommendedCategory=response.getReturnValue();
                    
                    var appEvt = $A.get("e.c:IndirectNavigateToNextSteps");
                    appEvt.setParams({"storeId" : component.get("v.store.Id"),
                                      "bodyToRender" : "nextsteps",
                                      "storeVisitCategory": component.get("v.storeVisitCategory"),
                                      "recommendedCategory":recommendedCategory}).fire();
                }        
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
        }  
    }
})