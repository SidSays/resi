/************************************************************************************************************************************************************
Name: AccountManagementServiceCallout 
Description: This class calls the  ESP service to display PDF View of Bill.
Author: Lalit Singh Accenture
--------------- ------------------ ------------------------------
10 Oct 2015 Comcast 
Modification History: 02-28-2016 Accenture : Modified to fix the Error keyword from PDF blob 
*************************************************************************************************************************************************************/
public class AccountManagementServiceCallout
{
    //Variable Decalaration
    public static string billingAccountNumber = '';
    public static String endUrl ='';
    public static String userName = ''; 
    public static String password = ''; 
    public static String systemServiceId = ''; 
    public static String numberOfRecentMonths = '2';
    public String DsmStringData = '';
    public String DsmStringErrorMsg = ''; //String added to handle only error message
    public String pdfBlobData { get; set; }
    public static boolean checkrest = false;
    public static String errMaxPDFSizeMsg = 'Exceeded max size limit of 6000000';
    /**
    * Name: getPdfBlobData
    * Description: This method is used to return the pdfdata in the string to pass to the vf page. 
    * @parameters: None
    * @return: None
    **/
    public String getPdfBlobData() {
        return pdfBlobData ;
    }
   
    /**
    * Name: AccountManagementServiceCallout(String bilingAccountNumber)
    * Description:Parameterized constructor to pass the billingAccountNumber to the AccountManagementServiceRest class.
    * @parameters: None
    * @return: None
    **/
     public AccountManagementServiceCallout(String bilingAccountNumber){
        checkrest = true;
        initialiseConstantVariable();
        getHttpResponse(bilingAccountNumber);
    }
    
    /**
    * Name: AccountManagementServiceCallout
    * Description:constructor to pass the pdf data to page.
    * @parameters: None
    * @return: None
    **/
    public AccountManagementServiceCallout(){
        initialiseConstantVariable();
        billingAccountNumber = ApexPages.CurrentPage().getParameters().get('billingAccountNumber');
        getHttpResponse(billingAccountNumber);
    }
    
