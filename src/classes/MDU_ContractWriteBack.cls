/************************************************************************************************************************************************************
Name: MDU_ContractWriteBack 
Description: This class is used to create contract in sfdc based on data as response from Emptoris system
Author: Accenture
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
18 March 2015 Comcast  
*************************************************************************************************************************************************************/
public class MDU_ContractWriteBack{
        
    /*  DATA MEMBER'S */
    
    private static final string serviceType = 'Video Only'; 
    private static String executionLog = '';
    private static DateTime startTime;
    private static boolean isEligibleForAppLogging = false;
    private static String dtTimeStr = MDU_EmptorisUtility.SetNow();
    private static Map<String, String> propertyFeeRecordTypeMap = new Map<String, String>();
    public static Map<String, ContractTermWrapperClass> wrapperContractMap = new Map<String, ContractTermWrapperClass>();     
    private static final String EMPTY_STRING = '';
    private static final String SPLIT_CONSTANT = ';';
    private static final String SUBS_DEFAULT = '0';
    public static MDU_ContractWriteBack.BulkServicesWrapper objContractedBulkService = new MDU_ContractWriteBack.BulkServicesWrapper();
    // contract Id set
    private static Set<String> contractIdSet = new Set<String>();   
    public static Set<String> statusUpdatecontractIdSet = new Set<String>();   
    private static List<ContractResponseStatusWrapper> responseWrapperObjList = new List<ContractResponseStatusWrapper>();
    private static Attachment attachmentObject = new Attachment(); 
    private static Set<String> opportunutyIdSet = new Set<String>();  
   
   //Initialize Child Object For Contract 
    private static Map<String, Contract__c> contractIdContractObjMap = new Map<String, Contract__c>();
    public static Map<String, MDU_ContractWriteBack.BulkServicesWrapper> contractIdBulkServiceMap = new Map<String, MDU_ContractWriteBack.BulkServicesWrapper>();
    private static Map<String, List<Property_Fees__c>> contractIdPropertyFeeMap = new Map<String, List<Property_Fees__c>>();
    private static Map<String, Attachment> contractIdAttachmentMap = new Map<String, Attachment> ();
    private static Map<String,String> contractPropertyIdMap = new Map<String,String>();
    private static Map<String,String> contractOpportunityIdMap = new Map<String,String>();
    private static boolean isAttachmentExist = false;
       
    /* Method Name : createContractDataOperation 
    *  Description : Create contractId set and insert contract in sfdc after fetching data from emptoris(Actual Batch Start from this method)
    *  Parameter   : None
    *  Return Type : void
    */
    public static void createContractDataOperation(){
        try{
            string contractDataLogMessage = EMPTY_STRING;
            startTime = System.Now();               
            //Set user eligibility if user to check create application log
            isEligibleForAppLogging = MDU_EmptorisUtility.setEligibilityForApplicationLogging();                           
            executionLog = Mdu_ApplicationLogger.logStart(MDU_Constants.MDU_CONTRACT_WRITEBACK_PROCESS  + dtTimeStr + MDU_Constants.GET_EXEC_WRITEBACK, executionLog, isEligibleForAppLogging);             
          
            Map<String,Mdu_Property__c> contLegpropertyObjectMap = new Map<String,Mdu_Property__c>();
            Set<String> propertyIdSet = new  Set<String> ();
            Map<String,id> contractSfdcIdMap = new Map<String,id>();
            List<Contract__c> contractFinalList = new List<Contract__c>();
            Set<String> contractHiddenIdsOfAddendumOpp = new Set<String>();
            List<Attachment> attachmentFinalList = new List<Attachment>();
            List<Property_Fees__c> propertyFeeList = new List<Property_Fees__c>();
            List<Contracted_Bulk_Service__c> contractedBulkServiceList = new List<Contracted_Bulk_Service__c>();                                        
            Map<Id,Opportunity> opportunutyUpdateMap = new Map<Id,Opportunity>();
        
            HttpResponse executeRequestRes = MDU_EmptorisUtility.searchExecutedRequest();            
            Dom.Document docExec = executeRequestRes.getBodyDocument();
            Dom.XMLNode executeNodeDoc = docExec.getRootElement();
            if(executeRequestRes.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE ){                   
                getNodeData(executeNodeDoc);  
            } else {
                String  errorResponseData = '';
                errorResponseData = MDU_EmptorisUtility.responseErrorLog(executeNodeDoc);                  
                executionLog = Mdu_ApplicationLogger.logMessage(errorResponseData +MDU_Constants.EXUCUTED_ERROR , executionLog, isEligibleForAppLogging);  
            }                                                                   
            HttpResponse searchActiveRes = MDU_EmptorisUtility.searchActiveRequest();
            Dom.Document docActive = searchActiveRes.getBodyDocument();
            Dom.XMLNode searchAciveNodeDoc = docActive.getRootElement();
            if(searchActiveRes.getStatusCode() == MDU_Constants.SUCCESSSTATUSCODE ){                   
                getNodeData(searchAciveNodeDoc);  
            } else {
                String  errorResponseData = '';
                errorResponseData = MDU_EmptorisUtility.responseErrorLog(searchAciveNodeDoc);  
                executionLog = Mdu_ApplicationLogger.logMessage( errorResponseData + MDU_Constants.ACTIVE_ERROR , executionLog, isEligibleForAppLogging); 
            }
            
            if(!contractIdSet.isEmpty()){
                
                Map<String,List<Contracted_Bulk_Service__c>> contractIdBulkServiceListMap = new Map<String,List<Contracted_Bulk_Service__c>>();
                
                /* Populate map with Property_fee recordType values. */
                setPropertyFeeRecordTypeId(); 
                
                // EXECUTE MAXIMUM 15 CONTRACTS PER BATCH PROCESS
                String contractNumberProcess = System.Label.XffinityContractNumberToBeProceesed;
                Integer contractNoFromSetting = 0 ;
                if(!String.IsBlank(System.Label.XffinityContractNumberToBeProceesed)){
                    contractNoFromSetting = Integer.ValueOf(contractNumberProcess);
                } else {}               
                
                /* Service call to get Contract details */                          
                Integer contractNumber = 0;
                for(String contractId: contractIdSet){                                                                                         
                    // fetch & populate Contract data based on ContractId from Emptoris
                    populateContractData(contractId);                                                      
                    // add Contract Id s processed - for status update in Emptoris                                   
                    contractNumber ++ ;
                    if(contractNumber == contractNoFromSetting){
                        break;
                    }
                }
                 
                //Fetch SFDC Id For Opportunity against Legacy Id passed in contractOpportunityIdMap
                Map<String,String> contractOpportunityIdUpdateMap = Mdu_WriteBackHelper.fetchOpportunitySFIdForLegacyId(contractOpportunityIdMap);
                //Create Log
                contractDataLogMessage = isEligibleForAppLogging ? contractDataLogMessage +MDU_Constants.OPPOOPRTUNTY_SFID+ contractOpportunityIdUpdateMap.values() + MDU_Constants.NEW_LINE : +contractDataLogMessage+EMPTY_STRING;
                                
                //Fetch SFDC Id For Property against Legacy Id passed in contractPropertyIdMap
                Map<String,String> contractPropertyIdUpdateMap = Mdu_WriteBackHelper.fetchPropertySFIdForLegacyId(contractPropertyIdMap);
                //Create Log
                contractDataLogMessage = isEligibleForAppLogging ? contractDataLogMessage +MDU_Constants.PROPERTY_SFID+ contractPropertyIdUpdateMap.values() + MDU_Constants.NEW_LINE : contractDataLogMessage+EMPTY_STRING;              
                //Create Opportunity list to set Stage as 'Close Won' 
                if(contractOpportunityIdUpdateMap.size() > 0){
                    opportunutyUpdateMap = Mdu_WriteBackHelper.fetchOpportunityUpdateList(contractOpportunityIdUpdateMap.values());
                }                   

                //generate property Id set using contractPropertyIdUpdateMap
                for(String contractIdTemp: contractPropertyIdUpdateMap.keySet()){ 
                     propertyIdSet.add(contractPropertyIdUpdateMap.get(contractIdTemp));
                }

                //create Property SFDC Id And Property Object Map
                Map<String,Mdu_Property__c> propertyIdObjectMap = Mdu_WriteBackHelper.fetchPropertyIdObjectMap(propertyIdSet);
                
                //Create ContractLegacy Id and Property Object Map
                for(String contractLegId : contractPropertyIdUpdateMap.keyset()){
                    if(!String.isBlank(contractPropertyIdUpdateMap.get(contractLegId))){                   
                        contLegpropertyObjectMap.put(contractLegId,propertyIdObjectMap.get(contractPropertyIdUpdateMap.get(contractLegId)));
                    }                   
                }
                            
                contractIdBulkServiceListMap =  getUpdatedContractedServiceAndContract(contractIdBulkServiceMap, contractIdContractObjMap,contLegpropertyObjectMap);               
                /* Replace Opportunity Legacy Id By SFDC ID */                
                for(String contractIdTemp: contractIdContractObjMap.keySet()){          
                    if(!String.IsBlank(contractPropertyIdUpdateMap.get(contractIdTemp))){
                        Contract__c  contractObj = contractIdContractObjMap.get(contractIdTemp);
                        contractObj.Property__c = contractPropertyIdUpdateMap.get(contractIdTemp);
                        String oppId = contractOpportunityIdUpdateMap.get(contractIdTemp);
                       /*US769406  - Communities: MCAT Writeback for Addendums
                        * Do not write back any contracts and their children if corresponding
                        * opportunity is of type "Addendum"     
                        */
                        if(!String.IsBlank(oppId)){
                             if(!opportunutyUpdateMap.isEmpty() && opportunutyUpdateMap.get(oppId) != null &&
	                          opportunutyUpdateMap.get(oppId).Type != MDU_Constants.OPPORTUNITY_TYPE_ADDENDUM){
                                contractObj.Opportunity__c = contractOpportunityIdUpdateMap.get(contractIdTemp);
                                contractFinalList.add(contractObj);
                             }else{
                                contractHiddenIdsOfAddendumOpp.add(contractObj.Contract_Id_Hidden__c); // To include for MCAT processing
                             }
                        } else{ // if opportunityId is null
                            contractFinalList.add(contractObj);
                        }
                        
                    }                   
                }

                Set<Id> contractIdTempSet = new Set<Id>();              
                /* Insert Contract Record And Create Map Of SFDC Contract Id And Temp Contract Id */
                if(!contractFinalList.isEmpty()){
                    Database.SaveResult[] contractSaveResult = Database.insert(contractFinalList, false);                     
                    for (Database.SaveResult result : contractSaveResult ) {
                        if(result.isSuccess()){
                            contractIdTempSet.add(result.getId());                          
                        }
                        if(!result.isSuccess()) {
                            for(Database.Error error : result.getErrors()) {
                                contractDataLogMessage = isEligibleForAppLogging ? MDU_Constants.CONTRACT_INSERT_MESSAGE + error.getMessage() + MDU_Constants.NEW_LINE : contractDataLogMessage +EMPTY_STRING;
                            } 
                        }   
                    }                   
                }
                //Generate contractSfdcIdMap that will return SF id for contract with Emptoris Id
                //for(Contract__c contract : [SELECT id, Contract_Id_Hidden__c FROM Contract__c WHERE Id IN: contractFinalList]){
                for(Contract__c contract : [SELECT id, Contract_Id_Hidden__c FROM Contract__c WHERE Id IN: contractIdTempSet]){
                    contractSfdcIdMap.put(contract.Contract_Id_Hidden__c, contract.id);
                    // add Contract Id s processed - for status update in Emptoris
                    statusUpdatecontractIdSet.add(contract.Contract_Id_Hidden__c);              
                }
                if(!contractHiddenIdsOfAddendumOpp.isEmpty()){
                    statusUpdatecontractIdSet.addAll(contractHiddenIdsOfAddendumOpp); //US769406
                }
                
                if(isEligibleForAppLogging){
                    contractDataLogMessage += MDU_Constants.CONTRACT_SFID+ contractSfdcIdMap.values();
                }else{}                                
                
                /* Create attachment object record */
                attachmentFinalList = Mdu_WriteBackHelper.fetchAttachmentList(contractIdAttachmentMap,contractSfdcIdMap);
             
                /* Create Property Fee Object record */      
                propertyFeeList = Mdu_WriteBackHelper.fetchPropertyFeesList(contractIdPropertyFeeMap,contractSfdcIdMap);
                
                /* Create Contracted Bulk Services Record */       
                contractedBulkServiceList = Mdu_WriteBackHelper.fetchContractedBulkServiceList(contractIdBulkServiceListMap,contractSfdcIdMap);         
                                                   
                /* Insert All Child's Here */
                if(!propertyFeeList.isEmpty()){
                    Database.insert(propertyFeeList, false);
                }
                if(!attachmentFinalList.isEmpty()){
                    Database.insert(attachmentFinalList, false);
                }
                if(!contractedBulkServiceList.isEmpty()){
                    Database.insert(contractedBulkServiceList, false);
                }
                             
                //Update Opportunity Record
                if(!opportunutyUpdateMap.isEmpty()){
                    Database.SaveResult[] opportunityUpdateResult = database.update(opportunutyUpdateMap.values(), false); 
                    for (Database.SaveResult result : opportunityUpdateResult ) {
                        if(!result.isSuccess()) {
                            for(Database.Error error : result.getErrors()) {                               
                                contractDataLogMessage = isEligibleForAppLogging ? MDU_Constants.OPPORTUNITY_INSERT_MESSAGE+error.getMessage()+MDU_Constants.NEW_LINE:contractDataLogMessage+EMPTY_STRING;
                            } 
                        }   
                    }
                }                                                                                   
                //Create Log
                executionLog = Mdu_ApplicationLogger.logMessage(contractDataLogMessage, executionLog, isEligibleForAppLogging);
                Mdu_ApplicationLogger.createLog(executionLog + MDU_Constants.PROCESS_SUCCESS,  isEligibleForAppLogging , startTime, System.Now());
                        
            } 
            else {              
                executionLog = executionLog + MDU_Constants.CONTRACT_NOT_FOUND;
                Mdu_ApplicationLogger.createLog(executionLog, isEligibleForAppLogging, startTime, System.Now());
            }
        }   
        catch(Exception e){
            Mdu_ApplicationLogger.createLog(executionLog +MDU_Constants.EXCEPTION_MEESAGE+e.getMessage()  ,  isEligibleForAppLogging , startTime, System.Now());          
        }

    }  
     
    
    /* Method Name : getNodeData 
    *  Description : Response parsing to fetch Contract Ids
    *  Parameter   : Dom.XMLNode resRoot
    *  Return Type : void
    */
    public static void getNodeData(Dom.XMLNode resRoot){
        
        Dom.XmlNode node = resRoot.getChildElement(MDU_Constants.BODY_NODE, MDU_Constants.NODE_FUNCTION); //For Header Element                    
        for (Dom.XMLNode child: node.getChildren()) {
            if (child.getNodeType() == DOM.XMLNodeType.ELEMENT) { 
                getRecursivelyNode(child);
            }
        }
    }
             
