@isTest
                        
global class MockHttpResponseGeneratorForEmptoris implements HttpCalloutMock {
    // Implement this interface method
    public Boolean flag;
    global MockHttpResponseGeneratorForEmptoris(Boolean flag) {
    this.flag = flag;
    }
    

    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.  
        
        // Create a fake response
        if(flag){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Header><ns1:sessionID soapenv:actor="http://schemas.xmlsoap.org/soap/actor/next" soapenv:mustUnderstand="0" xmlns:ns1="http://xml.apache.org/axis/session">-2112006561454585054</ns1:sessionID></soapenv:Header><soapenv:Body><get-url-response xmlns="">https://comcasttraining.emptoris.com/dicarta/signon?user=testUser123&amp;token=jw508XiES91sgThDK6LRxw%3D%3D&amp;credDate=March+12%2C+2015+06%3A51%3A50+AM&amp;credType=SharedSecret&amp;host=&amp;source=DEFAULT&amp;redirectUrl=https%3A%2F%2Fcomcasttraining.emptoris.com%2Fdicarta%2FLoading.do%3Fmodule%3DHomePage%26userType%3Dadv%26userHost%3Dlogin&amp;digAlg=MD5</get-url-response></soapenv:Body></soapenv:Envelope>');
            res.setStatusCode(200);
            flag = false;
            return res;

        }
        else {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            res.setBody('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><soapenv:Fault><faultcode>soapenv:Server.generalException</faultcode><faultstring>Contract with Id test Oppty not available.</faultstring><detail><faultString>Contract with Id test Oppty not available.</faultString><ns1:exceptionName xmlns:ns1="http://xml.apache.org/axis/">com.dicarta.webservices.faults.ObjectNotFoundFault</ns1:exceptionName><ns2:hostname xmlns:ns2="http://xml.apache.org/axis/">wdc01c189r10r01ecm2.sl.emptoris.com</ns2:hostname></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>');
            
            return res;
           
        }
       
    }
}