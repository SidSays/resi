({
	setClock : function(component) {
        //get time remaining (ms) from component attr set during construction in SLA_Indicator.page
        var remaining = component.get("v.remaining");

        if(remaining != null)
        {
            //update remaining time, subtract one second
            component.set("v.remaining",  remaining -1000);

            //convert toal ms remaining to hours, min, sec
            x = remaining /1000;
            seconds = x % 60;

            x /= 60
            minutes = x % 60

            x /= 60
            hours = x % 24

            x /= 24
            days = x
            
            // create dispaly string and set on component
            time = "";

            if(remaining > 0)
            {
                if(parseInt(days) > 0)
                {
                    time += parseInt(days)+ " d ";
                }
                if(parseInt(hours) >= 0)
                {
                    time += parseInt(hours)+ " h ";
                }
                
                if(parseInt(minutes) >= 0)
                {
                    time += parseInt(minutes) + " m ";
                }                
                time += " remaining";
            }else
            {
                if(parseInt(days) < 0)
                {
                    time += (parseInt(days) *-1)+ " d ";
                }
                if(parseInt(hours) <= 0)
                {
                    time += (parseInt(hours) *-1)+ " h ";
                }
                
                if(parseInt(minutes) <= 0)
                {
                    time += (parseInt(minutes) *-1) + " m ";
                }
                time += " overdue";
            }

            var redBoundary = 3600000; // in ms
            var yellowBoundary = 60000; // in ms
            if(remaining > redBoundary){
              document.body.style.cssText = 'background-color:#04844b !important';                
            }else if(remaining < redBoundary && remaining > yellowBoundary){
              document.body.style.cssText = 'background-color:#D0B049 !important';
            }else{
              document.body.style.cssText = 'background-color:#c23934 !important';
            }

        }
        else
        {
            time = "No SLA due";
            var cmpTarget = component.find('timeString');
            $A.util.removeClass(cmpTarget, 'timeString');
            $A.util.addClass(cmpTarget, 'noSLA');



        }
        
        component.set("v.time",  time);
	}
})