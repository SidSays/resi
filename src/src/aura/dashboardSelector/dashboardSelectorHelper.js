({
    /*selectDashboard: function(component, event) {
        //console.warn("selectDashboard: ", component, event);
        var target = event.target;
        //console.warn("target: ", target);
        var id = target.getAttribute("data-id");
        //console.warn("id: ", id);
        var evt = $A.get('e.c:showDashboard');
        evt.setParams({
            dashboardId: id
        });
        evt.fire();          
    },*/
    
    /*populatePicklist: function(component, event){
        var dashboardIds = component.get("v.dashboardIds");
        var opts = [];
        for (var i = 0; i < dashboardIds.length; i++) {            
                opts.push{ class: "optionClass", 
                    	   label: "Option", 
                           value: dashboardIds[i],
                           selected: "true" }           
        }
        component.find("InputSelectDynamic").set("v.options", opts);
    },*/
   
	listDashboards: function(component, event) {
        var dashboardIds = component.get("v.dashboardIds");
        var list = component.find("list").getElement();
        //console.warn("list: ", list);
        if (list) {
            
        var item = null;
        var link = null;
        var self = this;
        var id = null;
            var opts = [];
        list.innerHTML = null;
        for (var i = 0; i < dashboardIds.length; i++) {
            
            id = dashboardIds[i];
            item = document.createElement("li");
            link = document.createElement("a");
            link.innerHTML = id;//i==0?"XSP KPIs":"XSP Compensation";
            link.setAttribute("data-id", id);
            //link.setAttrubute("class","slds-button")
            link.onclick = function(evt) {
                self.selectDashboard(component, evt);
            }
            item.appendChild(link);
            list.appendChild(item);
        }		
        }
	}
})