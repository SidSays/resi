({
	raiseS1Event: function(component,event,helper,eventName,params) {
        var evt = $A.get(eventName);
        if (evt) {
            evt.setParams(params);
            evt.fire();
            
        } else {
            helper.alert(
                component,
                "Feature Only Available in Salesforce1",
                $A.get("$Label.c.FeatureNotAvailable")
            );
            
        }
        
    }				
})