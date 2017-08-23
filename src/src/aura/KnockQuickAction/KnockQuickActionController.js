({ 
    
    doInit : function(component, event, helper) {
        var geo = navigator.geolocation;
        if(geo){
            geo.getCurrentPosition(function (position) { 
                component.set("v.lat",position.coords.latitude); 
                component.set("v.longi",position.coords.longitude);
            }, function () {
                console.log("Unable to retrieve your location");
            });
        }else{
            console.log("Geolocation is not supported by this browser.");
        }
        
        var dpopts=[]; var vcopts=[]; var icopts=[]; var xhopts=[];
        var pcopts=[]; var stopts=[]; var nmropts=[]; var rropts=[];
        
        // Pre-fill all the picklist fields available on the component
        var action = component.get("c.getAllPicklistValues");  
        action.setCallback(this, function(cb) {
            var result = cb.getReturnValue();
            if(result){
                var dp  = result.dpoptions;
                var vc  = result.vcoptions;
                var ic  = result.icoptions;
                var pc  = result.pcoptions;
                var xh  = result.xhoptions;
                var st  = result.stoptions;
                var nmr = result.nmroptions;
                var rr  = result.rroptions;
                
                dpopts.push({"class": "optionClass", label: "--None--", value: null});
                for(var i=0;i< dp.length;i++){
                    if(dp[i] !== "No Knock")
                    dpopts.push({"class": "optionClass", label: dp[i], value: dp[i]});
                }
                component.find("disposition").set("v.options", dpopts);
                
                vcopts.push({"class": "optionClass", label: "--None--", value: null});
                for(var i=0;i< vc.length;i++){
                    vcopts.push({"class": "optionClass", label: vc[i], value: vc[i]});
                }
                component.find("videocomp").set("v.options", vcopts);
                
                icopts.push({"class": "optionClass", label: "--None--", value: null});
                for(var i=0;i< ic.length;i++){
                    icopts.push({"class": "optionClass", label: ic[i], value: ic[i]});
                }
                component.find("internetcomp").set("v.options", icopts);
                
                pcopts.push({"class": "optionClass", label: "--None--", value: null});
                for(var i=0;i< pc.length;i++){
                    pcopts.push({"class": "optionClass", label: pc[i], value: pc[i]});
                }
                component.find("phonecomp").set("v.options", pcopts);
                
                xhopts.push({"class": "optionClass", label: "--None--", value: null});
                for(var i=0;i< xh.length;i++){
                    xhopts.push({"class": "optionClass", label: xh[i], value: xh[i]});
                }
                component.find("xhcomp").set("v.options", xhopts);
                
                stopts.push({"class": "optionClass", label: "--None--", value: null});
                for(var i=0;i< st.length;i++){
                    stopts.push({"class": "optionClass", label: st[i], value: st[i]});
                }
                component.find("salestype").set("v.options", stopts);
                
                nmropts.push({"class": "optionClass", label: "--None--", value: null});
                for(var i=0;i< nmr.length;i++){
                    nmropts.push({"class": "optionClass", label: nmr[i], value: nmr[i]});
                }
                component.find("nonMarktRsn").set("v.options", nmropts);
                
                rropts.push({"class": "optionClass", label: "--None--", value: null});
                for(var i=0;i< rr.length;i++){
                    rropts.push({"class": "optionClass", label: rr[i], value: rr[i]});
                }
                component.find("rejectreason").set("v.options", rropts);
            } 
            
        });
        $A.enqueueAction(action);
        
        if (!navigator.geolocation){
            alert('Geolocation is not supported by your browser');
            $A.get("e.force:showToast").setParams({
                "title": "Error!","message": "Geolocation is not supported by your browser"}).fire();
        }
    },  
    
	// this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.spinner", true); 
   },
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.spinner", false);
    },
    
    saveAction : function(component, event, helper) {
        helper.saveKnock(component,helper);        
    },
    
    cancelAction : function(component, event, helper) {
        $A.get("e.force:navigateToSObject").setParams({
            "recordId": component.get ("v.recordId"),"slideDevName": "detail"}).fire();        
    },
    
    onChangeFunction: function(component, event, helper) {
        var showSection = component.find("disposition").get("v.value");
        component.set("v.disp",showSection.toUpperCase());
        component.set ("v.title", true);
        component.set ("v.showSection0", false);
        component.set ("v.showSection8", true);
        if (showSection === "Contact" || showSection === "Engage" || showSection === "Discover"
            || showSection === "Position" || showSection === "Close"){
            component.set ("v.showSection1", true);
            component.set ("v.showSection4", true);
            component.set ("v.showSection7", true);
        }
        if (showSection === "Start"){
            component.set ("v.showSection1", true);
            component.set ("v.showSection2", true); 
            component.set ("v.showSection3", true);
            component.set ("v.showSection4", true);
            component.set ("v.showSection5", true);
            component.set ("v.showSection7", true);
        }
        if (showSection === "Non-Marketable Address"){
            component.set ("v.showSection6", true); 
            component.set ("v.showSection7", true);
        }
        if (showSection === "No Answer" || showSection === "Door Hanger" || showSection === "No Knock"){
            component.set ("v.showSection7", true); 
        }
    }
    
})