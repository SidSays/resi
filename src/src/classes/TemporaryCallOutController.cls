public class TemporaryCallOutController {
    
    public String retString {get;set;}
    public String auth{get;set;}
    public String SoapXMLBody{get;set;}
    public HttpResponse Results1 {get;set;}
    
    public TemporaryCallOutController(){
        retString = '';
        auth = '';
        SoapXMLBody = '';
    }
    public pageReference test(){
        retString = '';
        auth = '';        
        string SoapXML;
        SoapXML = SoapXMLBody;
        Integer ContentLength = 0;
        ContentLength = SoapXML.length();

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        req.setMethod('POST');
        req.setEndPoint('https://soa.comcast.com/AccountManagementControllerService/1.35?WSDL'); 
        req.setHeader('Content-type','text/xml');
        req.setHeader('Content-Length',ContentLength.format());
        req.setHeader('SoapAction','https://soa.comcast.com/AccountManagementControllerService/1.35?WSDL');
    
        req.setBody(SoapXML);
        res = h.send(req);
        retString = res.ToString();
        System.Debug('res:'+res);
        
        auth = res.getBody();
        System.Debug('Debug(auth:'+auth);
        return null;
    }
}