/**************************************************************************************************
* Name : LoginToGetSessionId
* Description : Get session id by passing username and password. Pass the session id to batch class
* User Story : US1024537(Indirect - Coach for Indirect - Retail Sales Rep - RGU Goal - Metric Targets and Actuals)
* Date : 20 April 2017
* Author : Animesh Datta
***************************************************************************************************/

public with sharing class LoginToGetSessionId {

    private static final String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    private static final String NS_SF = 'urn:partner.soap.sforce.com';
    private static final String ENDPOINT = URL.getSalesforceBaseUrl().toExternalForm() + Label.EndPointURL;//Label value = /services/Soap/u/39.0
    
    //Pass user name and password(plus security token if any). Method returns session id
    public static String login(String user, String password)
    {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');   
        req.setTimeout(Integer.valueOf(Label.LoginToGetSessionIdTimeOut));//Increase time out value from Label if requires
        req.setEndpoint(ENDPOINT);
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');        
        req.setHeader('SOAPAction', '""');
        req.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' +user+ '</username><password>' + password + '</password></login></Body></Envelope>');        
        HttpResponse res =  new Http().send(req);
        if(res.getStatusCode() != 200)// if response is BAD
        {
            Dom.Document responseDocument = res.getBodyDocument();
            Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
            Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body 
            Dom.Xmlnode faultElm = bodyElm.getChildElement('Fault', NS_SOAP); // soapenv:Fault
            Dom.Xmlnode faultStringElm = faultElm.getChildElement('faultstring', null); // faultstring          
            throw new LoginException(faultStringElm.getText()); 
        }
        //when response is OK
        Dom.Document responseDocument = res.getBodyDocument();
        Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
        Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', NS_SOAP); // soapenv:Body 
        Dom.Xmlnode loginResponseElm = bodyElm.getChildElement('loginResponse', NS_SF); // loginResponse
        Dom.Xmlnode resultElm = loginResponseElm.getChildElement('result', NS_SF); // result
        Dom.Xmlnode sessionIdElm = resultElm.getChildElement('sessionId', NS_SF); // sessionId
        return sessionIdElm.getText();//Session Id
    }
    
    //Handle exception
    public class LoginException extends Exception {}
}