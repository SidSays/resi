public class getBillingArrangement {
     
    
    //Variable Decalaration
    public static string billingAccountNumber = '';
    public static String endUrl ='';
    public static String userName = ''; 
    public static String password = ''; 
    public static String systemServiceId = '';
    public String DsmStringData = '';
    public static boolean checkrest = false;
    public set<String> billingAccountNumberList = new set<String>();
        
     public static List<ESPAccountContactHistory> getBillingArrangementRequest(String address)
    {
        try{
        List<String> billingAccNos;
        
        Customer_Address__c add=[select Id, Billing_House_Key__c, Billing_System__c,Account__r.Billing_Account_Number__c from Customer_Address__c where Id=:address];
        if(add.Billing_System__c=='CSG'){
           
            billingAccNos= QueryBillingArrangementServiceCallout.getHttpResponse(add.Billing_House_Key__c);
       }
        if(add.Billing_System__c=='DDP'){
           billingAccNos= BillingAccountNumberUtility.generateAccount(add.Account__r.Billing_Account_Number__c);
            
        }
            if(billingAccNos==null){
            List<ESPAccountContactHistory> accountDetails1 = new List<ESPAccountContactHistory>();
                return accountDetails1;}
        
        InitialiseConstantVariable();
        String banList = '';
        String todayDate = CalloutUtility.generateTimestamp();
        String trackingId = CalloutUtility.generateTrackingId();
        String nonce = CalloutUtility.generateNonce();
        integer i=0;
        for(String billingAccNo: billingAccNos)
        {i++;
            banList = banList + '<typ1:string>' + billingAccNo + '</typ1:string>';
            if(i==10){
                Break;
            }
            
        }
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
            '<ser:getBillingArrangement>' + 
            '<ser:getBillingArrangementRequest>' + 
            '<typ1:billingArrangementID>'+banList+'</typ1:billingArrangementID>' + 
            '<typ1:billingArrangementProfile>' + 
            '<typ1:billingArrangementProfile>ADVANCE</typ1:billingArrangementProfile>' +
            '<typ1:billingArrangementProfile>MONTHLY_RATE</typ1:billingArrangementProfile>' +
            '<typ1:billingArrangementProfile>CURRENT_BALANCE</typ1:billingArrangementProfile>' +                              
            '<typ1:billingArrangementProfile>BADDEBT_DETAIL</typ1:billingArrangementProfile>' + 
            '</typ1:billingArrangementProfile>' +
            '</ser:getBillingArrangementRequest>' +
            '</ser:getBillingArrangement>' + 
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
            params.add(banList);
         
        
        String soapMsg = String.format(soapEnvTemplate, params);
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endUrl);
        
        req.setHeader('Content-Type','text/xml;charset=UTF-8');
        req.setHeader('SOAPAction','getBillingArrangement');
        req.setMethod('GET');
       // req.setMethod('GET');
        req.setTimeout(45000);
        req.setBody(soapMsg);
        Http http = new Http();
        //System.debug('============');
        //System.debug('*** REQUEST  '+req);
        HttpResponse resp = http.send(req);
        if(resp.getStatusCode() != 200){
            Dom.Document docExec = resp.getBodyDocument();
            Dom.XMLNode executeNodeDoc = docExec.getRootElement();
            String errorMessage = responseErrorLog(executeNodeDoc);
            String errorMessageToShow = 'Unable to retrieve account history at this time: '+ errorMessage;
            errorMessageToShow = errorMessageToShow + '\n\n' + req + '\n\n' + resp ;
            system.debug('Error Message'+errorMessage);
            return null;
        }else{
          return getBillingArrangementDetails(resp);
          }
        }
        catch(Exception e){
             return null;  
          }
       }
     /**
    * Name: getBillingArrangementDetails
    * Description:Method to get the node value.
    * @parameters: HttpResponse 
    * @return: List<ESPAccountContactHistory>
    **/   
    public static  List<ESPAccountContactHistory> getBillingArrangementDetails(HttpResponse attachmentResp){  
        List<ESPAccountContactHistory> accountDetails = new List<ESPAccountContactHistory>();
        ESPAccountContactHistory accountInfo;
        Dom.Document doc = attachmentResp.getBodyDocument();
        Dom.XMLNode envelope  = doc.getRootElement();                                                                
        Dom.XmlNode node = envelope.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XmlNode queryBillingArrangementResponse = node.getChildElement('getBillingArrangementResponse', 'http://xml.comcast.com/accountmanagement/services');
        Dom.XmlNode queryBillingArrangementReturn = queryBillingArrangementResponse.getChildElement('getBillingArrangementReturn', 'http://xml.comcast.com/accountmanagement/services'); 
        for (Dom.XMLNode billingArrangement: queryBillingArrangementReturn.getChildren()){    
            if(billingArrangement.getName()=='billingArrangement'){
                accountInfo = new ESPAccountContactHistory();
            for (Dom.XMLNode fields: billingArrangement.getChildren()){
                if(fields.getName()=='billingArrangementID')
                accountInfo.billingAccountNumber = fields.getText();
                if(fields.getName()=='billingArrangementStatus')
                accountInfo.customerStatus = fields.getText();
                if(fields.getName()=='currentBalance'){
                    for (Dom.XMLNode currentBalance: fields.getChildren()){
                         if(currentBalance.getName()=='balance')
                            accountInfo.balance = currentBalance.getText();
                         if(currentBalance.getName()=='monthlyRateTotal')
                            accountInfo.monthlyRateTotal = currentBalance.getText();
                    }
                }
                if(fields.getName()=='connectStatus')
                accountInfo.installationStatus = fields.getText();
                if(fields.getName()=='disconnectDate')
                accountInfo.disconnectedDate = getDateFromESP(fields.getText());
               // String disconnectedDate = getDateFromESP(accountInfo.disconnectedDate);
                //system.debug('disconnectedDate'+accountInfo.disconnectedDate);
                
                if(fields.getName()=='dateCreated')
                accountInfo.lastInstallDate = getDateFromESP(fields.getText());
               // String lastInstallDate = getDateFromESP(accountInfo.lastInstallDate);
                //system.debug('lastInstallDate'+ accountInfo.lastInstallDate);
                if(fields.getName()=='badDebtDetail'){
                 for (Dom.XMLNode badDebtDetail: fields.getChildren()){
                         if(badDebtDetail.getName()=='writeOffAmount')
                            accountInfo.writeOffAmount = badDebtDetail.getText();
                  }
                }   
                if(fields.getName()=='billingPersonName'){
                   for (Dom.XMLNode billingPersonName: fields.getChildren()){
                         if(billingPersonName.getName()=='firstName')
                            accountInfo.FirstName = billingPersonName.getText();
                       if(billingPersonName.getName()=='lastName'){
                            accountInfo.LastName = billingPersonName.getText();
                            accountInfo.accountName=billingPersonName.getText()+ ' HOME';
                       }
                    }  
                    
                }
                if(fields.getName()=='billingEmailContact'){
                    accountInfo.eMail=new list<ESPAccountContactHistory.Email>();
                   for (Dom.XMLNode billingEmailContact: fields.getChildren()){
                       if(billingEmailContact.getName()=='emailContact'){
                           ESPAccountContactHistory.Email emp=new ESPAccountContactHistory.Email();
                           for (Dom.XMLNode emailContact: billingEmailContact.getChildren()){
                               if(emailContact.getName()=='emailContactType'){
                                   emp.emailContactType=emailContact.getText();
                               }
                               if(emailContact.getName()=='email'){
                                   for (Dom.XMLNode email: emailContact.getChildren()){
                                      if(email.getName()=='emailAddress')
                                       emp.email=email.getText();}
                               }
                           }
                           accountInfo.eMail.add(emp);
                       }
                   }  
                    
                }
                
                if(fields.getName()=='billingPhoneContact'){
                    accountInfo.phone=new list<ESPAccountContactHistory.Phone>();
                   for (Dom.XMLNode billingPhoneContact: fields.getChildren()){
                       if(billingPhoneContact.getName()=='phoneContact'){
                           ESPAccountContactHistory.Phone phonetemp=new ESPAccountContactHistory.Phone();
                           for (Dom.XMLNode phoneContact: billingPhoneContact.getChildren()){
                               if(phoneContact.getName()=='contactType'){
                                   phonetemp.contactType=phoneContact.getText();
                               }
                               if(phoneContact.getName()=='telephoneNumber'){
                                   phonetemp.telephoneNumber=new list<ESPAccountContactHistory.Telephone>();
                                   ESPAccountContactHistory.Telephone telePhone=new ESPAccountContactHistory.Telephone();
                                   for (Dom.XMLNode parseTelePhone: phoneContact.getChildren()){
                                    if(parseTelePhone.getName()=='areaCode')
                                    telePhone.areaCode=  parseTelePhone.getText();
                                       if(parseTelePhone.getName()=='phoneNumber')
                                    telePhone.phoneNumber=  parseTelePhone.getText();
                                       if(parseTelePhone.getName()=='extension')
                                    telePhone.extension=  parseTelePhone.getText();
                                   }
                                   phonetemp.telephoneNumber.add(telePhone);
                                 }
                           }
                           accountInfo.phone.add(phonetemp);
                       }
                   }  
                    
                }
            }  if(accountInfo.customerStatus!=null && accountInfo.customerStatus!='')
                accountDetails.add(accountInfo);
            }
        }
       
        return accountDetails;
    }
       
     public static  String getDateFromESP(String dateTZString )
    {
        String dateString = '';
        String tzString = '';
        Date myDate;
        String returnDate = dateTZString ; // input date
        
        if(!String.isBlank(dateTZString))
        {
            if(dateTZString.length() > 9)
            {
                dateString = dateTZString.substring(0,10);  
                myDate = Date.valueOf(dateString); 
                if(dateTZString.length() > 12)
                {
                    tzString = dateTZString.substring(11,13); 
                    if(!String.isEmpty(tzString)) 
                    {
                        myDate = mydate.addDays(-1);
                    }
                }
                // DateTime dt = new DateTime(myDate);
                DateTime dt = DateTime.newInstance(myDate.year(), myDate.month(), myDate.day());
                returnDate = dt.format('MM/dd/yyyy');
            }
        }
      
        return returnDate;
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