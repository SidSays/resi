/************************************************************************************************************************************************************
Name: MDU_LaunchEmptoriosButtonWS 
Description: This class holds the Launch Emptoris Button Request.
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
16 Feb 2015 Comcast  
*************************************************************************************************************************************************************/
global class MDU_LaunchEmptorisButtonWS{
     
    public static String url=null;
    public static String executionLog;
    public static DateTime startTime;
    public static boolean isEligibleForAppLogging = false;
    /**
    * Name: launchEmptorisProcess
    * Description: This method is used to invoke the Launch Emptoris Process. 
    * @parameters: None
    * @return: String
    **/
    webService static String launchEmptorisProcess(){
        if(MDU_UserAppLoggingCS__c.getValues(UserInfo.getProfileId()) != null || MDU_UserAppLoggingCS__c.getValues(UserInfo.getUserId()) != null){
            isEligibleForAppLogging = true;
        }
        executionLog ='';
        executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.LAUNCH_EMPTORIS_PROCESS, executionLog , isEligibleForAppLogging);
        launchEmptorisHttpRequest();
        return url;
    }
    
    /**
    * Name: launchEmptorisProcess
    * Description: This method is used to request the Launch Emptoris Process. 
    * @parameters: None
    * @return: String
    **/
    public static string launchEmptorisHttpRequest(){
        
        
        //startTime = MDU_EmptorisUtility.SetNow();
        startTime = System.Now();
        
        executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.LAUNCHEMPTORISHTTPREQUEST, executionLog , isEligibleForAppLogging);
        String dtTimeStr = MDU_EmptorisUtility.SetNow();
        String userName = MDU_EmptorisUtility.getUserName();
        String hostStr='';
        String sourceStr = '';
        String algoStr =  '';
        String shareSecret  = '';
        String port = MDU_Constants.PORT_NUMBER;
        String module = MDU_Constants.MODULE;
        String homePage = MDU_Constants.HOMEPAGE;
        String userType = MDU_Constants.USERTYPE;
        String adv = MDU_Constants.ADV;
        String userHost = MDU_Constants.USERHOST;
        String login = MDU_Constants.LOGIN;
        String protocol = MDU_Constants.PROTOCOL;
        String host = '';
        String launch_Emptoris_Url_Endpoint='';
        
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
        launch_Emptoris_Url_Endpoint = mapOfParamNameAndValue.get(MDU_Constants.LAUNCH_EMPTORIS_URL_ENDPOINT);
        host = mapOfParamNameAndValue.get(MDU_Constants.HOST_URL);
        
        String soapEnvTemplate =  '' + MDU_EmptorisEnvelopeTemplate.LAUNCH_EMPTORIS_BASE_ENV;
        soapEnvTemplate += MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        
        soapEnvTemplate += '<request-data><page>HomePageOpener</page><url-desc><protocol xmlns="http://www.dicarta.com/contracts/types/domain/single-signon">{12}';
        soapEnvTemplate += '</protocol><host xmlns="http://www.dicarta.com/contracts/types/domain/single-signon">{13}</host><port xmlns="http://www.dicarta.com/contracts/types/domain/single-signon">{5}</port>';      
        soapEnvTemplate += '<parameters xmlns="http://www.dicarta.com/contracts/types/domain/single-signon"><parameters><name>{6}</name><value>{7}</value></parameters>';
        soapEnvTemplate += '<parameters><name>{8}</name><value>{9}</value></parameters><parameters><name>{10}</name><value>{11}</value></parameters></parameters></url-desc>';
        
        soapEnvTemplate +=  MDU_EmptorisEnvelopeTemplate.LAUNCH_EMPTORIS_SHARED_CRED;           
        soapEnvTemplate += '</request-data></get-url-request></s:Body></s:Envelope>';
       
        String theToken =   MDU_EmptorisUtility.GenerateToken(userName, dtTimeStr);
        List<String> params = new List<String>();
        
        params.add(userName);
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(port);
        params.add(module);
        params.add(homePage);
        params.add(userType);
        params.add(adv);
        params.add(userHost);
        params.add(login);
        params.add(protocol);
        params.add(host);

        String soapMsg = String.format(soapEnvTemplate,params);
        
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,launch_Emptoris_Url_Endpoint);        
        if(res.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
            executionLog = MDU_ApplicationLogger.logEnd(res.getBody(), executionLog , isEligibleForAppLogging);
            Dom.Document doc = res.getBodyDocument();
            Dom.XMLNode responseNew = doc.getRootElement();
            url = MDU_EmptorisUtility.parseResponse(responseNew, MDU_Constants.GET_URL_RESPONSE);
        }else{
            url = System.Label.Launch_Emptoris_Error;
            if(isEligibleForAppLogging){
                Dom.XMLNode responseErr = res.getBodyDocument().getRootElement();
                executionLog += MDU_Constants.NL_ERROR + '' + MDU_EmptorisUtility.responseErrorLog(responseErr);
            }
        }        
        MDU_ApplicationLogger.createLog(executionLog, isEligibleForAppLogging ,startTime , System.Now());
        
        return url;
    }
}