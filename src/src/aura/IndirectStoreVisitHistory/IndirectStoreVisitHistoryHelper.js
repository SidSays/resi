({
    showToast: function(component)
    {
        var toast = $A.get("e.force:showToast");
        toast.setParams({"message" : "No completed activity is created for this category"});
        toast.fire();
    }
    

})