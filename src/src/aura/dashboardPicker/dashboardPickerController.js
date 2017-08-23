({
    doInit : function(component) {
        var action = component.get("c.getCoachingCustomMetaData");
        console.warn('in do in it');
        action.setCallback(this, function(a) {           
            var dashboardIdList = [];
            var opts = [];
            var result = a.getReturnValue();
            if(result != null){
                for(var i = 0 ; i<result.length;i++){
                    opts.push({ class: "optionClass", label: result[i].MasterLabel, value: result[i].Value__c });
                    dashboardIdList.push(result[i].Value__c );
                }
               // component.set("v.dashboardIds", dashboardIdList);
                component.find("levels").set("v.options", opts);
                console.warn('dashboardIdList',dashboardIdList);
                var evt = $A.get('e.c:sendDashboardIds');
                evt.setParams({
                    dashboardIds: dashboardIdList
                });
                evt.fire(); 
            }
        });                        
        $A.enqueueAction(action);
    },
    
    onSelectChange : function(component, event, helper) {
        var selected = component.find("levels").get("v.value");
        helper.selectDashboard(component, event,selected);
    },
    
    openObservationForm : function(component, event, helper){
    var url = "https://onecomcast--devpro1--c.cs14.visual.force.com/apex/ObservationForm";
    window.location.assign(url);    
    }
})