/************************************************************************************************************************************************************
Name: MDU_InterviewTemplates 
Description: This class is used to Create the Interview Templates.
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
16 Feb 2015 Comcast  
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
    public static Map<String, Decimal> paramIntegerValMap =null;   
    public static Map<String, String> paramStringValMap =null;
    
    public static Map<String, Decimal> paramIntegerValMapOpty =null;   
    public static Map<String, String> paramStringValMapOpty =null;
    private static final String OPPORTUNITY = 'Opportunity';
    private static final String OPPORTUNITYPROPERTY = 'OpportunityProperty';
    private static final String MDU_PROPERTY = 'MDU_Property__c';
    private static final String INTEGER_VAL = 'Integer';
    private static final String DECIMAL_VAL = 'Decimal';
    private static final String STRING_VAL = 'String';
    private static final String BLANK_VAL_PROP = 'BLANK_PROP';
    private static final String BLANK_VAL_OPP = 'BLANK_OPP';
    private static final String OPPORTUNITY_INFO = 'opportunity_info__c';
    private static final String PROPERTY_INFO = 'Property_Info__c';
    private static final String PROPERTY_NAME_ADDR = 'Property_Name_Address__c';
    private static final String RISK_STATUS = 'Risk_Status__c';
    private static final String PRIMARY_CONTACT_VAL = 'primary_contact';
    private static final String FIXED_PROP_VAL = 'FIXED_PROP';
    private static final String FIXED_OPP_VAL = 'FIXED_OPP';
    private static final String FRANCHISE_NAME_HIDDEN = 'Franchise_Name_Hidden__c';
    private static final String COMCAST_LEGAL_NAME_HIDDEN = 'comcast_legal_name_hidden__c';
    private static final String AMP_VAL = '&';
    private static final String GREATER_THAN_VAL = '>';
    private static final String LESS_THAN_VAL = '<';
    private static final String AMP_REPLACE = '&amp;';
    private static final String GREATER_THAN_REPLACE = '&gt;';
    private static final String LESS_THAN_REPLACE = '&lt;';

    
    /**
    * Name: setConstantVariable
    * Description: This method is used to Set The constant Variables values come from MDU_EmptorisIntegrationCS__c custom setting. 
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
        String stepName = MDU_Constants.MDU_CONFIRM_PROPERTY; 
        String stepNameOpty = MDU_Constants.MDU_CONFIRM_OPTY;               
        // Envelop string mapping parameters
        params.add(user);
        params.add(sourceStr);
        params.add(dtTimeStr);
        params.add(algoStr);
        params.add(theToken);       
        params.add(interviewInstanceName);       
        params.add(description);
        params.add(templateNm);
        params.add(stepName);
        params.add(stepNameOpty);
    
        MDU_InterviewTemplates.franchiseLegalData(propertyData.Franchise_New__c);
        MDU_InterviewTemplates.populateContactData(objOpportunityPropertyData, objOpportunityContactRole);
        MDU_InterviewTemplates.populateOpportunityPropertyData(objOpportunityPropertyData, propertyData, opportunityData, templateNm);
              
        String soapEnvTemplate = MDU_EmptorisEnvelopeTemplate.CREATE_INTERVIEW_BASE_ENV;    
        soapEnvTemplate+= MDU_EmptorisEnvelopeTemplate.REQUEST_AUTHENTICATION;
        
        soapEnvTemplate+= '<request-data><name>{5}</name><label>{5}</label><description>{6}</description><template-name>{7}</template-name><steps><name xmlns="http://www.dicarta.com/contracts/types/domain/step">{8}</name>';
        
        for(String paramName: paramStringValMap.KeySet()){          
            soapEnvTemplate += '<simple-input-controls xmlns="http://www.dicarta.com/contracts/types/domain/step"><name xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control">'+ paramName
            + '</name><value xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control"><string-value xmlns="http://www.dicarta.com/contracts/types/domain/common">' 
            + paramStringValMap.get(paramName) + '</string-value></value></simple-input-controls>';
        }
                
        for(String paramName: paramIntegerValMap.KeySet()){         
            soapEnvTemplate += '<simple-input-controls xmlns="http://www.dicarta.com/contracts/types/domain/step"><name xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control">'+ paramName
            + '</name><value xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control"><number-value xmlns="http://www.dicarta.com/contracts/types/domain/common">' 
            + paramIntegerValMap.get(paramName) + '</number-value></value></simple-input-controls>';
        }
        soapEnvTemplate += '</steps>';
        
        soapEnvTemplate += '<steps><name xmlns="http://www.dicarta.com/contracts/types/domain/step">{9}</name>';
        
        for(String paramName: paramStringValMapOpty.KeySet()){          
            soapEnvTemplate += '<simple-input-controls xmlns="http://www.dicarta.com/contracts/types/domain/step"><name xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control">'+ paramName
            + '</name><value xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control"><string-value xmlns="http://www.dicarta.com/contracts/types/domain/common">' 
            + paramStringValMapOpty.get(paramName) + '</string-value></value></simple-input-controls>';
        }
                
        for(String paramName: paramIntegerValMapOpty.KeySet()){         
            soapEnvTemplate += '<simple-input-controls xmlns="http://www.dicarta.com/contracts/types/domain/step"><name xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control">'+ paramName
            + '</name><value xmlns="http://www.dicarta.com/contracts/types/domain/simple-input-control"><number-value xmlns="http://www.dicarta.com/contracts/types/domain/common">' 
            + paramIntegerValMapOpty.get(paramName) + '</number-value></value></simple-input-controls>';
        }
        
        soapEnvTemplate += '<party-input-controls xmlns="http://www.dicarta.com/contracts/types/domain/step"><name xmlns="http://www.dicarta.com/contracts/types/domain/party-input-control">primary_contact_hidden</name><party-object xmlns="http://www.dicarta.com/contracts/types/domain/party-input-control"><organization-number>External Org</organization-number><organization-name>External Org</organization-name><primary-contact-id>';
        
        soapEnvTemplate += UUID;        
        soapEnvTemplate += '</primary-contact-id><party-type>Organization</party-type><role>Primary</role><contacts>';
        soapEnvTemplate += UUID;       
        soapEnvTemplate +=  '</contacts></party-object></party-input-controls></steps></request-data></create-interview-instance-request></s:Body></s:Envelope>';        
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
    
    /**
    * Name: populateOpportunityPropertyData
    * Description: This method is used to Populate the Opportunity and Property Related Fields. 
    * @parameters: objOpportunityProperty, Opportunity & Property data
    * @return: None
    **/
    public static void populateOpportunityPropertyData(Opportunity_Property__c objOpportunityPropertyData, MDU_Property__c propertyData, Opportunity opportunityData, String temptName){
        
        primary_contact = '';
        paramIntegerValMap = new Map<string, Decimal>();
        paramStringValMap = new Map<String, String>();
        
        paramIntegerValMapOpty = new Map<string, Decimal>();
        paramStringValMapOpty = new Map<String, String>();
        
        Map<String, List<MDU_InterviewTemplateMapping__c>> sObjectTemplateListMap = new Map<String, List<MDU_InterviewTemplateMapping__c>>();       
        List<MDU_InterviewTemplateMapping__c> templateMapping = MDU_InterviewTemplateMapping__c.getAll().values(); 
        
        if(!templateMapping.isEmpty()){
            for(MDU_InterviewTemplateMapping__c obj : templateMapping){ 
            
                if(obj.Object__c!=null){
                    // Template check to be added here
                    List<MDU_InterviewTemplateMapping__c> tempList = sObjectTemplateListMap.get(obj.Object__c);
                    if(tempList==null){
                        tempList= new List<MDU_InterviewTemplateMapping__c>();                                                 
                    }
                    tempList.add(obj);
                    sObjectTemplateListMap.put(obj.Object__c, tempList);                        
                }
            }                                      
        }
        
        for(String str: sObjectTemplateListMap.keySet()){
            
            if(str.equalsIgnoreCase(OPPORTUNITY)){
                for(MDU_InterviewTemplateMapping__c obj: sObjectTemplateListMap.get(str)){
                    
                    if(obj.TEMPLATE__C.containsIgnoreCase(temptName)){
                        if(obj.Data_Type__c!=null && obj.Data_Type__c.equalsIgnoreCase(INTEGER_VAL)){
                            paramIntegerValMapOpty.put(obj.Attribute_Name__c, opportunityData.get(obj.SFDC_Field_Name__c)==null?0: Integer.valueOf(opportunityData.get(obj.SFDC_Field_Name__c)));
                        } 
                        else if(obj.Data_Type__c!=null && obj.Data_Type__c.equalsIgnoreCase(DECIMAL_VAL)){
                            paramIntegerValMapOpty.put(obj.Attribute_Name__c, opportunityData.get(obj.SFDC_Field_Name__c)==null?0: Decimal.valueOf(String.valueOf(opportunityData.get(obj.SFDC_Field_Name__c))));
                        }else {
                            if(obj.SFDC_Field_Name__c.equalsIgnoreCase(OPPORTUNITY_INFO)){
                                string temp = String.valueOf(opportunityData.get(OPPORTUNITY_INFO));
                                temp = (temp==null?'': temp.replace('<br>', '\n'));
                                paramStringValMapOpty.put(obj.Attribute_Name__c,temp);
                            }
                            else{
                                paramStringValMapOpty.put(obj.Attribute_Name__c, opportunityData.get(obj.SFDC_Field_Name__c)==null?'': String.valueOf(opportunityData.get(obj.SFDC_Field_Name__c)).replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE));
                            }
                        }
                    }
                }
            }
            
            if(str.equalsIgnoreCase(OPPORTUNITYPROPERTY)){
                for(MDU_InterviewTemplateMapping__c obj: sObjectTemplateListMap.get(str)){
                    
                    if(obj.TEMPLATE__C.containsIgnoreCase(temptName)){
                        if(obj.Data_Type__c!=null && obj.Data_Type__c.equalsIgnoreCase(INTEGER_VAL)){
                            paramIntegerValMapOpty.put(obj.Attribute_Name__c, propertyData.get(obj.SFDC_Field_Name__c)==null?0: Integer.valueOf(propertyData.get(obj.SFDC_Field_Name__c)));
                        } else {
                            paramStringValMapOpty.put(obj.Attribute_Name__c, propertyData.get(obj.SFDC_Field_Name__c)==null?'': String.valueOf(propertyData.get(obj.SFDC_Field_Name__c)).replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE));
                        }
                    }
                }
            }
            
            if(str.equalsIgnoreCase(MDU_PROPERTY)){
                for(MDU_InterviewTemplateMapping__c obj: sObjectTemplateListMap.get(str)){                  
                    if(obj.TEMPLATE__C.containsIgnoreCase(temptName)){
                        
                        if(obj.Data_Type__c!=null && obj.Data_Type__c.equalsIgnoreCase(INTEGER_VAL)){
                            paramIntegerValMap.put(obj.Attribute_Name__c, propertyData.get(obj.SFDC_Field_Name__c)==null?0: Integer.valueOf(propertyData.get(obj.SFDC_Field_Name__c)));
                        }
                        else if(obj.Data_Type__c!=null && obj.Data_Type__c.equalsIgnoreCase(DECIMAL_VAL)){
                            paramIntegerValMap.put(obj.Attribute_Name__c, propertyData.get(obj.SFDC_Field_Name__c)==null?0: Decimal.valueOf(String.valueOf(propertyData.get(obj.SFDC_Field_Name__c))));
                        }else {
                            /*if(obj.SFDC_Field_Name__c.equalsIgnoreCase(RISK_STATUS)){
                                paramStringValMap.put(obj.Attribute_Name__c, propertyData.get(obj.SFDC_Field_Name__c)==null?'': EncodingUtil.urlEncode(String.valueOf(propertyData.get(obj.SFDC_Field_Name__c)),MDU_Constants.UTF8));
                            }
                            else*/ 
                            if(obj.SFDC_Field_Name__c.equalsIgnoreCase(PROPERTY_INFO)){
                                string temp = String.valueOf(propertyData.get(PROPERTY_INFO));                          
                                temp = (temp==null?'': temp.replace('<br>', '\n')) + (franchiseName==null?'':franchiseName);
                                paramStringValMap.put(obj.Attribute_Name__c,temp);
                            }
                            else if(obj.SFDC_Field_Name__c.equalsIgnoreCase(PROPERTY_NAME_ADDR)){
                                string temp = String.valueOf(propertyData.get(PROPERTY_NAME_ADDR));
                                temp = (temp==null?'': temp.replace('<br>', '\n'));
                                paramStringValMap.put(obj.Attribute_Name__c,temp);
                            }
                            else if(obj.SFDC_Field_Name__c.equalsIgnoreCase(FRANCHISE_NAME_HIDDEN)){
                                paramStringValMap.put(obj.Attribute_Name__c, franchiseName==null?'':franchiseName);
                            }
                            else if(obj.SFDC_Field_Name__c.equalsIgnoreCase(COMCAST_LEGAL_NAME_HIDDEN)){
                                paramStringValMap.put(obj.Attribute_Name__c, legalEntityName==null?'':legalEntityName);
                            }
                            else{
                                paramStringValMap.put(obj.Attribute_Name__c, propertyData.get(obj.SFDC_Field_Name__c)==null?'': String.valueOf(propertyData.get(obj.SFDC_Field_Name__c)).replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE));
                            }
                        }
                    } 
                    
                }
            }
            
            // EMPTY MApping for PROPERTY
            if(str.equalsIgnoreCase(BLANK_VAL_PROP)){
                for(MDU_InterviewTemplateMapping__c obj: sObjectTemplateListMap.get(str)){                  
                    paramStringValMap.put(obj.Attribute_Name__c, '');                                      
                }
            }
            
            // EMPTY Mapping for Opportunity
            if(str.equalsIgnoreCase(BLANK_VAL_OPP)){
                for(MDU_InterviewTemplateMapping__c obj: sObjectTemplateListMap.get(str)){                  
                    paramStringValMapOpty.put(obj.Attribute_Name__c, '');                                    
                }
            }
            
            // FIXED value for PROPERTY (if any)
            if(str.equalsIgnoreCase(FIXED_PROP_VAL)){
                for(MDU_InterviewTemplateMapping__c obj: sObjectTemplateListMap.get(str)){  
                    if(obj.Data_Type__c!=null && obj.Data_Type__c.equalsIgnoreCase(INTEGER_VAL)){
                        paramIntegerValMap.put(obj.Attribute_Name__c, obj.Fixed_Value__c==null?0: Integer.valueOf(obj.Fixed_Value__c));
                    } else if(obj.Data_Type__c!=null && obj.Data_Type__c.equalsIgnoreCase(DECIMAL_VAL)){              
                        paramIntegerValMap.put(obj.Attribute_Name__c, obj.Fixed_Value__c==null?0: Decimal.valueOf(String.valueOf(obj.Fixed_Value__c)));             
                    }else {              
                        paramStringValMap.put(obj.Attribute_Name__c, obj.Fixed_Value__c==null?'': String.valueOf(obj.Fixed_Value__c).replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE));  
                    }                                                  
                }
            }
            
            // FIXED value for OPPORTUNITY (if any)
            if(str.equalsIgnoreCase(FIXED_OPP_VAL)){
                for(MDU_InterviewTemplateMapping__c obj: sObjectTemplateListMap.get(str)){  
                    if(obj.Data_Type__c!=null && obj.Data_Type__c.equalsIgnoreCase(INTEGER_VAL)){
                        paramIntegerValMapOpty.put(obj.Attribute_Name__c, obj.Fixed_Value__c==null?0: Integer.valueOf(obj.Fixed_Value__c));
                    } else if(obj.Data_Type__c!=null && obj.Data_Type__c.equalsIgnoreCase(DECIMAL_VAL)){              
                        paramIntegerValMapOpty.put(obj.Attribute_Name__c, obj.Fixed_Value__c==null?0: Decimal.valueOf(String.valueOf(obj.Fixed_Value__c)));
                    }else {              
                        paramStringValMapOpty.put(obj.Attribute_Name__c, obj.Fixed_Value__c==null?'': String.valueOf(obj.Fixed_Value__c).replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE));    
                    }                                                  
                }
            }
        }
       
        // Calculated based on Opportunity Contact fields (if present) OR OpportunityContactRoles
        primary_contact = MDU_Constants.CONTACT_FIRST_NAME + contactFirstName +'\n'+ MDU_Constants.LAST_NAME +contactLastName +'\n'+ MDU_Constants.CONTACT_EMAIL + contactEmail;        
        paramStringValMapOpty.put(PRIMARY_CONTACT_VAL, primary_contact);       
                       
    }
}