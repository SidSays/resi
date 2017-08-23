({   
    save : function(component, event, helper){ 	
    if(component.get("v.LookupFieldValue") != null){
        var action = component.get("c.DoActivityContactsExist");
        action.setParams({
            "activityId" : component.get("v.storeActivity.Id"),
            "lookUpFieldValue" : component.get("v.LookupFieldValue")
        });
        
        action.setCallback(this, function(a){
            var message = component.find("messagebox");
            var outputText = message.get("v.body")[0]; 
            if(a.getState() === 'SUCCESS'){				                
                if(a.getReturnValue()){
                    message.set("v.class","slds-hide");
                    //changed the variable name as editMarkup as part of US1146600
                    var editMarkup = component.find("edit");
                    if(editMarkup.length >= 2){
                        editMarkup[editMarkup.length-1].get("e.recordSave").fire();
                    }
                    else{ 
                        editMarkup.get("e.recordSave").fire();
                    }
                    //changes end
                } else{
                    message.set("v.class","slds-show");
                    outputText.set("v.value","This field is required");
                }  
               
            } else{
                message.set("v.class","slds-show");
                outputText.set("v.value","Internal server error");
            }  
        });
        $A.enqueueAction(action);
    }else{
        var a = component.find("edit");   
        if(a.length >= 2){
            a[a.length-1].get("e.recordSave").fire();
        }
        else{ 
            a.get("e.recordSave").fire();
        }        
    }        
    },
    
    handleSaveSuccess : function(component, event, helper){ 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The activity has been saved successfully."
        });
        toastEvent.fire();
        var latestRecordId = component.get("c.getLatestStoreActivity");
        latestRecordId.setParams({
            "loggedInUser" : component.get("v.loggedInUser.Id"),
            "store" : component.get("v.storeTest.Id")
        });
        
        latestRecordId.setCallback(this, function(a){            
            component.set("v.storeActivity", a.getReturnValue());           
            var appEvent = $A.get("e.c:IndirectAddButtonEvent");
            appEvent.setParams({
                "storeActivities" : component.get("v.storeActivity"),
                "edit" : false,
                "readOnly" : true
            });
            appEvent.fire();
        });
        $A.enqueueAction(latestRecordId);
    },
    
    contactsSelection : function(component, event, helper){         
        var selectedItem = event.currentTarget; 
        var currentLookupFieldValue = selectedItem.dataset.record; // Get the LookupField Value        
        var appEvent = $A.get("e.c:IndirectContactSelectionForActivityEvent");
        appEvent.setParams({
            "storeId" : component.get("v.storeTest.Id"),                
            "bodyToRender" : "addContactsToActivity" ,
            "storeActivityId" : component.get("v.storeActivity.Id"),
            "StoreActivityCatagory" : component.get("v.StoreActivityCatagory"),
            "storeVisitCategory" : component.get("v.storeVisitCategory"),
            "LookupFieldValue" : currentLookupFieldValue
        });
        appEvent.fire();
    }
})