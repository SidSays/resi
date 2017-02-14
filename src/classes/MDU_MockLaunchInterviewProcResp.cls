/************************************************************************************************************************************************************
Name: MDU_MockLaunchInterviewProcResp 
Description: Class use to send Mock http Response to test MDU_LaunchInterviewProcessTest class.
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
16 Feb 2015 Comcast  
*************************************************************************************************************************************************************/
 
@isTest
public class MDU_MockLaunchInterviewProcResp{
    
    //searchIndividual() response1   
    public static string searchIndividualResp =  '<?xml version="1.0" encoding="utf-8"?>'
    +'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header><ns1:sessionID soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0" xmlns:ns1="http://xml.apache.org/axis/session">8859539161662154015</ns1:sessionID></soapenv:Header>'
    +'<soapenv:Body><search-response xmlns="http://www.dicarta.com/contracts/services/organization/individual"><response-data/></search-response></soapenv:Body></soapenv:Envelope>';
    
    
    //createIndividual() response2
    public static string createIndividualResp = '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header><ns1:sessionID soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0" xmlns:ns1="http://xml.apache.org/axis/session">-5597415833407273924</ns1:sessionID>'
    +'</soapenv:Header><soapenv:Body><create-response xmlns="http://www.dicarta.com/contracts/services/organization/individual"><id>c5f415a83f5041e894dce48d1ae7a4a9</id></create-response></soapenv:Body></soapenv:Envelope>';
    
    //createInterview() response6
    public static string createInterviewResp ='<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header>'
    +'<ns1:sessionID soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0" xmlns:ns1="http://xml.apache.org/axis/session">-7983954236972086280</ns1:sessionID></soapenv:Header><soapenv:Body><create-response xmlns="">453cb6f3b4ef4a7581dc7f45abf81b95</create-response></soapenv:Body></soapenv:Envelope>';
    
    //searchInterview() response7
    public static string searchInterviewResp = '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header><ns1:sessionID soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0" xmlns:ns1="http://xml.apache.org/axis/session">244830977301882448</ns1:sessionID></soapenv:Header>'
    +'<soapenv:Body><search-response xmlns="http://www.dicarta.com/contracts/services/interview-instance"><response-data><ns1:interview-instance xmlns:ns1="http://www.dicarta.com/contracts/types/domain/interview-instance"><ns1:name>mdu200963february 0320150235</ns1:name><ns1:id>453cb6f3b4ef4a7581dc7f45abf81b95</ns1:id><ns1:status>Active</ns1:status></ns1:interview-instance></response-data></search-response></soapenv:Body></soapenv:Envelope>';
    
    //buildSSOUrlWizard()  response9
    public static string buildSSOUrlWizardResp = '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header>'
    +'<ns1:sessionID soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0" xmlns:ns1="http://xml.apache.org/axis/session">-6747124546286983637</ns1:sessionID>'
    +'</soapenv:Header><soapenv:Body><get-url-response xmlns="">https://comcasttraining.emptoris.com/dicarta/pt/signon?user=smarti001c&amp;token=4T3yqjohIptoWewU1A218w%3D%3D&amp;credDate=February+03%2C+2015+02%3A35%3A32+PM&amp;credType=SharedSecret&amp;host=&amp;source=DEFAULT&amp;redirectUrl=https%3A%2F%2Fcomcasttraining.emptoris.com%2Fdicarta%2Fpt%2FwizardPageServlet%3FSSOResumeWizardId%3D453cb6f3b4ef4a7581dc7f45abf81b95%26SSOResumeFirstStep%3Dtrue&amp;digAlg=MD5</get-url-response></soapenv:Body></soapenv:Envelope>';
    
    public  static String launchInterviewErrHandleResp = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault>'
    +'<faultcode>soapenv:Server.generalException</faultcode><detail><faultString>Authentication failed.</faultString><ns1:exceptionName xmlns:ns1="http://xml.apache.org/axis/">com.dicarta.webservices.faults.ObjectNotFoundFault</ns1:exceptionName><ns2:hostname xmlns:ns2="http://xml.apache.org/axis/">wdc01c189r10r01ecm2.sl.emptoris.com</ns2:hostname></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>';
    
}