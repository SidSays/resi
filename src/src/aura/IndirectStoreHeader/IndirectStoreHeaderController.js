({
	/*goToMyStores : function(component) {
		var navigateEvent = $A.get("e.c:IndirectNavigateToMyStores");
        navigateEvent.setParams({"currentuser" : component.get("v.loggedInUser"),
                                 "hisstores":component.get("v.stores"),
                                 "hisvisits":component.get("v.storevisits")});
        navigateEvent.fire();
	},
    
    goToMyDashboard : function(component) {
		var navigateEvent = $A.get("e.c:IndirectNavigateToDashboard");
        navigateEvent.setParams({"currentuser" : component.get("v.loggedInUser"),
                                 "hisstores":component.get("v.stores"),
                                 "hisvisits":component.get("v.storevisits")});
        navigateEvent.fire();
	},
    scheduleEvent : function(Component){
                
    }*/
    /*doinit : function(component) {
        alert('1st');
        var action = component.get("c.runReport");
        alert('658365');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var reportData = JSON.parse(response.getReturnValue());
                var = returnData = [];
                for(i = 0, j = reportData.groupingsDown.groupings.length; i < j; i++) {
                    var label = reportData.groupingsDown.groupings[i].label;
                    var key = reportData.groupingsDown.groupings[i].key;
                    var value = reportData.factMap[key + '!T'].aggregates[0].value;
                    returnData.push(label, value);
                }
                var chart = c3.generate({
                    bindto: '#char',
                    data: {
                        columns: returnData,
                        type: 'pie'
                    }
                });
            }
        });
        $A.enqueAction(action);
    }*/
    
})