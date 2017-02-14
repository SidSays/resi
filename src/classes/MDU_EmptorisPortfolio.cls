/**
* Class Name: MDU_EmptorisPortfolio
* Author: Abhishek Mathur, Accenture
* Date: 26-December-2014 
* Last Modified By: Sagar Gurav
* Description: Class to return the property details based on opportunity id.
*/
global class MDU_EmptorisPortfolio{
    
    //Variable declaration.
    public static final String ECM_MONTHLY_BILLING = 'total_monthly_billing';
    public static final String ECM_TOTAL_COMPENSATION = 'total_compensation';
    public static Map<Id,Legal_Entity__c> legalEntityIdToObjMap = new Map<Id,Legal_Entity__c>();  
    public static final String AMP_VAL = '&';
    public static final String GREATER_THAN_VAL = '>';
    public static final String LESS_THAN_VAL = '<';
    public static final String AMP_REPLACE = '&amp;';
    public static final String GREATER_THAN_REPLACE = '&gt;';
    public static final String LESS_THAN_REPLACE = '&lt;';
              
    /*
    * Generate Emptoris XML using OpportunityId
    */
    webService static List<WrapperProp> getPropertyInfo(String opportunityId){
        List<MDU_EmptorisFieldMapping__c> customSettingMap = new List<MDU_EmptorisFieldMapping__c>();
        Map<Id,Opportunity_Property__c> propIdToOppProp = new Map<Id,Opportunity_Property__c>();
        customSettingMap = getEmtorisCustomSettingDetails();
        
        // Re initialize static map.
        legalEntityIdToObjMap = new Map<Id,Legal_Entity__c>();  
        propIdToOppProp = getPropertyIdToOppPropObj(opportunityId);
        List<WrapperProp> wrapperObjList = new List<WrapperProp>();
        if(propIdToOppProp !=null && customSettingMap != null){
            for(Opportunity_Property__c oppPropInst :  propIdToOppProp.values()){                
                WrapperProp wrapObj = new WrapperProp();
                String valBuild = '';
                valBuild = valBuild+'<a:_ECM_Values>';
                valBuild = valBuild+'<ECM_Variables>';
                for(MDU_EmptorisFieldMapping__c customSettingObj : customSettingMap){
                    
                    valBuild = valBuild+'<ECM_Variable>';
                    valBuild = valBuild+'<Name>' + customSettingObj.ECM_Variable_Name__c + '</Name>';
                    valBuild = valBuild+'<InternalName>' + customSettingObj.ECM_Variable_Internal_Name__c + '</InternalName>';
                    valBuild = valBuild+'<Type>' + customSettingObj.ECM_Variable_Data_Type__c + '</Type>';
                    valBuild = valBuild+'<Value>';  
                    
                    /*Added to pass the Opportunity Id as term value to ECM system for Legacy Opportunity records*/
                    if(customSettingObj.Object__c.containsIgnoreCase('Opportunity')){
                        valBuild = valBuild+ (oppPropInst.Opportunity__c==null?'': String.valueOf(oppPropInst.Opportunity__c)).replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE);
                    }   
                                 
                    else if(ECM_MONTHLY_BILLING.containsIgnoreCase(customSettingObj.ECM_Variable_Internal_Name__c)){
                        if(oppPropInst.Opportunity__r.Video_Bulk_Proposed_Rate__c != null && oppPropInst.Opportunity__r.Data_Bulk_Proposed_Rate__c != null && oppPropInst.Opportunity__r.Voice_Bulk_Proposed_Rate__c != null && oppPropInst.Property__r.Number_of_Units__c != null ){
                            valBuild = valBuild+ ''+(oppPropInst.Opportunity__r.Video_Bulk_Proposed_Rate__c +
                            oppPropInst.Opportunity__r.Data_Bulk_Proposed_Rate__c +
                            oppPropInst.Opportunity__r.Voice_Bulk_Proposed_Rate__c) *
                            oppPropInst.Property__r.Number_of_Units__c;
                        }
                    }               
                    else if(ECM_TOTAL_COMPENSATION.containsIgnoreCase(customSettingObj.ECM_Variable_Internal_Name__c)){
                        if(oppPropInst.Opportunity__r.Per_Unit_Door_Fee__c != null && oppPropInst.Property__r.Number_of_Units__c != null) {
                            valBuild = valBuild+ ''+oppPropInst.Opportunity__r.Per_Unit_Door_Fee__c * oppPropInst.Property__r.Number_of_Units__c;   
                        }
                    }
                    else if(customSettingObj.Object__c.containsIgnoreCase('Legal')){
                            
                            if(oppPropInst.Property__r.Franchise_Legal_ID__c != null){
                                List<String> franchiseLegalId = oppPropInst.Property__r.Franchise_Legal_ID__c.split('-');
                                if(franchiseLegalId!=null && franchiseLegalId.size()>1){
                                    String legaglId = franchiseLegalId[1];
                                    valBuild = valBuild+ (getLegalDetails(legaglId, customSettingObj.SFDC_Field_Name__c)).replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE); 
                                }
                            }else{
                                valBuild = valBuild + '';
                            }
                    }
                    
                    else if(customSettingObj.SFDC_Field_Name__c.containsIgnoreCase('BLANK')){
                            valBuild = valBuild + '';
                    }
                    else{
                            String tempVal = '';
                            tempVal = oppPropInst.Property__r.get(customSettingObj.SFDC_Field_Name__c)==null?'': String.valueOf(oppPropInst.Property__r.get(customSettingObj.SFDC_Field_Name__c));
                            valBuild = valBuild+ ''+ tempVal.replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE);                                            
                    } 
                    valBuild = valBuild+'</Value>';
                    valBuild = valBuild+'</ECM_Variable>';
                }
                valBuild = valBuild+'</ECM_Variables>';
                valBuild = valBuild+'</a:_ECM_Values>';
                
                wrapObj.XMLString = valBuild;
                
                //updated to pass property ID 
                wrapObj.PropertyComplexId = oppPropInst.Property__c;
                wrapObj.PropertyName = (propIdToOppProp.get(oppPropInst.Property__c).Property__r.Name).replace(AMP_VAL,AMP_REPLACE).replace(LESS_THAN_VAL,LESS_THAN_REPLACE).replace(GREATER_THAN_VAL,GREATER_THAN_REPLACE);
                wrapObj.IsPrimaryProperty = propIdToOppProp.get(oppPropInst.Property__c).Primary_Property__c;
                wrapperObjList.add(wrapObj);
            }
        }        
        return wrapperObjList;
    }
    
    
        
   /*
   * Wrapper class used to store opportunity property id, Property Name, Primary_Property__c & XMLString
   */
    global class WrapperProp {
        webservice String PropertyComplexId;
        webservice String PropertyName;
        webservice Boolean IsPrimaryProperty;
        webservice String XMLString;
    }
    
    
    /*
    * Method to return prop id & its associated Opportunity Property for an opportunity.
    */
    public static Map<Id,Opportunity_Property__c> getPropertyIdToOppPropObj(String opportunityId){
        
        Map<Id,Opportunity_Property__c> returnobj = new Map<Id,Opportunity_Property__c>();
        try{
            Set<id> franchiseLegalIdSet = new Set<id>();
            Set<id> proipertyId = new Set<id>();
            for(Opportunity_Property__c opportunityPropertyTemp : [SELECT id, Property__c, Primary_Property__c, Opportunity__r.Video_Bulk_Proposed_Rate__c,                                                        Opportunity__r.Per_Unit_Door_Fee__c, Opportunity__r.Data_Bulk_Proposed_Rate__c, 
                                                                    Opportunity__r.Voice_Bulk_Proposed_Rate__c, Property__r.comcast_legal_name_hidden__c, Property__r.Franchise_Name_Hidden__c, Property__r.Number_of_Units__c, Property__r.City__c,Property__r.Franchise_Legal_ID__c, Property__r.Address__c, Property__r.Address_2__c, Property__r.PostalCode__c, Opportunity__c, 
                                                                    Property__r.County__c, Property__r.Property_Grade__c, Property__r.Complex_ID__c, Property__r.Name, Property__r.Property_Rating__c, Property__r.MDU_State__c, Property__r.Property_Type__c, Property__r.Risk_Status__c, Property__r.owner_account_street__c,  Property__r.owner_account_name__c, Property__r.owner_account_zipcode__c,Property__r.owner_account_mduState__c, Property__r.owner_account_city__c, Property__r.State_Name__c  FROM Opportunity_Property__c WHERE 
                                                                    Opportunity__c =: opportunityId OR Opportunity__r.MDU_Opportunity_ID__c=:opportunityId]){
                returnobj.put(opportunityPropertyTemp.Property__c,opportunityPropertyTemp);
                
                //get Legal Entity details
                List<String> idList = new List<String>();
                if(opportunityPropertyTemp.Property__r.Franchise_Legal_ID__c!=null){
                    idList = opportunityPropertyTemp.Property__r.Franchise_Legal_ID__c.split('-');
                }
                
                if(idList.size()>1){
                    franchiseLegalIdSet.add(idList[1]);
                }
            }
            
            if(!franchiseLegalIdSet.isEmpty()){
                for(Legal_Entity__c legEntInst : [SELECT id,Legal_Entity_Address_City__c,Legal_Entity_Address_Line2__c,Legal_Entity_Address_State_ID__c, 
                Legal_Entity_Address_Street__c,Legal_Entity_Address_Zip__c,Legal_Entity_ID__c,Legal_Entity_Name__c,
                Legal_Entity_Type__c from Legal_Entity__c where id =: franchiseLegalIdSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    
                    legalEntityIdToObjMap.put(legEntInst.id,legEntInst);
                }
            }
        }catch(Exception ex){
            System.debug('Following exception occurred :'+ex.getMessage());
        }     
        return  returnobj;       
    }
    
    
    /*
    * This method is used to get legal entity details.
    */
    public static String getLegalDetails(String franchiselegal, String sfdcFieldName) {
        string returnStr = '';
        try{
            if(legalEntityIdToObjMap.containsKey(franchiselegal)){
            Legal_Entity__c legEntTemp = legalEntityIdToObjMap.get(franchiselegal);
            returnStr = legEntTemp.get(sfdcFieldName)==null?'': String.valueOf(legEntTemp.get(sfdcFieldName));            
        }
        }catch(Exception ex){
            System.debug('Following exception occurred :'+ex.getMessage());
        }
        
        return returnStr;
    }
    
    /*
    * Get Emptoris Custom Setting Map
    */
    public static List<MDU_EmptorisFieldMapping__c> getEmtorisCustomSettingDetails(){
        List<MDU_EmptorisFieldMapping__c> ecmVarNameObjectMap = new List<MDU_EmptorisFieldMapping__c>();
        try{
            ecmVarNameObjectMap =  MDU_EmptorisFieldMapping__c.getAll().values();         
        }catch(Exception ex){
            System.debug('Following exception occurred :'+ex.getMessage());
        }
        return  ecmVarNameObjectMap;       
    } 
}