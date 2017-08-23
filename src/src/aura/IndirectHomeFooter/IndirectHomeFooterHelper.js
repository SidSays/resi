({
 showAlertBox : function(component, event, helper, title,endPreviousStore) {     
       var title = title;      
      $A.createComponent(
            "c:IndirectShowAlert",{ 
                "title" : title,
                "confirmBox" : true,
                "endPreviousStore" : endPreviousStore
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