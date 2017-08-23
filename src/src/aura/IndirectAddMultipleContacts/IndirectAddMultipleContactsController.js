({
    doInit : function(component, event, helper) {
         component.set("v.fromMultiContComp",true);
         setTimeout(function() { 
            var action2 = component.get("c.getContactsWithActivity");
            action2.setParams({
                "storeId" : component.get("v.storeId"),
                "activityId" : component.get("v.storeActivityId"),
                "lookupFieldValue" : component.get("v.LookupFieldValue")
            });
            
            action2.setCallback(this, function(a){
                component.set("v.contactsList", a.getReturnValue());
                
            });
            $A.enqueueAction(action2);
         }, 100);
    },
    
    addContactToActivity : function(component, event, helper){        
        var contactsWrapperList = component.get("v.contactsList");
        var checkedContactList = new Array();
        var uncheckedContactList = new Array();
        for(i=0 ; i<contactsWrapperList.length; i++)
        { 
            if( contactsWrapperList[i].checked)
            {
                checkedContactList.push(contactsWrapperList[i].contactObj);                
            }else{
                uncheckedContactList.push(contactsWrapperList[i].contactObj);
            }
        } 
        if(checkedContactList.length > 0){      
			var action = component.get("c.insertActivityContact");
			action.setParams({
				"checkedContactList" : checkedContactList,
				"uncheckedContactList" : uncheckedContactList,
				"activityId" : component.get("v.storeActivityId"),
				"lookupFieldValue" : component.get("v.LookupFieldValue")
			});
			
			action.setCallback(this, function(a){
				var navigateEvent = $A.get("e.c:IndirectNavigateToStoreVisit");
				navigateEvent.setParams({"storeId" : component.get("v.storeId"),
										 "bodyToRender" : "storevisit",
										 "StoreActivityCatagory" : component.get("v.StoreActivityCatagory"),
										 "storeVisitCategory" : component.get("v.storeVisitCategory"),
										 "storeActivityId" : component.get("v.storeActivityId"),
										 "LookupFieldValue" : component.get("v.LookupFieldValue"),
										 "fromMultiContComp" : component.get("v.fromMultiContComp")}).fire(); 
			});
			$A.enqueueAction(action);
        }else{
			//alert('Please select at least one contact');
			var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        "title": "Error!",
					        "message": "Please select at least one contact"
					    });
					    toastEvent.fire();
			// helper.showAlertBox(component, event, helper); 
		}
    },
    
    cancel : function(component, event, helper){
        var navigateEvent = $A.get("e.c:IndirectNavigateToStoreVisit");
        navigateEvent.setParams({"storeId" : component.get("v.storeId"),
                                 "bodyToRender" : "storevisit",
                                 "StoreActivityCatagory" : component.get("v.StoreActivityCatagory"),
                                 "storeVisitCategory" : component.get("v.storeVisitCategory"),
                                 "storeActivityId" : component.get("v.storeActivityId"),
                                 "LookupFieldValue" : component.get("v.LookupFieldValue"),
                                 "fromMultiContComp" : component.get("v.fromMultiContComp")}).fire(); 
    }
})