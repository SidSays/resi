/************************************************************************************************************************************************************
Name: MDU_LaunchInterviewProcess 
Description: This class holds the Launch Interview Service Request.
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
16 Feb 2015 Comcast  
*************************************************************************************************************************************************************/
public class MDU_LaunchInterviewProcess{
    
    public static String finalResult;
    public static String errorMessage='';
    public static Opportunity_Property__c objOpportunityPropertyData;
    public static String globalToken;
    public static String dtTimeStr = MDU_EmptorisUtility.SetNow();
    public static String hostStr ='';
    public static String sourceStr ;
    public static String algoStr;
    public static String shareSecret;
    public static OpportunityContactRole objOpportunityContactRole;
    public static String opptyIdForInterviewName ;
    public static string contactFirstName;
    public static string contactLastName;
    public static string contactEmail;
    public static String UUID ='';
    public static boolean isUpdateOpportunity; 
    public static String interviewInstanceNameFinal ;
    public static String search_Individual_Endpoint ;
    public static String create_Individual_Endpoint ;
    public static String search_Interview_Endpoint ;
    public static String build_Sso_Url_Wizard_Endpoint ;
    public static String create_Interview_Endpoint ;
    public static String emptorisOrgID ;
    public static String emptorisAccount ;
    public static String hostUrl;
    
    public static String executionLog;
    public static DateTime startTime;
    public static boolean isEligibleForAppLogging = false;
    public static final String PROPERTY_INDUSTRY_ERROR =  Label.PropertyIndustryGovtErr+'\n';
    
    public static final String AMP_VAL = '&';
    public static final String GREATER_THAN_VAL = '>';
    public static final String LESS_THAN_VAL = '<';
    public static final String AMP_REPLACE = '&amp;';
    public static final String GREATER_THAN_REPLACE = '&gt;';
    public static final String LESS_THAN_REPLACE = '&lt;';
    
    /**
    * Name: MDU_LaunchInterviewProcess
    * Description: This is constructor. 
    * @parameters: None
    * @return: None
    **/
    public MDU_LaunchInterviewProcess(){
        objOpportunityPropertyData = new Opportunity_Property__c();
        objOpportunityContactRole = new OpportunityContactRole();
        isUpdateOpportunity = false;
       
    }
    
    /**
    * Name: setRequestVariables
    * Description: This method is used to Set The Request Variables. 
    * @parameters: None
    * @return: None
    **/
    public static void setRequestVariables(){
        Map<String, String> mapOfParamNameAndValue = new Map<String , String>();
        try{
            if(MDU_UserAppLoggingCS__c.getValues(UserInfo.getProfileId()) != null || MDU_UserAppLoggingCS__c.getValues(UserInfo.getUserId()) != null){
            isEligibleForAppLogging = true;
        }
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
        search_Individual_Endpoint = mapOfParamNameAndValue.get(MDU_Constants.SEARCH_INDIVIDUAL_ENDPOINT);
        create_Individual_Endpoint = mapOfParamNameAndValue.get(MDU_Constants.CREATE_INDIVIDUAL_ENDPOINT);
        search_Interview_Endpoint = mapOfParamNameAndValue.get(MDU_Constants.SEARCH_INTERVIEW_ENDPOINT);
        build_Sso_Url_Wizard_Endpoint = mapOfParamNameAndValue.get(MDU_Constants.BUILD_SSO_URL_WIZARD_ENDPOINT);
        create_Interview_Endpoint = mapOfParamNameAndValue.get(MDU_Constants.CREATE_INTERVIEW_ENDPOINT);
        emptorisOrgID = mapOfParamNameAndValue.get(MDU_Constants.EMPTORISORGID);
        emptorisAccount = mapOfParamNameAndValue.get(MDU_Constants.EMPTORISACCOUNT);
        hostUrl= mapOfParamNameAndValue.get(MDU_Constants.HOST_URL);
        }catch(Exception ex){
            System.debug('Following exception occurred :'+ex.getMessage());
        } 
    }
    
