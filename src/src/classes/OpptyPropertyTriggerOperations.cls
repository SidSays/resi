/**
* Class Name: opptyPropertyTriggerOperations
* Author: Abhishek Mathur, Accenture
* Date: 26-December-2014 
* Requirement # Request Id: USer Story 
* Last Modified By: Sagar Gurav
* Description: 1. To set Property as Primary Property if Opportunity has not other Property associated.
               2. To validate that no property, associated with any other open opportunity, can be added to an Opportunity
               3. To validate industry type and property type of secondary property should be same as the industry and property type of primary property of associated opportunity 
               4. To set new primary property on existing opportunity property before deleting opportunity property which has primary property on it
* Last Modified: 5/23/2017 by Radhika Bansal for US1110566 - System Engineering: “Entity is deleted” error is thrown in DeletePropertyBatch.   
* Last Modified By: Deepika Jain
* Last Modified Date : 14th Aug 2017
* User story  : US1167685(XC - Wifi Ready Fields in Opportunity).
* Desciption : Adding method "updateOppFieldsOnPrimaryPropDelete".This method is used to update the fields on Opportunity when the same fields on Property are updated when the primary property is deleted.
*/

public class OpptyPropertyTriggerOperations{   
    
    private static final String CLOSED = 'CLOSED'; 
    private static final String SEMICOLON = ';';    
    private static final string CLOSE_WON_STAGE = 'Closed Won';
    private static final string CLOSE_LOST_STAGE = 'Closed Lost';
    public static final String CONTRACT_DOCUMENT_REVIEW = 'Contract Document Review';
    private static final string REGION_SALES_REP_TYPE = 'Region';
    private static final string XC_ANALYST = 'XC Analyst';
    private static final string XC_MANAGER = 'XC Manager';
    private static final string XFINITY_CAR_MANAGER = 'Xfinity CAR Manager';
    /*
    * To set Property as Primary Property if Opportunity has not other Property associated.
    * To validate that no property, associated with any other open opportunity, can be added to an Opportunity.
    * To validate property type of secondary property should be same as the property type of primary property of associated opportunity.
    */
   public static void setPrimaryPropeertyOrFireValidation(){ 
        List<Opportunity_Property__c> lOpportunityProperties = Trigger.New;        
        Set<Id> setPropertyId = new Set<Id>();
        Set<Id> setSPId = new Set<Id>();
        Set<String> propTypeSet = new Set<String>();
        Map<Id, String> mapPropertyType = new Map<Id, String>();
        Map<Id, String> mapIndustryType = new Map<Id, String>();
        Map<id, Set<string>> mapOptySetAddress = new Map<id, Set<string>>();
        Map<id, string> mapAddresstoOpenSP = new Map<id, string>();
        Map<id, string> mapOptyPPPropertyType = new Map<id, string>();
        Map<id, string> mapOptyPPIndustryType = new Map<id, string>();       
        
        /*
        *   Opp_Prop_Trigger_Property_Types contains 'CONDOMINIUM';'CONDOMINIUM-DETACHED';'TOWN HOMES'
        */
        /* for(String objStr : System.Label.Opp_Prop_Trigger_Property_Types.split(SEMICOLON)){
            propTypeSet.add(objStr.toUpperCase());
        }
        */
        for(String objStr : System.Label.Prop_Lookup_PropTypeInCCT.split(SEMICOLON)){
            propTypeSet.add(objStr.trim().toUpperCase());
        }
        
        for(Opportunity_Property__c opptyProperty:lOpportunityProperties){
            setPropertyId.add(opptyProperty.Property__c);   
            setSPId.add(opptyProperty.Opportunity__c);               
        }
        
        /*
        * Map mapPropertyType 
        */
        for(MDU_Property__c property:[Select Property_Type__c, Industry_Type__c from MDU_Property__c
                                    where id In:  setPropertyId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            mapPropertyType.put(property.Id, property.Property_Type__c );
            mapIndustryType.put(property.Id, property.Industry_Type__c );
        }
        for(Opportunity_Property__c opptyProperty:lOpportunityProperties){
        /*
        * Opportunity doesn't have any property
        * Property not associated with any open Opportunity
        */
        for(Opportunity_Property__c opptyProperty2:[select Id, Primary_Property__c, Property__c , 
                                                    Property__r.Property_Type__c, Property__r.Industry_Type__c, Opportunity__c, Opportunity__r.StageName  
                                                    FROM Opportunity_Property__c WHERE Property__c IN: setPropertyId OR Opportunity__c IN : setSPId 
                                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){                                      
            Set<string> tempSet2 = new Set<string>();
            if(mapOptySetAddress.containsKey(opptyProperty2.Opportunity__c)){
                tempSet2 = mapOptySetAddress.get(opptyProperty2.Opportunity__c);                    
            }
            tempSet2.add(opptyProperty2.Property__c);
            mapOptySetAddress.put(opptyProperty2.Opportunity__c, tempSet2);
            
            /*
            *Create map of Primary Property PRoperty Type and opportunity
            */
            if(opptyProperty2.Primary_Property__c == true){
                mapOptyPPPropertyType.put(opptyProperty2.Opportunity__c, opptyProperty2.Property__r.Property_Type__c);
                mapOptyPPIndustryType.put(opptyProperty2.Opportunity__c, opptyProperty2.Property__r.Industry_Type__c);
            }
            if(opptyProperty2.Opportunity__r.StageName.toUpperCase().contains(CLOSED)){
               
            }
            else{
                mapAddresstoOpenSP.put(opptyProperty2.Property__c, opptyProperty2.Opportunity__c);
            }   
        }        
            Set<string> tempSet = new Set<string>();            
            if(mapAddresstoOpenSP.containsKey(opptyProperty.Property__c)){
                opptyProperty.addError(System.Label.Opp_Prop_Trigger_Open_Opp_Err);
            }
            else{
                if(mapOptySetAddress.containsKey(opptyProperty.Opportunity__c)){
                    tempSet = mapOptySetAddress.get(opptyProperty.Opportunity__c);                    
                    if(tempSet.isEmpty()){                     
                        opptyProperty.Primary_Property__c = true;
                        //opptyProperty.OpptyPropertyID__c = String.valueof(opptyProperty.Opportunity__c) + String.valueof(opptyProperty.Property__c);
                    }
                    else{

                    /*
                    * Check Industry Type and Property Type of the new Property with Primary Property of Opportunity   
                    */                         
                        String propertyType = mapPropertyType.get(opptyProperty.Property__c);  
                        String industryType = mapIndustryType.get(opptyProperty.Property__c);       
                        string primaryPropertype = mapOptyPPPropertyType.get(opptyProperty.Opportunity__c); 
                        string primaryIndustrytype = mapOptyPPIndustryType.get(opptyProperty.Opportunity__c);  
                        //Industry type of property to be added should be same as Industry type of primary property 
                        if(industryType.trim().toUpperCase() == primaryIndustrytype.trim().toUpperCase()){                            
                            //Property type of Secondary property should be within propTypeSet if Property Type of primary property is in propTypeSet Or Vice Versa
                            if((propTypeSet.contains(propertyType.trim().toUpperCase()) 
                                && !propTypeSet.contains(primaryPropertype.trim().toUpperCase())) 
                               ||  (propTypeSet.contains(primaryPropertype.trim().toUpperCase())  
                                && !propTypeSet.contains(propertyType.trim().toUpperCase()))){
                                opptyProperty.addError(System.Label.Opp_Prop_Trigger_Primary_PropType_Err);
                            }
                                                                                                       
                        }else{
                            opptyProperty.addError(System.Label.Opp_Prop_Trigger_Primary_IndustryType_Err);
                        }
                        
                    }
                }
                else{             
                       opptyProperty.Primary_Property__c = true;
                       Set<string> temp = new Set<string>();
                       temp.add(opptyProperty.Property__c);
                       mapOptySetAddress.put(opptyProperty.Opportunity__c, temp);
                       mapOptyPPIndustryType.put(opptyProperty.Opportunity__c, mapIndustryType.get(opptyProperty.Property__c));
                       mapOptyPPPropertyType.put(opptyProperty.Opportunity__c, mapPropertyType.get(opptyProperty.Property__c));                     
                       //opptyProperty.OpptyPropertyID__c = String.valueof(opptyProperty.Opportunity__c) + String.valueof(opptyProperty.Property__c);
                }
            }
        }   
    }   
    
    
    /*
    * Set oldest opportunity property as primary if earlier primary property is deleted.
    * Validation to throw if ECM_id field is not present on Opp Prop.
    * Validation to throw if trying to delete last Opp Prop which is primary. 
    */
    public static void setPrimaryPropeertyOnDelete() {
        Set<id> oppPropertydDeleteSet = new Set<id>();
        Set<id> opportunityWithPrimaryPropSet = new Set<id>();
        List<Opportunity_Property__c> oppPropToBeUpdatedList = new List<Opportunity_Property__c>();
        Map<id,Opportunity_Property__c> oppPropOldMap = (Map<id,Opportunity_Property__c>) Trigger.oldMap;
        Map<Id, List<Opportunity_Property__c>> oppIdToOppPropListWithNoPrimProp = new Map<Id, List<Opportunity_Property__c>>();
        
        /*
        * Creating set of opportunity property which are primary & are about to be deleted
        * Creating set of opportunities which has primary opp prop set on it.
        */
        for(Opportunity_Property__c OppPropertytemp : (List<Opportunity_Property__c>) Trigger.Old){
            if(oppPropOldMap.get(OppPropertytemp.id).Primary_Property__c){
                oppPropertydDeleteSet.add(OppPropertytemp.id);
                opportunityWithPrimaryPropSet.add(OppPropertytemp.Opportunity__c); 
            }               
        }
       
       /*
        * Creating map of opportunity to list of opportunity property which has no primary property in it.
        */
        for(Opportunity_Property__c oppPropInst : [Select id,CreatedDate,Primary_Property__c,Opportunity__c,Name,ECM__c from Opportunity_Property__c where id NOT in:oppPropertydDeleteSet AND Opportunity__c IN:opportunityWithPrimaryPropSet]){
            List<Opportunity_Property__c> tempList = oppIdToOppPropListWithNoPrimProp.get(oppPropInst.Opportunity__c);
            if(tempList == null){
                tempList = new List<Opportunity_Property__c>();
            }  
            tempList.add(oppPropInst);
            oppIdToOppPropListWithNoPrimProp.put(oppPropInst.Opportunity__c, tempList);
        }
        
        /*
        * To assign oldest opportunity property as primary property. 
        */
        if(!oppIdToOppPropListWithNoPrimProp.IsEmpty()){
            for(Id oppId : oppIdToOppPropListWithNoPrimProp.keyset()){
                if(!(oppIdToOppPropListWithNoPrimProp.get(oppId)).isEmpty()){
                    Opportunity_Property__c temp = null;
                    for(Opportunity_Property__c oppPropInst:  oppIdToOppPropListWithNoPrimProp.get(oppId)){
                        if(temp == null){
                            temp = oppPropInst;
                            temp.Primary_Property__c = true;
                            oppPropToBeUpdatedList.add(temp);                        
                        }
                        else{
                            if(oppPropInst.CreatedDate < temp.CreatedDate){
                                temp = oppPropInst;
                                temp.Primary_Property__c = true;
                                oppPropToBeUpdatedList.add(temp);                            
                            }                           
                        }                      
                    }
                }   
            }
        }
        if(!oppPropToBeUpdatedList.isEmpty()){
          Database.update(oppPropToBeUpdatedList,false);
          updateOppFieldsOnPrimaryPropDelete(oppPropToBeUpdatedList); // Added as part of US1167685. Added by Deepika Jain
        }
        
        
        
        /*
        * Cannot delete opportunity property which has no other opportunity property on it.
        */
        for(Opportunity_Property__c OppPropertytemp :(List<Opportunity_Property__c>) Trigger.Old){
            if(!oppIdToOppPropListWithNoPrimProp.containsKey(OppPropertytemp.Opportunity__c) && oppPropertydDeleteSet.contains(OppPropertytemp.id)){
                OppPropertytemp.addError(System.Label.Opp_Prop_Trigger_Primary_Delete_Err); 
            }
        }
        
        /*
        * Cannot delete opportunity property which has ECM Contract ID field present on it.
        */
        for(Opportunity_Property__c OppPropertytemp :(List<Opportunity_Property__c>) Trigger.Old){
            if(OppPropertytemp.ECM__c != null){
                OppPropertytemp.addError(System.Label.Opp_Prop_Trigger_ECM_Err); 
            }
        }
    }
    
    
    /*
    * Name : setOpptyPortFolioName
    * Para : None
    * Return Value : None
    * Description : Show validation message to have unique  Portfolio Name on associating more property records on opportunity.  
    */
    public static void setOpptyPortFolioName(){
        
        String validationMessage = System.Label.Portfolio_Name_Require_Validation_Message ;
        Set<Id> opportunityIdSet = new Set<Id>();       
        Map<Id,string> idOpportunityMap = new Map<Id,string>();
        List<Opportunity_Property__c> opportunityPropertyList = (List<Opportunity_Property__c>)Trigger.New;
        //set opportunityIdSet with Opportunity Id
        for(Opportunity_Property__c opptyPropertyTemp : opportunityPropertyList){
            opportunityIdSet.add(opptyPropertyTemp.Opportunity__c);
        }       
        //Create map with opportunity Id having Primary Property and Portfolio Name
        for(Opportunity_Property__c opptyProperty : [Select Id , Opportunity__c ,Opportunity__r.Sales_Portfolio_Name__c
                                                     FROM Opportunity_Property__c
                                                     WHERE Primary_Property__c = true AND Opportunity__c IN : opportunityIdSet
                                                     LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())] ){                                                 
            idOpportunityMap.put(opptyProperty.Opportunity__c, opptyProperty.Opportunity__r.Sales_Portfolio_Name__c );
        }       
        for(Opportunity_Property__c oppProperty : opportunityPropertyList){        
            if(idOpportunityMap.containsKey(oppProperty.Opportunity__c) && String.isBlank(idOpportunityMap.get(oppProperty.Opportunity__c))){               
                oppProperty.addError(validationMessage);
            }
        }
                                                                
    }
    
    
     /*
    * Name : activeOpptyFlagOnProperty
    * Para : None
    * Return Value : None
    * Description : This method set active oppty flag on property base on insertion of opty property record.  
    */
    public static void activeOpptyFlagOnProperty(){
        
        Set<Id> opportunityIdSet = new Set<Id>();        
        List<Opportunity> opportunityList = new List<Opportunity>();               
        //get oppty Id
        For(Opportunity_Property__c optyProperty :  (List<Opportunity_Property__c>) Trigger.New){
            opportunityIdSet.add(optyProperty.Opportunity__c);
        }       
        //get Oppty objects
        for(Opportunity opptyTemp : [SELECT Id, StageName, Date_in_Stage__c, RecordTypeId 
                                        FROM Opportunity WHERE Id IN : opportunityIdSet]){
            opportunityList.add(opptyTemp);
        }             
        //Call method use on OpportunityTriggerOperations class use for opptyTrigger 
        if(!opportunityList.isEmpty()){
            OpportunityTriggerController.setActiveOpportunityAndUpdateClosedFields(opportunityList, null);
        }              
    }
    
    /*
    * Name : activeOpptyFlagOnPropertyForDelete
    * Para : None
    * Return Value : None
    * Description : This method set active oppty flag on property base on deletion of Oppty Property.
       Set flag to true if any property associated opportunity is open   
    * Updated: 5/23/2017 by Radhika Bansal for US1110566 - System Engineering: “Entity is deleted” error is thrown in DeletePropertyBatch.   
    */
    public static void activeOpptyFlagOnPropertyForDelete(){
        Set<Id> propertyIdSet = new Set<Id>();      
        List<MDU_Property__c> propertyList = new List<MDU_Property__c>();   
        //get Property Id
        for(Opportunity_Property__c optyProperty :  (List<Opportunity_Property__c>) Trigger.Old){
            propertyIdSet.add(optyProperty.Property__c);            
        }
        //fetch opportunities associated to property and check opportunities stage to set flag 
        for(MDU_Property__c propertyObject : [  SELECT Id,Active_Opportunity__c, 
                                                (SELECT Id,Property__C,Opportunity__c, Opportunity__r.StageName,
                                                 Opportunity__r.Name FROM Opportunity_Properties__r) 
                                                FROM MDU_Property__c                                                      
                                                WHERE ID  IN:propertyIdSet
                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
           boolean checkActive = false;
           //Start Added null check for US1110566
            if(propertyObject != null){
               for(Opportunity_Property__c optyPropetty : propertyObject.Opportunity_Properties__r){                                              
                    if(!CLOSE_WON_STAGE.equalsIgnoreCase(optyPropetty.Opportunity__r.StageName) 
                        && !CLOSE_LOST_STAGE.equalsIgnoreCase(optyPropetty.Opportunity__r.StageName)) {                    
                            checkActive = true;                                              
                    }
                }
                   
               if(propertyObject.Active_Opportunity__c != checkActive){
                    propertyObject.Active_Opportunity__c = checkActive;
                    propertyList.add(propertyObject);
                } 
            }   
            //End of if statement in the null check         
        }
        //Start Added null check for US1110566
        if(propertyList.size() >0){
            Database.update(propertyList,false);                             
        }
        //End of if statement in the null check 
    }
    /*
    * Name : updateOppFieldsOnPrimaryPropDelete
    * Para : List<Opportunity_Property__c> oppPropList
    * Return Value : None
    * Description : To update the fields on Opportunity whenever the primary property is deleted and next property is assigned as primary property.  
    */
    public static void updateOppFieldsOnPrimaryPropDelete(List<Opportunity_Property__c> oppPropList){
        List<Opportunity> oppList = new List<Opportunity>();
        Map<String,Opportunity_Property__c> oppIdVSOppPropMap= new Map<String,Opportunity_Property__c>();
        try{
        	for(Opportunity_Property__c oppProp: [SELECT Id, Opportunity__c, Property__c,Property__r.Common_area_wide_Wifi_Ready__c,Property__r.Property_Wide_Wifi_Ready__c,
                              Property__r.Wifi_Ready__c from Opportunity_Property__c WHERE Id IN: oppPropList]){
            	oppIdVSOppPropMap.put(oppProp.Opportunity__c,oppProp);
        	}                                  
        	if(!oppIdVSOppPropMap.isEmpty()){
            	for(Opportunity opp:[SELECT Id, Property__c, Common_area_wide_Wifi_Ready__c,Property_Wide_Wifi_Ready__c, Wifi_Ready__c FROM Opportunity 
            											WHERE Id IN: oppIdVSOppPropMap.keySet() AND StageName != :CLOSE_WON_STAGE 
            												LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){             
               		if(oppIdVSOppPropMap.containskey(opp.id)){
                			opp.Common_area_wide_Wifi_Ready__c = (oppIdVSOppPropMap.get(opp.id)).Property__r.Common_area_wide_Wifi_Ready__c;
                			opp.Property_Wide_Wifi_Ready__c = (oppIdVSOppPropMap.get(opp.id)).Property__r.Property_Wide_Wifi_Ready__c;
                	opp.Wifi_Ready__c = (oppIdVSOppPropMap.get(opp.id)).Property__r.Wifi_Ready__c;
                		oppList.add(opp);
            		}
            	}
        		if(!oppList.isEmpty()){
        			OpportunityTriggerHelper.allowOppValidation = false;
            		Database.update(oppList,false);
        		}
        	}
    	}
    	catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }  
    }
}