({
	 getNotes : function(component, event, helper) {  
        var storeId = component.get("v.store.Id");
        console.log(storeId);
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "AttachedContentNotes", 
            "parentRecordId": component.get("v.store.Id")
        });
        relatedListEvent.fire();
        }
})