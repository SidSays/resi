({
	 goToStoreDetail : function(component, event, helper) {
        var cmpEvt = component.getEvent("onClick");
        cmpEvt.setParams({"store" : compoenent.get("v.store")}).fire();
	}
})