    /**
    * Name: processInterview
    * Description: This method is used to invoke the Launch Interview Process. 
    * @parameters: opptyId
    * @return: String
    **/
    public static String processInterview(String opptyId){
        setRequestVariables();
        executionLog = '';
        try{
            executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.LAUNCH_EMPTORIS_PROCESS + dtTimeStr, executionLog , isEligibleForAppLogging);
            startTime = System.Now();
            if(opptyId != null){
                opptyIdForInterviewName = opptyId;
                objOpportunityPropertyData = MDU_EmptorisUtility.fetchOpportunityPropertyData(opptyId);            
                
                if(objOpportunityPropertyData!=null && objOpportunityPropertyData.Opportunity__r.Contact_Email__c != null 
                &&  objOpportunityPropertyData.Opportunity__r.Contact_First_Name__c != null 
                && objOpportunityPropertyData.Opportunity__r.Contact_Last_Name__c != null){
                    
                    contactFirstName = objOpportunityPropertyData.Opportunity__r.Contact_First_Name__c;
                    contactLastName = objOpportunityPropertyData.Opportunity__r.Contact_Last_Name__c;
                    contactEmail = objOpportunityPropertyData.Opportunity__r.Contact_Email__c;
                }else{               
                    objOpportunityContactRole = MDU_EmptorisUtility.fetchOpportunityContactRoleData(opptyId);
                    if(objOpportunityContactRole != null){
                        contactFirstName = objOpportunityContactRole.Contact.FirstName;
                        contactLastName = objOpportunityContactRole.Contact.LastName;
                        contactEmail = objOpportunityContactRole.Contact.Email;
                    }  
                }
                contactFirstName = contactFirstName!=null?(contactFirstName.replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE)): null;
                contactLastName = contactLastName!=null?(contactLastName.replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE)):null;
                contactEmail = contactEmail!=null?(contactEmail.replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE)):null;            
                
                if(objOpportunityPropertyData != null){
                    String validationMsg = MDU_EmptorisUtility.validateLaunchInterview(objOpportunityPropertyData);                
                    if( validationMsg != null && validationMsg != ''){                   
                        finalResult = MDU_Constants.ERROR + validationMsg;                 
                        return finalResult;
                    }else{                          
                        searchIndividual();
                    }
                }else{
                    finalResult = MDU_Constants.ERROR + MDU_Constants.NL_NO_PROPERTY_RECORD_WITH_OPP;
                    executionLog += MDU_Constants.NL_NO_PROPERTY_RECORD_WITH_OPP ;
                    MDU_ApplicationLogger.createLog(executionLog, isEligibleForAppLogging ,startTime , System.Now());
                }
            }
        }catch(Exception ex){
            System.debug('Following exception occurred :'+ex.getMessage());
        }
        
        return finalResult;
    }
    
    
    /**
    * Name: searchIndividual
    * Description: This method is used to invoke the Search Individual Service. 
    * @parameters: None
    * @return: None
    **/ 
    public static void searchIndividual(){
        try{
            executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.SEARCH_INDIVIDUAL, executionLog , isEligibleForAppLogging);
            String soapEnvTemplate = ''+ MDU_EmptorisEnvelopeTemplate.INDIVIDUAL_BASE_ENV;
            soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;       
            soapEnvTemplate+= '<request-data><email><operation xmlns="http://www.dicarta.com/contracts/types/search">{5}</operation><value xmlns="http://www.dicarta.com/contracts/types/search">{6}</value></email></request-data></search-request></s:Body></s:Envelope>';
            
            List<String> params = new List<String>();
            String manageUserAccount = emptorisAccount;
            String theToken =   MDU_EmptorisUtility.GenerateToken(manageUserAccount,dtTimeStr);              
            
            params.add(manageUserAccount);
            params.add(sourceStr);
            params.add(dtTimeStr);
            params.add(algoStr);
            params.add(theToken);
            params.add(MDU_Constants.OPERATION);
            params.add(contactEmail);
            
            String soapMsg = String.format(soapEnvTemplate,params);       
            
            HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,search_Individual_Endpoint);        
            //createIndividual();
            Dom.Document buildKeyDoc = res.getBodyDocument();       
            Dom.XMLNode responseBuildKey = buildKeyDoc.getRootElement();
            if(res.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
               
                executionLog = MDU_ApplicationLogger.logEnd(res.getBody(), executionLog , isEligibleForAppLogging);
                
                MDU_EmptorisUtility.parsedValue = '';
                String individualID = MDU_EmptorisUtility.parseResponse(responseBuildKey,MDU_Constants.ID);                        
                if(individualID != null && individualID != ''){

                    UUID = individualID;
                    if(objOpportunityPropertyData.Opportunity__r.ECM_Interview_Instance_Name__c != null &&  objOpportunityPropertyData.Opportunity__r.ECM_Interview_Instance_Name__c !=''){
                        searchInterview(); // search Interview
                    }else{
                        createInterview(); // create Interview
                    }   
                }else{
                    createIndividual();//Create Individual
                }
            }else{
                MDU_EmptorisUtility.parsedValue = '';
                finalResult = MDU_EmptorisUtility.responseErrorLog(responseBuildKey);  
                executionLog += MDU_Constants.NL_ERROR +finalResult;
                MDU_ApplicationLogger.createLog(executionLog, isEligibleForAppLogging ,startTime , System.Now());
            }
        }catch(Exception ex){
            System.debug('Following exception occurred :'+ex.getMessage());
        }
        
    }
    
    
    /**
    * Name: createIndividual
    * Description: This method is used to invoke the Create Individual Service. 
    * @parameters: None
    * @return: None
    **/ 
    public static void createIndividual(){
        try{
            executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.CREATE_INDIVIDUAL, executionLog , isEligibleForAppLogging);
            String individualId;
            List<String> params = new List<String>();
            
            String soapEnvTemplate = ''+ MDU_EmptorisEnvelopeTemplate.CREATE_INDIVIDUAL_BASE_ENV;
            soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;        
            soapEnvTemplate+= '<request-data><first-name>{5}</first-name><last-name>{6}</last-name><middle-name xsi:nil="true"/><company-type>{7}</company-type><number>{8}</number>';
            soapEnvTemplate+= '<title xsi:nil="true"/><organization-id>{9}</organization-id><manager-id xsi:nil="true"/><email>{10}</email><notes xsi:nil="true"/>';
            soapEnvTemplate+= '<start-date>{11}</start-date><end-date/><external-system-info><external-id xmlns="http://www.dicarta.com/contracts/types/domain/common">{10}</external-id>';
            soapEnvTemplate+= '<external-name xsi:nil="true" xmlns="http://www.dicarta.com/contracts/types/domain/common"/></external-system-info></request-data></create-request></s:Body></s:Envelope>';
            
            String firstName;
            String lastName;
            String email;
            
            if(contactFirstName != null){
                firstName = contactFirstName;
            }
            
            if(contactLastName != null){
                lastName = contactLastName;
            }
            if(contactEmail != null){
                email = contactEmail;
            }
            String orgId = emptorisOrgID; // This is fixed.
            String manageUserAccount = emptorisAccount; // EmptorisAccount
            String startDate = String.valueOf(Date.valueOf(System.today()));
            String theToken =   MDU_EmptorisUtility.GenerateToken(manageUserAccount,dtTimeStr);

            params.add(manageUserAccount);
            params.add(sourceStr);
            params.add(dtTimeStr);
            params.add(algoStr);
            params.add(theToken);
            params.add(firstName);
            params.add(lastName);
            params.add(MDU_Constants.COMPANY_TYPE);
            params.add(MDU_Constants.COMPANY_NUMBER);
            params.add(orgId);
            params.add(email);
            params.add(startDate);
            
            String soapMsg = String.format(soapEnvTemplate,params);        
            
            HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,create_Individual_Endpoint);        
            Dom.Document buildKeyDoc = res.getBodyDocument();        
            Dom.XMLNode responseBuildKey = buildKeyDoc.getRootElement();        
            if(res.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE ){
                executionLog = MDU_ApplicationLogger.logEnd(res.getBody(), executionLog , isEligibleForAppLogging);
                MDU_EmptorisUtility.parsedValue = '';
                individualId = MDU_EmptorisUtility.parseResponse(responseBuildKey,MDU_Constants.ID);            
                UUID = individualId;            
                if(individualId != null && individualId != ''){
                    UUID = individualId;
                    if(objOpportunityPropertyData.Opportunity__r.ECM_Interview_Instance_Name__c != null &&  objOpportunityPropertyData.Opportunity__r.ECM_Interview_Instance_Name__c !=''){
                        searchInterview(); // search Interview
                    }else{
                        createInterview(); // create Interview
                    }
                }
            }else{
                MDU_EmptorisUtility.parsedValue = '';
                finalResult = MDU_EmptorisUtility.responseErrorLog(responseBuildKey);
                executionLog = MDU_Constants.NL_ERROR +finalResult;
                MDU_ApplicationLogger.createLog(executionLog, isEligibleForAppLogging ,startTime , System.Now());
            }
        }catch(Exception ex){
            System.debug('Following exception occurred :'+ex.getMessage());
        }
        
    }
    
    
    /**
    * Name: searchInterview
    * Description: This method is used to invoke the Search Interview Service. 
    * @parameters: None
    * @return: None
    **/ 
    public static void searchInterview(){
        try{
            executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.SEARCH_INTERVIEW, executionLog , isEligibleForAppLogging);
            String interviewInstanceId ='';
            List<String> params = new List<String>();
            
            String soapEnvTemplate = ''+ MDU_EmptorisEnvelopeTemplate.INTERVIEW_BASE_ENV;
            soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;       
            soapEnvTemplate+= '<request-data><interview-instance-name><operation xmlns="http://www.dicarta.com/contracts/types/search">{5}</operation>';
            soapEnvTemplate+= '<value xmlns="http://www.dicarta.com/contracts/types/search">{6}</value></interview-instance-name></request-data></search-request></s:Body></s:Envelope>';
            
            String userName = MDU_EmptorisUtility.getUserName();

            String interviewInstanceName = objOpportunityPropertyData.Opportunity__r.ECM_Interview_Instance_Name__c;
            String theToken =   MDU_EmptorisUtility.GenerateToken(userName,dtTimeStr);
            
            params.add(userName);
            params.add(sourceStr);
            params.add(dtTimeStr);
            params.add(algoStr);
            params.add(theToken);
            params.add(MDU_Constants.OPERATION);
            params.add(interviewInstanceName);
            
            String soapMsg = String.format(soapEnvTemplate, params);        
            //Send the SOAP Request:
            
            HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,search_Interview_Endpoint);        
            Dom.Document searchInterviewcdoc = res.getBodyDocument();
            Dom.XMLNode searchInterviewResponse = searchInterviewcdoc.getRootElement();

            if(res.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
                
                executionLog = MDU_ApplicationLogger.logEnd(res.getBody(), executionLog , isEligibleForAppLogging);
                MDU_EmptorisUtility.parsedValue = '';
                interviewInstanceId = MDU_EmptorisUtility.parseResponse(searchInterviewResponse,MDU_Constants.ID);
                           
                if(interviewInstanceId != null && interviewInstanceId != ''){
                    buildSSOUrlWizard(interviewInstanceId);
                }
            }else{
                MDU_EmptorisUtility.parsedValue = '';
                finalResult = MDU_EmptorisUtility.responseErrorLog(searchInterviewResponse);
                executionLog += MDU_Constants.NL_ERROR +finalResult;
                MDU_ApplicationLogger.createLog(executionLog, isEligibleForAppLogging ,startTime , System.Now());
            }
        }catch(Exception ex){
            System.debug('Following exception occurred :'+ex.getMessage());
        }
        
        
    }
   
    /**
    * Name: buildSSOUrlWizard
    * Description: This method is used to invoke the Build interview SSO URL Service. 
    * @parameters: interviewInstanceId , interviewCreatedDate
    * @return: None
    **/
    public static void buildSSOUrlWizard(String interviewInstanceId){
       try{
        executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.BUILDSSOURLWIZARD, executionLog , isEligibleForAppLogging);
        String userName = MDU_EmptorisUtility.getUserName();
        String nowDt = MDU_EmptorisUtility.SetNow();
        String theToken =  MDU_EmptorisUtility.GenerateToken(userName,nowDt);

        List<String> params = new List<String>();
        
        params.add(userName);
        params.add(sourceStr);
        params.add(nowDt);
        params.add(algoStr);
        params.add(theToken);
        params.add(hostUrl);
        params.add(MDU_Constants.PORT_NUMBER);
        params.add(MDU_Constants.SSORESUMEWIZARDID);
        params.add(interviewInstanceId);
        params.add(MDU_Constants.SSORESUMEFIRSTSTEP);
        params.add(MDU_Constants.TRUE_STRING);
        
        String soapEnvTemplate = ''+ MDU_EmptorisEnvelopeTemplate.GET_URL_WIZARD_BASE_ENV;
        soapEnvTemplate += MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;  
        
        soapEnvTemplate +='<request-data><page>WizardPage</page><url-desc><protocol xmlns="http://www.dicarta.com/contracts/types/domain/single-signon">https</protocol>';
        soapEnvTemplate += '<host xmlns="http://www.dicarta.com/contracts/types/domain/single-signon">{5}</host><port xmlns="http://www.dicarta.com/contracts/types/domain/single-signon">{6}</port>';
        soapEnvTemplate += '<parameters xmlns="http://www.dicarta.com/contracts/types/domain/single-signon"><parameters>';

        soapEnvTemplate += '<name>{7}</name><value>{8}</value></parameters><parameters><name>{9}</name><value>{10}</value></parameters></parameters></url-desc><user>{0}</user>';
        soapEnvTemplate += '<shared-secret-credential><source xmlns="http://www.dicarta.com/contracts/types/auth">{1}</source><date xmlns="http://www.dicarta.com/contracts/types/auth">{2}';
        
        soapEnvTemplate += '</date><algorithm xmlns="http://www.dicarta.com/contracts/types/auth">{3}</algorithm><token xmlns="http://www.dicarta.com/contracts/types/auth">{4}';
        
        soapEnvTemplate += '</token><host xmlns="http://www.dicarta.com/contracts/types/auth"/></shared-secret-credential></request-data></get-url-request></s:Body></s:Envelope>';

        String soapMsg = String.format(soapEnvTemplate, params);

        //Send the SOAP Request
     
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,build_Sso_Url_Wizard_Endpoint);        
        
        Dom.Document buildSSOURLDoc = res.getBodyDocument();
        Dom.XMLNode buildSSOURLResponse = buildSSOURLDoc.getRootElement();
        if(res.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){  
            
            executionLog = MDU_ApplicationLogger.logEnd(res.getBody(), executionLog , isEligibleForAppLogging);
            MDU_EmptorisUtility.parsedValue = '';
            finalResult = MDU_EmptorisUtility.parseResponse(buildSSOURLResponse,MDU_Constants.GET_URL_RESPONSE);
        }else{
            MDU_EmptorisUtility.parsedValue = '';
            finalResult = MDU_EmptorisUtility.responseErrorLog(buildSSOURLResponse);            
            if(isEligibleForAppLogging){
                executionLog += MDU_Constants.NL_ERROR +finalResult;
            }
        }       
        MDU_ApplicationLogger.createLog(executionLog, isEligibleForAppLogging ,startTime , System.Now());
       }catch(Exception ex){
           System.debug('Following exception occurred :'+ex.getMessage());
       }
    }
    
    
    /**
    * Name: createInterview
    * Description: This method is used to invoke the Create interview Service. 
    * @parameters: None
    * @return: None
    **/
    public static void createInterview(){
        
        try{
            executionLog = MDU_ApplicationLogger.logStart(MDU_Constants.CREATEINTERVIEW, executionLog , isEligibleForAppLogging);
        String userName = MDU_EmptorisUtility.getUserName();      
        String theToken =   MDU_EmptorisUtility.GenerateToken(userName,dtTimeStr);
        String interviewInstanceName = MDU_EmptorisUtility.generateInterviewInstanceName(objOpportunityPropertyData.Opportunity__c);
        
        List<MDU_Property__c> propertyData = MDU_EmptorisUtility.getPropertyData(objOpportunityPropertyData.Property__c);
        List<Opportunity> opportunityData = MDU_EmptorisUtility.getOpportunityData(objOpportunityPropertyData.Opportunity__c);
        
        interviewInstanceNameFinal = interviewInstanceName;
        
        String soapMsg=null;               
        if (objOpportunityPropertyData.Property__r.Property_Type__c.equalsIgnoreCase(MDU_Constants.MOBILE_HOME)){
            soapMsg = MDU_InterviewTemplates.mdu_template(objOpportunityPropertyData, objOpportunityContactRole, propertyData[0], opportunityData[0], UUID, userName,theToken,interviewInstanceName,dtTimeStr,MDU_Constants.MDU_RESIDENTIAL_SFU);
        }else{
            String industryType = objOpportunityPropertyData.Property__r.Industry_Type__c.Trim();
            if(industryType.equalsIgnoreCase(MDU_Constants.SINGLE_FAMILY)){
                
                soapMsg = MDU_InterviewTemplates.mdu_template(objOpportunityPropertyData, objOpportunityContactRole, propertyData[0], opportunityData[0], UUID, userName,theToken,interviewInstanceName,dtTimeStr,MDU_Constants.MDU_RESIDENTIAL_SFU);
                
            }else if(industryType.equalsIgnoreCase(MDU_Constants.MULTI_FAMILY)){
                
                soapMsg = MDU_InterviewTemplates.mdu_template(objOpportunityPropertyData, objOpportunityContactRole, propertyData[0], opportunityData[0], UUID, userName,theToken,interviewInstanceName,dtTimeStr,MDU_Constants.MDU_RESIDENTIAL);
                
            }else if(industryType.equalsIgnoreCase(MDU_Constants.HOSPITALITY)){
                
                soapMsg = MDU_InterviewTemplates.mdu_template(objOpportunityPropertyData,objOpportunityContactRole,propertyData[0], opportunityData[0],UUID,userName,theToken,interviewInstanceName,dtTimeStr,MDU_Constants.MDU_HOSPITALITY);
                
            }else if(industryType.equalsIgnoreCase(MDU_Constants.HEALTHCARE)){
                
            soapMsg = MDU_InterviewTemplates.mdu_template(objOpportunityPropertyData, objOpportunityContactRole,propertyData[0], opportunityData[0],UUID,userName,theToken,interviewInstanceName,dtTimeStr,MDU_Constants.MDU_HEALTHCARE);
            
            }else if(industryType.equalsIgnoreCase(MDU_Constants.COMMERCIAL)){
                
                soapMsg = MDU_InterviewTemplates.mdu_template(objOpportunityPropertyData, objOpportunityContactRole, propertyData[0], opportunityData[0], UUID,userName,theToken,interviewInstanceName,dtTimeStr, MDU_Constants.MDU_RESIDENTIAL);
                
            }else if(industryType.equalsIgnoreCase(MDU_Constants.EDUCATION)){
                
                soapMsg = MDU_InterviewTemplates.mdu_template(objOpportunityPropertyData, objOpportunityContactRole, propertyData[0], opportunityData[0], UUID,userName,theToken,interviewInstanceName,dtTimeStr,MDU_Constants.MDU_EDUCATION);
                
            }else if(industryType.equalsIgnoreCase(MDU_Constants.GOVERNMENT)){
                
                soapMsg = MDU_InterviewTemplates.mdu_template(objOpportunityPropertyData, objOpportunityContactRole, propertyData[0], opportunityData[0], UUID,userName,theToken,interviewInstanceName,dtTimeStr,MDU_Constants.MDU_EDUCATION);              
            }else{
                // DEFAULT - MDU_RESIDENTIAL
                soapMsg = MDU_InterviewTemplates.mdu_template(objOpportunityPropertyData, objOpportunityContactRole, propertyData[0], opportunityData[0], UUID,userName,theToken,interviewInstanceName,dtTimeStr,MDU_Constants.MDU_RESIDENTIAL);
            }   
        }               
        soapMsg = soapMsg.replaceAll(MDU_Constants.NULL_STRING,'');               
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,create_Interview_Endpoint);        
        String interviewInstanceId1;
        Dom.Document createInterviewDoc = res.getBodyDocument();
        Dom.XMLNode createInterviewResponse = createInterviewDoc.getRootElement();
        if(res.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE){
            executionLog = MDU_ApplicationLogger.logEnd(res.getBody(), executionLog , isEligibleForAppLogging);
            MDU_EmptorisUtility.parsedValue = '';
            interviewInstanceId1 = MDU_EmptorisUtility.parseResponse(createInterviewResponse,MDU_Constants.CREATE_RESPONSE);                        
            if(interviewInstanceId1 != null && interviewInstanceId1 != ''){
                buildSSOUrlWizard(interviewInstanceId1);
                isUpdateOpportunity = true;
            }
        }else{
            MDU_EmptorisUtility.parsedValue = '';                        
            finalResult = MDU_EmptorisUtility.responseErrorLog(createInterviewResponse);    
            executionLog += MDU_Constants.NL_ERROR +finalResult;
            MDU_ApplicationLogger.createLog(executionLog, isEligibleForAppLogging ,startTime , System.Now());
        }
        }catch(Exception ex){
            System.debug('Following exception occurred :'+ex.getMessage());
        }   
    }
}