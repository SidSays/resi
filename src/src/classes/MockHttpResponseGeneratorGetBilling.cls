@isTest                       
global class MockHttpResponseGeneratorGetBilling implements HttpCalloutMock {
    
  
   // MockDirectSalesResp obj = new MockDirectSalesResp();
      public Boolean flag;
    
    global MockHttpResponseGeneratorGetBilling(Boolean flag) {
         this.flag = flag;
       
    }

    global HTTPResponse respond(HTTPRequest req) {
      HTTPResponse httpResponse = new httpResponse();
       // if(req.getBody().contains('locationID')){
        if(!flag){       
            httpResponse.setHeader('Content-Type', 'application/xml');
            httpResponse.setBody(MockDirectSalesResp.generateRealAccountContResponse);
            httpResponse.setStatusCode(201);  
       return httpResponse;
      }
        else
        {
            httpResponse.setHeader('Content-Type', 'application/xml');
            httpResponse.setBody(MockDirectSalesResp.generateAccountContResponse);
            httpResponse.setStatusCode(200); 
             return httpResponse;
        }
            //return httpResponse;
       // }
    /*else if(req.getBody().contains('pdfStatementID')){
            httpResponse.setHeader('Content-Type', 'application/xml');
            httpResponse.setBody(obj.generateAccountMangResponseSecond);
            httpResponse.setStatusCode(200);
          }*/
          return httpResponse;
    }
    
}