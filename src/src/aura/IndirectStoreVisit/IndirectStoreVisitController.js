({
    doInit : function(component, event, helper) {        
        var a = component.get("v.store.Id");      
        helper.storeVisitDetails(component); 
        
    },
    
    endVisit : function(component, event, helper)
    { 
        var isTrue = false;
        var activitiesWrapper;
        var act = component.get("c.isAutoCompletedStoreVisit");
        act.setParams({
            "storeVisitId" : component.get("v.StoreVisitObj.Id")           					
        });
        act.setCallback(this, function(a){ 								   
            activitiesWrapper = a.getReturnValue();
            component.set("v.activitiesWrapper",activitiesWrapper);
            isTrue = activitiesWrapper.isAutoCheckOut;			
            if(isTrue){
                //alert("This visit has already ended.");
                var title = "This visit has already ended.";                
                var confirm = false;
                var showSummary = true;
                var showSummaryonEndVisit = false;
                helper.showAlertBox(component, event, helper, title, confirm, showSummary,showSummaryonEndVisit);                
                
            }else{			
                if (!navigator.geolocation){
                    //alert('Geolocation is not supported by your browser');
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Geolocation is not supported by your browser"
                    });
                    toastEvent.fire();
                }
                navigator.geolocation.getCurrentPosition(success, error);
                function success(position) {
                    component.set("v.lat",position.coords.latitude); 
                    component.set("v.longi",position.coords.longitude); 
                }
                function error() {
                    //alert('Unable to retrieve your location');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "Unable to retrieve your location"
                    });
                    toastEvent.fire();
                }
                var lat = component.get("v.lat");
                var longi = component.get("v.longi");  
                //var r =  confirm("Are you sure that you want to end this visit?");
                var title = "Are you sure that you want to end this visit?";
                var confirm = true;
                var showSummary = false; 
                var showSummaryonEndVisit = true;
                helper.showAlertBox(component, event, helper, title, confirm,showSummary,showSummaryonEndVisit);               
            }    
            
        });	
        $A.enqueueAction(act);   	
        
    },
    
    OkBox: function(component, event, helper){
      
        if(event.getParam("v.okclose")){
            var activitiesWrapper = component.get("v.activitiesWrapper");
            if(activitiesWrapper != null){
                var appEvent = $A.get("e.c:IndirectSendSummaryEvent");                    
                appEvent.setParams({ 
                    "storeVisitObj" : component.get("v.StoreVisitObj"),
                    "storeActivities" : activitiesWrapper.storeActivityList,
                    "storeId" : component.get("v.store.Id"),
                    "bodyToRender" : "sendsummary",
                    "storeVisitCategory" : component.get("v.storeVisitCategory")
                });
                appEvent.fire();
            }
        }
    },
        
	IndirectShowSummary : function(component, event, helper){
           var activitiesWrapper = component.get("v.activitiesWrapper");
            if(activitiesWrapper != null){
                var appEvent = $A.get("e.c:IndirectSendSummaryEvent");                    
                appEvent.setParams({ 
                    "storeVisitObj" : component.get("v.StoreVisitObj"),
                    "storeActivities" : activitiesWrapper.storeActivityList,
                    "storeId" : component.get("v.store.Id"),
                    "bodyToRender" : "sendsummary",
                    "storeVisitCategory" : component.get("v.storeVisitCategory")
                });
                appEvent.fire();
            }
    },
    
    IndirectShowSummaryonEndVisit : function(component, event, helper){
        if(event.getParam("showSummaryonEndVisit") == true){
        var lat = component.get("v.lat");
        var longi = component.get("v.longi"); 
        
        var storeVisit = component.get("v.StoreVisitObj");  
        var userDetail = component.get("v.loggedInUser");
        var storeDetail = component.get("v.store");
        var storeActivityDetail = component.get("v.storeActivity");
        var storeAddress=storeDetail.BillingStreet +','+storeDetail.BillingCity +','
        +storeDetail.BillingState +','+storeDetail.BillingPostalCode +','+storeDetail.BillingCountry;
        
        var action = component.get("c.stopVisitAndGetInCompletedActivities");
        action.setParams({
            "userDetail" : userDetail,           
            "storeId" : storeDetail.Id,
            "storeAddress" : storeAddress,
            "StoreVisit" : storeVisit,
            "lat" : lat,
            "longi" : longi,
            "categories" : component.get("v.storeVisitCategory"),
            "storeDetail":storeDetail
            
        });
        
        
        action.setCallback(this, function(a){ 
            
            var storeVisitWrapper = a.getReturnValue();
            var storeActivities = storeVisitWrapper.StoreActivityList;
            component.set("v.StoreVisitObj", storeVisitWrapper.StoreVisit); 
            var appEvent = $A.get("e.c:IndirectSendSummaryEvent");
            
            appEvent.setParams({ 
                "storeVisitObj" : component.get("v.StoreVisitObj"),
                "storeActivities" : storeActivities,
                "storeId" : component.get("v.store.Id"),
                "bodyToRender" : "sendsummary",
                "storeVisitCategory" : component.get("v.storeVisitCategory")
            });
            appEvent.fire();
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Mail has been sent Successfully "
            });
            toastEvent.fire();
            
        });
        $A.enqueueAction(action);   
        }
        
    },
    
    getInput : function(component, event, helper)
    {    
        var selectedItem = event.currentTarget; // Get the target object
        var storevisitCategoryId = selectedItem.dataset.record; // Get the store Id  
        
        var storeVisit = component.get("v.StoreVisitObj"); 
        var storeAct = component.get("c.createStoreActivity");
        storeAct.setParams({
            "storevisitCategoryRecordTypeId" : storevisitCategoryId,
            "storeVisit" : storeVisit
        });
        storeAct.setCallback(this, function(a){
            if(a.getReturnValue() == null){
                // alert("This visit has already ended.");
                var title = "This visit has already ended.";
                var confirm = false;
                var showSummary = false;                
                var showSummaryonEndVisit = false;
                helper.showAlertBox(component, event, helper,title,confirm, showSummary,showSummaryonEndVisit); 
            }
            else
            {
                component.set("v.storeActivity", a.getReturnValue());
                var wrapper = component.get("v.StoreVisitWrapper2");
                
                var i;
                for(i= 0; i<wrapper.length; i++){
                    if(wrapper[i].stc.Record_Type_Id__c == storevisitCategoryId && wrapper[i].stc != undefined)
                    {       
                        wrapper[i].check = true;
                        component.set("v.LookupFieldValue",null);
                        var stc = wrapper[i].stc;                
                        var lookupField = stc.Lookup_field_value__c;
                        if(lookupField !== undefined){ 
                            var lookupFieldList = new Array();
                            if(lookupField.includes(";")){
                                lookupFieldList = lookupField.split(";");
                            }else{
                                lookupFieldList.push(lookupField);
                            }             
                            component.set("v.LookupFieldValue",lookupFieldList);            
                        }
                    }
                    else
                    {
                        wrapper[i].check = false;
                    }
                }
                component.set("v.edit", true);
                component.set("v.readOnly", false);
                component.set("v.StoreVisitWrapper2", wrapper);    
            }
        });
        $A.enqueueAction(storeAct);
        
        
    },
    
    toggleup: function(component){
        var selectedItem = event.currentTarget; // Get the target object
        var storevisitCategoryId = selectedItem.dataset.record; // Get the store Id
        
        var wrapper = component.get("v.StoreVisitWrapper2");
        var i;
        for(i= 0; i<wrapper.length; i++){
            if(wrapper[i].stc.Record_Type_Id__c == storevisitCategoryId )
            {       
                wrapper[i].check = false;
                component.set("v.LookupFieldValue",null);
                component.set("v.LookupField",null);
                
            }
            
        }
        component.set("v.storeActivity", null);
        component.set("v.edit", false);
        component.set("v.readOnly", true);
        component.set("v.StoreVisitWrapper2", wrapper);  
    },    
    
    SaveNotes : function(component, event, helper){       
        var storeVisit = component.get("v.StoreVisitObj");         
        var Notes = component.find("notesId").get("v.value");        
        var action = component.get("c.updateStoreVisit");
        action.setParams({
            "storeVisit" : storeVisit,
            "Notes" : Notes
        });
        action.setCallback(this, function(a){
           
            if(a.getReturnValue() == null){
                //alert("This visit has already ended.");
                var title = "This visit has already ended.";
                var confirm = false;
                var showSummary = false;
                var showSummaryonEndVisit = false;
                helper.showAlertBox(component, event, helper,title, confirm,showSummary,showSummaryonEndVisit); 
            }
            else{
                component.set("v.StoreVisitObj", a.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The notes has been added successfully."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action); 
        
    },
    
    
    addContact: function(component){
        var acntId = component.get("v.store.Id");
        var storeVisitId = component.get("v.StoreVisitObj.Id");
        var action = component.get("c.displayContacts");
        action.setParams({
            "storeId" : acntId,
            "storeVisitId" : storeVisitId
        });
        action.setCallback(this, function(a){
            $A.createComponent(
                "c:IndirectAddContactDialog",
                {
                    "contactsList": a.getReturnValue(),                
                    "acnt": component.get("v.store"),                
                    "storeVisit": component.get("v.StoreVisitObj"),
                    "dynamic": "slds-show"
                },
                function(msgBox){                
                    if (component.isValid()) {
                        var targetCmp = component.find('ModalDialogPlaceholder');
                        var body = targetCmp.get("v.body");
                        body.push(msgBox);
                        targetCmp.set("v.body", body); 
                    }
                }
            );
        });
        $A.enqueueAction(action);       
    },
    
    handleApplicationEvent : function(cmp, event) {
        var storeActivity = event.getParam("storeActivities");       
        cmp.set("v.storeActivity", storeActivity);        
        cmp.set("v.edit", event.getParam("edit"));        
        cmp.set("v.readOnly", event.getParam("readOnly"));        
    },
    
    save : function(component, event, helper) {       
        helper.save(component,event,helper);
    }
})