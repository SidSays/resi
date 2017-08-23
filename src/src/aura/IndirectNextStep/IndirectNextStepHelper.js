({
	getData : function(component, event, helper){
       var getStat = component.get("c.getTaskData"); 
        	getStat.setParams({            
            "storeId": component.get("v.store.Id")
        	}); 
			getStat.setCallback(this, function(response){
            var taskData=JSON.parse(response.getReturnValue());
              $A.createComponent(
            	"c:IndirectAddTask",{
                "title" : "Create Task",
                "statusList" : taskData.statuses,
                "priorityList" : taskData.priorities,
                "loggedInUser" : component.get("v.loggedInUser"),
                "storeVisit" : taskData.storeVisits,
                "store" : component.get("v.store")
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
			});
			$A.enqueueAction(getStat);
    },
})