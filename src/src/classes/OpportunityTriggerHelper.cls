/***************************************************************************************************************************************
 * Author     : Sagarika 
 * Date       : 01-June-2017
 * Description: This is a Helper class for methods which are called from the Opportunity Trigger.
 * Last Modified By: Deepika Jain
* Last Modified Date : 14th Aug 2017
* User story  : US1167685(XC - Wifi Ready Fields in Opportunity).
* Desciption : Adding methods to restrict the editing of the fields on Opportunity.
* Last Modified By : Deepika Jain
* Last Modified Date : 22nd Aug 2017 
* User Story: US1166692 and US1166808 (XC -  Video Equipment by Industry) and (XC -  Marketing Rights)
* Description : Added methods to put validation on Opportunity fields 'Marketing Rights' and 'Type of video equipment' fields.
***************************************************************************************************************************************/
public without sharing class OpportunityTriggerHelper {
    
    private final static String PROPERTY_NAME = 'PROPERTY_NAME';
    private final static String OPP_NAME =  'OPP_NAME';
    private final static String OPP_STAGE = 'OPP_STAGE';
    public static boolean allowOppValidation = true;
    public final static String MDTA='MDTA';
    public final static String DTA='DTA';
    public final static String DCT='DCT';
    public final static String DTA_AND_DCT='DTA and DCT';
    
     /*
    Name : sendEmailToCARonOpportunityProperty
    Description : This method is used to send email to Assigned CARs when the Stage of Opportnity Changes.
    Return : void
    Author : Sagarika Somasundaram
    User Story : US990966 
    */
    public static void sendEmailToCAROnOpportunityProperty(Map<Id,Opportunity> oldOppMap,List<Opportunity> newOppList ){
        
        Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity_Property__c> opptyPropertyList = new list<Opportunity_Property__c>();
        Set<Opportunity_Property__c> oppIdVsOpptyPropertyMapWithCAR = new Set<Opportunity_Property__c>();
        
        try{
            oppIdSet = getOpportunitiesWithStageChange(oldOppMap, newOppList);
            //Start Empty Check for opportunity id
            if(!oppIdSet.isEmpty()){
                opptyPropertyList = [SELECT Id,Property__c,opportunity__c,Property__r.Assigned_CAR__c, Property__r.Name, Opportunity__r.name, Opportunity__r.StageName FROM Opportunity_Property__c 
                                     WHERE opportunity__c IN : oppIdSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                if(!opptyPropertyList.isEmpty()){
                    for(Opportunity_Property__c opptyProp : opptyPropertyList){
                        //Check if Property is not NULL.
                        if(opptyProp.Property__c != null ){
                            //Check if Assigned_CAR__c is not null
                            if(opptyProp.Property__r.Assigned_CAR__c != null){
                                oppIdVsOpptyPropertyMapWithCAR.add(opptyProp);
                            }
                        }
                    }                     
                }

                Messaging.SingleEmailMessage singleEmailForCAR = null;
                List<Messaging.SingleEmailMessage>  emailsForCAR = new List<Messaging.SingleEmailMessage>();
                String emailMessage = null;
                if(!oppIdVsOpptyPropertyMapWithCAR.isEmpty()){
                    for(Opportunity_Property__c opptyProp : oppIdVsOpptyPropertyMapWithCAR){
                        emailMessage = System.Label.EmailToCAROnOpportunityStageChange.replace(PROPERTY_NAME, opptyProp.Property__r.name);
                        emailMessage = emailMessage.replace(OPP_NAME, opptyProp.Opportunity__r.name);
                        emailMessage = emailMessage.replace(OPP_STAGE, opptyProp.Opportunity__r.StageName); 
                        
                        singleEmailForCAR = new Messaging.SingleEmailMessage();
                        singleEmailForCAR.setSubject(opptyProp.Opportunity__r.name);
                        singleEmailForCAR.setTargetObjectId(opptyProp.Property__r.Assigned_CAR__c);
                        singleEmailForCAR.saveAsActivity=false;
                        singleEmailForCAR.setHtmlBody(emailMessage);
                        emailsForCAR.add(singleEmailForCAR);  
                    }
                }   
                
                if(!emailsForCAR.isEmpty())
                {
                    Messaging.sendEmail(emailsForCAR);
                }
            }
        }
        //Catch block 
        catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }          
        
    }
    
    /*
    Name : getOpportunitiesWithStageChange
    Description : This method is used to get all opportunitiies for which stage is changed.
    Return : Set<Id>  opportunity
    Author : Sagarika Somasundaram
    User Story : US990966 
    */
    public static Set<Id> getOpportunitiesWithStageChange(Map<Id,Opportunity> oldOppMap,List<Opportunity> newOppList)
    {
        Set<Id> changedOpps = null;
        try
        {
            String stageOfNewOpp = null;
            String stageOfOldOpp = null;
            if(!newOppList.isEmpty()){
                changedOpps = new Set<Id>();
                for(Opportunity opportunity : newOppList){
                        stageOfOldOpp = null;
                        if(oldOppMap.get(opportunity.Id) != null)
                        {
                            stageOfOldOpp =  oldOppMap.get(opportunity.Id).StageName;
                        }
                        stageOfNewOpp = null;
                        if(opportunity != null && !String.isBlank(opportunity.StageName))
                        {
                            stageOfNewOpp =  opportunity.StageName;
                        }
                        //Check if Stage on Opportunity is Changed.
                        if(stageOfOldOpp != stageOfNewOpp){
                        //Add opportunity Id to set
                            changedOpps.add(opportunity.Id);
                        }
                    }               
                }
        }
        catch(Exception e){
            System.debug('Exception: '+e.getMessage());
        }          
        return changedOpps;
    }
    
     /*
    * Name : restrictEditWifiReadyFieldInsert
    * Para : List<Opportunity> newOppList
    * Return Value : None
    * Description : To restrict editing of the fields on Opportunity whenever new Opportunity is created.  
    */
    public static void restrictEditWifiReadyFieldInsert(List<Opportunity> newOppList){
        Set<Id> propIdSet =  new Set<Id>();
        Map<Id,MDU_Property__c> propertyMap = new map<Id,MDU_Property__c>();
        for(Opportunity opp : newOppList){
            propIdSet.add(opp.Property__c);
        }
        for(MDU_Property__c prop : [SELECT Id,Common_area_wide_Wifi_Ready__c,Property_Wide_Wifi_Ready__c,WiFi_Ready__c,Industry_Type__c FROM MDU_Property__c
                                                     WHERE Id IN: propIdSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            propertyMap.put(prop.id,prop);
        }
        for(Opportunity opp : newOppList){
            if(propertyMap.containskey(opp.Property__c)){
                if(opp.Common_area_wide_Wifi_Ready__c!=(propertyMap.get(opp.Property__c)).Common_area_wide_Wifi_Ready__c ||
                        opp.Property_Wide_Wifi_Ready__c!=(propertyMap.get(opp.Property__c)).Property_Wide_Wifi_Ready__c ||
                        opp.WiFi_Ready__c!=(propertyMap.get(opp.Property__c)).WiFi_Ready__c){
                    opp.addError(Label.OppFieldsCannotBeEdited, false);
                }
            }
            
        }   
    }
    /*
    * Name : restrictEditWifiReadyFieldsUpdate
    * Para : List<Opportunity> newOppList, Map<Id,Opportunity> oldOppMap
    * Return Value : None
    * Description : To restrict editing of the fields on Opportunity whenever new Opportunity is updated.  
    */ 
    public static void restrictEditWifiReadyFieldsUpdate(List<Opportunity> newOppList, Map<Id,Opportunity> oldOppMap){
        Set<Id> oppIdsSet = new Set<Id>();
        Map<Id,Opportunity_Property__c> opportunityPropertyMap = new Map<Id,Opportunity_Property__c>();
        for(Opportunity opp:newOppList){
            if(opp.Common_area_wide_Wifi_Ready__c!=oldOppMap.get(opp.id).Common_area_wide_Wifi_Ready__c || 
                            opp.Property_Wide_Wifi_Ready__c!=oldOppMap.get(opp.id).Property_Wide_Wifi_Ready__c ||
                            opp.Wifi_Ready__c!=oldOppMap.get(opp.id).Wifi_Ready__c){
                oppIdsSet.add(opp.id);      
            }
        }
        if(!oppIdsSet.isEmpty()){
            for(Opportunity_Property__c oppProp:[SELECT Id, Opportunity__c,Property__c, Property__r.Common_area_wide_Wifi_Ready__c, Property__r.Property_Wide_Wifi_Ready__c, 
                                                            Property__r.Wifi_Ready__c,Property__r.Industry_Type__c FROM Opportunity_Property__c WHERE Opportunity__c IN: oppIdsSet AND 
                                                                Primary_Property__c = true LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){  
                opportunityPropertyMap.put(oppProp.Opportunity__c,oppProp) ;                        
            } 
            if(!opportunityPropertyMap.isEmpty()){
                for(Opportunity objopportunity:newOppList){
                    if(opportunityPropertyMap.containskey(objopportunity.id)){
                        if(objopportunity.Common_area_wide_Wifi_Ready__c!=(opportunityPropertyMap.get(objopportunity.id)).Property__r.Common_area_wide_Wifi_Ready__c||
                            objopportunity.Property_Wide_Wifi_Ready__c!=(opportunityPropertyMap.get(objopportunity.id)).Property__r.Property_Wide_Wifi_Ready__c || 
                            objopportunity.Wifi_Ready__c!=(opportunityPropertyMap.get(objopportunity.id)).Property__r.Wifi_Ready__c){
                            objopportunity.addError(Label.OppFieldsCannotBeEdited, false);  
                        }
                    }
                }
            }  
        }    
    }
         /*
    * Name : validateOpportunityFieldsOnUpdate
    * Para : List<Opportunity> newOppList
    * Return Value : None
    * Description : To validate Opportunity fields on updation of Opportunity.  Validation is for 'Marketing Rights' and 'Type of Video Equipment' fields.
    */ 
    public static void validateOpportunityFieldsOnUpdate(List<Opportunity> newOppList){
        Map<Id,Opportunity_Property__c> opportunityPropertyMap = new Map<Id,Opportunity_Property__c>();
        String industryType = MDU_Constants.BLANK_VALUE;
        String typeOfVideoEquipment = MDU_Constants.BLANK_VALUE;
        for(Opportunity_Property__c oppProp:[SELECT Id, Opportunity__c,Property__c,Property__r.Industry_Type__c FROM Opportunity_Property__c WHERE Opportunity__c IN: newOppList AND 
                                                                Primary_Property__c = true LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){  
                opportunityPropertyMap.put(oppProp.Opportunity__c,oppProp) ;                        
            } 
            if(!opportunityPropertyMap.isEmpty()){
                for(Opportunity objopportunity:newOppList){
                    if(opportunityPropertyMap.containskey(objopportunity.id)){
                        industryType=(opportunityPropertyMap.get(objopportunity.id)).Property__r.Industry_Type__c;
                        typeOfVideoEquipment=objopportunity.Type_of_Video_Equipment__c;
                         if((industryType!=MDU_Constants.EDUCATION && industryType!=MDU_Constants.MULTI_FAMILY && industryType!=MDU_Constants.SINGLE_FAMILY) && (objopportunity.Marketing_Rights_for_CD__c!=null||
                                                    objopportunity.Marketing_Rights_for_HSI__c!=null ||objopportunity.Marketing_Rights_for_Video__c!=null)){
                                 objopportunity.addError(Label.Marketing_Rights_are_only_for_specified_LOBs, false);
                        }
                        if(industryType ==MDU_Constants.SINGLE_FAMILY && typeOfVideoEquipment==MDTA){
                            objopportunity.addError(Label.Opportunity_page_Type_of_video_equipement_SFU, false);  
                        }
                        if(industryType==MDU_Constants.HOSPITALITY && (typeOfVideoEquipment==DTA || typeOfVideoEquipment==DCT || typeOfVideoEquipment==DTA_AND_DCT)){  
                            objopportunity.addError(Label.Opportunity_page_Type_of_video_equipement_Hospitality, false);  
                        }
                        if(industryType==MDU_Constants.HEALTHCARE && (typeOfVideoEquipment==DCT || typeOfVideoEquipment==DTA_AND_DCT)){
                            objopportunity.addError(Label.Opportunity_page_Type_of_video_equipement_Healthcare, false);   
                        }
                    }
                }
            }     
    }
     /*
    * Name : validateOpportunityFieldsOnInsert
    * Para : List<Opportunity> newOppList
    * Return Value : None
    * Description : To validate Opportunity fields on insertion of Opportunity.  Validation is for 'Marketing Rights' and 'Type of Video Equipment' fields.
    */ 
    public static void validateOpportunityFieldsOnInsert(List<Opportunity> newOppList){
        Set<Id> propIdSet =  new Set<Id>();
        Map<Id,MDU_Property__c> propertyMap = new map<Id,MDU_Property__c>();
        String industryType= MDU_Constants.BLANK_VALUE;
        String typeOfVideoEquipment= MDU_Constants.BLANK_VALUE;
        for(Opportunity opp : newOppList){
            propIdSet.add(opp.Property__c);
        }
        for(MDU_Property__c prop : [SELECT Id,Industry_Type__c FROM MDU_Property__c WHERE Id IN: propIdSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            propertyMap.put(prop.id,prop);
        }
        for(Opportunity opp : newOppList){
            if(propertyMap.containskey(opp.Property__c)){
                industryType = (propertyMap.get(opp.Property__c)).Industry_Type__c;
                typeOfVideoEquipment = opp.Type_of_Video_Equipment__c;
                if((industryType!=MDU_Constants.EDUCATION && industryType!=MDU_Constants.MULTI_FAMILY && industryType!=MDU_Constants.SINGLE_FAMILY) && (opp.Marketing_Rights_for_CD__c!=null||opp.Marketing_Rights_for_HSI__c!=null ||opp.Marketing_Rights_for_Video__c!=null)){
                    opp.addError(Label.Marketing_Rights_are_only_for_specified_LOBs, false);
                }
                if(industryType==MDU_Constants.SINGLE_FAMILY && typeOfVideoEquipment==MDTA){
                            opp.addError(Label.Opportunity_page_Type_of_video_equipement_SFU, false); 
                        }
                        if(industryType==MDU_Constants.HOSPITALITY && (typeOfVideoEquipment==DTA || typeOfVideoEquipment==DCT || typeOfVideoEquipment==DTA_AND_DCT)){
                            opp.addError(Label.Opportunity_page_Type_of_video_equipement_Hospitality, false); 
                        }
                        if(industryType==MDU_Constants.HEALTHCARE && (typeOfVideoEquipment==DCT || typeOfVideoEquipment==DTA_AND_DCT)){
                            opp.addError(Label.Opportunity_page_Type_of_video_equipement_Healthcare, false);  
                        }
                
            }
            
        }   
    }
}