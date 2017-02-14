/************************************************************************************************************************************************************
Name: AccountContactAddressLocationCallout 
Description: This class is used make http callout to generate Vf page and display Account/Contact information
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
28 Sep 2015 Comcast(Direct Sales)  
*************************************************************************************************************************************************************/

public class AccountContactAddressLocationCallout
{

        public static string BLANK_VALUE = '';
        public static String endUrl ='';
        public static String userName = ''; 
        public static String password = ''; 
        public static String systemServiceId = ''; 
        
    //piblic String billingAccntNo;
    /*public AccountManagementServiceCallout(ApexPages.StandardController accnt){
        String accntId = ApexPages.CurrentPage().getParameters().get('Id');
        billingAccntNo = [select Billing_Account_Number__c from Account where Id = :accntId limit 1].Billing_Account_Number__c;
    }*/
    public static void generateHttpResponse()
        {   
            String todayDate = Datetime.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
            String trackingId = Datetime.now().format('yyyyMMddHH'); 
            initialiseConstantVariable();
          
            String soapEnvTemplate = '<soapenv:Envelope xmlns:ser="http://xml.comcast.com/accountmanagement/services" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:typ="http://xml.comcast.com/types" xmlns:typ1="http://xml.comcast.com/accountmanagement/types" xmlns:typ2="http://xml.comcast.com/common/types">';
            soapEnvTemplate += '<soapenv:Header> <typ:requestHeader><typ:timestamp>{0}</typ:timestamp> <typ:sourceSystemId>{1}</typ:sourceSystemId> <typ:sourceSystemUserId>{2}</typ:sourceSystemUserId> <typ:sourceServerId>{3}</typ:sourceServerId> <typ:trackingId>{4}</typ:trackingId></typ:requestHeader>';                                                                                                                                
            soapEnvTemplate += '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><wsse:UsernameToken wsu:Id="UsernameToken-12">';                   
            soapEnvTemplate += '<wsse:Username>{5}</wsse:Username><wsse:Password>{6}</wsse:Password><wsse:Nonce>{7}</wsse:Nonce> <wsu:Created>{8}</wsu:Created> </wsse:UsernameToken></wsse:Security> </soapenv:Header>';                                                                                                                      
            soapEnvTemplate += '<soapenv:Body><ser:queryBillingArrangement> <ser:queryBillingArrangementCriteria><typ1:serviceAddress><typ2:locationID>{9}</typ2:locationID>';
            soapEnvTemplate += '</typ1:serviceAddress> </ser:queryBillingArrangementCriteria></ser:queryBillingArrangement> </soapenv:Body> </soapenv:Envelope>';
           
            List<String> params = new List<String>();               
                
            params.add(todayDate); 
            params.add(systemServiceId);
            params.add(userName);
            params.add(systemServiceId);
            params.add(trackingId+'1');
            params.add(userName);
            params.add(password);
            params.add(trackingId+'1234');
            params.add(todayDate); 
            params.add('23060000046653');
                              
            String soapMsg = String.format(soapEnvTemplate, params);                   
            HttpRequest req = new HttpRequest();
            System.debug('---End Url---'+endUrl);
            req.setEndpoint(endUrl);
            req.setMethod('GET');
            req.setTimeout(12000);
            req.setBody(soapMsg);
            Http http = new Http();
            HttpResponse resp = http.send(req);     
                
        }
      
             
     /**
        * Name: initialiseConstantVariable
        * Description: This method is used to Set The constant Variables values come from custom setting. 
        * @parameters: None
        * @return: None
    **/
    public static void initialiseConstantVariable(){
        Map<String, String> mapOfParamNameAndValue = new Map<String , String>();
        for(AccountManagementServiceCS__c objectCS : AccountManagementServiceCS__c.getall().values()){
            if(objectCS.Name != null){
                    if(objectCS.Param_Value__c != null){
                        mapOfParamNameAndValue.put(objectCS.Name,objectCS.Param_Value__c);
                    }else{
                        mapOfParamNameAndValue.put(objectCS.Name,'');
                    }
            }
        }
        endUrl = mapOfParamNameAndValue.get('Endurl');
        password = mapOfParamNameAndValue.get('Password');
        userName = mapOfParamNameAndValue.get('Username');    
        systemServiceId = mapOfParamNameAndValue.get('SystemServiceId');          
    }
    /*
    public static void getPdfResponseId(HttpResponse pdfAttachmentResp){                            
        Dom.Document doc = pdfAttachmentResp.getBodyDocument();       
        Dom.XMLNode getPdfDetailRes = doc.getRootElement();                                          
        //For Body Element                       
        Dom.XmlNode node = getPdfDetailRes.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');       
        for (Dom.XMLNode child: node.getChildren()) {          
           getRecursivelyPdfChilds(child);
        }                          
    }
    
    public static void getRecursivelyPdfChilds(Dom.XMLNode node){        
       
       if(node.getNodeType() == DOM.XMLNodeType.ELEMENT){ 
            system.debug(LoggingLevel.ERROR,'--Node Name--'+node.getName());                        
            //Check For Node Other Than 'pdfStatementImage'                      
            if(!'pdfStatementImage'.equalsIgnoreCase(node.getName())){                  
                    for(Dom.XMLNode childField2 : node.getChildElements()){                                 
                       getRecursivelyPdfChilds(childField2);
                  }         
            }else{                                                  
                system.debug(LoggingLevel.ERROR,'--Node--'+node.getText());                    
            }
        }
    } 
      
    */
}