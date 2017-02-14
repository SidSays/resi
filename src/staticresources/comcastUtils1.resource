
 function checkIsNumeric(textId)
    {
//     var textIdText =  (document.getElementById(textId).value);
       var textIdText =  textId.value;
       var ValidChars = "0123456789, ";
       var IsNumber=true;
       var Char;
       for (i = 0; i < textIdText.length && IsNumber == true; i++)
          {
          Char = textIdText.charAt(i);
          if (ValidChars.indexOf(Char) == -1)
             {
                 IsNumber = false;
             }
          }
        if (IsNumber == false)
           {
             alert("Please enter 5 or 9-digit zip codes separated by commas.  Entries can only contain numbers, commas and spaces. ");
             
             textId.value = '';
           return false;
           }
         var zip;
         var is5or9 = true;  
         var splitZips = textIdText.split(",");
         for(i = 0; i < splitZips.length; i++){
         	zip = '';
         	zip = splitZips[i].trim().length;
         	if(zip == 0 || zip == 5 || zip ==9){
				var i = i;
			}else{
				is5or9 = false;
			}
		}
		
		if(!is5or9){
		
			alert("Zip codes should be either 5 or 9 characters in length.");
		}
         
       }
       
       String.prototype.trim = function () {
		    return this.replace(/^\s*/, "").replace(/\s*$/, "");
		}

        function checkIsDate1(dateObj) { 
     	re = /^((0?[13578]|10|12)(-|\/)(([1-9])|(0[1-9])|([12])([0-9]?)|(3[01]?))(-|\/)((19)([2-9])(\d{1})|(20)([01])(\d{1})|([8901])(\d{1}))|(0?[2469]|11)(-|\/)(([1-9])|(0[1-9])|([12])([0-9]?)|(3[0]?))(-|\/)((19)([2-9])(\d{1})|(20)([01])(\d{1})|([8901])(\d{1})))$/

            if(dateObj.value != '' && !dateObj.value.match(re)) { 
                alert("Invalid date format: " + dateObj.value + " Date should be in the following format - mm/dd/yyyy " ); 
                dateObj.focus(); 
                return false; 
            } 

        return true;
        }
       
       function checkIsDate(dateObj) { 
            //re = /^(0|1)[0-9]\/[0-3][0-9]\/(19|20)[0-9]{2}$/
            //re = /^[01][0-2][/\.-]?[0-3][0-9][/\.-](19|20)[0-9]{2}$/
            re = /^((0?[13578]|10|12)(-|\/)(([1-9])|(0[1-9])|([12])([0-9]?)|(3[01]?))(-|\/)((19)([2-9])(\d{1})|(20)([01])(\d{1})|([8901])(\d{1}))|(0?[2469]|11)(-|\/)(([1-9])|(0[1-9])|([12])([0-9]?)|(3[0]?))(-|\/)((19)([2-9])(\d{1})|(20)([01])(\d{1})|([8901])(\d{1})))$/
            if (dateObj.value.length > 0) { 
                if(dateObj.value.match(re ))
               {
                  /*
                  var date_array = dateObj.value.split('/');
                  var day = date_array[0];
            
                  // Attention! Javascript consider months in the range 0 - 11
                  var month = date_array[1] - 1;
                  var year = date_array[2];
            
                  // This instruction will create a date object
                  source_date = new Date(year,month,day);
                  alert('Source Date: ' + source_date.getFullYear()+ ' the Year: ' + year);
            
                  if(year != source_date.getFullYear())
                  {
                     alert('Year is not valid!' + ' ' + source_date.getFullYear()+ ' ' + year);
                     dateObj.value = '';
                     return false;
                  }
            
                  if(month != source_date.getMonth())
                  {
                     alert('Month is not valid!');
                     dateObj.value = '';
    
                     return false;
                  }
            
                  if(day != source_date.getDate())
                  {
                     alert('Day is not valid!');
                     dateObj.value = '';
                     return false;
                  }*/
                  return true;
               }
               else
               {
                  alert("Incorrect Date or Invalid date format: " + dateObj.value + " Date should be in the following format - mm/dd/yyyy " ); 
                  dateObj.value = '';
                  return false;
               }
            }       
           return true;
        
            
       }


   function showProgressBar(message1 ) {
    document.getElementById('messageText1').innerHTML = message1;
        showDialog(document.getElementById('AddUserDialog'));
    }
        function hideProgressBar() {
       var headerObj = document.getElementById('AddUserDialog');
        headerObj.style.display = "none";
    }
      function showDialog(x) {
        //get viewport's width and height
        var d = document.documentElement;
        vpWidth=self.innerWidth;
        vpHeight=self.innerHeight;
        if (vpWidth == undefined) {
            vpWidth=d.clientWidth;
            vpHeight=d.clientHeight;
        } 
        //get dialog's width and height
        dialogWidth=x.offsetWidth; 
        dialogHeight=x.offsetHeight;
        //calculate position
        dialogTop =200; 
        dialogLeft = 500;
        
        //Position the Dialog
        x.style.top =dialogTop+"px";
        x.style.left =dialogLeft+"px";
        x.style.display = "block";
        }

            
