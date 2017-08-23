({
	  selectDashboard: function(component, event,select) {
        var evt = $A.get('e.c:showDashboard');
        evt.setParams({
            dashboardId: select
        });
        evt.fire();          
    }
})