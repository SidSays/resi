({
    doInit : function(component, event, helper) {  
        if(component.get("v.contactsList") == ''){
            var action2 = component.get("c.getContacts");
            action2.setParams({
                "storeId":component.get("v.store.Id")
            });
            
            action2.setCallback(this, function(a){
                component.set("v.contactsList", a.getReturnValue());
                
            });
            $A.enqueueAction(action2);
        }
        
        if(component.get("v.StoreVisitObj") == null){
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
            
    sendEmailToExtRec : function(component, event, helper){
        var contactsWrapperList = component.get("v.contactsList");
        var loggedInUser=component.get("v.loggedInUser");
        var storeVisitCategory = component.get("v.storeVisitCategory");
        var store =component.get("v.store");
        var StoreVisitObj =component.get("v.StoreVisitObj");
        var checkedContactList = new Array();
        
        for(i=0 ; i<contactsWrapperList.length; i++)
        { 
            if( contactsWrapperList[i].checked)
            {
                checkedContactList.push(contactsWrapperList[i].contactObj);                
            }
        }   
        
        if(checkedContactList.length > 0){  
            var action = component.get("c.getContactsWrap");
            action.setParams({
                "checkedContactList" : checkedContactList,
                "StoreVisit" : StoreVisitObj,
                "categories" : component.get("v.storeVisitCategory"),
                "storeDetail" : store
            });
            
            action.setCallback(this, function(a){ 
                component.set("v.contactsList", '');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Email has been sent successfully to selected contacts"
                });
                toastEvent.fire();
                
                var appEvent = $A.get("e.c:IndirectSendSummaryEvent");
                appEvent.setParams({ 
                    "storeVisitObj" : component.get("v.StoreVisitObj"),
                    "storeActivities" : component.get("v.storeActivities"),
                    "storeId" : component.get("v.store.Id"),
                    "bodyToRender" : "sendsummary",
                    "storeVisitCategory" : component.get("v.storeVisitCategory")
                });
                appEvent.fire();                        
                
            });
            $A.enqueueAction(action);
        }
        else{                  
           // alert('Please select at least one contact');
           // var title = "Please select at least one contact";
           // helper.showAlertBox(component, event, helper, title); 
           var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        "title": "Error!",
					        "message": "Please select at least one contact"
					    });
					    toastEvent.fire();
        }
        
        
    },
    cancel : function(component, event, helper){
        component.set("v.contactsList", '');
        var appEvent = $A.get("e.c:IndirectSendSummaryEvent");
        
        appEvent.setParams({ 
            "storeVisitObj" : component.get("v.StoreVisitObj"),
            "storeActivities" : component.get("v.storeActivities"),
            "storeId" : component.get("v.store.Id"),
            "bodyToRender" : "sendsummary"                   
        });
        appEvent.fire();
    } 
    })