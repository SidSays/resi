/**************************************************************************************************
Name : ContractTriggerOperations
Date : 18 December 2014
User Story : 009
Description : This class use to change data status,video status,voice status filed on Address(Property Xffinity) base on status on Contract  
Author : Ashish Sonawane
***************************************************************************************************/
public class ContractTriggerOperations
{
  
    //Data Member
    private static final string BULK_BILLING_TYPE_DATA = System.Label.PROP_DataBillingType_Bulk;
    private static final string BULK_BILLING_TYPE_VIDEO = System.Label.PROP_VideoBillingType_Bulk;
    private static final string BULK_BILLING_TYPE_VOICE = System.Label.PROP_VoiceBillingType_Bulk;
    private static final string RETAIL_BILLING_TYPE_DATA = System.Label.PROP_DataBillingType_Retail;
    private static final string RETAIL_BILLING_TYPE_VIDEO = System.Label.PROP_VideoBillingType_Retail;
    private static final string RETAIL_BILLING_TYPE_VOICE = System.Label.PROP_VoiceBillingType_Retail;
    private static final String DATA_BULK = System.Label.Contract_DataBillingType_Bulk;
    private static final String VIDEO_BULK = System.Label.Contract_VideoBillingType_Bulk;
    private static final String VOICE_BULK = System.Label.Contract_VoiceBillingType_Bulk;
    private static final String DATA_RETAIL = System.Label.Contract_DataBillingType_Retail;
    private static final String VIDEO_RETAIL = System.Label.Contract_VideoBillingType_Retail;
    private static final String VOICE_RETAIL = System.Label.Contract_VoiceBillingType_Retail;
    private static final string OBJECT_TYPE = 'Contract__c';
    private static final string LABEL_NAME_SPLIT = ';';
    private static final string CONTRACT_LOB = 'Yes';
    private static final string CONTRACT_LOB_NO = 'No';
    private static final string BLANK_VALUE = '';
    private static final string NO_CONTRACT = System.Label.PROP_DataContractStatus_NoContract;
    private static final String MONTHS = System.Label.Contract_ConTermUnit_Months;
    private static final String YEARS = System.Label.Contract_ConTermUnit_Years;
    private static final Map<Id,Id> propertyContractIdMap = new Map<Id,Id>();
   
