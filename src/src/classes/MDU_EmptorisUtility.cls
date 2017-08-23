/************************************************************************************************************************************************************
Name: MDU_EmptorisUtility 
Description: This class is used as a utility class for Emptoris Integration Services.
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
16 Feb 2015 Comcast  
*************************************************************************************************************************************************************/
public class MDU_EmptorisUtility {
    
    // Variable declaration
    public static String parsedValue ='';
    // Variable for HttpRequest
    public static string BLANK_VALUE = '';
    public static String hostStr ='';
    public static String sourceStr = ''; 
    public static String algoStr = ''; 
    public static String shareSecret = ''; 
    public static String GET_CONTRACT_ENDPOINT = '';
    public static String writeBackUser = '';
    public static String revisionId='';
    
    
    // Global Describe
    public static Map<String, Schema.SobjectType> schemaMap = Schema.getGlobalDescribe();//Get sObject name from Id 
    
    /**
    * Name: setConstantVariable
    * Description: This method is used to Set The constant Variables values come from custom setting. 
    * @parameters: None
    * @return: None
    **/
    public static void initialiseConstantVariable(){
        Map<String, String> mapOfParamNameAndValue = new Map<String , String>();
        for(MDU_EmptorisIntegrationCS__c objectCS : MDU_EmptorisIntegrationCS__c.getall().values()){
            if(objectCS.Param_Name__c != null){
                    if(objectCS.Param_Value__c != null){
                        mapOfParamNameAndValue.put(objectCS.Param_Name__c,objectCS.Param_Value__c);
                    }else{
                        mapOfParamNameAndValue.put(objectCS.Param_Name__c,'');
                    }
            }
        }
        sourceStr = mapOfParamNameAndValue.get(MDU_Constants.SOURCESTR);
        algoStr = mapOfParamNameAndValue.get(MDU_Constants.ALGOSTR);
        shareSecret = mapOfParamNameAndValue.get(MDU_Constants.SHARED_SECRET);    
        writeBackUser = mapOfParamNameAndValue.get(MDU_Constants.MDU_WRITEBACT_USER);   
        GET_CONTRACT_ENDPOINT = mapOfParamNameAndValue.get(MDU_Constants.GETCONTRACT_DETAILS_ENDPOINT);
        revisionId = mapOfParamNameAndValue.get('REVISIONID');
    }
    