    /**
    * Name: getHttpResponse
    * Description:Method to pass the first request with the billingaccountnumber.
    * @parameters: String
    * @return: None
    **/
    public void getHttpResponse(String billingAccountNum){
    
        String todayDate = CalloutUtility.generateTimestamp();
        // Datetime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        //String trackingId = Datetime.now().format('yyyyMMddHH');
        String trackingId = CalloutUtility.generateTrackingId(); 
        String nonce = CalloutUtility.generateNonce();
        // Datetime.now().format('yyyyMMddHHmmssSSS');
        
        /*String soapEnvTemplate = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"';
               soapEnvTemplate +='xmlns:typ="http://xml.comcast.com/types"xmlns:ser="http://xml.comcast.com/accountmanagement/services"xmlns:typ1="http://xml.comcast.com/accountmanagement/types">';
               soapEnvTemplate +='<soapenv:Header><typ:requestHeader><typ:timestamp>{0}</typ:timestamp><typ:sourceSystemId>{1}</typ:sourceSystemId>';
               soapEnvTemplate +='<typ:sourceSystemUserId>{2}</typ:sourceSystemUserId><typ:sourceServerId>{3}</typ:sourceServerId><typ:trackingId>{4}</typ:trackingId>';
               soapEnvTemplate +='</typ:requestHeader><wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">';
               soapEnvTemplate +='<wsse:UsernameToken wsu:Id="UsernameToken-12"><wsse:Username>{5}</wsse:Username><wsse:Password>{6}</wsse:Password>';
               soapEnvTemplate +='<wsse:Nonce>{7}</wsse:Nonce><wsu:Created>{8}</wsu:Created></wsse:UsernameToken></wsse:Security></soapenv:Header>';
               soapEnvTemplate +='<soapenv:Body><ser:queryBill><!--Optional:--><ser:queryBillCriteria><typ1:billingArrangementID>{9}</typ1:billingArrangementID><typ1:numberOfRecentMonths>{10}</typ1:numberOfRecentMonths>';
               soapEnvTemplate +='</ser:queryBillCriteria></ser:queryBill></soapenv:Body></soapenv:Envelope>';*/
               
               //Added proper spaces after discussing with ESP services architech Sreekanth
        String soapEnvTemplate = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ';
               soapEnvTemplate +='xmlns:typ="http://xml.comcast.com/types" xmlns:ser="http://xml.comcast.com/accountmanagement/services" xmlns:typ1="http://xml.comcast.com/accountmanagement/types">';
               soapEnvTemplate +='<soapenv:Header><typ:requestHeader><typ:timestamp>{0}</typ:timestamp><typ:sourceSystemId>{1}</typ:sourceSystemId>';
               soapEnvTemplate +='<typ:sourceSystemUserId>{2}</typ:sourceSystemUserId><typ:sourceServerId>{3}</typ:sourceServerId><typ:trackingId>{4}</typ:trackingId>';
               soapEnvTemplate +='</typ:requestHeader><wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">';
               soapEnvTemplate +='<wsse:UsernameToken wsu:Id="UsernameToken-12"><wsse:Username>{5}</wsse:Username><wsse:Password>{6}</wsse:Password>';
               soapEnvTemplate +='<wsse:Nonce>{7}</wsse:Nonce><wsu:Created>{8}</wsu:Created></wsse:UsernameToken></wsse:Security></soapenv:Header>';
               soapEnvTemplate +='<soapenv:Body><ser:queryBill><!--Optional:--><ser:queryBillCriteria><typ1:billingArrangementID>{9}</typ1:billingArrangementID><typ1:numberOfRecentMonths>{10}</typ1:numberOfRecentMonths>';
               soapEnvTemplate +='</ser:queryBillCriteria></ser:queryBill></soapenv:Body></soapenv:Envelope>';
 

        
        
        List<String> params = new List<String>();
            
            params.add(todayDate);
            params.add(systemServiceId);
            params.add(userName);
            params.add(systemServiceId);
            params.add(trackingId);
            //system.debug('--trackingId--');
            params.add(userName);
            params.add(password);
            params.add(nonce);
            //system.debug('--trackingId--');
            params.add(todayDate);
            params.add(billingAccountNum);
            params.add(numberOfRecentMonths);
        
        String soapMsg = String.format(soapEnvTemplate, params);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endUrl);
        //Added headers after discussing with ESP services architech Sreekanth
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        req.setHeader('SOAPAction','queryBill');
        req.setMethod('POST');
//        req.setMethod('GET');
        req.setTimeout(Integer.ValueOf(System.Label.GetPDFTimeOut));
        req.setBody(soapMsg);
        //System.debug('*** REQUEST: '+ req.getBody());
        //System.debug('*** REQUEST String: '+ req.toString());
        Http http = new Http();
        HttpResponse resp = http.send(req);
        //System.debug('*** RESPONSE: '+ resp);
        //System.debug('*** RESPONSE Body: '+ resp.getBody());
        if(resp.getStatusCode() != 200){
            Dom.Document docExec = resp.getBodyDocument();
            Dom.XMLNode executeNodeDoc = docExec.getRootElement();
            String errorMessage = responseErrorLog(executeNodeDoc);
            String errorMessageToShow = 'Unable to retrieve the customers bill'+ errorMessage;
            // errorMessageToShow = errorMessageToShow + '\n\n' + req + '\n\n' + resp ;
            
            System.debug('ERROR RECEIVED' + errorMessage);
            
            if(!checkrest && errorMessage.containsIgnoreCase('error')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessageToShow));
            }            
            DsmStringErrorMsg = errorMessage;
        }else{
            getQueryBillResponse(resp);
        }
    }
    
    /**
    * Name: getQueryBillResponse
    * Description:Method to get the node value.
    * @parameters: HttpResponse 
    * @return: None
    **/   
    public void getQueryBillResponse(HttpResponse attachmentResp){                    
        
        Dom.Document doc = attachmentResp.getBodyDocument();       
        Dom.XMLNode getDetailRes = doc.getRootElement();                                                                
        Dom.XmlNode node = getDetailRes.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
        for (Dom.XMLNode child: node.getChildren()){          
           getRecursivelyQueryBillChilds(child);
        }
    }
    
    /**
    * Name: getRecursivelyQueryBillChilds
    * Description:Method to get the child from the node value.
    * @parameters: Dom.XMLNode
    * @return: None
    **/
    public void getRecursivelyQueryBillChilds(Dom.XMLNode node){        
       
       if(node.getNodeType() == DOM.XMLNodeType.ELEMENT) {                                      
            if(!'pdfId'.equalsIgnoreCase(node.getName())){                  
                for(Dom.XMLNode childField2 : node.getChildElements()){                                 
                   getRecursivelyQueryBillChilds(childField2);
                }         
            }else{                                                  
                getPdf(node.getText());        
            }
        }
    }
    
    /**
    * Name: getPdf
    * Description:Method to send the second request with the pdfid.
    * @parameters: String 
    * @return: None
    **/
    public void getPdf(String pdfId){
       
       String todayDate = CalloutUtility.generateTimestamp(); 
       // Datetime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
       //String trackingId = Datetime.now().format('yyyyMMddHH');
       String trackingId = CalloutUtility.generateTrackingId();
       // Datetime.now().format('yyyyMMddHHmmssSSS'); 
        String nonce = CalloutUtility.generateNonce();
        
       String soapEnvTemplate = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ';
       soapEnvTemplate +='xmlns:typ="http://xml.comcast.com/types" xmlns:ser="http://xml.comcast.com/accountmanagement/services" xmlns:typ1="http://xml.comcast.com/accountmanagement/types">';
       soapEnvTemplate +='<soapenv:Header><typ:requestHeader><typ:timestamp>{0}</typ:timestamp><typ:sourceSystemId>{1}</typ:sourceSystemId>';
       soapEnvTemplate +='<typ:sourceSystemUserId>{2}</typ:sourceSystemUserId><typ:sourceServerId>{3}</typ:sourceServerId><typ:trackingId>{4}</typ:trackingId></typ:requestHeader>';
       soapEnvTemplate +='<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">';
       soapEnvTemplate +='<wsse:UsernameToken wsu:Id="UsernameToken-12"><wsse:Username>{5}</wsse:Username><wsse:Password>{6}</wsse:Password><wsse:Nonce>{7}</wsse:Nonce><wsu:Created>{8}</wsu:Created>';
       soapEnvTemplate +='</wsse:UsernameToken></wsse:Security></soapenv:Header><soapenv:Body><ser:getBill><ser:getBillCriteria><typ1:pdfStatementID>{9}</typ1:pdfStatementID>';
       soapEnvTemplate +='<typ1:viewBillProfile>{10}</typ1:viewBillProfile></ser:getBillCriteria></ser:getBill></soapenv:Body></soapenv:Envelope>';
        
        
        List<String> params = new List<String>();
        
            params.add(todayDate);
            params.add(systemServiceId);
            params.add(userName);
            params.add(systemServiceId);
            params.add(trackingId);
            //system.debug('--trackingId--');
            params.add(userName);
            params.add(password);
            params.add(nonce);
            //system.debug('--nonce--');
            params.add(todayDate);
            params.add(pdfId);
            params.add('DOCUMENT_VIEW');
        
        String soapMsg = String.format(soapEnvTemplate, params);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endUrl);
