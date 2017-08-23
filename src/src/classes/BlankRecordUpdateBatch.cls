/**************************************************************************************************
* Name : BlankRecordUpdateBatch
  Description : This batch class is created to update all addresses by region so that addresses gets added to the property
                Once property data (sys/prin/complex code/house misc code/billing corp etc) is corrected, this batch need to run. 
                Address update will trigger address to property linking logic present in address trigger
                This batch cab used to update any other object as well
  User Story : US1164265
  Date : 22 August 2017
  Author : Animesh Datta
***************************************************************************************************/
global class BlankRecordUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    //Start - Declaring variables
    private static final string BATCH_JOB_NAME = 'BlankRecordUpdateBatch';
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final String NEW_VAL = System.Label.JOB_StatusNew;
    private static final String SPACE_BLANK = ' ';
    private static final String NEW_LINE = '\n\r';  
    private static final String LABEL_NAME_SPLIT = ';';
    private static final String SYSTEM_EXCEPTION = 'System Exception - ';
    private Id jobStatusId=null;
    private String query='';
    private static final Set<String> RECORDTYPEIDS= new Set<String>();
    private static final String HYPHEN_STR = ' - ';
    //End - Declaring variables
    
    /***************************************************
        Description : Constructor for batch query 
        User Story : US1164265
        Date : 21 August 2017
        Author : Animesh Datta
    ****************************************************/
    global BlankRecordUpdateBatch(String query){
        this.query=query;
    }
    
    /******************************************************************************
        Description : Start methood of batch 
        User Story : US1164265
        Date : 22 August 2017
        Author : Animesh Datta
    ******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bContext) {
        //Create Job Status Object record
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME+ HYPHEN_STR + Datetime.now();
        jobStatus.Status__c = NEW_VAL;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = SPACE_BLANK;
        jobStatus.Number_Of_Fallouts__c = 0;
        Database.insert(jobStatus);//create job status record
        jobStatusId = jobStatus.Id;
        return Database.getQueryLocator(query);//record in scope of batch
    }
    
    /**************************************************************************************************
        Description : Execute methood of batch 
        User Story : US1164265
        Date : 22 August 2017
        Author : Animesh Datta
    ***************************************************************************************************/
    global void execute(Database.BatchableContext bContext, LIST<sObject> scopeList){
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        try{
            if(!scopeList.isEmpty()){
                Database.SaveResult[] saveResult = Database.Update(scopeList,false);
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
                        }
                        database.update(jobStatus[0]);//update job status record
                }
            }
        }catch(Exception exp){
            if(jobStatus!=null && !jobStatus.isEmpty()){
                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ? SYSTEM_EXCEPTION + exp.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + exp.getMessage() + NEW_LINE;                                    
                jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg;                          
                database.update(jobStatus[0]);//update job status record
            }
        }       
    }
   
    /**************************************************************************************************
        Description : Finish methood of batch 
        User Story : US1164265
        Date : 22 August 2017
        Author : Animesh Datta
    ***************************************************************************************************/
    global void finish(Database.BatchableContext bContext){
        //Add Job Status       
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        if(jobStatus!=null && !jobStatus.isEmpty()){
            jobStatus[0].Batch_End_Time__c = Datetime.now();
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ;   
            database.update (jobStatus[0]);//update job status record
        }        
    }
    
    /**************************************************************************************************
        Description : Get job status 
        User Story : US1164265
        Date : 22 August 2017
        Author : Animesh Datta
    ***************************************************************************************************/
    private List<Job_Status__c> getJobStatus(Id jobStatusId) {
        return [SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                Batch_Start_Time__c, Batch_End_Time__c FROM Job_Status__c WHERE Status__c =: NEW_VAL AND ID=: jobStatusId LIMIT 1];
    } 

}