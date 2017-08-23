({
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