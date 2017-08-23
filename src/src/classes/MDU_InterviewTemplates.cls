/************************************************************************************************************************************************************
Name: MDU_InterviewTemplates 
Description: This class is used to Create the Interview Templates.
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
16 Feb 2015 Comcast  
* @Last modified By: Sagarika
* @Last modified Date: 26-July-2017 
* @Description : Modifications to send values to Interview Page
* @User Story : US1132369 : XC LI - Distribution Wiring Send to LI, US1132449 : XC - LI - Contracting Org Type LI, US1132350 : XC - LI - Education Ownership Type send to LI
* @Last modified By: Sagarika
* @Last modified Date: 07-Aug-2017 
* @Description : Adding code for sending Premium Channels to launch interview
* @User Story : US1132755: XC LI - Premium Channels Launch Interview
*************************************************************************************************************************************************************/
public class MDU_InterviewTemplates{
    
   
    //Variable Declarations   
    public static String primary_contact=null;    //Format= 'Contact First Name: sadvadv Contact Last Name:vdsadsv Contact Email: vsadvdsv@dfhds.fdhdsf';    
    public static string contactFirstName=null;
    public static string contactLastName=null;
    public static string contactEmail=null;
    public static string franchiseName = null;
    public static string legalEntityName = null;
    public static String algoStr = '';
    public static String sourceStr = '';
    
    private static final String OPPORTUNITY = 'Opportunity';
    private static final String OPPORTUNITYPROPERTY = 'OpportunityProperty';
    private static final String MDU_PROPERTY = 'MDU_Property__c';
    private static final String INTEGER_VAL = 'Integer';
    private static final String DECIMAL_VAL = 'Decimal';
    private static final String STRING_VAL = 'String';
    private static final String BLANK_VAL_PROP = 'BLANK_PROP';
    private static final String BLANK_VAL_OPP = 'BLANK_OPP';
    private static final String PROPERTY_INFO = 'Property_Info__c';
    private static final String PRIMARY_CONTACT_VAL = 'primary_contact';
    private static final String FIXED_PROP_VAL = 'FIXED_PROP';
    private static final String FIXED_OPP_VAL = 'FIXED_OPP';
    private static final String AMP_VAL = '&';
    private static final String GREATER_THAN_VAL = '>';
    private static final String LESS_THAN_VAL = '<';
    private static final String AMP_REPLACE = '&amp;';
    private static final String GREATER_THAN_REPLACE = '&gt;';
    private static final String LESS_THAN_REPLACE = '&lt;';
    
    //Start : Sagarika - Changes for US1132369, US1132449, US1132350 
    private static final String LINE_BREAK = '<br>';
    private static final String NEW_LINE = '\n';
    private static final String NONE  = 'None';
    private static final String stepTag = '<steps><name xmlns="http://www.dicarta.com/contracts/types/domain/step">STEP_NAME</name>INPUT_CONTROLS</steps>';
    private static final String STEP_NAME = 'STEP_NAME';
    private static final String INPUT_CONTROLS = 'INPUT_CONTROLS';
    private static final String ZERO = '0';
    private static final String COMMA = ',';
    private static final String FRANCISE_NAME_HIDDEN = MDU_Property__c.Franchise_Name_Hidden__c.getDescribe().getName();
    private static final String LEGAL_NAME_HIDDEN = MDU_Property__c.Comcast_legal_name_hidden__c.getDescribe().getName();
    private static final String CONTRACTING_ORG_TYPE = MDU_Property__c.Contracting_Org_Type__c.getDescribe().getName();
    //End : Sagarika - Changes for US1132369, US1132449, US1132350 
    //Start : Sagarika - Changes for US1132755
    private static final String PREMIUM_CHANNELS = 'Premium_Channels__c';
    //End : Sagarika - Changes for  US1132755								  

