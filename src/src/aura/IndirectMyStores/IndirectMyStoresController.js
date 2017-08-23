({
    doInit : function(component,event,helper){
    	var storeMap = component.get("v.storeMap");
        var storeList = [];
        for(storeId in storeMap){
            storeList.push(storeMap[storeId]);
        }
        storeList.sort(function(a, b){            
                	return a.Name < b.Name ? -1 : a.Name > b.Name ? 1 : 0;              
        });               
        component.set("v.stores", storeList);        
    },
    
    sortStoreList : function(component,event,helper){
        var selected = component.find("levels").get("v.value");
        var stores = component.get("v.stores");
        var levels = component.get("v.sortlevels");
        stores.sort(function(a, b){
            	if(selected == levels[0]){
                	return a.Name < b.Name ? -1 : a.Name > b.Name ? 1 : 0;
                } else if(selected == levels[1]){
                    for(var idx in stores){
                        stores[idx].Last_Visit_Date_UTC__c = stores[idx].Last_Visit_Date__c ? new Date(stores[idx].Last_Visit_Date__c) : 0;
                    }
                    
                    return a.Last_Visit_Date_UTC__c < b.Last_Visit_Date_UTC__c ? -1 : a.Last_Visit_Date_UTC__c > b.Last_Visit_Date_UTC__c ? 1 : 0;                    
                } 
            });
               
        component.set("v.stores", stores);
	},
    goToStoreDetail: function(component,event,helper){
         var user = component.get("v.loggedInUser");
		 var selectedItem = event.currentTarget; // Get the target object
         var storeId = selectedItem.dataset.record; // Get its value i.e. the storeId
         var appEvt = $A.get("e.c:IndirectNavigateToStoreDetails");
         appEvt.setParams({"storeId" : storeId,
                           "bodyToRender" : "storedetail"}).fire();
    }
})