global class TestWSController {
    global String URL {get;set;}
    public String retString {get;set;}
    public HttpResponse Results1 {get;set;}
    
    public PageReference callPing() {
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(URL);
            req.setMethod('GET');
            Http h = new Http();
            HttpResponse res = h.send(req);
            retString = res.toString();
            if(retString.contains('Status=OK')){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, retString)); 
            } else{
                 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, retString));    
            }
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, e.getMessage()));   
            retString = '';
        }
        return null;
    }
}