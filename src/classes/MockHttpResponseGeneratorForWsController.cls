/***************************************************************************************************************************************
 * Author     :Lalit Singh, Accenture
 * Date       : 08-June-2015
 * Description: This is Test class to create the mock data for the request.
 * History
     Version             : 1.0
     Author Last Updated : Lalit, Accenture 
     PROJECT             : Residential Salesforce
***************************************************************************************************************************************/
@isTest

global class MockHttpResponseGeneratorForWsController implements HttpCalloutMock {

    // Implement this interface method
    public Boolean flag;
    
    global MockHttpResponseGeneratorForWsController(Boolean flag) {
        this.flag = flag;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        // Creating a fake response
        if(flag)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('OK');
            res.setStatusCode(200);
            flag = false;
            return res;
        }
            else{
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/xml');
                res.setBody('NOTOK');
                return res;
            }
    }
}