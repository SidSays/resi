/****************************************************************************************************************************************************
Name: MockHttpResponseGeneratorAccountContactVf
Description: This class is used to generate mock response for AccountContactAddressLocationCallout class 
Author: Ashish Sonawane (Accenture)
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
29/09/2015 Comcast  
*************************************************************************************************************************************************************/
@isTest                       
global class MockHttpResponseGeneratorAccountCont implements HttpCalloutMock {
    
  
    MockDirectSalesResp obj = new MockDirectSalesResp();
    
    global MockHttpResponseGeneratorAccountCont() {
       
    }

    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse httpResponse = new httpResponse();
        httpResponse.setHeader('Content-Type', 'application/xml');
        httpResponse.setBody(MockDirectSalesResp.generateAccountContResponse);
        httpResponse.setStatusCode(200);  
        return httpResponse;
    }
    global HTTPResponse respondforPdfId(HTTPRequest req) {
        HTTPResponse httpResponse = new httpResponse();
        httpResponse.setHeader('Content-Type', 'application/xml');
        httpResponse.setBody(obj.generateAccountMangResponseFirst);
        httpResponse.setStatusCode(200);  
        return httpResponse;
    }
    global HTTPResponse respondforPdfResponse(HTTPRequest req) {
        HTTPResponse httpResponse = new httpResponse();
        httpResponse.setHeader('Content-Type', 'application/xml');
        httpResponse.setBody(obj.generateAccountMangResponseSecond);
        httpResponse.setStatusCode(200);  
        return httpResponse;
    }
}