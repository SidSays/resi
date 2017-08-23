({
    /**
     *  @description Handles Wave Filter Event. This is a standard event from Wave Dashboards 
     * ("wave:selectionChanged").
    */
    
    handleSelectionChanges : function(component, event, helper) {
        component.set("v.showCoachingTimeline", false);
        component.set("v.showCoaching", false);
        component.set("v.selectedCoachings", null);
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
                helper.addInfoMessage("Filter the dashboard to one sales employee to enable 1:1 coaching.", "infoSec");
            } else if(numSalesReps == numMaxSalesReps) {
                displayCoachingSelections = true;
            } else {
                displayCoachingSelections = false;
                helper.addMessage(component.get("v.errorMessages"), "errorSec");
            }
        }
        if(displayCoachingSelections == true){
            $("#messageSec").text('');
        	$("#messageSec").css("display", "none");
        
            var data = payload.data;            
            // Cycle through the data associated with the Wave filter event
            data.forEach(function(obj) {
                for(var k in obj) { 
                    // NAME_PERNR filter = Sales Rep Filter
                    if(k == "NAME_PERNR") {
                        console.warn('in name pernr');
                        //Call for sending the selected rep into multiple dashboards
                        self.handleSalesRepNameChanged(component, obj[k], dashboardId);
                        console.warn('in name pernr 2');
                        var salesRepPERNR = obj[k];
                        var index = salesRepPERNR.lastIndexOf("[");
                        // Store Sales REp PERNR and Sales Rep Name separately
                        var PERNR = salesRepPERNR.slice(index + 1, salesRepPERNR.length-1);
                        var checkUserMethod = component.get("c.checkUserAndCoaching");
                        checkUserMethod.setParams({
                            "pernrID" : PERNR     
                        });
                        checkUserMethod.setCallback(this,function(userData){
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
                                        helper.addMessage(result.errorMsg, "errorSec");
                                    }
                                }else{
                                    component.set("v.showCoachingButton",true);
                                    helper.addMessage(result.errorMsg, "errorSec");
                                }
                            }else{
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
    
    /****************
    * @Description: Coach for Retail - Maintain selected user through dashboards
    * @Author: Radhika Bansal, Accenture    
    * @Date: 03-Aug-2017   
    * @User Story: US1161032   
    ****************/
    
    handleSalesRepNameChanged: function(component, values, sourceId) {
        console.warn("handleSalesRepNameChanged: ", values, sourceId);
        
        var fieldName = "NAME_PERNR";
        
        var self = this;
    
		var dashboardIds = component.get("v.dashboardIds");
        console.warn('dashboardIds',dashboardIds);
        var cmp = null;
        var localId = null;
    	var otherIds = [];       
        for (var i = 0; i < dashboardIds.length; i++) {
            cmp = dashboardIds[i];
            console.warn("cmp: ", cmp, cmp.getLocalId());
            localId = cmp.getLocalId();
             if (localId !== sourceId) {
				otherIds.push(localId);
			}
 		}
 
		console.warn("otherIds: ", otherIds);
    
		otherIds.forEach(function(id) {
            
            
			var datasetName = null;
            
			if (id === "0FK16000000L0FNGA0") {
                datasetName = "Xfinity_Stores_Team_Performance";
            } /*else if (id === "0FK0j0000004CP6GAM") {
                datasetName = "CK_CommissionsTier_Hierarchy";
            }*/

            var datasetDevName = datasetName; //ns + "__" + datasetName;        
            
            var selection = {
                datasets: {                    
                    [datasetDevName]: [                    
                        {
                            fields: [fieldName],
                            selection: values
                        }
                    ]                
                }            
            };
        
            console.warn("selection: ", selection);
    
            var json = JSON.stringify(selection);
        
        	console.warn("json: ", json);
        
            
			var evt = $A.get('e.wave:update');
            evt.setParams({
                value: json,
                id: id,
                type: "dashboard"
            });
            console.warn("firing event: ", evt, evt.getParams());
            evt.fire();
        });
    },
 
 	populateDashboardIds : function(component, event){
    	component.set("v.dashboardIds", event.getParams().dashboardIds);
	}
       
})