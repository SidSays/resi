({
showAlertBox : function(component, event, helper, title) {     
        //var title="No contact available on the Store";
        var title = title;
       
        $A.createComponent(
            "c:IndirectShowAlert",{ 
                "title" : title,
                "confirmBox" : false
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