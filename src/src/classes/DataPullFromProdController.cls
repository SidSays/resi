//TODO - documentation, removing commented code, novasuite issues, enhancemnent, linking of records etc. inserting property. removing hardcode etc.
//TODO - For custom settings data need to see if upsert can be used.
public class DataPullFromProdController {
    public String userName {get;set;}   
    public String passWord {get;set;}
    public String securityToken {get;set;}  
    public String objectName {get;set;}
    public String[] objNames = new String[]{'None'};
    public List<String> fieldNames = new List<String>();
    public List<String> availableFieldNames = new List<String>();
    public sobjectPartnerSoapSforceCom.sObject_x[] values;  
    //public List<String> output {get; set;}
    public String output {get; set;}
    //public List<sobjectPartnerSoapSforceCom.sObject_x> output {get; set;}
    public integer i {get;set;}
    public integer j = 0;
       
    /* String array for select box(Fields) */
    String[] selectedFields = new String[]{};
    String[] checkedFields = new String[]{};
   
    public partnerSoapSforceCom.Soap con = new partnerSoapSforceCom.Soap();
   
    public void login()
    {
        if(checkLogin())
        {
            retrieveObjects();
        }
    }
   
    public boolean checkLogin(){
        try{                                 
            partnerSoapSforceCom.LoginResult loginResult = con.login(username, (password+securityToken));                   
            con.SessionHeader = new partnerSoapSforceCom.SessionHeader_element();       
            con.endpoint_x =loginResult.ServerUrl;       
            con.Sessionheader.sessionid = loginResult.sessionid;
        }catch(Exception e){}
        return true;
    }
    
     /* Retrieving all the objects */
    public void retrieveObjects(){
        if(checkLogin()){
            partnerSoapSforceCom.DescribeGlobalresult sobjectResults = con.describeGlobal();
            partnerSoapSforceCom.DescribeGlobalSObjectResult[] objects = sobjectResults.sobjects;        
            for(partnerSoapSforceCom.DescribeGlobalSObjectResult tmpRes:objects){
                objNames.add(tmpRes.Name);
            }
        }
    }
    
    /* Getting the selected object name */
    public String getobjectName()    
    {     
        return objectName;   
    }       
    public void setobjectName(String obj)    
    {     
        this.objectName = objectName;    
    }
     
    public List<SelectOption> getobjectNames(){         
        List<SelectOption> options = new List<SelectOption>();
        Map<String,String> metadataObjMap = getFieldNamesFromMetadata();
        for(String temp:objNames){
            if(metadataObjMap != null && !metadataObjMap.isEmpty() && metadataObjMap.containsKey(temp))
            options.add(new SelectOption(temp,temp));
        }     
        return options;   
    }
    
