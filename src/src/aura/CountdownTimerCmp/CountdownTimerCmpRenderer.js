({
    reRender: function(component, helper) {
        //reRender is called automatically everytime the components data is changed,
        // in this case when v.time is updated by setInterval
        // get the latest time string and set the html

         
        
        var ret = this.superReRender();
        var time = component.get("v.time");
        document.getElementById("clock").innerHTML= time;

        var backgroundColor = component.get("v.backgroundColor");
        return ret;
    }
})