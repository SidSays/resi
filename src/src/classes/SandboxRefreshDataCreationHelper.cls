public class SandboxRefreshDataCreationHelper {
    
    public static void fetchData(String sql, String userName,String passwordSecurityToken){
            JSONParser parser;
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://onecomcast--TQM1.cs43.my.salesforce.com/services/Soap/u/39.0');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            request.setHeader('SOAPAction', '""');

            request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + userName+ '</username><password>' + passwordSecurityToken + '</password></login></Body></Envelope>');
            Dom.XmlNode resultElmt = (new Http()).send(request).getBodyDocument().getRootElement()
                .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
                .getChildElement('result', 'urn:partner.soap.sforce.com');
   
            final String SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com') .getText().split('/services')[0];
            final String SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com') .getText();
   
            final PageReference theUrl = new PageReference(SERVER_URL + '/services/data/v39.0/query/');
            theUrl.getParameters().put('q',sql);
            request = new HttpRequest();
            request.setEndpoint(theUrl.getUrl());
            request.setMethod('GET');
            request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
   
            String body = (new Http()).send(request).getBody();
            system.debug('body>>>>>>'+body);
            parser = JSON.createParser(body);
            createAccountRecords(parser);
    }
    public static void createAccountRecords(JSONParser parser){
        //List<Account> accountList = new List<Account>();
        List<sObject> lstSobject = new List<sObject>();
        integer i = 0;
        SandboxRefreshParam__c customSetttingObj = SandboxRefreshParam__c.getinstance('Account');
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        string extnlId = string.valueof(customSetttingObj.ExternalId_Value__c)+i;
                        //string extnlId = '1234590909090'+i;
                        Account accRec = (Account)parser.readValueAs(Account.class);
                        Account accountReference = new Account(SandboxRefresh_ExtId__c=extnlId);
                        accRec.SandboxRefresh_ExtId__c = extnlId;
                        lstSobject.add(accRec);
                        for(Contact conObj : accRec.Contacts){
                            conObj.Account = accountReference;
                            lstSobject.add(conObj);
                        }
                        i++;
                        //accountList.add(accRec);
                    }
                }
            }
        }
        lstSobject.sort();
        //List<sObject> lstSobject1 = new List<sObject>();
        //lstSobject1.addAll(lstSobject).sort();
        Database.insert(lstSobject,false);
        //return lstSobject;
    }
}