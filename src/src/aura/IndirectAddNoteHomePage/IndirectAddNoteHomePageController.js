({
	showDetails : function(component, event, helper) {
		
        var storedetails = component.get("v.store");
            //  alert('storedetails>>>' +storedetails.Id);
        var eventVar = $A.getEvt("c:IndirectAddNoteEvent");
        eventVar.setParams({"acc" : storedetails});
            // alert('eventVar>>>' + eventVar);
       eventVar.fire();
        
	}
})