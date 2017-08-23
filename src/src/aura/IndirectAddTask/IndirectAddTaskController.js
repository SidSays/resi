({
    doInit : function(component, event, helper) {
     var status=component.get("v.statusList");
        //alert(status.length);
         opts= [];
         for (var i=0; i<status.length; i++) {
             if(status[i] == "In Progress")
               {
                    opts.push({
                    label : status[i],
                    value: status[i],
                    selected: "true",
                    class: "optionClass"      
                });
               }else{              
                opts.push({
                    label : status[i],
                    value: status[i],
                    class: "optionClass"
                });
               }
            }
     component.find("statusDropdown").set("v.options", opts);
        
     var priority=component.get("v.priorityList")
        //opts.splice(0,opts.length); 
        opts=[];
         for (var i=0; i<priority.length; i++) {
               if(priority[i] == "Normal")
               {
                    opts.push({
                    label : priority[i],
                    value: priority[i],
                    selected: "true",
                    class: "optionClass"
                });
               }else{
                opts.push({
                    label : priority[i],
                    value: priority[i],
                    class: "optionClass"
                });
            }
         }
     component.find("priorityDropdown").set("v.options", opts); 
        
     var taskInitialValue = { 'sobjectType': 'Task', 'Subject': 'Remainder Task' , 'ActivityDate': '','Description':''};
     component.set("v.task", taskInitialValue);
       
    },
    
	SaveTask : function(component, event, helper) {
       var subject = component.find("subject");
       var subjectvalue = subject.get("v.value");
       
       if(subjectvalue  === ""){           	
            subject.set("v.errors", [{message:"Subject cannot be blank" }]);
        }else{
            subject.set("v.errors", null);
        	var storeVis = component.get("c.CreateTask");
			storeVis.setParams({            
            "task": component.get("v.task"),
            "whatId" : component.get("v.store.Id"),
            "status" : component.get("v.status"),            
            "priority" : component.get("v.priority")
        	}); 
            helper.defaultClose(component,event, helper);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                        "title": "Success!",
                        "message": "Task has been created successfully!!"
                    });
            toastEvent.fire();
        	storeVis.setCallback(this, function(response){  
                var state = response.getState();
               // var toastEvent = $A.get("e.force:showToast");
        		if (state === "SUCCESS") { 
                    /*toastEvent.setParams({
                        "title": "Success!",
                        "message": "Task has been created successfully!!"
                    });
                    toastEvent.fire();
            		helper.defaultClose(component,event, helper);*/
                }else if (state === "ERROR") {
                    // generic error handler
                    var errors = response.getError();
                    if (errors) {
                        $A.logf("Errors", errors);
                        if (errors[0] && errors[0].message) {
                            throw new Error("Error" + errors[0].message);
                        }
                    } else {
                        throw new Error("Unknown Error");
                    }
                }
			});
			$A.enqueueAction(storeVis);	
        }
        },
    defaultCloseAction : function(component, event, helper) {  
        helper.defaultClose(component,event, helper);
    },
})