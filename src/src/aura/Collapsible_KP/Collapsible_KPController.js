({
    redirectToMyInfoQuest : function(component, event, helper) {
        window.open('https://apex.infoquest.tv/Account/LogOn','_blank');
	},
	redirectToOrderLab : function(component, event, helper) {
        window.open('https://www.salesspace.comcast.com/orderlab/#home','_blank');
	},
    redirectToComcastNow : function(component, event, helper) {
        window.open('https://www.comcastnow.com','_blank');
	},
    
    redirectToObservation : function(component, event, helper) {
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            //"url": "/apex/ObservationForm"
            "url": "https://onecomcast--devpro1--c.cs14.visual.force.com/apex/ObservationFormKP"
            });
        urlEvent.fire();*/
        
        var url = "https://onecomcast--devpro1--c.cs14.visual.force.com/apex/ObservationFormKP";
        window.location.assign(url);
    },
    
    toggleParent : function(component, event, helper) {      
        var mainDivTag = component.find("mainDiv");
        var arrowButton = component.find("arrowButton");
        var isOpen = $A.util.hasClass(mainDivTag, "slds-is-open");
        if(isOpen){
            $A.util.removeClass(mainDivTag, "slds-is-open");
            $A.util.addClass(mainDivTag, "slds-is-closed"); 
            
            $A.util.removeClass(arrowButton, "slds-is-open");
            $A.util.addClass(arrowButton, "slds-is-closed"); 
             
        }else{
            $A.util.addClass(mainDivTag, "slds-is-open");
            $A.util.removeClass(mainDivTag, "slds-is-closed");
            
            $A.util.addClass(arrowButton, "slds-is-open");
            $A.util.removeClass(arrowButton, "slds-is-closed");
        }
        
        var myEvent = component.getEvent("toggleClick");
    	myEvent.fire();
    },
    
    handleSelectionChanged: function(component, event, helper) {
        var params = event.getParams();
        var payload = params.payload;
        var repList = [];
        if (payload) {
          //var step = payload.step;
          var data = payload.data;
          data.forEach(function(obj) {
            for (var k in obj) {
              if (k === 'NAME_PERNR') {
                  var formatName = obj[k];
                  var index = formatName.lastIndexOf('[');
                  repList.push(formatName.substring(0, index).replace(',', ''));   
                  component.set("v.repList", repList);
              }
            }
          });        	
        }        
  	}
})