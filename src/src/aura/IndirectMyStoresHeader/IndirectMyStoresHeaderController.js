({
    goToMyDashboard : function(component, event, helper) {
		var eventVar = $A.get("e.c:IndirectNavigateToDashboard");
        eventVar.setParams({"currentuser" : component.get("v.loggedInUser"),
                            "hisstores" : component.get("v.stores"),
                            "hisvisits" : component.get("v.storevisits")}).fire();
	},
      
    sortStoreList : function(component,event,helper){
        var selected = component.find("levels").get("v.value");
        var stores = component.get("v.stores");
        var levels = component.get("v.sortlevels");
        stores.sort(function(a, b){
            	if(selected == levels[0]){
                	return a.Name > b.Name;
                } else if(selected == levels[1]){
                    return a.Last_Visit_Date__c > b.Last_Visit_Date__c;
                } else{
                    return a.Name < b.Name;
                }
            });
               
        component.set("v.stores", stores);
	},
    goToStoreDetail: function(component,event,helper){
		 var selectedItem = event.currentTarget; // Get the target object
         var Index = selectedItem.dataset.record; // Get its value i.e. the index
         var selectedStore = component.get("v.stores")[Index]; // Use it retrieve the store record
         var navigateToStoreDetailEvt = $A.get("e.c:IndirectNavigateToStoreDetails");
         navigateToStoreDetailEvt.setParams({"store" : selectedStore,
                                            "stores" : component.get("v.stores"),
                                            "visits" : component.get("v.storevisits"),
                                            "currentuser" : component.get("v.loggedInUser")}).fire();
    }
})