    /**
    * Name: setConstantVariable
    * Description: This method is used to Set The constant Variables values come from MDU_EmptorisIntegrationCS__c custom setting. 
    * @parameters: None
    * @return: None
    **/
    public static void initialiseConstantVariable(){
        Map<String, String> mapOfParamNameAndValue = new Map<String , String>();
        for(MDU_EmptorisIntegrationCS__c objectCS : MDU_EmptorisIntegrationCS__c.getall().values()){
			if(!String.isBlank(objectCS.Param_Name__c))
			{
	            if(!String.isBlank(objectCS.Param_Value__c)){
	                mapOfParamNameAndValue.put(objectCS.Param_Name__c,objectCS.Param_Value__c);
	            }else{
	                mapOfParamNameAndValue.put(objectCS.Param_Name__c, MDU_Constants.BLANK_VALUE);
	            }
			}
        }
        sourceStr = mapOfParamNameAndValue.get(MDU_Constants.SOURCESTR);
        algoStr = mapOfParamNameAndValue.get(MDU_Constants.ALGOSTR);       
    }
        
    /**
    * Name: mdu_template
    * Description: This method is used to build all templates. 
    * @parameters: objOpportunityPropertyData , objOpportunityContactRole, propertyData, opportunityData , UUID , user , theToken , interviewInstanceName ,dtTimeStr  
    * @return: Template
    **/
    public static String mdu_template(Opportunity_Property__c objOpportunityPropertyData ,OpportunityContactRole objOpportunityContactRole, MDU_Property__c propertyData, Opportunity opportunityData, String UUID , String user ,String theToken , String interviewInstanceName , String dtTimeStr, String templateNm){
        initialiseConstantVariable();
        List<String> params = new List<String>();
        String description = MDU_Constants.TEMPLATE_DESCRIPTION +templateNm+ MDU_Constants.TEMPLATE ;
           
        // Envelop string mapping parameters
        params.add(user);
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);       
        params.add(interviewInstanceName);       
        params.add(description);
        params.add(templateNm);
    
        MDU_InterviewTemplates.franchiseLegalData(propertyData.Franchise_New__c);
        MDU_InterviewTemplates.populateContactData(objOpportunityPropertyData, objOpportunityContactRole);
              
        String soapEnvTemplate = MDU_EmptorisEnvelopeTemplate.CREATE_INTERVIEW_BASE_ENV;    
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        soapEnvTemplate+= '<request-data><name>{5}</name><label>{5}</label><description>{6}</description><template-name>{7}</template-name>';
        
        //Start : Sagarika - Changes for US1132369, US1132449, US1132350 
        soapEnvTemplate+= populateStepData(objOpportunityPropertyData, propertyData, opportunityData, templateNm, UUID);
        //End : Sagarika - Changes for US1132369, US1132449, US1132350 
        
        soapEnvTemplate +=  '</request-data></create-interview-instance-request></s:Body></s:Envelope>';       
         
