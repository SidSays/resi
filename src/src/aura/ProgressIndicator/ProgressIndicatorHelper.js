({
    barChart: function (percentage, status, width, height, x, y) {
        var svgns = "http://www.w3.org/2000/svg";

        var backgroundColor = "#d0d0d0";
        var strokeColor = "#A7B8D1";
        var greenColor = "#04844b";
        var yellowColor = "#ffb75d";
        var redColor = "#c23934"; 

        //create svg container
        var chart = document.createElementNS(svgns, "svg:svg");
        chart.setAttribute("width", width);
        chart.setAttribute("height", height);
        chart.setAttribute("viewBox", x + " " + y + " " + width + " " + height);
        
        // Background rectangle
        var back = document.createElementNS(svgns, "rect");
        back.setAttributeNS(null, "x", x);
        back.setAttributeNS(null, "y", y);
        back.setAttributeNS(null, "width", width);
        back.setAttributeNS(null, "height", height);
        back.setAttributeNS(null, "stroke-width", 1);
        back.setAttributeNS(null, "stroke", strokeColor);
        back.setAttributeNS(null, "fill", backgroundColor);
        chart.appendChild(back);
        
        // creates progress rect
        var progressWidth = ((percentage * width)/100);
        var progress = document.createElementNS(svgns, "rect");
        progress.setAttributeNS(null, "x", x);
        progress.setAttributeNS(null, "y", y);
        progress.setAttributeNS(null, "width", progressWidth);
        progress.setAttributeNS(null, "height", height);
        progress.setAttributeNS(null, "fill", greenColor);

        //set animiation left to right
        var animateScale = document.createElementNS(svgns, "animate");
        animateScale.setAttributeNS(null, "attributeName", "width");
        animateScale.setAttributeNS(null, "from", "0");
        animateScale.setAttributeNS(null, "to", progressWidth);
        animateScale.setAttributeNS(null, "begin", "0s");
        animateScale.setAttributeNS(null, "dur", "2s");
        progress.appendChild(animateScale);

        //animate green to yellow
        var animateGreenToYellow = document.createElementNS(svgns, "animate");
        animateGreenToYellow.setAttributeNS(null, "attributeName", "fill");
        animateGreenToYellow.setAttributeNS(null, "id", "greenToYellow");
        animateGreenToYellow.setAttributeNS(null, "fill", "freeze");
        animateGreenToYellow.setAttributeNS(null, "from", greenColor);
        animateGreenToYellow.setAttributeNS(null, "to", yellowColor);
        animateGreenToYellow.setAttributeNS(null, "dur", "1s");

        //animate yellow to red
        var animateYellowToRed = document.createElementNS(svgns, "animate");
        animateYellowToRed.setAttributeNS(null, "attributeName", "fill");
        animateYellowToRed.setAttributeNS(null, "begin", "greenToYellow.end");
        animateYellowToRed.setAttributeNS(null, "fill", "freeze");
        animateYellowToRed.setAttributeNS(null, "to", redColor);
        animateYellowToRed.setAttributeNS(null, "dur", "1s");

        
        if(status == "yellow")
        {
            progress.appendChild(animateGreenToYellow);
        }
        else if(status == "red")
        {
            progress.appendChild(animateGreenToYellow);
            progress.appendChild(animateYellowToRed);    
        }
 
        chart.appendChild(progress);


        // var data = document.createTextNode(text);
        // var text = document.createElementNS(svgns, "text");
        // text.setAttributeNS(null, "x", width / 2);
        // text.setAttributeNS(null, "y", 0.55 * height);
        // text.setAttributeNS(null, "fill", "black");
        // text.setAttributeNS(null, "text-anchor", "middle");
        // text.appendChild(data);
        // chart.appendChild(text);

        return chart;
    }
})