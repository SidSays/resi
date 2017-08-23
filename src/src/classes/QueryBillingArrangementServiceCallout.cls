public class QueryBillingArrangementServiceCallout {
 
    //Variable Decalaration
    public static String endUrl ='';
    public static String userName = ''; 
    public static String password = ''; 
    public static String systemServiceId = '';
    
     /**
    * Name: getHttpResponse
    * Description:Method to pass the first request with the billingHouseKey.
    * @parameters: String
    * @return: None
    **/
    public static List<String>  getHttpResponse(String billingHouseKey){
          
        initialiseConstantVariable();
        String todayDate = CalloutUtility.generateTimestamp();
        String trackingId = CalloutUtility.generateTrackingId(); 
        String nonce = CalloutUtility.generateNonce();
       
        String soapEnvTemplate = '<soapenv:Envelope xmlns:ser="http://xml.comcast.com/accountmanagement/services" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://xml.comcast.com/types" xmlns:typ1="http://xml.comcast.com/accountmanagement/types" xmlns:typ2="http://xml.comcast.com/common/types">' + 
            '<soapenv:Header>' + 
            '<typ:requestHeader>' + 
         '<typ:timestamp>{0}</typ:timestamp>' + 
         '<typ:sourceSystemId>{1}</typ:sourceSystemId>' + 
         '<typ:sourceSystemUserId>{2}</typ:sourceSystemUserId>' + 
         '<typ:sourceServerId>{3}</typ:sourceServerId>' + 
         '<typ:trackingId>{4}</typ:trackingId>' + 
            '</typ:requestHeader>' + 
            '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' + 
            '<wsse:UsernameToken wsu:Id="UsernameToken-12">' + 
         '<wsse:Username>{5}</wsse:Username>' + 
         '<wsse:Password>{6}</wsse:Password>' + 
            '<wsse:Nonce>{7}</wsse:Nonce>' + 
            '<wsu:Created>{8}</wsu:Created>' + 
            '</wsse:UsernameToken>' + 
            '</wsse:Security>' + 
            '</soapenv:Header>' + 
            '<soapenv:Body>' + 
            '<ser:queryBillingArrangement>' + 
            '<ser:queryBillingArrangementCriteria>' + 
            '<typ1:serviceAddress>' + 
               '<typ2:locationID>{9}</typ2:locationID>' + 
            '</typ1:serviceAddress>' + 
            '</ser:queryBillingArrangementCriteria>' + 
            '</ser:queryBillingArrangement>' + 
            '</soapenv:Body>' + 
            '</soapenv:Envelope>';
        
        List<String> params = new List<String>();
            
            params.add(todayDate);
            params.add(systemServiceId);
            params.add(Username);
            params.add(systemServiceId);
            params.add(trackingId);
            params.add(username);
            params.add(password);
            params.add(nonce);
            params.add(todayDate);
            params.add(billingHouseKey);
         
        
        String soapMsg = String.format(soapEnvTemplate, params);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endUrl);
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        req.setHeader('SOAPAction','queryBillingArrangement');
        //req.setMethod('POST');        
        req.setMethod('GET');
        req.setTimeout(45000);
        req.setBody(soapMsg);
        system.debug('*** Request '+req);
        Http http = new Http();
        HttpResponse resp = http.send(req);
        system.debug('resp***'+resp);
        if(resp.getStatusCode() != 200){
            Dom.Document docExec = resp.getBodyDocument();
            Dom.XMLNode executeNodeDoc = docExec.getRootElement();
           String errorMessage = responseErrorLog(executeNodeDoc);
           String errorMessageToShow = 'Unable to retrieve account history at this time: '+ errorMessage;
            return null;
         }else{
             return  getBillingHouseKeyResponse(resp);
        }
    }

    
     /**
    * Name: getBillingHouseKeyResponse
    * Description:Method to get the node value.
    * @parameters: HttpResponse 
    * @return: List<String>
    **/   
    public static List<String> getBillingHouseKeyResponse(HttpResponse attachmentResp){                    
        List<String> banList = new List<String>();
        Dom.Document doc= attachmentResp.getBodyDocument();       
        Dom.XMLNode envelope = doc.getRootElement();  
        Dom.XmlNode result  = envelope.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XmlNode queryBillingArrangementResponse = result.getChildElement('queryBillingArrangementResponse', 'http://xml.comcast.com/accountmanagement/services');
        Dom.XmlNode queryBillingArrangementReturn = queryBillingArrangementResponse.getChildElement('queryBillingArrangementReturn', 'http://xml.comcast.com/accountmanagement/services'); 
        Dom.XmlNode billingArrangement = null;
        for(dom.XmlNode node : queryBillingArrangementReturn.getChildElements()) 
        {
            if(node.getName() == 'billingArrangement')
            {
                String billingArrangementID = getNodeText(node, 'billingArrangementID', 'http://xml.comcast.com/common/types');
               
                banList.add(billingArrangementID );
            }
        }
        
        return banList ;
    }
    
    
    
    /**
    * Name: initialiseConstantVariable
    * Description: This method is used to Set The constant Variables values come from custom setting. 
    * @parameters: None
    * @return: None
    **/
    public static void initialiseConstantVariable(){
        Map<String, String> mapOfParamNameAndValue = new Map<String , String>();
        for(AccountManagementServiceCS__c objectCS : AccountManagementServiceCS__c.getall().values()){
            if(objectCS.Name != null){
                    if(objectCS.Param_Value__c != null){
                        mapOfParamNameAndValue.put(objectCS.Name,objectCS.Param_Value__c);
                    }else{
                        mapOfParamNameAndValue.put(objectCS.Name,'');
                    }
            }
        }
        endUrl = mapOfParamNameAndValue.get('Endurl');
        password = mapOfParamNameAndValue.get('Password');
        userName = mapOfParamNameAndValue.get('Username');    
        systemServiceId = mapOfParamNameAndValue.get('SystemServiceId');
     }
    
    
    /**
    * Name: responseErrorLog
    * Description: This method is used to capture the error while requesting ESP services. 
    * @parameters: 
    * @return: String
    **/
    public static String responseErrorLog(DOM.XMLNode node){
        
        MDU_EmptorisUtility.parsedValue = '';
        String finalResult ='';
        MDU_EmptorisUtility.parsedValue = '';
        String faultString = MDU_EmptorisUtility.parseResponse(node, 'text');
        String faultString2 = MDU_EmptorisUtility.parseResponse(node,MDU_Constants.FAULTSTRING);
        finalResult = '' + MDU_Constants.ERROR+ MDU_Constants.SEMICOLON  + MDU_Constants.ERROR_MESSAGE_STRING + faultString + faultString2;
        return finalResult;
    }
    
    /**
    * Name: getNodeText
    * Description: This method is used to get text of the node from ESP Response. 
    * @parameters: 
    * @return: String
    **/
    public static String getNodeText(dom.XmlNode parentNode, String nodeName, String schemaName)
    {
        String nodeText = '';
        
        if(parentNode != null)
        {
            DOM.XMLNode childNode = parentNode.getChildElement(nodeName, schemaName);
            if(childNode != null)
            {
                nodeText = childNode.getText().trim();
            }

        }
        return nodeText;
    }
    
    
    
}