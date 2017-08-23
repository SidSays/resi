({
    doInit : function(component) {
        var action = component.get("c.getCoachingCustomMetaData");
		
        action.setCallback(this, function(response) {   
            var result = response.getReturnValue();
            if(result != null){
                for(var i = 0 ; i<result.length;i++){
                    if(result[i].DeveloperName === "Key_KPI_s"){//Key_KPI_s  Landing_Page
                        var dashboardIdVal = result[i].Value__c;
                        
                        $A.createComponent("forceCommunity:waveDashboard", 
                                           {"dashboardId": dashboardIdVal, 
                                            "showSharing":"true",
                                            "height":"620",
                                            "openLinksInNewWindow":false}, function(dashboard) {
                   			var dashboardContainer = component.find("dashboardDiv");
                  			dashboardContainer.set("v.body", dashboard); 

                });
                    }
                }                
            }
        });                        
        $A.enqueueAction(action);
    },
    
    dashboardToggle : function(component, event, helper) {
        var toggleDashboard = component.find("dashboardDiv");
        var toggleCoach = component.find("coachDiv");
        var isOpen = $A.util.hasClass(toggleDashboard, "slds-large-size--9-of-12");
       
        if(isOpen){
            $A.util.removeClass(toggleDashboard, "slds-large-size--9-of-12");
            $A.util.removeClass(toggleDashboard, "slds-medium-size--8-of-12");
            $A.util.addClass(toggleDashboard, "slds-large-size--12-of-12 "); 
            $A.util.addClass(toggleDashboard, "slds-medium-size--12-of-12"); 
            
            $A.util.removeClass(toggleCoach, "slds-large-size--3-of-12");
            $A.util.removeClass(toggleCoach, "slds-medium-size--4-of-12");
             
        }else{
            $A.util.removeClass(toggleDashboard, "slds-large-size--12-of-12");
            $A.util.removeClass(toggleDashboard, "slds-medium-size--12-of-12");
            $A.util.addClass(toggleDashboard, "slds-large-size--9-of-12");
            $A.util.addClass(toggleDashboard, "slds-medium-size--8-of-12");
            
            $A.util.addClass(toggleCoach, "slds-large-size--3-of-12");
            $A.util.addClass(toggleCoach, "slds-medium-size--4-of-12");
        }        
	}   
})