   /*
    * Name : afterContractInsertOperation  
    * Description : Use to write logic to change status on Property(Parent) page base on child page Contract__c(Child) New custom object for MDU module  
    * Parameters : None
    * Return : void      
    */ 
    public static void afterContractInsertOperation() { 
        //Get Developer Name Of Record Type And Fetch Record Only For That Record Type             
        string labelName = System.Label.XfinityContractRecordType; 
        Set<String> recordTypeSet = new Set<String>();              
        Set<Id> addressIdSet = new Set<Id>();
        Map<Id,Contract__c> propertyIdContractMap = new Map<Id,Contract__c>();
        List<Contract__c> lContractList = Trigger.New;   
        Set<Id> contractIdSet = new Set<Id>(); 
        Map<id,String> contractIdStatusMap = new Map<id,String>();          
        Map<id,Contract__c> mapOfOldContract = new Map<id,Contract__c>();               
        Map<id,MDU_Property__c> propertyMap = new Map<id,MDU_Property__c>(); 
        Map<id,WrapperContract> propertyIdWrapperMap = new Map<id,WrapperContract>();     
        
        if(!string.isBlank(labelName)){
            for(String str: labelName.split(LABEL_NAME_SPLIT)){
                recordTypeSet.add(Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get(str).getRecordTypeId());                
            }
        }               
                                       
        if(trigger.isUpdate){
            mapOfOldContract = (Map<id,Contract__c>)Trigger.OldMap;
        }else{
            //future code
        }
         
        //updated or inserted contract                
        for(Contract__c contInstance : lContractList){
            
            if(recordTypeSet.contains(contInstance.RecordTypeId)){               
                if(trigger.isUpdate){ 
                   if(mapOfOldContract.get(contInstance.id).Video__c != contInstance.Video__c
                        || mapOfOldContract.get(contInstance.id).Archived__c != contInstance.Archived__c
                        || mapOfOldContract.get(contInstance.id).Contract_Status__c != contInstance.Contract_Status__c                       
                        || mapOfOldContract.get(contInstance.id).Voice__c != contInstance.Voice__c                           
                        || mapOfOldContract.get(contInstance.id).Data__c != contInstance.Data__c  
                        || mapOfOldContract.get(contInstance.id).Data_Billing_Type__c != contInstance.Data_Billing_Type__c
                        || mapOfOldContract.get(contInstance.id).Voice_Billing_Type__c != contInstance.Voice_Billing_Type__c
                        || mapOfOldContract.get(contInstance.id).Video_Billing_Type__c != contInstance.Video_Billing_Type__c
                        || mapOfOldContract.get(contInstance.id).Video_Increase_Period__c != contInstance.Video_Increase_Period__c
                        || mapOfOldContract.get(contInstance.id).Video_Increase_Notice__c != contInstance.Video_Increase_Notice__c                                                     
                        || mapOfOldContract.get(contInstance.id).Video_Rate_Escalator__c != contInstance.Video_Rate_Escalator__c
                        || mapOfOldContract.get(contInstance.id).Voice_Rate_Escalator__c != contInstance.Voice_Rate_Escalator__c
                        || mapOfOldContract.get(contInstance.id).Data_Rate_Escalator__c != contInstance.Data_Rate_Escalator__c
                        || mapOfOldContract.get(contInstance.id).Effective_Date__c != contInstance.Effective_Date__c
                        || mapOfOldContract.get(contInstance.id).Expiration_Date__c != contInstance.Expiration_Date__c
                        || mapOfOldContract.get(contInstance.id).Sub_Status__c != contInstance.Sub_Status__c
                    ){                       
                        contractIdSet.add(contInstance.Id);    
                        contractIdStatusMap.put(contInstance.Id,contInstance.Contract_Status__c);                       
                        addressIdSet.add(contInstance.Property__c);    
                        propertyIdContractMap.put(contInstance.Property__c,contInstance);  
                    }else{
                        if(!propertyContractIdMap.keySet().isEmpty()){                          
                            contractIdStatusMap.put(contInstance.Id,contInstance.Contract_Status__c);
                        }
                    }                                                                       
                }else if(Trigger.isInsert && !contInstance.Archived__c && contInstance.Effective_Date__c != null){
                    contractIdSet.add(contInstance.Id);
                    addressIdSet.add(contInstance.Property__c);    
                    propertyIdContractMap.put(contInstance.Property__c,contInstance);                                   
                }else{
                    //Future code
                }               
            }else{
                //Future code
            }                          
        }        
       
        //Update LOB Status on property records
        if(Trigger.isUpdate && !propertyContractIdMap.keySet().isEmpty()){
            List<MDU_Property__c> propertyList = new List<MDU_Property__c>();
            for(MDU_Property__c propertyTemp : [SELECT Id, Video_Contract_Status__c, Data_Contract_Status__c, Voice_Contract_Status__c, Comcast_Video_Serviced__c,
                                                Comcast_Data_Serviced__c, Comcast_Voice_Serviced__c
                                                FROM MDU_Property__c WHERE Id IN : propertyContractIdMap.keySet() 
                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    
                    if(CONTRACT_LOB.equalsIgnoreCase(propertyTemp.Comcast_Video_Serviced__c)){                       
                        propertyTemp.Video_Contract_Status__c = contractIdStatusMap.get(propertyContractIdMap.get(propertyTemp.Id)); 
                    }else{
                        propertyTemp.Video_Contract_Status__c = '';
                    }
                    if(CONTRACT_LOB.equalsIgnoreCase(propertyTemp.Comcast_Data_Serviced__c)){
                        propertyTemp.Data_Contract_Status__c = contractIdStatusMap.get(propertyContractIdMap.get(propertyTemp.Id));
                    } else{
                        propertyTemp.Data_Contract_Status__c = '';
                    }  
                    if(CONTRACT_LOB.equalsIgnoreCase(propertyTemp.Comcast_Voice_Serviced__c)){
                        propertyTemp.Voice_Contract_Status__c = contractIdStatusMap.get(propertyContractIdMap.get(propertyTemp.Id));  
                    }else{
                        propertyTemp.Voice_Contract_Status__c = '';
                    }                                   
                    propertyList.add(propertyTemp);
            }
            Database.update(propertyList, false);   
        }       
            
        List<MDU_Property__c> addressList = new List<MDU_Property__c>();                                                        
        for(MDU_Property__c tempaddressList : [select Id ,Increase_Amount__c ,Status_SubStatus__c ,Increase_Period__c
                                                        ,Contract_Video_Notice_Period__c,Voice_Contract_Status__c ,Video_Contract_Status__c
                                                        ,Lob_Billing_Type__c ,Data_Contract_Status__c, Video_Billing_Type__c
                                                        , Voice_Billing_Type__c, Data_Billing_Type__c FROM  MDU_Property__c WHERE Id IN : addressIdSet 
                                                limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
        {                   
            propertyMap.put(tempaddressList.id,tempaddressList);                                                                        
        }                                                                                
             
        //Fetch All Non-Archive Contract Come Under Property whose contract fields updated/inserted
        for(Contract__c tempContract : [select Status_Sub_Status__c , Lob_Billing_Type__c , Increase_Amount__c , Data_Rate_Escalator__c, Initial_Effective_Date__c
                                            ,Voice_Rate_Escalator__c,Video_Rate_Escalator__c, Status__c,Sub_Status__c,Video_Increase_Period__c
                                            ,Video_Increase_Notice__c, Effective_Date__c, Expiration_Date__c, Property__c, Video__c,Voice__c,Data__c,Data_Billing_Type__c,
                                            Voice_Billing_Type__c,Video_Billing_Type__c,Contract_Status__c
                                        from Contract__c where Archived__c = false and Property__c IN : addressIdSet 
                                        limit : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ]  ){                                   
            WrapperContract wrapperContractObject = new WrapperContract() ;                  
            
            //Initialize all the wrapper class attributes
            wrapperContractObject.videoBulkContract = new Contract__c();
            wrapperContractObject.videoRetailContract = new Contract__c();
            wrapperContractObject.dataBullkContract = new Contract__c();
            wrapperContractObject.dataRetailContract = new Contract__c();
            wrapperContractObject.voiceBullkContract = new Contract__c();
            wrapperContractObject.voiceRetailContract = new Contract__c();
            wrapperContractObject.contractWithHighestEffectiveDate = new Contract__c();  
            MDU_Property__c relatedProperty = propertyMap.get(tempContract.Property__c);                  
            if(propertyIdWrapperMap.containsKey(tempContract.Property__c)){
                wrapperContractObject = propertyIdWrapperMap.get(tempContract.Property__c);                     
            }else{
              //future code
            }
            if(relatedProperty != null){
                /* 
                    Set Lob Type and Status on property same as on contract that we insert having Highest Effective Date than Other contract Initial Effective date      
                */
                if(Trigger.isInsert){
                    Contract__c contract = propertyIdContractMap.get(relatedProperty.Id);                                                           
                    if(tempContract.Id != contract.Id){                      
                        wrapperContractObject.multyContractProperty = true;
                        if(contract.Effective_Date__c >= tempContract.Initial_Effective_Date__c){                  
                            wrapperContractObject.contractWithHighestEffectiveDate = contract;                                                     
                        }else{
                            wrapperContractObject.contractWithHighestEffectiveDate = new Contract__c(); 
                        } 
                    }else{
                         if(wrapperContractObject.contractWithHighestEffectiveDate.Effective_Date__c == null && !wrapperContractObject.multyContractProperty){            
                            wrapperContractObject.contractWithHighestEffectiveDate = contract;
                        }
                    }                    
                }
                                            
                //For Property Video LOB Check For BULK                                
                if(relatedProperty.Video_Billing_Type__c != null && BULK_BILLING_TYPE_VIDEO.equalsIgnoreCase(relatedProperty.Video_Billing_Type__c) 
                        &&  tempContract.Video_Billing_Type__c != null && BULK_BILLING_TYPE_VIDEO.equalsIgnoreCase(tempContract.Video_Billing_Type__c)){
                    if(wrapperContractObject.videoBulkContract.Expiration_Date__c == null || 
                        tempContract.Expiration_Date__c > wrapperContractObject.videoBulkContract.Expiration_Date__c){                                                           
                        wrapperContractObject.videoBulkContract = tempContract;                                                     
                    }else{
                        //future code
                    }   
                }              
                
                //For Property Data LOB Check For BULK                              
                if(relatedProperty.Data_Billing_Type__c != null && BULK_BILLING_TYPE_DATA.equalsIgnoreCase(relatedProperty.Data_Billing_Type__c) 
                        &&  tempContract.Data_Billing_Type__c != null && BULK_BILLING_TYPE_DATA.equalsIgnoreCase(tempContract.Data_Billing_Type__c)){
                    if(wrapperContractObject.dataBullkContract.Expiration_Date__c == null
                        || tempContract.Expiration_Date__c > wrapperContractObject.dataBullkContract.Expiration_Date__c){
                        wrapperContractObject.dataBullkContract = tempContract;
                    }else{
                        //future code
                    }                              
                }                                    
                //For Property Voice LOB Check For BULK                                
                if(relatedProperty.Voice_Billing_Type__c != null 
                        && BULK_BILLING_TYPE_VOICE.equalsIgnoreCase(relatedProperty.Voice_Billing_Type__c) 
                        &&  tempContract.Voice_Billing_Type__c != null 
                        && BULK_BILLING_TYPE_VOICE.equalsIgnoreCase(tempContract.Voice_Billing_Type__c)){
                    if(wrapperContractObject.voiceBullkContract.Expiration_Date__c == null 
                        || tempContract.Expiration_Date__c > wrapperContractObject.voiceBullkContract.Expiration_Date__c){
                        wrapperContractObject.voiceBullkContract = tempContract;
                    }else{
                        //future code
                    }                               
                }                                              
                //Pick a Bulk contract with highest Expiration Date from Video,Data And Voice Bulk                                              
                if(wrapperContractObject.videoBulkContract.Video_Billing_Type__c != null 
                    && BULK_BILLING_TYPE_VIDEO.equalsIgnoreCase(wrapperContractObject.videoBulkContract.Video_Billing_Type__c)
                    || wrapperContractObject.dataBullkContract.Data_Billing_Type__c != null
                    && BULK_BILLING_TYPE_DATA.equalsIgnoreCase(wrapperContractObject.dataBullkContract.Data_Billing_Type__c)
                    || wrapperContractObject.voiceBullkContract.Voice_Billing_Type__c != null
                    && BULK_BILLING_TYPE_VOICE.equalsIgnoreCase(wrapperContractObject.voiceBullkContract.Voice_Billing_Type__c)
                ){                                       
                    if(wrapperContractObject.videoBulkContract.Expiration_Date__c != null 
                       && wrapperContractObject.dataBullkContract.Expiration_Date__c != null                          
                    ){                                              
                        if(wrapperContractObject.videoBulkContract.Expiration_Date__c > wrapperContractObject.dataBullkContract.Expiration_Date__c){                          
                            wrapperContractObject.bulkContractHighestExpireDate = wrapperContractObject.videoBulkContract;
                        }else{
                            wrapperContractObject.bulkContractHighestExpireDate = wrapperContractObject.dataBullkContract;
                        }                                                      
                    }
                    else if(wrapperContractObject.dataBullkContract.Expiration_Date__c != null){                         
                        wrapperContractObject.bulkContractHighestExpireDate = wrapperContractObject.dataBullkContract;
                    }  
                    else if(wrapperContractObject.videoBulkContract.Expiration_Date__c != null){                          
                        wrapperContractObject.bulkContractHighestExpireDate = wrapperContractObject.videoBulkContract;
                    } 
                    else if(wrapperContractObject.voiceBullkContract.Expiration_Date__c != null){                          
                        wrapperContractObject.bulkContractHighestExpireDate = wrapperContractObject.voiceBullkContract;
                    }else{
                        //future code
                    }                       
                    if(wrapperContractObject.voiceBullkContract.Expiration_Date__c != null 
                            && wrapperContractObject.bulkContractHighestExpireDate.Expiration_Date__c != null){
                        if(wrapperContractObject.voiceBullkContract.Expiration_Date__c
                                > wrapperContractObject.bulkContractHighestExpireDate.Expiration_Date__c){
                            wrapperContractObject.bulkContractHighestExpireDate = wrapperContractObject.voiceBullkContract;
                        }else{
                            //future code
                        }
                    }else{
                        //future code
                    }                                                           
                }else{
                    //future code
                }                                                           
            }else{
              //future code
            }                                                   
            propertyIdWrapperMap.put(relatedProperty.ID, wrapperContractObject);                             
        }                                                                                                       
        //Iterate Through Contract To Update Property
        List<MDU_Property__c> listAddressToUpdate = new List<MDU_Property__c>();              
        for(Id id: propertyMap.keyset()){
            MDU_Property__c propertyTemp = propertyMap.get(id);                
            WrapperContract tempContract1 = propertyIdWrapperMap.get(propertyTemp.Id);                       
            if(tempContract1.bulkContractHighestExpireDate != null){                                                                  
                propertyTemp.Status_SubStatus__c = tempContract1.bulkContractHighestExpireDate.Status_Sub_Status__c ;
                propertyTemp.Lob_Billing_Type__c = tempContract1.bulkContractHighestExpireDate.Lob_Billing_Type__c ;                       
                propertyTemp.Increase_Amount__c =  tempContract1.bulkContractHighestExpireDate.Increase_Amount__c ; 
                propertyTemp.Increase_Period__c =  tempContract1.bulkContractHighestExpireDate.Video_Increase_Period__c; 
                propertyTemp.Contract_Video_Notice_Period__c =  tempContract1.bulkContractHighestExpireDate.Video_Increase_Notice__c;                     
            }else{
                //future code
            } 
            if(Trigger.isInsert){                
                if(tempContract1.contractWithHighestEffectiveDate.Effective_Date__c != null){
                    propertyContractIdMap.put(propertyTemp.Id, tempContract1.contractWithHighestEffectiveDate.Id);                       
                    if(CONTRACT_LOB.equalsIgnoreCase(tempContract1.contractWithHighestEffectiveDate.Video__c)){
                        propertyTemp.Comcast_Video_Serviced__c = tempContract1.contractWithHighestEffectiveDate.Video__c;
                    }else{
                        propertyTemp.Comcast_Video_Serviced__c = CONTRACT_LOB_NO;
                    }
                    if(CONTRACT_LOB.equalsIgnoreCase(tempContract1.contractWithHighestEffectiveDate.Data__c)){
                        propertyTemp.Comcast_Data_Serviced__c = tempContract1.contractWithHighestEffectiveDate.Data__c;
                    }else{
                        propertyTemp.Comcast_Data_Serviced__c = CONTRACT_LOB_NO;
                    }
                    if(CONTRACT_LOB.equalsIgnoreCase(tempContract1.contractWithHighestEffectiveDate.Voice__c)){
                        propertyTemp.Comcast_Voice_Serviced__c = tempContract1.contractWithHighestEffectiveDate.Voice__c; 
                    }
                    else{
                        propertyTemp.Comcast_Voice_Serviced__c = CONTRACT_LOB_NO;
                    }
                    propertyTemp.Video_Billing_Type__c = tempContract1.contractWithHighestEffectiveDate.Video_Billing_Type__c;
                    propertyTemp.Data_Billing_Type__c = tempContract1.contractWithHighestEffectiveDate.Data_Billing_Type__c;
                    propertyTemp.Voice_Billing_Type__c = tempContract1.contractWithHighestEffectiveDate.Voice_Billing_Type__c;                   
                    propertyTemp.Video_Contract_Status__c = CONTRACT_LOB.equalsIgnoreCase(tempContract1.contractWithHighestEffectiveDate.Video__c)?contractIdStatusMap.get(tempContract1.contractWithHighestEffectiveDate.Id):BLANK_VALUE;
                    propertyTemp.Data_Contract_Status__c = CONTRACT_LOB.equalsIgnoreCase(tempContract1.contractWithHighestEffectiveDate.Data__c)?contractIdStatusMap.get(tempContract1.contractWithHighestEffectiveDate.Id):BLANK_VALUE;
                    propertyTemp.Voice_Contract_Status__c =  CONTRACT_LOB.equalsIgnoreCase(tempContract1.contractWithHighestEffectiveDate.Voice__c)?contractIdStatusMap.get(tempContract1.contractWithHighestEffectiveDate.Id):BLANK_VALUE;                    
                }
            }
             
            listAddressToUpdate.add(propertyTemp);
        }             
        if(!listAddressToUpdate.IsEmpty()){             
            Database.SaveResult[] saveResult = Database.update(listAddressToUpdate,false); 
        }else{
            //future code
        }           
    }
   
   /**
    *@Name:WrapperContract
    *@Description: Wrapper class to load information of Contract
    *@params : NA
    *@return type : NA
    **/
    public class WrapperContract{
        public Contract__c  videoBulkContract{get;set;}
        public Contract__c  videoRetailContract{get;set;}
        public Contract__c  dataBullkContract{get;set;}        
        public Contract__c  dataRetailContract{get;set;}
        public Contract__c  voiceBullkContract{get;set;}        
        public Contract__c  voiceRetailContract{get;set;} 
        public Contract__c  contractWithHighestEffectiveDate{get;set;} 
        public boolean multyContractProperty = false;
        //property use to set Notice period and Notice date for Bulk contract as Use on Bulk Rate Increase                
        public Contract__c  bulkContractHighestExpireDate{get;set;}                           
       
    } 
    
    /**
    *@Name:deleteContract
    *@Description: This method use to delete contract and record in deleted property
    *@params : NA
    *@return type : NA
    **/
    Public static void deleteContract(){
        
        List<Contract__c> triggerOld = (List<Contract__c>) trigger.old;
        List<Deleted_Property__c> deletePropertyLogList = new List<Deleted_Property__c>();
     
        for(Contract__c contract: triggerOld){
            Deleted_Property__c propertyLog = new Deleted_Property__c();
            propertyLog.Property_Name__c=contract.Name;
            propertyLog.Property_Deleted_ID__c =contract.Id;
            propertyLog.Deleted_Date__c = System.now();
            propertyLog.Contract_Type__c=contract.Contract_Type__c;
            propertyLog.Is_Contract__c=true;
            deletePropertyLogList.add(propertyLog); 
        }
        
        if(!deletePropertyLogList.isEmpty()){
            Database.Insert(deletePropertyLogList, false);
        }else{
            //Future Code
        }
    }
    
     /**
    *@Name:expireDateSetInBefore
    *@Description: This Method use to set expiration date before insert/update of contract record
    *@params : NA
    *@return type : NA
    **/
    public static void expireDateSetInBefore(){            
        List<Contract__c> newContract =  (List<Contract__c>)Trigger.New;
        Map<Id,Contract__c> oldMap = new Map<Id,Contract__c>();
        
        if(Trigger.isUpdate){
            oldMap =  (Map<Id,Contract__c>)Trigger.OldMap; 
        }else{}                                    
       
        for(Contract__c contractTemp : newContract){           
            if(oldMap.containsKey(contractTemp.id) && 
                (contractTemp.Contract_Term__c != oldMap.get(contractTemp.id).Contract_Term__c || contractTemp.Contract_Term_Unit__c != oldMap.get(contractTemp.id).Contract_Term_Unit__c || contractTemp.Effective_Date__c != oldMap.get(contractTemp.id).Effective_Date__c))
                {
                     if(contractTemp.Contract_Term__c != null 
                         && contractTemp.Contract_Term_Unit__c != null 
                         && contractTemp.Effective_Date__c != null){
                        Date dateOfContractExpiration = Date.newInstance(contractTemp.Effective_Date__c.Year(), contractTemp.Effective_Date__c.Month(), contractTemp.Effective_Date__c.Day());                                                                                  
                        if(YEARS.equalsIgnoreCase(contractTemp.Contract_Term_Unit__c)){                            
                            contractTemp.Expire_Date__c = dateOfContractExpiration.addYears(Integer.ValueOf(contractTemp.Contract_Term__c));
                        } else if(MONTHS.equalsIgnoreCase(contractTemp.Contract_Term_Unit__c)){
                           contractTemp.Expire_Date__c = dateOfContractExpiration.addMonths(Integer.ValueOf(contractTemp.Contract_Term__c));
                        }else{}                                                
                    }                                     
                }else if(Trigger.isInsert){                    
                    if(contractTemp.Contract_Term__c != null && contractTemp.Contract_Term_Unit__c != null && contractTemp.Effective_Date__c != null){
                        Date dateOfContractExpiration = Date.newInstance(contractTemp.Effective_Date__c.Year(), contractTemp.Effective_Date__c.Month(), contractTemp.Effective_Date__c.Day());                                                                                                              
                        if(YEARS.equalsIgnoreCase(contractTemp.Contract_Term_Unit__c)){                            
                            contractTemp.Expire_Date__c = dateOfContractExpiration.addYears(Integer.ValueOf(contractTemp.Contract_Term__c));                                                       
                        } else if(MONTHS.equalsIgnoreCase(contractTemp.Contract_Term_Unit__c)){
                           contractTemp.Expire_Date__c = dateOfContractExpiration.addMonths(Integer.ValueOf(contractTemp.Contract_Term__c));                                                
                        } else{}                                               
                    }
                                     
                } else{}      
        }                   
    }  

    /*
    * Method Name: afterInsertUpdateDelCotermOpp
    * Author Name: Sagar Gurav.
    * User Story Sprint 5:US475004
    * Description: Method to update noncoterminous checkbox based on initial effective date, initial expiration date & LOB's of contract.
    */
    public static void afterInsertUpdateDelCotermOpp() { 

        string labelName = System.Label.XfinityContractRecordType;
        Map<id,list<contract__c>> propToMultContracts = new Map<id,list<contract__c>>();     
        Map<id, boolean> propertyToNoncoterminousMap = new Map<id, boolean>();
        Set<Id> recordTypeIdSet = new Set<Id>();
        List<MDU_Property__c> propListToUpdate = new List<MDU_Property__c>();
        Set<Id> propertySetToTrigger = new Set<Id>();
        Map<Id,MDU_Property__c> propertyMapForNonCoterminous = new Map<Id,MDU_Property__c>();
        Map<Id,MDU_Property__c> propertyMap = new Map<Id,MDU_Property__c>();
        boolean noncoterminousBulk = false;
        
        /*
        Get Record Types in set from label             
        */
        if(!string.isBlank(labelName)){
            for(String str: labelName.split(';')){
                recordTypeIdSet.add(Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get(str).getRecordTypeId());                
            }
        }          
        
        /*
        * Creating property set that will be triggered based on events.
        */
        if(Trigger.isDelete){        
            for(Contract__c contract : (List<Contract__c>)Trigger.old){
                if(recordTypeIdSet.contains(contract.recordtypeId)) {               
                    propertySetToTrigger.add(contract.property__c);
                }
            }
        }else if(Trigger.isInsert){
            for(contract__c con: (List<Contract__c>)Trigger.new) {
                if(recordTypeIdSet.contains(con.recordtypeId)) {                
                    propertySetToTrigger.add(con.property__c); 
                }
            }
        }else if(Trigger.isUpdate){
            Map<id,Contract__c> oldContractMap = (Map<Id,Contract__c>)Trigger.OldMap;
            for(Contract__c contractInst : (List<Contract__c>)Trigger.new){
                if(recordTypeIdSet.contains(contractInst.recordtypeId)) {
                    if((oldContractMap.get(contractInst.id).Initial_Effective_Date__c != contractInst.Initial_Effective_Date__c) || 
                    (oldContractMap.get(contractInst.id).Initial_Expiration_Date__c != contractInst.Initial_Expiration_Date__c) ||
                    (oldContractMap.get(contractInst.id).Data_Billing_Type__c != contractInst.Data_Billing_Type__c) ||
                    (oldContractMap.get(contractInst.id).Video_Billing_Type__c != contractInst.Video_Billing_Type__c ) ||
                    (oldContractMap.get(contractInst.id).Voice_Billing_Type__c != contractInst.Voice_Billing_Type__c ))
                    {
                        propertySetToTrigger.add(contractInst.property__c);
                    }
                }
            }
        }
        
        /*
        * Creating Map of property to contracts for only those properties which have more than 1 contract associated to it.
        */
        
        if(!propertySetToTrigger.isEmpty()) {
            for(MDU_Property__c prop : [select id,Noncoterminous_Bulk__c,(select id,Data_Billing_Type__c, Voice_Billing_Type__c,
                                        Video_Billing_Type__c ,property__c,Initial_Effective_Date__c,Initial_Expiration_Date__c from Contracts1__r)
                                        from MDU_Property__c where id IN: propertySetToTrigger
                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                if(prop.Contracts1__r.size() > 1) {
                    propToMultContracts.put(prop.id,prop.Contracts1__r); 
                    propertyMap.put(prop.id,prop);
                }
                else {
                    propertyMapForNonCoterminous.put(prop.id,prop);
                    propertyToNoncoterminousMap.put(prop.id, false);
                }
            }
        }
        
        /*
        * 1. Filtering properties whose contracts have same initial effective date, different initial expiration date, 
        * one contract having all retails in LOB(data,video,voice) & other contract set to any bulk in LOB.
        * 2. Forming map from property to non coterminous value based on above mentioned filter conditions
        */
        if(!propToMultContracts.isEmpty()) {
            for(MDU_Property__c prop: propertyMap.values()) {
                noncoterminousBulk = false;
                propertyToNoncoterminousMap.put(prop.id, false);
                propertyMapForNonCoterminous.put(prop.id,prop);
                for(Contract__c contractInst : propToMultContracts.get(prop.id)) {
                    if(contractInst.Initial_Effective_Date__c != null && contractInst.Initial_Expiration_Date__c != null) {
                        for(Contract__c con : propToMultContracts.get(prop.id)) {
                            if((con.Initial_Effective_Date__c == contractInst.Initial_Effective_Date__c)
                                && (con.Initial_Expiration_Date__c != contractInst.Initial_Expiration_Date__c) && con.Id!=contractInst.Id ) { 
                                if((DATA_RETAIL.equalsIgnorecase(con.Data_Billing_Type__c) && VOICE_RETAIL.equalsIgnorecase(con.Voice_Billing_Type__c) 
                                    && VIDEO_RETAIL.equalsIgnorecase(con.Video_Billing_Type__c)) && 
                                    (DATA_BULK.equalsIgnorecase(contractInst.Data_Billing_Type__c) || VOICE_BULK.equalsIgnorecase(contractInst.Voice_Billing_Type__c) 
                                    || VIDEO_BULK.equalsIgnorecase(contractInst.Video_Billing_Type__c))){                                
                                    propertyToNoncoterminousMap.put(prop.id, true);
                                    propertyMapForNonCoterminous.put(prop.id,prop);
                                    break;                                   
                                } else if((DATA_RETAIL.equalsIgnorecase(contractInst.Data_Billing_Type__c) && VOICE_RETAIL.equalsIgnorecase(contractInst.Voice_Billing_Type__c) 
                                    && VIDEO_RETAIL.equalsIgnorecase(contractInst.Video_Billing_Type__c)) && 
                                    (DATA_BULK.equalsIgnorecase(con.Data_Billing_Type__c) || VOICE_BULK.equalsIgnorecase(con.Voice_Billing_Type__c) 
                                    || VIDEO_BULK.equalsIgnorecase(con.Video_Billing_Type__c))){                                                              
                                    propertyToNoncoterminousMap.put(prop.id, true);   
                                    propertyMapForNonCoterminous.put(prop.id,prop);
                                    break;
                                }
                            }
                        }                   
                    }
                    if(propertyToNoncoterminousMap.get(contractInst.property__c) == true) {
                        break;  
                    }
                } 
                if(propertyToNoncoterminousMap.get(prop.id) == true) {
                    break;  
                }
            }
        }

        /*
        * Creating list to properties whose  non coterminous checkbox will be updated.
        */
        if(!propertyToNoncoterminousMap.isEmpty()){
            for(MDU_Property__c prop: propertyMapForNonCoterminous.values()){
                prop.Noncoterminous_Bulk__c = propertyToNoncoterminousMap.get(prop.Id);
                propListToUpdate.add(prop);
            }
        }
        
        /*
        * Commiting to database & updating list of properties.
        */
        if(!propListToUpdate.isEmpty()) {
            Database.update(propListToUpdate);    
        }   
    }
}