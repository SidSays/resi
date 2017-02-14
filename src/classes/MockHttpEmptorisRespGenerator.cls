@isTest
                        
global class MockHttpEmptorisRespGenerator implements HttpCalloutMock {
    
    // Implement this interface method
    public Boolean flag;
    
    global MockHttpEmptorisRespGenerator (Boolean flag) {
    this.flag = flag;
    }
    

    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.  
        
        // Create a fake response
        if(flag){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody(MDU_MockResponseUtility.emptCorrectResp);
            res.setStatusCode(200);
            flag = false;
            return res;

        }
        else {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody(MDU_MockResponseUtility.emptErrHandleResp);            
            return res;
           
        }
       
    }
}