//        req.setMethod('GET');
        //Added headers after discussing with ESP services architech Sreekanth
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        req.setHeader('SOAPAction','getBill');
        req.setMethod('POST');

        req.setTimeout(Integer.ValueOf(System.Label.GetPDFTimeOut));
        req.setBody(soapMsg);
        Http http = new Http();
        String errorMessage;
        String errorMessageToShow = 'Unable to retrieve the customers bill';
        try{
            HttpResponse resp = http.send(req);                 
            if(resp.getStatusCode() != 200){
                Dom.Document docExec = resp.getBodyDocument();
                Dom.XMLNode executeNodeDoc = docExec.getRootElement();            
                errorMessage = responseErrorLog(executeNodeDoc);
                errorMessageToShow +=  errorMessage;
            if(!checkrest && errorMessage.containsIgnoreCase('error')){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessageToShow));
            }
                DsmStringErrorMsg = errorMessage;  //Change the Variables to store the Error
            }else{
                getPdfResponseId(resp);
            }
            
        }catch(Exception e){
        if(e.getMessage().contains(errMaxPDFSizeMsg)){
            if(checkrest){
                DsmStringErrorMsg = errorMessageToShow;  //Change the Variables to store the Error message
            }
            else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,errorMessageToShow));
                DsmStringErrorMsg = errorMessageToShow;  //Change the Variables to store the Error message
            }
        }
      }
    }
    
    /**
    * Name: getPdfResponseId
    * Description:Method to get the node value of the response.
    * @parameters: HttpResponse 
    * @return: None
    **/
    public void getPdfResponseId(HttpResponse pdfAttachmentResp){                    
        
        Dom.Document doc = pdfAttachmentResp.getBodyDocument();       
        Dom.XMLNode getPdfDetailRes = doc.getRootElement();                                                                 
        Dom.XmlNode node = getPdfDetailRes.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');       
        for (Dom.XMLNode child: node.getChildren()) {          
           getRecursivelyPdfChilds(child);
        }                          
    }
    
    /**
    * Name: getRecursivelyPdfChilds
    * Description:Method to get the pdf  value of the response in a base 64 format string.
    * @parameters: HttpResponse 
    * @return: None
      * Modification History:
         *Modification 1:
           *Modification Description: US799797: Systems Engineering: AccountManagementServiceCallout Optimization
           *Modified By: Srini Bhattiprolu
           *Date: 5/1/2017
           *Sprint: 53
    **/
    public void getRecursivelyPdfChilds(Dom.XMLNode node){        
       
       if (node.getNodeType() == DOM.XMLNodeType.ELEMENT){                                     
            if(!'pdfStatementImage'.equalsIgnoreCase(node.getName())){                  
                    for(Dom.XMLNode childField2 : node.getChildElements()){                                 
                       getRecursivelyPdfChilds(childField2);
                  }
            }else{
            	// ***US799797 Start ***Added if-else block to differentiate accessing "View Bill" functionality from DSM and Salesforce
            	if (checkrest){
            	DsmStringData = node.getText();
            	}
                else{
                pdfBlobData = node.getText();
                }        
                // ***US799797 End ***
            }
        }
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
        numberOfRecentMonths = mapOfParamNameAndValue.get('numberOfRecentMonths');
       
    }
    
    /**
    * Name: responseErrorLog
    * Description: This method is used to capture the error while requesting ESP services. 
    * @parameters: 
    * @return: None
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
}