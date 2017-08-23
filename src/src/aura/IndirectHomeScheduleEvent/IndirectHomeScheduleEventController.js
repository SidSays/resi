({
    createRecord : function (component, event, helper) {
    helper.raiseS1Event(
                    component,
                    event,
                    helper,
                    "e.force:createRecord", 
    {entityApiName: component.get("v.objectname")}
                      ); 
 
 }   
})