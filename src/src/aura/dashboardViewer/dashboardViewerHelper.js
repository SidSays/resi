({
    //This method is created to show only the appropriate value from the v.body 
    //with the help of $A.util.removeClass(cmp, "hide"); and  $A.util.addClass(cmp, "hide"); 
    setVisibility: function(component) {
        var dashboardId = component.get("v.dashboardId");
        var body = component.get("v.body");
        console.warn('body value 1 ',component.get("v.body"));
        var cmp = null;
        var localId = null;
        var found = false;
        for (var i = 0; i < body.length; i++) {
            cmp = body[i];
            localId = cmp.getLocalId();
            if (localId === dashboardId) {
                // Dashboard exists, so show it 
                $A.util.removeClass(cmp, "hide");               
                found = true;
            } else {            
                $A.util.addClass(cmp, "hide");                              
            }
        }
        console.warn('body value 2',component.get("v.body"));       
        return found;
    },
    
    //This method is used to show one dashboard by default.
    loadDashboards: function(component) {
        var preload = component.get("v.preload");
        if (preload == true) {
            var dashboardIds = component.get("v.dashboardIds");            
            var dashboardId = null;
            
            var config = null;
            var self = this;
            
            for (var i = 0; i < dashboardIds.length; i++) {	
                dashboardId = dashboardIds[i];               
                if (component.get("v.dashboardId") == undefined) {
                    component.set("v.dashboardId", dashboardId);                                            
                }
            }
        }
        
    },
    
    //This method is used to dynamically create component of wave:dashboard and 
    //add that component to v.body attribute.
    showDashboard: function(component, event) {
        var dashboardId = component.get("v.dashboardId");        
        if (!dashboardId) {
            return;
        }        
        var self = this;        
        var found = self.setVisibility(component);
        if (found) {
            return;
        }
        
        //To set the config propertied of dashboard
        var config = {
            "aura:id": dashboardId,
            height: component.get("v.height")
        };
        if (dashboardId) {
            config.dashboardId = dashboardId;
        } else if (developerName) {
            config.developerName = developerName;
        }        
        if (config) {
            
            $A.createComponent("wave:waveDashboard", config, 
                               function(dashboard, status, err) {
                                   
                                   if (status === "SUCCESS") {
                                       
                                       //console.warn("created dashboard: ", dashboard, dashboard.getLocalId());
                                       
                                       var body = component.get("v.body");                                       
                                       body.push(dashboard);
                                       component.set("v.body", body);
                                       
                                       self.setVisibility(component);
                                       
                                   }
                                   else if (status === "INCOMPLETE") {
                                       console.warn("No response from server or client is offline.")
                                   } else if (status === "ERROR") {
                                       console.warn("Error: " + errorMessage);
                                   }
                               }
                              );
        }
    }
})