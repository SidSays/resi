({
    //37.773972, -122.431297 San
    //39.9523300, -75.1637900 Phila
	helperjsloaded : function(component, event) {
		
        setTimeout(function() {
            var map = L.map('map',{zoomcontrol : false}).setView([37.773972, -122.431297], 14);
            L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                {
                    attribution: ''
                }).addTo(map);
            component.set("v.map", map);
        });
	},
    
    
})