({
	SaveNotes : function(component, event){
        var noteval = component.get("v.newContentNote");  
        var noteTitle = component.find("notesname").get("v.value");
       	var notesContent = component.find("contentDes").get("v.value");
        var store = component.get("v.store");
        if(noteTitle === ""){
            noteTitle= "Untitled Note";            
        }
        
        var action = component.get("c.saveNote");
        action.setParams({
            "noteObj" : noteval,
            "titleVar" : noteTitle,
            "contentVar" : notesContent,
            "LinkedEntityId": store.Id
        })
        action.setCallback(this, function(response){
           component.find("notesname").set("v.value",null);
           component.find("contentDes").set("v.value",null);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been saved successfully."
                    });
                    toastEvent.fire();
            
			});
			$A.enqueueAction(action);
        
    } ,
    
    actionReq : function(comp, event, helper){
        var cmpNames = ["c:IndirectAddNoteComp"];
        helper.navigateAddnoteComponent(comp,event,cmpNames);
    }
})