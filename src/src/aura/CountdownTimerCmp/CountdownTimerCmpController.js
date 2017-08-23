({
	doInit : function(component, event, helper) {        
        // create an interval timer that calls setClock        
        window.setInterval(
            $A.getCallback(function(){
                helper.setClock(component)
                })
            ,1000);

        
	}
})