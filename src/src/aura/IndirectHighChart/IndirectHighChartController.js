({
    afterScriptsLoaded: function(component, event, helper) {      
        var storeId = component.get("v.store.Id");       
        var action = component.get("c.getPastSevenDaysChart");
        action.setParams({
            "storeId" : storeId            
        });
        action.setCallback(this, function(a){
             component.set("v.PastSevenDaysChart", a.getReturnValue());           
             	helper.getChartData(component);
        });
        $A.enqueueAction(action); 
    }    
})