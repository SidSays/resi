/************************************************************************************************************************************************************
Name: Mdu_WriteBackHelper 
Description: This class is used as a Helper class for Mdu_WriteBackContract
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
25 March 2015 Comcast  
*************************************************************************************************************************************************************/
public class Mdu_WriteBackHelper{
    
    //private static MDU_ContractWriteBack.BulkServicesDTO bulkServiceObject = new MDU_ContractWriteBack.BulkServicesDTO();
    private static final string serviceType = 'Video Only';
        
    /* Method Name : fetchPropertySFIdForLegacyId 
    *  Description :  Fetch (Property)SFDC Id For Legacy Id And insert SFDC id to contractPropertyIdUpdateMap and return that Map
    *  Parameter   : Map<string,string> contractIdLegacyMap
    *  Return Type : contractPropertyIdUpdateMap Map
    */
    public static Map<string,string> fetchPropertySFIdForLegacyId(Map<string,string> contractIdLegacyMap){
        set<string> propertyLegacyIdSet = new set<string>();
        Map<string,string> contractPropertyIdUpdateMap = new Map<string,string>();
        //Create set of legacy id if exists in contractIdLegacyMap.
        for(String contractTempId : contractIdLegacyMap.keySet()){
            String propertyLegecyId = contractIdLegacyMap.get(contractTempId);            
            //Check condition for Legacy Id
            if(propertyLegecyId.isNumeric() && (propertyLegecyId.length() != 15 || propertyLegecyId.length() != 18)) {
                propertyLegacyIdSet.add(propertyLegecyId);
            }else{
                contractPropertyIdUpdateMap.put(contractTempId,propertyLegecyId);
            }
        }
        
        if(propertyLegacyIdSet.size() > 0){
            //Fetch Map Of LegacyId And SFDC Id
            Map<string, string> contractLegacyIdMap = getSfdcPropertyId(propertyLegacyIdSet);
            //Create set for LegacyId
            Set<String> legacyIdSet = contractLegacyIdMap.keyset();
            for(string contrId : contractIdLegacyMap.keySet()){
                //create map for legacy Id & SF Id.
                if(legacyIdSet.contains(contractIdLegacyMap.get(contrId)) 
                    && !string.isBlank(contractLegacyIdMap.get(contractIdLegacyMap.get(contrId)))){
                    contractPropertyIdUpdateMap.put(contrId,contractLegacyIdMap.get(contractIdLegacyMap.get(contrId)));
                } 
            }
        }
        return contractPropertyIdUpdateMap;
    }
    
    /* Method Name : fetchOpportunitySFIdForLegacyId 
    *  Description :  Fetch (Opportunity)SFDC Id For Legacy Id And insert SFDC id to contractPropertyIdUpdateMap and return that Map
    *  Parameter   : Map<string,string> contractIdLegacyMap
    *  Return Type : contractPropertyIdUpdateMap Map
    */
    public static Map<string,string> fetchOpportunitySFIdForLegacyId(Map<string,string> contractOpportunityIdMap){
        /* 
        * Replace Opportunity Legacy Id By SFDC ID            
        */ 
        Map<string,string> contractOpportunityIdUpdateMap = new Map<string,string>();
        set<string> opportunityLegacyIdSet = new set<string>();         
        for(string contractId :  contractOpportunityIdMap.keyset()){
            string opportLegacyOrSFDCId = contractOpportunityIdMap.get(contractId);
            //Check for legacy Id
            if(opportLegacyOrSFDCId.isNumeric() && (opportLegacyOrSFDCId.length() != 15 || opportLegacyOrSFDCId.length() != 18)) { 
                opportunityLegacyIdSet.add(opportLegacyOrSFDCId);
            }else{
                contractOpportunityIdUpdateMap.put(contractId , opportLegacyOrSFDCId);               
            }
        }       
        
        //Get SFDC Opportunity Id Set  
        if(opportunityLegacyIdSet.size() > 0){
            Map<string,string> opportunityLegacyIdMap = getOpportunityIdFromDirect(opportunityLegacyIdSet);
            set<string> legacyIdForOpportunitySet = opportunityLegacyIdMap.keyset();
            for(string contractId : contractOpportunityIdMap.keyset()){
                //create map for legacy Id & SF Id. 
                if(legacyIdForOpportunitySet.contains(contractOpportunityIdMap.get(contractId))){
                    contractOpportunityIdUpdateMap.put(contractId,opportunityLegacyIdMap.get(contractOpportunityIdMap.get(contractId)));
                }
            }
        }
        return contractOpportunityIdUpdateMap;
        
    }
    
