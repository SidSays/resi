@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assertEquals('https://soa.comcast.com/AccountManagementControllerService/1.35?WSDL', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-type','text/xml');
        res.setBody('<note><to>ToTest1</to><from>Test2</from><heading>Reminder</heading><body>Testing body</body></note>');
        return res;
    }
}