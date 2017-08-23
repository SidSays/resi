({
    afterRender: function(component, helper) {
        this.superAfterRender();
        helper.listDashboards(component);
    }
})