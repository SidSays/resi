({
    "doInit": function(cmp, event, helper) {
        helper.processInit(cmp, event);
    },

    "navigateTo": function(cmp, event, helper) {
        // Hide the submenu tooltip on any nav item click.
        $A.util.addClass(cmp.find("submenuNotMobileId"), 'toggle');
        $A.util.addClass(cmp.find("submenuMobileId"), 'toggle');
    },

    "appLauchClick": function(cmp, event) {
        $A.util.addClass(cmp.find("submenuNotMobileId"), 'toggle');
        $A.util.addClass(cmp.find("submenuMobileId"), 'toggle');
        $A.util.toggleClass(cmp.find("headMenu"), 'slds-panel-active');

        $A.get("e.c:ToggleDashboardEvent").fire();
    },

    "toggleSubMenus": function(cmp, event) {
        $A.util.toggleClass(cmp.find("submenuNotMobileId"), "toggle");
        $A.util.toggleClass(cmp.find("submenuMobileId"), "toggle");
    },

    "toggleMenu": function(cmp, event) {
        $A.util.addClass(cmp.find("submenuNotMobileId"), 'toggle');
        $A.util.addClass(cmp.find("submenuMobileId"), 'toggle');
        $A.util.toggleClass(cmp.find("headMenu"), 'slds-panel-active');
    }

})