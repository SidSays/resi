({
    selectDashboard: function(component, event) {
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
    },
    
	listDashboards: function(component, event) {
        var dashboardIds = component.get("v.dashboardIds");
        var list = component.find("list").getElement();
        //console.warn("list: ", list);
        if (list) {
            
        var item = null;
        var link = null;
        var self = this;
        var id = null;
        list.innerHTML = null;
        for (var i = 0; i < dashboardIds.length; i++) {
            id = dashboardIds[i];
            item = document.createElement("button");
            //link = document.createElement("a");
            item.innerHTML = i==0?"View XSP KPIs":"View XSP Compensation";
            //link.setAttribute("class","slds-button")
            var btnClass = i==0? "slds-button_stateful slds-is-selected":"slds-button_stateful";
            item.setAttribute("data-id", id);
            item.onclick = function(evt) {
                self.selectDashboard(component, evt);
            }
            //item.appendChild(link);
            list.appendChild(item);
        }		
        }
	}
})