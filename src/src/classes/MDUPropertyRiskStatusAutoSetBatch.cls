/**************************************************************************************************
* Name : MDUPropertyRiskStatusAutoSetBatch
  Description : This batch class created to create batch job that will auto set Risk Status of property base on various condition mention in execute method  
  User Story : 78
  Date : 06 January 2015
  Author : Ashish Sonawane
* Last Modified By : Amit Kumar Pradhan
  Last Modified Date : 25-Feb-2017
  User Story : US917335
  Description : replacing inner query with map and made the batch parameterized. 
                And calling "MDUPropertyRatingAutoSetBatch" batch class from finish method.
***************************************************************************************************/
global class MDUPropertyRiskStatusAutoSetBatch implements Database.Batchable<sObject>, Database.Stateful { 

    private static final string BATCH_JOB_NAME = System.Label.Xffinity_Property_Risk_Status_Auto_Set_Batch_Name;
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final String NEW_VAL = System.Label.JOB_StatusNew;
    private static final String SPACE_BLANK = ' ';
    private static final String BULK_VAL_VIDEO = System.Label.PROP_VideoBillingType_Bulk;
    private static final String RETAIL_VAL_VIDEO = System.Label.PROP_VideoBillingType_Retail;
    private static final String BULK_VAL_VOICE = System.Label.PROP_VoiceBillingType_Bulk;
    private static final String RETAIL_VAL_VOICE = System.Label.PROP_VoiceBillingType_Retail;
    private static final String BULK_VAL_DATA = System.Label.PROP_DataBillingType_Bulk;
    private static final String RETAIL_VAL_DATA = System.Label.PROP_DataBillingType_Retail;
    private static final String BULK_VAL_BULKSTATUS = System.Label.PROP_PropertyBulkStatusBulk;
    private static final String RETAIL_VAL_BULKSTATUS = System.Label.PROP_PropertyBulkStatusRetail; 
    private static final String YES_VAL_VIDEO = System.Label.PROP_VideoServiced_Yes;
    private static final String NO_VAL_VIDEO = System.Label.Contract_Video_No;
    private static final String YES_VAL_VOICE = System.Label.PROP_VoiceServiced_Yes;
    private static final String NO_VAL_VOICE = System.Label.Contract_Voice_No;
    private static final String YES_VAL_DATA = System.Label.PROP_DataServiced_Yes;
    private static final String NO_VAL_DATA = System.Label.Contract_Data_No;
    private static final String NEW_LINE = '\n\r';  
    private static final String LABEL_NAME_SPLIT = ';'; 
    private static final String NO_CONTRACT = System.Label.PROP_RiskStatus_NoContract;
    private static final String FRANCHISE_VAL = System.Label.PROP_RiskStatus_Franchise;
    private static final String EXPIRED_VAL_CONTRACT_STATUS = System.Label.PROP_ContractStatus_Expired;
    private static final String EXPIRED_VAL_RISK_STATUS = System.Label.Contract_RiskStatus_Expired;
    private static final String NOT_SERVICED = System.Label.PROP_BulkStatus_NotServiced;
    private static final String AUTO_RENEWED_CONTRACT = System.Label.Contract_SubStatus_AutoRenewed;
    private static final String AUTO_RENEWED_PROPERTY = System.Label.PROP_RiskStatus_AutoRenewed;
    private static final String SYSTEM_EXCEPTION = 'System Exception - ';
    private static final String WITHIN_0_6 = System.Label.PROP_RiskStatus_WithIn0To6;
    private static final String WITHIN_6_12 = System.Label.PROP_RiskStatus_WithIn6To12;
    private static final String WITHIN_12_24 = System.Label.PROP_RiskStatus_WithIn12To24;
    private static final String ABOVE_24 = System.Label.PROP_RiskStatus_Above24;
    private static final String LIMIT_25 = ' limit 25';
    private Id jobStatusId=null;
    private String query='';
    private static final Set<String> recordTypeIds = new Set<String>();
    
    //Start : Added By Amit Kumar Pradhan(Part Of US917335)
    /* Constructor for batch class MDUPropertyRiskStatusAutoSetBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-  'SELECT Id ,Risk_Status__c, Comcast_Video_Serviced__c, Comcast_Voice_Serviced__c, Comcast_Data_Serviced__c, Video_Billing_Type__c, Voice_Billing_Type__c, Data_Billing_Type__c, Number_of_Units__c FROM MDU_Property__c WHERE RecordTypeId IN : recordTypeIds'
     */
    global MDUPropertyRiskStatusAutoSetBatch(String query)
    {
        this.query=query;
    }
    //End : Added By Amit Kumar Pradhan(Part Of US917335)
    
    /*
    * Query execution for AutoRenewMduContractBatch
    */
    global Database.QueryLocator start(Database.BatchableContext bContext) {
  
        //Create Job Status Object
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME+ ' - ' + Datetime.now();
        jobStatus.Status__c = NEW_VAL;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Total_RGU_Activations_Processed__c = 0;
        jobStatus.Total_RGU_Orders_Processed__c = 0;
        jobStatus.Total_RGU_ORders_Upserted_Today__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = SPACE_BLANK;
        jobStatus.Number_Of_Fallouts__c = 0;
        insert jobStatus;

        jobStatusId = jobStatus.Id; 
        
        String labelName = System.Label.XfinityPropertyRecordType;          
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeIds.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }   
        
        //query string is commented as we are passing the query string as parameter(Part Of US917335)
        /* string query = ' Select id ,Risk_Status__c,Comcast_Video_Serviced__c,Comcast_Voice_Serviced__c,Comcast_Data_Serviced__c, '+
                       ' Video_Billing_Type__c, Voice_Billing_Type__c, Data_Billing_Type__c, Number_of_Units__c,'+  
                       ' (SELECT Id, Contract_Status__c,Video_Billing_Type__c, Voice_Billing_Type__c ,Data_Billing_Type__c, Effective_Date__c, Status__c, '+
                       ' Initial_Effective_Date__c, Expiration_Date__c, Life_of_Franchise__c, Sub_Status__c FROM Contracts1__r '+
                       ' where Archived__c != True AND (Video_Billing_Type__c != Null Or Data_Billing_Type__c != Null Or Voice_Billing_Type__c != Null)) ' +
                       ' from MDU_Property__c Where RecordTypeId IN : recordTypeIds';  */
                       
        //' from MDU_Property__c Where RecordTypeId IN : recordTypeIds '; 
        if(Test.isRunningTest()) {
            query+= LIMIT_25;
        }      
        return Database.getQueryLocator(query);
    }
    
    
    /*
    * Execute business logic on data come in propertyList list
    */
    global void execute(Database.BatchableContext bContext, LIST<MDU_Property__c> propertyList){      
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);  
        try{                   
            Map<id,List<Contract__c>> propertyIdContractListMap = new Map<id,List<Contract__c>>();
            Set<String> propertyIdSet = new Set<String>();
            for(MDU_Property__c instantProperty : propertyList){
                propertyIdSet.add(instantProperty.Id);
            }
            
            //Start : Added By Amit Kumar Pradhan(Part Of US917335)
            //Creating Map of property with contract list
            for(Contract__c contractObj : [SELECT Id, Property__c,Contract_Status__c, Video_Billing_Type__c, Voice_Billing_Type__c,
                                            Data_Billing_Type__c,Effective_Date__c, Status__c, Initial_Effective_Date__c, Expiration_Date__c,
                                            Life_of_Franchise__c,Sub_Status__c FROM Contract__c WHERE Archived__c = False 
                                            AND Property__c IN: propertyIdSet
                                            AND (Video_Billing_Type__c != Null Or Data_Billing_Type__c != Null Or Voice_Billing_Type__c != Null) 
                                            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                List<Contract__c> tempContractList = new List<Contract__c>();
                if(propertyIdContractListMap.containsKey(contractObj.Property__c)){
                    tempContractList = propertyIdContractListMap.get(contractObj.Property__c);
                }
                tempContractList.add(contractObj);
                propertyIdContractListMap.put(contractObj.Property__c,tempContractList);
                
            }
            
            //Code commented as we are creating propertyIdContractListMap in the above part
            /*for(MDU_Property__c instantProperty : propertyList){          
                propertyIdContractListMap.put(instantProperty.Id, instantProperty.Contracts1__r); //Map of Property Id To Contract List  
            }*/
            //End : Added By Amit Kumar Pradhan(Part Of US917335)
            
            List<MDU_Property__c> propertyUpdateList =new List<MDU_Property__c>();     
            //Iterate through list of property         
			boolean propertyUpdated = false;      
            for(MDU_Property__c instantProperty : propertyList){ 
				propertyUpdated = false;
				if((Variable_Setting__c.getInstance('MDUBatchSwitch').Value__c).equalsIgnoreCase('True'))
				{
					if(instantProperty.Comcast_Video_Serviced__c == YES_VAL_VIDEO 
	                    || instantProperty.Comcast_Voice_Serviced__c == YES_VAL_VOICE 
	                    || instantProperty.Comcast_Data_Serviced__c == YES_VAL_DATA){
	                    
	                    List<Contract__c> listOfContract = new List<Contract__c>();
	                    if(!propertyIdContractListMap.isEmpty() && propertyIdContractListMap.containsKey(instantProperty.Id)){
	                        listOfContract = propertyIdContractListMap.get(instantProperty.Id);
	                    }
	                    if((instantProperty.Video_Billing_Type__c == BULK_VAL_VIDEO || instantProperty.Voice_Billing_Type__c == BULK_VAL_VOICE || instantProperty.Data_Billing_Type__c == BULK_VAL_DATA) 
	                        && instantProperty.Number_of_Units__c>=5){     
							if(instantProperty.Bulk_Status__c != BULK_VAL_BULKSTATUS)
							{
								instantProperty.Bulk_Status__c = BULK_VAL_BULKSTATUS;
								propertyUpdated = true;
							} 										                            
	                    }else{                        
							if(instantProperty.Bulk_Status__c != RETAIL_VAL_BULKSTATUS)
							{
								instantProperty.Bulk_Status__c = RETAIL_VAL_BULKSTATUS;
								propertyUpdated = true;  
							}  
	                    }                   
	                    if(listOfContract.isEmpty()){
							if(instantProperty.Risk_Status__c  != NO_CONTRACT)
							{
								instantProperty.Risk_Status__c  = NO_CONTRACT;
								propertyUpdated = true;
							} 														
	                    }else{                                                
	                        Contract__c objContractWithHightestInitEffDate=null; 
	                        Boolean isBulk = false;                        
	                        if(instantProperty.Video_Billing_Type__c == BULK_VAL_VIDEO || instantProperty.Voice_Billing_Type__c == BULK_VAL_VOICE || instantProperty.Data_Billing_Type__c == BULK_VAL_DATA){
	                            isBulk = true;                               
	                        }
	                        else{
	                            isBulk = false;
	                        }
	                        List<Contract__c> listContractsforCurrentProperty = new List<Contract__c>();
	                        if(!propertyIdContractListMap.isEmpty() && propertyIdContractListMap.containsKey(instantProperty.Id)){
	                            listContractsforCurrentProperty = propertyIdContractListMap.get(instantProperty.Id);
	                        }
	                        if(isBulk == true){                                
	                            //Find Contract Having Highest Initial Effective Date And Any Billing Type As Bulk
	                            if(!listContractsforCurrentProperty.isEmpty() && listContractsforCurrentProperty!=null){
	                                for(Contract__c contractTemp: listContractsforCurrentProperty){                                                   
	                                   if(contractTemp.Initial_Effective_Date__c != null && 
	                                    (contractTemp.Video_Billing_Type__c == BULK_VAL_VIDEO 
	                                    || contractTemp.Voice_Billing_Type__c == BULK_VAL_VOICE 
	                                    ||  contractTemp.Data_Billing_Type__c == BULK_VAL_DATA )){
	                                    
	                                        if(objContractWithHightestInitEffDate== null){
	                                            objContractWithHightestInitEffDate = contractTemp; 
	                                        }else{                
	                                            if(contractTemp.Initial_Effective_Date__c> objContractWithHightestInitEffDate.Initial_Effective_Date__c){
	                                                objContractWithHightestInitEffDate = contractTemp;                                                        
	                                            }
	                                        }
	                                    }                                                       
	                                }
	                            }
	                            if(objContractWithHightestInitEffDate==null && listContractsforCurrentProperty!=null){
	                                isBulk = false;
	                            }
	                        }                                
	                             //Find Contract Having Highest Initial Effective Date And Any Billing Type As Retail , This will true when we don't have any Contract__c with bulk type
	                        if(isBulk == false){    
	                            for(Contract__c contractTemp: listContractsforCurrentProperty) {                                       
	                                if(contractTemp.Initial_Effective_Date__c != null && (contractTemp.Video_Billing_Type__c == RETAIL_VAL_VIDEO || contractTemp.Voice_Billing_Type__c == RETAIL_VAL_VOICE ||  contractTemp.Data_Billing_Type__c == RETAIL_VAL_DATA ))   {                          
	                                    if(objContractWithHightestInitEffDate == null){                                                               
	                                        objContractWithHightestInitEffDate =contractTemp; 
	                                    }else{                                                                 
	                                        if(contractTemp.Initial_Effective_Date__c > objContractWithHightestInitEffDate.Initial_Effective_Date__c ){
	                                            objContractWithHightestInitEffDate =contractTemp;                                                 
	                                        }
	                                    } 
	                                }                                     
	                            }                                
	                        }                                                        
	                        if(objContractWithHightestInitEffDate != null){ 
	                        //If any contract with initial effective date                                                                                           
	                            if(objContractWithHightestInitEffDate.Life_of_Franchise__c){    

									if(instantProperty.Risk_Status__c != FRANCHISE_VAL)
									{
										instantProperty.Risk_Status__c  = FRANCHISE_VAL;
										propertyUpdated = true;
									} 
	                            }else{                              
	                                if(objContractWithHightestInitEffDate.Contract_Status__c != null && objContractWithHightestInitEffDate.Contract_Status__c.equalsIgnoreCase(EXPIRED_VAL_CONTRACT_STATUS)){  
										if(instantProperty.Risk_Status__c != EXPIRED_VAL_RISK_STATUS)
										{
											instantProperty.Risk_Status__c  = EXPIRED_VAL_RISK_STATUS;
											propertyUpdated = true;
										}                                           
	                                }else{                                            
	                                    //Find Month Difference between initial effective date and expiration date , use that month to set risk status 
	                                    Integer monthdifference=null;
	                                    Date dtToday = Date.newInstance(date.today().Year(), date.today().Month(), date.today().Day());
	                                    if(objContractWithHightestInitEffDate.Expiration_Date__c != null){
	                                        Date dtExpirationDate = Date.newInstance(objContractWithHightestInitEffDate.Expiration_Date__c.Year(),objContractWithHightestInitEffDate.Expiration_Date__c.Month(),objContractWithHightestInitEffDate.Expiration_Date__c.Day());
	                                        monthdifference = dtToday.monthsBetween(dtExpirationDate);                                      
	                                            
	                                    }
	                                                                                                                  
	                                    if(objContractWithHightestInitEffDate.Sub_Status__c != null && objContractWithHightestInitEffDate.Sub_Status__c.equalsIgnoreCase(AUTO_RENEWED_CONTRACT) ){    
											if(instantProperty.Risk_Status__c != AUTO_RENEWED_PROPERTY)
											{
												instantProperty.Risk_Status__c  = AUTO_RENEWED_PROPERTY;
												propertyUpdated = true;
											}                                                                            
	                                                                          
	                                    }else{                                                                                                                                            
	                                        if(objContractWithHightestInitEffDate.Expiration_Date__c != null){
	                                            if(monthdifference <= 6){
													if(instantProperty.Risk_Status__c != WITHIN_0_6)
													{
														instantProperty.Risk_Status__c  = WITHIN_0_6;
														propertyUpdated = true;
													}	                                                
	                                            } else if(monthdifference > 6 && monthdifference <= 12){	                                                
													if(instantProperty.Risk_Status__c != WITHIN_6_12)
													{
														instantProperty.Risk_Status__c  = WITHIN_6_12;
														propertyUpdated = true;
													}	
	                                            } else if(monthdifference > 12 && monthdifference <= 24){	                                                 
													if(instantProperty.Risk_Status__c != WITHIN_12_24)
													{
														instantProperty.Risk_Status__c  = WITHIN_12_24;
														propertyUpdated = true;
													}
	                                            } else if(monthdifference > 24){	                                                
													if(instantProperty.Risk_Status__c != ABOVE_24)
													{
														instantProperty.Risk_Status__c  = ABOVE_24; 
														propertyUpdated = true;
													}
	                                            } else if(objContractWithHightestInitEffDate.Video__c == NO_VAL_VIDEO && objContractWithHightestInitEffDate.Voice__c == NO_VAL_VOICE && objContractWithHightestInitEffDate.Data__c == NO_VAL_DATA){
													if(instantProperty.Risk_Status__c != NO_CONTRACT)
													{
														instantProperty.Risk_Status__c  = NO_CONTRACT;
														propertyUpdated = true;
													}	                                              
	                                            }
	                                        }
	                                    }                                                                  
	                                }  
	                            }            
	                        }                                                                                                       
	                    }
	                }else{      
						if(instantProperty.Risk_Status__c != NOT_SERVICED)
						{
							instantProperty.Risk_Status__c = NOT_SERVICED;
							propertyUpdated = true;
						}
						if(instantProperty.Bulk_Status__c != NOT_SERVICED)
						{
							instantProperty.Bulk_Status__c = NOT_SERVICED;    
							propertyUpdated = true;
						}
	                }  
					if(propertyUpdated)
					{	
						//Add to Property List
						propertyUpdateList.add(instantProperty); 
					}
				}
				else
				{
					if(instantProperty.Comcast_Video_Serviced__c == YES_VAL_VIDEO 
                    || instantProperty.Comcast_Voice_Serviced__c == YES_VAL_VOICE 
                    || instantProperty.Comcast_Data_Serviced__c == YES_VAL_DATA){
                    
                    List<Contract__c> listOfContract = new List<Contract__c>();
                    if(!propertyIdContractListMap.isEmpty() && propertyIdContractListMap.containsKey(instantProperty.Id)){
                        listOfContract = propertyIdContractListMap.get(instantProperty.Id);
                    }
                    if((instantProperty.Video_Billing_Type__c == BULK_VAL_VIDEO || instantProperty.Voice_Billing_Type__c == BULK_VAL_VOICE || instantProperty.Data_Billing_Type__c == BULK_VAL_DATA) 
                        && instantProperty.Number_of_Units__c>=5){                                                                 
                            instantProperty.Bulk_Status__c = BULK_VAL_BULKSTATUS;                               
                    }else{                                          
                        instantProperty.Bulk_Status__c = RETAIL_VAL_BULKSTATUS;    
                    }                   
                    if(listOfContract.isEmpty()){                                                                                  
                        instantProperty.Risk_Status__c  = NO_CONTRACT;  
                    }else{                                                
                        Contract__c objContractWithHightestInitEffDate=null; 
                        Boolean isBulk = false;                        
                        if(instantProperty.Video_Billing_Type__c == BULK_VAL_VIDEO || instantProperty.Voice_Billing_Type__c == BULK_VAL_VOICE || instantProperty.Data_Billing_Type__c == BULK_VAL_DATA){
                            isBulk = true;                               
                        }
                        else{
                            isBulk = false;
                        }
                        List<Contract__c> listContractsforCurrentProperty = new List<Contract__c>();
                        if(!propertyIdContractListMap.isEmpty() && propertyIdContractListMap.containsKey(instantProperty.Id)){
                            listContractsforCurrentProperty = propertyIdContractListMap.get(instantProperty.Id);
                        }
                        if(isBulk == true){                                
                            //Find Contract Having Highest Initial Effective Date And Any Billing Type As Bulk
                            if(!listContractsforCurrentProperty.isEmpty() && listContractsforCurrentProperty!=null){
                                for(Contract__c contractTemp: listContractsforCurrentProperty){                                                   
                                   if(contractTemp.Initial_Effective_Date__c != null && 
                                    (contractTemp.Video_Billing_Type__c == BULK_VAL_VIDEO 
                                    || contractTemp.Voice_Billing_Type__c == BULK_VAL_VOICE 
                                    ||  contractTemp.Data_Billing_Type__c == BULK_VAL_DATA )){
                                    
                                        if(objContractWithHightestInitEffDate== null){
                                            objContractWithHightestInitEffDate = contractTemp; 
                                        }else{                
                                            if(contractTemp.Initial_Effective_Date__c> objContractWithHightestInitEffDate.Initial_Effective_Date__c){
                                                objContractWithHightestInitEffDate = contractTemp;                                                        
                                            }
                                        }
                                    }                                                       
                                }
                            }
                            if(objContractWithHightestInitEffDate==null && listContractsforCurrentProperty!=null){
                                isBulk = false;
                            }
                        }                                
                             //Find Contract Having Highest Initial Effective Date And Any Billing Type As Retail , This will true when we don't have any Contract__c with bulk type
                        if(isBulk == false){    
                            for(Contract__c contractTemp: listContractsforCurrentProperty) {                                       
                                if(contractTemp.Initial_Effective_Date__c != null && (contractTemp.Video_Billing_Type__c == RETAIL_VAL_VIDEO || contractTemp.Voice_Billing_Type__c == RETAIL_VAL_VOICE ||  contractTemp.Data_Billing_Type__c == RETAIL_VAL_DATA ))   {                          
                                    if(objContractWithHightestInitEffDate == null){                                                               
                                        objContractWithHightestInitEffDate =contractTemp; 
                                    }else{                                                                 
                                        if(contractTemp.Initial_Effective_Date__c > objContractWithHightestInitEffDate.Initial_Effective_Date__c ){
                                            objContractWithHightestInitEffDate =contractTemp;                                                 
                                        }
                                    } 
                                }                                     
                            }                                
                        }                                                        
                        if(objContractWithHightestInitEffDate != null){ 
                        //If any contract with initial effective date                                                                                           
                            if(objContractWithHightestInitEffDate.Life_of_Franchise__c){                                                                           
                                  instantProperty.Risk_Status__c  = FRANCHISE_VAL;  
                            }else{                              
                                if(objContractWithHightestInitEffDate.Contract_Status__c != null && objContractWithHightestInitEffDate.Contract_Status__c.equalsIgnoreCase(EXPIRED_VAL_CONTRACT_STATUS)){                                   
                                    instantProperty.Risk_Status__c  = EXPIRED_VAL_RISK_STATUS;                                              
                                }else{                                            
                                    //Find Month Difference between initial effective date and expiration date , use that month to set risk status 
                                    Integer monthdifference=null;
                                    Date dtToday = Date.newInstance(date.today().Year(), date.today().Month(), date.today().Day());
                                    if(objContractWithHightestInitEffDate.Expiration_Date__c != null){
                                        Date dtExpirationDate = Date.newInstance(objContractWithHightestInitEffDate.Expiration_Date__c.Year(),objContractWithHightestInitEffDate.Expiration_Date__c.Month(),objContractWithHightestInitEffDate.Expiration_Date__c.Day());
                                        monthdifference = dtToday.monthsBetween(dtExpirationDate);                                      
                                            
                                    }
                                                                                                                  
                                    if(objContractWithHightestInitEffDate.Sub_Status__c != null && objContractWithHightestInitEffDate.Sub_Status__c.equalsIgnoreCase(AUTO_RENEWED_CONTRACT) ){                                                                                
                                        instantProperty.Risk_Status__c  = AUTO_RENEWED_PROPERTY;                                  
                                    }else{                                                                                                                                            
                                        if(objContractWithHightestInitEffDate.Expiration_Date__c != null){
                                            if(monthdifference <= 6){
                                                instantProperty.Risk_Status__c  = WITHIN_0_6;
                                            } else if(monthdifference > 6 && monthdifference <= 12){
                                                instantProperty.Risk_Status__c  = WITHIN_6_12;
                                            } else if(monthdifference > 12 && monthdifference <= 24){
                                                instantProperty.Risk_Status__c  = WITHIN_12_24; 
                                            } else if(monthdifference > 24){
                                                instantProperty.Risk_Status__c  = ABOVE_24; 
                                            } else if(objContractWithHightestInitEffDate.Video__c == NO_VAL_VIDEO && objContractWithHightestInitEffDate.Voice__c == NO_VAL_VOICE && objContractWithHightestInitEffDate.Data__c == NO_VAL_DATA){
                                            instantProperty.Risk_Status__c  = NO_CONTRACT;  
                                            }
                                        }
                                    }                                                                  
                                }  
                            }            
                        }                                                                                                       
                    }
                }else{                    
                    instantProperty.Risk_Status__c = NOT_SERVICED;
                    instantProperty.Bulk_Status__c = NOT_SERVICED;                
                }  
                //Add to Property List
                propertyUpdateList.add(instantProperty); 
				}
            }      
            if(!propertyUpdateList.IsEmpty()){              
                Database.SaveResult[] saveResult = Database.update(propertyUpdateList, false);  //update propertyUpdateList;  
                if(jobStatus!=null && !jobStatus.isEmpty()){
                    for (Database.SaveResult result : saveResult) {
                        jobStatus[0].Total_Records_Processed__c ++;
                        if(!result.isSuccess()){                                                
                            for (Database.Error error : result.getErrors()) {
                                jobStatus[0].Number_Of_Fallouts__c  ++;
                                
                                Integer len = Job_Status__c.Comments__c.getDescribe().getLength();
                                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + NEW_LINE;                                    
                                jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg;
                            }
                        }
                        else{
                            //jobStatus.Total_RGU_Activations_Processed__c ++ ;
                        }       
                    }
                    database.update(jobStatus[0]);  
                }               
            }  
        }catch(Exception e){
            if(jobStatus!=null && !jobStatus.isEmpty()){
                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ? SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE;                                    
                jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg;                          
                database.update(jobStatus[0]);
            }
        }     
    }
    
    
    /*
    * Execute Finish logic after execution of batch records completed
    */
    global void finish(Database.BatchableContext bContext){
        //Add Job Status       
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        if(jobStatus!=null && !jobStatus.isEmpty()){
            jobStatus[0].Batch_End_Time__c = Datetime.now();
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ;   
            database.update (jobStatus[0]);  
        }
        
        //Start : Added By Amit Kumar Pradhan(Part Of US917335)
        /****
        * Calling MDUPropertyRatingAutoSetBatch 
        * The query string passed while batch is executed.
        * 'SELECT Id ,Risk_Status__c, Comcast_Video_Serviced__c, Comcast_Voice_Serviced__c, Comcast_Data_Serviced__c, Video_Billing_Type__c, Voice_Billing_Type__c, Data_Billing_Type__c, Number_of_Units__c FROM MDU_Property__c WHERE RecordTypeId IN : recordTypeIds';   
        *****/
        String queryString = '';
        if(System.Label.MDUPropertyRatingAutoSetBatchLabel != Null){
            queryString = System.Label.MDUPropertyRatingAutoSetBatchLabel;
        }              
        Integer batchSize=200;
        if(System.Label.XCPropertyRatingBatchSize!=null && System.Label.XCPropertyRatingBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.XCPropertyRatingBatchSize);
        }       
        if(!Test.isRunningTest()){ 
            database.executebatch(new MDUPropertyRatingAutoSetBatch(queryString), batchSize);
        }
        //End : Added By Amit Kumar Pradhan(Part Of US917335)
    }
    
    
    //Get job status
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        return [SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                Total_RGU_ORders_Upserted_Today__c FROM Job_Status__c WHERE Status__c =: NEW_VAL AND ID=: jobStatusId];
    } 

}