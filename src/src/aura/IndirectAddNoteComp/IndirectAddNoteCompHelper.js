({
	navigateAddnoteComponent : function(component,event,newCmps) {
        
        $A.createComponents([
            			 [newCmps[0],{newStore : event.getParam("acc").Id} ]
                                             
                     ],function(components,status,statusMessagesList){
                        if (component.isValid()) {
                            var body = [];
                            body.push(components[0]);                        
                            component.set("v.body", body);
                        }
        			}
                            
        );
	
    }
})