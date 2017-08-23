({
	  showAlertBox : function(component, event, helper, title, confirm, selectedEvent) { 
        var OkBox = false;        
        if(confirm == false){
            var OkBox = true;
        }       
		var title = title;        
        $A.createComponent(
            "c:IndirectShowAlert",{ 
                "title" : title,
                "confirmBox" : confirm,
                "OkBox" : OkBox,
                "selectedEvent" :selectedEvent               
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