    public Map<String,String> getFieldNamesFromMetadata(){
            //String fieldsToQuery = '';
            Map<String,String> objectAPINameVsFieldsMap = new Map<String,String>();
            List<Sandbox_Refresh_Object_Mapping__mdt> sandboxmetaDataMappingList = new List<Sandbox_Refresh_Object_Mapping__mdt> ();
            String valueForProperty = '';
            sandboxmetaDataMappingList  = [SELECT DeveloperName, Field_Set__c, Object_API_Name__c FROM Sandbox_Refresh_Object_Mapping__mdt
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            if(!sandboxmetaDataMappingList.isEmpty()) {
                for(Sandbox_Refresh_Object_Mapping__mdt metaObj : sandboxmetaDataMappingList) {
                    //fieldsToQuery = metaObj.Field_Set__c;
                    objectAPINameVsFieldsMap.put(metaObj.Object_API_Name__c,metaObj.Field_Set__c);
                }
            }
        return objectAPINameVsFieldsMap;
    }
    
    public void fetch(){
        if(checkLogin()){
            integer availableFieldNamesLen = availableFieldNames.size();
            String fieldsToQuery = '';
            Map<String, String> copyingDataToAnotherMap = getFieldNamesFromMetadata();
             
            SandboxRefreshObjectMapping__c objName = SandboxRefreshObjectMapping__c.getInstance(objectName);
            //Set<Id> billingAccNumberSet = new Set<Id>();
            Map<String,Id> accIdVsBillingAccNumMap = new Map<String,Id>();
            if('Contact'.equalsIgnorecase(objectName)){
                List<Account> accList = [SELECT Id, Billing_Account_Number__c FROM Account WHERE Billing_Account_Number__c!= null];
                for(Account acc: [SELECT Id, Billing_Account_Number__c FROM Account WHERE Billing_Account_Number__c!= null]){
                    //billingAccNumberSet.add(acc.Billing_Account_Number__c);
                    accIdVsBillingAccNumMap.put(acc.Billing_Account_Number__c,acc.Id);
                }
            }
            
            String sql = '';
            if(copyingDataToAnotherMap != null && !String.isBlank(objectName) && copyingDataToAnotherMap.containsKey(objectName)){
                sql += 'SELECT ' + copyingDataToAnotherMap.get(objectName) + ' FROM ' + objectName;
                if('Contact'.equalsIgnorecase(objectName)){
                    //sql += ' WHERE Account.Billing_Account_Number__c IN : accIdVsBillingAccNumMap.keySet()';
                }
                if(objectName == 'Goal'){
                    sql += ' WHERE RecordTypeId = \'012160000010oBS\'';
                }
                if(objectName == 'Metric'){
                    sql += ' WHERE RecordTypeId = \'01216000001YcH5\'';
                }
                sql += ' ORDER BY CreatedDate';
                if(objectName != 'Account'){
                    sql += ' LIMIT 300';
                }
                system.debug('sql>>>>>>>>>'+sql);
            }
            
            /*partnerSoapSforceCom.Soap partner = new partnerSoapSforceCom.Soap();
            partnerSoapSforceCom.LoginResult lr=partner.login('test@example.com', 'myPasswordInPlainText!PlusTheSecurityToken');
            partnerSoapSforceCom.SessionHeader_element header=new partnerSoapSforceCom.SessionHeader_element();
            header.sessionId=lr.sessionId;
            partner.SessionHeader=header;
            partner.endpoint_x = lr.serverUrl;
            partnerSoapSforceCom.QueryResult qr = partner.Query('Select Id from Account limit 1');
            System.debug('Number of Query results:' + qr);
            sobjectPartnerSoapSforceCom.sObject_x result1 = qr.records[0];
            System.debug(result1);*/
            
            JSONParser parser;
            if(objectName != 'Account'){
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://onecomcast--TQM1.cs43.my.salesforce.com/services/Soap/u/39.0');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
                request.setHeader('SOAPAction', '""');

                request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + userName+ '</username><password>' + passWord + securityToken + '</password></login></Body></Envelope>');
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
            }
            if(objectName == 'Account'){
                String query = 'SELECT Id, Name FROM User LIMIT 1';
                integer batchsize = 1; 
                SandboxDataCreationBatch inst = new SandboxDataCreationBatch(query,sql,userName,passWord + securityToken); 
                database.executebatch(inst, batchSize);
                //createAccountRecords(parser);
                
            }
            if(objectName == 'Contact'){
                createContactRecords(parser,accIdVsBillingAccNumMap);
                
            }
            if('Goal'.equalsIgnorecase(objectName)){
                createGoalRecords(parser);
                
            }
            if('Metric'.equalsIgnorecase(objectName)){
                createMetricRecords(parser);
                
            }
            if('Terms_and_Conditions__c'.equalsIgnorecase(objectName)){
                createTandCRecords(parser);
                
            }
            if('Territory__c'.equalsIgnorecase(objectName)){
                createTerritoryRecords(parser);
                
            }
            if('Customer_Address__c'.equalsIgnorecase(objectName)){
                createAddressRecords(parser);
                
            }
            /*if('MDU_Property__c'.equalsIgnorecase(objectName)){
                createProppertyRecords(parser);
                
            }*/
            if('MDU_EmptorisIntegrationCS__c'.equalsIgnorecase(objectName)){
                createEmptorisIntegrationCSRecords(parser);
                
            }
            if('MDU_EmptorisFieldMapping__c'.equalsIgnorecase(objectName)){
                createEmptorisFieldMapRecords(parser);
                
            }
            if('MDU_InterviewTemplateMapping__c'.equalsIgnorecase(objectName)){
                createInterviewTemplateMapRecords(parser);
                
            }
        } 
    }
    public List<MDU_InterviewTemplateMapping__c> createInterviewTemplateMapRecords(JSONParser parser){
        List<MDU_InterviewTemplateMapping__c> emptorInterviewTemplateMapCSList = new List<MDU_InterviewTemplateMapping__c>();
        MDU_InterviewTemplateMapping__c emptorisCS;
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        MDU_InterviewTemplateMapping__c cusSetObj = new MDU_InterviewTemplateMapping__c();
                        MDU_InterviewTemplateMapping__c customSetRec = (MDU_InterviewTemplateMapping__c)parser.readValueAs(MDU_InterviewTemplateMapping__c.class);
                        emptorisCS = MDU_InterviewTemplateMapping__c.getInstance(customSetRec.Name);//can be done before loop using getAll
                        customSetRec.Id = emptorisCS.Id;
                        emptorInterviewTemplateMapCSList.add(customSetRec);
                    }
                }
            }
        }
        Database.update(emptorInterviewTemplateMapCSList,true);
        return emptorInterviewTemplateMapCSList;
    }
    public List<MDU_EmptorisFieldMapping__c> createEmptorisFieldMapRecords(JSONParser parser){
        List<MDU_EmptorisFieldMapping__c> emptorFieldMapCSList = new List<MDU_EmptorisFieldMapping__c>();
        MDU_EmptorisFieldMapping__c emptorisCS;
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        MDU_EmptorisFieldMapping__c cusSetObj = new MDU_EmptorisFieldMapping__c();
                        MDU_EmptorisFieldMapping__c customSetRec = (MDU_EmptorisFieldMapping__c)parser.readValueAs(MDU_EmptorisFieldMapping__c.class);
                        emptorisCS = MDU_EmptorisFieldMapping__c.getInstance(customSetRec.Name);//can be done before loop using getAll
                        customSetRec.Id = emptorisCS.Id;
                        emptorFieldMapCSList.add(customSetRec);
                    }
                }
            }
        }
        Database.update(emptorFieldMapCSList,true);
        return emptorFieldMapCSList;
    }
    public List<MDU_EmptorisIntegrationCS__c> createEmptorisIntegrationCSRecords(JSONParser parser){
        List<MDU_EmptorisIntegrationCS__c> emptorisintegrationCSList = new List<MDU_EmptorisIntegrationCS__c>();
        MDU_EmptorisIntegrationCS__c emptorisCS;
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        MDU_EmptorisIntegrationCS__c cusSetObj = new MDU_EmptorisIntegrationCS__c();
                        MDU_EmptorisIntegrationCS__c customSetRec = (MDU_EmptorisIntegrationCS__c)parser.readValueAs(MDU_EmptorisIntegrationCS__c.class);
                        emptorisCS = MDU_EmptorisIntegrationCS__c.getInstance(customSetRec.Name);//can be done before loop using getAll
                        customSetRec.Id = emptorisCS.Id;
                        emptorisintegrationCSList.add(customSetRec);
                    }
                }
            }
        }
        Database.update(emptorisintegrationCSList,true);
        return emptorisintegrationCSList;
    }
    /*public List<MDU_Property__c> createProppertyRecords(JSONParser parser){
        List<MDU_Property__c> propList = new List<MDU_Property__c>();
        integer i = 0;
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        MDU_Property__c propObj = new MDU_Property__c();
                        MDU_Property__c propRec = (MDU_Property__c)parser.readValueAs(MDU_Property__c.class);
                        if(propRec.Industry_Type__c!=null){
                            propRec.Contracting_Org_Type__c = 'None';
                        }
                        propList.add(propRec);
                        i++;
                    }
                }
            }
        }
        Database.insert(propList,true);
        return propList;
    }*/
    public List<Customer_Address__c> createAddressRecords(JSONParser parser){
        List<Customer_Address__c> addressList = new List<Customer_Address__c>();
        integer i = 0;
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Customer_Address__c addressObj = new Customer_Address__c();
                        Customer_Address__c addressRec = (Customer_Address__c)parser.readValueAs(Customer_Address__c.class);
                        addressRec.OwnerId = '005G0000004HHd8';
                        //addressRec.Billing_House_Key__c = '53721345'+ i;//temporary - need to remove
                        addressList.add(addressRec);
                        i++;
                    }
                }
            }
        }
        Database.insert(addressList,false);
        return addressList;
    }
    public List<Territory__c> createTerritoryRecords(JSONParser parser){
        List<Territory__c> territoryList = new List<Territory__c>();
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Territory__c territoryObj = new Territory__c();
                        Territory__c territoryRec = (Territory__c)parser.readValueAs(Territory__c.class);
                        territoryList.add(territoryRec);
                    }
                }
            }
        }
        Database.insert(territoryList,false);
        return territoryList;
    }
    public List<Terms_and_Conditions__c> createTandCRecords(JSONParser parser){
        List<Terms_and_Conditions__c> termsAndConditionList = new List<Terms_and_Conditions__c>();
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Terms_and_Conditions__c termAndConditionObj = new Terms_and_Conditions__c();
                        Terms_and_Conditions__c tAndCRec = (Terms_and_Conditions__c)parser.readValueAs(Terms_and_Conditions__c.class);
                        termsAndConditionList.add(tAndCRec);
                    }
                }
            }
        }
        Database.insert(termsAndConditionList,true);
        return termsAndConditionList;
    }
    //
    public List<Metric> createMetricRecords(JSONParser parser){
        List<Metric> metricList = new List<Metric>();
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Metric metricObj = new Metric();
                        Metric metricRec = (Metric)parser.readValueAs(Metric.class);
                        metricList.add(metricRec);
                    }
                }
            }
        }
        Database.insert(metricList,true);
        return metricList;
    }
    //
    public List<sObject> createGoalRecords(JSONParser parser){
        List<sObject> lstSobject = new List<sObject>();
        integer i = 0;
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Goal goalRec = (Goal)parser.readValueAs(Goal.class);
                        string extnlId = '9994590909090'+i;
                        Goal goalReference = new Goal(SandboxRefresh_ExtId__c=extnlId);
                        goalRec.SandboxRefresh_ExtId__c = extnlId;
                        lstSobject.add(goalRec);
                        for(Metric goalObj : goalRec.Metrics){
                            goalObj.Goal = goalReference;
                            lstSobject.add(goalObj);
                        }
                        i++;
                    }
                }
            }
        }
        lstSobject.sort();
        Database.insert(lstSobject,true);
        return lstSobject;
    }
    //
    public List<Contact> createContactRecords(JSONParser parser,Map<String,Id> accIdVsBillingAccNumMap){
        List<Contact> contactList = new List<Contact>();
        List<Contact> finalContactList = new List<Contact>();
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Contact cont = new Contact();
                        Contact conRec = (Contact)parser.readValueAs(Contact.class);
                        conRec.AccountId = '001c000001Edt75';
                        //cont.AccountId = conRec.billAccnumber;
                        //cont.Account.Billing_Account_Number__c = conRec.billAccnumber;
                        contactList.add(conRec);
                    }
                }
            }
        }
        Database.insert(contactList,true);
        for(Contact cont : contactList){
            //cont.AccountId = accIdVsBillingAccNumMap.get(cont.Account.Billing_Account_Number__c);
            finalContactList.add(cont);
        }
        //Database.insert(finalContactList,false);
        
        return finalContactList;
    }
    //SandboxRefresh_ExtId__c   
    public List<sObject> createAccountRecords(JSONParser parser){
        //List<Account> accountList = new List<Account>();
        List<sObject> lstSobject = new List<sObject>();
        integer i = 0;
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        string extnlId = '1234590909090'+i;
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
        return lstSobject;
    }
}