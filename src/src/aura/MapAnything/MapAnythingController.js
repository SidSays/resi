({
    
    jsLoaded: function(component, event, helper) {
        helper.helperjsloaded(component, event);
        var markersLayer = new L.LayerGroup();
        component.set("v.markerLayerGroup",markersLayer);  
    },
    
    /*
     * Modified: Radhika Bansal - 8/22/2017- US1156825 DSM to SF1: Tooltip on Address Selection 
     */
    addressesLoaded: function(component, event) {
        
        // For getting the first marker
        var marker1;
        // For Adding markers
        var markerArray = [];
        var map = component.get('v.map');
        /*Start Added by Radhika Bansal for US728543*/
        map.locate({setView: false, maxZoom: 15});
        map.on('locationfound', function onLocationFound(e) {
            // create a marker at the users current location "latlng" and add it to the map
            L.circleMarker(e.latlng).addTo(map);
        });        
        /*End Added by Radhika Bansal for US728543*/
        var markersLayer = component.get("v.markerLayerGroup");
        if(markersLayer){ 
            markersLayer.clearLayers();
        }
        
        var startMarkerLocation;
        var addresses = event.getParam('filteredAddresses');  
        
        if(addresses != undefined){
            for (var i=0; i<addresses.length; i++) {
                var address = addresses[i];
                startMarkerLocation =  [addresses[0].Latitude__c, addresses[0].Longitude__c];
                var latLng = [address.Latitude__c||null, address.Longitude__c||null];
                var video;
                var HSI;
                var voice;
                var XH;
                var active_inactive;
                if(address.Video_Active1__c){
                    video = $A.get('$Resource.Tooltip_images')+'/IconVideo.png';
                }else{
                    video = $A.get('$Resource.Tooltip_images')+'/IconVideoDisabled.png';
                }
                if(address.HSI_Active1__c){
                    HSI = $A.get('$Resource.Tooltip_images')+'/IconInternet.png';
                }else{
                    HSI = $A.get('$Resource.Tooltip_images')+'/IconInternetDisabled.png';	              
                }  
                if(address.Voice_Active1__c){
                    voice = $A.get('$Resource.Tooltip_images')+'/IconVoice.png';
                }else{
                    voice = $A.get('$Resource.Tooltip_images')+'/IconVoiceDisabled.png';	              
                }             
                if(address.XH_Active1__c){
                    XH = $A.get('$Resource.Tooltip_images')+'/IconXh.png';
                }else{
                    XH = $A.get('$Resource.Tooltip_images')+'/IconXhDisabled.png';	              
                }
                
                if(address.FormulaTapStatus__c === 'HOT'){                
                    active_inactive = $A.get('$Resource.Tooltip_images')+'/IconPlugActive.png';
                }else{                
                    active_inactive = $A.get('$Resource.Tooltip_images')+'/IconPlugInactive_gray.png';	              
                }
                
                if(address.Customer_Name__c == undefined){
                    address.Customer_Name__c= ''; 
                }
                var popupString =''+'<span>'+address.Name+'' +'</span><span class=\"slds-float--right\">'+address.Active_Inactive__c+'</span>'+'<br>'+
                    address.City__c+' '+ address.State__c+' '+address.PostalCode__c+'<br>'+"<div style=\"width: 100%;\">"+
                    "<span>"+address.Customer_Name__c+
                    "</span><span class=\"slds-float--right\">"+address.Dwelling_Type__c+'</span></div><br>'+
                    "<img src=" + video+">"+
                    "<img src=" + HSI+">"+
                    "<img src=" + voice+">"+
                    "<img src=" + XH+">"+
                    "<img src=" + active_inactive+">"+ 
                    "<a class=\"slds-badge slds-float--right\" style=\"margin-top:2%;\"" +
                    " onclick=\"sforce.one.navigateToSObject('"+ address.Id +"','detail')\">Details</a>";
                var marker = L.marker(latLng, {Customer_Address__c: address})            
                .bindPopup(popupString);
                
                // To add all values to marker array for opening tooltip of selected record.
                markerArray.push(marker);
                
                // For opening the tooltip of first selected record
                if(marker1 == undefined){
                    marker1 = marker;
                }
                markersLayer.addLayer(marker);                 
            }
            
        } 
        if(startMarkerLocation){ 
            map.panTo(startMarkerLocation);
            map.setZoom(18);
        }
        map.addLayer(markersLayer);     
        marker1.openPopup();
        component.set("v.markerArray", markerArray);
    },
    
    /*CreatedDate: 14-June-2017
     * CreatedBy: Radhika Bansal
     * Requirement: US1099096 DSM to SF1: Default Address and Selecting Addresses on AddressFiltering
     * Modified: Radhika Bansal - 8/22/2017- US1156825 DSM to SF1: Tooltip on Address Selection 
     */
    callPointMarker:function(component, event, helper){
        var markerToPopUp;
        
        // Get array of all the markers
        var markerArray = component.get("v.markerArray");
        var map = component.get('v.map');  
        
        //Get the params values of selected record
        var addressLat = event.getParam("selectedAddressLat");
        var addressLongi = event.getParam("selectedAddressLong");
        var location = [addressLat, addressLongi];       
        
        //To find out the selected marker for showing the tooltip on it.
        for (var i=0; i<markerArray.length; i++) {
            if(markerArray[i]._latlng.lat == addressLat && markerArray[i]._latlng.lng == addressLongi){
                markerToPopUp = markerArray[i];
                break;
            }
        }
        
        // Code to open popup of the specified marker
        if(markerToPopUp != undefined){
        	markerToPopUp.openPopup();
        }
        map.setZoom(18);
        map.panTo(location);
    }
    
})