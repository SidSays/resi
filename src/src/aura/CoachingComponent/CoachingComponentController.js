({
	/****************
	* @Description: navigateToCreateOneOneCoaching method to set attribute that are 
    				passing through CreateOneOneCoachingEvent event
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/ 
    navigateToCreateOneOneCoaching : function(component, event, helper) {       
        component.set("v.showCreateOneOneCoaching",event.getParam("showCreateOneOneCoaching"));
        component.set("v.showCoachingTimeline",event.getParam("showCoachingTimeline"));
	}
    
})