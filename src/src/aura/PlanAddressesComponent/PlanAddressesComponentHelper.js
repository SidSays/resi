({
	getAddresses : function(component, event, helper) {
        //console.log('in getAddresses');
		var action = component.get("c.getPlanAddresses");
        //console.log('action'+action);
        action.setParams({
			"planId" : component.get("v.pageRecordId")           					
		});
       action.setCallback(this, function(a) {
            console.log('addressesin callback'+ a.getReturnValue());
            //component.set("v.accounts", a.getReturnValue());
            var event1 = $A.get("e.c:PlanAddressesEvent");
            event1.setParams({"addresses": a.getReturnValue()});
            event1.fire();
        });
    $A.enqueueAction(action);
	}
})