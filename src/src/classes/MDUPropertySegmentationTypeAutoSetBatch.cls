/**************************************************************************************************
* Name : MDUPropertySegmentationTypeAutoSetBatch 
  Description : This batch class created to run batch job that will auto set Segmentation values of property base on various condition mention in execute method  
  User Story : 76
  Date : 9 January 2015
  Author : Ashish Sonawane
* Last Modified By : Amit Kumar Pradhan
  Last Modified Date : 25-Feb-2017
  User Story : US917335
  Description : replacing inner query with map and made the batch parameterized.
* Last Modified By : Animesh Datta
  Last Modified Date : 21-Aug-2017
  User Story : US1125026
  Description : Call batch PenetrationbyRGUUpdateBatch from finish method.  PenetrationbyRGUUpdateBatch - This batch class is created to update # RGU penetration value on Property   
***************************************************************************************************/
global class MDUPropertySegmentationTypeAutoSetBatch implements Database.Batchable<sObject>, Database.Stateful {
     
    private static final string BATCH_JOB_NAME = System.Label.Xffinity_Property_Segmentation_Type_Auto_Set_Batch_Name;
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final String SYSTEM_EXCEPTION =  'System Exception - ';
    private static final String NEW_LINE = '\n';
    private static final String NEW_JOB_STATUS = System.Label.JOB_StatusNew;   
    private static final String QUERY_LIMIT = ' limit 25';
    private static final String PROPERTY_OBJECT = 'MDU_Property__c';
    private static final String SPLIT_JOB = ' - ';
    private static final String MULTIFAMILY_INDUSTRY_TYPE = System.Label.PROP_IndustryTypeMultiFamiliy;
    private static final String APARTMENT_PROPERTY_TYPE = System.Label.PROP_PropertyTypeApartment;
    private static final String SINGLE_FAMILY_INDUSTRY_TYPE = System.Label.PROP_IndustryTypeSingle_Family;
    private static final String BULK_BULK_STATUS = System.Label.PROP_PropertyBulkStatusBulk;
    private static final String RETAIL_BULK_STATUS = System.Label.PROP_PropertyBulkStatusRetail;
    private static final Decimal FIBER_PERCENT = 35.00;
    private static final String UNKNOWN_PROPERTY_TYPE =  System.Label.PROP_PropertyTypeUnknown;
    private static final string LABEL_NAME_SPLIT = ';';
    private static final String PUBLIC_HOUSING_PROPERTY_TYPE = System.Label.PROP_PropertyTypePublicHousing;
    private static final String RETIRE_HOME_PROPERTY_TYPE = System.Label.PROP_PropertyTypeRetirementHome;
    private static final String ASSISTED_LIVING_PROPERTY_TYPE = System.Label.PROP_PropertyTypeAssistedLivling;
    private static final String SENIOR_APPRTMNT_PROPERTY_TYPE = System.Label.PROP_PropertyTypeSeniorApartments;
    private static final String H_SEGMENTATION = System.Label.PROP_SegmentationH;
    private static final String I_SEGMENTATION = System.Label.PROP_Segmentation_I;
    private static final String G_SEGMENTATION = System.Label.PROP_Segmentation_G;
    private static final String A_SEGMENTATION = System.Label.PROP_Segmentation_A;
    private static final String B_SEGMENTATION = System.Label.PROP_Segmentation_B;
    private static final String C_SEGMENTATION = System.Label.PROP_Segmentation_C;
    private static final String D_SEGMENTATION = System.Label.PROP_Segmentation_D;
    private static final String E_SEGMENTATION = System.Label.PROP_Segmentation_E;
    private static final String F_SEGMENTATION = System.Label.PROP_Segmentation_F;
    private static final String BLANK_SPACE = ' ';
    
    //Start : Added By Amit Kumar Pradhan(Part Of US917335)
    //constant variable use in contract fetching query(line no-138)
    private static final String CONTRACT_STATUS_ARCHIVED = 'Archived';
    private static final String MARKETING_RIGHTS_EXCLUSIVE = 'Exclusive';
    private static final String MARKETING_RIGHTS_NON_EXCLUSIVE = 'Non-Exclusive';
    
    //Query string is commented as we are passing the query string as parameter
    /*private static final String QUERY_STRING = ' Select id,Name ,PostalCode__c,Risk_Status__c,Comcast_Video_Serviced__c,Comcast_Voice_Serviced__c,Comcast_Data_Serviced__c, '+
                       ' Video_Billing_Type__c,Industry_Type__c,Property_Type__c,Property_Rating__c,Voice_Billing_Type__c,Data_Billing_Type__c, Bulk_Status__c, '+  
                       ' Number_of_Units__c ,(SELECT Id, Name, Effective_Date__c, Video_Billing_Type__c, Voice_Billing_Type__c, Data_Billing_Type__c, Contract_Status__c,Status__c,'+
                       ' Data_Marketing_Rights__c,Video_Marketing_Rights__c, Voice_Marketing_Rights__c , Initial_Effective_Date__c, Expiration_Date__c, Life_of_Franchise__c, Sub_Status__c '+
                       ' FROM Contracts1__r where Contract_Status__c != \'Archived\' AND ((Data_Marketing_Rights__c = \'Exclusive\' OR Data_Marketing_Rights__c = \'Non-Exclusive\') OR (Video_Marketing_Rights__c = \'Exclusive\' OR Video_Marketing_Rights__c = \'Non-Exclusive\') OR (Voice_Marketing_Rights__c = \'Exclusive\' OR Voice_Marketing_Rights__c = \'Non-Exclusive\'))) '+
                       ' from MDU_Property__c where RecordTypeId IN: recordTypeIds  ';  */ 
                       
    //End : Added By Amit Kumar Pradhan(Part Of US917335)
    private static Integer count = null;
    private Id jobStatusId=null;
    private String query='';
    private static final Set<String> recordTypeIds = new Set<String>();
    
    //Start : Added By Amit Kumar Pradhan(Part Of US917335)
    /* Constructor for batch class MDUPropertySegmentationTypeAutoSetBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :- 'SELECT Id, Name, PostalCode__c, Risk_Status__c, Comcast_Video_Serviced__c, Comcast_Voice_Serviced__c, Comcast_Data_Serviced__c,
                        Video_Billing_Type__c, Industry_Type__c, Property_Type__c, Property_Rating__c, Voice_Billing_Type__c, Data_Billing_Type__c, Bulk_Status__c,  
                        Number_of_Units__c FROM MDU_Property__c WHERE RecordTypeId IN: recordTypeIds  '
     */
    global MDUPropertySegmentationTypeAutoSetBatch(String query)
    {
        this.query=query;
    }
    //End : Added By Amit Kumar Pradhan(Part Of US917335)
    
    /*
    * Query execution for SegmentationTypeAutoSetBatch
    */
    global Database.QueryLocator start(Database.BatchableContext bContext) {        
        
        //Create Job Status Object
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME+ SPLIT_JOB + Datetime.now();
        jobStatus.Status__c = NEW_JOB_STATUS;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Total_RGU_Activations_Processed__c = 0;
        jobStatus.Total_RGU_Orders_Processed__c = 0;
        jobStatus.Total_RGU_ORders_Upserted_Today__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = BLANK_SPACE;
        jobStatus.Number_Of_Fallouts__c = 0;
        insert jobStatus; 

        jobStatusId = jobStatus.Id;
        
        String labelName = System.Label.XfinityPropertyRecordType;        
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                recordTypeIds.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }                               
               
        if(Test.isRunningTest()){
            query+= QUERY_LIMIT; 
        }             
        return Database.getQueryLocator(query);
    }
   
    /*
    * Execute business logic on data come in propertyList list
    */
    global void execute(Database.BatchableContext bContext, LIST<MDU_Property__c> propertyList){                                
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);  
        try{                          
            Set<Id> propertyIdset = new Set<id>();           
            Set<String> zipDecimalCodeSet = new Set<String>();
            Map<Id,List<Contract__c>> propertyIdContractListMap = new Map<id, List<Contract__c>>();      
            Map<String, Decimal> zipCodeFibrePercntMap  = new  Map<String, Decimal>();
           
            //Create map for property id with associated contracts
            for(MDU_Property__c property: propertyList){
                propertyIdset.add(property.Id);
                //Add zipcode only if zipode not null   and take only first character to map with zip fibre table                                        
                if(property.PostalCode__c != null && String.ValueOf(property.PostalCode__c).Trim().length() >= 5 ){ 
                    zipDecimalCodeSet.add(String.ValueOf(property.PostalCode__c).Trim().substring(0, 5));
                }   
                //Add zipcode only if zipode not null   and take only first character to map with zip fibre table                            
                else if(property.PostalCode__c != null && String.ValueOf(property.PostalCode__c).Trim().length() >= 4 ){ 
                    zipDecimalCodeSet.add(String.ValueOf(property.PostalCode__c).Trim().substring(0, 4));    
                }                               
                //propertyIdContractListMap.put(property.Id, property.Contracts1__r); //Map of Property Id To Contract List 
            }
            
            //Start : Added By Amit Kumar Pradhan(Part Of US917335)
            //Creating Map of property with contract list
            //Adding where clause(WHERE Property__c IN: propertyIdSet) while fetching the contracts(last modified data-28/3/2017)
            for(Contract__c contractObj : [SELECT Id, Property__c, Name, Effective_Date__c, Video_Billing_Type__c, Voice_Billing_Type__c, Data_Billing_Type__c,
                                           Contract_Status__c, Status__c, Data_Marketing_Rights__c, Video_Marketing_Rights__c, Voice_Marketing_Rights__c,
                                           Initial_Effective_Date__c, Expiration_Date__c, Life_of_Franchise__c, Sub_Status__c FROM Contract__c 
                                           WHERE Property__c IN: propertyIdSet AND Contract_Status__c !=: CONTRACT_STATUS_ARCHIVED 
                                           AND ((Data_Marketing_Rights__c =: MARKETING_RIGHTS_EXCLUSIVE OR Data_Marketing_Rights__c =: MARKETING_RIGHTS_NON_EXCLUSIVE) 
                                                OR (Video_Marketing_Rights__c =: MARKETING_RIGHTS_EXCLUSIVE OR Video_Marketing_Rights__c =: MARKETING_RIGHTS_NON_EXCLUSIVE)
                                                OR (Voice_Marketing_Rights__c =: MARKETING_RIGHTS_EXCLUSIVE OR Voice_Marketing_Rights__c =: MARKETING_RIGHTS_NON_EXCLUSIVE)) 
                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                                    
                List<Contract__c> tempContractList = new List<Contract__c>();                
                if(propertyIdContractListMap.containsKey(contractObj.Property__c)){
                    tempContractList = propertyIdContractListMap.get(contractObj.Property__c);
                }
                tempContractList.add(contractObj);
                propertyIdContractListMap.put(contractObj.Property__c,tempContractList);      
            }
            //End : Added By Amit Kumar Pradhan(Part Of US917335)
            
            //Create map of Zip code to Percent fibre           
            for(MDU_Zip_Code_Fiber__c  tmpzipFibre : [SELECT Zip_Code__c, Percent_Fiber__c from MDU_Zip_Code_Fiber__c where Zip_Code__c In : zipDecimalCodeSet]){
                zipCodeFibrePercntMap.put(String.ValueOf(tmpzipFibre.Zip_Code__c), tmpzipFibre.Percent_Fiber__c );
            }     
           
            
            List<MDU_Property__c> propertyUpdateList =new List<MDU_Property__c>();
            boolean propertyUpdated = false;     
            for(MDU_Property__c instantProperty : propertyList){     //Loop through all property come in execute method   
                propertyUpdated = false;           
                if((Variable_Setting__c.getInstance('MDUBatchSwitch').Value__c).equalsIgnoreCase('True'))
                {
                    if(instantProperty.Industry_Type__c!=null && (instantProperty.Industry_Type__c.equalsIgnoreCase(MULTIFAMILY_INDUSTRY_TYPE) 
                        || instantProperty.Industry_Type__c.equalsIgnoreCase(SINGLE_FAMILY_INDUSTRY_TYPE))){
                        
                        List<Contract__c> contractList = new List<Contract__c>();
                        if(!propertyIdContractListMap.isEmpty() && propertyIdContractListMap.containsKey(instantProperty.Id)){
                            contractList = propertyIdContractListMap.get(instantProperty.Id);
                        }
                        List<Contract__c> contractStatusAutoRenewDataMarketingList = new List<Contract__c>() ;                  
                        String bulkType=null;
                        if(instantProperty.Bulk_Status__c != null && (instantProperty.Bulk_Status__c.equalsIgnoreCase(BULK_BULK_STATUS) 
                            || instantProperty.Bulk_Status__c.equalsIgnoreCase(RETAIL_BULK_STATUS))){ 
                            bulkType = instantProperty.Bulk_Status__c;
                        } 
                        if(contractList!=null && !contractList.isEmpty()){
                            contractStatusAutoRenewDataMarketingList = contractList ;    
                        }
    
                        Decimal zipPercent= null ;
                        if(instantProperty.PostalCode__c != null && zipCodeFibrePercntMap != null){  //Get Zip Percent For Current Property 
                           if(String.ValueOf(instantProperty.PostalCode__c).Trim().length() >= 5 ){
                            zipPercent = zipCodeFibrePercntMap.get(String.ValueOf(instantProperty.PostalCode__c).Trim().substring(0, 5));
                            } 
                           else if(String.ValueOf(instantProperty.PostalCode__c).Trim().length() >= 4 ){
                            zipPercent = zipCodeFibrePercntMap.get(String.ValueOf(instantProperty.PostalCode__c).Trim().substring(0, 4));
                            } 
                        }                                                          
                        if(instantProperty.Bulk_Status__c != null){                                                            
                            //Check for bulk property                              
                            if(instantProperty.Bulk_Status__c.equalsIgnoreCase(BULK_BULK_STATUS)) {    
                                //Check whether zip perc greater than 35%                      
                                if(zipPercent != null && zipPercent >= FIBER_PERCENT){ 
                                    if(instantProperty.Segmentation__c != H_SEGMENTATION){
                                        instantProperty.Segmentation__c = H_SEGMENTATION;
                                        propertyUpdated = true;    
                                    }
                                } else{
                                    //Check whether list is empty or not   
                                    if(!contractStatusAutoRenewDataMarketingList.IsEmpty() && contractStatusAutoRenewDataMarketingList != null){   
                                        if(instantProperty.Segmentation__c != H_SEGMENTATION){
                                            instantProperty.Segmentation__c = H_SEGMENTATION;
                                            propertyUpdated = true;    
                                        }
                                    }else{
                                        if(instantProperty.Segmentation__c != I_SEGMENTATION){
                                            instantProperty.Segmentation__c = I_SEGMENTATION; 
                                            propertyUpdated = true;    
                                        }                                       
                                    }
                                }                     
                            } else if(instantProperty.Bulk_Status__c.equalsIgnoreCase(RETAIL_BULK_STATUS)){ //Check for Retail property
                                if((instantProperty.Property_Type__c != null) && (instantProperty.Property_Type__c.equalsIgnoreCase(PUBLIC_HOUSING_PROPERTY_TYPE) 
                                    || instantProperty.Property_Type__c.equalsIgnoreCase(RETIRE_HOME_PROPERTY_TYPE) 
                                    || instantProperty.Property_Type__c.equalsIgnoreCase(ASSISTED_LIVING_PROPERTY_TYPE) 
                                    || instantProperty.Property_Type__c.equalsIgnoreCase(SENIOR_APPRTMNT_PROPERTY_TYPE))){ 
                                    if(instantProperty.Segmentation__c != G_SEGMENTATION){
                                        instantProperty.Segmentation__c = G_SEGMENTATION; 
                                        propertyUpdated = true;    
                                    } 
                                } else{  
                                     //Check whether zip percent greater than 35%                           
                                    if(zipPercent != null && zipPercent >= FIBER_PERCENT){                                       
                                        if(!contractStatusAutoRenewDataMarketingList.IsEmpty() && contractStatusAutoRenewDataMarketingList != null) { 
                                            if(instantProperty.Property_Type__c != null && (instantProperty.Property_Type__c.equalsIgnoreCase(APARTMENT_PROPERTY_TYPE) 
                                                || instantProperty.Property_Type__c.equalsIgnoreCase(UNKNOWN_PROPERTY_TYPE))){                                  
                                                if(instantProperty.Segmentation__c != A_SEGMENTATION){
                                                    instantProperty.Segmentation__c = A_SEGMENTATION; 
                                                    propertyUpdated = true;    
                                                } 
                                            } else{                                  
                                                if(instantProperty.Segmentation__c != B_SEGMENTATION){
                                                    instantProperty.Segmentation__c = B_SEGMENTATION; 
                                                    propertyUpdated = true;    
                                                }
                                            }    
                                        } else{                               
                                            if(instantProperty.Segmentation__c != C_SEGMENTATION){
                                                instantProperty.Segmentation__c = C_SEGMENTATION; 
                                                propertyUpdated = true;    
                                            }
                                        }                             
                                    } else{                          
                                        if(!contractStatusAutoRenewDataMarketingList.IsEmpty() && contractStatusAutoRenewDataMarketingList != null){                              
                                            if(instantProperty.Property_Type__c != null && (instantProperty.Property_Type__c.equalsIgnoreCase(APARTMENT_PROPERTY_TYPE) 
                                                || instantProperty.Property_Type__c.equalsIgnoreCase(UNKNOWN_PROPERTY_TYPE))){                                  
                                                if(instantProperty.Segmentation__c != D_SEGMENTATION){
                                                    instantProperty.Segmentation__c = D_SEGMENTATION; 
                                                    propertyUpdated = true;    
                                                }
                                            } else{                                 
                                                if(instantProperty.Segmentation__c != E_SEGMENTATION){
                                                    instantProperty.Segmentation__c = E_SEGMENTATION; 
                                                    propertyUpdated = true;    
                                                }
                                            }  
                                        } else{                              
                                            if(instantProperty.Segmentation__c != F_SEGMENTATION){
                                                instantProperty.Segmentation__c = F_SEGMENTATION; 
                                                propertyUpdated = true;    
                                            }
                                        }                                                                                                           
                                    }
                                }
                            }
                        }
                    } else if(instantProperty.Segmentation__c != null){         
                        instantProperty.Segmentation__c = null;
                        propertyUpdated = true; 
                    }
                    if(propertyUpdated)
                    {
                    // ADD TO Property LIST
                        propertyUpdateList.add(instantProperty) ;   
                    }
                }
                else
                {
                    if(instantProperty.Industry_Type__c!=null && (instantProperty.Industry_Type__c.equalsIgnoreCase(MULTIFAMILY_INDUSTRY_TYPE) 
                        || instantProperty.Industry_Type__c.equalsIgnoreCase(SINGLE_FAMILY_INDUSTRY_TYPE))){
                        
                        List<Contract__c> contractList = new List<Contract__c>();
                        if(!propertyIdContractListMap.isEmpty() && propertyIdContractListMap.containsKey(instantProperty.Id)){
                            contractList = propertyIdContractListMap.get(instantProperty.Id);
                        }
                        List<Contract__c> contractStatusAutoRenewDataMarketingList = new List<Contract__c>() ;                  
                        String bulkType=null;
                        if(instantProperty.Bulk_Status__c != null && (instantProperty.Bulk_Status__c.equalsIgnoreCase(BULK_BULK_STATUS) 
                            || instantProperty.Bulk_Status__c.equalsIgnoreCase(RETAIL_BULK_STATUS))){ 
                            bulkType = instantProperty.Bulk_Status__c;
                        } 
                        if(contractList!=null && !contractList.isEmpty()){
                            contractStatusAutoRenewDataMarketingList = contractList ;    
                        }
    
                        Decimal zipPercent= null ;
                        if(instantProperty.PostalCode__c != null && zipCodeFibrePercntMap != null){  //Get Zip Percent For Current Property 
                           if(String.ValueOf(instantProperty.PostalCode__c).Trim().length() >= 5 ){
                            zipPercent = zipCodeFibrePercntMap.get(String.ValueOf(instantProperty.PostalCode__c).Trim().substring(0, 5));
                            } 
                           else if(String.ValueOf(instantProperty.PostalCode__c).Trim().length() >= 4 ){
                            zipPercent = zipCodeFibrePercntMap.get(String.ValueOf(instantProperty.PostalCode__c).Trim().substring(0, 4));
                            } 
                        }                                                          
                        if(instantProperty.Bulk_Status__c != null){                                                            
                            //Check for bulk property                              
                            if(instantProperty.Bulk_Status__c.equalsIgnoreCase(BULK_BULK_STATUS)) {    
                                //Check whether zip perc greater than 35%                      
                                if(zipPercent != null && zipPercent >= FIBER_PERCENT){                                          
                                    instantProperty.Segmentation__c = H_SEGMENTATION;                           
                                } else{
                                    //Check whether list is empty or not   
                                    if(!contractStatusAutoRenewDataMarketingList.IsEmpty() && contractStatusAutoRenewDataMarketingList != null){   
                                        instantProperty.Segmentation__c = H_SEGMENTATION; 
                                    }else{
                                        instantProperty.Segmentation__c = I_SEGMENTATION; 
                                    }
                                }                     
                            } else if(instantProperty.Bulk_Status__c.equalsIgnoreCase(RETAIL_BULK_STATUS)){ //Check for Retail property
                                if((instantProperty.Property_Type__c != null) && (instantProperty.Property_Type__c.equalsIgnoreCase(PUBLIC_HOUSING_PROPERTY_TYPE) 
                                    || instantProperty.Property_Type__c.equalsIgnoreCase(RETIRE_HOME_PROPERTY_TYPE) 
                                    || instantProperty.Property_Type__c.equalsIgnoreCase(ASSISTED_LIVING_PROPERTY_TYPE) 
                                    || instantProperty.Property_Type__c.equalsIgnoreCase(SENIOR_APPRTMNT_PROPERTY_TYPE))){                        
                                    instantProperty.Segmentation__c = G_SEGMENTATION; 
                                } else{  
                                     //Check whether zip percent greater than 35%                           
                                    if(zipPercent != null && zipPercent >= FIBER_PERCENT){                                       
                                        if(!contractStatusAutoRenewDataMarketingList.IsEmpty() && contractStatusAutoRenewDataMarketingList != null) { 
                                            if(instantProperty.Property_Type__c != null && (instantProperty.Property_Type__c.equalsIgnoreCase(APARTMENT_PROPERTY_TYPE) 
                                                || instantProperty.Property_Type__c.equalsIgnoreCase(UNKNOWN_PROPERTY_TYPE))){                                  
                                                instantProperty.Segmentation__c = A_SEGMENTATION; 
                                            } else{                                  
                                                instantProperty.Segmentation__c = B_SEGMENTATION; 
                                            }    
                                        } else{                               
                                            instantProperty.Segmentation__c = C_SEGMENTATION; 
                                        }                             
                                    } else{                          
                                        if(!contractStatusAutoRenewDataMarketingList.IsEmpty() && contractStatusAutoRenewDataMarketingList != null){                              
                                            if(instantProperty.Property_Type__c != null && (instantProperty.Property_Type__c.equalsIgnoreCase(APARTMENT_PROPERTY_TYPE) 
                                                || instantProperty.Property_Type__c.equalsIgnoreCase(UNKNOWN_PROPERTY_TYPE))){                                  
                                                instantProperty.Segmentation__c = D_SEGMENTATION; 
                                            } else{                                 
                                                instantProperty.Segmentation__c = E_SEGMENTATION; 
                                            }  
                                        } else{                              
                                            instantProperty.Segmentation__c = F_SEGMENTATION; 
                                        }                                                                                                           
                                    }
                                }
                            }
                        }
                    } else{              
                        instantProperty.Segmentation__c = null;
                    }
                    // ADD TO Property LIST
                    propertyUpdateList.add(instantProperty) ;       
                }
            }
            
            if(!propertyUpdateList.IsEmpty()){                          
                Database.SaveResult[] saveResult = Database.update(propertyUpdateList, false);
                if(jobStatus!=null && !jobStatus.isEmpty()){
                    for (Database.SaveResult result : saveResult) {                   
                        jobStatus[0].Total_Records_Processed__c ++;
                        if(!result.isSuccess()){                                              
                            for (Database.Error error : result.getErrors()) {
                                jobStatus[0].Number_Of_Fallouts__c  ++;                             
                                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + NEW_LINE;                                    
                                jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg;                                                                    
                            }
                        }
                        else{
                            //jobStatus.Total_RGU_Activations_Processed__c ++ ;
                        }       
                     }
                    database.update (jobStatus[0]);
                }               
            }  
        }catch(Exception e){
            if(jobStatus!=null && !jobStatus.isEmpty()){
                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ? SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                    
                jobStatus[0].Comments__c=(tempMsg.length() > len)? tempMsg.substring(0, len):tempMsg;                                            
                database.update (jobStatus[0]); 
            }
        }         
    }
   
   
    /*
    * Execute Finish logic after execution of batch records completed
    *   Last Modified By : Animesh Datta
        Last Modified Date : 21-Aug-2017
        User Story : US1125026
        Description : Call batch PenetrationbyRGUUpdateBatch from finish method.  PenetrationbyRGUUpdateBatch - This batch class is created to update # RGU penetration value on Property
    */
    global void finish(Database.BatchableContext bContext){
         //Add Job Status       
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        if(jobStatus!=null && !jobStatus.isEmpty()){
            jobStatus[0].Batch_End_Time__c = Datetime.now();
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ;   
            database.update(jobStatus[0]);  
        }
        //Start : Added By Animesh Datta(Part Of US1125026)
        /****
        * Calling PenetrationbyRGUUpdateBatch
        * The query string passed while batch is executed.
        * 'SELECT Id, HSI_Penetration__c, Video_Penetration__c, Voice_Penetration__c, XH_Penetration__c FROM MDU_Property__c WHERE RecordTypeId IN : recordTypeIds';   
        *****/      
        String queryString = '';
        if(System.Label.PenetrationbyRGUUpdateBatchQuery != Null){
            queryString = System.Label.PenetrationbyRGUUpdateBatchQuery;
        }              
        Integer batchSize=200;
        if(System.Label.PenetrationbyRGUUpdateBatchSize!=null && System.Label.PenetrationbyRGUUpdateBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.PenetrationbyRGUUpdateBatchSize);
        }        
        if(!Test.isRunningTest()){ 
            database.executebatch(new PenetrationbyRGUUpdateBatch(queryString), batchSize);
        }
        //End : Added By Animesh Datta(Part Of US1125026)
                
    }
    
    //Get job status
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        return [SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                Total_RGU_ORders_Upserted_Today__c FROM Job_Status__c WHERE Status__c =: NEW_JOB_STATUS AND ID=: jobStatusId];
    } 

}