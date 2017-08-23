/**************************************************************************************************
* Name : MDUContractAutoRenewBatch
  Description : This batch class created to run batch job that will  set sub-status of contract to auto-renewed .
  User Story : 24
  Date : 6 January 2015
  Author : Ashish Sonawane
* Last Modified By : Amit Kumar Pradhan
  Last Modified Date : 25-Feb-2017
  User Story : US917335
  Description : made the batch parameterized and calling "MDUPropertyRiskStatusAutoSetBatch" batch class from finish method 
***************************************************************************************************/
global class MDUContractAutoRenewBatch implements Database.Batchable<sObject>, Database.Stateful {   
   
    private static final string BATCH_JOB_NAME = System.Label.Xffinity_Contract_AutoRenew_Batch_Name;
    private static final String CONTRACT = 'Contract__c';
    private static final String DAYS = System.Label.Contract_RenewalTermUnit_Days;
    private static final String MONTHS = System.Label.Contract_RenewalTermUnit_Months;
    private static final String YEARS = System.Label.Contract_RenewalTermUnit_Years;
    private static final String AUTORENEWED = System.Label.Contract_ConSubStatus_AutoRenewed;
    private static final String SEMICOLON = ';';
    private static final String BLANK = '';
    private static final String LIMIT25 = ' limit 25';
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final String NEW_JOB = System.Label.JOB_StatusNew;
    private static final String JOB_NAME_SPACE = ' - ';
    private static final String BLANK_JOB_COMMENT = ' ';
    private static final String SYSTEM_EXCEPTION = 'System Exception - ';
    private static final String NEW_LINE = '\n';
    private static final String LABEL_NAME_SPLIT = ';'; 
    private Id jobStatusId = null; 
    private String query='';
    private static final Set<String> recordTypeIds = new Set<String>();
    //Start : Added By Amit Kumar Pradhan(Part Of US917335)
    //BATCHQUERY string is commented as we are passing the query string as parameter
    /*private static final String BATCHQUERY = ' select id, Data__c ,Renewal_Term__c,Renewal_Term_Unit__c,Sub_Status__c,Effective_Date__c ,Expiration_Date__c, Property__r.id ,Auto_Renewal_Limit__c,Contract__c.RecordTypeId,Auto_Renewal_Count__c from Contract__c where Expiration_Date__c < = TODAY  and Expiration_Date__c != null '+
                 'and  CALENDAR_YEAR(Expiration_Date__c) > 1970 and Archived__c != True  and  (Renewal_Term__c != null and Renewal_Term__c >= 1) and Renewal_Term_Unit__c != null '+
                 'and (Property__r.Comcast_Video_Serviced__c = \'Yes\' Or Property__r.Comcast_Voice_Serviced__c = \'Yes\' or Property__r.Comcast_Data_Serviced__c  = \'Yes\')'+
                 'and (Data__c = \'Yes\' Or Video__c = \'Yes\' or Voice__c = \'Yes\') '+
                 'and (Auto_Renewal_Limit__c = null or Auto_Renewal_Limit__c >= 0 )'+
                 'and  IsRenewalCountNotExceed__c = \'true\'   and Contract__c.RecordTypeId IN: recordTypeIds  ';*/
    
    
    /* Constructor for batch class MDUPropertySegmentationTypeAutoSetBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :- 'SELECT Id, Data__c, Renewal_Term__c, Renewal_Term_Unit__c, Sub_Status__c, Effective_Date__c, Expiration_Date__c, Property__r.Id, Auto_Renewal_Limit__c, Contract__c.RecordTypeId, Auto_Renewal_Count__c FROM Contract__c WHERE Expiration_Date__c < = TODAY  AND Expiration_Date__c != null
                 AND CALENDAR_YEAR(Expiration_Date__c) > 1970 and Archived__c != True  and  (Renewal_Term__c != null and Renewal_Term__c >= 1) and Renewal_Term_Unit__c != null
                 AND (Property__r.Comcast_Video_Serviced__c = 'Yes' Or Property__r.Comcast_Voice_Serviced__c = 'Yes' or Property__r.Comcast_Data_Serviced__c  = 'Yes')'
                 AND (Data__c = 'Yes' Or Video__c = 'Yes' or Voice__c = 'Yes')
                 AND (Auto_Renewal_Limit__c = null or Auto_Renewal_Limit__c >= 0 )
                 AND IsRenewalCountNotExceed__c = 'true' AND Contract__c.RecordTypeId IN: recordTypeIds '
     */
    global MDUContractAutoRenewBatch(String query)
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
        jobStatus.Name = BATCH_JOB_NAME + JOB_NAME_SPACE + Datetime.now();
        jobStatus.Status__c = NEW_JOB;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Total_RGU_Activations_Processed__c = 0;
        jobStatus.Total_RGU_Orders_Processed__c = 0;
        jobStatus.Total_RGU_ORders_Upserted_Today__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = BLANK_JOB_COMMENT;
        jobStatus.Number_Of_Fallouts__c = 0;
        Database.insert(jobStatus);        
        jobStatusId = jobStatus.Id;       
        Set<String> recordTypeSet = new Set<String>();
        
        //Get Developer Name Of Record Type And Fetch Record Only For That Record Type             
        string labelName = System.Label.XfinityContractRecordType;                    
        if(!string.isBlank(labelName)){
            for(String str: labelName.split(LABEL_NAME_SPLIT)){
                recordTypeIds.add(Schema.SObjectType.Contract__c.getRecordTypeInfosByName().get(str).getRecordTypeId());                
            }
        }  
                              
        if(Test.isRunningTest()){
            query+= LIMIT25;
        }       
        return Database.getQueryLocator(query);            
    }
    
  /*
    * Execute business logic on data come in contractList list
    */
    global void execute(Database.BatchableContext bContext, LIST<Contract__c> contractList){          
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);       
        try{         
                List<Contract__c> contractUpdateList = new List<Contract__c>();
                for(Contract__c instantContract: contractList){                                
                    instantContract.Sub_Status__c = AUTORENEWED;
                    instantContract.Effective_Date__c = instantContract.Expiration_Date__c;
                    if(instantContract.Auto_Renewal_Count__c == null ){
                        instantContract.Auto_Renewal_Count__c = 1;
                    }else{               
                        instantContract.Auto_Renewal_Count__c = instantContract.Auto_Renewal_Count__c  + 1;   
                    }                
                    if(instantContract.Renewal_Term_Unit__c !=null && instantContract.Renewal_Term__c !=null && instantContract.Effective_Date__c != null){ //Renewal_Term__c,Renewal_Term_Unit__c
                        Date dateOfContractExpiration = Date.newInstance(instantContract.Effective_Date__c.Year(), instantContract.Effective_Date__c.Month(), instantContract.Effective_Date__c.Day());                    
                        if(YEARS.equalsIgnoreCase(instantContract.Renewal_Term_Unit__c)){                      
                          instantContract.Expiration_Date__c = dateOfContractExpiration.addYears(Integer.ValueOf(instantContract.Renewal_Term__c));
                        }
                        else if(MONTHS.equalsIgnoreCase(instantContract.Renewal_Term_Unit__c)){                      
                          instantContract.Expiration_Date__c = dateOfContractExpiration.addMonths(Integer.ValueOf(instantContract.Renewal_Term__c));                        
                        }
                        else if(DAYS.equalsIgnoreCase(instantContract.Renewal_Term_Unit__c)){                      
                          instantContract.Expiration_Date__c = dateOfContractExpiration.addDays(Integer.ValueOf(instantContract.Renewal_Term__c));
                        }                         
                    contractUpdateList.add(instantContract);    
                }
            }
            
            if(!contractUpdateList.IsEmpty()){
                Database.SaveResult[] saveResult = Database.Update(contractUpdateList);
                if(jobStatus!=null && !jobStatus.isEmpty()){
                    for (Database.SaveResult result : saveResult) {
                        jobStatus[0].Total_Records_Processed__c ++;
                        if(!result.isSuccess()){                                                                     
                            for (Database.Error error : result.getErrors()) {
                                jobStatus[0].Number_Of_Fallouts__c  ++;  
                                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + NEW_LINE;                                    
                                jobStatus[0].Comments__c=(tempMsg.length() > len)? tempMsg.substring(0,len):tempMsg;                                                                      
                            }
                        } else{//jobStatus[0].Total_RGU_Activations_Processed__c ++ ;}
                        }                               
                    }   
                    Database.update(jobStatus[0]);  
                }                                
            }          
        }catch(Exception e){
            
            if(jobStatus!=null && !jobStatus.isEmpty()){
                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE;                                    
                jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0,len):tempMsg;                           
                Database.update(jobStatus[0]); 
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
            Database.update(jobStatus[0]);  
        }
        
        //Start : Added By Amit Kumar Pradhan(Part Of US917335)
        /*****
        * Calling MDUPropertyRiskStatusAutoSetBatch
        * The query string passed while batch is executed.
        * 'SELECT Id ,Risk_Status__c, Comcast_Video_Serviced__c, Comcast_Voice_Serviced__c, Comcast_Data_Serviced__c, Video_Billing_Type__c, Voice_Billing_Type__c, Data_Billing_Type__c, Number_of_Units__c FROM MDU_Property__c WHERE RecordTypeId IN : recordTypeIds';   
        *****/
        String queryString = '';
        if(System.Label.MDUPropertyRiskStatusAutoSetBatchQueryLabel != Null){
            queryString = System.Label.MDUPropertyRiskStatusAutoSetBatchQueryLabel;
        }              
        Integer batchSize=200;
        if(System.Label.XCPropertyRiskStatusBatchSize!=null && System.Label.XCPropertyRiskStatusBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.XCPropertyRiskStatusBatchSize);
        }        
        if(!Test.isRunningTest()){
            database.executebatch(new MDUPropertyRiskStatusAutoSetBatch(queryString), batchSize);
        }
        //End : Added By Amit Kumar Pradhan(Part Of US917335)
    }
    
    /*
    /* Get job status
    */    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        return [SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                Total_RGU_ORders_Upserted_Today__c 
                FROM Job_Status__c WHERE Status__c = 'New' AND ID=: jobStatusId];
    }   
}