    /* Method Name : successRequestExecute 
    *  Description : Execute this method to check response of final http call to check status of contract at emptoris
    *  Parameter   : Set<String> contractIdResponseSet
    *  Return Type : void
    */
    public static void successRequestExecute(Set<String> contractIdResponseSet){
        String logMessage = EMPTY_STRING;
        try{
            boolean isEligibleForAppLoggingInFuture = MDU_EmptorisUtility.setEligibilityForApplicationLogging();
            DateTime startTimeForFuture = System.Now();  
            logMessage = Mdu_ApplicationLogger.logStart(MDU_Constants.FUTURE_METHOD_STARTED+contractIdResponseSet ,logMessage , isEligibleForAppLoggingInFuture);
            for(String contractId: contractIdResponseSet){          
                ContractResponseStatusWrapper responseWrapperObj = new ContractResponseStatusWrapper();
                responseWrapperObj.contractIdToCheckResp = contractId;
                Httpresponse subStatusRequestResponse = MDU_EmptorisUtility.updateContractSubstatusRequest(contractId) ;
                responseWrapperObj.contractSubStatusResponse = subStatusRequestResponse.getStatus(); 
                if(subStatusRequestResponse.getStatusCode() != MDU_Constants.SUCCESSSTATUSCODE && isEligibleForAppLoggingInFuture){
                    Dom.XMLNode contractStatusNode = subStatusRequestResponse.getBodyDocument().getRootElement();
                    String  errorResponseData = MDU_EmptorisUtility.responseErrorLog(contractStatusNode);  
                    logMessage = Mdu_ApplicationLogger.logMessage(MDU_Constants.CONTRACT_STATUS_MESSAGE+contractId+MDU_Constants.NEW_LINE+errorResponseData , logMessage , isEligibleForAppLoggingInFuture);
                }
                
                Httpresponse termRequestResponse = MDU_EmptorisUtility.updateContractTermRequest(contractId);  
                responseWrapperObj.contractTermResponse = termRequestResponse.getStatus();      
                if(termRequestResponse.getStatusCode() != MDU_Constants.SUCCESSSTATUSCODE && isEligibleForAppLoggingInFuture){                
                    Dom.XMLNode contractTermNode = termRequestResponse.getBodyDocument().getRootElement();
                    String  errorResponseData = MDU_EmptorisUtility.responseErrorLog(contractTermNode);              
                    logMessage = Mdu_ApplicationLogger.logMessage(MDU_Constants.CONTRACT_TERM_MESSAGE+contractId+MDU_Constants.NEW_LINE+errorResponseData , logMessage , isEligibleForAppLoggingInFuture);
                }
                
                Httpresponse customPropertyResponse = MDU_EmptorisUtility.updateContractCustomPropertyRequest(contractId); 
                responseWrapperObj.contractCustomPropertyResponse = customPropertyResponse.getStatus();             
                if(customPropertyResponse.getStatusCode() != MDU_Constants.SUCCESSSTATUSCODE && isEligibleForAppLoggingInFuture){
                    Dom.XMLNode custPropNode = customPropertyResponse.getBodyDocument().getRootElement();
                    String  errorResponseData = MDU_EmptorisUtility.responseErrorLog(custPropNode);  
                    logMessage = Mdu_ApplicationLogger.logMessage(MDU_Constants.CUST_PROP_MESSAGE+contractId+MDU_Constants.NEW_LINE+errorResponseData , logMessage , isEligibleForAppLoggingInFuture);               
                }
                responseWrapperObjList.add(responseWrapperObj);             
            } 
            logMessage = Mdu_ApplicationLogger.logEnd(MDU_Constants.FUTURE_METHOD_ENDED,logMessage , isEligibleForAppLoggingInFuture);          
            Mdu_ApplicationLogger.createLog(logMessage , isEligibleForAppLoggingInFuture , startTimeForFuture , System.Now());
        }catch(Exception e){
            Mdu_ApplicationLogger.createLog(logMessage +MDU_Constants.EXCEPTION_MEESAGE+e.getMessage()  ,  isEligibleForAppLogging , startTime, System.Now());          
        }
    }   
    
   
    /* Class Name : ContractResponseStatusWrapper 
    *  Description : created to store response status from Contract Sub status , term and custom property request   
    */
    public class ContractResponseStatusWrapper{
        