    /* Method Name : fetchOpportunityUpdateList 
    *  Description : This method return Opportunity List with updated stage name
    *  Parameter   : list<string> opportunityIdList
    *  Return Type : List<Opportunity> 
    */
    public static  Map<Id, Opportunity> fetchOpportunityUpdateList(list<string> opportunityIdList){
        Map<Id, Opportunity> opportunityIdObjUpdateMap = new Map<Id, Opportunity>();
        for(Opportunity opp : [SELECT StageName , Date_in_Stage__c, Type 
                                               FROM Opportunity WHERE Id IN : opportunityIdList
                                               LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    opp.StageName = MDU_Constants.OPPORTUNITY_STAGE_CLOSE_WON;                   
                    opportunityIdObjUpdateMap.put(opp.Id,opp);
        }  
        return  opportunityIdObjUpdateMap;
    }
    
    /* Method Name : fetchAttachmentList 
    *  Description : This method return List of attachment against parent id pass in contractSfdcIdMap 
    *  Parameter   : contractIdAttachmentMap , contractSfdcIdMap
    *  Return Type : List<Attachment>
    */
    public static  List<Attachment> fetchAttachmentList(Map<string,Attachment> contractIdAttachmentMap
                              , Map<string,string> contractSfdcIdMap){
        List<Attachment> attachmentFinalList = new List<Attachment>();
        for(string contractIdForAttachment : contractIdAttachmentMap.keySet()){                    
            Attachment attachmentObj = contractIdAttachmentMap.get(contractIdForAttachment);                                   
            if(attachmentObj != null && !string.IsBlank(contractSfdcIdMap.get(contractIdForAttachment))){
                attachmentObj.ParentId = contractSfdcIdMap.get(contractIdForAttachment);
                attachmentFinalList.add(attachmentObj);
            }           
        }
        return attachmentFinalList ;
    }
    
     /* Method Name : fetchPropertyFeesList 
    *  Description : This method set contract id to fees and return List of Property_Fees__c 
    *  Parameter   : contractIdPropertyFeeMap , contractSfdcIdMap
    *  Return Type : List<Property_Fees__c>
    */
    public static  List<Property_Fees__c> fetchPropertyFeesList(Map<string,List<Property_Fees__c>> contractIdPropertyFeeMap
                                  , Map<string,string> contractSfdcIdMap){
        List<Property_Fees__c> propertyFeeList = new List<Property_Fees__c>();
        for(string contractIdForPropertyFee : contractIdPropertyFeeMap.keySet()){
            List<Property_Fees__c> propertyFeeTempList = new List<Property_Fees__c>();          
            for(Property_Fees__c propertyFeeObject : contractIdPropertyFeeMap.get(contractIdForPropertyFee)){                    
                if(propertyFeeObject != null && !string.IsBlank(contractSfdcIdMap.get(contractIdForPropertyFee))){
                    propertyFeeObject.Contract__c = contractSfdcIdMap.get(contractIdForPropertyFee);
                    propertyFeeTempList.add(propertyFeeObject);
                }                       
            }           
            
            if(propertyFeeTempList != null || !propertyFeeTempList.IsEmpty()){
                propertyFeeList.addAll(propertyFeeTempList);
            }           
        }
        return propertyFeeList;
    }
    
     /* Method Name : fetchContractedBulkServiceList 
    *  Description : This method set contract id to Contracted bulk service object and return List of Contracted_Bulk_Service__c with its contract id
    *  Parameter   : contractIdBulkServiceMap , contractSfdcIdMap
    *  Return Type : List<Contracted_Bulk_Service__c>
    */
    public static  List<Contracted_Bulk_Service__c> fetchContractedBulkServiceList(Map<string,List<Contracted_Bulk_Service__c>> contractIdBulkServiceMap
                                                                                 , Map<string,string> contractSfdcIdMap){
        List<Contracted_Bulk_Service__c> contractedBulkServiceList = new List<Contracted_Bulk_Service__c>();
        for(string contractIdForBulkService : contractIdBulkServiceMap.keySet()){
            List<Contracted_Bulk_Service__c> contractedBulkServiceObjectList = contractIdBulkServiceMap.get(contractIdForBulkService);                
            if(!contractedBulkServiceObjectList.isEmpty()){
                for(Contracted_Bulk_Service__c bulkServiceObject : contractedBulkServiceObjectList){
                    if(!string.IsBlank(contractSfdcIdMap.get(contractIdForBulkService))){
                        bulkServiceObject.Contract__c = contractSfdcIdMap.get(contractIdForBulkService);
                        contractedBulkServiceList.add(bulkServiceObject);
                    }
                }
            }                  
        }
        return contractedBulkServiceList;
    }
    
    
    /* Method Name : getSfdcPropertyId
    *  Description : This method get legacy id of property and fetch sfdc id for same in Map
    *  Parameter   : propertyLegacySet of LegacyId Set
    *  Return Type : Map<string,string> of LegacyId And SFDC Id 
    */
    public static  Map<string,string> getSfdcPropertyId(set<string> propertyLegacySet) {
        Map<string,string> legacyPropertySfdcIdMap = new Map<string,string>();
        for(Mdu_Property__c property : [SELECT id, Complex_ID__c
                                        FROM Mdu_Property__c WHERE Complex_ID__c IN : propertyLegacySet
                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    legacyPropertySfdcIdMap.put(property.Complex_ID__c,property.id);  
        }
        return legacyPropertySfdcIdMap;
    }
    
    public static  Map<string,Mdu_Property__c>  fetchPropertyIdObjectMap(Set<String> propertyIdSet){
        Map<string,Mdu_Property__c> propertyIdObjectMap = new Map<string,Mdu_Property__c>();
        for(Mdu_Property__c property : [SELECT id,Industry_Type__c
                                        FROM Mdu_Property__c WHERE Id  IN : propertyIdSet
                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    propertyIdObjectMap.put(property.Id,property);  
        }
        return propertyIdObjectMap;  
    }
    
    
    /* Method Name : getOpportunityIdFromDirect
    *  Description : This method get legacy id of opportunity and fetch sfdc id for same in Map
    *  Parameter   : propertyLegacySet of LegacyId Set
    *  Return Type : Map<string,string> of LegacyId And SFDC Id 
    */
    public static Map<string,string> getOpportunityIdFromDirect(set<string> opportunityLegacySet) {
        Map<string,string> opportunutyLegacySFDCIdset = new Map<string,string>();
        for(Opportunity opportunity : [SELECT id, MDU_Opportunity_ID__c
                                       FROM Opportunity WHERE MDU_Opportunity_ID__c IN : opportunityLegacySet
                                       LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    opportunutyLegacySFDCIdset.put(opportunity.MDU_Opportunity_ID__c,opportunity.id);  
        }
        return opportunutyLegacySFDCIdset;
    } 
    
    
    /* Method Name : getUpdatedContractedServiceAndContract
    *  Description : This method create contracted bulk service and update Contract record . 
    *  Parameter   : contractIdBulkServiceList and contractIdObjectMap
    *  Return Type : Map<Id,List<Contracted_Bulk_Service__c>>
    */
    /*
    public static Map<Id,List<Contracted_Bulk_Service__c>> getUpdatedContractedServiceAndContract(Map<String,MDU_ContractWriteBack.BulkServicesDTO> contractIdBulkServiceList, Map<String, Contract__c> contractIdObjectMap){
        Map<Id,List<Contracted_Bulk_Service__c>> contactLegcyIdBulkServListMap = new Map<Id,List<Contracted_Bulk_Service__c>>();
        
        for(String legacyContractId : contractIdObjectMap.keyset()){
            if(contractIdBulkServiceList.get(legacyContractId) != null){
                    List<Contracted_Bulk_Service__c> bulkServiceList = SetUpBulkServices(contractIdBulkServiceList.get(legacyContractId), contractIdObjectMap.get(legacyContractId));
                    if(!bulkServiceList.isEmpty()){
                        contactLegcyIdBulkServListMap.put(legacyContractId, bulkServiceList);
                    }
            }           
        }                  
        return contactLegcyIdBulkServListMap;
    }
    */
  
  
   
}