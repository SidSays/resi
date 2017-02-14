@isTest                       
global class MockHttpResponseGeneratorGetBilling implements HttpCalloutMock {
    
  
   // MockDirectSalesResp obj = new MockDirectSalesResp();
    
    global MockHttpResponseGeneratorGetBilling() {
       
    }

    global HTTPResponse respond(HTTPRequest req) {
        HTTPResponse httpResponse = new httpResponse();
        if(req.getBody().contains('locationID')){
            
            httpResponse.setHeader('Content-Type', 'application/xml');
            httpResponse.setBody(MockDirectSalesResp.generateAccountContResponse);
            httpResponse.setStatusCode(200);  
            //return httpResponse;
        }/*else if(req.getBody().contains('pdfStatementID')){
            httpResponse.setHeader('Content-Type', 'application/xml');
            httpResponse.setBody(obj.generateAccountMangResponseSecond);
            httpResponse.setStatusCode(200);
          }*/
          return httpResponse;
    }
}