({
    doInit: function(component, event, helper) {
    	helper.listDashboards(component, event);    
    },
    onSelectChange : function(component, event, helper) {
    var selected = component.find("levels").get("v.value");
    //do something else
}
})