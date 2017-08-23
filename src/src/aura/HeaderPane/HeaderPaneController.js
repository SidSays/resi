({  
    doInit : function(component, event, helper) {        
       if (!navigator.geolocation){
				//alert('Geolocation is not supported by your browser');
				
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Error!",
					"message": "Geolocation is not supported by your browser"
				});
				toastEvent.fire();
			}
			navigator.geolocation.getCurrentPosition(success, error);
			function success(position) {
				component.set("v.lat",position.coords.latitude); 
				component.set("v.longi",position.coords.longitude);
                var lat = component.get("v.lat");
		        var longi = component.get("v.longi"); 
			}
			function error() {
				//alert('Unable to retrieve your location');
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"title": "Error!",
					"message": "Unable to retrieve your location"
				});
				toastEvent.fire();
			}
			
		 var today = new Date();
        component.set('v.endDateTime', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
		
    },
    toggleMenu : function(component, event, helper) {
        $A.util.toggleClass(component.find('dropdown'), 'slds-is-open'); 
		$A.util.removeClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('distdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('rejdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('playlist'), 'slds-is-open');
        $A.util.addClass(component.find("searchbox"), 'slds-combobox-lookup');
        $A.util.removeClass(component.find("searchbox"), 'slds-is-open');
    },
    
    closeSearchBox : function(component, event, helper) {
        document.getElementById('searchbox').setAttribute("aria-expanded", false); 
        $A.util.removeClass(component.find("searchbox"), 'slds-is-open');
        $A.util.addClass(component.find("searchbox"), 'slds-combobox-lookup');
        
    },
    
    togglePlaylistPopup : function(component, event, helper) {
        $A.util.toggleClass(component.find('playlist'), 'slds-is-open');
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.addClass(component.find("searchbox"), 'slds-combobox-lookup');
        $A.util.removeClass(component.find("searchbox"), 'slds-is-open');
    },
    
    // called when event "SendFilteredAndOriginalAddressList" is fired and subsequently handled
    addressesLoaded: function(component, event, helper) {
        var filteredAddress = event.getParam('filteredAddresses');
        if(filteredAddress != undefined ){
			//add event.getparam
            component.set("v.filteredAddresses",event.getParam('filteredAddresses'));
            component.set("v.originalAddresses",event.getParam('originalAddresses'));
			//end
        }
    },
	
    //Get Current Plan's Name
	getCurrentPlanName : function(component, event, helper) {
        var planName = event.getParam("CurrentPlanName");
        if(planName != undefined ){
            component.set("v.CurrentPlanName",planName);
        }
    },   
    // To clear all filters in one tap
    clearAll : function(component, event, helper){
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.addClass(component.find('worktype'), 'hide-initially');
        $A.util.addClass(component.find('apc'), 'hide-initially');
        $A.util.addClass(component.find('mrc'), 'hide-initially');
        $A.util.addClass(component.find('ap'), 'hide-initially');
        $A.util.addClass(component.find('cs'), 'hide-initially');
        $A.util.addClass(component.find('dt'), 'hide-initially');
        $A.util.addClass(component.find('disp'), 'hide-initially');
        $A.util.addClass(component.find('ts'), 'hide-initially');
		$A.util.addClass(component.find('dist'), 'hide-initially');
		$A.util.addClass(component.find('rejId'), 'hide-initially');
		$A.util.addClass(component.find('discdate'), 'hide-initially')
		
        
        document.getElementById("video").checked=false;
        document.getElementById("internet").checked=false;
        document.getElementById("voice").checked=false;
        document.getElementById("xh").checked=false;
        
        document.getElementById("active").checked=false;
        document.getElementById("inactive").checked=false;
        
        document.getElementById("bulkbilledmaster").checked=false;
        document.getElementById("bulkbilledmdu").checked=false;
        document.getElementById("commercial").checked=false;
        document.getElementById("multipledwellingunit").checked=false;
        document.getElementById("nonbulkbilled").checked=false;
        document.getElementById("nonbulkbilledmdu").checked=false;
        document.getElementById("singlefamily").checked=false;
        document.getElementById("singlefamilyunit").checked=false;
        document.getElementById("unknown").checked=false;
        document.getElementById("vacant").checked=false;
        document.getElementById("sfu").checked=false;
        document.getElementById("mdu").checked=false;
        document.getElementById("other").checked=false;
        document.getElementById("excludemapping").checked=false;
        
        document.getElementById("noknock").checked=false;
        document.getElementById("noanswer").checked=false;
        document.getElementById("doorhanger").checked=false;
        document.getElementById("contact").checked=false;
        document.getElementById("engage").checked=false;
        document.getElementById("discover").checked=false;
        document.getElementById("position").checked=false;
        document.getElementById("close").checked=false;
        document.getElementById("start").checked=false;
        document.getElementById("nma").checked=false;     
        
        document.getElementById("hot").checked=false;
        document.getElementById("cold").checked=false;   
              
        var predicateArray =[]
        component.set("v.PredicateArray",predicateArray);
        
        var addresses = helper.clearFilter(component,predicateArray,component.get("v.originalAddresses"));
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
    },
    
    // Creates Playlist on save
    createPlaylist : function(component, event, helper) {
        
        //Hide playlist pop-over
        $A.util.removeClass(component.find($A.get("$Label.c.PlanTypePlaylist")), 'slds-is-open');
        
        // Call apex method to create playlist and move addresses from turf to playlist
        var action = component.get("c.createPlaylistFromTurf");
        action.setParams({
            "addresses" : component.get("v.filteredAddresses"),
            "planId" : component.get("v.planId"),
            "playlistName" :  component.get("v.playlistName")         					
        });
        action.setCallback(this, function(a) {
            if(a.getState() === "SUCCESS"){
                var playlistId = a.getReturnValue();
                if(playlistId && playlistId.slice(0,3) == 'a0I'){ //set redirection to load playlist
                    //window.location.href = "/apex/AddressFiltering?id="+playlistId+"&sfdc.override=1";
                    var myURL = "/apex/AddressFiltering?id="+playlistId+"&sfdc.override=1";
                    if( (typeof sforce != 'undefined') && (sforce != null) ) {
                        // Salesforce1 navigation
                        sforce.one.navigateToURL(myURL);
                    } else {
                        // In Browser 
                        window.location.href = myURL;
                    }
                    
                    
                } else{
                    console.log("Error creating Playlist");
                }
            } 
        });
        $A.enqueueAction(action);        
    },
    
    //Search Addresses
    searchKeyChange : function(component, event, helper) {
        var searchKey = event.target.value
        var onturf = document.getElementById("onturf").checked;
        var offturf = document.getElementById("offturf").checked;
        var onOrOff, planId;

        if(onturf && offturf){
            onOrOff = "both";
            planId = component.get("v.planId");
        } else if(onturf == true &&  offturf == false){
            onOrOff = "on";
            planId = component.get("v.planId");
        } else if(onturf == false &&  offturf == true){
            onOrOff = "off";
            planId = null;
        } else{
            component.set("v.SearchResults",false);
        }
        if(onOrOff){
            if(searchKey.length > 4){ //Start searching only if search key length exceeds 4 chars
                
                component.set("v.SearchResults",true);
                $A.get("e.c:SearchKeyChange").setParams({"searchKey": searchKey,
                                                         "onOrOff" : onOrOff,
                                                         "planId"  : planId})
                                                         .fire();
            } else{
                component.set("v.SearchResults",false);
            }      
        } 
    },
    
    openSearchBox : function(component, event, helper) {       
        var searchbox= component.find("searchbox");
        $A.util.removeClass(searchbox, 'slds-combobox-lookup');
        $A.util.addClass(searchbox, 'slds-is-open');
       // document.getElementById('searchbox').setAttribute("aria-expanded", true);  
        $A.util.removeClass(component.find('playlist'), 'slds-is-open');
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');            
    },
    
    showWorkTypes: function (component, event, helper) {
        $A.util.toggleClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('wtdropdown'), 'showwt');
        $A.util.removeClass(component.find('apcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('csdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('tsdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dtdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('distdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('rejdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('dddropdown'), 'slds-dropdown');
		
    },
    
    filterByWorkType : function(component, event, helper) {
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
        $A.util.removeClass(component.find('worktype'), 'hide-initially'); //Un-Hide the worktype Filter Value
        
        var workType= event.currentTarget.dataset.wt;// Get the Worktype filter value
        component.set("v.workType",workType); //set the worktype to be displayed under filter type after applying
        
        var addresses=component.get("v.filteredAddresses");        
        var predicateArray = component.get("v.PredicateArray") || [];
        var bool;
        
        if(workType === 'Worked'){
            predicateArray.push({name : $A.get("$Label.c.WorkType"), type : "Single Select",value: $A.get("$Label.c.Worked")});    
            bool= true;
        }else{
            predicateArray.push({name : $A.get("$Label.c.WorkType"), type : "Single Select",value: $A.get("$Label.c.Not_Worked")});                
            bool = false;
        }            
        var filteredAddresses =  helper.applyFilter(component,addresses,function(currentAddress){
            return currentAddress.Worked__c == bool;
        });
       
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": filteredAddresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
    },
    
    clearWorkType : function(component, event, helper) {
        //Hide all the menu & submenues
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.toggleClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('wtdropdown'), 'showwt');
        $A.util.addClass(component.find('worktype'), 'hide-initially');   
        
        var predicateArray = component.get("v.PredicateArray");
        
        predicateArray = predicateArray.filter(function (predicate) {
            return predicate.name != $A.get("$Label.c.WorkType");
        });
        component.set("v.PredicateArray",predicateArray);
        
        //pass the copy of predicateArray by array.slice(0) otherwise it changes the modifies origianal array
        var addresses = helper.clearFilter(component,predicateArray.slice(0),component.get("v.originalAddresses"));
        console.log("Clear WorkType : "+ addresses.length);
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
    },
    
    showActiveProductsCount: function (component, event, helper) {
        $A.util.toggleClass(component.find('apcdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('apcdropdown'), 'showwt');
        $A.util.removeClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('csdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('tsdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dtdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('distdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('rejdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('dddropdown'), 'slds-dropdown');
    },
    
    filterByActiveProductsCount : function(component, event, helper) {
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
        $A.util.removeClass(component.find('apc'), 'hide-initially'); //Un-Hide APC Filter value
        
        var APC= event.currentTarget.dataset.apc;// Get the APC filter value
        component.set("v.activeProductsCount",APC); //set the APC to be displayed under filter type after applying
        
        var addresses=component.get("v.filteredAddresses");        
        var predicateArray = component.get("v.PredicateArray") || [];
        var filteredAddresses;
        if(APC === $A.get("$Label.c.One_Product")){
            predicateArray.push({name : $A.get("$Label.c.Active_Product_Count"), 
                                 type : "Single Select",
                                 value: $A.get("$Label.c.One_Product")}); 
            filteredAddresses = helper.applyFilter(component,addresses,function(currentAddress){
                return currentAddress.WA_Actives_1_Product__c == true;
            });  
        } else if(APC === $A.get("$Label.c.Two_Products")){
            predicateArray.push({name : $A.get("$Label.c.Active_Product_Count"), 
                                 type : "Single Select",
                                 value: $A.get("$Label.c.Two_Products")}); 
            filteredAddresses = helper.applyFilter(component,addresses,function(currentAddress){
                return currentAddress.WA_Actives_2_Product__c == true;
            });  
        } else if(APC === $A.get("$Label.c.Three_Products")){
            predicateArray.push({name : $A.get("$Label.c.Active_Product_Count"), 
                                 type : "Single Select",
                                 value: $A.get("$Label.c.Three_Products")}); 
            filteredAddresses = helper.applyFilter(component,addresses,function(currentAddress){
                return currentAddress.WA_Actives_3_Product__c == true;
            });  
        }       
      
        //Update AddressPane and Map Pane to show filtered addresses       		        
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": filteredAddresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();   
    },
    
    clearActiveProductsCount : function(component, event, helper) {
        //Hide all the menu & submenues
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.toggleClass(component.find('apcdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('apcdropdown'), 'showwt');
        $A.util.addClass(component.find('apc'), 'hide-initially');   
        
        var predicateArray = component.get("v.PredicateArray");             
        predicateArray = predicateArray.filter(function (predicate) {
            return predicate.name != $A.get("$Label.c.Active_Product_Count");
        });
        component.set("v.PredicateArray",predicateArray);
        
        //pass the copy of predicateArray by array.slice(0) otherwise it changes the modifies origianal array
        var addresses = helper.clearFilter(component,predicateArray.slice(0),component.get("v.originalAddresses"));
        
      
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire(); 
    },
    
    showMRC: function (component, event, helper) {
        $A.util.toggleClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('mrcdropdown'), 'showwt');
        $A.util.removeClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('csdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('tsdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dtdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('distdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('rejdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('dddropdown'), 'slds-dropdown');
    },
    
    filterByMRC : function(component, event, helper) {
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
        $A.util.removeClass(component.find('mrc'), 'hide-initially'); //Un-Hide the MRC filter value
        
        var MRC= event.currentTarget.dataset.mrc;// Get the MRC filter value
        component.set("v.MRC",MRC); //set the MRC to be displayed under filter type after applying
        var addresses=component.get("v.filteredAddresses");
        var predicateArray = component.get("v.PredicateArray") || [];
        var filteredAddresses;
        if(MRC === $A.get("$Label.c.Less_Than_125")){
            predicateArray.push({name : $A.get("$Label.c.Total_Montly_Rate"), 
                                 type : "Single Select",
                                 value: $A.get("$Label.c.Less_Than_125")}); 
            filteredAddresses = helper.applyFilter(component,addresses,function(currentAddress){
                return currentAddress.Total_Monthly_Rate__c < 125;
            });  
        } else if(MRC === $A.get("$Label.c.Greater_Than_150")){
            predicateArray.push({name : $A.get("$Label.c.Total_Montly_Rate"), 
                                 type : "Single Select",
                                 value: $A.get("$Label.c.Greater_Than_150")}); 
            filteredAddresses = helper.applyFilter(component,addresses,function(currentAddress){
                return currentAddress.Total_Monthly_Rate__c > 150;
            }); 
        }          
       
        
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": filteredAddresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
    },
    
    clearMRC : function(component, event, helper) {
        //Hide all the menu & submenues
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.toggleClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('mrcdropdown'), 'showwt');
        $A.util.addClass(component.find('mrc'), 'hide-initially');   
        
        var predicateArray = component.get("v.PredicateArray");        
        
        predicateArray = predicateArray.filter(function (predicate) {
            return predicate.name != $A.get("$Label.c.Total_Montly_Rate");
        });
        component.set("v.PredicateArray",predicateArray);
        
        //pass the copy of predicateArray by array.slice(0) otherwise it changes the modifies origianal array
        var addresses = helper.clearFilter(component,predicateArray.slice(0),component.get("v.originalAddresses"));
        
      
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();  
    },
    
    showActiveProducts: function (component, event, helper) {
        $A.util.toggleClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('apdropdown'), 'showwt');
        $A.util.removeClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('csdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('tsdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dtdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('distdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('rejdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('dddropdown'), 'slds-dropdown');
    },
    
    filterByActiveProduct : function (component, event, helper) {
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
        $A.util.removeClass(component.find('ap'), 'hide-initially'); //Hide the AP sub menu
        var addresses=component.get("v.filteredAddresses");
        var predicateArray = component.get("v.PredicateArray") || [];        
                
        predicateArray.push({name : "Active Products", 
                             type : "Multi Select",
                             value: "Video,Internet,Voice,XH"}); 
        
     

        var filteredAddresses = helper.filterByActiveProduct(component,addresses);
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": filteredAddresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
        
    },
    
    clearActiveProducts : function (component, event, helper) {
        //Hide all the menu & submenues
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.toggleClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('apdropdown'), 'showwt');
        $A.util.addClass(component.find('ap'), 'hide-initially');   
        
        document.getElementById("video").checked=false;
        document.getElementById("internet").checked=false;
        document.getElementById("voice").checked=false;
        document.getElementById("xh").checked=false;
        
        var predicateArray = component.get("v.PredicateArray");        
        
        predicateArray = predicateArray.filter(function (predicate) {
            return predicate.name != "Active Products";
        });
        component.set("v.PredicateArray",predicateArray);
        
        //pass the copy of predicateArray by array.slice(0) otherwise it changes the modifies origianal array
        var addresses = helper.clearFilter(component,predicateArray.slice(0),component.get("v.originalAddresses"));
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire(); 
    },
    
    showCustomerStatuses: function (component, event, helper) {
        $A.util.toggleClass(component.find('csdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('csdropdown'), 'showwt');
        $A.util.removeClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apcdropdown'), 'slds-dropdown');
    	$A.util.removeClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('tsdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dtdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('distdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('rejdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('dddropdown'), 'slds-dropdown');
    },
    
    filterByCustomerStatus : function (component, event, helper) {
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
        $A.util.removeClass(component.find('cs'), 'hide-initially'); //Hide the AP sub menu
		var addresses=component.get("v.filteredAddresses");
        var predicateArray = component.get("v.PredicateArray") || [];
        
        predicateArray.push({name : "Customer Status", 
                             type : "Multi Select",
                             value: "Active,Inactive" });
        var filteredAddresses = helper.filterByCustomerStatus(component,addresses);
       
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": filteredAddresses,
                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
        
    },
    
    clearCustomerStatuses : function (component, event, helper) {
    	//Hide all the menu & submenues
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.toggleClass(component.find('csdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('csdropdown'), 'showwt');
        $A.util.addClass(component.find('cs'), 'hide-initially');   
        
        document.getElementById("active").checked=false;
        document.getElementById("inactive").checked=false;
        
        var predicateArray = component.get("v.PredicateArray");        
        
        predicateArray = predicateArray.filter(function (predicate) {
            return predicate.name != "Customer Status";
        });
        component.set("v.PredicateArray",predicateArray);

        //pass the copy of predicateArray by array.slice(0) otherwise it changes the modifies origianal array
        var addresses = helper.clearFilter(component,predicateArray.slice(0),component.get("v.originalAddresses"));
        
      
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
    },    
    
    showDwellingTypes: function (component, event, helper) {
        $A.util.toggleClass(component.find('dtdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('dtdropdown'), 'showwt');
        $A.util.removeClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apcdropdown'), 'slds-dropdown');
    	$A.util.removeClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('tsdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('csdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('distdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('rejdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('dddropdown'), 'slds-dropdown');
    },
    
    filterByDwellingType : function (component, event, helper) {
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
        $A.util.removeClass(component.find('dt'), 'hide-initially'); //Hide the AP sub menu
		var addresses=component.get("v.filteredAddresses");
        var predicateArray = component.get("v.PredicateArray") || [];
        
        predicateArray.push({name : "Dwelling Type", 
                             type : "Multi Select",
                             value: "MDU,SFU" });
        var filteredAddresses = helper.filterByDwellingType(component,addresses);
        
       
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": filteredAddresses,
                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
        
    },
    
    clearDwellingType : function (component, event, helper) {
    	//Hide all the menu & submenues
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.toggleClass(component.find('dtdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('dtdropdown'), 'showwt');
        $A.util.addClass(component.find('dt'), 'hide-initially');   
        
        document.getElementById("bulkbilledmaster").checked=false;
        document.getElementById("bulkbilledmdu").checked=false;
        document.getElementById("commercial").checked=false;
        document.getElementById("multipledwellingunit").checked=false;
        document.getElementById("nonbulkbilled").checked=false;
        document.getElementById("nonbulkbilledmdu").checked=false;
        document.getElementById("singlefamily").checked=false;
        document.getElementById("singlefamilyunit").checked=false;
        document.getElementById("unknown").checked=false;
        document.getElementById("vacant").checked=false;
        document.getElementById("sfu").checked=false;
        document.getElementById("mdu").checked=false;
        document.getElementById("other").checked=false;
        document.getElementById("excludemapping").checked=false;
        
        var predicateArray = component.get("v.PredicateArray");        
        
        predicateArray = predicateArray.filter(function (predicate) {
            return predicate.name != "Dwelling Type";
        });
        component.set("v.PredicateArray",predicateArray);

        //pass the copy of predicateArray by array.slice(0) otherwise it changes the modifies origianal array
        var addresses = helper.clearFilter(component,predicateArray.slice(0),component.get("v.originalAddresses"));
        
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                    "originalAddresses": component.get("v.originalAddresses")}).fire(); 
    },
	
    showDispositions: function (component, event, helper) {
        $A.util.toggleClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('dispdropdown'), 'showwt');
        $A.util.removeClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apcdropdown'), 'slds-dropdown');
    	$A.util.removeClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('tsdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('csdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('distdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('rejdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('dddropdown'), 'slds-dropdown');
    },
    
    filterByDisposition : function (component, event, helper) {
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
        $A.util.removeClass(component.find('disp'), 'hide-initially'); //Hide the disp sub menu
		
        var addresses=component.get("v.filteredAddresses");
        var predicateArray = component.get("v.PredicateArray") || [];
        //console.log("OriginalAddresses : " + addresses.length);
        
        predicateArray.push({name : "Disposition", 
                             type : "Multi Select",
                             value: "Start,Engage,Discover,Contact" });
        var filteredAddresses = helper.filterByDisposition(component,addresses);
        
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": filteredAddresses,
                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
        
    },
    
    clearDisposition : function (component, event, helper) {
    	//Hide all the menu & submenues
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.toggleClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('dispdropdown'), 'showwt');
        $A.util.addClass(component.find('disp'), 'hide-initially');   
        
		document.getElementById("noknock").checked=false;
        document.getElementById("noanswer").checked=false;
        document.getElementById("doorhanger").checked=false;
        document.getElementById("contact").checked=false;
        document.getElementById("engage").checked=false;
        document.getElementById("discover").checked=false;
        document.getElementById("position").checked=false;
        document.getElementById("close").checked=false;
        document.getElementById("start").checked=false;
        document.getElementById("nma").checked=false;      
        
        var predicateArray = component.get("v.PredicateArray");        
        
        predicateArray = predicateArray.filter(function (predicate) {
            return predicate.name != "Disposition";
        });
        component.set("v.PredicateArray",predicateArray);

        //pass the copy of predicateArray by array.slice(0) otherwise it changes the modifies origianal array
        var addresses = helper.clearFilter(component,predicateArray.slice(0),component.get("v.originalAddresses"));
       
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                    "originalAddresses": component.get("v.originalAddresses")}).fire(); 
    },    

    showTapStatuses: function (component, event, helper) {
        $A.util.toggleClass(component.find('tsdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('tsdropdown'), 'showwt');
        $A.util.removeClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apcdropdown'), 'slds-dropdown');
    	$A.util.removeClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('csdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('distdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('rejdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('dddropdown'), 'slds-dropdown');
    },
    
    filterByTapStatus : function (component, event, helper) {
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
        $A.util.removeClass(component.find('ts'), 'hide-initially'); //Hide the AP sub menu

        var addresses=component.get("v.filteredAddresses");
        var predicateArray = component.get("v.PredicateArray") || [];
      
        predicateArray.push({name : "Tap Status", 
                             type : "Multi Select",
                             value: "HOT,COLD" });
        var filteredAddresses = helper.filterByTapStatus(component,addresses);
        
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": filteredAddresses,
                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
        
    },
    
    clearTapStatus : function (component, event, helper) {
    	//Hide all the menu & submenues
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.toggleClass(component.find('tsdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('tsdropdown'), 'showwt');
        $A.util.addClass(component.find('ts'), 'hide-initially');           
        
        document.getElementById("hot").checked=false;
        document.getElementById("cold").checked=false;
        
        var predicateArray = component.get("v.PredicateArray");        
        
        predicateArray = predicateArray.filter(function (predicate) {
            return predicate.name != "Tap Status";
        });
        component.set("v.PredicateArray",predicateArray);

        //pass the copy of predicateArray by array.slice(0) otherwise it changes the modifies origianal array
        var addresses = helper.clearFilter(component,predicateArray.slice(0),component.get("v.originalAddresses"));
        
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
    },
	//For current location
	getCurrentLoc:function(component, event, helper){
		$A.util.removeClass(component.find("CurrentLocation"), "slds-button_neutral");
        $A.util.addClass(component.find("CurrentLocation"), "slds-button_brand");
        $A.util.removeClass(component.find("Addresses"), "slds-button_brand");
        $A.util.addClass(component.find("Addresses"), "slds-button_neutral");
		$A.util.toggleClass(component.find('distdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('distdropdown'), 'showwt');
       	component.set("v.IsFilterByCurrentLocation",true);
	},
	
    //For Selected Address
	getSelectedAddress:function(component, event, helper){
		$A.util.removeClass(component.find("Addresses"), "slds-button_neutral");
        $A.util.addClass(component.find("Addresses"), "slds-button_brand");
        $A.util.removeClass(component.find("CurrentLocation"), "slds-button_brand");
        $A.util.addClass(component.find("CurrentLocation"), "slds-button_neutral");
		$A.util.toggleClass(component.find('distdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('distdropdown'), 'showwt');
        component.set("v.IsFilterByCurrentLocation",false);
	},
	
    //Get select address latitude and longitude from event
	callselectedAddressLatLongEvent:function(component, event, helper){
        var selectedAddressLatFromEvent = event.getParam("selectedAddressLat");
		var selectedAddressLongFromEvent = event.getParam("selectedAddressLong");
        component.set("v.selectedAddressLat",selectedAddressLatFromEvent);
        component.set("v.selectedAddressLong",selectedAddressLongFromEvent);
	},
	/*
    * @Description: US946437 - DSM to SF1: Filter by Disconnect Date
    * @Author: Siddharth Sinha (Accenture)
    * @Date: 13-July-2017 
    * @Param: showDisconnectedDate, clearDisconnectedDate, filterByDisconnectedDate functions
    * @Return: Filtered Addresses by Disconnect Date on SF1
    */
      showDisconnectedDate: function (component, event, helper) {
        $A.util.toggleClass(component.find('dddropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('dddropdown'), 'showwt');
        $A.util.removeClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('csdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('tsdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dtdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('distdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('rejdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
		
	 },	
	
	 clearDisconnectedDate : function(component, event, helper) {
        //Hide all the menu & sub-menues
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.toggleClass(component.find('dddropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('dddropdown'), 'showwt');
        $A.util.addClass(component.find('discdate'), 'hide-initially');   
        
        var predicateArray = component.get("v.PredicateArray");
        
        predicateArray = predicateArray.filter(function (predicate) {
             return predicate.name != $A.get("$Label.c.Disconnected_Date");
        });
        component.set("v.PredicateArray",predicateArray);
        
        //pass the copy of predicateArray by array.slice(0) otherwise it changes the modifies original array
        var addresses = helper.clearFilter(component,predicateArray.slice(0),component.get("v.originalAddresses"));
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
    },
    
	filterByDisconnectedDate : function(component, event, helper) {
		$A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
		$A.util.removeClass(component.find('discdate'), 'hide-initially'); //Un-Hide DIST Filter value
		var addresses=component.get("v.filteredAddresses");
		var DISCDATE= event.currentTarget.dataset.dd;// Get the filter value which user has selected
		component.set("v.disconnectedDate",DISCDATE);
        var predicateArray = component.get("v.PredicateArray") || [];
        predicateArray.push({name : "Disconnect Date", 
                             type : "Single Select",
                             value: DISCDATE});
        var filteredAddresses = helper.filterByDisconnectDate(component,addresses,DISCDATE);
        //Update AddressPane and Map Pane to show filtered addresses       		        
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": filteredAddresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();   		   
    },
    //Sid-Changes End            
	showDistance: function (component, event, helper) {
        $A.util.toggleClass(component.find('distdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('distdropdown'), 'showwt');
        $A.util.removeClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('apcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('csdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dtdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('tsdropdown'), 'slds-dropdown');	
		$A.util.removeClass(component.find('rejdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('dddropdown'), 'slds-dropdown');
    },
    
    filterByDistance : function(component, event, helper) {
		$A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
		$A.util.removeClass(component.find('dist'), 'hide-initially'); //Un-Hide DIST Filter value
		
        var DIST= event.currentTarget.dataset.dist;// Get the DIST filter value
		component.set("v.distance",DIST+" Miles");
		var addresses=component.get("v.filteredAddresses");
        var predicateArray = component.get("v.PredicateArray") || [];
				
        predicateArray.push({name : "Distance", 
                            type : "Single Select",
                            value: DIST}); 
							console.log('predicateArray'+predicateArray);
        filteredAddresses = helper.filterByDistance(component,addresses,DIST); 
        
        //Update AddressPane and Map Pane to show filtered addresses       		        
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": filteredAddresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();   		   
    },
    
	 clearDistance : function(component, event, helper) {
        //Hide all the menu & submenues
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.toggleClass(component.find('distdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('distdropdown'), 'showwt');
        $A.util.addClass(component.find('dist'), 'hide-initially');   
        
        var predicateArray = component.get("v.PredicateArray");
        
        predicateArray = predicateArray.filter(function (predicate) {
            return predicate.name != "Distance";
        });
        component.set("v.PredicateArray",predicateArray);
        
        //pass the copy of predicateArray by array.slice(0) otherwise it changes the modifies origianal array
        var addresses = helper.clearFilter(component,predicateArray.slice(0),component.get("v.originalAddresses"));
        
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
    },
	showRejectedAddress: function (component, event, helper) {
        $A.util.toggleClass(component.find('rejdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('rejdropdown'), 'showwt');
        $A.util.removeClass(component.find('wtdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('mrcdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('apcdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('apdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('csdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dispdropdown'), 'slds-dropdown');
        $A.util.removeClass(component.find('dtdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('tsdropdown'), 'slds-dropdown');	
		$A.util.removeClass(component.find('distdropdown'), 'slds-dropdown');
		//$A.util.removeClass(component.find('yesdropdown'), 'slds-dropdown');
		$A.util.removeClass(component.find('dddropdown'), 'slds-dropdown');
    },
	showYesOrNo: function (component, event, helper) {
		$A.util.toggleClass(component.find('yesdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('yesdropdown'), 'showwt');
       
	},
	filterYes : function (component, event, helper) {
        console.log('in rej');
		$A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
		$A.util.removeClass(component.find('rejId'), 'hide-initially');
        var REJECTED= event.currentTarget.dataset.rej;// Get the DIST filter value
		console.log('rejected'+event.currentTarget.dataset.rej);
		component.set("v.rejected",REJECTED);
		var addresses=component.get("v.filteredAddresses");
        var predicateArray = component.get("v.PredicateArray") || [];
			
        predicateArray.push({name : "Rejected Addresses", 
                                 type : "Single Select",
                                 value: REJECTED}); 
            helper.getRejectedAddresses(component,addresses); 
		
    },
	
	filterByRejectedAddress : function(component, event, helper) {
	
		$A.util.removeClass(component.find('dropdown'), 'slds-is-open');//Hide the filter drop down
		$A.util.removeClass(component.find('rejId'), 'hide-initially');
        var REJECTED= event.currentTarget.dataset.rej;// Get the DIST filter value
		component.set("v.rejected",REJECTED);
		var addresses=component.get("v.filteredAddresses");
        var predicateArray = component.get("v.PredicateArray") || [];
			 predicateArray.push({name : "Rejected Addresses", type : "Single Select",value: REJECTED}); 
			 console.log('predicateArray'+predicateArray);
			var filteredAddresses =  helper.applyFilter(component,addresses,function(currentAddress){
				return (currentAddress.Rejected_Reason__c ===  undefined || currentAddress.Rejected_Reason__c === null);				
			});
			
			
			$A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": filteredAddresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();  
		
			   
		},
 
	clearRejAddrss : function(component, event, helper) {
    	//Hide all the menu & submenues
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
        $A.util.toggleClass(component.find('rejdropdown'), 'slds-dropdown');
        $A.util.toggleClass(component.find('rejdropdown'), 'showwt');
        $A.util.addClass(component.find('rejId'), 'hide-initially');   
        
        var predicateArray = component.get("v.PredicateArray");
        
        predicateArray = predicateArray.filter(function (predicate) {
            return predicate.name != "Rejected Addresses";
        });
        component.set("v.PredicateArray",predicateArray);
        
        //pass the copy of predicateArray by array.slice(0) otherwise it changes the modifies origianal array
        var addresses = helper.clearFilter(component,predicateArray.slice(0),component.get("v.originalAddresses"));
        
        //Update AddressPane and Map Pane to show filtered addresses
        $A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addresses,
                                                                    "originalAddresses": component.get("v.originalAddresses")}).fire();
    },
})