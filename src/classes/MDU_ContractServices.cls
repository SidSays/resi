/************************************************************************************************************************************************************
Name: MDU_ContractServices 
Description: This class holds the Contract Service Request.
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
25 Feb 2015 Comcast  
*************************************************************************************************************************************************************/
public Class MDU_ContractServices{
    
    public static String now = MDU_EmptorisUtility.SetNow();
    public static String dtTimeStr =now;
    public static Opportunity_Property__c objOpptyProperty = new Opportunity_Property__c();
    public static Set<String> setOfParsingValues = new Set<String>();
    public static String parsedValue ='';
    public static String finalResult ='';
    public static String hostStr ='';
    public static String sourceStr ;
    public static String algoStr;
    public static String shareSecret;
    public static String hostUrl;
    public static String emptorisAccount ;
    public static String usertodeletecontract;
    public static String getcontractuser_Endpoint ;
    public static String getcontract_Details_Endpoint ;
    public static String delete_Contract_Endpoint ;
    public static String get_Contract_Url_Endpoint ;
    public static String executionLog ='';
    public static DateTime startTime;
    private static final string CONTRACT_DELETE_VIEW_ERR  = System.Label.Contract_Delete_Error;
    public static boolean isEligibleForAppLogging = false;
    
    /**
    * Name: setRequestVariables
    * Description: This method is used to Set The Request Variables. 
    * @parameters: None
    * @return: None
    **/
    public static void setRequestVariables(){
        if(MDU_UserAppLoggingCS__c.getValues(UserInfo.getProfileId()) != null || MDU_UserAppLoggingCS__c.getValues(UserInfo.getUserId()) != null){
            isEligibleForAppLogging = true;
        }
        Map<String, String> mapOfParamNameAndValue = new Map<String , String>();
        for(MDU_EmptorisIntegrationCS__c objectCS : MDU_EmptorisIntegrationCS__c.getall().values()){
            if(objectCS.Param_Name__c != null){
                if(objectCS.Param_Value__c != null){
                    mapOfParamNameAndValue.put(objectCS.Param_Name__c,objectCS.Param_Value__c);
                }else{
                    mapOfParamNameAndValue.put(objectCS.Param_Name__c,'');
                }
            }
        }        
        hostStr = mapOfParamNameAndValue.get(MDU_Constants.HOSTSTR);
        sourceStr = mapOfParamNameAndValue.get(MDU_Constants.SOURCESTR);
        algoStr = mapOfParamNameAndValue.get(MDU_Constants.ALGOSTR);
        shareSecret = mapOfParamNameAndValue.get(MDU_Constants.SHARED_SECRET);
        getcontractuser_Endpoint = mapOfParamNameAndValue.get(MDU_Constants.GETCONTRACTUSER_ENDPOINT);
        emptorisAccount = mapOfParamNameAndValue.get(MDU_Constants.EMPTORISACCOUNT);
        usertodeletecontract = mapOfParamNameAndValue.get(MDU_Constants.USERTODELETECONTRACT);
        getcontract_Details_Endpoint = mapOfParamNameAndValue.get(MDU_Constants.GETCONTRACT_DETAILS_ENDPOINT);
        delete_Contract_Endpoint = mapOfParamNameAndValue.get(MDU_Constants.DELETE_CONTRACT_ENDPOINT);
        get_Contract_Url_Endpoint = mapOfParamNameAndValue.get(MDU_Constants.GET_CONTRACT_URL_ENDPOINT);
        hostUrl = mapOfParamNameAndValue.get(MDU_Constants.HOST_URL);
        
    }
    
    /**
    * Name: deleteContractProcess
    * Description: This method is used to initiate the delete contract service. 
    * @parameters: opptyPropertyId
    * @return: None
    **/ 
    public static String deleteContractProcess(String opptyPropertyId){
        setRequestVariables();
        startTime = System.Now();
        executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.DELETE_CONTRACT_PROCESS + startTime, executionLog , isEligibleForAppLogging);
        String userId ='';
        List<String> listOfParsingValues = new List<String>();
        if(opptyPropertyId != null && opptyPropertyId != ''){
            
            fetchOpptyPropertyData(opptyPropertyId);
            if(objOpptyProperty != null && objOpptyProperty.ECM__c != '' && objOpptyProperty.ECM__c != null){
                
                HTTPResponse getContractUserServiceResponse = getContractUser();
                Dom.Document getUserDoc = getContractUserServiceResponse.getBodyDocument();
                Dom.XMLNode getConractUserRes = getUserDoc.getRootElement();
                
                if(getContractUserServiceResponse.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
                    
                    if(MDU_ContractServices.bulkParseMethod(getConractUserRes,MDU_Constants.ID)!=null){
                        listOfParsingValues.addAll(MDU_ContractServices.bulkParseMethod(getConractUserRes,MDU_Constants.ID));
                        userId = listOfParsingValues[0];
                    }
                    system.debug('userId>>>>' + userId);
                    
                    HTTPResponse getContractDetailResponse = getContractDetails(objOpptyProperty.ECM__c);
                    
                    Dom.Document getContractDetailDoc = getContractDetailResponse.getBodyDocument();
                    Dom.XMLNode getContractDetailRes = getContractDetailDoc.getRootElement();  
                    
                    if(getContractDetailResponse.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
                        
                        Set<String> setOfPrimaryContactId = new Set<String>();
                        String getContactResult = MDU_ContractServices.parsingMethodForGetContactDetails(getContractDetailRes);                        
                        for(String str : getContactResult.split(';')){
                            if(str.split(':').size() > 1 && str.split(':')[0].trim().equalsIgnoreCase(MDU_Constants.PRIMARY_CONTACT_ID)){
                                setOfPrimaryContactId.add(str.split(':')[1].trim());
                            }
                        }
                        system.debug('setOfPrimaryContactId>>>>' + setOfPrimaryContactId);
                        
                        if(setOfPrimaryContactId.contains(userId)){
                        
                            HTTPResponse deleteContractResponse =  deleteContract(objOpptyProperty.ECM__c);
                            Dom.Document getContractURLDoc = deleteContractResponse.getBodyDocument();
                            Dom.XMLNode getContractURLRes = getContractURLDoc.getRootElement();
                            
                            if(deleteContractResponse.getStatusCode() != MDU_Constants.SUCCESSSTATUSCODE){                              
                                finalResult = MDU_EmptorisUtility.responseErrorLog(getContractURLRes);
                                if(isEligibleForAppLogging){
                                    executionLog += MDU_Constants.NL_ERROR +finalResult;
                                }
                            } else {
                                // IF Contract Deletion is successful, remove the ECM Id reference in Salesforce
                                objOpptyProperty.Ecm__c = null;
                                database.update(objOpptyProperty, true);
                            }
                        } else {
                            finalResult = System.Label.Contract_Delete_User_Error;
                        }
                    }else{                      
                        finalResult = MDU_EmptorisUtility.responseErrorLog(getContractDetailRes);
                        if(isEligibleForAppLogging){
                            executionLog += MDU_Constants.NL_ERROR +finalResult;
                        }
                    }
                }else{
                    finalResult = MDU_EmptorisUtility.responseErrorLog(getConractUserRes); 
                    if(isEligibleForAppLogging){
                        executionLog += MDU_Constants.NL_ERROR +finalResult;
                    }
                }
            } else {
                finalResult = CONTRACT_DELETE_VIEW_ERR;
            }
        } 
        MDU_ApplicationLogger.createLog(executionLog, isEligibleForAppLogging ,startTime , System.Now());
        return finalResult;
    }
    
    
    /**
    * Name: viewContractProcess
    * Description: This method is used to initiate the view contract service. 
    * @parameters: opptyPropertyId
    * @return: None
    **/
    public static String viewContractProcess(String opptyPropertyId){
        setRequestVariables();
        startTime = System.Now();
        executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.VIEW_CONTRACT_PROCESS + startTime, executionLog , isEligibleForAppLogging);
        if(opptyPropertyId!=null && opptyPropertyId!=''){
            fetchOpptyPropertyData(opptyPropertyId);
            if(objOpptyProperty != null && objOpptyProperty.ECM__c != null && objOpptyProperty.ECM__c != ''){          
                HTTPResponse getContractDetailResponse = getContractDetails(objOpptyProperty.ECM__c);
                Dom.Document viewConDoc = getContractDetailResponse.getBodyDocument();
                Dom.XMLNode viewConResponse = viewConDoc.getRootElement();
                if(getContractDetailResponse.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
                    HTTPResponse getContractURLResponse =  getContractURL(objOpptyProperty.ECM__c);
                    Dom.Document viewConURLDoc = getContractURLResponse.getBodyDocument();
                    Dom.XMLNode viewConURLResponse = viewConURLDoc.getRootElement();
                    if(getContractURLResponse.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
                        MDU_EmptorisUtility.parsedValue = '';
                        finalResult = MDU_EmptorisUtility.parseResponse(viewConURLResponse,MDU_Constants.GET_URL_RESPONSE);
                        if(String.isBlank(finalResult)){
                            finalResult = label.Launch_Emptoris_Error;
                        }
                    }else{                  
                        finalResult = MDU_EmptorisUtility.responseErrorLog(viewConURLResponse);
                        if(isEligibleForAppLogging){
                            executionLog += MDU_Constants.NL_ERROR +finalResult;
                        }
                    }
                }else{                  
                    finalResult = MDU_EmptorisUtility.responseErrorLog(viewConResponse);  
                    if(isEligibleForAppLogging){
                        executionLog += MDU_Constants.NL_ERROR +finalResult;
                    }
                }
            } else {
                finalResult = CONTRACT_DELETE_VIEW_ERR;
            }
                
        }
        MDU_ApplicationLogger.createLog(executionLog, isEligibleForAppLogging ,startTime , System.Now());
        return finalResult;
    }
    
    
    /**
    * Name: fetchOpptyPropertyData
    * Description: This method is getting used to fetch the Opportunity_Property__c Data. 
    * @parameters: opptyPropertyId
    * @return: None
    **/
    public static void fetchOpptyPropertyData(String opptyPropertyId){
        objOpptyProperty = [Select Id,ECM__c from Opportunity_Property__c where Id =: opptyPropertyId limit 1];
    }
    
    
    /**
    * Name: getContractUser
    * Description: This method is used to invoke the get Contract User Service Request. 
    * @parameters: None
    * @return: HTTPResponse
    **/
    public static HTTPResponse getContractUser(){
       
        executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.GET_CONTRACT_USER, executionLog , isEligibleForAppLogging);
        String soapEnvTemplate = ''+ MDU_EmptorisEnvelopeTemplate.GETCONTRACT_USER_BASE_ENV;    
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;      
        soapEnvTemplate+= '<request-data><username>{5}</username></request-data></get-request></s:Body></s:Envelope>';

        List<String> params = new List<String>();
        String userAccount = emptorisAccount;
        String theToken =   MDU_EmptorisUtility.GenerateToken(userAccount, dtTimeStr);
        String userName = MDU_EmptorisUtility.getUserName();

        params.add(userAccount);
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(userName);

        String soapMsg = String.format(soapEnvTemplate,params);
        //Send the SOAP Request:
        
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,getcontractuser_Endpoint);        
        executionLog = MDU_ApplicationLogger.logEnd(res.getBody(), executionLog , isEligibleForAppLogging);
        return res;
    }
    
    
    /**
    * Name: getContractDetails
    * Description: This method is used to invoke the get Contract details Service Request. 
    * @parameters: None
    * @return: HTTPResponse
    **/
    public static HTTPResponse getContractDetails(String ecmId){
        
        executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.GET_CONTRACT_DETAILS, executionLog , isEligibleForAppLogging);
        List<String> params = new List<String>();
        String userAccount = emptorisAccount;
        String userName = MDU_EmptorisUtility.getUserName();
        String theToken =   MDU_EmptorisUtility.GenerateToken(userName,dtTimeStr);

        String soapEnvTemplate = ''+ MDU_EmptorisEnvelopeTemplate.GETCONTRACT_BASE_ENV;     
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        soapEnvTemplate+= '<request-data><id xmlns="http://www.dicarta.com/contracts/types/domain/contract">{5}</id></request-data></get-request></s:Body></s:Envelope>';
               
        params.add(userName);
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(ecmId);

        String soapMsg = String.format(soapEnvTemplate,params);

        //Send the SOAP Request:

        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,getcontract_Details_Endpoint);        
        executionLog = MDU_ApplicationLogger.logEnd(res.getBody(), executionLog , isEligibleForAppLogging);
        return res;
    }
    
    
    /**
    * Name: deleteContract
    * Description: This method is used to invoke the delete Contract Service Request. 
    * @parameters: None
    * @return: None
    **/
    public static HTTPResponse deleteContract(String ecmId){
        
        executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.DELETE_CONTRACT, executionLog , isEligibleForAppLogging);
        String soapEnvTemplate = ''+ MDU_EmptorisEnvelopeTemplate.DELETE_CONTRACT_BASE_ENV;
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        soapEnvTemplate+= '<request-data><uuid xmlns="http://www.dicarta.com/contracts/types/domain/common">{5}</uuid></request-data></delete-contracts-request></s:Body></s:Envelope>';

        List<String> params = new List<String>();
        String userAccount = usertodeletecontract;
        
        String theToken = MDU_EmptorisUtility.GenerateToken(userAccount,dtTimeStr);
        params.add(userAccount);
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(ecmId);

        String soapMsg = String.format(soapEnvTemplate,params);

        //Send the SOAP Request:
       
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,delete_Contract_Endpoint);        
        executionLog = MDU_ApplicationLogger.logEnd(res.getBody(), executionLog , isEligibleForAppLogging);
        return res;
    }
    
    
    /**
    * Name: getContractURL
    * Description: This method is used to invoke the get Contract URL Service Request. 
    * @parameters: ecmId
    * @return: None
    **/
    public static HTTPResponse getContractURL(String ecmId){
        
        executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.GET_CONTRACT_URL, executionLog , isEligibleForAppLogging);        
        List<String> params = new List<String>();
        String userName = MDU_EmptorisUtility.getUserName();
        String theToken =   MDU_EmptorisUtility.GenerateToken(userName,dtTimeStr);
        String port = MDU_Constants.PORT_NUMBER;
        params.add(userName);
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(hostUrl);
        params.add(port);
        
        String soapEnvTemplate = '' + MDU_EmptorisEnvelopeTemplate.GET_URL_WIZARD_BASE_ENV;
        
        soapEnvTemplate += MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        
        soapEnvTemplate += '<request-data><page>ContractOpener</page><url-desc><protocol xmlns="http://www.dicarta.com/contracts/types/domain/single-signon">https</protocol><host xmlns="http://www.dicarta.com/contracts/types/domain/single-signon">{5}</host><port xmlns="http://www.dicarta.com/contracts/types/domain/single-signon">{6}</port><parameters xmlns="http://www.dicarta.com/contracts/types/domain/single-signon"><parameters><name>contractId</name><value>';
        
        soapEnvTemplate += ecmId;
        
        soapEnvTemplate += '</value></parameters><parameters><name>Status</name><value>Active</value></parameters><parameters><name>Creation</name><value>AUTHORED</value></parameters></parameters></url-desc>';
        soapEnvTemplate += '<user>{0}</user><shared-secret-credential><source xmlns="http://www.dicarta.com/contracts/types/auth">{1}</source><date xmlns="http://www.dicarta.com/contracts/types/auth">{2}</date><algorithm xmlns="http://www.dicarta.com/contracts/types/auth">{3}</algorithm><token xmlns="http://www.dicarta.com/contracts/types/auth">{4}</token><host xmlns="http://www.dicarta.com/contracts/types/auth"/></shared-secret-credential></request-data></get-url-request></s:Body></s:Envelope>';
       
        String soapMsg = String.format(soapEnvTemplate,params);        
        //Send the SOAP Request:
        
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,get_Contract_Url_Endpoint);        
        executionLog = MDU_ApplicationLogger.logEnd(res.getBody(), executionLog , isEligibleForAppLogging);
        return res;
    }
    
    
    /**
    * Name: bulkParseMethod
    * Description: This method is used to parse the xml response. 
    * @parameters: DOM.XMLNode node, string valueToGet
    * @return: Set<String>
    **/
    public static Set<String> bulkParseMethod(DOM.XMLNode node, string valueToGet) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if (node.getText().trim() != '') {
                if(node.getName().equalsIgnoreCase(valueToGet) ){
                    setOfParsingValues.add(node.getText().trim());
                }
            }
            if(!node.getName().equalsIgnoreCase(MDU_Constants.USERGROUPS)){
                for (Dom.XMLNode child: node.getChildElements()) {
                    bulkParseMethod(child,valueToGet);
                }
            }
            return setOfParsingValues;
        }
        return (new Set<String>()); 
    }
    
    
    /**
    * Name: parsingMethodForGetContactDetails
    * Description: This method is used to parse the Get Contact Details xml response. 
    * @parameters: DOM.XMLNode node
    * @return: String
    **/
    public static String parsingMethodForGetContactDetails(DOM.XMLNode node) {
        String result = '\n';
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            result += node.getName();
            if (node.getText().trim() != '') {
              result += ' : ' + node.getText().trim() + ' ; ';
            }
            for (Dom.XMLNode child: node.getChildElements()) {
              result += parsingMethodForGetContactDetails(child);
            }
            return result;
        }
        return '';
    }
}