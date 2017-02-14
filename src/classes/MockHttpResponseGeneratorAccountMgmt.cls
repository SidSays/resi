/****************************************************************************************************************************************************
Name: MockHttpResponseGeneratorAccountMgmt
Description: This class is used to generate mock response for AccountManagementServiceCallout class 
Author: Lalit Singh (Accenture)
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
29/09/2015 Comcast  
*************************************************************************************************************************************************************/
@isTest                       
global class MockHttpResponseGeneratorAccountMgmt implements HttpCalloutMock {
    
  
    MockDirectSalesResp obj = new MockDirectSalesResp();
    
    global MockHttpResponseGeneratorAccountMgmt() {
       
    }

    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse httpResponse = new httpResponse();
        if(req.getBody().contains('billingArrangementID')){
            
            httpResponse.setHeader('Content-Type', 'application/xml');
            httpResponse.setBody(obj.generateAccountMangResponseFirst);
            httpResponse.setStatusCode(200);  
            //return httpResponse;
        }else if(req.getBody().contains('pdfStatementID')){
            httpResponse.setHeader('Content-Type', 'application/xml');
            httpResponse.setBody(obj.generateAccountMangResponseSecond);
            httpResponse.setStatusCode(200);
          }
          return httpResponse;
    }
}