        public String contractIdToCheckResp{get;set;}
        public String contractSubStatusResponse{get;set;}
        public String contractTermResponse{get;set;}
        public String contractCustomPropertyResponse{get;set;}
    }
    
    
    /* Method Name : populateContractData 
    *  Description :  base on contract id pass to method this method create contract object and its sub child, attachment
    *  Parameter   : String contractIdTemp
    *  Return Type : void
    */
    public static void populateContractData(String contractIdTemp){
        String logMessage = EMPTY_STRING;
        if(isEligibleForAppLogging){
            logMessage += MDU_Constants.CONTRACT_START_TO_FETCH+contractIdTemp;
        }       
        createContractMappingData(contractIdTemp); 
        createContractAttachment(contractIdTemp);
        Contract__c tempContract = new Contract__c();     
        List<MDU_ContractExtraction__c> fieldMapping = MDU_ContractExtraction__c.getAll().values();                                          
        
        boolean isDoorFeeExist = false;
        boolean isRecuringFeeExist = false;
        boolean isHomeInstall = false;      
        boolean isHomeRunInstall = false;
        boolean isChannelAgreement = false;
        boolean isDoorFeeRecordCreated = false;
        boolean isRecurringFeeRecordCreated = false;
        string BillingType = '';
        Integer equipmentQuantityDCT = 0;
        Integer equipmentQuantityDTA = 0;
        String propertyId = MDU_Constants.BLANK_VALUE;
        String opportunityId = MDU_Constants.BLANK_VALUE;
        String homeInstallBy = MDU_Constants.BLANK_VALUE;
        String videoSubs = MDU_Constants.BLANK_VALUE;
        String dataSubs = MDU_Constants.BLANK_VALUE;
        String voiceSubs = MDU_Constants.BLANK_VALUE;
        String ecmCourtesyAccountType = MDU_Constants.BLANK_VALUE;
        String chwInstalledBy = MDU_Constants.BLANK_VALUE;
        String chrwWiring = MDU_Constants.BLANK_VALUE;
        
        Property_Fees__c propertyDoorFeeObject = new Property_Fees__c();
        Property_Fees__c propertyRecurringFeeObject = new Property_Fees__c();
        Contracted_Bulk_Service__c contractedBulkService = new Contracted_Bulk_Service__c();
       
        //We First Apply Loop On Custom Setting And Set Some Contract Object Field And Variable Declare Above  
        for(MDU_ContractExtraction__c customSetting: fieldMapping){                 
           
            String tempval = getTermValue(wrapperContractMap.get(customSetting.ECM_Variable_Internal_Name__c));                         
            if(!String.IsBlank(tempval)) {                                      
                //For Contract Object(Object Type = 'MDUContract' )
                if(MDU_Constants.MDUCONTRACT_DIRECT_TYPE.equalsIgnoreCase(customSetting.DIRECT_Object__c)){                
                    if(MDU_Constants.DECIMAL_TYPE.equalsIgnoreCase(wrapperContractMap.get(customSetting.ECM_Variable_Internal_Name__c).termType)){    
                        if(MDU_Constants.NUMBER_OF_CHANNEL.equalsIgnoreCase(customSetting.SFDC_Field_API_Name__c)) {
                            tempContract.put(customSetting.SFDC_Field_API_Name__c, tempval);
                        }else{   
                            tempContract.put(customSetting.SFDC_Field_API_Name__c, decimal.valueof(tempval));
                        }
                    }else if(MDU_Constants.DATE_TYPE.equalsIgnoreCase(wrapperContractMap.get(customSetting.ECM_Variable_Internal_Name__c).termType)){
                        tempContract.put(customSetting.SFDC_Field_API_Name__c, date.valueof(tempval));                          
                    }else{           
                        if(customSetting.SFDC_Field_API_Name__c != null  &&  !MDU_Constants.SFDC_DAYS_CANCEL_API.equalsIgnoreCase(customSetting.SFDC_Field_API_Name__c)){//customSetting.SFDC_Field_API_Name__c != 'Name' remove from above if                          
                            if(!String.IsBlank(customSetting.Mapping_Function_Name__c)){ //First Work For Function
                                if(MDU_Constants.lobECMInternalVariableSet.contains(customSetting.ECM_Variable_Internal_Name__c)){ 
                                    //For LOB  Function Name  GetYesNoFromContractServiceAsInt
                                    String LobString = MDU_Constants.lobValueSet.contains(tempval) ? MDU_Constants.YES_FLAG : MDU_Constants.NO_FLAG;
                                    tempContract.put(customSetting.SFDC_Field_API_Name__c,LobString);
                                }else if(MDU_Constants.homeExclusiveECMSet.contains(customSetting.ECM_Variable_Internal_Name__c)) {
                                    //Home Exclusive Use GetYesNoAsInt Function Use
                                    if(MDU_Constants.YES_FLAG.equalsIgnoreCase(tempval) || MDU_Constants.NO_FLAG.equalsIgnoreCase(tempval)){
                                        tempContract.put(customSetting.SFDC_Field_API_Name__c,tempval); 
                                    }
                                }else if(MDU_Constants.installByECMSet.contains(customSetting.ECM_Variable_Internal_Name__c)) {
                                    //Home Insertion Equip GetOwnerComcastAsIntForInsertion Function Use
                                    if(MDU_Constants.OWNER_CONST.equalsIgnoreCase(tempval) || MDU_Constants.COMACAST_USER.equalsIgnoreCase(tempval)){
                                        tempContract.put(customSetting.SFDC_Field_API_Name__c,tempval); 
                                    }
                                }else if(MDU_Constants.homeInstrumnetOwnMaintainSet.contains(customSetting.ECM_Variable_Internal_Name__c)) {
                                    //Home maintain by , own by Function Use
                                    if(MDU_Constants.OWNER_CONST.equalsIgnoreCase(tempval) || MDU_Constants.COMACAST_USER.equalsIgnoreCase(tempval) 
                                        || MDU_Constants.ASSOCIATE_DEV_USER.equalsIgnoreCase(tempval) || MDU_Constants.INDIVIDUAL_RESIDENT_USER.equalsIgnoreCase(tempval) ){
                                        tempContract.put(customSetting.SFDC_Field_API_Name__c,tempval); 
                                    }else if(MDU_Constants.HOME_INSTRUMENT_OWNER_RESP_VALUE.equalsIgnoreCase(tempval)){ 
                                        tempContract.put(customSetting.SFDC_Field_API_Name__c,MDU_Constants.HOME_INSTRUMENT_OWNER_SFDC_VALUE); 
                                    }
                                }else if(MDU_Constants.marketingRightSet.contains(customSetting.ECM_Variable_Internal_Name__c)) {
                                    //Home Insertion Equip GetOwnerComcastAsIntForInsertion Function Use
                                    if(MDU_Constants.EXCLUSIVE_MARKETING_RIGHT.equalsIgnoreCase(tempval) ||  MDU_Constants.NONEXCLUSIVE_MARKETING_RIGHT.equalsIgnoreCase(tempval)|| MDU_Constants.NORIGHT_MARKETING_RIGHT.equalsIgnoreCase(tempval)){
                                        tempContract.put(customSetting.SFDC_Field_API_Name__c,tempval); 
                                    }else if(MDU_Constants.MARKETING_RIGHT_RESP_VALUE.equalsIgnoreCase(tempval)){
                                        tempContract.put(customSetting.SFDC_Field_API_Name__c,MDU_Constants.NONEXCLUSIVE_MARKETING_RIGHT);
                                    }else if(MDU_Constants.MARKETING_RIGHT_NONE.equalsIgnoreCase(tempval)){
                                        tempContract.put(customSetting.SFDC_Field_API_Name__c,MDU_Constants.MARKETING_RIGHT_NONE_SFDC_VALUE);
                                    }
                                }                  
                                else if(MDU_Constants.DIG_VIDEO_EQPMNT_INT_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){//equipment type
                                    String tempValue =  MDU_Constants.DTA_DCT_INT_NAME.equalsIgnoreCase(tempval) ? MDU_Constants.DTA_DCT_SFDC_VALUE_NAME : tempval;                                 
                                    tempContract.put(customSetting.SFDC_Field_API_Name__c,tempValue);
                                }else if(MDU_Constants.DIR_SALE_PERMIT_INT_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){//direct sales permitted
                                    String tempValue =  tempval.contains(MDU_Constants.DIRECT_SALE_PERMIT_VALUE) ? MDU_Constants.YES_FLAG : MDU_Constants.NO_FLAG;
                                    tempContract.put(customSetting.SFDC_Field_API_Name__c,tempValue);
                                }else if(MDU_Constants.renewalUnitIntrnalNameSet.contains(customSetting.ECM_Variable_Internal_Name__c)){
                                    //renewal and contract term unit                                    
                                    tempContract.put(customSetting.SFDC_Field_API_Name__c,tempval);                                   
                                }else if(MDU_Constants.billingTypeSet.contains(customSetting.ECM_Variable_Internal_Name__c)){
                                    //Set Lob Billing type                                    
                                    tempContract.put(customSetting.SFDC_Field_API_Name__c,tempval);                                         
                                }else if(MDU_Constants.BULK_RATE_PERIOD_INT_NAME.contains(customSetting.ECM_Variable_Internal_Name__c)){
                                    //Set Video Increase Period     
                                    if(MDU_Constants.VIDEO_INCREASE_PERD_PER_YEAR.equalsIgnoreCase(tempval)){
                                        tempContract.put(customSetting.SFDC_Field_API_Name__c,MDU_Constants.ANNUAL_INCREASE_PERIOD);  
                                    }                                                                         
                                }else if(MDU_Constants.CERT_OFINSURANCE_INT_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                                    //Set certificate of insurance
                                    String tempValue = MDU_Constants.CERT_INSU_RESP_VALUE.equalsIgnoreCase(tempval) ? MDU_Constants.CERT_INSU_SFDC_VALUE : tempval;
                                    tempContract.put(customSetting.SFDC_Field_API_Name__c,tempValue);                                   
                                }else if(MDU_Constants.installMaintainByECMInternalSet.contains(customSetting.ECM_Variable_Internal_Name__c)){
                                    //Set Install/Maintain By                               
                                    tempContract.put(customSetting.SFDC_Field_API_Name__c,MDU_Constants.preexistingUserMap.get(tempval))   ;                               
                                }else if(MDU_Constants.ASSIGN_INTERNAL_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c) && MDU_Constants.assignableValueSet.contains(tempval)){
                                    //Assignable Value Set                                      
                                    tempContract.put(customSetting.SFDC_Field_API_Name__c,tempval);   
                                }                               
                            }else{
                                    if(tempval.isNumeric()){                                       
                                        Schema.DisplayType getTypeVal = Schema.getGlobalDescribe().get('Contract__c').getDescribe().fields.getMap().get(customSetting.SFDC_Field_API_Name__c).getDescribe().getType();
                                        if(String.ValueOf(getTypeVal)=='STRING' || String.ValueOf(getTypeVal)=='TEXTAREA'){
                                            tempContract.put(customSetting.SFDC_Field_API_Name__c, String.ValueOf(tempval));
                                        } else {
                                            tempContract.put(customSetting.SFDC_Field_API_Name__c, Decimal.ValueOf(tempval)); 
                                        }                           
                                        //Bulk Notice                                       
                                    }else{                                       
                                        tempContract.put(customSetting.SFDC_Field_API_Name__c,tempval);  
                                    }                           
                            }
                            
                        }else if(String.IsBlank(customSetting.SFDC_Field_API_Name__c)){
                            if(MDU_Constants.COURTESY_ACCOUNT_INTERNAL_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                                ecmCourtesyAccountType = tempval;
                            }
                        }                                                                   
                    }             
                }//Object Type = 'MDUContractPropertyFee' To Set Field's On Property Fee Record
                else if(MDU_Constants.PROPERTY_FEE_DIRECT_TYPE.equalsIgnoreCase(customSetting.DIRECT_Object__c)){      //For Property Fee Object                                                 
                   if(MDU_Constants.feePropertyFieldSet.contains(customSetting.ECM_Variable_Internal_Name__c)){                                                
                        if(!String.IsBlank(customSetting.SFDC_Field_API_Name__c)){                            
                            isDoorFeeRecordCreated = true;                            
                            if(MDU_Constants.DECIMAL_TYPE.equalsIgnoreCase(wrapperContractMap.get(customSetting.ECM_Variable_Internal_Name__c).termType)){
                                propertyDoorFeeObject.put(customSetting.SFDC_Field_API_Name__c, Decimal.valueof(tempval));
                            }else if(MDU_Constants.DATE_TYPE.equalsIgnoreCase(wrapperContractMap.get(customSetting.ECM_Variable_Internal_Name__c).termType)){
                                propertyDoorFeeObject.put(customSetting.SFDC_Field_API_Name__c, date.valueof(tempval));
                            }else{           
                                if(customSetting.SFDC_Field_API_Name__c != null ){                              
                                    if(tempval.isNumeric()){                                        
                                        Schema.DisplayType getTypeVal = Schema.getGlobalDescribe().get('Property_Fees__c').getDescribe().fields.getMap().get(customSetting.SFDC_Field_API_Name__c).getDescribe().getType();
                                        if(String.ValueOf(getTypeVal)=='STRING' || String.ValueOf(getTypeVal)=='TEXTAREA'){
                                            propertyDoorFeeObject.put(customSetting.SFDC_Field_API_Name__c, String.ValueOf(tempval));
                                        } else {
                                            propertyDoorFeeObject.put(customSetting.SFDC_Field_API_Name__c, Integer.ValueOf(tempval)); 
                                        }  
                                    }else{
                                        propertyDoorFeeObject.put(customSetting.SFDC_Field_API_Name__c,tempval);  
                                    }
                                }
                                
                            } 
                        }else if(MDU_Constants.DOOR_FEES_OBJECT_PROPERTY.equalsIgnoreCase(customSetting.DIRECT_Object_Property__c) && MDU_Constants.YES_FLAG.equalsIgnoreCase(tempval)){                          
                            isDoorFeeExist = true; 
                        }else if(MDU_Constants.COMPENSATION_PER_UNIT.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                            isDoorFeeRecordCreated = true;
                            propertyDoorFeeObject.UnitFee__c = decimal.valueOf(tempval);
                        }                               
                    }else{
                        if(!String.IsBlank(customSetting.SFDC_Field_API_Name__c)){                               
                            isRecurringFeeRecordCreated = true;             
                            if(MDU_Constants.DECIMAL_TYPE.equalsIgnoreCase(wrapperContractMap.get(customSetting.ECM_Variable_Internal_Name__c).termType)){
                                propertyRecurringFeeObject.put(customSetting.SFDC_Field_API_Name__c, decimal.valueof(tempval)); 
                            }else if(MDU_Constants.DATE_TYPE.equalsIgnoreCase(wrapperContractMap.get(customSetting.ECM_Variable_Internal_Name__c).termType)){
                                propertyRecurringFeeObject.put(customSetting.SFDC_Field_API_Name__c, date.valueof(tempval));
                            }else{                                          
                                if(tempval.isNumeric()){
                                    Schema.DisplayType getTypeVal = Schema.getGlobalDescribe().get('Property_Fees__c').getDescribe().fields.getMap().get(customSetting.SFDC_Field_API_Name__c).getDescribe().getType();
                                    if(String.ValueOf(getTypeVal)=='STRING' || String.ValueOf(getTypeVal)=='TEXTAREA'){
                                        propertyRecurringFeeObject.put(customSetting.SFDC_Field_API_Name__c, String.ValueOf(tempval));
                                    } else {
                                        propertyRecurringFeeObject.put(customSetting.SFDC_Field_API_Name__c, Integer.ValueOf(tempval)); 
                                    }  
                                }else{
                                    propertyRecurringFeeObject.put(customSetting.SFDC_Field_API_Name__c,tempval);  
                                }                                                                                                 
                            } 
                        } else if(MDU_Constants.RECIRRING_FEES_OBJECT_PROPERTY.equalsIgnoreCase(customSetting.DIRECT_Object_Property__c) &&  MDU_Constants.YES_FLAG.equalsIgnoreCase(tempval)){
                            isRecuringFeeExist = true; 
                        }                            
                    }   
                }
                //Check For Contracted Bulk Service
                else if(MDU_Constants.CONTRCT_BULKSERVICE_DIRECT_TYPE.equalsIgnoreCase(customSetting.DIRECT_Object__c)){
                    if(MDU_Constants.BULK_SERVIC_TYPE_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        contractedBulkService.put(customSetting.SFDC_Field_API_Name__c , tempval);
                        objContractedBulkService.RetailOnly = false;
                        objContractedBulkService.Bulk_Service_Type = tempval;
                                              
                    }else if(MDU_Constants.BULK_SERVIC_TYPE_HOSPITALITY_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        contractedBulkService.put(customSetting.SFDC_Field_API_Name__c , tempval);
                        objContractedBulkService.RetailOnly = false;
                        objContractedBulkService.Bulk_Service_Type = tempval;
                         
                    }
                    logMessage += MDU_Constants.CONTRACTED_BULK_AVAIL  + MDU_Constants.NEW_LINE;                  
                }
                //Check For CustomSetting Record That Does Not Have Any ObectType 
                else if(String.IsBlank(customSetting.DIRECT_Object__c)){
                                        
                    if(MDU_Constants.CHANNEL_AGREEMENT_INTERNAL_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        if(MDU_Constants.YES_FLAG.equalsIgnoreCase(tempval)){
                            isChannelAgreement = true;
                        }   
                    }
                    else if(MDU_Constants.EQUIPMNT_QUANTITY_DCT_INTERNAL_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        if(tempval.isNumeric()){
                            equipmentQuantityDCT = Integer.ValueOf(tempval);
                        }
                    }else if(MDU_Constants.EQUIPMNT_QUANTITY_DTA_INTERNAL_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        if(tempval.isNumeric()){
                            equipmentQuantityDTA = Integer.ValueOf(tempval);
                        }
                    }else if(MDU_Constants.VIDEO_SUBS_VARIABLE_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Name__c)){ // Added in Custom Setting
                        videoSubs =  tempval;                    
                    }else if(MDU_Constants.DATA_SUBS_VARIABLE_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Name__c)){ // Added in Custom Setting
                        dataSubs =  tempval;
                    }else if(MDU_Constants.VOICE_SUBS_VARIABLE_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Name__c)){// Not Added in Custom Setting
                        voiceSubs =  tempval;
                    }else if(MDU_Constants.CHW_INSTALL_INTERNAL_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        chwInstalledBy = tempval;
                    }else if(MDU_Constants.CHW_WIRING_INTERNAL_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        chrwWiring = tempval;
                    }// Contracted Bulk Service Logic
                    else if(MDU_Constants.SERVICE_FEE_PER_UNIT.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        objContractedBulkService.Video_Per_Unit_Fee = tempval;
                    }else if(MDU_Constants.HSI_SERVICE_FEE_PER_UNIT.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        objContractedBulkService.Data_Per_Unit_Fee = tempval;
                    }else if(MDU_Constants.VOICE_BULK_BILL_RATE.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        objContractedBulkService.Voice_Per_Unit_Fee = tempval;
                    }else if(MDU_Constants.EQUIPMENT_DCT.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        objContractedBulkService.Equipment_Quantity_DCT = Decimal.valueOf(tempval);
                    }else if(MDU_Constants.EQUIPMENT_DTA.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        objContractedBulkService.Equipment_Quantity_DTA = Decimal.valueOf(tempval);
                    }else if(MDU_Constants.INDUSTRY_TYPE_BULK.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        objContractedBulkService.Indusrty_Type = tempval;
                    }else if(MDU_Constants.BULK_UNIT_OUTLET.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        objContractedBulkService.Bulk_Service_Unit = tempval;
                    }else if(MDU_Constants.BILLING_TYPE.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                        BillingType = tempval;                      
                    }
                    
                }  
                //Work On ECM Variable Name 
                if(MDU_Constants.AUTORENEW_TERMNOTICE_INTERNAL_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Name__c)){                  
                    Integer termNumber = 0;
                    for(String termParts : tempval.Split(MDU_Constants.SPLIT_TREM_BY)){
                        if(!String.IsBlank(termParts.trim()) && termParts.trim().isNumeric()){
                            termNumber=Integer.ValueOf(termParts);
                        }
                    }                  
                    if (termNumber > 0){                    
                        tempContract.put(customSetting.SFDC_Field_API_Name__c,termNumber); 
                        tempContract.Non_Renewal_Notice_Required__c = true;                       
                    }               
                }else if(MDU_Constants.AUTORENEW_LIMIT_INTERNAL_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Name__c)){ 
                    tempContract.Auto_Renewal_Limit__c = decimal.valueOf(tempval);
                }
                else if(MDU_Constants.PROPERTY_ID.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){              
                    //Set Property Id For Contract
                    contractPropertyIdMap.put(contractIdTemp,tempval);   
                    logMessage += MDU_Constants.PROPERTY_ID_STRING+tempval;
                }
                else if(MDU_Constants.OPPORTUNITY_ID.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){               
                    //Set Opportunity Id For Contract
                    contractOpportunityIdMap.put(contractIdTemp,tempval);
                    logMessage += MDU_Constants.OPPORTUNITY_ID_STRING+tempval;                   
                }// Contracted Bulk Service Logic
                else if(MDU_Constants.NUMB_OF_UNIT.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){
                    if(tempval.isNumeric()){
                        objContractedBulkService.Video_Units = Integer.valueOf(tempval);
                        objContractedBulkService.Data_Units = Integer.valueOf(tempval);
                        objContractedBulkService.Voice_Units = Integer.valueOf(tempval);
                    }                   
                }else if(MDU_Constants.BULK_RATE_INCR_NOTC_PER.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){                   
                    objContractedBulkService.Video_Increase_Notice = String.valueOf(tempval);
                    objContractedBulkService.Data_Increase_Notice = String.valueOf(tempval);
                    objContractedBulkService.Voice_Increase_Notice = String.valueOf(tempval);
                }else if(MDU_Constants.BULK_ACCOUNT_NUMBER.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c)){                       
                    tempContract.put(customSetting.SFDC_Field_API_Name__c, tempval);                                                   
                }
               
            }else{
                if(MDU_Constants.EFF_START_DATE_INT_NAME.equalsIgnoreCase(customSetting.ECM_Variable_Internal_Name__c) && String.IsBlank(tempval)){
                    tempContract.put(customSetting.SFDC_Field_API_Name__c, date.TODAY());
                }
               
            }
        }
        
        // Set Contract Fields Base On Custom Settings And Data Populated during iteration over custom setting data
        if(!isChannelAgreement) {            
            tempContract.Number_of_Channels__c = MDU_Constants.BLANK_VALUE;
            tempContract.Insertion_Equip_Maintained_By__c = null;
            tempContract.Insertion_Equip_Installed_By__c = null;
            tempContract.Insertion_Equip_Owned_By__c = null;
        }
        
        tempContract.Home_Installed_By__c = getInstallBy(chwInstalledBy , tempContract.Home_Installed_By__c);
        tempContract.Home_Run_Installed_By__c = getInstallBy(chrwWiring, tempContract.Home_Run_Installed_By__c);
        
        //Set 'Years' As Default Unit If Unit Come As Blank  
        if(String.IsBlank(tempContract.Contract_Term_Unit__c)){ 
            tempContract.Contract_Term_Unit__c = MDU_Constants.UNIT_TERM;
        }       
        if(String.IsBlank(tempContract.Renewal_Term_Unit__c)){ 
            tempContract.Renewal_Term_Unit__c = MDU_Constants.UNIT_TERM;
        } 
        
        //Set Value To 'Pre-Existing' If Its Value Come As Null In Loop 
        if(String.IsBlank(tempContract.Home_Paid_By__c)){ 
            tempContract.Home_Paid_By__c = MDU_Constants.DEFAULT_HOME_PAID_BY;
        } 
        if(String.IsBlank(tempContract.Home_Run_Paid_By__c)){ 
            tempContract.Home_Run_Paid_By__c= MDU_Constants.DEFAULT_HOME_PAID_BY;
        }
        if(String.IsBlank(tempContract.Distribution_Installed_by__c)){ 
            tempContract.Distribution_Paid_By__c = MDU_Constants.DEFAULT_HOME_PAID_BY;
        }       
       
        //As Per New Logic In C# Code, Set Lob Base On Subs in Response
        tempContract.Video__c = videoSubs == SUBS_DEFAULT ? MDU_Constants.NO_FLAG : MDU_Constants.YES_FLAG; 
        tempContract.Data__c = dataSubs == SUBS_DEFAULT ? MDU_Constants.NO_FLAG : MDU_Constants.YES_FLAG;      
        tempContract.Voice__c = voiceSubs == SUBS_DEFAULT ? MDU_Constants.NO_FLAG : MDU_Constants.YES_FLAG;
        
        tempContract.Converters_per_Unit__c = equipmentQuantityDCT + equipmentQuantityDTA ;
       
       /*    Set Below Fields To Null Base On Courtesy Account Type  */
        if(tempContract.Recipients_Video_Units__c != null && !MDU_Constants.recipientVideoUnitOutletset.contains(ecmCourtesyAccountType)){
            tempContract.Recipients_Video_Units__c = null;
        }
        if(tempContract.Video_Outlets__c != null && !MDU_Constants.videoDataOutletOutSet.contains(ecmCourtesyAccountType)){
            tempContract.Video_Outlets__c = null;
        }
        if(tempContract.Recipient_Video_Outlets__c != null & !MDU_Constants.recipientVideoUnitOutletset.contains(ecmCourtesyAccountType)){
            tempContract.Recipient_Video_Outlets__c = null;
        }
        if(tempContract.Data_Outlets__c != null & !MDU_Constants.videoDataOutletOutSet.contains(ecmCourtesyAccountType)){
            tempContract.Data_Outlets__c = null;
        }
        if(tempContract.Video_Service_Level__c != null & !MDU_Constants.videoDataServiceLevelSet.contains(ecmCourtesyAccountType)){
            tempContract.Video_Service_Level__c = null;
        }
        if(tempContract.Recipient_Video_Service_Level__c != null & !MDU_Constants.recipientVideoUnitOutletset.contains(ecmCourtesyAccountType)){
            tempContract.Recipient_Video_Service_Level__c = null;
        }
        if(tempContract.Data_Service_Level__c != null & !MDU_Constants.videoDataServiceLevelSet.contains(ecmCourtesyAccountType)){
            tempContract.Data_Service_Level__c = null;
        }
        /*    Set Below Fields To Null Base On Courtesy Account Type  */
        
        /* Set fields to default value Start */
        tempContract.Distribution_Exclusive_Use__c = MDU_Constants.YES_FLAG;
        tempContract.Distribution_Maintained_By__c  = MDU_Constants.COMACAST_USER ;   
        tempContract.Sub_Status__c = MDU_Constants.DEF_SUBSTATUS ;
        tempContract.Assignment_ID__c = MDU_Constants.DEFAULT_ASSIGN_ID;
        tempContract.Contract_Id_Hidden__c = contractIdTemp;    
        /* Set fields to default value End */               
             
        //Create Property Fee List
        List<Property_Fees__c> propertyFeesList = new List<Property_Fees__c>();
        if(isEligibleForAppLogging){
            logMessage += MDU_Constants.DOOR_FEE_FLAG +isDoorFeeExist + MDU_Constants.DOOR_FEE_CREATED + isDoorFeeRecordCreated;
            logMessage += MDU_Constants.REC_FEE_FLAG +isRecuringFeeExist + MDU_Constants.REC_FEE_CREATED + isRecurringFeeRecordCreated ;                 
        }
        if(propertyDoorFeeObject != null && isDoorFeeExist && isDoorFeeRecordCreated){                     
            if(!propertyFeeRecordTypeMap.isEmpty() && propertyFeeRecordTypeMap.get(MDU_Constants.DOOR_FEE) !=null){
                propertyDoorFeeObject.RecordTypeId = propertyFeeRecordTypeMap.get(MDU_Constants.DOOR_FEE); // Move name to final String or constants
            }           
            propertyFeesList.add(propertyDoorFeeObject);           
        }
        if(propertyRecurringFeeObject != null && isRecuringFeeExist && isRecurringFeeRecordCreated) {           
            //Here are some additional check apply over Recurring Fee 
            propertyRecurringFeeObject.Video_Revenue_Share_Type__c = (propertyRecurringFeeObject.Video_Minimum_Penetration_w_Payment__c == 0 || propertyRecurringFeeObject.Video_Payment_at_50_Penetration__c == propertyRecurringFeeObject.Video_Maximum_Pay_Rate__c) ? MDU_Constants.FLAT_RATE : MDU_Constants.SLIDING_RATE;
            
            propertyRecurringFeeObject.Data_Revenue_Share_Type__c = (propertyRecurringFeeObject.Data_Minimum_Penetration_w_Payment__c == 0 || propertyRecurringFeeObject.Data_Payment_at_50_Penetration__c == propertyRecurringFeeObject.Data_Maximum_Pay_Rate__c) ? MDU_Constants.FLAT_RATE : MDU_Constants.SLIDING_RATE;
            
            propertyRecurringFeeObject.Voice_Revenue_Share_Type__c = (propertyRecurringFeeObject.Voice_Minimum_Penetration_w_Payment__c == 0 || propertyRecurringFeeObject.Video_Payment_at_50_Penetration__c == propertyRecurringFeeObject.Voice_Maximum_Pay_Rate__c) ? MDU_Constants.FLAT_RATE : MDU_Constants.SLIDING_RATE;
            
            if(!propertyFeeRecordTypeMap.isEmpty() && propertyFeeRecordTypeMap.get(MDU_Constants.RECURRING_FEE) !=null){
                propertyRecurringFeeObject.RecordTypeId = propertyFeeRecordTypeMap.get(MDU_Constants.RECURRING_FEE); // Move name to final String or constants
            }           
            propertyRecurringFeeObject.Pay_Period__c = MDU_Constants.PAY_PERIOD_QUARTERLY;                      
            propertyRecurringFeeObject.Contract__c = tempContract.id;            
            propertyFeesList.add(propertyRecurringFeeObject);
        }                      
        //Add Contract And Its Child's To Corresponding Map       
        contractIdContractObjMap.put(contractIdTemp,tempContract);        
        if (MDU_Constants.BILLING_TYPE_RETAIL.equalsIgnoreCase(BillingType)){                
            //objContractedBulkService.Contract_Bulk = false;
            objContractedBulkService.RetailOnly = true;
        }else{                          
            //objContractedBulkService.Contract_Bulk = true;
        }
        if(isEligibleForAppLogging){
            logMessage += MDU_Constants.RETAIL_ONLY_BULK_SERVICE +objContractedBulkService.RetailOnly + MDU_Constants.NEW_LINE;
        }
        //Set ContractedBulkService Wrapper object
        contractIdBulkServiceMap.put(contractIdTemp,objContractedBulkService);                   
        //Set Property Fee List to map 
        contractIdPropertyFeeMap.put(contractIdTemp,propertyFeesList);      
        
        if(isAttachmentExist){
            contractIdAttachmentMap.put(contractIdTemp,attachmentObject);       
        }       
        wrapperContractMap.clear();
        attachmentObject = new Attachment();
        isAttachmentExist = false;
        objContractedBulkService = new MDU_ContractWriteBack.BulkServicesWrapper(); 
        
        if(isEligibleForAppLogging){
            logMessage += MDU_Constants.CONTRACT_END_TO_FETCH+contractIdTemp + MDU_Constants.PROCESS_ENDED;
        }
         executionLog = Mdu_ApplicationLogger.logMessage(logMessage, executionLog ,isEligibleForAppLogging);
    }
     
     
    /* Method Name : getTermValue 
    *  Description : Return term value base term object
    *  Parameter   : ContractTermWrapperClass termObject
    *  Return Type : String
    */
    public static String getTermValue(ContractTermWrapperClass termObject){
        
        if(termObject != null){
            return termObject.termValue;
        }           
        else{
            return null;
        }           
    }
    
    
    /* Method Name : getInstallBy 
    *  Description : Return Install By Field Value base on condition in method
    *  Parameter   : String wring, String installBy
    *  Return Type : String
    */
    public static String getInstallBy(String wring, String installBy){
        
        String returnValue = MDU_Constants.BLANK_VALUE;
        if(MDU_Constants.EXISTING_CONST.equalsIgnoreCase(wring)){
            returnValue = MDU_Constants.DEFAULT_HOME_PAID_BY;           
        }else if(MDU_Constants.INSTALL_CONST.equalsIgnoreCase(wring) || MDU_Constants.REWIRE_CONST.equalsIgnoreCase(wring)){
            if(MDU_Constants.OWNER_CONST.equalsIgnoreCase(installBy)){
                returnValue = MDU_Constants.OWNER_CONST;
            }else if(MDU_Constants.COMACAST_USER.equalsIgnoreCase(installBy)){
                returnValue = MDU_Constants.COMACAST_USER;
            }       
        }   
        return returnValue;
    }
     
     
    /* Method Name : setPropertyFeeRecordTypeId 
    *  Description : Create Map that will store property fee record type name and record type id
    *  Parameter   : None
    */
    public static void setPropertyFeeRecordTypeId(){              
       
        String labelName = System.Label.XfinityPropertyFeeRecordType;  
        if(!string.IsBlank(labelName)){
            for(String recordTypeLabel : labelName.split(SPLIT_CONSTANT)){              
                propertyFeeRecordTypeMap.put(recordTypeLabel,Schema.SObjectType.Property_Fees__c.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId());  
            }
        } 
    }
    
    
    /* Method Name : createContractMappingData 
    *  Description : Parse the Contract Response to create map that will store terms for contract
    *  Parameter   : String contractIdTemp
    */ 
     public static void createContractMappingData(String contractIdTemp){
        
        HttpResponse contractDataResponse = MDU_EmptorisUtility.GetContractRequest(contractIdTemp)   ;    
        Dom.Document doc = contractDataResponse.getBodyDocument();       
        Dom.XMLNode contractNode = doc.getRootElement();     
        if(contractDataResponse.getStatusCode() != MDU_Constants.SUCCESSSTATUSCODE && isEligibleForAppLogging){
            String  errorResponseData = '';
            errorResponseData = MDU_EmptorisUtility.responseErrorLog(contractNode);             
            executionLog = Mdu_ApplicationLogger.logMessage(MDU_Constants.CONTRACT_REQUEST_ERROR + errorResponseData  , executionLog, isEligibleForAppLogging);
        }       
       
        Dom.XmlNode node = contractNode.getChildElement(MDU_Constants.BODY_NODE, MDU_Constants.NODE_FUNCTION); //For Body Element                            
        for (Dom.XMLNode child: node.getChildren()) {          
           getContractNodeDetails(child);
        }       
    }       
    /* Method Name : getContractNodeDetails 
    *  Description : Logic to add terms in map through which we can create contract record
    *  Parameter   : Dom.XMLNode node
    */ 
    public static void getContractNodeDetails(Dom.XMLNode node){
                
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {                       
            //Check For Node Other Than 'terms'                    
            if(!MDU_Constants.TERMS_NODE.equalsIgnoreCase(node.getName())){                                  
                for(Dom.XMLNode childField2 : node.getChildElements()){                                 
                   getContractNodeDetails(childField2);                     
                }         
            }else{                     
                for(Dom.XMLNode child: node.getChildren()) {
                    ContractTermWrapperClass wrapperObject = new ContractTermWrapperClass();
                    for (Dom.XMLNode innerChild: child.getChildren()) {                       
                        if(innerChild.getNodeType() == DOM.XMLNodeType.ELEMENT) {                                                        
                            if(MDU_Constants.TERM_LABEL.equalsIgnoreCase(innerChild.getName())){
                               wrapperObject.termLabel = innerChild.getText();
                            }
                            else if(MDU_Constants.TERM_TYPE.equalsIgnoreCase(innerChild.getName())){                               
                               wrapperObject.termType = innerChild.getText();
                            }                           
                            else if(MDU_Constants.TERM_REFERENCE_FOR_NAME.equalsIgnoreCase(innerChild.getName())){
                                Dom.XMLNode[] childReferenceNode = innerChild.getChildren();
                                if(MDU_Constants.TERM_NAME.equalsIgnoreCase(childReferenceNode[0].getName())){
                                    wrapperObject.termName = childReferenceNode[0].getText();
                                }                                                      
                            }
                            else if(MDU_Constants.TERM_VALUE.equalsIgnoreCase(innerChild.getName())){                               
                                if(!String.IsBlank(wrapperObject.termType)){
                                    for(Dom.XMLNode childNodeValue : innerChild.getChildren()) {
                                        if(MDU_Constants.STRING_TYPE.equalsIgnoreCase(wrapperObject.termType) && MDU_Constants.TERM_STRING_VALUE.equalsIgnoreCase(childNodeValue.getName())){
                                            wrapperObject.termValue = childNodeValue.getText();
                                            break;
                                        }
                                        else if(MDU_Constants.DECIMAL_TYPE.equalsIgnoreCase(wrapperObject.termType) && MDU_Constants.TERM_NUMBER_VALUE.equalsIgnoreCase(childNodeValue.getName())){
                                            wrapperObject.termValue = childNodeValue.getText();
                                            break;
                                        }   
                                        else if(MDU_Constants.DATE_TYPE.equalsIgnoreCase(wrapperObject.termType) && MDU_Constants.TERM_DATE_VALUE.equalsIgnoreCase(childNodeValue.getName())){
                                            wrapperObject.termValue = childNodeValue.getText();
                                            break;
                                        }       
                                    }
                                }                                                                
                            }                                                  
                        }           
                    }                       
                    wrapperContractMap.put(wrapperObject.termName , wrapperObject);                             
                }                
            }            
        }         
    }    
     
     
    /*
    * Wrapper class to add each term in contract so that we can create Map of wrapper object 
    */  
    public class ContractTermWrapperClass{
        public String termLabel{get;set;}
        public String termType{get;set;}  
        public String termName{get;set;}   
        public String termValue{get;set;}  
    }
    
    
    /* Method Name : createContractAttachment 
    *  Description : Parse the attachment response for contract 
    *  Parameter   : string contractIdTemp
    */   
    public static void createContractAttachment(String contractIdTemp){                    
        HttpResponse contractAttachmentResp = MDU_EmptorisUtility.GetContractLanguageRequest(contractIdTemp);
        Dom.Document doc = contractAttachmentResp.getBodyDocument();       
        Dom.XMLNode getContractDetailRes = doc.getRootElement();        
        if(contractAttachmentResp.getStatusCode() != MDU_Constants.SUCCESSSTATUSCODE && isEligibleForAppLogging){
            String  errorResponseData = '';
            errorResponseData = MDU_EmptorisUtility.responseErrorLog(getContractDetailRes);             
            executionLog = Mdu_ApplicationLogger.logMessage(MDU_Constants.ATACHMENT_REQUEST_ERROR + errorResponseData, executionLog, isEligibleForAppLogging);
        }       
                     
        //For Body Element                       
        Dom.XmlNode node = getContractDetailRes.getChildElement(MDU_Constants.BODY_NODE, MDU_Constants.NODE_FUNCTION); 
        for (Dom.XMLNode child: node.getChildren()) {          
           getRecursivelyContractAttachment(child);
        }                          
    }
    
    
    /* Method Name : getRecursivelyContractAttachment 
    *  Description : Here we are parsing HttpResponse to create attachment record base on contract id
    *  Parameter   : Dom.XMLNode node
    */
    public static void getRecursivelyContractAttachment(Dom.XMLNode node){        
       
       if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {                       
            //Check For Node Other Than 'Id'                      
            if(!MDU_Constants.RESPONSEDATA_NODE.equalsIgnoreCase(node.getName())){                  
                for(Dom.XMLNode childField2 : node.getChildElements()){                                 
                   getRecursivelyContractAttachment(childField2);                     
                }         
            }else{                                                  
                Attachment dataFile = new Attachment();
                for(Dom.XMLNode child: node.getChildren()) {                   
                    if(child.getNodeType() == DOM.XMLNodeType.ELEMENT) {                        
                        if(MDU_Constants.CONTRACTLANG_NODE.equalsIgnoreCase(child.getName())){                           
                            for(Dom.XMLNode child2: child.getChildren()) {                                        
                                for(Dom.XMLNode child3: child2.getChildren()) {                            
                                    if(MDU_Constants.DATA_NODE.equalsIgnoreCase(child3.getName())){                                             
                                        isAttachmentExist = true ;
                                        String data = EncodingUtil.base64Encode(Blob.valueOf(child3.getText()));
                                        Blob responseAsBlob = EncodingUtil.base64Decode(child3.getText());                                            
                                        dataFile.body = responseAsBlob;                                                                                      
                                    }else if(MDU_Constants.FILENAME_NODE.equalsIgnoreCase(child3.getName())){
                                        dataFile.Name = child3.getText(); 
                                    }else if(MDU_Constants.MOMETYPE_NODE.equalsIgnoreCase(child3.getName())){
                                        dataFile.ContentType = child3.getText();//mime type for docx 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'; 
                                    }
                                }                                   
                            }                           
                        }                                            
                    }                    
                }         
                attachmentObject =  dataFile;              
            }
        }
    }       
        
    /* Method Name : getRecursivelyNode 
    *  Description :This method recursively iterate over xml response and get create set if contract id
    *  Parameter   : Dom.XMLNode node
    */
    public static void getRecursivelyNode(Dom.XMLNode node){
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {                       
            //Check For Node Other Than 'Id'
            if(!MDU_Constants.NODE_TO_FIND.equalsIgnoreCase(node.getName())){
                for (Dom.XMLNode child: node.getChildElements()) {
                    getRecursivelyNode(child);
                }                           
            }//Else Create Set If 'Id'
            else{
                ContractIdSet.add(node.getText());                
            }
        }       
    }
    
      
   
    /* Method Name : getUpdatedContractedServiceAndContract
    *  Description : This method create contracted bulk service and update Contract record . 
    *  Parameter   : contractIdBulkServiceList and contractIdObjectMap
    *  Return Type : Map<Id,List<Contracted_Bulk_Service__c>>
    */
    public static Map<String,List<Contracted_Bulk_Service__c>> getUpdatedContractedServiceAndContract(Map<String,MDU_ContractWriteBack.BulkServicesWrapper> contractIdBulkServiceList, Map<String, Contract__c> contractIdObjectMap, Map<String,Mdu_Property__c> contractLegacyIdPropertyMap){
        Map<String,List<Contracted_Bulk_Service__c>> contactLegcyIdBulkServListMap = new Map<String,List<Contracted_Bulk_Service__c>>();
       
        for(String legacyContractId : contractIdObjectMap.keyset()){
            if(contractIdBulkServiceList.get(legacyContractId) != null){
                    List<Contracted_Bulk_Service__c> bulkServiceList = SetUpBulkServices(contractIdBulkServiceList.get(legacyContractId), contractIdObjectMap.get(legacyContractId), contractLegacyIdPropertyMap.get(legacyContractId));
                    if(!bulkServiceList.isEmpty()){
                        contactLegcyIdBulkServListMap.put(legacyContractId, bulkServiceList);
                    }
            }           
        }                  
        return contactLegcyIdBulkServListMap;
    }
  
  
   /* 
    *   This method create Contracted Bulk service record based on Billing type set for Video,Data and Voice
    */
    public static List<Contracted_Bulk_Service__c> SetUpBulkServices(MDU_ContractWriteBack.BulkServicesWrapper objContractedBulkServiceDTO, Contract__c sfdcContractObject, Mdu_Property__c propertyObject){
         
        MDU_ContractWriteBack.BulkServicesWrapper bulkServiceObject = new MDU_ContractWriteBack.BulkServicesWrapper();
        bulkServiceObject = objContractedBulkServiceDTO;       
        List<Contracted_Bulk_Service__c> contractedBulkServiceList = new List<Contracted_Bulk_Service__c>();       
        
        if (sfdcContractObject.Video_Outlets_Per_Unit__c != null 
            && sfdcContractObject.Video_Outlets_Per_Unit__c > 0){        
            bulkServiceObject.Video_Outlets_Per_Unit = String.valueOf(sfdcContractObject.Video_Outlets_Per_Unit__c);
        }
        
        if((MDU_Constants.BULK_TYPE.equalsIgnoreCase(sfdcContractObject.Video_Billing_Type__c))
            && (MDU_Constants.LOB_BILLING_TYPE_NOT_SERVICE.equalsIgnoreCase(sfdcContractObject.Data_Billing_Type__c) || String.isBlank(sfdcContractObject.Data_Billing_Type__c))
            && (MDU_Constants.LOB_BILLING_TYPE_NOT_SERVICE.equalsIgnoreCase(sfdcContractObject.Voice_Billing_Type__c) || String.isBlank(sfdcContractObject.Voice_Billing_Type__c))){           
            contractedBulkServiceList.add(getVideoBulkService(bulkServiceObject, serviceType));            
            setVideoContractAttribute(bulkServiceObject, sfdcContractObject, false);            
            setDataContractAttribute(bulkServiceObject, sfdcContractObject, true);
            setVoiceContractAttribute(bulkServiceObject, sfdcContractObject, true); 
            flushDataForNotServiceLOB(sfdcContractObject);
            flushVoiceForNotServiceLOB(sfdcContractObject);
        }else{
            //Video Billing Type LOB check
            if(MDU_Constants.BULK_TYPE.equalsIgnoreCase(sfdcContractObject.Video_Billing_Type__c)){
                contractedBulkServiceList.add(getVideoBulkService(bulkServiceObject, MDU_Constants.SERVICE_TYPE_VIDEO));
                setVideoContractAttribute(bulkServiceObject, sfdcContractObject, false);
            }else{
                if(MDU_Constants.LOB_BILLING_TYPE_NOT_SERVICE.equalsIgnoreCase(sfdcContractObject.Video_Billing_Type__c)){
                   flushVideoForNotServiceLOB(sfdcContractObject);
                }
                setVideoContractAttribute(bulkServiceObject, sfdcContractObject, true);
            }
            
            //Data Billing Type LOB check
            if(MDU_Constants.BULK_TYPE.equalsIgnoreCase(sfdcContractObject.Data_Billing_Type__c)){
                contractedBulkServiceList.add(getDataBulkService(bulkServiceObject));
                setDataContractAttribute(bulkServiceObject, sfdcContractObject, false);
            }else{
                if(MDU_Constants.LOB_BILLING_TYPE_NOT_SERVICE.equalsIgnoreCase(sfdcContractObject.Data_Billing_Type__c)){
                   flushDataForNotServiceLOB(sfdcContractObject);
                }
                setDataContractAttribute(bulkServiceObject, sfdcContractObject, true);
            }
            
            //Voice Billing Type LOB check
            if(MDU_Constants.BULK_TYPE.equalsIgnoreCase(sfdcContractObject.Voice_Billing_Type__c)){
                contractedBulkServiceList.add(getVoiceBulkService(bulkServiceObject));
                setVoiceContractAttribute(bulkServiceObject, sfdcContractObject, false);
            }else{
                if(MDU_Constants.LOB_BILLING_TYPE_NOT_SERVICE.equalsIgnoreCase(sfdcContractObject.Voice_Billing_Type__c)){
                   flushVoiceForNotServiceLOB(sfdcContractObject);
                }
                setVoiceContractAttribute(bulkServiceObject, sfdcContractObject, true);
            }
        }
               
        return contractedBulkServiceList;
    }
    
    
   /*
    * This method set Contract Bulk information based on  Billing type set for Video LOB 
    */
    private static void setVideoContractAttribute(MDU_ContractWriteBack.BulkServicesWrapper bulkServicesObject, Contract__c sfdcContractObject, boolean isSetToEmpty){
        if(!isSetToEmpty){
            if(!String.isBlank(bulkServicesObject.Video_Increase_Notice)){        
                sfdcContractObject.Video_Increase_Notice__c = Decimal.valueOf(bulkServicesObject.Video_Increase_Notice);
                sfdcContractObject.Video_Increase_Period__c = MDU_Constants.ANNUAL_INCREASE_PERIOD;
            }
        }else{
            //Blank out Video Bulk information as Lob is Not 'Bulk' 
            sfdcContractObject.Video_Rate_Escalator__c = null;
            sfdcContractObject.Video_Outlets_Per_Unit__c = null;
            sfdcContractObject.Video_Increase_Notice__c = null;
            sfdcContractObject.Video_Increase_Period__c = null;
        }
        
    }
    
    
   /*
    * This method set Contract Bulk information based on  Billing type set for data LOB 
    */
    private static void setDataContractAttribute(MDU_ContractWriteBack.BulkServicesWrapper bulkServicesObject, Contract__c sfdcContractObject, boolean isSetToEmpty){
        if(!isSetToEmpty){
            if (!String.isBlank(bulkServicesObject.Data_Increase_Notice)) {       
                sfdcContractObject.Data_Increase_Notice__c = Decimal.valueOf(bulkServicesObject.Data_Increase_Notice);
                sfdcContractObject.Data_Increase_Period__c = MDU_Constants.ANNUAL_INCREASE_PERIOD;
            }
        }else{
            //Blank out Data Bulk information as Lob is Not 'Bulk' 
            sfdcContractObject.Data_Rate_Escalator__c = null;
            sfdcContractObject.Data_Outlets_Per_Unit__c = null;
            sfdcContractObject.Data_Increase_Notice__c = null;
            sfdcContractObject.Data_Increase_Period__c = null;
        }
            
    }   
    
    
   /*
    *  This method set Contract Bulk information based on  Billing type set for Voice LOB 
    */
    private static void setVoiceContractAttribute(MDU_ContractWriteBack.BulkServicesWrapper bulkServicesObject, Contract__c sfdcContractObject, boolean isSetToEmpty){
        if(!isSetToEmpty){
            if (!String.isBlank(bulkServicesObject.Voice_Increase_Notice)) {       
                sfdcContractObject.Voice_Increase_Notice__c = Decimal.valueOf(bulkServicesObject.Voice_Increase_Notice);
                sfdcContractObject.Voice_Increase_Period__c = MDU_Constants.ANNUAL_INCREASE_PERIOD;
            }   
        }else{
            //Blank out Voice Bulk information as Lob is Not 'Bulk' 
            sfdcContractObject.Voice_Rate_Escalator__c = null;
            sfdcContractObject.Voice_Outlets_Per_Unit__c = null;
            sfdcContractObject.Voice_Increase_Notice__c = null;
            sfdcContractObject.Voice_Increase_Period__c = null;
        }   
        
    }
    
   /* Method Name : getVideoBulkService 
    *  Description : Create Contracted bulk service record for video bulk and Set Service type as 'Video Only' 
    *  Parameter   : name="bulkServicesObject" BulkServicesWrapper object used to contain variables used in this logic  
                     name="videoserviceType" service type to create contracted bulk service
    *  Return Type : Contracted_Bulk_Service__c object
    */
    private static Contracted_Bulk_Service__c getVideoBulkService(MDU_ContractWriteBack.BulkServicesWrapper bulkServicesObject, string videoserviceType){
        
        Contracted_Bulk_Service__c contractBulkService = new Contracted_Bulk_Service__c();
        contractBulkService.Service_Type__c = videoserviceType;
        contractBulkService.Units__c = bulkServicesObject.Video_Units;
        
        if(!String.isBlank(bulkServicesObject.Video_Per_Unit_Fee)){
            Decimal perUnitFeeTemp = Decimal.valueOf(bulkServicesObject.Video_Per_Unit_Fee);
            
            if (MDU_Constants.HEALTHCARE.equalsIgnoreCase(bulkServicesObject.Indusrty_Type) 
                    && !String.isBlank(bulkServicesObject.Video_Outlets_Per_Unit) && !String.isBlank(bulkServicesObject.Video_Per_Unit_Fee)) {  
                contractBulkService.Rate_Per_Unit__c = calculateOutletBasedPerUnitFee(Integer.valueOf(bulkServicesObject.Video_Outlets_Per_Unit), perUnitFeeTemp);
            }else if (MDU_Constants.EDUCATION.equalsIgnoreCase(bulkServicesObject.Indusrty_Type) && MDU_Constants.BULK_SERV_UNIT.equalsIgnoreCase(bulkServicesObject.Bulk_Service_Unit)  
                        && !String.isBlank(bulkServicesObject.Video_Outlets_Per_Unit)){         
                contractBulkService.Rate_Per_Unit__c = calculateOutletBasedPerUnitFee(Integer.valueOf(bulkServicesObject.Video_Outlets_Per_Unit), perUnitFeeTemp);
            }else{          
                contractBulkService.Rate_Per_Unit__c = perUnitFeeTemp;
            }
        }
        return  contractBulkService;
    }
    
    
   /* Method Name : calculateOutletBasedPerUnitFee 
    *  Description : Create Contracted bulk service record for video bulk and Set Service type as 'Video Only'
    *  Parameter   : videoOutLet as Integer And perUnitFee as perUnitFee
    *  Return Type : Multiplication value of videoOutLet and perUnitFee 
    */
    public static Decimal calculateOutletBasedPerUnitFee(Integer videoOutLet, Decimal perUnitFee){
        return (videoOutLet * perUnitFee);
    }
    
   
   /* Method Name : getDataBulkService 
    *  Description :  Create Contracted bulk service record for Data bulk
    *  Parameter   : name="bulkServicesObject">BulkServicesWrapper object used to contain variables used in this logic ,    
    *  Return Type : Contracted_Bulk_Service__c object
    */
    public static Contracted_Bulk_Service__c getDataBulkService(MDU_ContractWriteBack.BulkServicesWrapper bulkServicesObject)
    {
      
        string serviceTypeID = MDU_Constants.SERVICE_TYPE_INTERNET;
        Contracted_Bulk_Service__c contractBulkServiceTemp = new Contracted_Bulk_Service__c();
       
        contractBulkServiceTemp.Service_Type__c = serviceTypeID;
        if(!String.isBlank(bulkServicesObject.Data_Per_Unit_Fee)){
            contractBulkServiceTemp.Rate_Per_Unit__c = Decimal.valueOf(bulkServicesObject.Data_Per_Unit_Fee);
        }       
        contractBulkServiceTemp.Units__c = bulkServicesObject.Data_Units;

        return contractBulkServiceTemp;
    }

    
   /* Method Name : getVoiceBulkService 
    *   Description :  Create Contracted bulk service record for Voice bulk
    *   Parameter   : name="bulkServicesObject">BulkServicesWrapper object used to contain variables used in this logic ,   
    *   Return Type : Contracted_Bulk_Service__c object
    */
    public static Contracted_Bulk_Service__c getVoiceBulkService(MDU_ContractWriteBack.BulkServicesWrapper bulkServicesObject)
    {
        
        string serviceTypeID = MDU_Constants.SERVICE_TYPE_VOICE;
        Contracted_Bulk_Service__c contractBulkServiceTemp = new Contracted_Bulk_Service__c();
       
        contractBulkServiceTemp.Service_Type__c = serviceTypeID;
        if(!String.isBlank(bulkServicesObject.Voice_Per_Unit_Fee)){
            contractBulkServiceTemp.Rate_Per_Unit__c = Decimal.valueOf(bulkServicesObject.Voice_Per_Unit_Fee);  
        }        
        contractBulkServiceTemp.Units__c = bulkServicesObject.Data_Units;

        return contractBulkServiceTemp;
    }
    
   /* 
    *   Clear Video LOB For Not Serviced Billing Type 
    */ 
    public static void flushVideoForNotServiceLOB(Contract__c sfdcContractObject){
        sfdcContractObject.Video__c = MDU_Constants.NO;
        sfdcContractObject.Video_Billing_Type__c = null;
        sfdcContractObject.Video_All_Units__c = false;
    }
    
   /* 
    *   Clear Data LOB For Not Serviced Billing Type 
    */
    public static void flushDataForNotServiceLOB(Contract__c sfdcContractObject){
        sfdcContractObject.Data__c = MDU_Constants.NO;
        sfdcContractObject.Data_Billing_Type__c = null;
        sfdcContractObject.Data_All_Units__c = false;
    }
    
   /* 
    *   Clear Voice LOB For Not Serviced Billing Type 
    */
    public static void flushVoiceForNotServiceLOB(Contract__c sfdcContractObject){
        sfdcContractObject.Voice__c = MDU_Constants.NO;
        sfdcContractObject.Voice_Billing_Type__c = null;
        sfdcContractObject.Voice_All_Units__c = false;
    }
    
   /*
    * Wrapper class to create ContractedBulkService record  with retail only false true
    */
    public class BulkServicesWrapper
    {
        public boolean RetailOnly { get; set; }

        public Integer User_ID { get; set; }
        public String Indusrty_Type { get; set; }
        public String Bulk_Service_Type { get; set; }
        public String Bulk_Service_Unit { get; set; }

        public Decimal Equipment_Quantity_DCT { get; set; }
        public Decimal Equipment_Quantity_DTA { get; set; }

        public Integer Video { get; set; }
        public String Video_Billing_Type { get; set; }
        public Integer Video_Billing_Type_ID { get; set; }
        public String Video_Outlets_Per_Unit { get; set; }
        public Integer Video_Increase_Period { get; set; }
        public String Video_Increase_Notice { get; set; }
        public string Video_Rate_Increase_Other { get; set; }

        public Integer Video_Units { get; set; }
        public string Video_Per_Unit_Fee { get; set; }

        public Integer Data { get; set; }
        public string Data_Billing_Type { get; set; }
        public Integer Data_Billing_Type_ID { get; set; }
        public Integer Data_Outlets_Per_Unit { get; set; }
        public Integer Data_Increase_Period { get; set; }
        public String Data_Increase_Notice { get; set; }
        public Integer Data_Units { get; set; }
        public string Data_Per_Unit_Fee { get; set; }

        public Integer Voice { get; set; }
        public string Voice_Billing_Type { get; set; }
        public Integer Voice_Billing_Type_ID { get; set; }
        public Integer Voice_Outlets_Per_Unit { get; set; }
        public Integer Voice_Increase_Period { get; set; }
        public String Voice_Increase_Notice { get; set; }
        public Integer Voice_Units { get; set; }
        public string Voice_Per_Unit_Fee { get; set; }

        public BulkServicesWrapper()
        {
            //set retail only to true - it will get set to false from bulk triggers
            this.RetailOnly = true;
        }
    }
            
}