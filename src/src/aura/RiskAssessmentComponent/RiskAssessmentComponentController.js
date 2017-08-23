({
	/**
     * @author Salesforce Program Architect
     * @date 20170605
     * @description Initialize Component
     */
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
	},
    
	/**
     * @author Salesforce Program Architect
     * @date 20170605
     * @description Handle Wave Filter Events
     */
	handleWaveSelections : function(component, event, helper) {
        helper.handleWaveSelections(component, event, helper);
	},
    
	/**
     * @author Salesforce Program Architect
     * @date 20170605
     * @description Save (Upsert) Disposition Records to Server
     */
    saveDispositions : function(component, event, helper) {
        helper.saveDispositions(component, event, helper);
	},
    
	/**
     * @author Salesforce Program Architect
     * @date 20170605
     * @description Show Modal Dialog to User to Create / Update Dispositions
     */
    showPopup : function(component, event, helper) {
		helper.showPopup(component, event, helper);
    },
    
	/**
     * @author Salesforce Program Architect
     * @date 20170605
     * @description Hide Modal Dialog based on Submit or Dismissal (implemented here vs helper for brevity)
     */
    hidePopup : function(component, event, helper) {
        $(".modalContainer").css("display", "none");
	}
})