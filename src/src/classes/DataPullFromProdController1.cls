//TODO - documentation, removing commented code, novasuite issues, enhancemnent, linking of records etc. inserting property. removing hardcode etc.
//TODO - For custom settings data need to see if upsert can be used.
public class DataPullFromProdController1 {
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
            /*Map<String,String> objectAPINameVsFieldsMap = new Map<String,String>();
            List<Sandbox_Refresh_Object_Mapping__mdt> sandboxmetaDataMappingList = new List<Sandbox_Refresh_Object_Mapping__mdt> ();
            String valueForProperty = '';
            sandboxmetaDataMappingList  = [SELECT DeveloperName, Field_Set__c FROM Sandbox_Refresh_Object_Mapping__mdt WHERE DeveloperName=:objectName
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            if(!sandboxmetaDataMappingList.isEmpty()) {
                for(Sandbox_Refresh_Object_Mapping__mdt metaObj : sandboxmetaDataMappingList) {
                    fieldsToQuery = metaObj.Field_Set__c;
                    objectAPINameVsFieldsMap.put(metaObj.DeveloperName,metaObj.Field_Set__c);
                }
            }*/
             
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
                sql += ' ORDER BY CreatedDate LIMIT 300';
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
            
            /*-----------------------------------
             Login via SOAP/XML web service api
            -----------------------------------*/
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://onecomcast--TQM1.cs43.my.salesforce.com/services/Soap/u/39.0');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/xml;charset=UTF-8');
            request.setHeader('SOAPAction', '""');
            /*not escaping username and password because we're setting those variables above
            in other words, this line "trusts" the lines above
            if username and password were sourced elsewhere, they'd need to be escaped below*/
            request.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + userName+ '</username><password>' + passWord + securityToken + '</password></login></Body></Envelope>');
            Dom.XmlNode resultElmt = (new Http()).send(request).getBodyDocument().getRootElement()
                .getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/')
                .getChildElement('loginResponse', 'urn:partner.soap.sforce.com')
                .getChildElement('result', 'urn:partner.soap.sforce.com');
   
            /*-------------------------------
             Grab session id and server url
            --------------------------------*/
            final String SERVER_URL = resultElmt.getChildElement('serverUrl', 'urn:partner.soap.sforce.com') .getText().split('/services')[0];
            final String SESSION_ID = resultElmt.getChildElement('sessionId', 'urn:partner.soap.sforce.com') .getText();
   
            /*----------------------------------
             Load first 20 accounts via REST API
            ---------------------------------*/
            final PageReference theUrl = new PageReference(SERVER_URL + '/services/data/v39.0/query/');
            theUrl.getParameters().put('q',sql);
            request = new HttpRequest();
            request.setEndpoint(theUrl.getUrl());
            request.setMethod('GET');
            request.setHeader('Authorization', 'OAuth ' + SESSION_ID);
   
            String body = (new Http()).send(request).getBody();
            system.debug('body>>>>>>'+body);
            JSONParser parser = JSON.createParser(body);
            if(objectName == 'Account'){
                createAccountRecords(parser);
                
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
                        /*addressObj.Name = addressRec.Name;
                        addressObj.Address__c = addressRec.Address__c;
                        addressObj.Address_2__c = addressRec.Address_2__c;
                        addressObj.Biller_Agent_Code__c = addressRec.Biller_Agent_Code__c;
                        addressObj.Biller_Principal_Code__c = addressRec.Biller_Principal_Code__c;
                        addressObj.Biller_System_Code__c = addressRec.Biller_System_Code__c;
                        addressObj.Billing_Account_Key__c = addressRec.Billing_Account_Key__c;
                        addressObj.Billing_House_Key__c = addressRec.Billing_House_Key__c;
                        addressObj.Census_Block__c = addressRec.Census_Block__c;
                        addressObj.City__c = addressRec.City__c;
                        addressObj.Comp_Footprint__c = addressRec.Comp_Footprint__c;
                        addressObj.Complex_Office__c = addressRec.Complex_Office__c;
                        addressObj.Corp__c = addressRec.Corp__c;
                        addressObj.Country__c = addressRec.Country__c;
                        addressObj.Dwelling_Type__c = addressRec.Dwelling_Type__c;
                        addressObj.Dwell_Type_Description__c = addressRec.Dwell_Type_Description__c;
                        addressObj.Excluded__c = addressRec.Excluded__c;
                        addressObj.Excluded_from_Territory__c = addressRec.Excluded_from_Territory__c;
                        addressObj.Exclude_from_Plan__c = addressRec.Exclude_from_Plan__c;
                        addressObj.Exclusion_Lens__c = addressRec.Exclusion_Lens__c;
                        addressObj.HSI_Only_Address__c = addressRec.HSI_Only_Address__c;
                        addressObj.Inclusion_Lens__c = addressRec.Inclusion_Lens__c;
                        addressObj.Latitude__c = addressRec.Latitude__c;
                        addressObj.Location_ID__c = addressRec.Location_ID__c;
                        addressObj.Longitude__c = addressRec.Longitude__c;
                        addressObj.Node__c = addressRec.Node__c;
                        addressObj.Property_Code__c = addressRec.Property_Code__c;
                        addressObj.Region__c = addressRec.Region__c;
                        addressObj.State__c = addressRec.State__c;
                        addressObj.Targeted__c = addressRec.Targeted__c;
                        addressObj.PostalCode__c = addressRec.PostalCode__c;
                        addressObj.PostalCode_4__c = addressRec.PostalCode_4__c;*/
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
                        /*territoryObj.Name = territoryRec.Name;
                        territoryObj.Census_Tracts__c = territoryRec.Census_Tracts__c;
                        territoryObj.Region__c = territoryRec.Region__c;
                        territoryObj.Status__c = territoryRec.Status__c;
                        territoryObj.Territory_Code__c = territoryRec.Territory_Code__c;
                        territoryObj.AssignedTo__c = territoryRec.AssignedTo__c;
                        territoryObj.OwnerId = territoryRec.OwnerId;*/
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
                        /*termAndConditionObj.Terms_and_Conditions_Text__c = tAndCRec.Terms_and_Conditions_Text__c;
                        termAndConditionObj.Active__c = tAndCRec.Active__c;
                        termAndConditionObj.Reset_Terms_and_Conditions_Accepted__c = tAndCRec.Reset_Terms_and_Conditions_Accepted__c;*/
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
                        /*metricObj.Name = metricRec.Name;
                        metricObj.StartDate = metricRec.StartDate;
                        metricObj.DueDate = metricRec.DueDate;
                        metricObj.Description = metricRec.Description;
                        metricObj.RecordTypeId = metricRec.RecordTypeId;
                        metricObj.Status = metricRec.Status;
                        metricObj.TargetValue = metricRec.TargetValue;
                        metricObj.Sort_Order__c = metricRec.Sort_Order__c;*/
                        metricList.add(metricRec);
                    }
                }
            }
        }
        Database.insert(metricList,true);
        return metricList;
    }
    //
    public List<Goal> createGoalRecords(JSONParser parser){
        List<Goal> goalList = new List<Goal>();
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Goal goalObj = new Goal();
                        Goal goalRec = (Goal)parser.readValueAs(Goal.class);
                        /*goalObj.Name = goalRec.Name;
                        goalObj.StartDate = goalRec.StartDate;
                        goalObj.DueDate = goalRec.DueDate;
                        goalObj.Description = goalRec.Description;
                        goalObj.RecordTypeId = goalRec.RecordTypeId;
                        goalObj.Status = goalRec.Status;
                        goalObj.Division__c = goalRec.Division__c;
                        goalObj.Level__c = goalRec.Level__c;
                        goalObj.Profile_Name__c = goalRec.Profile_Name__c;
                        goalObj.Region__c = goalRec.Region__c;
                        goalObj.Sales_Rep_Type__c = goalRec.Sales_Rep_Type__c;
                        goalObj.Template_Type__c = goalRec.Template_Type__c;*/
                        goalList.add(goalRec);
                    }
                }
            }
        }
        Database.insert(goalList,true);
        return goalList;
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
                        /*cont.FirstName = conRec.FirstName;
                        cont.LastName = conRec.LastName;
                        cont.RecordTypeId = conRec.RecordTypeId;
                        cont.Email = conRec.Email;
                        cont.phone = conRec.Phone;*/
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
    //
    public List<Account> createAccountRecords(JSONParser parser){
        List<Account> accountList = new List<Account>();
        while (parser.nextToken() != null) {
            if(parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while(parser.nextToken() != null) {
                    if(parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        Account acct = new Account();
                        Account accRec = (Account)parser.readValueAs(Account.class);
                        /*acct.Name = accRec.Name;
                        acct.AccountNumber = accRec.AccountNumber;
                        acct.RecordTypeId = accRec.RecordTypeId;
                        acct.AccountSource = accRec.AccountSource;
                        acct.Description = accRec.Description;
                        acct.Phone = accRec.Phone;
                        acct.Type = accRec.Type;
                        acct.X3rd_party_consultant_text__c = accRec.X3rd_party_consultant_text__c;
                        acct.Account_Type_Values__c = accRec.Account_Type_Values__c;
                        acct.Billing_Account_key__c = accRec.Billing_Account_key__c;
                        acct.Billing_Account_Number__c = accRec.Billing_Account_Number__c;
                        acct.City__c = accRec.City__c;
                        acct.Country__c = accRec.Country__c;
                        acct.Customer_Status__c = accRec.Customer_Status__c;
                        acct.House_Key__c = accRec.House_Key__c;
                        if(accRec.IsActive__c != null && accRec.IsActive__c) {
                            acct.IsActive__c = true;
                        }
                        else{
                            acct.IsActive__c = false;
                        }
                        acct.LeadExpirationDuration__c = accRec.LeadExpirationDuration__c;
                        acct.LeadTransferDuration__c = accRec.LeadTransferDuration__c;
                        acct.Length_of_Residence__c = accRec.Length_of_Residence__c;
                        acct.Monthly_RGU_Activations_Goal__c = accRec.Monthly_RGU_Activations_Goal__c;
                        acct.Monthly_RGU_Order_Goal__c = accRec.Monthly_RGU_Order_Goal__c;
                        acct.Name__c = accRec.Name__c;
                        acct.OpportunityExpirationDuration__c = accRec.OpportunityExpirationDuration__c;
                        acct.OpportunityTransferDuration__c = accRec.OpportunityTransferDuration__c;
                        acct.Postal_Code__c = accRec.Postal_Code__c;
                        acct.Prior_Value__c = accRec.Prior_Value__c;
                        acct.Region__c = accRec.Region__c;
                        acct.MDU_State__c = accRec.MDU_State__c;
                        acct.Store_Designation__c = accRec.Store_Designation__c;
                        acct.Store_Type__c = accRec.Store_Type__c;
                        acct.Zip_Code__c = accRec.Zip_Code__c;*/
                        accountList.add(accRec);
                    }
                }
            }
        }
        Database.insert(accountList,false);
        return accountList;
    }
    /*public class ProdContactRecord {
        String FirstName;
        String LastName;
        String RecordTypeId;
        String Email;
        String Phone;
        //String billAccnumber;
        //String Account.Billing_Account_Number__c = conRec.Account.Billing_Account_Number__c;
    }*/

    /*public class ProdAccountRecord {
        String Name;
        String AccountNumber;
        String RecordTypeId;
        String AccountSource;
        String Description;
        String Phone;
        String Type;
        String X3rd_party_consultant_text;
        String Account_Type_Values;
        String Billing_Account_key;
        String Billing_Account_Number;
        String City;
        String Country;
        String Customer_Status;
        String House_Key;
        Boolean IsActive;
        Decimal LeadExpirationDuration;
        Decimal LeadTransferDuration;
        Decimal Length_of_Residence;
        Decimal Monthly_RGU_Activations_Goal;
        Decimal Monthly_RGU_Order_Goal;
        String Name1;
        Decimal OpportunityExpirationDuration;
        Decimal OpportunityTransferDuration;
        Decimal Postal_Code;
        String Prior_Value;
        String Region;
        String MDU_State;
        String Store_Designation;
        String Store_Type;
        String Zip_Code;
    }*/
    /*public class AccountRecord {
        String name;
        String AccountNumber;
        String RecordTypeId;
        String AccountSource;
        String Description;
        String Phone;
        String Type;
        String X3rd_party_consultant_text;
        String Account_Type_Values;
        String Billing_Account_key;
        String Billing_Account_Number;
        String City;
        String Country;
        String Customer_Status;
        String House_Key;
        Boolean IsActive;
        Decimal LeadExpirationDuration;
        Decimal LeadTransferDuration;
        Decimal Length_of_Residence;
        Decimal Monthly_RGU_Activations_Goal;
        Decimal Monthly_RGU_Order_Goal;
        String Name1;
        Decimal OpportunityExpirationDuration;
        Decimal OpportunityTransferDuration;
        Decimal Postal_Code;
        String Prior_Value;
        String Region;
        String MDU_State;
        String Store_Designation;
        String Store_Type;
        String Zip_Code;
    }
    public AccountRecord copyProdAccountRecordToAccountRecord (ProdAccountRecord prodAccRec) {
        AccountRecord acRec = new AccountRecord();
        acRec.Name = prodAccRec.Name;
        acRec.AccountNumber = prodAccRec.AccountNumber;
        acRec.RecordTypeId = prodAccRec.RecordTypeId;
        acRec.AccountSource = prodAccRec.AccountSource;
        acRec.Description = prodAccRec.Description;
        acRec.Phone = prodAccRec.Phone;
        acRec.Type = prodAccRec.Type;
        acRec.X3rd_party_consultant_text = prodAccRec.X3rd_party_consultant_text;
        acRec.Account_Type_Values = prodAccRec.Account_Type_Values;
        acRec.Billing_Account_key = prodAccRec.Billing_Account_key;
        acRec.Billing_Account_Number = prodAccRec.Billing_Account_Number;
        acRec.City = prodAccRec.City;
        acRec.Country = prodAccRec.Country;
        acRec.Customer_Status = prodAccRec.Customer_Status;
        acRec.House_Key = prodAccRec.House_Key;
        acRec.IsActive = prodAccRec.IsActive;
        acRec.LeadExpirationDuration = prodAccRec.LeadExpirationDuration;
        acRec.LeadTransferDuration = prodAccRec.LeadTransferDuration;
        acRec.Length_of_Residence = prodAccRec.Length_of_Residence;
        acRec.Monthly_RGU_Activations_Goal = prodAccRec.Monthly_RGU_Activations_Goal;
        acRec.Monthly_RGU_Order_Goal = prodAccRec.Monthly_RGU_Order_Goal;
        acRec.Name1 = prodAccRec.Name1;
        acRec.OpportunityExpirationDuration = prodAccRec.OpportunityExpirationDuration;
        acRec.OpportunityTransferDuration = prodAccRec.OpportunityTransferDuration;
        acRec.Postal_Code = prodAccRec.Postal_Code;
        acRec.Prior_Value = prodAccRec.Prior_Value;
        acRec.Region = prodAccRec.Region;
        acRec.MDU_State = prodAccRec.MDU_State;
        acRec.Store_Designation = prodAccRec.Store_Designation;
        acRec.Store_Type = prodAccRec.Store_Type;
        acRec.Zip_Code = prodAccRec.Zip_Code;
        return acRec;
    }*/
}