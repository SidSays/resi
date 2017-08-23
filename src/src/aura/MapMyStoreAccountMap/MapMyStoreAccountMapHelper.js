({
    //37.773972, -122.431297 San
    //39.9523300, -75.1637900 Phila
	helperjsloaded : function(component, event, helper) {
		//component.rerender();
        setTimeout(function() {
            var tileLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                {
                    attribution: ''
                });
             
            var map = L.map('map', {
                zoomControl: false,
                layer : tileLayer
            }).setView([37.773972, -122.431297], 14);
            
            component.set("v.map", map);
            //console.log('jsloaded map'+map);
        });
	},
       
    
})