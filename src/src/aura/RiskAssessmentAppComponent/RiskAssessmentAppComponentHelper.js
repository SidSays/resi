({
	/**
     * @author Salesforce Program Archited
     * @date 20170821 
     * @description Initialize Component
     */
    doInit : function(component, event, helper) {
        // Given the design-time Channel selection, get the Dashboard Id
		var action = component.get("c.getDashboardId");
        action.setParams({
        	"channel": component.get("v.channel")
        });   
        action.setCallback(this, function(a) {
            // Get the Dashboard Id for the selected Channel
            var resp = a.getReturnValue();
            if(resp != null) {
            	$A.createComponent("wave:waveDashboard", 
                	{
                        "dashboardId":resp,
                        "showTitle":"false",
                        "showSharing":"true",
                        "height":"800",
						"openLinksInNewWindow":false
                    }, 
                    function(dashboard) {
                   		var dashboardContainer = component.find("dashboardDiv");
                  		dashboardContainer.set("v.body", dashboard); 
                    }
                )
            }
        });
        $A.enqueueAction(action);
    }
})