        String soapMsg = String.format(soapEnvTemplate, params);                  
        return soapMsg;
    }
    
    /**
    * Name: populateContactData
    * Description: This method is used to Populate the Contact Related Fields. 
    * @parameters: objOpportunityPropertyData, objOpportunityContactRole
    * @return: None
    **/
    public static void populateContactData(Opportunity_Property__c objOpportunityPropertyData , OpportunityContactRole objOpportunityContactRole ){
                
        if(objOpportunityPropertyData.Opportunity__r.Contact_Email__c != null &&  objOpportunityPropertyData.Opportunity__r.Contact_First_Name__c != null && objOpportunityPropertyData.Opportunity__r.Contact_Last_Name__c != null){
            contactFirstName = objOpportunityPropertyData.Opportunity__r.Contact_First_Name__c;
            contactLastName = objOpportunityPropertyData.Opportunity__r.Contact_Last_Name__c;
            contactEmail = objOpportunityPropertyData.Opportunity__r.Contact_Email__c;
        }else{
            contactFirstName = objOpportunityContactRole.Contact.FirstName;
            contactLastName = objOpportunityContactRole.Contact.LastName;
            contactEmail = objOpportunityContactRole.Contact.Email;
        }
            contactFirstName = contactFirstName!=null?(contactFirstName.replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE)):null;
            contactLastName = contactLastName!=null?(contactLastName.replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE)):null;
            contactEmail = contactEmail!=null?(contactEmail.replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE)):null;   
    }
    
    /**
    * Name: franchiseLegalData
    * Description: This method is used to Populate the Franchise Name and Legal Name. 
    * @parameters: String (Franchise_New__c)
    * @return: None
    **/
    public static void franchiseLegalData(String franchName){
                
        List<Franchise__c> fran =[SELECT Franchise_Name__c,Franchise_Title__c, id, Legal_Entity__c, Legal_Entity__r.Legal_Entity_Name__c from Franchise__c WHERE Franchise_Title__c=: franchName limit 1];
        if(fran!=null & !fran.isEmpty()){
            franchiseName = fran[0].Franchise_Name__c;
            legalEntityName = fran[0].Legal_Entity__r.Legal_Entity_Name__c;
            franchiseName = franchiseName!=null?(franchiseName.replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE)):null;
            legalEntityName = legalEntityName!=null?(legalEntityName.replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE)):null;
        }
    }
    
    /*@Created By: Sagarika
    * @Created Date: 26-July-2017 
    * @Description : Added to create step tags for the create-interview-instance-request 
    * @User Story : US1132369 : XC LI - Distribution Wiring Send to LI, US1132449 : XC - LI - Contracting Org Type LI, US1132350 : XC - LI - Education Ownership Type send to LI
    **/
    public static String populateStepData(Opportunity_Property__c objOpportunityPropertyData, MDU_Property__c propertyData, Opportunity opportunityData, String temptName, String UUID){
        
        String stepDataForRequest = MDU_Constants.BLANK_VALUE;
        String simpleControlsForStep = MDU_Constants.BLANK_VALUE; 
        
        //create a map with steps and input conntrols to map in each step
        Map<String, List<MDU_InterviewTemplateMapping__c>> attributesForSteps = new  Map<String, List<MDU_InterviewTemplateMapping__c>> ();
        
        //Get all the MDU_InterviewTemplateMapping__c records
        List<MDU_InterviewTemplateMapping__c> simpleControlsToMap = MDU_InterviewTemplateMapping__c.getAll().values();
        List<MDU_InterviewTemplateMapping__c> tempList = null;
        boolean matchingTemplate = false;
        if(!simpleControlsToMap.isEmpty()){
            for(MDU_InterviewTemplateMapping__c obj : simpleControlsToMap){    
                matchingTemplate = false;
                if(!String.isBlank(obj.Template__c))
                {
                    for(String template : obj.Template__c.split(COMMA)){
                        if(temptName.equalsIgnoreCase(template.trim())){
                            matchingTemplate = true;
                        }
                    }
                }
                if(matchingTemplate)
                {         
                    tempList = attributesForSteps.get(obj.Step_Name__c);
                    if(tempList == null)
                    {
                        tempList = new List<MDU_InterviewTemplateMapping__c>();
                    }
                    tempList.add(obj);
                    //populate the map with input conntrols for each step
                    attributesForSteps.put(obj.Step_Name__c, tempList);
                }
            }                                      
        }
        
        List<String> params = null;
        for(String stepName : attributesForSteps.keySet()){
            //Map the input controls one by one 
            simpleControlsForStep = MDU_Constants.BLANK_VALUE; 
            for(MDU_InterviewTemplateMapping__c simpleControlForMapping : attributesForSteps.get(stepName)){
                
                if(FRANCISE_NAME_HIDDEN.equalsIgnoreCase(simpleControlForMapping.SFDC_Field_Name__c)){
                    simpleControlsForStep += populateFranchiseData(simpleControlForMapping.Attribute_Name__c);
                }
                else if(LEGAL_NAME_HIDDEN.equalsIgnoreCase(simpleControlForMapping.SFDC_Field_Name__c)){
                    simpleControlsForStep += populateComcastLegalNameData(simpleControlForMapping.Attribute_Name__c);
                }
                else if(OPPORTUNITY.equalsIgnoreCase(simpleControlForMapping.Object__c)){
                    simpleControlsForStep += populateSimpleControl(simpleControlForMapping , opportunityData);
                }
                else if(OPPORTUNITYPROPERTY.equalsIgnoreCase(simpleControlForMapping.Object__c)){
                    simpleControlsForStep += populateSimpleControl(simpleControlForMapping , propertyData);
                }
                else if(MDU_PROPERTY.equalsIgnoreCase(simpleControlForMapping.Object__c)){
                    simpleControlsForStep += populateSimpleControl(simpleControlForMapping , propertyData);
                }
                else if(BLANK_VAL_PROP.equalsIgnoreCase(simpleControlForMapping.Object__c) || BLANK_VAL_OPP.equalsIgnoreCase(simpleControlForMapping.Object__c)){
                    params = new List<String>();
                    params.add(simpleControlForMapping.Attribute_Name__c);
                    params.add(MDU_Constants.BLANK_VALUE);
                    simpleControlsForStep += createSimpleControl(params, STRING_VAL);
                }
                else if(FIXED_PROP_VAL.equalsIgnoreCase(simpleControlForMapping.Object__c) || FIXED_OPP_VAL.equalsIgnoreCase(simpleControlForMapping.Object__c)){
                    params = new List<String>();
                    params.add(simpleControlForMapping.Attribute_Name__c);
                    
                    if(!String.isBlank(simpleControlForMapping.Fixed_Value__c))
                    {
                        params.add(simpleControlForMapping.Fixed_Value__c);
                    }
                    else
                    {
                        if(INTEGER_VAL.equalsIgnoreCase(simpleControlForMapping.Data_Type__c) || DECIMAL_VAL.equalsIgnoreCase(simpleControlForMapping.Data_Type__c)){
                            params.add(ZERO);
                        }else {
                            params.add(MDU_Constants.BLANK_VALUE);
                        }
                    }
                    simpleControlsForStep += createSimpleControl(params, simpleControlForMapping.Data_Type__c);
                }
            }
            
            //Add Primary Contact data and Party Input Controls to step name = mdu_confirm_opp
            if(MDU_Constants.MDU_CONFIRM_OPTY.equalsIgnoreCase(stepName))
            {
                simpleControlsForStep += populatePrimaryContactData();
                simpleControlsForStep += '<party-input-controls xmlns="http://www.dicarta.com/contracts/types/domain/step"><name xmlns="http://www.dicarta.com/contracts/types/domain/party-input-control">primary_contact_hidden</name><party-object xmlns="http://www.dicarta.com/contracts/types/domain/party-input-control"><organization-number>External Org</organization-number><organization-name>External Org</organization-name><primary-contact-id>';
                simpleControlsForStep += UUID;        
                simpleControlsForStep += '</primary-contact-id><party-type>Organization</party-type><role>Primary</role><contacts>';
                simpleControlsForStep += UUID;       
                simpleControlsForStep +=  '</contacts></party-object></party-input-controls>'; 
            }
            
            if(!String.isBlank(simpleControlsForStep))
            {
                stepDataForRequest += stepTag.replace(STEP_NAME, stepName).replace(INPUT_CONTROLS, simpleControlsForStep);  
            }
            
        }
        return stepDataForRequest; 
    }
    
    /*@Created By: Sagarika
    * @Created Date: 26-July-2017 
    * @Description : Populates the Primary Contact details in create-interview-instance-request
    * @User Story : US1132369 : XC LI - Distribution Wiring Send to LI, US1132449 : XC - LI - Contracting Org Type LI, US1132350 : XC - LI - Education Ownership Type send to LI
    **/
    public static String populatePrimaryContactData()
    {
        List<String> params = new List<String>();
        params.add(PRIMARY_CONTACT_VAL);
        // Calculated based on Opportunity Contact fields (if present) OR OpportunityContactRoles
        primary_contact = MDU_Constants.CONTACT_FIRST_NAME + contactFirstName +'\n'+ MDU_Constants.LAST_NAME +contactLastName +'\n'+ MDU_Constants.CONTACT_EMAIL + contactEmail;        
        params.add(primary_contact);
        return createSimpleControl(params,  STRING_VAL);
    }
    
    /*@Created By: Sagarika
    * @Created Date: 26-July-2017 
    * @Description : Populates the Franchise details in create-interview-instance-request
    * @User Story : US1132369 : XC LI - Distribution Wiring Send to LI, US1132449 : XC - LI - Contracting Org Type LI, US1132350 : XC - LI - Education Ownership Type send to LI
    **/
    public static String populateFranchiseData(String attributeName)
    {
        List<String> params = new List<String>();
        params.add(attributeName);
        params.add(String.isBlank(franchiseName) ?  MDU_Constants.BLANK_VALUE : franchiseName);
        return createSimpleControl(params, STRING_VAL);
    }
    
    /*@Created By: Sagarika
    * @Created Date: 26-July-2017 
    * @Description : Populates the Comcast Legal Name details in create-interview-instance-request
    * @User Story : US1132369 : XC LI - Distribution Wiring Send to LI, US1132449 : XC - LI - Contracting Org Type LI, US1132350 : XC - LI - Education Ownership Type send to LI
    **/   
    public static String populateComcastLegalNameData(String attributeName)
    {
        List<String> params = new List<String>();
        params.add(attributeName);
        params.add(String.isBlank(legalEntityName) ?  MDU_Constants.BLANK_VALUE : legalEntityName);
        return createSimpleControl(params, STRING_VAL);
    }
    
    /*@Created By: Sagarika
    * @Created Date: 26-July-2017 
    * @Description : Creates a param list using  the MDU_InterviewTemplateMapping__c obj 
    * @User Story : US1132369 : XC LI - Distribution Wiring Send to LI, US1132449 : XC - LI - Contracting Org Type LI, US1132350 : XC - LI - Education Ownership Type send to LI
    **/    
    public static String populateSimpleControl(MDU_InterviewTemplateMapping__c simpleControlData, Sobject obj)
    {
        List<String> params = new List<String>();
        String simpleControlTag = MDU_Constants.BLANK_VALUE;
        String temp = MDU_Constants.BLANK_VALUE;
        params.add(simpleControlData.Attribute_Name__c);
        if(INTEGER_VAL.equalsIgnoreCase(simpleControlData.Data_Type__c) || DECIMAL_VAL.equalsIgnoreCase(simpleControlData.Data_Type__c)){
            temp = String.valueOf(obj.get(simpleControlData.SFDC_Field_Name__c));
            params.add(String.isBlank(temp) ? ZERO : temp);
            simpleControlTag = createSimpleControl(params, simpleControlData.Data_Type__c);
        }else {
            temp = String.valueOf(obj.get(simpleControlData.SFDC_Field_Name__c));
            if(CONTRACTING_ORG_TYPE.equalsIgnoreCase(simpleControlData.SFDC_Field_Name__c) && NONE.equalsIgnoreCase(temp)){
                temp = MDU_Constants.BLANK_VALUE;
            }
             else if(PREMIUM_CHANNELS.equalsIgnoreCase(simpleControlData.SFDC_Field_Name__c) && !String.isBlank(temp))
            {
                temp = temp.replace(MDU_Constants.SEMI_COLON, NEW_LINE);
            }
            if(!String.isBlank(temp))
            {
                temp = formattedString(temp);
                if(PROPERTY_INFO.equalsIgnoreCase(simpleControlData.SFDC_Field_Name__c)){
                    temp += (String.isBlank(franchiseName) ? MDU_Constants.BLANK_VALUE : franchiseName);
                }
                params.add(temp);
                simpleControlTag = createSimpleControl(params, simpleControlData.Data_Type__c);
            }
        }
        return simpleControlTag;
    }
    
    /*@Created By: Sagarika
    * @Created Date: 26-July-2017 
    * @Description : Creates simple control tag depending on params and datatype passed
    * @User Story : US1132369 : XC LI - Distribution Wiring Send to LI, US1132449 : XC - LI - Contracting Org Type LI, US1132350 : XC - LI - Education Ownership Type send to LI
    **/
    public static String createSimpleControl(List<String> params, String dataType)
    {
        if(INTEGER_VAL.equalsIgnoreCase(dataType) || DECIMAL_VAL.equalsIgnoreCase(dataType)){
            return String.format(MDU_Constants.SIMPLE_DATA_CONTROL_NUMBER , params);
        }else {
            return String.format(MDU_Constants.SIMPLE_DATA_CONTROL_STRING , params);
        }
    }
    
    /*@Created By: Sagarika
    * @Created Date: 26-July-2017 
    * @Description : Formats string value to fix formating before adding to XML 
    * @User Story : US1132369 : XC LI - Distribution Wiring Send to LI, US1132449 : XC - LI - Contracting Org Type LI, US1132350 : XC - LI - Education Ownership Type send to LI
    **/
    public static String formattedString(String unformattedString)
    {
        String formattedString = MDU_Constants.BLANK_VALUE;
        if(!String.isBlank(unformattedString))
        {
            formattedString = unformattedString.replace(LINE_BREAK,NEW_LINE);
            formattedString = formattedString.replace(AMP_VAL,AMP_REPLACE);
            formattedString = formattedString.replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE);
        }
        return formattedString;
    }
}