({   
    MAX_FILE_SIZE: 25000000, /* 6 000 000 * 3/4 to account for base64*/
    CHUNK_SIZE: 900000, /* Use a multiple of 4 */
    
    getLocation: function(component, event, helper){
        var lat; 
        var longi;
        if (!navigator.geolocation){
            //alert('Geolocation is not supported by your browser');
            var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        "title": "Error!",
					        "message": "Geolocation is not supported by your browser"
					    });
					    toastEvent.fire();
        }
        navigator.geolocation.getCurrentPosition(success, error);
        function success(position) {            
            lat = position.coords.latitude; 
            longi = position.coords.longitude;
            
            component.set("v.lat", lat);
            component.set("v.longi", longi);
            
            var storeId = component.get("v.store.Id"); 
            var action = component.get("c.queryActiveStoreVisit");
            action.setParams({
                "storeId": storeId,
                "lat" :  component.get("v.lat"),
                "longi" : component.get("v.longi")
            });
            action.setCallback(this, function(a){
                var state = a.getState();
                if (state === "SUCCESS") {
                    component.set("v.StoreVisitObj", a.getReturnValue());    
                }
            });
            $A.enqueueAction(action);
        }
        function error() {
            //alert('Unable to retrieve your location');
            var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        "title": "Error!",
					        "message": "Unable to retrieve your location"
					    });
					    toastEvent.fire();
        }
    },
    
    
    storeVisitDetails : function(component) {
        var storeId = component.get("v.store.Id");
        this.getLocation(component);
        var action = component.get("c.queryActiveStoreVisit");
        action.setParams({
            "storeId": storeId,
            "lat" :  component.get("v.lat"),
            "longi" : component.get("v.longi")
        });
        
        action.setCallback(this, function(a){
            var state = a.getState();
            if (state === "SUCCESS") {
                component.set("v.StoreVisitObj", a.getReturnValue());
                var storeVisit = component.get("v.StoreVisitObj");
                this.getStoreVisitWrapper2(component);
                
                //Add MultipleContact US
                var storeActivityRecordTypeId = component.get("v.StoreActivityCatagory");               
                if(storeActivityRecordTypeId != 'undefined' && component.get("v.fromMultiContComp")){
                    var storeAct = component.get("c.createStoreActivity");
                    storeAct.setParams({
                        "storevisitCategoryRecordTypeId" : component.get("v.StoreActivityCatagory"),
                        "storeVisit" : component.get("v.StoreVisitObj")
                    });
                    storeAct.setCallback(this, function(a){           	
                        component.set("v.storeActivity", a.getReturnValue());           			                       
                        var wrapper = component.get("v.StoreVisitWrapper2");
                        
                        var i;
                        for(i= 0; i<wrapper.length; i++){
                            if(wrapper[i].stc.Record_Type_Id__c == storeActivityRecordTypeId )
                            {       
                                wrapper[i].check = true;
                                var stc = wrapper[i].stc;                
                                var lookupField = stc.Lookup_field_value__c;                           
                                if(lookupField !== undefined){   
                                    var lookupFieldList = new Array();
                                    if(lookupField.includes(";")){
                                        lookupFieldList = lookupField.split(";");
                                    }else{
                                        lookupFieldList.push(lookupField);
                                    }             
                                    component.set("v.LookupFieldValue",lookupFieldList);            
                                }
                            }
                            else
                            {
                                wrapper[i].check = false;
                            }
                        }
                        component.set("v.edit", true);
                        component.set("v.readOnly", false);
                        component.set("v.StoreVisitWrapper2", wrapper);                         
                    });
                    $A.enqueueAction(storeAct);      			
                }
                //this.downloadAttachment(component, storeVisit);
                this.attachmentList(component, storeVisit);     
            }
            
        }); 
        $A.enqueueAction(action);        
    },
    
    getStoreVisitWrapper2: function(component){
        var action = component.get("c.getStoreVisitWrapper2");
        action.setParams({
            "categories" : component.get("v.storeVisitCategory") 
        });
        action.setCallback(this, function(a)
                           {
                               component.set("v.StoreVisitWrapper2", a.getReturnValue()); 
                           });
        $A.enqueueAction(action);
    },
    
    save : function(component,event,helper) { 
        
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        
        var storevisit = component.get("v.StoreVisitObj");
        var action = component.get("c.activeVisitCheck");
        action.setParams({
            "storeVisit" : component.get("v.StoreVisitObj")
        });
        if (file == null) {
            //alert('Please select a file to attach');
              var title = "Please select a file to attach";
			  var confirm = false;
			  helper.showAlertBox(component, event, helper,title,confirm); 
            return;
        }
        
        if (file.size > this.MAX_FILE_SIZE) {
           //alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
             //     'Selected file size: ' + file.size);
             var title = "File size cannot exceed " + this.MAX_FILE_SIZE + " bytes.\n" +
                  "Selected file size: " + file.size;
			 var confirm = false;
			 helper.showAlertBox(component, event, helper,title,confirm); 
            return;
        }
        
        
        
        var fr = new FileReader();
        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            
            self.upload(component, file, fileContents, event, helper);    
        }
        
        $A.enqueueAction(action);   
        fr.readAsDataURL(file);  
        
    },
    
    upload: function(component, file, fileContents,event,helper) {
        var statuscheck ;
        var storevisit = component.get("v.StoreVisitObj");
        var action = component.get("c.activeVisitCheck");
        action.setParams({
            "storeVisit" : component.get("v.StoreVisitObj")
        });
        action.setCallback(this, function(a){
            statuscheck = a.getReturnValue();
            
            if (statuscheck == true) {
                //alert('This visit has already ended.');
	              var title = "This visit has already ended.";
				  var confirm = false;
				  helper.showAlertBox(component, event, helper,title,confirm); 
                return;   
            }
            
            
            var fromPos = 0;
            var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);
            var attachId = null;
            // start with the initial chunk
            this.uploadChunk(component, file, fileContents, fromPos, toPos, attachId); 
        });
        $A.enqueueAction(action);
    },
    
    uploadChunk : function(component, file, fileContents, fromPos, toPos, attachId) {
        var action = component.get("c.saveTheChunk"); 
        var chunk = fileContents.substring(fromPos, toPos);
        action.setParams({
            parentId: component.get("v.StoreVisitObj"),
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            fileId: attachId
        });
        
        var self = this;
        
        action.setCallback(this, function(a) {
            attachId = a.getReturnValue();
            fromPos = toPos;
            toPos = Math.min(fileContents.length, fromPos + self.CHUNK_SIZE);
            
            if (fromPos < toPos) {
                self.uploadChunk(component, file, fileContents, fromPos, toPos, attachId);
            } 
            
            
            else{             
                component.find("file").getElement().value='';  
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "File has been attached successfully."
                    
                });
                toastEvent.fire();
                
                var storeVisit = component.get("v.StoreVisitObj"); 
                this.attachmentList(component,storeVisit);
                //this.downloadAttachment(component,component.get("v.StoreVisitObj"));
                     
            }  
            
        }); 
        $A.enqueueAction(action);  
    },
    
    attachmentList:function(component){
        
        var numbers = [];
        var i;
        var action = component.get("c.getAttachmentName"); 
        action.setParams({
            parentId: component.get("v.StoreVisitObj")
        }); 
        
        
        action.setCallback(this, function(a)
                           { 
  							   var state = a.getState();
                               if (state === "SUCCESS"){
                                  
                                                                      
                                   for ( i = 0; i <= a.getReturnValue().length; i++) {
                                       numbers.push(a.getReturnValue()[i]);
     								var name = a.getReturnValue()
                                   component.set("v.Attachment", name);
                                       }
                                   if(a.getReturnValue().length > 0){    
                                       component.set("v.showAttachment", "true");
                                       }  
                                   
                               }
                           });   
        $A.enqueueAction(action);    
    },
    
    downloadAttachment:function(component){
        
        var numbers = [];
        var i;
        var action = component.get("c.downloadAttachment"); 
        action.setParams({
            parentId: component.get("v.StoreVisitObj")
        }); 
        
        
        action.setCallback(this, function(a)
                           { 
							   var state = a.getState();
                               if (state === "SUCCESS") {              
                                  for ( i = 0; i <= a.getReturnValue().length; i++) {
                                       numbers.push(a.getReturnValue()[i]);                   
                                   var fileId = numbers;
                                    var fileId = a.getReturnValue();                                    
                                       var url = "/servlet/servlet.FileDownload?file="+fileId;                                   
                                   component.set("v.Download", url);                                    
                                   }
                               }
                           });   
        $A.enqueueAction(action);  
        return true;
    },
    
    showAlertBox : function(component, event, helper, title, confirm, showSummary,showSummaryonEndVisit) {     
        var OkBox = false;
        var alreadyEndedVisit = false;
        if(confirm == false){
            var OkBox = true;}
       /* if(title = "This visit has already ended.")
        {
            alreadyEndedVisit = true;
        }*/
		var title = title;       
        $A.createComponent(
            "c:IndirectShowAlert",{ 
                "title" : title,
                "confirmBox" : confirm,
                "OkBox" : OkBox,
                "showSummary" : showSummary,
                "showSummaryonEndVisit" :showSummaryonEndVisit
               // "alreadyEndedVisit" : alreadyEndedVisit
                
            },
            function(msgBox){
                if (component.isValid()) {
                    var targetCmp = component.find('optionalModalDialog');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                }
            }
        );
        
    },
    
})