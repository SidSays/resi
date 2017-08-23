({
	
    applyFilter : function (component, collection, predicate){
        var result = [];        
        for(var j = 0; j < collection.length; j++){
            if(predicate(collection[j])){                
                result.push(collection[j]);
            }
        }            
        return result;            	
    },
    
    //This method recursive the apply each filter (predicate) present in "Predicate Array"
    clearFilter : function (component, predicateArray,addresses){    	
        	// Set the default Chevron
        	if($('.sort-icon').hasClass('desc')){
        	$('.sort-icon').removeClass('desc').addClass('asc');
        	}; 
        	$(".sort-item").removeClass('selected asc desc');
        	// Update the PlanInfo component to reset by default sort code
        	$A.get("e.c:UpdatePlanInfo").setParams({"passHeaderLabel": "Address"}).fire();        
        var p = predicateArray.pop();        
        var filteredAddresses;
        if(p){
            if(p.name===$A.get("$Label.c.WorkType")){
                if(p.value === $A.get("$Label.c.Worked")){
                    filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                        return currentAddress.Worked__c == true;
                    });                    
                } else{
                    filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                        return currentAddress.Worked__c == false;
                    });
                }
            } else if(p.name==$A.get("$Label.c.Active_Product_Count")){
                if(p.value === $A.get("$Label.c.One_Product")){
                    filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                        return currentAddress.WA_Actives_1_Product__c == true;
                    });  
                } else if(p.value === $A.get("$Label.c.Two_Products")){
                    filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                        return currentAddress.WA_Actives_2_Product__c == true;
                    });  
                } else if(p.value === $A.get("$Label.c.Three_Products")){
                    filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                        return currentAddress.WA_Actives_3_Product__c == true;
                    });  
                }
            } else if(p.name==$A.get("$Label.c.Total_Montly_Rate")){
                if(p.value === $A.get("$Label.c.Less_Than_125")){
                    filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                        return currentAddress.Total_Monthly_Rate__c < 125;
                    });  
                } else if(p.value === $A.get("$Label.c.Greater_Than_150")){
                    filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                        return currentAddress.Total_Monthly_Rate__c > 150;
                    }); 
                }
            } 
           else if(p.name=="Active Products"){
                filteredAddresses = this.filterByActiveProduct(component,addresses);                
            } else if(p.name=="Customer Status"){
                filteredAddresses = this.filterByCustomerStatus(component,addresses);
            } else if(p.name=="Dwelling Type"){
                filteredAddresses = this.filterByDwellingType(component,addresses);
            } else if(p.name=="Disposition"){
                filteredAddresses = this.filterByDisposition(component,addresses);
            } else if(p.name=="Tap Status"){
                filteredAddresses = this.filterByTapStatus(component,addresses);
            }  else if(p.name=="Distance"){
				//console.log('in pre dist');
				var distance = component.get("v.distance");
				distance = distance.split(" ")[0];
                filteredAddresses = this.filterByDistance(component,addresses,distance);
            }else if(p.name == "Rejected Addresses"){
                //console.log('in pre rej');
				if(p.value === $A.get("$Label.c.Yes")){
					//console.log('in yes');
                    filteredAddresses = this.getRejectedAddresses(component,addresses);  
                    //console.log('fil'+filteredAddresses);
                } else if(p.value === $A.get("$Label.c.No")){
					//console.log('in no');
                    filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                       return (currentAddress.Rejected_Reason__c ===  undefined || currentAddress.Rejected_Reason__c === null);
                    }); 
                    //console.log('fil'+filteredAddresses);
                }
			} else if(p.name==$A.get("$Label.c.Disconnected_Date")){
            	var dsdate = component.get("v.disconnectedDate");
            	//console.log("dsdate="+dsdate);
                filteredAddresses = this.filterByDisconnectDate(component,addresses,dsdate);                
            }
			
            if(predicateArray.length > 0){
                filteredAddresses = this.clearFilter(component,predicateArray,filteredAddresses);
            }                
            
            return filteredAddresses;  
        } else{
			//console.log('in p else');
            return addresses;
        }
        
    },
    
    filterByActiveProduct : function(component,addresses){
        
        var AP=[];
        var videoChecked = document.getElementById("video").checked;
        var internetChecked = document.getElementById("internet").checked;
        var voiceChecked = document.getElementById("voice").checked;
        var xhChecked = document.getElementById("xh").checked;
        
        if(videoChecked) AP.push("Video");
        if(internetChecked) AP.push("Internet");
        if(voiceChecked) AP.push("Voice");
        if(xhChecked) AP.push("XH");
        
        component.set("v.activeProducts",AP.join()); //set the AP to be displayed under filter type after applying                       
        
        filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
            return (currentAddress.Video_Active1__c==videoChecked && currentAddress.HSI_Active1__c == internetChecked &&
                    currentAddress.Voice_Active1__c==voiceChecked && currentAddress.XH_Active1__c==xhChecked);
        });
        
        return filteredAddresses;
    },
    
    filterByCustomerStatus : function(component,addresses){
        var CS=[];
        var activeChecked = document.getElementById("active").checked;
        var inactiveChecked = document.getElementById("inactive").checked;
        
        if(activeChecked) CS.push("Active");
        if(inactiveChecked) CS.push("Inactive");
        component.set("v.customerStatus",CS.join()); //set the CS to be displayed under filter type after applying
        
        if(CS.length == 1){                        
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Active_Inactive__c==CS[0]);
        	});
        }else if(CS.length == 2){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Active_Inactive__c==CS[0] || currentAddress.Active_Inactive__c==CS[1]);
        	});
        } else{//length==0
            filteredAddresses = addresses;
        }      
        
        return filteredAddresses;
    },
    
    filterByDwellingType :  function(component,addresses){
        var DT=[];
        var bulkbilledmasterChecked = document.getElementById("bulkbilledmaster").checked;
        var bulkbilledmduChecked = document.getElementById("bulkbilledmdu").checked;
        var commercialChecked = document.getElementById("commercial").checked;
        var multipledwellingunitChecked = document.getElementById("multipledwellingunit").checked;
        var nonbulkbilledChecked = document.getElementById("nonbulkbilled").checked;
        var nonbulkbilledmduChecked = document.getElementById("nonbulkbilledmdu").checked;
        var singlefamilyChecked = document.getElementById("singlefamily").checked;
        var singlefamilyunitChecked = document.getElementById("singlefamilyunit").checked;
        var unknownChecked = document.getElementById("unknown").checked;
        var vacantChecked = document.getElementById("vacant").checked;
        var sfuChecked = document.getElementById("sfu").checked;
        var mduChecked = document.getElementById("mdu").checked;
        var otherChecked = document.getElementById("other").checked;
        var excludemappingChecked = document.getElementById("excludemapping").checked;   
        
        if(bulkbilledmasterChecked) DT.push("Bulk Billed Master");
        if(bulkbilledmduChecked) DT.push("Bulk Billed MDU");                
        if(commercialChecked) DT.push("Commercial");
        if(multipledwellingunitChecked) DT.push("Multiple Dwelling Unit");                
        if(nonbulkbilledChecked) DT.push("Non Bulk Billed");
        if(nonbulkbilledmduChecked) DT.push("Non Bulk Billed MDU");        
        if(singlefamilyChecked) DT.push("Single Family");
        if(singlefamilyunitChecked) DT.push("Single Family Unit");        
        if(unknownChecked) DT.push("Unknown");
        if(vacantChecked) DT.push("Vacant");        
        if(sfuChecked) DT.push("SFU");
        if(mduChecked) DT.push("MDU");        
        if(otherChecked) DT.push("OTHER");
        if(excludemappingChecked) DT.push("EXCLUDE MAPPING");
        
        component.set("v.dwellingType",DT.join()); //set the CS to be displayed under filter type after applying
        
        if(DT.length == 1){                        
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0]);
        	});
        }else if(DT.length == 2){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0] || currentAddress.Dwelling_Type__c==DT[1]);
        	});
        }else if(DT.length == 3){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0] || currentAddress.Dwelling_Type__c==DT[1] || 
                            currentAddress.Dwelling_Type__c==DT[2]);
        	});
        }else if(DT.length == 4){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0] || currentAddress.Dwelling_Type__c==DT[1] ||
                            currentAddress.Dwelling_Type__c==DT[2] || currentAddress.Dwelling_Type__c==DT[3]);
        	});
        }else if(DT.length == 5){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0] || currentAddress.Dwelling_Type__c==DT[1] ||
                            currentAddress.Dwelling_Type__c==DT[2] || currentAddress.Dwelling_Type__c==DT[3] ||
                            currentAddress.Dwelling_Type__c==DT[4]);
        	});
        }else if(DT.length == 6){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0] || currentAddress.Dwelling_Type__c==DT[1] ||
                            currentAddress.Dwelling_Type__c==DT[2] || currentAddress.Dwelling_Type__c==DT[3] ||
                            currentAddress.Dwelling_Type__c==DT[4] || currentAddress.Dwelling_Type__c==DT[5]);
        	});
        }else if(DT.length == 7){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0] || currentAddress.Dwelling_Type__c==DT[1] ||
                            currentAddress.Dwelling_Type__c==DT[2] || currentAddress.Dwelling_Type__c==DT[3] ||
                            currentAddress.Dwelling_Type__c==DT[4] || currentAddress.Dwelling_Type__c==DT[5] ||
                            currentAddress.Dwelling_Type__c==DT[6]);
        	});
        }else if(DT.length == 8){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0] || currentAddress.Dwelling_Type__c==DT[1] ||
                            currentAddress.Dwelling_Type__c==DT[2] || currentAddress.Dwelling_Type__c==DT[3] ||
                            currentAddress.Dwelling_Type__c==DT[4] || currentAddress.Dwelling_Type__c==DT[5] ||
                            currentAddress.Dwelling_Type__c==DT[6] || currentAddress.Dwelling_Type__c==DT[7]);
        	});
        }else if(DT.length == 9){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0] || currentAddress.Dwelling_Type__c==DT[1] ||
                            currentAddress.Dwelling_Type__c==DT[2] || currentAddress.Dwelling_Type__c==DT[3] ||
                            currentAddress.Dwelling_Type__c==DT[4] || currentAddress.Dwelling_Type__c==DT[5] ||
                            currentAddress.Dwelling_Type__c==DT[6] || currentAddress.Dwelling_Type__c==DT[7] ||
                            currentAddress.Dwelling_Type__c==DT[8]);
        	});
        }else if(DT.length == 10){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0] || currentAddress.Dwelling_Type__c==DT[1] ||
                            currentAddress.Dwelling_Type__c==DT[2] || currentAddress.Dwelling_Type__c==DT[3] ||
                            currentAddress.Dwelling_Type__c==DT[4] || currentAddress.Dwelling_Type__c==DT[5] ||
                            currentAddress.Dwelling_Type__c==DT[6] || currentAddress.Dwelling_Type__c==DT[7] ||
                            currentAddress.Dwelling_Type__c==DT[8] || currentAddress.Dwelling_Type__c==DT[9]);
        	});
        }else if(DT.length == 11){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0] || currentAddress.Dwelling_Type__c==DT[1] ||
                            currentAddress.Dwelling_Type__c==DT[2] || currentAddress.Dwelling_Type__c==DT[3] ||
                            currentAddress.Dwelling_Type__c==DT[4] || currentAddress.Dwelling_Type__c==DT[5] ||
                            currentAddress.Dwelling_Type__c==DT[6] || currentAddress.Dwelling_Type__c==DT[7] ||
                            currentAddress.Dwelling_Type__c==DT[8] || currentAddress.Dwelling_Type__c==DT[9] ||
                            currentAddress.Dwelling_Type__c==DT[10]);
        	});
        }else if(DT.length == 12){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0]  || currentAddress.Dwelling_Type__c==DT[1] ||
                            currentAddress.Dwelling_Type__c==DT[2]  || currentAddress.Dwelling_Type__c==DT[3] ||
                            currentAddress.Dwelling_Type__c==DT[4]  || currentAddress.Dwelling_Type__c==DT[5] ||
                            currentAddress.Dwelling_Type__c==DT[6]  || currentAddress.Dwelling_Type__c==DT[7] ||
                            currentAddress.Dwelling_Type__c==DT[8]  || currentAddress.Dwelling_Type__c==DT[9] ||
                            currentAddress.Dwelling_Type__c==DT[10] || currentAddress.Dwelling_Type__c==DT[11]);
        	});
        }else if(DT.length == 13){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0]  || currentAddress.Dwelling_Type__c==DT[1]  ||
                            currentAddress.Dwelling_Type__c==DT[2]  || currentAddress.Dwelling_Type__c==DT[3]  ||
                            currentAddress.Dwelling_Type__c==DT[4]  || currentAddress.Dwelling_Type__c==DT[5]  ||
                            currentAddress.Dwelling_Type__c==DT[6]  || currentAddress.Dwelling_Type__c==DT[7]  ||
                            currentAddress.Dwelling_Type__c==DT[8]  || currentAddress.Dwelling_Type__c==DT[9]  ||
                            currentAddress.Dwelling_Type__c==DT[10] || currentAddress.Dwelling_Type__c==DT[11] ||
                            currentAddress.Dwelling_Type__c==DT[12]);
        	});
        }else if(DT.length == 14){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Dwelling_Type__c==DT[0]  || currentAddress.Dwelling_Type__c==DT[1]  ||
                            currentAddress.Dwelling_Type__c==DT[2]  || currentAddress.Dwelling_Type__c==DT[3]  ||
                            currentAddress.Dwelling_Type__c==DT[4]  || currentAddress.Dwelling_Type__c==DT[5]  ||
                            currentAddress.Dwelling_Type__c==DT[6]  || currentAddress.Dwelling_Type__c==DT[7]  ||
                            currentAddress.Dwelling_Type__c==DT[8]  || currentAddress.Dwelling_Type__c==DT[9]  ||
                            currentAddress.Dwelling_Type__c==DT[10] || currentAddress.Dwelling_Type__c==DT[11] ||
                            currentAddress.Dwelling_Type__c==DT[12] || currentAddress.Dwelling_Type__c==DT[13]);
        	});
        } else{//length==0
            filteredAddresses = addresses;
        }      
        
        return filteredAddresses;
    },
    
    filterByDisposition :  function(component,addresses){
        var DISP=[];
        var noknockChecked = document.getElementById("noknock").checked;
        var noanswerChecked = document.getElementById("noanswer").checked;
        var doorhangerChecked = document.getElementById("doorhanger").checked;
        var contactChecked = document.getElementById("contact").checked;
        var engageChecked = document.getElementById("engage").checked;
        var discoverChecked = document.getElementById("discover").checked;
        var positionChecked = document.getElementById("position").checked;
        var closeChecked = document.getElementById("close").checked;
        var startChecked = document.getElementById("start").checked;
        var nmaChecked = document.getElementById("nma").checked;
        
        if(noknockChecked) DISP.push("No Knock");
        if(noanswerChecked) DISP.push("No Answer");                
        if(doorhangerChecked) DISP.push("Door Hanger");
        if(contactChecked) DISP.push("Contact");                
        if(engageChecked) DISP.push("Engage");
        if(discoverChecked) DISP.push("Discover");        
        if(positionChecked) DISP.push("Position");
        if(closeChecked) DISP.push("Close");        
        if(startChecked) DISP.push("Start");
        if(nmaChecked) DISP.push("Non-Marketable Address");        


        
        component.set("v.dispositions",DISP.join()); //set the CS to be displayed under filter type after applying
        
        if(DISP.length == 1){                        
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Most_Recent_Disposition__c==DISP[0]);
        	});
        }else if(DISP.length == 2){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Most_Recent_Disposition__c==DISP[0] || currentAddress.Most_Recent_Disposition__c==DISP[1]);
        	});
        }else if(DISP.length == 3){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Most_Recent_Disposition__c==DISP[0] || currentAddress.Most_Recent_Disposition__c==DISP[1] || 
                            currentAddress.Most_Recent_Disposition__c==DISP[2]);
        	});
        }else if(DISP.length == 4){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Most_Recent_Disposition__c==DISP[0] || currentAddress.Most_Recent_Disposition__c==DISP[1] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[2] || currentAddress.Most_Recent_Disposition__c==DISP[3]);
        	});
        }else if(DISP.length == 5){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Most_Recent_Disposition__c==DISP[0] || currentAddress.Most_Recent_Disposition__c==DISP[1] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[2] || currentAddress.Most_Recent_Disposition__c==DISP[3] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[4]);
        	});
        }else if(DISP.length == 6){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Most_Recent_Disposition__c==DISP[0] || currentAddress.Most_Recent_Disposition__c==DISP[1] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[2] || currentAddress.Most_Recent_Disposition__c==DISP[3] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[4] || currentAddress.Most_Recent_Disposition__c==DISP[5]);
        	});
        }else if(DISP.length == 7){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Most_Recent_Disposition__c==DISP[0] || currentAddress.Most_Recent_Disposition__c==DISP[1] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[2] || currentAddress.Most_Recent_Disposition__c==DISP[3] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[4] || currentAddress.Most_Recent_Disposition__c==DISP[5] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[6]);
        	});
        }else if(DISP.length == 8){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Most_Recent_Disposition__c==DISP[0] || currentAddress.Most_Recent_Disposition__c==DISP[1] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[2] || currentAddress.Most_Recent_Disposition__c==DISP[3] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[4] || currentAddress.Most_Recent_Disposition__c==DISP[5] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[6] || currentAddress.Most_Recent_Disposition__c==DISP[7]);
        	});
        }else if(DISP.length == 9){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Most_Recent_Disposition__c==DISP[0] || currentAddress.Most_Recent_Disposition__c==DISP[1] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[2] || currentAddress.Most_Recent_Disposition__c==DISP[3] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[4] || currentAddress.Most_Recent_Disposition__c==DISP[5] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[6] || currentAddress.Most_Recent_Disposition__c==DISP[7] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[8]);
        	});
        }else if(DISP.length == 10){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.Most_Recent_Disposition__c==DISP[0] || currentAddress.Most_Recent_Disposition__c==DISP[1] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[2] || currentAddress.Most_Recent_Disposition__c==DISP[3] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[4] || currentAddress.Most_Recent_Disposition__c==DISP[5] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[6] || currentAddress.Most_Recent_Disposition__c==DISP[7] ||
                            currentAddress.Most_Recent_Disposition__c==DISP[8] || currentAddress.Most_Recent_Disposition__c==DISP[9]);
        	});
        }else{//length==0
            filteredAddresses = addresses;
        }      
        
        return filteredAddresses;
    },
    
    filterByTapStatus : function(component,addresses){
        var TP=[];
        var hotChecked = document.getElementById("hot").checked;
        var coldChecked = document.getElementById("cold").checked;
        
        if(hotChecked) TP.push("HOT");
        if(coldChecked) TP.push("COLD");
        component.set("v.tapStatus",TP.join()); //set the TP to be displayed under filter type after applying
        
        if(TP.length == 1){                        
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.FormulaTapStatus__c==TP[0]);
        	});
        }else if(TP.length == 2){
            filteredAddresses = this.applyFilter(component,addresses,function(currentAddress){
                    return (currentAddress.FormulaTapStatus__c==TP[0] || currentAddress.FormulaTapStatus__c==TP[1]);
        	});
        } else{//length==0
            filteredAddresses = addresses;
        }      
        
        return filteredAddresses;
    },
	
    filterByDistance : function (component, addresses, distanceFilterValue){
		 var filteredAddresses=[];
		 var d;
			for(var j = 0; j < addresses.length; j++){
				var isFilterByCurrentLoc = component.get("v.IsFilterByCurrentLocation");
				if(isFilterByCurrentLoc){
					var lat = component.get("v.lat");
					var longi = component.get("v.longi");
				}else{
					var lat = component.get("v.selectedAddressLat");
					var longi = component.get("v.selectedAddressLong");
					 
				}
				
                var lat2 = addresses[j].Latitude__c;
                var lon2 = addresses[j].Longitude__c;
                var radlat1 = Math.PI * lat/180;
                var radlat2 = Math.PI * lat2/180;
                var radlon1 = Math.PI * longi/180;
              
                
                var radlon2 = Math.PI * lon2/180;
                var theta = longi-lon2;
                var radtheta = Math.PI * theta/180;
                var dist = (Math.sin(radlat1) * Math.sin(radlat2)) + (Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta));
                dist = Math.acos(dist);
                dist = dist * 180/Math.PI;
                dist = parseInt(dist * 60 * 1.1515);
                //return dist;
               
                
                var a = parseInt(distanceFilterValue);
                if(dist <= a){
                    filteredAddresses.push(addresses[j]);
		        }
					
				
			}	
			
		
        	return filteredAddresses;
	},
	/*
    * @Description: US946437 - DSM to SF1: Filter by Disconnect Date
    * @Author: Siddharth Sinha (Accenture)
    * @Date: 13-July-2017 
    * @Param: Component, Addresses and Value selected for sorting by the user on UI
    * @Return: filteredAddresses
    */
    filterByDisconnectDate : function (component, addresses, value){
			var currentDate = new Date();// Today's date
			var sixMonthAgo = new Date();// Today's date
			var yearAgo = new Date();// Today's date
			var twoYearAgo = new Date();// Today's date
			var threeYearAgo = new Date();// Today's date
			yearAgo.setFullYear(currentDate.getFullYear() - 1);// convert the disconnect date to date format 1 year ago
			sixMonthAgo.setMonth(currentDate.getMonth() - 6);// convert the disconnect date to date format 6 months ago
			twoYearAgo.setFullYear(currentDate.getFullYear() - 2);// convert the disconnect date to date format 2 years ago
			threeYearAgo.setFullYear(currentDate.getFullYear() - 3); // convert the disconnect date to date format 3 years ago
			var filteredAddresses=[]; // array to return the filtered addresses based on filter applied
			var j; // variable for iterating in loop
			
		//Code Logic starts to get the user input and filter the addresses that qualify to be shown
		if(value === $A.get("$Label.c.X6_Months")){
			for(j = 0; j < addresses.length; j++){
				var addDate1 = new Date(addresses[j].Last_Disconnected_Date__c);
				if(addDate1<currentDate && addDate1>sixMonthAgo && (addDate1)){
				  filteredAddresses.push(addresses[j]);
				}
			}
		}
		if(value === $A.get("$Label.c.Between_6_Months_and_1_Year")){	
			for(j = 0; j < addresses.length; j++){
				var addDate2 = new Date(addresses[j].Last_Disconnected_Date__c);
				if(addDate2<sixMonthAgo && addDate2>yearAgo && (addDate2)){
				  filteredAddresses.push(addresses[j]);
				}
			}				
		}
		if(value === $A.get("$Label.c.X1_Year")){
			for(j = 0; j < addresses.length; j++){
				var addDate3 = new Date(addresses[j].Last_Disconnected_Date__c);
				if(addDate3>yearAgo && addDate3<currentDate && (addDate3)){
				  filteredAddresses.push(addresses[j]);
				}
			}	
		}
		if(value === $A.get("$Label.c.Between_1_and_2_Years")){
			for(j = 0; j < addresses.length; j++){
				var addDate4 = new Date(addresses[j].Last_Disconnected_Date__c);
				if(addDate4<yearAgo && addDate4>twoYearAgo && (addDate4)){
				  filteredAddresses.push(addresses[j]);
				}
			}	
		}				
		if(value === $A.get("$Label.c.X2_Years")){
			for(j = 0; j < addresses.length; j++){
				var addDate5 = new Date(addresses[j].Last_Disconnected_Date__c);
				if(addDate5>twoYearAgo && addDate5<currentDate && (addDate5)){
				  filteredAddresses.push(addresses[j]);
				}
			}	
		}
		if(value === $A.get("$Label.c.Between_2_and_3_Years")){
			for(j = 0; j < addresses.length; j++){
				var addDate6 = new Date(addresses[j].Last_Disconnected_Date__c);
				if(addDate6<twoYearAgo && addDate6>threeYearAgo && (addDate6)){
				  filteredAddresses.push(addresses[j]);
				}
			}	
		}
		if(value === $A.get("$Label.c.X3_Years")){
			for(j = 0; j < addresses.length; j++){
				var addDate7 = new Date(addresses[j].Last_Disconnected_Date__c);
				if(addDate7>threeYearAgo && addDate7<currentDate && (addDate7)){
				  filteredAddresses.push(addresses[j]);
				}
			}	
		}
				 
        return filteredAddresses;
	},
	//US946437 Changes End
		
	getRejectedAddresses : function(component, addresses) {
		var filteredAddresses=[];
		
			var action = component.get("c.getRejectedAddresses");
			//console.log('startDateTime>>>>>'+component.get("v.startDateTime"));
			//console.log('endDateTime>>>>>'+component.get("v.endDateTime"));
			//console.log('planId>>>>>'+component.get("v.planId"));
			action.setParams({
			
				"startDate" : component.get("v.startDateTime"),
				"endDate" : component.get("v.endDateTime"),
				"planId" : component.get("v.planId")
				
			});
		   action.setCallback(this, function(a){
			   if(a.getState() === "SUCCESS"){
				   var addressesAndPlan = a.getReturnValue();
				   var d = new Date();
				  d.setDate(d.getDate() -179);
				  var date=(d.toISOString().slice(0,10));
				var start = component.get("v.startDateTime");
                   var today = component.get("v.endDateTime");
				   if(addressesAndPlan != null && addressesAndPlan.length>0){
					//Update AddressPane and Map Pane to show filtered addresses  
					if(start>date) {		
						$A.get("e.c:SendFilteredAndOriginalAddressList").setParams({"filteredAddresses": addressesAndPlan,
																		"originalAddresses": component.get("v.originalAddresses")}).fire(); 
                    }else{
						alert('Start date cannot be earlier than 180 days from today');
					}
                   
				   }else{
					   console.log("Some Error");
				   }
			   } else{
				   console.log("No Address found");
			   }
			});
			$A.enqueueAction(action);
	},
	
    
})