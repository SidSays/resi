/************************************************************************************************************************************************************
Name: MDU_EmptorisEnvelopeTemplate
Description: This class holds the request templates for Emptoris services.
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
26 Feb 2015 Comcast  
*************************************************************************************************************************************************************/
public class MDU_EmptorisEnvelopeTemplate{

    /*
    * Stores the base envelope template for Launch Emptoris
    */
    public static final String LAUNCH_EMPTORIS_BASE_ENV= '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:urn="urn:partner.soap.sforce.com"><get-url-request xmlns="http://www.dicarta.com/contracts/services/single-signon">';
    
    /*
    * Stores the base envelope template for Launch Emptoris
    */
    public static final String LAUNCH_EMPTORIS_SHARED_CRED= '<user>{0}</user><shared-secret-credential><source xmlns="http://www.dicarta.com/contracts/types/auth">{1}</source><date xmlns="http://www.dicarta.com/contracts/types/auth">{2}</date><algorithm xmlns="http://www.dicarta.com/contracts/types/auth">{3}</algorithm><token xmlns="http://www.dicarta.com/contracts/types/auth">{4}</token><host xmlns="http://www.dicarta.com/contracts/types/auth"/></shared-secret-credential>';
    
    /*
    * Stores the base envelope template for Search Individual
    */
    public static final String INDIVIDUAL_BASE_ENV='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><search-request xmlns="http://www.dicarta.com/contracts/services/organization/individual">';

    /*
    * Stores the base envelope template for create Individual
    */
    public static final String CREATE_INDIVIDUAL_BASE_ENV= '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><create-request xmlns="http://www.dicarta.com/contracts/services/organization/individual">';
    
    /*
    * Stores the base envelope template for Search Interview
    */
    public static final String INTERVIEW_BASE_ENV = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><search-request xmlns="http://www.dicarta.com/contracts/services/interview-instance">';
    
    /*
    * Stores the base envelope template for Create Interview
    */
    public static final String CREATE_INTERVIEW_BASE_ENV =  '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><create-interview-instance-request xmlns="http://www.dicarta.com/contracts/services/interview-instance">';
    
    /*
    * Stores the base envelope template for Get Interview
    */
    public static final String GET_INTERVIEW_BASE_ENV = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><get-request xmlns="http://www.dicarta.com/contracts/services/interview-instance">';
    
    /*
    * Stores the base envelope template for Get SSO WIZARD
    */
    public static final String GET_URL_WIZARD_BASE_ENV = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><get-url-request xmlns="http://www.dicarta.com/contracts/services/single-signon">';
    
    /*
    * Stores the base envelope template for Interview Request Authentication
    */
    public static final String REQUEST_AUTHENTICATION = '<authentication><user xmlns="http://www.dicarta.com/contracts/types/auth">{0}</user><credential xmlns="http://www.dicarta.com/contracts/types/auth"><shared-secret><source>{1}</source><date>{2}</date><algorithm>{3}</algorithm><token>{4}</token><host/></shared-secret></credential></authentication>';
    
    /*
    * Stores the base envelope template for Get User in Contract View
    */
    public static final String GETCONTRACT_USER_BASE_ENV ='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><get-request xmlns="http://www.dicarta.com/contracts/services/security/user">';
    
    /*
    * Stores the base envelope template for View Contract.
    */
    public static final String GETCONTRACT_BASE_ENV = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><get-request xmlns="http://www.dicarta.com/contracts/services/contract">';
    
    /*
    * Stores the base envelope template for DELETE Contract request.
    */
    public static final String DELETE_CONTRACT_BASE_ENV ='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><delete-contracts-request xmlns="http://www.dicarta.com/contracts/services/contract">';

    /*
    * Stores the base envelope template for SEARCH Active and Executed Contract request.
    */
    public static final String SEARCH_CONTRACT_REQUEST_ENV ='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><search-request xmlns="http://www.dicarta.com/contracts/services/contract">';
    
    /*
    * Stores the base envelope template for Get Contract request.
    */
    public static final String GET_CONTRACT_REQUEST_ENV ='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><get-request xmlns="http://www.dicarta.com/contracts/services/contract">';
    
    /*
    * Stores the base envelope template for Get Contract Language request.
    */
    public static final String GET_CONTRACT_LANGUAGE_REQUEST_ENV ='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><get-language-request xmlns="http://www.dicarta.com/contracts/services/contract">';
    
    /*
    * Stores the base envelope template for Update Contract SubStatus request.
    */
    public static final String UPDATE_CONTRACT_SUBSTATUS_REQUEST_ENV ='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><update-substatus-request xmlns="http://www.dicarta.com/contracts/services/contract">';
    
    /*
    * Stores the base envelope template for Update Contract Term request.
    */
    public static final String UPDATE_CONTRACT_TERM_REQUEST_ENV ='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><update-term-request xmlns="http://www.dicarta.com/contracts/services/contract">';
    
    /*
    * Stores the base envelope template for Update Contract Custom property request.
    */
    public static final String UPDATE_CONTRACT_CUSTOM_PROPERTY_REQUEST_ENV ='<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><update-custom-property-request xmlns="http://www.dicarta.com/contracts/services/contract">';
}