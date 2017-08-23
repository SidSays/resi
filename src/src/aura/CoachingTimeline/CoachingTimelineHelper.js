({
    /**
     *  @description Handles Wave Filter Event. This is a standard event from Wave Dashboards 
     * ("wave:selectionChanged").
    */
    
    handleSelectionChanges : function(component, event, helper) {
        component.set("v.showCoachingTimeline", false);
        component.set("v.showCoaching", false);
        component.set("v.selectedCoachings", null);
        component.set("v.showCoachingButton",false);
        var self = this;
        var isSalesRep = false;
        var numSalesReps = 0;
        var params = event.getParams();
        var dashboardId = params.id;
        var payload = params.payload;
        var displayCoachingSelections = false;
        var numMaxSalesReps= 1;  
        if(payload) {
            if (payload["step"] == "SALES_REP_FILTER") {
                isSalesRep = true;
                numSalesReps = payload.data.length;
            }  
        }
        
        if(isSalesRep){
            if(numSalesReps == 0) {
                displayCoachingSelections = false;
                helper.addMessage(component.get("v.errorMessages")[1], "infoSec");
            } else if(numSalesReps == numMaxSalesReps) {
                displayCoachingSelections = true;
            } else {
                displayCoachingSelections = false;
                helper.addMessage(component.get("v.errorMessages")[0], "errorSec");
            }
        }
        if(displayCoachingSelections == true){
            $("#messageSec").text('');
        	$("#messageSec").css("display", "none");
        	console.log("handleSelectionChanges fired in helper");
            var data = payload.data;            
            // Cycle through the data associated with the Wave filter event
            data.forEach(function(obj) {
                for(var k in obj) { 
                    // NAME_PERNR filter = Sales Rep Filter
                    if(k == "NAME_PERNR") {
                        //Call for sending the selected rep into multiple dashboards
                        //self.handleSalesRepNameChanged(component, obj[k], dashboardId);
                        var salesRepPERNR = obj[k];
                        var index = salesRepPERNR.lastIndexOf("[");
                        // Store Sales REp PERNR and Sales Rep Name separately
                        var PERNR = salesRepPERNR.slice(index + 1, salesRepPERNR.length-1);
                        var checkUserMethod = component.get("c.checkUserAndCoaching");
                        checkUserMethod.setParams({
                            "pernrID" : PERNR     
                        });
                        checkUserMethod.setCallback(this,function(userData){
                            console.log("Callback result: "+userData.getState());
                            
                            var result = userData.getReturnValue();
                            if(result.validUser == true){
                                var coachingRecId = result.coachingId;
                                if(coachingRecId){
                                    component.set("v.showCoachingTimeline", true);
                                    component.set("v.workCoachingId", coachingRecId);
                                    component.set("v.userDetails", result.userInfo);
                                    component.set("v.isRep", result.isRep);
                                    var oneOneCoachingRecords = result.oneOneCoachingList;                              
                                    if(oneOneCoachingRecords){
                                        component.set("v.selectedCoachings",oneOneCoachingRecords);
                                        component.set("v.showCoaching", true);                                                                                
                                    }else{    
                                        console.log("No one to one coaching");
                                        helper.addMessage(result.errorMsg, "errorSec");
                                    }
                                }else{
                                    console.log("No coaching");
                                    if(result.userInfo){
                                    	component.set("v.showCoachingButton",true);
                                    }
                                    helper.addMessage(result.errorMsg, "errorSec");
                                }
                            }else{
                                console.log("Invalid user");
                                helper.addMessage(result.errorMsg, "errorSec");
                            }
                            
                        });
                        $A.enqueueAction(checkUserMethod); 
                        
                    }
                }
            });
        }
    },
    addMessage : function(strMessage, strClass) {
        $("#messageSec").text(strMessage);
        if(strClass === "errorSec"){
            $("#messageSec").removeClass("infoSec");
        }else if(strClass === "infoSec"){
            $("#messageSec").removeClass("errorSec");
        }
        $("#messageSec").addClass(strClass);
        $("#messageSec").css("display", "block");
    },
    
    /****************
    * @Description: This helper method is for navigate to CoachingComponent to create 
    * 				one one coaching record                 
    * @Author: Amit Kumar Pradhan, Accenture    
    * @Date: 31-July-2017   
    * @User Story: US1141906   
    ****************/
    navigateToOneOneCoachingCmp : function(component, event, helper) {
        $A.get("e.c:CreateOneOneCoachingEvent").setParams({
            "showCreateOneOneCoaching" : "true",
            "showCoachingTimeline" : "false"
        }).fire();
        
        var coachingDetailsEvent = $A.get("e.c:OneOneCoachingDetailsEvent");
        coachingDetailsEvent.setParams({           
            "oneOneCoachingRecords" : component.get("v.selectedCoachings"),
            "userDetails" : component.get("v.userDetails"),
            "coachingId" : component.get("v.workCoachingId"),
            "isRep" : component.get("v.isRep")
        });
        coachingDetailsEvent.fire();
    },
    
})