    /**
    * Name: MDU_EmptorisUtility
    * Description: This is constructor. 
    * @parameters: None
    * @return: None
    **/
    public MDU_EmptorisUtility(){
        parsedValue = '';      
    }
    
    
    /**
    * Name: fetchOpportunityPropertyData
    * Description: This method is used to fetch the data of Opportunity and Property object. 
    * @parameters: opptyId
    * @return: Opportunity_Property__c
    * @Modify : remove the Opportunity__r.Owner.MDU_Area__c,Opportunity__r.Owner.MDU_Region__c,Opportunity__r.Owner.MDU_Division__c from query
    **/
    public static Opportunity_Property__c fetchOpportunityPropertyData(String opptyId){
        
        List<Opportunity_Property__c> objOpportunityProperty = new List<Opportunity_Property__c>();
        if(opptyId != null){
            objOpportunityProperty = [Select Id, Property__c,Opportunity__c,Opportunity__r.Video_Subs__c,Opportunity__r.Video_Bulk_Current_Rate__c, 
            Opportunity__r.Video_Bulk_Proposed_Rate__c,Opportunity__r.Video_Bulk_Discount__c,Opportunity__r.Data_Bulk_Current_Rate__c, 
            Opportunity__r.Data_Bulk_Proposed_Rate__c,Opportunity__r.Data_Bulk_Discount__c,Opportunity__r.Voice_Bulk_Current_Rate__c,
            Opportunity__r.Voice_Bulk_Proposed_Rate__c,Opportunity__r.Voice_Bulk_Discount__c, Opportunity__r.Video_Penetration__c, 
            Opportunity__r.Video_Retail_Rate__c,Opportunity__r.Video_Monthly_Revenue__c,Opportunity__r.Video_Estimated_Revenue_Share_Rate__c, 
            Opportunity__r.Data_Subs__c,Opportunity__r.Data_Penetration__c,Opportunity__r.Data_Retail_Rate__c,Opportunity__r.Data_Monthly_Revenue__c, 
            Opportunity__r.Data_Estimated_Revenue_Share__c,Opportunity__r.Voice_Subs__c,Opportunity__r.Voice_Penetration__c,Opportunity__r.Voice_Retail_Rate__c, 
            Opportunity__r.Voice_Monthly_Revenue__c,Opportunity__r.Voice_Estimated_Revenue_Share__c,Opportunity__r.Per_Unit_Door_Fee__c,Opportunity__r.IRR__c, 
            Opportunity__r.NPV__c,Opportunity__r.Total_Equipment_Cost__c,Opportunity__r.Payback_Period_Months__c,Opportunity__r.Construction_Capex_Cost__c, 
            Opportunity__r.Gross_Contract_Value__c,Property__r.Owner_Account__c,Property__r.County__c,Property__r.Franchise_New__c,Property__r.PostalCode__c, 
            Opportunity__r.Contact_Email__c,Opportunity__r.Contact_First_Name__c,Opportunity__r.Contact_Last_Name__c,Opportunity__r.ContractTermUnit__c, 
            Opportunity__r.Contract_Type__c,Opportunity__r.Number_of_Units__c, Opportunity__r.Type, Opportunity__r.Fiber_To_The_Unit__c , 
            Opportunity__r.ContractTerm__c,Opportunity__r.Total_Properties__c, Opportunity__r.Sales_Portfolio_Name__c,Property__r.Property_Rating__c ,
            Property__r.Address__c, Property__r.Address_2__c, Property__r.City__c, Property__r.MDU_State__c, Property__r.State_Name__c, Property__r.Number_of_Units__c , 
            Property__r.Industry_Type__c, Property__r.Property_Type__c , Property__r.Name , Property__r.Risk_Status__c, Property__r.Developer__r.Name ,
            Property__r.Developer__r.City__c ,Property__r.Developer__r.Street__c,Property__r.Developer__r.Zip_Code__c, Property__r.Owner_Account__r.Name,
            Property__r.Owner_Account__r.City__c,Property__r.Owner_Account__r.Street__c,Property__r.Owner_Account__r.Zip_Code__c,Opportunity__r.ECM_Interview_Instance_Name__c,
            Opportunity__r.Interview_Created_Date__c, Property__r.Contracting_Org_Type__c, Property__r.Ownership_Type__c, Property__r.Distribution_wiring__c
            from Opportunity_Property__c where Opportunity__c =: opptyId AND Opportunity__c != null AND Primary_Property__c = true];
        }
        return !objOpportunityProperty.isEmpty()?objOpportunityProperty[0]: null;
    }  
    
    
    /**
    * Name: getPropertyData
    * Description: This method is used to fetch the data of Property object. 
    * @parameters: opptyId
    * @return: MDU_Property__c
    **/
    public static List<MDU_Property__c> getPropertyData(String propertyId){
        
        String query = generateSelectAllQuery('MDU_Property__c', 'Id', propertyId);//Generate query
        List<MDU_Property__c> propList = Database.query(query);//Query  records on sObject
        return propList;
    }
    
    
    /**
    * Name: getOpportunityData
    * Description: This method is used to fetch the data of Opportunity object. 
    * @parameters: opptyId
    * @return: Opportunity
    **/
    public static List<Opportunity> getOpportunityData(String opptyId){
            
        String query = generateSelectAllQuery('Opportunity', 'Id', opptyId);//Generate query
        List<Opportunity> oppList = Database.query(query);//Query  records on sObject
        return oppList;
    }
    
    
    /**
    * generateSelectAllQuery Static Method
    * @params - String, String, String 
    * Generate query for sObject via the source Id. 
    */  
    public static String generateSelectAllQuery(String objectName, String fieldName, String sourceId) {
        String query = 'select Id';
        for(Schema.SObjectField field : schemaMap.get(objectName).getDescribe().fields.getMap().values()) {
                if(!field.getDescribe().getName().equalsIgnoreCase('id')){
                    query += ',' + field.getDescribe().getName();//Add field names to query
                }
        }
        query += ' from ' + objectName + ' where ' + fieldName + '= \'' + sourceId + '\'';       
        return query;
    }
    
    
    /**
    * Name: fetchOpportunityContactRoleData
    * Description: This method is used to fetch the data of OpportunityContactRole. 
    * @parameters: opptyId
    * @return: OpportunityContactRole
    **/
    public static OpportunityContactRole fetchOpportunityContactRoleData(String opptyId){
        List<OpportunityContactRole> objOpportunityContactRole1 = new List<OpportunityContactRole>();
        for(OpportunityContactRole opptyConRole :[Select Id,ContactId,Contact.FirstName , Contact.LastName , Contact.Email  from OpportunityContactRole where OpportunityId =:opptyId AND isPrimary = true limit 1]){
            objOpportunityContactRole1.add(opptyConRole);
        }
        return !objOpportunityContactRole1.isEmpty()?objOpportunityContactRole1[0]:null;
    } 
    
    
    /**
    * Name: parseResponse
    * Description: This method is used to Parse the XML response. 
    * @parameters: DOM.XMLNode, valueToGet
    * @return: Parsed Value
    **/
    public static String parseResponse(DOM.XMLNode node, String valueToGet) {
        String result = MDU_Constants.NEXT_LINE_OPERATOR;
        if (node.getNodeType() == DOM.XMLNodeType.COMMENT) {
            return MDU_Constants.COMMENT +  node.getText() + MDU_Constants.RIGHT_PARENTHISYS;
        }
        if (node.getNodeType() == DOM.XMLNodeType.TEXT) {
            return MDU_Constants.TEXT + node.getText() + MDU_Constants.RIGHT_PARENTHISYS;
        }
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            result += 'Element: ' + node.getName();            
            if (node.getText().trim() != '') {
                if(node.getName().equalsIgnoreCase(valueToGet)){
                    
                    parsedValue = node.getText();
                }
                result += ', text=' + node.getText().trim();
            }
            if (node.getAttributeCount() > 0) { 
                for (Integer i = 0; i< node.getAttributeCount(); i++ ) {
                    result += ', attribute #' + i + ':' + node.getAttributeKeyAt(i) + '=' + node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
                }  
            }
            if(parsedValue != ''){
                return parsedValue;
            }
            for (Dom.XMLNode child: node.getChildElements()) {
                if(parsedValue == ''){
                    result += parseResponse(child,valueToGet);
                }else{                    
                    return parsedValue;
                }
            }          
        }        
        return parsedValue;  
    }
    
    
    /**
    * Name: generateInterviewInstanceName
    * Description: This method is used to Generate the Interview Instance Name. 
    * @parameters: opptyId
    * @return: String
    **/
    public static String generateInterviewInstanceName(String opptyId){
        
        Datetime dt = System.now();       
        String day = dt.day()< 10 ? '0'+ String.Valueof(dt.day()):String.Valueof(dt.day());
        String hour = dt.hour()< 10 ? '0'+ String.Valueof(dt.hour()):String.Valueof(dt.hour());   
        String month = dt.month() < 10 ? '0'+ String.Valueof(dt.month()):String.Valueof(dt.month());   
        String minute = dt.minute()< 10 ? '0'+ String.Valueof(dt.minute()):String.Valueof(dt.minute());  
        Integer year = dt.year();
        
        opptyId = opptyId.subString(0, 15);
        String interviewInstanceName = MDU_Constants.MDU +opptyId + month +day + year + hour+ minute;
        return interviewInstanceName;
    }
    
    
    /**
    * Name: updateOpportunity
    * Description: This method is used to Update the Opportunity with Latest Interview Instance Name. 
    * @parameters: opptyId , interviewInstanceName , dtTimeStr1
    * @return: None
    **/
    public static void updateOpportunity(String opptyId, String interviewInstanceName , String dtTimeStr1){
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Id = opptyId;
        objOpportunity.ECM_Interview_Instance_Name__c = interviewInstanceName;
        objOpportunity.Interview_Created_Date__c = dtTimeStr1;
        try{
            update objOpportunity;
        }catch(Exception ex){
        }
    }
    
    
    /**
    * Name: responseErrorLog
    * Description: This method is used to capture the error while requesting Emptoris services. 
    * @parameters: 
    * @return: None
    **/
    public static String responseErrorLog(DOM.XMLNode node){
        
        MDU_EmptorisUtility.parsedValue = '';
        String finalResult ='';
        MDU_EmptorisUtility.parsedValue = '';
        String faultString = MDU_EmptorisUtility.parseResponse(node, MDU_Constants.FAULTSTRING);
        finalResult = '' + MDU_Constants.ERROR+ MDU_Constants.SEMICOLON + System.Label.Launch_Interview_HTTP_ERROR + MDU_Constants.SEMICOLON + MDU_Constants.ERROR_MESSAGE_STRING + faultString;
        return finalResult;
        
    }
    
    /**
    * Name: getUserName
    * Description: This method is used to get the user NT Login. 
    * @parameters: 
    * @return: None
    **/
    public static String getUserName(){     
        String userName=null;       
        
        List<User> uList = [Select Id, FederationIdentifier from User where Id=: UserInfo.getUserId()];        
        if(!uList.isEmpty() && uList[0].FederationIdentifier!=null){
            userName= uList[0].FederationIdentifier.toLowerCase();
        }
  
        return userName;      
    }
    
    /**
    * Name: SetNow
    * Description: This method is used to Set the Current Date. 
    * @parameters: None
    * @return: String
    **/
    public static String SetNow() {
        Datetime dt = System.now();       
        String dtTimeStr = dt.format(MDU_Constants.DATEFORMAT);
        return dtTimeStr;
    }
     
     
    /**
    * Name: SetGMT
    * Description: This method is used to Set the user's locale datetime to GMT Timezone. 
    * @parameters: None
    * @return: String
    **/
    public static String SetGMT() {
       
        DateTime nowGmt = system.now();
        TimeZone dt = UserInfo.getTimeZone();
        DateTime dt1 = DateTime.newInstanceGMT(nowGmt.dateGMT(), nowGmt.timeGMT());
        Integer Offsetvalue = ((dt.getOffset(dt1))/3600000);
        String dtTimeStrGMT = nowGmt.addHours(-(Offsetvalue)).format(MDU_Constants.DATEFORMAT_SSM);
        return dtTimeStrGMT;   
    }
    
    /**
    * Name: GenerateToken
    * Description: This method is used to Generate Token. 
    * @parameters: UserName
    * @return: String
    **/
    public static string GenerateToken(string user , String date1)  {
        
        Map<String, String> mapOfParamNameAndValue = new Map<String , String>();
        // Declarations //      
        String clearText='';
        for(MDU_EmptorisIntegrationCS__c objectCS : MDU_EmptorisIntegrationCS__c.getall().values()){
            if(objectCS.Param_Name__c != null){
                if(objectCS.Param_Value__c != null){
                    mapOfParamNameAndValue.put(objectCS.Param_Name__c,objectCS.Param_Value__c);
                }else{
                    mapOfParamNameAndValue.put(objectCS.Param_Name__c,'');
                }
            }
        }
        
        string host = mapOfParamNameAndValue.get(MDU_Constants.HOSTSTR);
        string source = mapOfParamNameAndValue.get(MDU_Constants.SOURCESTR);
        string algorithm = mapOfParamNameAndValue.get(MDU_Constants.ALGOSTR);
        string secret = mapOfParamNameAndValue.get(MDU_Constants.SHARED_SECRET);
        
        
        if (user != null){
            clearText+= user + MDU_Constants.COLON;
        }
        if (host != null){
            clearText+= host + MDU_Constants.COLON;
        }
        if (source != null){
            clearText+= source + MDU_Constants.COLON;
        }
        if (date1 != null){
            clearText+= date1 + MDU_Constants.COLON;
        }
        if (algorithm != null){
            clearText+= algorithm + MDU_Constants.COLON;
        }
        if (secret != null){
            clearText+= secret;
        }
                      
        blob md5Coded = Crypto.generateDigest(MDU_Constants.MD5, Blob.valueOf(String.ValueOf(clearText)));

        return EncodingUtil.base64Encode(md5Coded);
    }
    
    /**
    * Name: requestMethod
    * Description: This method is used to call the request. 
    * @parameters: None
    * @return: String
    **/
    public static HTTPResponse requestMethod(String soapMsg, String endPoint ) {
        //Send the SOAP Request:
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod(MDU_Constants.POST);
        req.setHeader(MDU_Constants.CONTENT_TYPE,MDU_Constants.TEXT_XML_CHARSET_UTF_8);
        req.setHeader(MDU_Constants.ACCEPT,MDU_Constants.TEXT_XML);
        req.setHeader(MDU_Constants.SOAPACTION,MDU_Constants.BLANKHEADER);

        req.setBody(soapMsg);  
        system.debug('Request EndPoint:' + endPoint);    
    system.debug('Request String:' + soapMsg);

        Http http = new Http();
        HTTPResponse res = http.send(req);    
        system.debug('response:' + res);   
        return res;
    }
    
    /**
    * Name: validateLaunchInterview
    * Description: This method is used to Validate the Data before Launch Interview Process. 
    * @parameters: objOpportunityProperty
    * @return: String
    **/
    public static String validateLaunchInterview(Opportunity_Property__c objOpportunityProperty){
        String errorMessage='';
        Integer i =1;
        if(objOpportunityProperty != null){
                
            if(objOpportunityProperty.Property__c != null && objOpportunityProperty.Opportunity__c != null){
                
                if(objOpportunityProperty.Property__r.Industry_Type__c!=null && objOpportunityProperty.Property__r.Industry_Type__c.Trim().equalsIgnoreCase(MDU_Constants.MDU_INDUSTRY_GOVERNMENT)){
                    errorMessage += ''+ System.Label.PropertyIndustryGovtErr;
                    return errorMessage;
                }
                
                if(objOpportunityProperty.Opportunity__r.Contract_Type__c!=null && objOpportunityProperty.Opportunity__r.Contract_Type__c.equalsIgnoreCase(MDU_Constants.RETAIL_TYPE)
                && objOpportunityProperty.Property__r.Industry_Type__c!=null && (objOpportunityProperty.Property__r.Industry_Type__c.Trim().equalsIgnoreCase(MDU_Constants.HOSPITALITY)
                || objOpportunityProperty.Property__r.Industry_Type__c.Trim().equalsIgnoreCase(MDU_Constants.EDUCATION)
                || objOpportunityProperty.Property__r.Industry_Type__c.Trim().equalsIgnoreCase(MDU_Constants.HEALTHCARE))){
                    errorMessage+='' + system.Label.ContractType_IndustryTypeCheck;
                    return errorMessage;
                }
            }

            //Property Field Validation
            if(objOpportunityProperty.Property__c != null){
                if(objOpportunityProperty.Property__r.Owner_Account__c == null){                   
                    errorMessage += ' '+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Property_Page_Owner_Account_Err;
                }
                if(objOpportunityProperty.Property__r.County__c == '' || objOpportunityProperty.Property__r.County__c == null){
                    
                    errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Property_Page_County_Err;
                }
                if(objOpportunityProperty.Property__r.Franchise_New__c == '' || objOpportunityProperty.Property__r.Franchise_New__c == null){
                    
                    errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Property_Page_Franchise_New_Err;
                }
                if(objOpportunityProperty.Property__r.PostalCode__c == '' || objOpportunityProperty.Property__r.PostalCode__c == null){
                    
                    errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Property_Page_PostalCode_Err;
                }
            }

            //Opportunity Field Validation
            if(objOpportunityProperty.Opportunity__c != null){
                if(objOpportunityProperty.Opportunity__r.Contact_Email__c == '' || objOpportunityProperty.Opportunity__r.Contact_Email__c == null){
                    
                    errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Property_Page_Contact_Email_Err;
                }
                if(objOpportunityProperty.Opportunity__r.Contact_First_Name__c == '' || objOpportunityProperty.Opportunity__r.Contact_First_Name__c == null){
                    
                    errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Property_Page_Contact_First_Name_Err;
                }
                if(objOpportunityProperty.Opportunity__r.Contact_Last_Name__c == '' || objOpportunityProperty.Opportunity__r.Contact_Last_Name__c == null){
                    
                    errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Property_Page_Contact_Last_Name_Err;
                }
                if(objOpportunityProperty.Opportunity__r.ContractTermUnit__c == '' || objOpportunityProperty.Opportunity__r.ContractTermUnit__c == null){
                    
                    errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Property_Page_ContractTermUnit_Err;
                }
                if(objOpportunityProperty.Opportunity__r.ContractTerm__c == null){
                    
                    errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Property_Page_ContractTerm_Err;
                }

                if(objOpportunityProperty.Opportunity__r.Contract_Type__c == '' || objOpportunityProperty.Opportunity__r.Contract_Type__c == null){
                    
                    errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Property_Page_Contract_Type_Err;
                    
                }else if(objOpportunityProperty.Opportunity__r.Contract_Type__c.equalsIgnoreCase(MDU_Constants.BULK_TYPE)){
                    if(objOpportunityProperty.Opportunity__r.Video_Subs__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Subs_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Video_Penetration__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Penetration_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Video_Bulk_Current_Rate__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Bulk_Current_Rate_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Video_Bulk_Proposed_Rate__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Bulk_Proposed_Rate_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Video_Bulk_Discount__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Bulk_Discount_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Video_Monthly_Revenue__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Monthly_Revenue_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Video_Estimated_Revenue_Share_Rate__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Estimated_Revenue_Share_Rate_Err;
                    }
                
                    if(objOpportunityProperty.Opportunity__r.Data_Subs__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Subs_Err;
                    }
                
                    if(objOpportunityProperty.Opportunity__r.Data_Penetration__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Penetration_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Data_Bulk_Current_Rate__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Bulk_Current_Rate_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Data_Bulk_Proposed_Rate__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Bulk_Proposed_Rate_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Data_Bulk_Discount__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Bulk_Discount_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Data_Monthly_Revenue__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Monthly_Revenue_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Data_Estimated_Revenue_Share__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Estimated_Revenue_Share_Err;
                    }
                    
                    if(objOpportunityProperty.Opportunity__r.Voice_Subs__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Subs_Err ;
                    }
                    
                    if(objOpportunityProperty.Opportunity__r.Voice_Penetration__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Penetration_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Voice_Bulk_Current_Rate__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Bulk_Current_Rate_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Voice_Bulk_Proposed_Rate__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Bulk_Proposed_Rate_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Voice_Bulk_Discount__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Bulk_Discount_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Voice_Monthly_Revenue__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Monthly_Revenue_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Voice_Estimated_Revenue_Share__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Estimated_Revenue_Share_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Per_Unit_Door_Fee__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Per_Unit_Door_Fee_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.IRR__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_IRR_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.NPV__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_NPV_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Total_Equipment_Cost__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Total_Equipment_Cost_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Payback_Period_Months__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Payback_Period_Months_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Construction_Capex_Cost__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Construction_Capex_Cost_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Gross_Contract_Value__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Gross_Contract_Value_Err ;
                    }
                }else if(objOpportunityProperty.Opportunity__r.Contract_Type__c.equalsIgnoreCase(MDU_Constants.RETAIL_TYPE)){
                    if(objOpportunityProperty.Opportunity__r.Video_Subs__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Subs_Err;
                    }                    
                    if(objOpportunityProperty.Opportunity__r.Video_Penetration__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Penetration_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Video_Retail_Rate__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Retail_Rate_Err;
                    }
                    
                    if(objOpportunityProperty.Opportunity__r.Video_Monthly_Revenue__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Monthly_Revenue_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Video_Estimated_Revenue_Share_Rate__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Video_Estimated_Revenue_Share_Rate_Err ;
                    }
                
                    if(objOpportunityProperty.Opportunity__r.Data_Subs__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Subs_Err ;
                    }
                    
                    if(objOpportunityProperty.Opportunity__r.Data_Penetration__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Penetration_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Data_Retail_Rate__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Retail_Rate_Err;
                    }
                
                    if(objOpportunityProperty.Opportunity__r.Data_Monthly_Revenue__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Monthly_Revenue_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Data_Estimated_Revenue_Share__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Data_Estimated_Revenue_Share_Err ;
                    }
                    
                    if(objOpportunityProperty.Opportunity__r.Voice_Subs__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Subs_Err ;
                    }
                    
                    if(objOpportunityProperty.Opportunity__r.Voice_Penetration__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Penetration_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Voice_Retail_Rate__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Retail_Rate_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Voice_Monthly_Revenue__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Monthly_Revenue_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Voice_Estimated_Revenue_Share__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Voice_Estimated_Revenue_Share_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Per_Unit_Door_Fee__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Per_Unit_Door_Fee_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.IRR__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_IRR_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.NPV__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_NPV_Err;
                    }
                    if(objOpportunityProperty.Opportunity__r.Total_Equipment_Cost__c == null){
                        
                    errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +System.Label.Opportunity_Page_Total_Equipment_Cost_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Payback_Period_Months__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS +MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Payback_Period_Months_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Construction_Capex_Cost__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR + i++ + MDU_Constants.LEFT_PARENTHISYS + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Construction_Capex_Cost_Err ;
                    }
                    if(objOpportunityProperty.Opportunity__r.Gross_Contract_Value__c == null){
                        
                        errorMessage += MDU_Constants.NEXT_LINE_OPERATOR+ i++ + MDU_Constants.LEFT_PARENTHISYS + MDU_Constants.LEFT_PARENTHISYS + System.Label.Opportunity_Page_Gross_Contract_Value_Err ;
                    }
                }
            }
        }
        return errorMessage;
    }
    
    /**
    * Name: searchExecutedRequest
    * Description: This method is used to create session at Emptoris .    
    * @return: HTTPResponse
    **/
    public static HTTPResponse searchExecutedRequest(){    
        initialiseConstantVariable();
        String dtTimeStr = MDU_EmptorisUtility.SetNow();          
        String soapEnvTemplate = BLANK_VALUE+ MDU_EmptorisEnvelopeTemplate.SEARCH_CONTRACT_REQUEST_ENV;
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        soapEnvTemplate+= '<request-data><contract-status>{5}</contract-status><terms><term><name>{6}</name><string-criteria>';
        soapEnvTemplate+= '<operation xmlns="http://www.dicarta.com/contracts/types/search">{7}</operation>';
        soapEnvTemplate+= '<value xmlns="http://www.dicarta.com/contracts/types/search">{8}</value></string-criteria></term></terms></request-data></search-request></s:Body></s:Envelope>';
        
        
        
        List<String> params = new List<String>();
        //String userName = System.Label.SearchRequestUser;
        String theToken = MDU_EmptorisUtility.GenerateToken(writeBackUser,dtTimeStr);
              
        params.add(writeBackUser);        
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(MDU_Constants.EXECUTED_STATUS_STRING);
        params.add(MDU_Constants.NAME_STRING);
        params.add(MDU_Constants.OPERATION);
        params.add(MDU_Constants.VALUE_STRING);
        
        String soapMsg = String.format(soapEnvTemplate,params); 
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,GET_CONTRACT_ENDPOINT);           
        return res;
    }

    /**
    * Name: searchActiveRequest
    * Description: This method is used to return contract id's from response after sending HttpRequest .    
    * @return: HTTPResponse
    **/
    public static HTTPResponse searchActiveRequest(){
        initialiseConstantVariable();
        String dtTimeStr = MDU_EmptorisUtility.SetNow();     
           
        String soapEnvTemplate = BLANK_VALUE+ MDU_EmptorisEnvelopeTemplate.SEARCH_CONTRACT_REQUEST_ENV;
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        soapEnvTemplate+= '<request-data><contract-status>{5}</contract-status><terms><term><name>{6}</name><string-criteria>';
        soapEnvTemplate+= '<operation xmlns="http://www.dicarta.com/contracts/types/search">{7}</operation>';
        soapEnvTemplate+= '<value xmlns="http://www.dicarta.com/contracts/types/search">{8}</value></string-criteria></term></terms></request-data></search-request></s:Body></s:Envelope>';
        
        List<String> params = new List<String>();             
        String theToken = MDU_EmptorisUtility.GenerateToken(writeBackUser,dtTimeStr);
        
        params.add(writeBackUser);
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(MDU_Constants.ACTIVE_STATUS_STRING);
        params.add(MDU_Constants.NAME_STRING);
        params.add(MDU_Constants.OPERATION);
        params.add(MDU_Constants.VALUE_STRING);
        
        String soapMsg = String.format(soapEnvTemplate, params);        
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,GET_CONTRACT_ENDPOINT);                  
        return res;
    }  
    
    /**
    * Name: GetContractRequest
    * Description: This method is used to return contract record created at emptoris site  from response after sending HttpRequest . 
    * Parameter : contractIdTemp(string)    
    * @return: HTTPResponse
    **/
    public static HTTPResponse GetContractRequest(string contractIdTemp){
        initialiseConstantVariable();
        String dtTimeStr = MDU_EmptorisUtility.SetNow();          
        String soapEnvTemplate = BLANK_VALUE+ MDU_EmptorisEnvelopeTemplate.GET_CONTRACT_REQUEST_ENV;
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        soapEnvTemplate+= '<request-data><id xmlns="http://www.dicarta.com/contracts/types/domain/contract">{5}</id><revision xmlns="http://www.dicarta.com/contracts/types/domain/contract">{6}</revision></request-data></get-request></s:Body></s:Envelope>';
        
        List<String> params = new List<String>();               
        String theToken = MDU_EmptorisUtility.GenerateToken(writeBackUser, dtTimeStr);
        
        params.add(writeBackUser);
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(contractIdTemp);
        params.add(revisionId);
        
        String soapMsg = String.format(soapEnvTemplate, params);        
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,GET_CONTRACT_ENDPOINT);        
        return res;
    }
    
    /**
    * Name: GetContractLanguageRequest
    * Description: This method is used to return attachment details of contract id passed to method.
    * Parameter : contractIdTemp        
    * @return: HTTPResponse
    **/
    public static HTTPResponse  GetContractLanguageRequest(string contractIdTemp){
        initialiseConstantVariable();
        String dtTimeStr = MDU_EmptorisUtility.SetNow();          
        String soapEnvTemplate = BLANK_VALUE+ MDU_EmptorisEnvelopeTemplate.GET_CONTRACT_LANGUAGE_REQUEST_ENV;
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        soapEnvTemplate+= '<request-data><contract-reference xmlns="http://www.dicarta.com/contracts/types/domain/contract"><id>{5}</id></contract-reference></request-data></get-language-request></s:Body></s:Envelope>';
        
        List<String> params = new List<String>();                       
        String theToken = MDU_EmptorisUtility.GenerateToken(writeBackUser, dtTimeStr);
        
        params.add(writeBackUser);
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(contractIdTemp);
        
        String soapMsg = String.format(soapEnvTemplate, params);      
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,GET_CONTRACT_ENDPOINT);         
        return res;        
    }
         
    /**
    * Name: UpdateContractSubstatusRequest
    * Description: This method send HttpRequest at Emptoris site and update contract sub status As Processed 
    * Parameter : contactIdForStatus        
    * @return: HTTPResponse
    **/
    public static HTTPResponse UpdateContractSubstatusRequest(string contactIdForStatus){
        initialiseConstantVariable();
        String dtTimeStr = MDU_EmptorisUtility.SetNow();          
        String soapEnvTemplate = BLANK_VALUE+ MDU_EmptorisEnvelopeTemplate.UPDATE_CONTRACT_SUBSTATUS_REQUEST_ENV;
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        soapEnvTemplate+= '<request-data><contract-id>{5}</contract-id><substatus>{6}</substatus></request-data></update-substatus-request></s:Body></s:Envelope>';
        
        List<String> params = new List<String>();              
        String theToken = MDU_EmptorisUtility.GenerateToken(writeBackUser, dtTimeStr);

        params.add(writeBackUser);        
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(contactIdForStatus); 
        params.add(MDU_Constants.SUBSTATUS_STRING);
        
        String soapMsg = String.format(soapEnvTemplate, params);        
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,GET_CONTRACT_ENDPOINT);    
        return res;
    }
    
    /**
    * Name: UpdateContractTermRequest
    * Description: This method send HttpRequest at Emptoris site and update contract_save_in_direct field as 'Yes' at  Emptoris end
    * Parameter : contractIdForTerm     
    * @return: HTTPResponse
    **/
    public static HTTPResponse UpdateContractTermRequest(string contractIdForTerm){
        initialiseConstantVariable();
        String dtTimeStr = MDU_EmptorisUtility.SetNow();          
        String soapEnvTemplate = BLANK_VALUE+ MDU_EmptorisEnvelopeTemplate.UPDATE_CONTRACT_TERM_REQUEST_ENV;
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        soapEnvTemplate+= '<request-data><contract-id>{5}</contract-id><term-name>{6}</term-name><value><string-value xmlns="http://www.dicarta.com/contracts/types/domain/common">{7}</string-value></value></request-data></update-term-request></s:Body></s:Envelope>';
        
        List<String> params = new List<String>();       
        String theToken = MDU_EmptorisUtility.GenerateToken(writeBackUser, dtTimeStr);
       
        params.add(writeBackUser);
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(contractIdForTerm); 
        params.add(MDU_Constants.NAME_STRING);
        params.add(MDU_Constants.YES_STRING);
        
        String soapMsg = String.format(soapEnvTemplate, params);        
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,GET_CONTRACT_ENDPOINT);        
        return  res;
    }   
    
    /**
    * Name: UpdateContractCustomPropertyRequest
    * Description: This method send HttpRequest at Emptoris site and update contract_save_in_direct for custom property field as 'Yes' at  Emptoris end
    * Parameter : contractIdForCustProperty     
    * @return: HTTPResponse
    **/
    public static HTTPResponse UpdateContractCustomPropertyRequest(string contractIdForCustProperty){
        initialiseConstantVariable();
        String dtTimeStr = MDU_EmptorisUtility.SetNow();          
        String soapEnvTemplate = BLANK_VALUE+ MDU_EmptorisEnvelopeTemplate.UPDATE_CONTRACT_CUSTOM_PROPERTY_REQUEST_ENV;
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        soapEnvTemplate+= '<request-data><contract-id>{5}</contract-id><name>{6}</name><value><string-value xmlns="http://www.dicarta.com/contracts/types/domain/cp">{7}</string-value></value></request-data></update-custom-property-request></s:Body></s:Envelope>';        
        List<String> params = new List<String>();               
        String theToken = MDU_EmptorisUtility.GenerateToken(writeBackUser, dtTimeStr);       
        params.add(writeBackUser);                 
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);
        params.add(contractIdForCustProperty); 
        params.add(MDU_Constants.NAME_STRING);
        params.add(MDU_Constants.YES_STRING);        
        String soapMsg = String.format(soapEnvTemplate, params);        
        HTTPResponse res = MDU_EmptorisUtility.requestMethod(soapMsg,GET_CONTRACT_ENDPOINT);           
        return res;
    }  

    /* Method Name : setEligibilityForApplicationLogging()
    *  Description : Set Eligible Flag To 'True' to create execution log 
    *  Parameter   : None
    *  Return Type : void
    */
    public static boolean setEligibilityForApplicationLogging(){
        boolean isEligibleForAppLogging = false;
        if(MDU_UserAppLoggingCS__c.getValues(UserInfo.getProfileId()) != null || MDU_UserAppLoggingCS__c.getValues(UserInfo.getUserId()) != null){
            isEligibleForAppLogging = true;
        }  
        return   isEligibleForAppLogging;      
    }
    
}