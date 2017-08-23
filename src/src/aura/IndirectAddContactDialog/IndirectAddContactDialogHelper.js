({
helperMethod : function() {

},
    
     defaultClose : function(component, event, helper) {  
        component.destroy();
    },
    
    addContacts : function(component, event, helper){
     var updates = component.get("v.contactsList");
       var ids = new Array();
        var falseIds = new Array();
        for(i=0 ; i<updates.length; i++)
        {
            
            if( updates[i].checked)
            {
                ids.push(updates[i].contactObj);                
            }
            else
            {
                falseIds.push(updates[i].contactObj);   
            }
        }
        if(ids.length > 0)
        {
        var storeId = component.get("v.acnt.Id");
            var storeVisitId = component.get("v.storeVisit.Id");
            
            var action = component.get("c.saveContacts");
            action.setParams({
            "ListOfContact":ids,            
            "storeVisit" : storeVisitId
        });
            
    $A.enqueueAction(action); 
        }
        
        if(falseIds.length > 0)
        {
        var storeId = component.get("v.acnt.Id");
            var storeVisitId = component.get("v.storeVisit.Id");
            
            var action = component.get("c.deleteContacts");
            action.setParams({
            "ListOfContact":falseIds,           
            "storeVisit" : storeVisitId
        });
            
    $A.enqueueAction(action); 
        }  
        var action1 = component.get("c.AddContacttoVisitContact");
            action1.setParams({
                "store" : component.get("v.store"),
                "storeVisit" : component.get("v.storeVisit")
            });
            $A.enqueueAction(action1);
        this.defaultClose(component, event, helper);
},
    
    
})