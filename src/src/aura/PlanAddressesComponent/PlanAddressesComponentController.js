({
	doInit : function(component, event, helper) {
		//console.log('recordid'+ component.get("v.pageRecordId"));
		
        helper.getAddresses(component, event, helper);
	}
})