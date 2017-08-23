({
    plansLoaded: function(component, event, helper) {
        var plans = event.getParam("Plans");
        var currentPlanName = event.getParam("CurrentPlanName");
        component.set("v.currentPlanName", currentPlanName);
        if (plans != undefined && plans.length > 0) {
            var turfs = [],
                playlists = [];

            plans.forEach(function(p) {
                p.Expiration_Date__c = helper.getShoreDate(component, new Date(p.Expiration_Date__c));
                p.Plan_Created_Date__c = helper.getShoreDate(component, new Date(p.Plan_Created_Date__c));
                if (p.Plan_Level__c === $A.get("$Label.c.PlanTypeTurf")) {
                    turfs.push(p);
                } else {
                    if (p.Plan_Level__c === $A.get("$Label.c.PlanTypePlaylist")) {
                        playlists.push(p);
                    }
                }
            });
            component.set("v.Turfs", turfs);
            component.set("v.Playlists", playlists);
        }
    },
    openPlans: function(component, event) {
        $A.util.toggleClass(component.find('planpopover'), 'slds-is-open');
    },
    // Description : US728539 - DSM to SF1 : Address Sorting, Author : Siddharth Sinha
    addressesLoaded: function(component, event, helper) {
        var filteredAddress = event.getParam('filteredAddresses');
        if (filteredAddress != undefined) {
        	//filteredAddress.sort(function(a,b) {return (a.Sort_Code__c > b.Sort_Code__c) ? 1 : ((b.Sort_Code__c > a.Sort_Code__c) ? -1 : 0);} );
            component.set("v.sortedAddresses", filteredAddress);
            component.set("v.originalAddresses", event.getParam('originalAddresses'));
        }
    },
    toggleSort: function(component, event, helper) {
        $A.util.toggleClass(component.find('sortDropdown'), 'slds-is-open');
    },
    sortAddr: function(component, event, helper) {
        var type;
        var sortedAddresses;
        var selected = event.currentTarget;
        $(selected).addClass("selected");
        $(".sort-icon").removeClass("asc desc");
        if ($(".selected").length > 1) {
            $(".sort-item").removeClass('selected asc desc');
            $(selected).addClass("selected");
        }
        if ($(".selected").length === 1) {
            if ($(selected).hasClass('asc')) {
                $(selected).removeClass('asc').addClass("desc");
                type = 'desc';
            } else {
                if ($(selected).hasClass('desc')) {
                    $(selected).removeClass('desc').addClass("asc");
                }
                type = 'asc';
                $(selected).removeClass('desc').addClass("asc");
            }
        }
        if (type === "asc") {
            $(".sort-icon").addClass("asc");
        }
        if (type === "desc") {
            $(".sort-icon").addClass("desc");
        }
        var addresses = component.get("v.sortedAddresses");
        var criteria = event.currentTarget.dataset.dd;
        sortedAddresses = helper.sorting(component, addresses, criteria, type);
        component.set("v.sortLabel", criteria);
        $A.util.toggleClass(component.find('sortDropdown'), 'slds-is-open');
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({
            "filteredAddresses": sortedAddresses,
            "originalAddresses": component.get("v.originalAddresses")
        }).fire();
    },
    //Get the Header Label from Clear All Event of Header Pane (Filtered Addresses)
	getsortLabel : function(component, event) {
    	var label = event.getParam("passHeaderLabel");
        component.set("v.sortLabel", label);          
	},    
    //changes end - US728539 - DSM to SF1 : Address Sorting
    
    openSortMenu: function(component, event) {
        //$A.util.toggleClass(component.find('planpopover'), 'slds-is-open');
    },

    listTurfs: function(component, event) {
        $A.util.removeClass(component.find("turfs"), "slds-button_neutral");
        $A.util.addClass(component.find("turfs"), "slds-button_brand");
        $A.util.removeClass(component.find("playlists"), "slds-button_brand");
        $A.util.addClass(component.find("playlists"), "slds-button_neutral");
        component.set("v.PlansType", $A.get("$Label.c.PlanTypeTurf"));

    },

    listPlaylists: function(component, event) {
        $A.util.removeClass(component.find("playlists"), "slds-button_neutral");
        $A.util.addClass(component.find("playlists"), "slds-button_brand");
        $A.util.removeClass(component.find("turfs"), "slds-button_brand");
        $A.util.addClass(component.find("turfs"), "slds-button_neutral");
        component.set("v.PlansType", $A.get("$Label.c.PlanTypePlaylist"));
    },

    loadPlan: function(component, event) {
        var selectedItem = event.currentTarget; // Get the target object
        var planId = selectedItem.dataset.record; // Get its value i.e. the planId
        if (planId && planId.slice(0, 3) == 'a0I') { //set redirection to load playlist
            var myURL = "/apex/AddressFiltering?id=" + planId + "&sfdc.override=1";
            if ((typeof sforce != 'undefined') && (sforce != null)) {
                // Salesforce1 navigation
                sforce.one.navigateToURL(myURL);
            } else {
                // In Browser 
                window.location.href = myURL;
            }
        } else {
            console.log("Error loading the Plan");
        }
    }
})