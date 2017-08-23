({
    doInit : function(component, event, helper) {       
        var action = component.get("c.getErrorsFromCustomMetaData");                   
        action.setCallback(this, function(a) {
            component.set("v.errorMessages", a.getReturnValue());
            helper.addMessage("Filter the dashboard to one sales employee to enable 1:1 coaching.", "infoSec");
        });                        
        $A.enqueueAction(action);
        
    },
    
    // for Hide/Close Model,set the "isOpen" attribute to "False" 
	hideDetails: function(component, event, helper) {       
    	component.set("v.isOpen", false);
    },
    
    //Shows the selected Coaching records and returns the information
    showDetails: function(component,event,helper){
    	var coachingid = event.currentTarget.dataset.coachingid ;
        
        //event.getSource().getElement().getAttribute('data-kaid');
        var action = component.get("c.getCoachingDetails");
            
        action.setParams({
          "recordId": coachingid
        });
            
            /*Results displayed from the method execution*/ 
        action.setCallback(this, function(a) {
            
            //Variable of the view where we are setting the query results
            component.set("v.CoachInfo", a.getReturnValue());
            component.set("v.isOpen", true);
        });
            
            
        $A.enqueueAction(action);
        
  	},
    
    /**
     *  @description  Call Helper method to pass Wave Data based on User and Date
     */
	filterWaveData : function(component, event, helper) {
        
	},
	viewCoaching : function(component, event, helper){
        console.warn('in viewCoaching');

        component.set("v.showCoaching", true);
    },

    updateRecordView: function(component, event, helper) {
      
        var id = component.get("coaching.id");
        var container = component.find("container");
        $A.createComponent("force:recordView",
                           {recordId: id,type: "MINI"},
                           function(cmp) {
                               container.set("coaching.body", [cmp]);
                           });
        
    },
     
    /*
     * To Handle the wave selection change
     */
    
    handleSelectionChanges : function(component, event, helper){   
       helper.handleSelectionChanges(component, event, helper);
    },
    
    /****************
    * @Description: This method is calling navigateToOneOneCoachingCmp hepler method                 
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/
    navigateToOneOneCoachingCmp : function(component, event, helper) {
    	helper.navigateToOneOneCoachingCmp(component, event, helper);
    },
    
     /****************
    * @Description: gettingOldOneOneList method is to set attribute that are passing through 
     				OneOneCoachingDetailsEvent
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/
    gettingOldOneOneList : function(component, event, helper) {
        component.set("v.showCoaching", true);
        component.set("v.showCoachingTimeline", true);
		component.set("v.selectedCoachings",event.getParam("oneOneCoachingRecords"));
        component.set("v.userDetails",event.getParam("userDetails"));
        component.set("v.workCoachingId",event.getParam("coachingId"));
        component.set("v.isRep",event.getParam("isRep"));
    },
    
     //Shows the selected Coaching records and returns the information
    showDetails: function(component,event,helper){
    var coachingid = event.currentTarget.dataset.coachingid ;
        
        //event.getSource().getElement().getAttribute('data-kaid');
        var action = component.get("c.getCoachingDetails");
            
        action.setParams({
          "recordId": coachingid
        });
            
            /*Results displayed from the method execution*/ 
        action.setCallback(this, function(a) {
            
            //Variable of the view where we are setting the query results
            component.set("v.CoachInfo", a.getReturnValue());
            component.set("v.isOpen", true);
        });
            
            
        $A.enqueueAction(action);
        
  },
    
    populateDashboardIds : function(component, event, helper){
        console.warn('in method');
        helper.populateDashboardIds(component, event);
    },
    
    redirectToObservation : function(component, event, helper) {
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            //"url": "/apex/ObservationForm"
            "url": "https://onecomcast--devpro1--c.cs14.visual.force.com/apex/ObservationFormKP"
            });
        urlEvent.fire();*/
        
        var url = "https://onecomcast--devpro1--c.cs14.visual.force.com/apex/ObservationFormKP";
        window.location.assign(url);
    },
    
    openmodalP: function(component,event,helper) {
        var childCmp = component.find("ObservationFormComp");
        console.log('testing KP $$$: ' + childCmp);
 		childCmp.callOpenmodal();
    }
})