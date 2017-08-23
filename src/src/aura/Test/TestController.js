({ 


	doInit : function(component, event, helper) {	
		helper.doesPropertyEventExist(component); 
    },
    
    save : function(component, event, helper){ 	

		component.find("edit").get("e.recordSave").fire();

    },
    
    handleSaveSuccess : function(component, event, helper){ 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The Property Event has been saved successfully."
        });
        toastEvent.fire();
		var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

})