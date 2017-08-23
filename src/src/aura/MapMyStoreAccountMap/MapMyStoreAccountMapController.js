({
    doInit : function(component, event, helper){
        component.set("v.redLegend",'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-red.png');
        component.set("v.yellowLegend",'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-yellow.png');
        component.set("v.orangeLegend",'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-orange.png');
    },
    
    jsLoaded: function(component, event, helper) {
        var tile;
        // helper.helperjsloaded(component, event, helper);
        //setTimeout(function() {
            var map = L.map('map', {zoomControl: false}).setView([37.773972, -122.431297], 14);
            tile = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                        {
                            attribution: ''
                        }).addTo(map);
            component.set("v.map", map);
            
        //});
        var markersLayer = new L.LayerGroup();      
        component.set("v.markerLayerGroup",markersLayer);
    },
    
    accountsLoaded: function(component, event, helper) {		
        // Add markers
        var greenIcon = new L.Icon({
            iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-green.png',
            shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
            iconSize: [25, 41],
            iconAnchor: [12, 41],
            popupAnchor: [1, -34],
            shadowSize: [41, 41]
        });
        var map = component.get('v.map');
        var accounts = event.getParam('accounts');
        for (var i=0; i<accounts.length; i++) {
            var account = accounts[i];
            var latLng = [account.Store_Location__Latitude__s, account.Store_Location__Longitude__s];
            L.marker(latLng, {account: account, icon: greenIcon}).addTo(map);
        }  
    },
    
    addressesLoaded: function(component, event, helper) {
        var map = component.get('v.map');
        var addresses = event.getParam('addresses');
        for (var i=0; i<addresses.length; i++) {
            var address = addresses[i];
            var latLng = [address.Latitude__c, address.Longitude__c];
            L.marker(latLng, {Customer_Address__c: address}).addTo(map)
            .bindPopup(address.Name)
            .openPopup();
        }  
    },
    
    propertyAndPropertVisit: function(component, event, helper) {      
        /*  var map = component.get("v.map");
        var propertyData = event.getParam('propertyData');
        var properties = propertyData.properties;
        var propVisits = propertyData.propVisits;
        for (var i=0; i<properties.length; i++) {
            var property = properties[i];
            var latLng = [property.Property_Location__Latitude__s,
                          property.Property_Location__Longitude__s];
            L.marker(latLng, {MDU_Property__c: property}).addTo(map)
            .bindPopup(property.Name)
            .openPopup();
        }  
          for (var i=0; i<propVisits.length; i++) {
            var propVisit = propVisits[i];
             console.log('propVisit lat'+ propVisit.Visit_Location__Latitude__s);
           // console.log('addresses longi'+ address.Longitude__c);
            var latLng = [propVisit.Visit_Location__Latitude__s,
                          propVisit.Visit_Location__Longitude__s];
            L.marker(latLng, {Property_Visit__c: propVisit}).addTo(map)
            .bindPopup(propVisit.Name)
            .openPopup();
        } */
    },   
    
    carMapView : function(component, event, helper){
        //var markersLayer = new L.LayerGroup();
        var user = event.getParam("user");
        var userArray = user.split("/");
        var viewType = event.getParam("viewType");
        component.set("v.viewType", viewType);
        var fromDate = event.getParam("fromDate");       
        var toDate = event.getParam("toDate");
        if(viewType == 'CAR Activity locations'){
            
            var markersLayer = component.get("v.markerLayerGroup");
            if(markersLayer){ 
                markersLayer.clearLayers();
            }
            var action = component.get("c.getProperyData");
            action.setParams({
                "selectedRep": userArray[1],
                "createdDate": fromDate,
                "endDate" : toDate
            });
            action.setCallback(this, function(a){
                
                // to update the list shown below the map
                var appEvent = $A.get("e.c:CARMapViewCARlocationData");       
                appEvent.setParams({                
                    "propertyData" : a.getReturnValue()                
                });
                appEvent.fire();
                
                var carmapViewLocation = a.getReturnValue();                               
                var visit = carmapViewLocation.propVisits;
                component.set("v.CARstartActivityLocation", visit[0]);
                component.set("v.CARendActivityLocation",visit[visit.length -1]);
                var starVisit = carmapViewLocation.starPropVisits;                
                var withoutStarPropVisits = carmapViewLocation.withoutStarPropVisits;
                
                var map = component.get('v.map');
                
                var orangeIcon = new L.Icon({
                    iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-orange.png',
                    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
                    iconSize: [25, 41],
                    iconAnchor: [12, 41],
                    popupAnchor: [1, -34],
                    shadowSize: [41, 41]
                });
                
                
                var yellowIcon = new L.Icon({
                    iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-yellow.png',
                    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
                    iconSize: [25, 41],
                    iconAnchor: [12, 41],
                    popupAnchor: [1, -34],
                    shadowSize: [41, 41]
                });
                var redIcon = new L.Icon({
                    iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
                    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
                    iconSize: [25, 41],
                    iconAnchor: [12, 41],
                    popupAnchor: [1, -34],
                    shadowSize: [41, 41]
                });
                
                //for star visits
                for (var i=0; i<starVisit.length; i++) {
                    var loc = starVisit[i];
                    var latLng = [loc.Visit_Location__Latitude__s, loc.Visit_Location__Longitude__s];
                    var marker = L.marker(latLng,{Property_Visit__c: loc,icon: orangeIcon})
                    .bindPopup(''+ '<b>Property Name:</b> '+'<a href=\"/'+loc.Property__c+'\" target=\"_blank\">'+loc.Property__r.Name+'</a>')
                    .openPopup();
                    markersLayer.addLayer(marker); 
                   map.panTo(latLng);                
                }
                markersLayer.addTo(map); 
                
                //for without star visits
                for (var i=0; i<withoutStarPropVisits.length; i++) {
                    var loc = withoutStarPropVisits[i];
                    var latLng = [loc.Visit_Location__Latitude__s, loc.Visit_Location__Longitude__s];
                   var marker = L.marker(latLng,{Property_Visit__c: loc,icon: yellowIcon})
                    .bindPopup(''+ '<b>Property Name:</b> '+'<a href=\"/'+loc.Property__c+'\" target=\"_blank\">'+loc.Property__r.Name+'</a>'+'<br>'+
                               '<b>Start Time:</b> '+
                               (loc.Start_Date_Time__c).substring(11,13)+':'+
                               (loc.Start_Date_Time__c).substring(14,16)+'<br>'+
                               '<b>End Time:</b> '+ (loc.End_Date_Time__c).substring(11,13)+':'+
                               (loc.End_Date_Time__c).substring(14,16)+'<br>'+                               
                               '<b>Time Spent:</b>(mm:ss) '+loc.Time_Spent__c)
                    .openPopup();
                   markersLayer.addLayer(marker);
                    map.panTo(latLng);
                }
               markersLayer.addTo(map); 
                
                //for prop without exact visit.
                for (var i=0; i<withoutStarPropVisits.length; i++) {
                    var loc = withoutStarPropVisits[i];
                    var latLng = [loc.Property__r.Property_Location__Latitude__s,
                                  loc.Property__r.Property_Location__Longitude__s];
                    //var propertyId = loc.Id;
                    //var url = 'https://onecomcast--devpro2--c.cs26.visual.force.com'+'\/'+ propertyId;
                    //console.log('## URL : ' + url);
                  var marker = L.marker(latLng,{Property_Visit__c: loc,icon: redIcon})
                    .bindPopup(''+ '<b>Property Name:</b> '+'<a href=\"/'+loc.Property__c+'\" target=\"_blank\">'+loc.Property__r.Name+'</a>')
                    .openPopup();
                   markersLayer.addLayer(marker);
                    map.panTo(latLng);
                } 
                markersLayer.addTo(map); 
            });
            $A.enqueueAction(action);
            
            
        }  
        else if(viewType == 'Last reported location today'){
            var markersLayer = component.get("v.markerLayerGroup");
            if(markersLayer){
                markersLayer.clearLayers();
            }
            var action1 = component.get("c.lastReportedData");
            action1.setParams({
                "selectedRep": userArray[1]
            });
            action1.setCallback(this, function(a){
                var todayLocation = a.getReturnValue();
                var redIcon = new L.Icon({
                    iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
                    shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
                    iconSize: [25, 41],
                    iconAnchor: [12, 41],
                    popupAnchor: [1, -34],
                    shadowSize: [41, 41]
                });  
                
                var map = component.get('v.map');               
                for (var i=0; i<todayLocation.length; i++) {
                    var loc = todayLocation[i];
                    var ps = loc.Timestamp__c;
                    //var startTime = moment(ps).format("HH:mm");
                    component.set("v.lastLocationCoordinates",loc.Latitude__c+"/"+loc.Longitude__c);
                    component.set("v.lastLocationTime",ps);
                    var latLng = [loc.Latitude__c, loc.Longitude__c];
                    var marker = L.marker(latLng,{Location__c: loc, icon:redIcon})
                    .bindPopup(''+ userArray[0]+'<br>'+ loc.Latitude__c + ','+ loc.Longitude__c +'<br>'
                               +(loc.Geocode_TimeStamp__c).substring(5,7)+'/'
                               +(loc.Geocode_TimeStamp__c).substring(8,10)+'/'
                               +(loc.Geocode_TimeStamp__c).substring(0,4)
                               +' '+loc.Timestamp__c)
                    .openPopup();
                    markersLayer.addLayer(marker);
                    map.panTo(latLng);
                } 
                markersLayer.addTo(map);
            });
            $A.enqueueAction(action1);
        }
        
            else if(viewType == 'Daily location history'){  
                var map = component.get('v.map');
                var markersLayer = component.get("v.markerLayerGroup");
                if(markersLayer){
                    markersLayer.clearLayers();
                }                
                var action1 = component.get("c.dailyLocation");
                action1.setParams({
                    "selectedRep": userArray[1],
                    "createdDate" : fromDate
                });
                action1.setCallback(this, function(a){
                    var dailyLocation = a.getReturnValue();                   
                    var redIcon = new L.Icon({
                        iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-2x-red.png',
                        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
                        iconSize: [25, 41],
                        iconAnchor: [12, 41],
                        popupAnchor: [1, -34],
                        shadowSize: [41, 41]
                    });               
                    
                    component.set("v.dailyLocationItems", dailyLocation);
                    component.set("v.endDailyLocation", dailyLocation[dailyLocation.length - 1]);
                    for (var i=0; i<dailyLocation.length; i++) {
                        var loc = dailyLocation[i];
                        var latLng = [loc.Latitude__c, loc.Longitude__c];
                                      
                        var marker = L.marker(latLng,{Location__c: loc, icon:redIcon})
                        .bindPopup(''+ userArray[0]+'<br>'+ loc.Latitude__c + ','+ loc.Longitude__c +'<br>'
                                   +(loc.Geocode_TimeStamp__c).substring(5,7)+'/'
                                   +(loc.Geocode_TimeStamp__c).substring(8,10)+'/'
                                   +(loc.Geocode_TimeStamp__c).substring(0,4)
                                   +' '+loc.Timestamp__c)
                        .openPopup();   
                        markersLayer.addLayer(marker);
                        map.panTo(latLng);
                    }  
                     markersLayer.addTo(map);
                });
                $A.enqueueAction(action1);
            }             
    }
    
})