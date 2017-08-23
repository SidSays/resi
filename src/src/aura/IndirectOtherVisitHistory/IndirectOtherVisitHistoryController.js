({
    doInit : function(component, event, helper) {
        
        var action = component.get("c.getVisitTypeValue");       
        action.setCallback(this, function(a){
            var opts= [];  var types = [];
            types = a.getReturnValue();
            for(var i =0; i< types.length; i++){
                if(types[i] == 'Event') 
                { opts.push({ class: "optionClass", label: types[i], value: types[i], selected: "true" });}
                
                else if(types[i] == 'Prospect')
                {
                    if(component.get("v.loggedInUser").Sales_Rep_Type__c == 'Dealer AE')
                        opts.push({ class: "optionClass", label: types[i], value: types[i] });
                }                
                else 
                {
                    opts.push({ class: "optionClass", label: types[i], value: types[i] }); 
                }  
            }
            
            component.find("visitList").set("v.options", opts);
            var selected = component.find("visitList").get("v.value");
            var action1 = component.get("c.getOtherVisitHistory");        
            action1.setParams({
                "selectedvisit" : selected,
                "loggedInUserId" : component.get("v.loggedInUser").Id
            });
            action1.setCallback(this, function(a){
                component.set("v.otherVisitWrapperList", a.getReturnValue());
            });
            $A.enqueueAction(action1);
        }); 
        $A.enqueueAction(action);
    },
    
    onSelectChange : function(component, event, helper) {
        var selected = component.find("visitList").get("v.value");
        var action = component.get("c.getOtherVisitHistory");        
        action.setParams({
            "selectedvisit" : selected,
            "loggedInUserId" : component.get("v.loggedInUser").Id
        });
        action.setCallback(this, function(a){
            component.set("v.otherVisitWrapperList", a.getReturnValue());
        });        
        $A.enqueueAction(action);
    },
    
    showOtherVisitDetails: function(component, event, helper) {
        
        var visits = component.get("v.otherVisitWrapperList");
        var selectedItem = event.currentTarget; 
        var storevisit = selectedItem.dataset.record;
        for(var i= 0; i<visits.length; i++){
            if(visits[i].stv.Id == storevisit && visits[i].check != true)
            {
                visits[i].check = true;
            }
            else
            {
                visits[i].check = false;
            }
        }
        component.set("v.otherVisitWrapperList", visits);
    }
})