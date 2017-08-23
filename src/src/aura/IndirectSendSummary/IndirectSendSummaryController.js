({
    doInit : function(component){
        if(component.get("v.StoreVisitObj") == null)
        {
            var action = component.get("c.queryActiveStoreVisit");
            action.setParams({
                storeId : component.get("v.store.Id"),
                loggedInUser: component.get("v.loggedInUser")
            });
            action.setCallback(this, function(a){
                component.set("v.StoreVisitObj", a.getReturnValue()); 
                if(component.get("v.storeActivities") == null || component.get("v.storeActivities") == '')
                {
                    var action = component.get("c.getCompletedActivities");
                    action.setParams({
                        storeVisitId : component.get("v.StoreVisitObj.Id")
                    });
                    action.setCallback(this, function(a){
                        component.set("v.storeActivities", a.getReturnValue());
                    });
                    $A.enqueueAction(action);
                }
            });
            $A.enqueueAction(action);
        } 
          
    },
    
    
    returnToOverview : function(component, event, helper) {   
        helper.sendToServer(component, event);        
    },
    
    returnToHomePage : function(component, event, helper) {   
        var navigateEvent = $A.get("e.c:IndirectNavigateToDashboard");
            navigateEvent.setParams({"bodyToRender" : "visits"}).fire();            
    },
    
    sendEmailToExtRecipient : function(component, event, helper) {
        
        var action = component.get("c.getContacts");
        action.setParams({
            "storeId":component.get("v.store.Id")
        });
        
        action.setCallback(this, function(a){ 
            component.set("v.contactsList", a.getReturnValue());
            
            var contactsWrapperList = component.get("v.contactsList");
            if(contactsWrapperList.length>0)
            {
            var appEvt = $A.get("e.c:IndirectNavigateToContactDetails");
            appEvt.setParams({"storeId" : component.get("v.store.Id"),                           
                              "bodyToRender" : "contactDetail",                        
                              "StoreVisitObj" : component.get("v.StoreVisitObj"),
                              "storeVisitCategory" : component.get("v.storeVisitCategory"),
                              "contactsList" : component.get("v.contactsList"),
                              "storeActivities" : component.get("v.storeActivities"),
                              }).fire(); 
            }
            else{
               // alert('No contact available on the Store');
               var title = "No contact available on the Store";
                 helper.showAlertBox(component, event, helper,title); 
            }
        });
        $A.enqueueAction(action);   
    }
})