/**************************************************************************************************
Name : LoginToGetSessionIdFailMockServiceImpl
Description : This test class is created to generate mock log in response when status is not 200
Date : 07-May-2017
Author : Animesh Datta
***************************************************************************************************/
@IsTest
global class LoginToGetSessionIdFailMockServiceImpl implements HttpCalloutMock {
    
    /*
        Mock response
    */
    global HttpResponse respond(HTTPRequest req) {
        string sessionBody = '<?xml version="1.0" encoding="utf-8"?>' +
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"' +
        'xmlns="urn:partner.soap.sforce.com"' +
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
        '<soapenv:Body>' +
        '<loginResponse>' +
        '<result>' +
        '<passwordExpired>false</passwordExpired>' +
        '<serverUrl>https://na1.salesforce.com/services/Soap/u/10.0</serverUrl>' +
        '<sessionId>QwWsHJyTPW.1pd0_jXlNKOSU</sessionId>' +
        '<userId>005D0000000nVYVIA2</userId>' +
        '<userInfo>' +
        '<!-- ... -->' +
        '</userInfo>' +
        '</result>' +
        '</loginResponse>' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml; charset=utf-8');
        res.setBody(sessionBody);
        res.setStatusCode(500);
        return res;
    }
}