({	
    /****************
	* @Description: doInit method to set template for 1-1 coaching
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/ 
    doInit: function(component, event, helper) {
        helper.getRecordTemplate(component);        
    },

	/****************
	* @Description: gettingAllCoachingRecords method to set attribute that are 
    				passing through OneOneCoachingDetailsEvent
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/    
    gettingAllCoachingRecords : function(component, event, helper) {
		component.set("v.oneOneCoachingRecords",event.getParam("oneOneCoachingRecords"));
        component.set("v.userDetails",event.getParam("userDetails"));
        component.set("v.workCoachingId",event.getParam("coachingId"));
        component.set("v.isRep",event.getParam("isRep"));
	},

	/****************
	* @Description: saveOneOneCoaching method save one one coaching
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/    
	saveOneOneCoaching : function(component, event, helper) {    
    	helper.saveOneOneCoaching(component, event, helper); 
	},

	/****************
	* @Description: cancel method cancel one one coaching creation
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/    
    cancel : function(component, event, helper) {		
        helper.cancel(component, event, helper);
	}
    
})