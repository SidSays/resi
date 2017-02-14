/**
* Class Name: UpdateInformationInSalesforce
* Author: Amitkumar Bangad, Accenture
* Date: 01-July-2013 
* Requirement # Integration CR
* Description: This Webservice can be called by Mobile API which performs 
*              a callout and fetches updated address information from the Biller hitting the middleware
* Last Modified :
*/
global class UpdateInformationInSalesforce{

    global class cAddress {
        webservice String country;
        webservice String city;
        webservice String unitType;
        webservice String zipCode;
        webservice String state;
        webservice String unitNumber;
        webservice String zip4Code;
        webservice String streetAddress1;
        webservice String streetAddress2;
        webservice String locationId;
        webservice String billingHouseKey;
    }
    public static AddressInformationUtility.AccountInfo accInfo;
    public static AddressInformationUtility.SubscriptionInfo subInfo;
    public static AddressInformationUtility.LocationInfo locInfo;
    public static AddressInformationUtility.CustomerInfo custInfo;
    public static String SOAPRequest;
    public static String SOAPResponse;
    public static String SOAPResponseBody;
    
    webservice static string getUpdateStatus(cAddress add) {
        String Username;
        String Password;
        String SourceSystemId;
        String sourceSystemUserId;
        String sourceServerId;
        String Endpoint;
        String SoapXMLBody;
        String responseBody;
        String trackingId = 'ab' + String.valueOf(Math.round(Math.random()*Math.pow(10, 6))) + '-mn' +
                     String.valueOf(Math.round(Math.random()*Math.pow(10, 6))) + '-yz' +
                     String.valueOf(Math.round(Math.random()*Math.pow(10, 6)));
        String serverResponse;
        decimal dt3;
        String parsedMessage;
        String salesForceStatus;
        
        if(add != null){
            system.debug('add in side main method'+add);
        // Fetch Custom Setting Data around 
            try {
                Username = Super_API_Parameters__c.getValues('Username').Value__c;
                Password = Super_API_Parameters__c.getValues('Password').Value__c;
                SourceSystemId = Super_API_Parameters__c.getValues('sourceSystemId').Value__c;
                sourceSystemUserId = Super_API_Parameters__c.getValues('sourceSystemUserId').Value__c;
                sourceServerId = Super_API_Parameters__c.getValues('sourceServerId').Value__c;
                Endpoint = Super_API_Parameters__c.getValues('Endpoint').Value__c;
            } catch(Exception ex) {
                System.debug('No data found in custom setting:'+ex);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
            }
            
            //Set Request Header
            SoapXMLBody = '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
                          '<env:Header xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">' +
                          '<typ:requestHeader xmlns:typ="http://xml.comcast.com/types">';  
            SoapXMLBody = SoapXMLBody + '<typ:timestamp>' + system.now() + '</typ:timestamp>';
            SoapXMLBody = SoapXMLBody + '<typ:sourceSystemId>' + SourceSystemId + '</typ:sourceSystemId>';
            SoapXMLBody = SoapXMLBody + '<typ:sourceSystemUserId>' + sourceSystemUserId + '</typ:sourceSystemUserId>';
            SoapXMLBody = SoapXMLBody + '<typ:sourceServerId>' + sourceServerId + '</typ:sourceServerId>';
            SoapXMLBody = SoapXMLBody + '<typ:trackingId>' + trackingId + '</typ:trackingId>';
            SoapXMLBody = SoapXMLBody + '</typ:requestHeader>';
            
            //Set Security Header
            SoapXMLBody = SoapXMLBody + '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">';
            SoapXMLBody = SoapXMLBody + '<wsse:UsernameToken>';
            SoapXMLBody = SoapXMLBody + '<wsse:Username>' + Username +'</wsse:Username>';
            SoapXMLBody = SoapXMLBody + '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+ Password +'</wsse:Password>';
            SoapXMLBody = SoapXMLBody + '</wsse:UsernameToken>';
            SoapXMLBody = SoapXMLBody + '</wsse:Security>';
            SoapXMLBody = SoapXMLBody + '</env:Header>';
            
            //Set Body Parameters
            SoapXMLBody = SoapXMLBody + '<env:Body xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">';
            
            //Call Method to get address information              
            SoapXMLBody = SoapXMLBody + '<m:getAddressInfo xmlns:m="http://xml.comcast.com/accountmanagementcontroller/services">';
            SoapXMLBody = SoapXMLBody + '<m:getAddressInfoRequest>';
            // If Billing House Key Present
            if(add.billingHouseKey != ''){
                SoapXMLBody = SoapXMLBody + '<typ:billingHouseKey xmlns:typ="http://xml.comcast.com/accountmanagementcontroller/types">'; 
                SoapXMLBody = SoapXMLBody + add.billingHouseKey + '</typ:billingHouseKey>';
            } 
            // If Location ID Present
            else if(add.locationId != ''){
                SoapXMLBody = SoapXMLBody + '<typ:locationId xmlns:typ="http://xml.comcast.com/accountmanagementcontroller/types">'; 
                SoapXMLBody = SoapXMLBody + add.locationId + '</typ:locationId>';    
            }
            // If Address Record Present
            else{
                SoapXMLBody = SoapXMLBody + '<typ:address xmlns:typ="http://xml.comcast.com/accountmanagementcontroller/types">';
                if(add.country != ''){
                    SoapXMLBody = SoapXMLBody + '<typ:country>' + add.country + '</typ:country>';
                }
                if(add.city != ''){
                    SoapXMLBody = SoapXMLBody + '<typ:city>' + add.city + '</typ:city>';
                }
                if(add.unitType != ''){
                    SoapXMLBody = SoapXMLBody + '<typ:unitType>' + add.unitType + '</typ:unitType>';
                }
                if(add.zipCode != ''){
                    SoapXMLBody = SoapXMLBody + '<typ:zipCode>' + add.zipCode + '</typ:zipCode>';
                }
                if(add.state != ''){
                    SoapXMLBody = SoapXMLBody + '<typ:state>' + add.state + '</typ:state>';
                }
                if(add.unitNumber != ''){
                    SoapXMLBody = SoapXMLBody + '<typ:unitNumber>' + add.unitNumber + '</typ:unitNumber>';
                }
                if(add.zip4Code != ''){
                    SoapXMLBody = SoapXMLBody + '<typ:zip4Code>' + add.zip4Code + '</typ:zip4Code>';
                }
                if(add.streetAddress1 != ''){
                    SoapXMLBody = SoapXMLBody + '<typ:streetAddress1>' + add.streetAddress1 + '</typ:streetAddress1>';
                }
                if(add.streetAddress2 != ''){
                    SoapXMLBody = SoapXMLBody + '<typ:streetAddress2>' + add.streetAddress2 + '</typ:streetAddress2>';
                }
                SoapXMLBody = SoapXMLBody + '</typ:address>';      
            }
            SoapXMLBody = SoapXMLBody + '</m:getAddressInfoRequest>';
            SoapXMLBody = SoapXMLBody + '</m:getAddressInfo>';
            SoapXMLBody = SoapXMLBody + '</env:Body>';
            SoapXMLBody = SoapXMLBody + '</soapenv:Envelope>';
            
            String SoapXML;
            SoapXML = SoapXMLBody;
            SOAPRequest = SoapXMLBody;
            // Set Content Length
            Integer ContentLength = 0;
            ContentLength = SoapXML.length();
            
                  system.debug('soapXML~~~~'+soapXML);
                   system.debug('ContentLength~~~~'+ContentLength);
            
            // Initialize HTTP Class Objects
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            
            req.setMethod('POST');
            req.setEndPoint(Endpoint); 
            req.setHeader('Content-type','application/soap+xml');
            req.setTimeout(120000);//Timeout must be between 1 and 120000
            req.setHeader('Content-Length',ContentLength.format());
            req.setHeader('SoapAction','https://integration-soa.comcast.com/AccountManagementControllerService/1.34?wsdl');
            req.setBody(SoapXML);
            try{
                decimal dt1 = System.Now().getTime();
                res = h.send(req);
                decimal dt2 = System.Now().getTime();
                dt3 = (dt2-dt1)/1000;
                
            } catch(System.CalloutException e){
                System.debug('CalloutException Error: '+ e);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                return null;
            }
            serverResponse = res.ToString();
            SOAPResponse = res.ToString();
            
            // Update: US475373 - Integration log to be disabled
            // Sprint 5 
            /*Integration_Error_Log__c iLog = new Integration_Error_Log__c();
            iLog.Server_Response__c = serverResponse;
            iLog.Timestamp__c = String.ValueOf(system.now());
            iLog.Tracking_Id__c = trackingId;
            iLog.Response_Time__c = dt3;
            iLog.Type__c = Label.SuperAPI;
            if(!serverResponse.contains(Label.serverResponseSuccess)){
                iLog.Error_Exception__c = res.getBody();
            } 
            try{
            	
                //insert iLog; 
            } catch(Exception Ex){
                system.debug('>>>>> Following Exception Occured'+ Ex.getMessage());
            } */
            system.debug(res.getBody());
            responseBody = ''+ res.getBody();
            SOAPResponseBody = ''+ res.getBody();
            if(serverResponse.contains(Label.serverResponseSuccess)){
                parsedMessage = parse(responseBody);
                if(parsedMessage.contains(Label.ErrorString)){
                    return Label.Error;
                } else{
                    salesForceStatus = updateData(serverResponse, trackingId, dt3,add);
                    if(salesForceStatus == Label.Success){
                        return Label.Success;
                    } else {
                        return Label.Error;
                    }
                }
            } else {
                return Label.Error;
            }
        } else {
        	// Update: US475373 - Integration log to be disabled
            // Sprint 5
           /* Integration_Error_Log__c iLog = new Integration_Error_Log__c();
            iLog.Timestamp__c = String.ValueOf(system.now());
            iLog.Tracking_Id__c = trackingId;
            iLog.Error_Exception__c = Label.NoAddressParameterError;
            iLog.Response_Time__c = dt3;
            iLog.Type__c = Label.MobileAPI;
            try{
                //insert iLog;
            } catch(Exception Ex){
                system.debug('>>>>> Following Exception Occured'+ Ex.getMessage());
            }*/
            return 'Error';    
        }
    }
    public static String parse(String toParse) { 
        DOM.Document doc = new DOM.Document();        
        try{  
            doc.load(toParse);      
            DOM.XMLNode root = doc.getRootElement();  
            return walkThrough(root);  
        }catch (System.XMLException e) { 
            System.debug('XMLException : '+ e);
            return Label.ErrorString + e.getMessage(); 
        } catch(System.LimitException e){
            System.debug('LimitException : '+ e); 
            return Label.ErrorString + e.getMessage(); 
        } 
    }
    private static String walkThrough(DOM.XMLNode node) {
        String result = '\n';
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            result += 'Element: ' + node.getName();
            String attribute = '';
            if (node.getAttributeCount() > 0) { 
                for (Integer i = 0; i< node.getAttributeCount(); i++ ) {
                    attribute =  'attribute #' + i + ':' + node.getAttributeKeyAt(i) + '=' + node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
                }  
            }
            if(!attribute.Contains('nil=true')){
                // Validate if Account Information present in response
                if(node.getName() == 'accountInfo'){
                    accInfo = new AddressInformationUtility.AccountInfo();
                }
                // Check for Connect Status, badDebt only if Account Information present in response
                if(accInfo != null){
                    if(node.getName() == 'connectStatus'){
                        accInfo.connectStatus = new AddressInformationUtility.connectStatus();
                    }
                    if(node.getName() == 'badDebt'){
                        accInfo.badDebt = new AddressInformationUtility.badDebt();
                    }
                    if(accInfo.badDebt != null){
                        if(accInfo.badDebt.delinquent != null && accInfo.badDebt.delinquent.delinquent != null){
                            if(node.getName() == 'delinquent' && node.getParent().getName() == 'delinquent'){
                                AddressInformationUtility.Delinquent singleDelinquent = new AddressInformationUtility.Delinquent();
                                for (Dom.XMLNode child: node.getChildElements()) {
                                    if(child.getName() == 'amount' && child.getText().trim() != ''){
                                        singleDelinquent.amount = decimal.valueof(child.getText().trim());
                                        accInfo.badDebt.delinquent.delinquent.add(singleDelinquent);
                                    }
                                    if(child.getName() == 'bucket' && child.getText().trim() != ''){
                                        singleDelinquent.bucket = integer.valueof(child.getText().trim());
                                        if(singleDelinquent.amount != null){
                                            accInfo.badDebt.delinquent.delinquent[accInfo.badDebt.delinquent.delinquent.size()-1].bucket = singleDelinquent.bucket;
                                        } else{
                                            accInfo.badDebt.delinquent.delinquent.add(singleDelinquent);
                                        }
                                        singleDelinquent = new AddressInformationUtility.Delinquent();
                                    }
                                }
                            }
                        }
                        if(node.getName() == 'delinquent' && node.getParent().getName() == 'badDebt'){
                            accInfo.badDebt.delinquent = new AddressInformationUtility.ArrayOfDelinquent();
                            accInfo.badDebt.delinquent.delinquent = new List<AddressInformationUtility.delinquent>();
                        }
                        if(accInfo.badDebt.unreturnedEquipment != null && accInfo.badDebt.unreturnedEquipment.unreturnedEquipment != null){
                            if(node.getName() == 'unreturnedEquipment' && node.getParent().getName() == 'unreturnedEquipment'){
                                AddressInformationUtility.UnreturnedEquipment singleEquipment = new AddressInformationUtility.UnreturnedEquipment();
                                for (Dom.XMLNode child: node.getChildElements()) {
                                    if(child.getName() == 'equipmentUnreturnedCharge' && child.getText().trim() != ''){
                                        singleEquipment.equipmentUnreturnedCharge = decimal.valueof(child.getText().trim());
                                        accInfo.badDebt.unreturnedEquipment.unreturnedEquipment.add(singleEquipment);
                                        singleEquipment = new AddressInformationUtility.UnreturnedEquipment();
                                    }
                                }
                            }
                        }
                        if(node.getName() == 'unreturnedEquipment' && node.getParent().getName() == 'badDebt'){
                            accInfo.badDebt.unreturnedEquipment = new AddressInformationUtility.ArrayOfUnreturnedEquipment();
                            accInfo.badDebt.unreturnedEquipment.unreturnedEquipment = new List<AddressInformationUtility.unreturnedEquipment>();
                        }
                        if(node.getName() == 'writtenOff' && node.getParent().getName() == 'badDebt'){
                            accInfo.badDebt.writtenOff = new AddressInformationUtility.WrittenOff();
                            AddressInformationUtility.WrittenOff writtenOf = new AddressInformationUtility.WrittenOff();
                            for (Dom.XMLNode child: node.getChildElements()) {
                                if(child.getName() == 'amount' && child.getText().trim() != ''){
                                    writtenOf.amount = decimal.valueof(child.getText().trim());
                                    accInfo.badDebt.writtenOff = writtenOf;
                                }
                                if(child.getName() == 'writtenOffDate' && child.getText().trim() != ''){
                                    writtenOf.writtenOffDate = datetime.valueof(child.getText().trim());
                                    accInfo.badDebt.writtenOff = writtenOf;
                                    writtenOf = new AddressInformationUtility.WrittenOff();
                                }
                            }
                        }
                    }
                }
                
                // Validate if Customer Information present in response
                if(node.getName() == 'customerInfo'){
                    custInfo = new AddressInformationUtility.CustomerInfo();
                }
                
                
                // Check for customerPremisesEquipment only if Customer Information recieved in response
                if(custInfo != null){
                    if(custInfo.customerPremisesEquipment != null && custInfo.customerPremisesEquipment.customerPremisesEquipment != null){
                        if(node.getName() == 'customerPremisesEquipment' && node.getParent().getName() == 'customerPremisesEquipment'){
                            AddressInformationUtility.customerPremisesEquipment singlePremEquipment = new AddressInformationUtility.customerPremisesEquipment();
                            for (Dom.XMLNode child: node.getChildElements()) {
                                if(child.getName() == 'type' && child.getText().trim() != ''){
                                    singlePremEquipment.type_x = child.getText().trim();
                                    custInfo.customerPremisesEquipment.customerPremisesEquipment.add(singlePremEquipment);
                                }
                                if(child.getName() == 'make' && child.getText().trim() != ''){
                                    singlePremEquipment.make = child.getText().trim();
                                    if(singlePremEquipment.type_x != null){
                                        custInfo.customerPremisesEquipment.customerPremisesEquipment[custInfo.customerPremisesEquipment.customerPremisesEquipment.size()-1].make = singlePremEquipment.make;
                                    } else{
                                        custInfo.customerPremisesEquipment.customerPremisesEquipment.add(singlePremEquipment);
                                    }
                                }
                                if(child.getName() == 'model' && child.getText().trim() != ''){
                                    singlePremEquipment.model = child.getText().trim();
                                    if(singlePremEquipment.type_x != null || singlePremEquipment.make != null){
                                        custInfo.customerPremisesEquipment.customerPremisesEquipment[custInfo.customerPremisesEquipment.customerPremisesEquipment.size()-1].model = singlePremEquipment.model;
                                    } else{
                                        custInfo.customerPremisesEquipment.customerPremisesEquipment.add(singlePremEquipment);
                                    }
                                }
                                if(child.getName() == 'serialNumber' && child.getText().trim() != ''){
                                    singlePremEquipment.serialNumber = child.getText().trim();
                                    if(singlePremEquipment.type_x != null || singlePremEquipment.make != null 
                                        || singlePremEquipment.model != null){
                                        custInfo.customerPremisesEquipment.customerPremisesEquipment[custInfo.customerPremisesEquipment.customerPremisesEquipment.size()-1].serialNumber = singlePremEquipment.serialNumber;
                                    } else{
                                        custInfo.customerPremisesEquipment.customerPremisesEquipment.add(singlePremEquipment);
                                    }
                                }
                                if(child.getName() == 'active' && child.getText().trim() != ''){
                                    singlePremEquipment.active = boolean.valueof(child.getText().trim());
                                    if(singlePremEquipment.type_x != null || singlePremEquipment.make != null 
                                        || singlePremEquipment.model != null || singlePremEquipment.active != null){
                                        custInfo.customerPremisesEquipment.customerPremisesEquipment[custInfo.customerPremisesEquipment.customerPremisesEquipment.size()-1].active = singlePremEquipment.active;
                                    } else{
                                        custInfo.customerPremisesEquipment.customerPremisesEquipment.add(singlePremEquipment);
                                    }
                                    singlePremEquipment = new AddressInformationUtility.customerPremisesEquipment();
                                }                                   
                            }
                        }
                    }
                    if(node.getName() == 'customerPremisesEquipment' && node.getParent().getName() == 'customerInfo'){
                        custInfo.customerPremisesEquipment = new AddressInformationUtility.ArrayOfCustomerPremisesEquipment();  
                        custInfo.customerPremisesEquipment.customerPremisesEquipment = new List<AddressInformationUtility.customerPremisesEquipment>();
                    }
                }
                
                // Validate if Location Information present in response
                if(node.getName() == 'locationInfo'){
                    locInfo = new AddressInformationUtility.LocationInfo();
                }
                
                // Validate if Subscription Information present in response
                if(node.getName() == 'subscriptionInfo'){
                    subInfo = new AddressInformationUtility.SubscriptionInfo();
                }
                
                // Check for serviceLineItem only if Subscription Information recieved in response
                if(subInfo != null){
                    if(subInfo.serviceLineItem != null && subInfo.serviceLineItem.serviceLineItem != null){
                        if(node.getName() == 'serviceLineItem' && node.getParent().getName() == 'serviceLineItem'){
                            AddressInformationUtility.serviceLineItem singleServiceAsset = new AddressInformationUtility.serviceLineItem();
                            for (Dom.XMLNode child: node.getChildElements()) {
                                if(child.getName() == 'serviceType' && child.getText().trim() != ''){
                                    singleServiceAsset.serviceType = child.getText().trim();
                                    subInfo.serviceLineItem.serviceLineItem.add(singleServiceAsset);
                                }
                                if(child.getName() == 'tier' && child.getText().trim() != ''){
                                    singleServiceAsset.tier = child.getText().trim();
                                    if(singleServiceAsset.serviceType != null){
                                        subInfo.serviceLineItem.serviceLineItem[subInfo.serviceLineItem.serviceLineItem.size()-1].tier = singleServiceAsset.tier;
                                    } else{
                                        subInfo.serviceLineItem.serviceLineItem.add(singleServiceAsset);
                                    }
                                }
                                if(child.getName() == 'activatedDate' && child.getText().trim() != ''){
                                    singleServiceAsset.activatedDate = Date.valueOf(child.getText().trim());
                                    if(singleServiceAsset.serviceType != null || singleServiceAsset.tier != null){
                                        subInfo.serviceLineItem.serviceLineItem[subInfo.serviceLineItem.serviceLineItem.size()-1].activatedDate = singleServiceAsset.activatedDate;
                                    } else{
                                        subInfo.serviceLineItem.serviceLineItem.add(singleServiceAsset);
                                    }
                                }
                                if(child.getName() == 'rate' && child.getText().trim() != ''){
                                    singleServiceAsset.rate = Decimal.ValueOf(child.getText().trim());
                                    if(singleServiceAsset.serviceType != null || singleServiceAsset.tier != null 
                                        || singleServiceAsset.activatedDate != null){
                                        subInfo.serviceLineItem.serviceLineItem[subInfo.serviceLineItem.serviceLineItem.size()-1].rate = singleServiceAsset.rate;
                                    } else{
                                        subInfo.serviceLineItem.serviceLineItem.add(singleServiceAsset);
                                    }
                                }
                            }
                        }
                    }
                    if(node.getName() == 'serviceLineItem' && node.getParent().getName() == 'subscriptionInfo'){
                        subInfo.serviceLineItem = new AddressInformationUtility.ArrayOfServiceLineItem();   
                        subInfo.serviceLineItem.serviceLineItem = new List<AddressInformationUtility.serviceLineItem>();
                    }
                }
                if (node.getText().trim() != '') {
                    result += ', text=' + node.getText().trim();
                    if(accInfo != null){
                        if(node.getName() == 'accountNumber'){
                            accInfo.accountNumber = node.getText().trim();
                        }
                        // If Count Status information is present the fetch the inner values
                        if(accInfo.connectStatus != null){
                            if(node.getName() == 'status'){
                                accInfo.connectStatus.status = node.getText().trim();
                            }
                            if(node.getName() == 'eventDate'){
                                accInfo.connectStatus.eventDate = date.valueof(node.getText().trim());
                            }
                            if(node.getName() == 'disconnectReason'){
                                accInfo.connectStatus.disconnectReason = node.getText().trim();
                            }
                            if(node.getName() == 'statusDetail'){
                                accInfo.connectStatus.statusDetail = node.getText().trim();
                            }
                        }
                        // If BadDebt information is present the fetch the inner values
                        if(accInfo.badDebt != null){
                            if(node.getName() == 'totalAccountBadDebt' && node.getParent().getName() == 'badDebt'){
                                accInfo.badDebt.totalAccountBadDebt = decimal.valueof(node.getText().trim());
                            }
                        }
                    }   
                    if(custInfo != null){   
                        if(node.getName() == 'doNotKnock'){
                            custInfo.doNotKnock = boolean.valueof(node.getText().trim());
                        }
                    }
                    if(locInfo != null){    
                        if(node.getName() == 'propertyCode'){
                            locInfo.propertyCode = node.getText().trim();
                        }
                        if(node.getName() == 'neverHouse'){
                            locInfo.neverHouse = boolean.valueof(node.getText().trim());
                        }
                    }
                    if(subInfo != null){    
                        if(node.getName() == 'totalMonthlyRate'){
                            subInfo.totalMonthlyRate = decimal.valueOf(node.getText().trim());
                        }
                    }
                }
            }
            if (node.getAttributeCount() > 0) { 
                for (Integer i = 0; i< node.getAttributeCount(); i++ ) {
                    result += ', attribute #' + i + ':' + node.getAttributeKeyAt(i) + '=' + node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
                }  
            }
            attribute = '';
            for (Dom.XMLNode child: node.getChildElements()) {
                result += walkThrough(child);
            }
            return result;
        }
        return '';  //should never reach here 
    }
    public static String updateData(String serverResponse, String trackingId, Decimal dt3, cAddress add){
        system.debug('add in side update Data'+add);
        Boolean delqAmountFlag = false;
        Boolean eqipAmountFlag = false;
        Boolean wOffFlag = false;
        Boolean newServiceFlag = true;
        Boolean newEquipmentFlag = true;
        Boolean accountFlag = false;
        //Boolean newAccountFlag = false;
        Boolean fetchedProductsFlag = false;
        Account acc;
        Customer_Address__c cAdd;
        List<Asset> equipmentList;
        List<Asset> serviceList;
        Map<String,Id> productNamebyIdMap = new Map<String,Id>();
        system.debug(accInfo);
        if(accInfo != null){
            // Fetching the address information
            try{
                if(add.billingHouseKey != ''){
                    cAdd = [Select Id, Name, Status__c, Region__c, Division, Do_not_Knock__c,Account__c, Billing_House_Key__c, Property_Code__c, Country__c, City__c, Disconnected__c, State__c, PostalCode__c from Customer_Address__c where Billing_House_Key__c =: add.billingHouseKey limit 1];  
                } else if (add.locationId != ''){
                    cAdd = [Select Id, Name, Division, Region__c, Status__c, Do_not_Knock__c, Account__c, Billing_House_Key__c, Property_Code__c, Country__c, City__c, Disconnected__c, State__c, PostalCode__c from Customer_Address__c where Location_ID__c =: add.locationId limit 1];  
                } else{
                    String addressQuery = 'Select Id, Division, Region__c, Name, Status__c, Do_not_Knock__c, Billing_House_Key__c, Country__c, Disconnected__c, City__c, State__c, PostalCode__c, Account__c, Property_Code__c from Customer_Address__c';
                    boolean whereFlag = false;
                    if(add.country != ''){
                        if(!whereFlag){
                            addressQuery = addressQuery + ' where';
                            whereFlag = true;
                        } else {
                            addressQuery = addressQuery + ' AND';
                        }
                        addressQuery = addressQuery + ' Country__c =\'' +add.country + '\'';
                    }
                    if(add.city != ''){
                        if(!whereFlag){
                            addressQuery = addressQuery + ' where';
                            whereFlag = true;
                        } else {
                            addressQuery = addressQuery + ' AND';
                        }
                        addressQuery = addressQuery + ' City__c =\'' + add.city + '\'';
                    }
                    if(add.zipCode != ''){
                        if(!whereFlag){
                            addressQuery = addressQuery + ' where';
                            whereFlag = true;
                        } else {
                            addressQuery = addressQuery + ' AND';
                        }
                        addressQuery = addressQuery + ' PostalCode__c =\'' +  add.zipCode + '\'';
                    }
                    if(add.state != ''){
                        if(!whereFlag){
                            addressQuery = addressQuery + ' where';
                            whereFlag = true;
                        } else {
                            addressQuery = addressQuery + ' AND';
                        }
                        addressQuery = addressQuery + ' State__c =\'' +add.state + '\'';
                    }
                    if(add.zip4Code != ''){
                        if(!whereFlag){
                            addressQuery = addressQuery + ' where';
                            whereFlag = true;
                        } else {
                            addressQuery = addressQuery + ' AND';
                        }
                        addressQuery = addressQuery + ' PostalCode_4__c =\'' + add.zip4Code + '\'';
                    }
                    if(add.streetAddress1 != ''){
                        if(!whereFlag){
                            addressQuery = addressQuery + ' where';
                            whereFlag = true;
                        } else {
                            addressQuery = addressQuery + ' AND';
                        }
                        addressQuery = addressQuery + ' Address__c =\'' + add.streetAddress1 + '\'';
                    }
                    if(add.streetAddress2 != ''){
                        if(!whereFlag){
                            addressQuery = addressQuery + ' where';
                            whereFlag = true;
                        } else {
                            addressQuery = addressQuery + ' AND';
                        }
                        addressQuery = addressQuery + ' Address_2__c =\'' + add.streetAddress2 + '\'';
                    }
                    addressQuery = addressQuery + ' limit 1';
                    system.debug('>>>>>>>addressQuery' +addressQuery);
                    cAdd = Database.Query(addressQuery);
                }
            }catch (System.QueryException qE){
                system.debug('>>>>> Following Exception Occured'+ qE.getMessage());
                return Label.ErrorString + qE.getMessage(); 
            }
            // Checking if Account Information present in the response
            if(accInfo.accountNumber != null){
                try{
                    system.debug(add.billingHouseKey);
                    system.debug(add.locationId);
                    if(add.billingHouseKey != ''){
                        acc = [Select Id, Name, Region__c, Installation_Status__c, Customer_Status__c, Billing_Account_key__c,Last_Disconnected_Date__c, Disconnected__c, Last_Install_Date__c, Division, billingCity, billingState, billingStreet, billingPostalCode, billingCountry, Disconnect_Reason__c, Past_Due_Balance__c, Write_Off_Amount__c, Total_Monthly_Rate__c from Account where Id =: cAdd.Account__c limit 1];
                    } else if (add.locationId != ''){
                        acc = [Select Id, Name, Region__c, Division, Installation_Status__c, Customer_Status__c, Billing_Account_key__c,Disconnected__c, Last_Install_Date__c, billingCity, billingState, billingStreet, billingPostalCode, billingCountry,Last_Disconnected_Date__c, Disconnect_Reason__c, Past_Due_Balance__c, Write_Off_Amount__c, Total_Monthly_Rate__c from Account where Id =: cAdd.Account__c limit 1];
                    } else {
                        acc = [Select Id, Name, Region__c, Installation_Status__c, Customer_Status__c, Billing_Account_key__c, Last_Disconnected_Date__c, Disconnected__c, Last_Install_Date__c, billingCity, billingState, billingStreet, billingPostalCode, billingCountry, Division, Disconnect_Reason__c, Past_Due_Balance__c, Write_Off_Amount__c, Total_Monthly_Rate__c from Account where Id =: cAdd.Account__c limit 1];
                    }
                    if(acc!=null){
                        accountFlag=true;
                    }
                }catch (System.QueryException qE){
                    system.debug('>>>>> Following Exception Occured'+ qE.getMessage());
                    /*newAccountFlag = true;
                    acc = new Account();
                    acc.Name = 'LastName HOME';
                    acc.House_Key__c = add.billingHouseKey;
                    acc.LocationID__c = add.locationId;
                    acc.Region__c = cAdd.Region__c;
                    acc.Service_Address__c = cAdd.Id;
                    acc.BillingCity = cAdd.City__c;
                    acc.BillingCountry = cAdd.Country__c;
                    acc.BillingState = cAdd.State__c;
                    acc.BillingStreet = cAdd.Name;
                    acc.BillingPostalCode = cAdd.PostalCode__c;*/
                } 
                //acc.Billing_Account_key__c = accInfo.accountNumber;
                //cAdd.Billing_Account_key__c = accInfo.accountNumber;
            } else{
                accountFlag = false;
            }
            if(accInfo.ConnectStatus != null){
                if(accInfo.ConnectStatus.status != null){
                    if(accInfo.ConnectStatus.status == 'ACTIVE'){
                        if(accountFlag){
                                if(acc.Customer_Status__c != 'Former'){
                                    acc.Customer_Status__c = Label.Active;
                                }
                            } /*else {

                               /* if(!newAccountFlag){
                                    newAccountFlag = true;
                                    acc = new Account();
                                    acc.Name = 'LastName HOME';
                                    acc.House_Key__c = add.billingHouseKey;
                                    acc.LocationID__c = add.locationId;
                                    acc.Region__c = cAdd.Region__c;
                                    acc.Service_Address__c = cAdd.Id;
                                    acc.Billing_Account_key__c = accInfo.accountNumber;
                                    acc.Customer_Status__c = Label.Active;
                                    acc.BillingCity = cAdd.City__c;
                                    acc.BillingCountry = cAdd.Country__c;
                                    acc.BillingState = cAdd.State__c;
                                    acc.BillingStreet = cAdd.Name;
                                    acc.BillingPostalCode = cAdd.PostalCode__c;
                                }
                            }
                            }*/
//                        cAdd.Status__c = Label.Active;
                    } else if(accInfo.ConnectStatus.status == 'INACTIVE'){
                        if(accountFlag){
                            acc.Customer_Status__c = Label.Former;
                        }
                     //   cAdd.Status__c = Label.Former;
                    }
                }
                if(accountFlag){
                    acc.Installation_Status__c = accInfo.ConnectStatus.statusDetail;
                    if(accInfo.ConnectStatus.statusDetail == 'PENDING_INSTALL' ||
                        accInfo.ConnectStatus.statusDetail == 'PENDING_RESTART' ||
                        accInfo.ConnectStatus.statusDetail == 'PENDING_DISCONNECT' ||
                        accInfo.ConnectStatus.statusDetail == 'ACTIVE'){
                        acc.Last_Install_Date__c = accInfo.ConnectStatus.eventDate;
                    } else if (accInfo.ConnectStatus.statusDetail == 'DISCONNECTED' || 
                                accInfo.ConnectStatus.statusDetail == 'CHARGED_OFF') {
                        acc.Last_Disconnected_Date__c = accInfo.ConnectStatus.eventDate;
                        if(accInfo.ConnectStatus.eventDate != null){
                            acc.Disconnected__c = true;
                            cAdd.Disconnected__c = true;
                        }
                    } else {
                        acc.Last_Disconnected_Date__c = accInfo.ConnectStatus.eventDate;
                    }
                    acc.Disconnect_Reason__c = accInfo.ConnectStatus.disconnectReason;
                }
            } else if(accInfo.ConnectStatus == null && accountFlag){
                acc.Last_Disconnected_Date__c = null;
                acc.Disconnect_Reason__c = null;
            }
            /*if(accInfo.badDebt != null && accountFlag){
                if(accInfo.badDebt.delinquent != null && accInfo.badDebt.delinquent.delinquent != null){
                    for(AddressInformationUtility.delinquent delq : accInfo.badDebt.delinquent.delinquent){
                        if(delq.amount > 0){
                            delqAmountFlag = true;
                            break;
                        }
                    }    
                }
                if(accInfo.badDebt.unreturnedEquipment != null && accInfo.badDebt.unreturnedEquipment.unreturnedEquipment != null){
                    for(AddressInformationUtility.unreturnedEquipment eqip : accInfo.badDebt.unreturnedEquipment.unreturnedEquipment){
                        if(eqip.equipmentUnreturnedCharge > 0){
                            eqipAmountFlag = true;
                            break;
                        }
                    }    
                } 
                if(accInfo.badDebt.writtenOff != null){
                    if(accInfo.badDebt.writtenOff.amount != null &&  accInfo.badDebt.writtenOff.amount> 0){
                            acc.Write_Off_Amount__c = accInfo.badDebt.writtenOff.amount;
                    } else {
                        acc.Write_Off_Amount__c = 0;
                    }
                } else {
                    acc.Write_Off_Amount__c = 0;
                }
                if(accInfo.badDebt.totalAccountBadDebt != null && (delqAmountFlag || eqipAmountFlag)){
                    acc.Past_Due_Balance__c = accInfo.badDebt.totalAccountBadDebt;
                } else{
                     acc.Past_Due_Balance__c = 0;
                }
            } else if (accInfo.badDebt == null && accountFlag){
                acc.Past_Due_Balance__c = 0;
                acc.Write_Off_Amount__c = 0;
            }          
            if(custInfo != null){
                if(custInfo.donotKnock != null){
                    cAdd.Do_Not_Knock__c = custInfo.doNotknock;
                }
                if(CustInfo.CustomerPremisesEquipment != null && accountFlag){
                    try{
                        equipmentList = new List<Asset>();
                        if(acc.Id != null){
                            equipmentList = [Select Id, Name, Make__c, AccountId, Product2Id, Product2.Name, IsUpdated__c, Model__c,Type__c, SerialNumber, Status, InstallDate, Price from Asset where AccountId =: acc.Id
                                        AND Type__c =: Label.Asset_Equipment]; 
                        }
                        for(Product2 prod: [Select Id, Name from Product2 Limit 50000]){
                            productNamebyIdMap.put(prod.Name,prod.Id);
                        }
                        if(!productNamebyIdMap.IsEmpty()){
                            fetchedProductsFlag = true;
                        }
                        for(AddressInformationUtility.CustomerPremisesEquipment equipment : CustInfo.CustomerPremisesEquipment.CustomerPremisesEquipment){
                            newEquipmentFlag = true;
                            if(equipmentList != null && !equipmentList.IsEmpty()){
                                for(Asset eqp : equipmentList){
                                    if(eqp.Product2Id != null && eqp.Name == equipment.type_x){
                                        eqp.Make__c = equipment.make;
                                        eqp.Model__c = equipment.model;
                                        eqp.IsUpdated__c = true;
                                        if(equipment.active){
                                            eqp.Status = Label.Active;
                                        } else{
                                            eqp.Status = Label.Asset_Inactive;
                                        }
                                        eqp.Type__c = Label.Asset_Equipment;
                                        eqp.SerialNumber = equipment.serialNumber;
                                        newEquipmentFlag = false;
                                    } 
                                }
                            }
                            if(newEquipmentFlag){
                                Asset equip = new Asset();
                                equip.Name = equipment.type_x;
                                equip.Make__c = equipment.make;
                                equip.Model__c = equipment.model;
                                equip.IsUpdated__c = true;
                                if(equipment.active){
                                    equip.Status = Label.Active;
                                } else{
                                    equip.Status = Label.Asset_Inactive;
                                }
                                equip.Type__c = Label.Asset_Equipment;
                                equip.SerialNumber = equipment.serialNumber;
                                if(productNamebyIdMap.containsKey(Label.Asset_Equipment)){
                                    equip.Product2Id = productNamebyIdMap.get(Label.Asset_Equipment);
                                }
                                equipmentList.add(equip);
                            }
                        }
                        if(equipmentList != null && !equipmentList.IsEmpty()){
                            for(Asset eqp : equipmentList){
                                if(!eqp.IsUpdated__c){
                                    eqp.Status = Label.Asset_Inactive;
                                }if(eqp.IsUpdated__c){
                                    eqp.IsUpdated__c = false;
                                }
                            }
                        }
                    }catch (System.QueryException qE){
                        system.debug('>>>>> Following Exception Occured'+ qE.getMessage());
                    }catch(Exception ex){Integration_Error_Log__c iLog = new Integration_Error_Log__c();iLog.Error_Exception__c = ex.getMessage();iLog.Server_Response__c = serverResponse;iLog.Timestamp__c = String.ValueOf(system.now());iLog.Tracking_Id__c = trackingId;iLog.Response_Time__c = dt3;iLog.Type__c = Label.SFDC;try{insert iLog;return Label.ErrorString + ex.getMessage();} catch(Exception Exc){system.debug('>>>>> Following Exception Occured'+ Exc.getMessage());}
                    }
                }else{
                    try{
                        equipmentList = new List<Asset>();
                        if(acc.Id != null){
                            equipmentList = [Select Id, Name,Make__c, Product2Id, AccountId, Product2.Name, IsUpdated__c, Model__c,Type__c, SerialNumber, Status, InstallDate, Price from Asset where AccountId =: acc.Id
                                        AND Type__c =: Label.Asset_Equipment]; 
                        }
                        if(equipmentList != null && !equipmentList.IsEmpty()){
                            for(Asset e : equipmentList){
                                e.Status = Label.Asset_Inactive;
                                e.IsUpdated__c = false;
                            }
                        }           
                    }catch (System.QueryException qE){
                        system.debug('>>>>> Following Exception Occured'+ qE.getMessage());
                    }catch (Exception dmlE){Integration_Error_Log__c iLog = new Integration_Error_Log__c();iLog.Error_Exception__c = dmlE.getMessage();iLog.Server_Response__c = serverResponse;iLog.Timestamp__c = String.ValueOf(system.now());iLog.Tracking_Id__c = trackingId;iLog.Response_Time__c = dt3;iLog.Type__c = Label.SFDC;try{insert iLog;return Label.ErrorString + dmlE.getMessage();} catch(Exception Exc){system.debug('>>>>> Following Exception Occured'+ Exc.getMessage());}
                    }
                }
            } else if(custInfo == null){
                cAdd.Do_Not_Knock__c = false;
                if(accountFlag){
                    try{
                        equipmentList = new List<Asset>();
                        if(acc.Id != null){
                            equipmentList = [Select Id, Name,Make__c, Product2Id, Product2.Name, AccountId, IsUpdated__c, Model__c,Type__c, SerialNumber, Status, InstallDate, Price from Asset where AccountId =: acc.Id
                                        AND Type__c =: Label.Asset_Equipment]; 
                        }
                        if(equipmentList != null && !equipmentList.IsEmpty()){
                            for(Asset e : equipmentList){
                                e.Status = Label.Asset_Inactive;
                                e.IsUpdated__c = false;
                            }
                        }           
                    }catch (System.QueryException qE){
                        system.debug('>>>>> Following Exception Occured'+ qE.getMessage());
                    }catch (Exception dmlE){Integration_Error_Log__c iLog = new Integration_Error_Log__c();iLog.Error_Exception__c = dmlE.getMessage();iLog.Server_Response__c = serverResponse;iLog.Timestamp__c = String.ValueOf(system.now());iLog.Tracking_Id__c = trackingId;iLog.Response_Time__c = dt3;iLog.Type__c = Label.SFDC;try{insert iLog;return Label.ErrorString + dmlE.getMessage();} catch(Exception Exc){system.debug('>>>>> Following Exception Occured'+ Exc.getMessage());}
                    }
                }
            }
            if(locInfo != null){
                cAdd.Property_Code__c = locInfo.propertyCode;
                if(locInfo.neverHouse != null){
                    if(locInfo.neverHouse == true){
//                        cAdd.Status__c = Label.Never;
                    }
                }
            }
            if(subInfo != null && accountFlag){
                acc.Total_Monthly_Rate__c = subInfo.totalMonthlyRate;
                if(subInfo.ServiceLineItem != null){
                    try{
                        serviceList = new List<Asset>();
                        if(acc.Id != null){
                            serviceList = [Select Id, Name, Make__c,IsUpdated__c, Model__c,Type__c, SerialNumber,Product2Id, Product2.Name, Status, InstallDate, AccountId, Price from Asset where AccountId =: acc.Id
                                AND Type__c =: Label.Asset_Service]; 
                        }
                        if(!fetchedProductsFlag){       
                            for(Product2 prod: [Select Id, Name from Product2 Limit 50000]){
                                productNamebyIdMap.put(prod.Name,prod.Id);
                            }
                        }
                        for(AddressInformationUtility.serviceLineItem service : subInfo.serviceLineItem.serviceLineItem){
                            newServiceFlag = true;
                            if(serviceList != null && !serviceList.IsEmpty()){
                                for(Asset ser : serviceList){
                                    if(ser.Product2Id != null && ser.Product2.Name == service.serviceType){
                                        if(!ser.IsUpdated__c){
                                            ser.Name = service.tier;
                                            ser.InstallDate = service.activatedDate;
                                            if(service.rate != null){
                                                ser.Price = service.rate;
                                            } else {
                                                ser.Price = 0;
                                            }
                                            ser.IsUpdated__c = true;
                                            ser.Status = Label.Active;
                                            ser.Type__c = Label.Asset_Service;
                                            newServiceFlag = false;
                                        }else{
                                            newServiceFlag = false;
                                            Integration_Error_Log__c iLog = new Integration_Error_Log__c();
                                            iLog.Error_Exception__c = Label.Multiple_LOB_Error + '(' + service.serviceType +')';
                                            iLog.Server_Response__c = serverResponse;
                                            iLog.Timestamp__c = String.ValueOf(system.now());
                                            iLog.Tracking_Id__c = trackingId;
                                            iLog.Type__c = Label.SuperAPI;
                                            try{
                                                insert iLog;
                                                return Label.ErrorString + Label.Multiple_LOB_Error + '(' + service.serviceType +')';
                                            } catch(Exception Exc){
                                                system.debug('>>>>> Following Exception Occured'+ Exc.getMessage());
                                            }
                                        }
                                    } 
                                }
                            }
                            if(newServiceFlag){
                                Asset serv = new Asset();
                                serv.Name = service.tier;
                                serv.InstallDate = service.activatedDate;
                                if(service.rate != null){
                                    serv.Price = service.rate;
                                } else {
                                    serv.Price = 0;
                                }
                                serv.IsUpdated__c = true;
                                serv.Status = Label.Active;
                                serv.Type__c = Label.Asset_Service;
                                if(productNamebyIdMap.containsKey(service.serviceType)){
                                    serv.Product2Id = productNamebyIdMap.get(service.serviceType);
                                }
                                serviceList.add(serv);
                            }
                        }
                        if(serviceList != null && !serviceList.IsEmpty()){
                            for(Asset ser : serviceList){
                                if(!ser.IsUpdated__c){
                                    ser.Status = Label.Asset_Inactive;
                                }if(ser.IsUpdated__c){
                                    ser.IsUpdated__c = false;
                                }
                            }
                        }
                    }catch (System.QueryException qE){
                        system.debug('>>>>> Following Exception Occured'+ qE.getMessage());
                    } catch(Exception ex){Integration_Error_Log__c iLog = new Integration_Error_Log__c();iLog.Error_Exception__c = ex.getMessage();iLog.Server_Response__c = serverResponse;iLog.Timestamp__c = String.ValueOf(system.now());iLog.Tracking_Id__c = trackingId;iLog.Response_Time__c = dt3; iLog.Type__c = Label.SFDC;try{insert iLog;return Label.ErrorString + ex.getMessage();} catch(Exception Exc){system.debug('>>>>> Following Exception Occured'+ Exc.getMessage());}
                    }
                } else{
                    try{
                        serviceList = new List<Asset>();
                        if(acc.Id != null){
                            serviceList = [Select Id, Name, Make__c,IsUpdated__c, Model__c,Type__c, SerialNumber,Product2Id, 
                                        Product2.Name, Status, InstallDate, AccountId, Price from Asset where AccountId =: acc.Id
                                            AND Type__c =: Label.Asset_Service];
                        }
                        if(serviceList != null && !serviceList.IsEmpty()){
                            for(Asset ser : serviceList){
                                ser.Status = Label.Asset_Inactive;
                                ser.IsUpdated__c = false;
                            }
                        }           
                    }catch (System.QueryException qE){
                        system.debug('>>>>> Following Exception Occured'+ qE.getMessage());
                    }catch (Exception dmlE){Integration_Error_Log__c iLog = new Integration_Error_Log__c();iLog.Error_Exception__c = dmlE.getMessage();iLog.Server_Response__c = serverResponse;iLog.Timestamp__c = String.ValueOf(system.now());iLog.Tracking_Id__c = trackingId;iLog.Type__c = Label.SFDC;try{insert iLog;return Label.ErrorString + dmlE.getMessage();} catch(Exception Exc){system.debug('>>>>> Following Exception Occured'+ Exc.getMessage());}
                    }
                }
            } else if(subInfo == null && accountFlag){
                try{
                    serviceList = new List<Asset>();
                    if(acc.Id != null){
                        serviceList = [Select Id, Name, Make__c,IsUpdated__c, Model__c,Type__c, SerialNumber,Product2Id, 
                                    Product2.Name, Status, InstallDate, AccountId, Price from Asset where AccountId =: acc.Id
                                        AND Type__c =: Label.Asset_Service];
                    }
                    if(serviceList != null && !serviceList.IsEmpty()){
                        for(Asset ser : serviceList){
                            ser.Status = Label.Asset_Inactive;
                            ser.IsUpdated__c = false;
                        }
                    }           
                }catch (System.QueryException qE){
                    system.debug('>>>>> Following Exception Occured'+ qE.getMessage());
                }catch (Exception dmlE){Integration_Error_Log__c iLog = new Integration_Error_Log__c();iLog.Error_Exception__c = dmlE.getMessage();iLog.Server_Response__c = serverResponse;iLog.Timestamp__c = String.ValueOf(system.now());iLog.Tracking_Id__c = trackingId; iLog.Response_Time__c = dt3;iLog.Type__c = Label.SFDC;try{insert iLog;return Label.ErrorString + dmlE.getMessage();} catch(Exception Exc){system.debug('>>>>> Following Exception Occured'+ Exc.getMessage());}
                }
            } */          
        }
        try{
            system.debug(acc);
            if(acc != null){
                system.debug(acc);
                if(acc.Id == null){
                    acc.Created_By_Super_API__c = true;
                }
                Database.UpsertResult upRes = database.upsert(acc,false);
                if(upRes.isSuccess()){
                    if(cAdd.Account__c == null & accountFlag){
                        cAdd.Account__c = upRes.getId();
                    }
                    /*if(newAccountFlag){
                        cAdd.Account__c = upRes.getId();
                        Contact c = new Contact();
                        c.firstName = 'FirstName';
                        c.lastName = 'LastName';
                        c.Email = 'FirstName' + String.valueOf(Math.round(Math.random()*Math.pow(10, 6))) +
                                     String.valueOf(Math.round(Math.random()*Math.pow(10, 6))) + '@LastName.com';
//                        c.Status__c = 'Active';
                        c.AccountId = upRes.getId();
                        Database.SaveResult sRes = database.insert(c,false);
                        if(sRes.isSuccess()){
                            acc.Customer__c = sRes.getId();
                            update acc;
                        }
                    }*/
                    /*if(serviceList != null && !serviceList.IsEmpty()){
                        for(Asset ser: serviceList){
                            if(ser.AccountId == null){
                                ser.AccountId = upRes.getId();
                            }
                        }
                        Database.upsert(serviceList,false); 
                    }
                    if(equipmentList != null && !equipmentList.IsEmpty()){
                        for(Asset eq: equipmentList){
                            if(eq.AccountId == null){
                                eq.AccountId = upRes.getId();
                            }
                        }
                        Database.upsert(equipmentList,false); 
                    }*/
                }
            }
            if(cAdd != null){
                update cAdd;
            }
            // Update: US475373 - Integration log to be disabled
            // Sprint 5
        } catch(Exception ex){
        	/*Integration_Error_Log__c iLog = new Integration_Error_Log__c();
        	iLog.Error_Exception__c = ex.getMessage();
        	iLog.Server_Response__c = serverResponse;iLog.Timestamp__c = String.ValueOf(system.now());
        	iLog.Tracking_Id__c = trackingId;iLog.Type__c = 'SFDC';
        	iLog.Response_Time__c = dt3;
        	try{
        		insert iLog;
        		return Label.ErrorString + ex.getMessage();
        	} catch(Exception Exc){
        		
        	}*/
        	 system.debug('>>>>> Following Exception Occured'+ ex.getMessage());
         
       }
        return Label.Success;       
    }
}