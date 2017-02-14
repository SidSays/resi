/**************************************************************************************************
Name : DeletePropertyBatch 
Description : This batch class will delete property with 'delete property' field check 
User Story : US727101
Date : 10 July 2016
Author : Mandeep Singh
***************************************************************************************************/

global class DeletePropertyBatch implements Database.Batchable<sObject>,Database.Stateful{
  
    private final Static String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'DeletePropertyBatch';
    private static final string JOB_STATUS = 'New';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private static final string DATE_STRINGS =  '-';
    private Id jobStatusId = null; 
    public String query;
    Integer count = 0; 
    List<MDU_Property__c> propList = new List<MDU_Property__c>();
    List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
  
 
    global DeletePropertyBatch(String query) {
        this.query=query;
    }
 
    global Database.QueryLocator start(Database.BatchableContext BC){
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME + JOB_NAME_SPACE  + Datetime.now();
        jobStatus.Status__c = JOB_STATUS;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = JOB_COMMENT;
        jobStatus.Number_Of_Fallouts__c = 0;
        Database.insert(jobStatus);  
        jobStatusId = jobStatus.Id;
        return Database.getQueryLocator(query);
    } 
  
    global void execute(Database.BatchableContext BC, List<MDU_Property__c> scopeList){  
          
        for(MDU_Property__c mduProp:scopeList){
            propList.add(mduProp);
      count++;
        } 
    
    if(jobStatus!=null && !jobStatus.isEmpty()){ 
          jobStatus[0].Total_Records_Processed__c = count;
          Database.update(jobStatus[0]); 
        }

        if(propList!=null && !propList.isEmpty()){ 
           Database.delete(propList);        
        }    
    } 
  
    global void finish(Database.BatchableContext BC){
    List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
    
    if(jobStatus!=null && !jobStatus.isEmpty()){ 
    jobStatus[0].Total_Records_Processed__c = count;
    jobStatus[0].Batch_End_Time__c = Datetime.now(); 
    jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ; 
    Database.update(jobStatus[0]); 
        } 
    }
    public List<Job_Status__c> getJobStatus(Id jobStatusId)
    {
    return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
    Batch_Start_Time__c, Batch_End_Time__c 
    FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId]);
       
       }
}