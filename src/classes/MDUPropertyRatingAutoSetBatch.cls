/**************************************************************************************************
Name : MDUPropertyRatingAutoSetBatch
Description : This batch class created to run batch job that will auto set Property Type of property base on various condition mention in execute method  
User Story : 76
Date : 9 January 2015
Author : Ashish Sonawane
***************************************************************************************************/
global class MDUPropertyRatingAutoSetBatch implements Database.Batchable<sObject>, Database.Stateful{ 
       
    private static final string BATCH_JOB_NAME = System.Label.Xffinity_Property_Rating_Auto_Set_Batch_Name;
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final String LABEL_NAME_SPLIT = ';';
    private static final String QUERY_LIMIT = ' limit 25';
    private static final String PROPERTY_OBJECT = 'MDU_Property__c';
    private static final String RISK_STATUS_ABV_24 = '>24';
    private static final String INDSTRY_MULTY_FAMLY = System.Label.PROP_IndustryTypeMultiFamiliy;
    private static final String INDSTRY_SINGLE_FAMLY = System.Label.PROP_IndustryTypeSingle_Family;
    private static final String NOT_SERICE_BULK_SERVICE = System.Label.PROP_BulkStatus_NotServiced;
    private static final String ARCHIVE_CONTRACT_STATUS = System.Label.Contract_ContractStatus_Archieved;
    private static final String SUBSTATUS_AUTOREN_STATUS = System.Label.Contract_ConSubStatus_AutoRenewed;
    private static final String EXCUSIVE_MARKETING_RIGHT = System.Label.Contract_MarketingRight_Exclusive;
    private static final String NONEXCUSIVE_MARKETING_RIGHT = System.Label.Contract_MarketingRight_NonExclusive;
    private static final String BULK_BULK_STATUS = System.Label.PROP_PropertyBulkStatusBulk;
    private static final String RETAIL_BULK_STATUS = System.Label.PROP_PropertyBulkStatusRetail;
    private static final String PUBLICHOUSING_PROPERTY_TYPE = System.Label.PROP_PropertyTypePublicHousing;
    private static final String RETIRMENT_HOME_PROPERTY_TYPE = System.Label.PROP_PropertyTypeRetirementHome;
    private static final String ASSISTED_LIVING_PROPERTY_TYPE = System.Label.PROP_PropertyTypeAssistedLivling;
    private static final String SYSTEM_EXCEPTION =  'System Exception - ';
    private static final String NEW_LINE = '\n';
    private static final String NEW_JOB_STATUS = System.Label.JOB_StatusNew;
    private static final String BLANK_SPACE = ' ';
    private static final String JOB_NAME_SEPARATER = ' - ';
    private static final Decimal FIBER_PERCENT = 35.00 ;
   
    private static final String BATCH_QUERY = 'Select Id , PostalCode__c ,Risk_Status__c, Comcast_Video_Serviced__c, Comcast_Voice_Serviced__c,  Comcast_Data_Serviced__c, '+
                        '(SELECT Id, Effective_Date__c,Contract_Status__c,Status__c, Data_Marketing_Rights__c, Voice_Marketing_Rights__c, Video_Marketing_Rights__c, Video_Billing_Type__c, Voice_Billing_Type__c, ' + 
                        ' Data_Billing_Type__c,Initial_Effective_Date__c,Expiration_Date__c,Life_of_Franchise__c,Sub_Status__c FROM Contracts1__r), ' +
                        ' Video_Billing_Type__c,Industry_Type__c,Property_Rating__c,Property_Type__c,Voice_Billing_Type__c,Data_Billing_Type__c, Bulk_Status__c, '+  
                        ' Number_of_Units__c from MDU_Property__c where RecordTypeId IN: recordTypeIds   ' ;  
    private Id jobStatusId = null; 
     /*
    * Query execution for AutoRenewMduContractBatch
    */
    global Database.QueryLocator start(Database.BatchableContext bContext) {    
        
         //Create Job Status Object
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME+ JOB_NAME_SEPARATER + Datetime.now();
        jobStatus.Status__c = NEW_JOB_STATUS;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Total_RGU_Activations_Processed__c = 0;
        jobStatus.Total_RGU_Orders_Processed__c = 0;
        jobStatus.Total_RGU_ORders_Upserted_Today__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = BLANK_SPACE;
        jobStatus.Number_Of_Fallouts__c = 0;
        database.insert(jobStatus);  
        jobStatusId = jobStatus.Id;
        
        String labelName = System.Label.XfinityPropertyRecordType;  
        Set<String> recordTypeIds = new Set<String>();
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeIds.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }  
        String query =  BATCH_QUERY;  
        if(Test.isRunningTest()) {
            query+= QUERY_LIMIT;
        }                
        return Database.getQueryLocator(query);
    }
    
    /*
    * Execute business logic on data come in contractList list
    */
    global void execute(Database.BatchableContext bContext, LIST<MDU_Property__c> propertyList){      
        
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);  
        try{                                
            Set<Id> propertyIdSet = new Set<id>(); 
            Set<String> zipCodeSet = new Set<String>();
            Map<Id, List<Contract__c>> propertyIdContractListMap = new Map<Id, List<Contract__c>>();      
            Map<String,Decimal> zipCodeFibrePercMap  = new  Map<String ,Decimal>(); 
            
            for(MDU_Property__c tmpProperty : propertyList){            
                propertyIdSet.add(tmpProperty.id);
                propertyIdContractListMap.put(tmpProperty.Id, tmpProperty.Contracts1__r);
                //Add zipcode only if zipode not null               
                if(tmpProperty.PostalCode__c != null && String.ValueOf(tmpProperty.PostalCode__c).Trim().length() >= 5) { 
                    zipCodeSet.add(String.ValueOf(tmpProperty.PostalCode__c).Trim().substring(0, 5));
                }
                else if(tmpProperty.PostalCode__c != null && String.ValueOf(tmpProperty.PostalCode__c).Trim().length() >= 4){
                    zipCodeSet.add(String.ValueOf(tmpProperty.PostalCode__c).Trim().substring(0, 4));
                } 
            }
                         
           //Create map of Zip code to Percent fibre                                             
                   
            for(MDU_Zip_Code_Fiber__c  tmpzipFibre : [SELECT Zip_Code__c, Percent_Fiber__c 
                                                     FROM MDU_Zip_Code_Fiber__c where Zip_Code__c In : zipCodeSet]){                     
                zipCodeFibrePercMap.put(String.ValueOf(tmpzipFibre.Zip_Code__c),tmpzipFibre.Percent_Fiber__c);
            }                       
          
            List<MDU_Property__c> propertyUpdateList =new List<MDU_Property__c>();            
            for(MDU_Property__c instantProperty: propertyList)
            {           

                if(instantProperty.Industry_Type__c != null 
                    && (instantProperty.Industry_Type__c.equalsIgnoreCase(INDSTRY_MULTY_FAMLY) 
                    || instantProperty.Industry_Type__c.equalsIgnoreCase(INDSTRY_SINGLE_FAMLY)))
                    {
                        if(instantProperty.Bulk_Status__c != null && instantProperty.Bulk_Status__c.equalsIgnoreCase(NOT_SERICE_BULK_SERVICE) ){    
                            if(instantProperty.Number_of_Units__c >= 100){                      
                                instantProperty.Property_Rating__c = 3;
                            } else{                      
                                instantProperty.Property_Rating__c = 2;
                            }
                        } else{                  
                            List<Contract__c> contractList = propertyIdContractListMap.get(instantProperty.id);
                            //First we check whether any contract available or not 
                            if(contractList!= null){              
                                Boolean isAutoRenewContractAvailable = true;                         
                                if(instantProperty.Risk_Status__c == RISK_STATUS_ABV_24) {                          
                                    for(Contract__c tempContract: contractList ) {                              
                                        if(tempContract.Contract_Status__c != null 
                                            && tempContract.Sub_Status__c != null 
                                            && !tempContract.Contract_Status__c.equalsIgnoreCase(ARCHIVE_CONTRACT_STATUS) 
                                            && !tempContract.Sub_Status__c.equalsIgnoreCase(SUBSTATUS_AUTOREN_STATUS)){
                                            //Check whether any contract with sub-status other that auto renewed 
                                            isAutoRenewContractAvailable = false;  
                                            break; 
                                        }      
                                    }
                                }                          
                                if(!isAutoRenewContractAvailable) {      //if no contract with sub-status auto renew then Set Rating as null                                                              
                                    instantProperty.Property_Rating__c = null;
                                } else{                                                   
                                                                   
                                    //if(instantProperty.Risk_Status__c != RISK_STATUS_ABV_24){
                                        List<Contract__c> contractWithStatusAutoRenewListTypeRetail = new List<Contract__c>();
                                        boolean checkAutoRenewContract= false;
                                        //Get list of retails contract having Sub Status As 'Auto Renewed' and status as 'non archive' & having Any billing type as RETAIL with Data Marketing Right As Exclusive OR Non Exclusive
                                        for(Contract__c tempContract: contractList ) {
                                            
                                            if( tempContract.Contract_Status__c != null 
                                                && tempContract.Sub_Status__c != null 
                                                && !tempContract.Contract_Status__c.equalsIgnoreCase(ARCHIVE_CONTRACT_STATUS) 
                                                && tempContract.Sub_Status__c.equalsIgnoreCase(SUBSTATUS_AUTOREN_STATUS)){
                                                checkAutoRenewContract = true;                                      
                                            }
                                            // Capturing Contracts:  Exclusive/ Non-Exclusive, Non-Archived & Auto-Renewed
                                            if(tempContract.Contract_Status__c != null){  
                                                if(!tempContract.Contract_Status__c.equalsIgnoreCase(ARCHIVE_CONTRACT_STATUS)
                                                    && (((tempContract.Data_Marketing_Rights__c != null) && (tempContract.Data_Marketing_Rights__c.equalsIgnoreCase(EXCUSIVE_MARKETING_RIGHT) || tempContract.Data_Marketing_Rights__c.equalsIgnoreCase(NONEXCUSIVE_MARKETING_RIGHT)))
                                                    || ((tempContract.Video_Marketing_Rights__c != null) && (tempContract.Video_Marketing_Rights__c.equalsIgnoreCase(EXCUSIVE_MARKETING_RIGHT) || tempContract.Video_Marketing_Rights__c.equalsIgnoreCase(NONEXCUSIVE_MARKETING_RIGHT)))
                                                    || ((tempContract.Voice_Marketing_Rights__c != null) && (tempContract.Voice_Marketing_Rights__c.equalsIgnoreCase(EXCUSIVE_MARKETING_RIGHT) || tempContract.Voice_Marketing_Rights__c.equalsIgnoreCase(NONEXCUSIVE_MARKETING_RIGHT))))
                                                    ){      
                                                    contractWithStatusAutoRenewListTypeRetail.add(tempContract);                                
                                                    }
                                                }                                                                                  
                                        }
                                        if((instantProperty.Risk_Status__c != RISK_STATUS_ABV_24) || checkAutoRenewContract){  
                                            if(instantProperty.Bulk_Status__c != null){                        
                                                if(instantProperty.Bulk_Status__c.equalsIgnoreCase(BULK_BULK_STATUS)){                                   
                                                    if(instantProperty.Number_of_Units__c >= 50){                              
                                                        instantProperty.Property_Rating__c = 3;
                                                    } else if((instantProperty.Number_of_Units__c >= 25) && (instantProperty.Number_of_Units__c < 50)) {                             
                                                        instantProperty.Property_Rating__c = 2;
                                                    } else if(instantProperty.Number_of_Units__c < 25 )  {                                            
                                                        instantProperty.Property_Rating__c = 1;
                                                    }                                              
                                                } else if(instantProperty.Bulk_Status__c.equalsIgnoreCase(RETAIL_BULK_STATUS)){    
                                      
                                                    if(instantProperty.Property_Type__c != null && (instantProperty.Property_Type__c.equalsIgnoreCase(PUBLICHOUSING_PROPERTY_TYPE) 
                                                        || instantProperty.Property_Type__c.equalsIgnoreCase(RETIRMENT_HOME_PROPERTY_TYPE) || instantProperty.Property_Type__c.equalsIgnoreCase(ASSISTED_LIVING_PROPERTY_TYPE))){
                                                        instantProperty.Property_Rating__c = 1;
                                                    }else{                                     
                                                        Decimal fibrPercent= null ;
                                                        if(instantProperty.PostalCode__c != null && zipCodeFibrePercMap != null){            
                                                           if(String.ValueOf(instantProperty.PostalCode__c).Trim().length() >= 5) 
                                                                fibrPercent = zipCodeFibrePercMap.get(String.ValueOf(instantProperty.PostalCode__c).Trim().substring(0, 5));
                                                           else if(String.ValueOf(instantProperty.PostalCode__c).Trim().length() >= 4)
                                                                fibrPercent = zipCodeFibrePercMap.get(String.ValueOf(instantProperty.PostalCode__c).Trim().substring(0, 4));                                                            
                                                        }                                                 
                                                        if(fibrPercent != null && fibrPercent >= FIBER_PERCENT){                                               
                                                            if(!contractWithStatusAutoRenewListTypeRetail.IsEmpty() && contractWithStatusAutoRenewListTypeRetail != null) {   //!contractStatusAutoRenewDataMarketingList.IsEmpty() This was initial condition                                                   
                                                                instantProperty.Property_Rating__c = 3;
                                                            } else 
                                                            {                                                       
                                                                if(instantProperty.Number_of_Units__c > 99){               
                                                                    instantProperty.Property_Rating__c = 3;
                                                                }  
                                                                else if(instantProperty.Number_of_Units__c < 100) {    
                                                                    instantProperty.Property_Rating__c = 2 ;                
                                                                }  
                                                            }
                                                        } else{                                                           
                                                            if(!contractWithStatusAutoRenewListTypeRetail.IsEmpty() && contractWithStatusAutoRenewListTypeRetail != null) {    //!contractStatusAutoRenewDataMarketingList.IsEmpty() This was initial condition                                                                                                   
                                                                instantProperty.Property_Rating__c = 2;
                                                            } else{                              
                                                                if(instantProperty.Number_of_Units__c > 99){           
                                                                    instantProperty.Property_Rating__c = 2;
                                                                }  
                                                                else if(instantProperty.Number_of_Units__c < 100) {                           
                                                                    instantProperty.Property_Rating__c = 1;                                     
                                                                } 
                                                            }
                                                        }
                                                    }  
                                                }                                      
                                            }
                                        }
                                    //}//if check <> >24
                                }
                        }
                    }       
                                   
                } else{                             
                    instantProperty.Property_Rating__c = null;
                }
                 
                    propertyUpdateList.add(instantProperty) ;      
            }
             
            // Update the Property records.
            if(!propertyUpdateList.IsEmpty()){
                Database.SaveResult[] saveResult = Database.Update(propertyUpdateList, false);
                if(jobStatus!=null && !jobStatus.isEmpty()){
                    for(Database.SaveResult result : saveResult) {
                        jobStatus[0].Total_Records_Processed__c ++;
                        if(!result.isSuccess()){                                              
                            for (Database.Error error : result.getErrors()) {
                                jobStatus[0].Number_Of_Fallouts__c  ++;  
                                Integer len = Job_Status__c.Comments__c.getDescribe().getLength();                               
                                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + NEW_LINE ;                                         
                                if(tempMsg.length() > len){
                                    tempMsg = tempMsg.substring(0, len);
                                    jobStatus[0].Comments__c = tempMsg;                                   
                                }else{
                                    jobStatus[0].Comments__c = tempMsg; 
                                }                                                           
                            }
                        }
                        else{
                            //jobStatus[0].Total_RGU_Activations_Processed__c ++ ;
                        }       
                    }
                    database.update(jobStatus[0]);  
                }               
            }               
        }
        catch(Exception e) {
            if(jobStatus!=null && !jobStatus.isEmpty()){
                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();               
                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ? SYSTEM_EXCEPTION +  e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                                           
                if(tempMsg.length() > len){
                    tempMsg = tempMsg.substring(0, len);
                    jobStatus[0].Comments__c = tempMsg;                                   
                }else{
                    jobStatus[0].Comments__c = tempMsg; 
                }      
                database.update(jobStatus[0]);  
            }            
        }       
    }
   
    /*
    * Execute Finish logic after execution of batch records completed
    */
    global void finish(Database.BatchableContext bContext) {
         //Add Job Status       
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        if(jobStatus!=null && !jobStatus.isEmpty()){
            jobStatus[0].Batch_End_Time__c = Datetime.now();
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ;   
            database.update(jobStatus[0]);  
        }       
    }
    
     //Get job status
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        return [SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                Total_RGU_ORders_Upserted_Today__c 
                FROM Job_Status__c WHERE Status__c =: NEW_JOB_STATUS AND ID=: jobStatusId];
    }  

}