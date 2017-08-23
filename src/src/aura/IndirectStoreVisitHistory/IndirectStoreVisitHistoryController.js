({
    doInit : function(component, event, helper) {
        var store = component.get("v.store");
        var action = component.get("c.getStoreVisits");
        action.setParams({"store" : component.get("v.store"),
                          "role" : component.get("v.role")});
        action.setCallback(this, function(a){
            component.set("v.storeVisitWrapperList", a.getReturnValue());
        });        
        $A.enqueueAction(action);
        
        //if(component.get("v.allCategories") == null || component.get("v.allCategories") == '')
        //{
            var action = component.get("c.queryActivityCategoriesForHistory");
            action.setParams({
                "storeType" : component.get("v.store.Store_Type__c"),
                "userRoleName" : component.get("v.role.DeveloperName")
            });
            action.setCallback(this, function(a){ 
                component.set("v.allCategories", a.getReturnValue());
            });            
            $A.enqueueAction(action);
       // }
        
        
    },
    
    showVisitDetails: function(component, event, helper) {
        
        var visits = component.get("v.storeVisitWrapperList");
        var selectedItem = event.currentTarget; // Get the target object
        var storevisit = selectedItem.dataset.record; // Get the store visit Id
        //var selectedVisit = component.get("v.storeVisitWrapperList")[storeVisit];
        var i;
        for(i= 0; i<visits.length; i++){
            if(visits[i].stv.Id == storevisit && visits[i].onRepeat == false)
            {
                
                visits[i].check = true;
                visits[i].onRepeat = true;
                
            }
            else
            {
                visits[i].check = false;
                visits[i].onRepeat = false;
                visits[i].checkActivity = false;
                visits[i].onRepeatActivity = false;
                //component.set("v.outer",false);
                
            }
        }
        component.set("v.storeVisitWrapperList", visits);
    },
    
    showCategoryDetails : function(component, event, helper) {
        var visits = component.get("v.storeVisitWrapperList"); 
        var selectedItem = event.currentTarget; // Get the target object
        var storevisit = selectedItem.dataset.record; // Get the store Id
        
        var i;
        for(i= 0; i<visits.length; i++){
            if(visits[i].stv.Id == storevisit && visits[i].onRepeatActivity == false)
            {       
                visits[i].checkActivity = true;
                visits[i].onRepeatActivity = true;
                
            }
            else
            {
                visits[i].checkActivity = false;
                visits[i].onRepeatActivity = false;
                
            }
        }
        
        
        component.set("v.storeVisitWrapperList", visits); 
        var action = component.get("c.getStoreVisitWrapper");
        action.setParams({
            categories: component.get("v.allCategories"),
            storeVisitId: storevisit
        });
        action.setCallback(this, function(a){
            console.log('in callback');
            component.set("v.listOfStoreVisitWrapper", a.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    hideCategoryDetails : function(component, event, helper) {
        var visits = component.get("v.storeVisitWrapperList"); 
        var selectedItem = event.currentTarget; // Get the target object
        var storevisit = selectedItem.dataset.record; // Get the store Id
        
        var i;
        for(i= 0; i<visits.length; i++){
            if(visits[i].stv.Id == storevisit)
            {       
                visits[i].checkActivity = false;
            }
            else
            {
                visits[i].checkActivity = true;
            }
        }
        component.set("v.storeVisitWrapperList", visits);
        for(i= 0; i<visits.length; i++){
            if(visits[i].stv.Id == storevisit)
            {       
                console.log('wrapper'+visits[i].checkActivity);
            }
        }
    },
    
    getInput : function(component,event,helper)
    {    
        var selectedItem = event.currentTarget; // Get the target object
        var storevisitCategoryId = selectedItem.dataset.record; // Get the store category Id
        var wrapper = component.get("v.listOfStoreVisitWrapper");
        var i;
        for(i= 0; i<wrapper.length; i++){
            if(wrapper[i].stc.Record_Type_Id__c == storevisitCategoryId )
            {       
                
                if(wrapper[i].sta == undefined)
                {
                    helper.showToast(component);
                }
                else
                {
                    wrapper[i].check = true;
                    var stc = wrapper[i].stc;                
                    var lookupField = stc.Lookup_field_value__c;
                    component.set("v.LookupFieldValue",null); 
                    if(lookupField !== undefined){ 
                        console.log('inside if*** getinput method');
                        var lookupFieldList = new Array();
                        if(lookupField.includes(";")){
                            lookupFieldList = lookupField.split(";");
                        }else{
                            lookupFieldList.push(lookupField);
                        }             
                        component.set("v.LookupFieldValue",lookupFieldList);            
                    }
                }
                
            }
            else
            {
                wrapper[i].check = false;
            }
        }
        component.set("v.isVisible",true);
        component.set("v.listOfStoreVisitWrapper", wrapper); 
    },
    
    toggleup: function(component){
        var selectedItem = event.currentTarget; // Get the target object
        var storevisitCategoryId = selectedItem.dataset.record; // Get the store category Id
        var wrapper = component.get("v.listOfStoreVisitWrapper");
        var i;
        for(i= 0; i<wrapper.length; i++){
            if(wrapper[i].stc.Record_Type_Id__c == storevisitCategoryId )
            {       
                wrapper[i].check = false;
            }
        }
        component.set("v.listOfStoreVisitWrapper", wrapper);  
    },    
    
    getTypeOfContact: function(component){
        console.log('in get Type of contact');
        var selectedItem = event.currentTarget; // Get the target object
        var storeActivityId = selectedItem.dataset.record; // Get the store activity
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Activity_Contacts__r", 
            "parentRecordId": storeActivityId
        });
        relatedListEvent.fire();
    }
    
    
})