({
	saveKnock: function(component, event, helper){
        
        var dispo = component.find("disposition").get("v.value");
        var vc = (component.find("videocomp"))? component.find("videocomp").get("v.value"):null;
        var ic = (component.find("internetcomp"))? component.find("internetcomp").get("v.value"):null;
        var xh = (component.find("xhcomp"))? component.find("xhcomp").get("v.value"):null;
        var pc = (component.find("phonecomp"))? component.find("phonecomp").get("v.value"):null;
        var st = (component.find("salestype"))? component.find("salestype").get("v.value"):null;
        var nm = (component.find("nonMarktRsn"))? component.find("nonMarktRsn").get("v.value"):null;
        //console.log("Sale type : "+ st + " Is it null : "+ (st==null));

        if(dispo === "Start" && (st==null)){
            component.find("salestype").set("v.errors", [{message:"You must select a Sale Type"}]);
           return;
        } else{
            component.find("salestype").set("v.errors", null);
        }
        
        var vcdate = (component.find("vcdate"))? component.find("vcdate").get("v.value"):null;
        var icdate = (component.find("icdate"))? component.find("icdate").get("v.value"):null;
        var pcdate = (component.find("pcdate"))? component.find("pcdate").get("v.value"):null;
        var xhdate = (component.find("xhdate"))? component.find("xhdate").get("v.value"):null;
        
        var vcsold = (component.find("vcsold"))? component.find("vcsold").get("v.value"):null;
        var icsold = (component.find("icsold"))? component.find("icsold").get("v.value"):null;
        var pcsold = (component.find("pcsold"))? component.find("pcsold").get("v.value"):null;
        var xhsold = (component.find("xhsold"))? component.find("xhsold").get("v.value"):null;
        
        var propevt = (component.find("propertyevent"))? component.find("propertyevent").get("v.value"):null;
        var evtname = (component.find("eventname"))? component.find("eventname").get("v.value"):null;
        
        var rr = (component.find("rejectreason"))? component.find("rejectreason").get("v.value"):null;
        var comms = (component.find("notesId"))?component.find("notesId").get("v.value"):null ;
        
        var action = component.get("c.createNewKnock");
        
        action.setParams({
            "addrId": component.get ("v.recordId"),
            "lat" : component.get("v.lat"),
            "longi" : component.get("v.longi"),
            "disposition" : dispo,
            "vc" : vc,"ic" : ic,"pc" : pc,
            "xh" : xh,"st" : st, "nm" : nm,
            "vcdate" : vcdate,"icdate" : icdate,
            "pcdate" : pcdate,"xhdate" : xhdate,
            "vcsold" : vcsold,"icsold" : icsold,
            "pcsold" : pcsold,"xhsold" : xhsold,
            "rr" : rr,"propEvt" : propevt,
            "evtName" : evtname,"comments" : comms,
            });

        action.setCallback(this, function(response){            
            var state = response.getState();
            var message = component.find("messagebox");
        	if (state === "SUCCESS") {
                message.set("v.class","slds-hide");
                var result = response.getReturnValue();
                if(result.isSuccess){
                   $A.get("e.force:navigateToSObject").setParams({
                      "recordId": component.get ("v.recordId"),
                      "slideDevName": "detail"
                    }).fire();
                    $A.get("e.force:showToast").setParams({
                        "title": "Success!",
                        "message": "Task has been created successfully!!"
                    }).fire();
                } else{
                    //Set the error message
                    message.set("v.class","slds-show");
                    var outputText = message.get("v.body")[0];
                    outputText.set("v.value",result.Error);
                }
            }
        });
            $A.enqueueAction(action);
        }
    }
})