({
    scheduleEvent : function(component, event, helper) {
        var whatId=component.get("v.store.Id") || null;        
        var assignedTo=component.get("v.loggedInUser.Name");        
        var relatedTo=component.get("v.store.Name");
        var title=(relatedTo==null) ? "Schedule Event" : "Schedule Visit" ; 
        
        $A.createComponent(
            "c:IndirectScheduleVisit",{
                "relatedTo" : relatedTo ,
                "assignedTo" : assignedTo ,
                "whatId" : whatId ,
                "title" : title 
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
    
    addContactToStore : function(component, event, helper) {
        var acntId = component.get("v.store.Id");     
        var action = component.get("c.displayContacts");
        action.setParams({
            "storeId" : acntId
        });
        action.setCallback(this, function(a){
            var relatedListEvent = $A.get("e.force:navigateToRelatedList");
            relatedListEvent.setParams({
                "relatedListId": "Contacts", 
                "parentRecordId": component.get("v.store.Id")
            });
            relatedListEvent.fire();
        });
        $A.enqueueAction(action); 
        
    }
})