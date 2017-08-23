({
    
    
    defaultCloseAction : function(component, event, helper) {  
        helper.defaultClose(component, event, helper);
    },
    
    onconfirm : function(component, event, helper) { 
        console.log('showSummaryonEndVisit'+ component.get("v.showSummaryonEndVisit"));
        if(component.get("v.showSummaryonEndVisit") == true){
          var appEvent = $A.get("e.c:IndirectShowSummaryonEndVisitEvent");
            appEvent.setParams({                
                "showSummaryonEndVisit" : true              
            });
            appEvent.fire();
            helper.defaultClose(component, event, helper);  
        }
		
        if(component.get("v.endPreviousStore") == true){
            var appEvent = $A.get("e.c:IndirectShowAlertEvent");
            appEvent.setParams({                
                "endPreviousStore" : true              
            });
            appEvent.fire();
            helper.defaultClose(component, event, helper);
        }
        
        if(component.get("v.checkErrorsOnEventEndVisit")){
            
            var appEvent = $A.get("e.c:checkErrorsOnEventEndVisitEvent");
            appEvent.setParams({                
                "checkErrorsOnEventEndVisit" : true  
                
            });
            appEvent.fire();   
            helper.defaultClose(component, event, helper);
        }
        if(component.get("v.checkErrorsOnEndVisit")){
            
            var appEvent = $A.get("e.c:checkErrorsOnEndVisitEvent");
            appEvent.setParams({                
                "checkErrorsOnEndVisit" : true                
            });
            appEvent.fire();   
            helper.defaultClose(component, event, helper);
        } 
        if(component.get("v.selectedEvent")) {
            
            var appEvent = $A.get("e.c:IndirectDashboardAlertEvent");
            appEvent.setParams({                
                "selectedEvent" : component.get("v.selectedEvent")              
            });
            appEvent.fire();
            helper.defaultClose(component, event, helper);
        }
        else{
            var appEvent = $A.get("e.c:IndirectShowAlertEvent");
            appEvent.setParams({                
                "endVisit" : true              
            });
            appEvent.fire();
            helper.defaultClose(component, event, helper);
        }
    },    
    
    onOk : function(component, event, helper) { 
        //if(component.get("v.alreadyEndedVisit") == true){
        if(component.get("v.showSummary") == true){
          var appEvent = $A.get("e.c:IndirectShowSummaryEvent");
            appEvent.setParams({                
                "showSummary" : true              
            });
            appEvent.fire();
            helper.defaultClose(component, event, helper);  
        }
        else{
             helper.defaultClose(component, event, helper);  
        }
         /*   var appEvent = $A.get("e.c:IndirectShowAlertEventForOK");
            appEvent.setParams({                
                "okclose" : true  
            });
            appEvent.fire();
            helper.defaultClose(component, event, helper);      */ 
        //}
    },
})