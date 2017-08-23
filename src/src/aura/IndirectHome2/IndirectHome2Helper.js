({
    setHeaderAndFooter : function(component,bodyToRender, storeName){
        switch(bodyToRender) {
            case 'visits':
                component.set("v.title","HOME");
                component.set("v.module","preparation");
                break;
            case 'stores':
                component.set("v.title","MY STORES");
                component.set("v.module","preparation");
                break;
            case 'storedetail':
                component.set("v.title",storeName);
                component.set("v.module","detail");
                break;
            case 'visithistory':
                component.set("v.title",storeName);
                component.set("v.module","detail");
                break;
            case 'visithistory2':
                component.set("v.title",storeName);
                component.set("v.module","visit");
                break;
            case 'storevisit':
                component.set("v.title",storeName);
                component.set("v.module","visit");
                break;
            case 'addnotes':
                component.set("v.title",storeName);
                component.set("v.module","visit");
                break;
            case 'sendsummary':
                if(storeName == null) {
                	component.set("v.title","OTHER VISITS");
                }
                else {
                    component.set("v.title",storeName);
                }
                component.set("v.module","");
                break;
            case 'nextsteps':
                component.set("v.title",storeName);
                component.set("v.module","visit");
                break;
            case 'other':
                component.set("v.title","OTHER VISITS");
                component.set("v.module","other");
                break;
            case 'otherHistory':
                component.set("v.title","OTHER VISITS");
                component.set("v.module","other");
                break;
            case 'contactDetail':
                component.set("v.title",storeName);
                component.set("v.module","");
                break;
            case 'addContactsToActivity':
                component.set("v.title",storeName);
                component.set("v.module","");
                break;
            default:
                break;
        }
    },
    
    updateDataInPlatformCache : function(component, bodyToRender, storeId, categories,emailSummary,storeActivityCatagory,activityId,currentButtonValue){      
        var action = component.get("c.setCachedData");        
        action.setParams({
            "bodyToRender" : bodyToRender,
            "storeId" : storeId,
            "categories" : categories,
            "emailSummary" : emailSummary,
            "storeActivityCatagory" : storeActivityCatagory,
            "activityId" : activityId,
            "currentButtonValue" : currentButtonValue
        });
        
        action.setCallback(this, function(a){
            var cachedData = a.getReturnValue();
            var store = (cachedData.storeId != null)? component.get("v.storeMap")[cachedData.storeId] : null;
            var storeName = store != null ? store.Name : null;
            var categories = (cachedData.categories != null)? cachedData.categories : null;
            var emailSummary = (cachedData.emailSummary != null)? cachedData.emailSummary : null;
            var storeActivityCatagory = (cachedData.storeActivityCatagory != null)? cachedData.storeActivityCatagory : null;
            var storeActivityId = (cachedData.activityId != null)? cachedData.activityId : null;
            var LookupFieldValue = (cachedData.currentButtonValue != null)? cachedData.currentButtonValue : null;
            
            component.set("v.store",store);
            component.set("v.storeVisitCategory",categories);
            component.set("v.emailSummaryForOtherVisits",emailSummary);                       
            component.set("v.renderbody",cachedData.bodyToRender);//Body
            component.set("v.StoreActivityCatagory",storeActivityCatagory);
            component.set("v.storeActivityId",storeActivityId);
         	component.set("v.LookupFieldValue",LookupFieldValue);  
            
            this.setHeaderAndFooter(component,cachedData.bodyToRender, storeName);   
            component.rerender();
        });
        
        $A.enqueueAction(action);                         	
                
    },
    
    navigateToDashboardOrMyStores : function(component, bodyToRender){
        
        this.updateDataInPlatformCache(component, bodyToRender);
        
        component.set("v.store", null);
    },
    
    navigateToOtherVisits : function(component, bodyToRender){
        
        this.updateDataInPlatformCache(component, bodyToRender);
        
        component.set("v.store", null);
    },
    
    navigateToSendSummary : function(component,bodyToRender,storeId,categories,activities,storeVisitObj, emailSummary){
        component.set("v.storeVisitObj", storeVisitObj);
        component.set("v.storeActivities",activities);
        component.set("v.emailSummaryForOtherVisits",emailSummary);
        this.updateDataInPlatformCache(component, bodyToRender, storeId, categories,emailSummary);  
       
    },   
    
     navigateToContactDetails : function(component,bodyToRender,storeId,categories,contactsList,activities){
         component.set("v.contactsList",contactsList);
         component.set("v.storeActivities",activities);
         
         this.updateDataInPlatformCache(component, bodyToRender, storeId, categories);  
       
    }, 
    
    navigateToContactSelection : function(component,bodyToRender,storeId,storeActivityId,StoreActivityCatagory,categories,LookupFieldValue){        
         component.set("v.storeActivityId",storeActivityId);
         component.set("v.LookupFieldValue",LookupFieldValue);        
         this.updateDataInPlatformCache(component, bodyToRender, storeId, categories,null,StoreActivityCatagory,storeActivityId,LookupFieldValue);  
       
    }, 
    
    navigateToOtherPages : function(component,bodyToRender,storeId, categories, recommendedCategories,StoreActivityCatagory,storeActivityId,LookupFieldValue,fromMultiContComp){       
        if(StoreActivityCatagory != null){
            component.set("v.StoreActivityCatagory",StoreActivityCatagory);
        }
        if(storeActivityId != null){
            component.set("v.storeActivityId",storeActivityId);
        }
        if(LookupFieldValue != null){
            component.set("v.LookupFieldValue",LookupFieldValue);
        }
        if(fromMultiContComp != null){
            component.set("v.fromMultiContComp",fromMultiContComp);
        }
        this.updateDataInPlatformCache(component, bodyToRender, storeId, categories,null,StoreActivityCatagory,storeActivityId,LookupFieldValue);  
        if(recommendedCategories != null)	
            component.set("v.recommendedCategory", recommendedCategories);
    },  
    
    navigateToHistorySurvey : function(component,bodyToRender,storeId, categories, allCategories){
        
        this.updateDataInPlatformCache(component, bodyToRender, storeId, categories);  
        if(allCategories != null)		  
            component.set("v.allCategories", allCategories);
    }  
})