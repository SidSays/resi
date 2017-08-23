({
    // This method is used to populate the dashboardIds attribute and call loadDashboards
    populateDashboardIds: function(component, event, helper){
        var dashboardIds = event.getParams().dashboardIds;    
        console.warn('dashboard idss in dashboard viewer', dashboardIds);
        component.set("v.dashboardIds", dashboardIds);
        console.warn('component.get("v.dashboardIds")',component.get("v.dashboardIds"));
        if(component.get("v.dashboardIds") != undefined){
            component.set("v.preload", true);
            helper.loadDashboards(component); 
        }
    },
    
    //This methods gets called everytime there is a change in dashboardId
    dashboardIdChange: function(component, event, helper) {
        var preload = component.get("v.preload");
        helper.showDashboard(component, event); 
        
    },
    
    //This method populated the dashboardId attribute with the value send from the event fired by dashboardPicker
    handleShowDashboard: function(component, event, helper) {
        var params = event.getParams();
        var dashboardId = params.dashboardId;        
        if (dashboardId) {
            component.set("v.dashboardId", dashboardId);
        } else {
            var developerName = params.developerName;
            if (developerName) {
                component.set("v.dashboardId", null);
                component.set("v.developerName", developerName);
            }
        }
    }
    
})