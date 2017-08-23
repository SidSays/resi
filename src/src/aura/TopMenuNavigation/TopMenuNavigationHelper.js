({
	clearClass : function(cmp, event, divId) {
		var navigationDivElement = document.getElementById(divId);
        var listItems = navigationDivElement.getElementsByTagName('a');
        
        //for each list item
        for (var index = 0; index < listItems.length; ++index) {
            if(event.target != listItems[index]){
                listItems[index].className = '';
            }
        }
	},
    
    processInit : function(cmp, event){
        var userInformationAction = cmp.get("c.getLoggedInUserInformation");

        userInformationAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var userObj = response.getReturnValue();
				cmp.set("v.userphotourl", userObj.SmallPhotoUrl);
                cmp.set("v.userName", userObj.Name);
            }else{
             	this.handleErrors(cmp, event, state);   
            }
        });
        
        var navigationMenuAction = cmp.get("c.getNavigationMenus");

        navigationMenuAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var navigationMenuWrapperList = response.getReturnValue();
				cmp.set("v.navigationMenuWrapperList", navigationMenuWrapperList);
                
            }else{
             	this.handleErrors(cmp, event, state);   
            }

        });

        var profileSubmenuOptionsAction = cmp.get("c.getProfileSubmenuOptions");

        profileSubmenuOptionsAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var submenuWrapperList = response.getReturnValue();
				cmp.set("v.submenuWrapperList", submenuWrapperList);
                
            }else{
             	this.handleErrors(cmp, event, state);   
            } 

        });
        // Add both the actions to queue.
        $A.enqueueAction(userInformationAction);
        $A.enqueueAction(navigationMenuAction);
        $A.enqueueAction(profileSubmenuOptionsAction);
    },
    
    handleErrors : function(cmp, event, state){
         if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        alert("Error message: " + 
                                 errors[0].message)
                    }
                } else {
                    console.log("Unknown error");
                    alert("Unknown error");
                }
            }
    }
})