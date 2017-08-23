({
    doInit : function(component, event, helper) {
       
        var a = component.get("v.dynamic");
        if(a == 'slds-hide')
        {
            component.set("v.title", 'Add Contact to Store');
        }
        else
        {
            component.set("v.title", 'Add Contact to Visit');
        }
        
        var action = component.get("c.getRecordType");
       action.setCallback(this, function(a){
            component.set("v.RecordTypeId", a.getReturnValue());
          
        });
        $A.enqueueAction(action);
        
        var dynamic = component.get("v.dynamic");
        var recordType = component.get("v.RecordTypeId");
        console.log('dynamic'+dynamic);
        if(dynamic != "slds-show")
        {           
            var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        	relatedListEvent.setParams({
            "relatedListId": "Contacts", 
            "parentRecordId": component.get("v.acnt.Id")
        	});
        relatedListEvent.fire();
        helper.defaultClose(component, event, helper);
        }
    },  
    
    defaultCloseAction : function(component, event, helper) {  
        helper.defaultClose(component,event, helper);
    },
    
	onconfirmDone : function(component, event, helper){
        var dynamic = component.get("v.dynamic");
        if(dynamic == "slds-show")
        	{
            helper.addContacts(component,event, helper);
        	} 
        helper.defaultClose(component,event, helper);
    },
        
    AddNewScreen: function(component, event, helper)
    { 
        var dynamic = component.get("v.dynamic");
        var recordType = component.get("v.RecordTypeId");
         if(dynamic == "slds-show")
            {        
            var relatedListEvent = $A.get("e.force:navigateToRelatedList");
                relatedListEvent.setParams({
                "relatedListId": "Contacts", 
                "parentRecordId": component.get("v.acnt.Id")
                });
            relatedListEvent.fire();    
            helper.addContacts(component,event, helper);
            } 
        
        
}   
  
})