({
    doInit : function(component){
      /*  var action = component.get("c.addButtonWrapper");
        action.setParams({
            "storeCategories" : component.get("v.storeVisitCategories")
        });
        action.setCallback(this, function(a){
            component.set("v.iterationList", a.getReturnValue());
        });
                           
                           $A.enqueueAction(action);*/
    },
    
    getInput : function(component)
    {    
        /*var categories = component.get("v.iterationList");*/
        var selectedItem = event.currentTarget; // Get the target object
        var storevisitCategoryRecordTypeId = selectedItem.dataset.record; // Get the storecategory Id
        console.log('storevisitCategoryRecordTypeId'+storevisitCategoryRecordTypeId);
       /* var i;
        for(i= 0; i<categories.length; i++){
            if(categories[i].stc == storevisitCategoryId && categories[i].onRepeat == false)
            {
                categories[i].check = true; 
                categories[i].onRepeat = true;
            }
            else
            {
                categories[i].check = false;
                categories[i].onRepeat = false;
            }
        }
        component.set("v.iterationList", visits);*/
        
        component.set("v.buttonClassdown" , "slds-hide");
        component.set("v.buttonClassup" , "slds-show");
        var storeVisit = component.get("v.StoreVisitObj");  
        
        var storeAct = component.get("c.createStoreActivity");
        storeAct.setParams({
            "storevisitCategoryRecordTypeId" : storevisitCategoryRecordTypeId,
            "storeVisit" : storeVisit
        });
        storeAct.setCallback(this, function(a){
            component.set("v.storeActivity", a.getReturnValue());
            console.log('store Activity in getInput' + component.get('v.storeActivity'));
            var appEvent = $A.get("e.c:IndirectAddButtonEvent");
            appEvent.setParams({
                "storeActivities" : component.get('v.storeActivity'),
                "edit" : true,
                "readOnly" : false
            });
            appEvent.fire();
        });
        $A.enqueueAction(storeAct);
    },
    
    ToggleUp: function(component){
        var storeActivity = component.get("v.storeActivity");
        component.set("v.buttonClassdown" , "slds-show");
        component.set("v.buttonClassup" , "slds-hide");
        var appEvent = $A.get("e.c:IndirectAddButtonEvent");
        appEvent.setParams({
            "storeActivities" : null,
            "edit" : false,
            "readOnly" : true
        });
        
        appEvent.fire();
    }
})