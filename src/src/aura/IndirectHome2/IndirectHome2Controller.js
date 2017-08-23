({
    doInit : function(component, event, helper) {      
        var action = component.get("c.getAllUserData");
        action.setCallback(this, function(response){
            
            var userData = response.getReturnValue();
            
            if(userData.assignedStores != null){
                component.set("v.storeMap",userData.assignedStores);}
            component.set("v.storevisits",userData.scheduledEvents);
            component.set("v.upcomingEvents",userData.upcomingEvents);
            component.set("v.loggedInUser",userData.loggedInUser);  
            component.set("v.role",userData.userRole);
            //component.set("v.renderbody","visits");
            //helper.setHeaderAndFooter(component,"visits");
            
        });
        $A.enqueueAction(action);
        var action2 = component.get("c.getCachedData");        	
        action2.setCallback(this, function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                var cachedData = a.getReturnValue();
                var store = cachedData.storeId == null? null:component.get("v.storeMap")[cachedData.storeId];
                var storeName =store == null ? null: store.Name;                
                var storeActivityCatagory = (cachedData.storeActivityCatagory != null)? cachedData.storeActivityCatagory : null;
           		var storeActivityId = (cachedData.activityId != null)? cachedData.activityId : null;
                var LookupFieldValue = (cachedData.currentButtonValue != null)? cachedData.currentButtonValue : null;
                
                component.set("v.store",store);                
                component.set("v.storeVisitCategory",cachedData.categories);
                component.set("v.emailSummaryForOtherVisits",cachedData.emailSummary);                              
                component.set("v.renderbody",cachedData.bodyToRender);//Body
                component.set("v.StoreActivityCatagory",storeActivityCatagory);
            	component.set("v.storeActivityId",storeActivityId);
         		component.set("v.LookupFieldValue",LookupFieldValue); 
                
                helper.setHeaderAndFooter(component,cachedData.bodyToRender,storeName);
            }else{
                console.log('Platform cache error!');
                //component.set("v.renderbody","visits");//Body                
                //helper.setHeaderAndFooter(component,"visits");
            }
        }); 
        $A.enqueueAction(action2);
    },
    
    setValuesStoreRelatedData : function(component, event, helper){
        if(event !=null ){
			component.set("v.storeMap",event.getParam("storeMap"));
            helper.updateDataInPlatformCache(component, event.getParam("bodyToRender"), 
                                             event.getParam("storeId"),event.getParam("storeVisitCategory"));
        }
    },
    
    navigateToMyStore : function(component, event, helper) {        
        if(event !=null ){            
            helper.navigateToDashboardOrMyStores(component,event.getParam("bodyToRender"));
        }
    },
    
    navigateToDashboard : function(component, event, helper) {        
        if(event !=null ){            
            helper.navigateToDashboardOrMyStores(component,event.getParam("bodyToRender"));
        }
    },
    
    navigateToOtherVisits : function(component, event, helper) {        
        if(event !=null ){            
            helper.navigateToOtherVisits(component,event.getParam("bodyToRender"));
        }
    },
    
    navigateToStoreDetail : function(component, event, helper) {        
        if(event != null){
            helper.navigateToOtherPages(component,event.getParam("bodyToRender"),
                                        event.getParam("storeId"));              	
        }
    },
    
    navigateToVisitHistorySurvey : function(component, event, helper) {
        if(event != null){
            helper.navigateToHistorySurvey(component,event.getParam("bodyToRender"),
                                           event.getParam("storeId"),
                                           event.getParam("storeVisitCategory"),
                                           event.getParam("allCategories"));              	
        }
    },
    
    navigateToStoreVisit : function(component, event, helper) {
        if(event != null){            
            helper.navigateToOtherPages(component,event.getParam("bodyToRender"),
                                        event.getParam("storeId"),
                                        event.getParam("storeVisitCategory"),null,
                                        event.getParam("StoreActivityCatagory"),
                                        event.getParam("storeActivityId"),
                                        event.getParam("LookupFieldValue"),
                                        event.getParam("fromMultiContComp"));              	
        }
    },
    
    
    navigateToAddNotes : function(component, event, helper) {        
        if(event != null){
            helper.navigateToOtherPages(component,event.getParam("bodyToRender"),
                                        event.getParam("storeId"),
                                        event.getParam("storeVisitCategory"));              	
        }
    },
    
    navigateToStoreDetails : function(component, event, helper) {
        
        var storeId = event.getParam("storeId");
        var bodyToRender = event.getParam("bodyToRender");
        
        if(event != null){
            helper.navigateToOtherPages(component,event.getParam("bodyToRender"),
                                        event.getParam("storeId"));              	
        }
    }, 
    navigateToSendSummary: function(component, event, helper) {
        var activities = event.getParam("storeActivities");
        var storeVisitObj = event.getParam("storeVisitObj");
        if(event != null){
            if(event.getParam("storeId") != null){
            	helper.navigateToSendSummary(component,event.getParam("bodyToRender"),
                                         event.getParam("storeId"),event.getParam("storeVisitCategory"),activities,storeVisitObj,null);              	
            } else {
                helper.navigateToSendSummary(component,event.getParam("bodyToRender"),
                                             null,null,null,null,event.getParam("emailSummaryForOtherVisits"));
            }
        }
    },
    
    navigateToContactDetails: function(component, event, helper) { 
        if(event != null){
            helper.navigateToContactDetails(component,event.getParam("bodyToRender"),
                                         event.getParam("storeId"),event.getParam("storeVisitCategory"),
                                         event.getParam("contactsList"),event.getParam("storeActivities"));              	
        }
    },
    
    navigateToContactSelection: function(component, event, helper) { 
        if(event != null){
            helper.navigateToContactSelection(component,event.getParam("bodyToRender"),
                                         event.getParam("storeId"),event.getParam("storeActivityId"),
                                         event.getParam("StoreActivityCatagory"),
                                         event.getParam("storeVisitCategory"),
                                         event.getParam("LookupFieldValue"));              	
        }
    },
    navigateToNextSteps : function(component, event, helper) {
        if(event != null){
            helper.navigateToOtherPages(component,event.getParam("bodyToRender"),
                                        event.getParam("storeId"),
                                        event.getParam("storeVisitCategory"),	
                                        event.getParam("recommendedCategory"));              	
        }
    },
    navigateToIndirectOtherHistory : function(component, event, helper) {
        helper.navigateToOtherPages(component,event.getParam("bodyToRender"));
    },
    
    showSpinner : function(component, event, helper) {
        var m = component.find('modalspinner');
        $A.util.removeClass(m, "slds-hide");
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();
        
    },
    
    hideSpinner: function(component, event, helper) {
        var m = component.find('modalspinner');
        $A.util.addClass(m, "slds-hide");
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();    
    },
    
})