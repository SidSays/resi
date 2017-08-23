({ 
    getYear: function()
    {
        var d1 = new Date();
        var y = d1.getYear();
        return y;
    },
    
     getMonth: function(number)
    {
        var d1 = new Date();        
        d1.setDate(d1.getDate() - number);        
        var d1M = d1.getMonth();    
        return d1M;
    },
    
    getADate: function(number)
    {
        var d1 = new Date();
        d1.setDate(d1.getDate() - number);
        var newDate =  d1.getDate();        
        return newDate;
    },
    getChartData: function(component){
    Highcharts.setOptions({
  		global: {
    	useUTC: false
  			}
		});    
    var chart = new Highcharts.StockChart({
            chart: {
                renderTo: component.find("chart").getElement(),
                type: 'bar',
                pinchType: 'none'
            },
			rangeSelector: {
                 	selected: 4,
                    inputEnabled: false,
                    buttonTheme: {
                        visibility: 'hidden'
                    },
                    labelStyle: {
                        visibility: 'hidden'
                    }
            },
        	tooltip: {
    				formatter: function () {
            		return false;
            			}
					
            },
        	legend: {
                enabled: true,
                align: 'right',
                //backgroundColor: '#FCFFC5',
                borderColor: 'black',
                borderWidth: 2,
                layout: 'vertical',
                verticalAlign: 'top',
                floating: true,
                
                shadow: true
        	},

            title: {
               // text: 'Orders and Activations for past 7 days'
            },
             xAxis: {  
                        type: 'datetime',
            		dateTimeLabelFormats: {
                		month: '%e. %b',
                        day: '%b %e',
                        hour: '%b %e',
                        year: '%b'  
                    },
                 labels: {
                    formatter: function() {
                      return moment(this.value).format("MM/DD");
                    		}
      					},
                 tickInterval: 24 * 3600 * 1000
                
            },                    
            yAxis: {
                 min: 0,
                minTickInterval: 1,
          /* labels: {
                overflow: 'justify'
            },*/
            title: {
                text: ''
            },
                       
                
            },
       		 navigator : {
                enabled : false
            },
        	scrollbar : {
                enabled : false
            },
        	/*plotOptions: {
            bar: {
                dataLabels: {
                    enabled: true
                			}
            	}
        	},*/
       		exporting: {
         		enabled: false
			},
        	credits: {
      			enabled: false
  			},
            series: [{
               name: 'RGU Orders',
            data: [	component.get("v.PastSevenDaysChart.SeventhDayOrderCount"),
                	component.get("v.PastSevenDaysChart.SixthDayOrderCount"),
                	component.get("v.PastSevenDaysChart.FifthDayOrderCount"),
                    component.get("v.PastSevenDaysChart.FourthDayOrderCount"),
                    component.get("v.PastSevenDaysChart.ThirdDayOrderCount"),
                    component.get("v.PastSevenDaysChart.SecondDayOrderCount"),
                    component.get("v.PastSevenDaysChart.FirstDayOrderCount")
                	],
               	pointStart: Date.UTC(2016, this.getMonth(7), this.getADate(7)),
            	pointInterval: 24 * 3600 * 1000
            }, {
                 name: 'Activations',
            	data: [component.get("v.PastSevenDaysChart.SeventhDayActivationCount"),
                        component.get("v.PastSevenDaysChart.SixthDayActivationCount"),
                        component.get("v.PastSevenDaysChart.FifthDayActivationCount"),
                        component.get("v.PastSevenDaysChart.FourthDayActivationCount"),
                        component.get("v.PastSevenDaysChart.ThirdDayActivationCount"),
                        component.get("v.PastSevenDaysChart.SecondDayActivationCount"),
                        component.get("v.PastSevenDaysChart.FirstDayActivationCount")          
            		],
                pointStart: Date.UTC(2016, this.getMonth(7), this.getADate(7)),
            	pointInterval: 24 * 3600 * 1000
            	},
                    ]
        	});
    	},  
})