({
    showAlertBox : function(component, event, helper) { 
      
        var title="Please select at least one contact";
        
        $A.createComponent(
            "c:IndirectShowAlert",{ 
                "title" : title
            },
            function(msgBox){
                if (component.isValid()) {
                  
                    var targetCmp = component.find('optionalModalDialog');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                }
            }
        );
        
    },
    
})