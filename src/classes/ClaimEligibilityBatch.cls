/*ClaimEligibiltyBatch Class*/
/**********************************************************************************************************************************
Name : ClaimEligibilityBatch
Description : This batch class is to set Claim Eligibilty Flag. Modifying this existing batch to handle null pointer exception and adding Job Status entry
Modified By: Ashish Srivastava
Modified Date : 25-Aug-2016
Last Modified By: Ashish Srivastava
Last Modified Date : 25-Aug-2016
***********************************************************************************************************************************/

global class ClaimEligibilityBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {    

    private String query= System.Label.ClaimEligibilityBatchLabel;
    private static final string BATCH_JOB_NAME = 'ClaimEligibilityBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private static final string JOB_COMMENT = ' ';
    private final Static String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';    
    private Id jobStatusId = null;
    private Integer batchSize = Integer.valueOf(System.label.ClaimEligibilityBatchSizeLabel);
   
    /*
    Method to execute the Batch using Schedulable   
    */
   global void execute(SchedulableContext SC) {
        ClaimEligibilityBatch ceb = new ClaimEligibilityBatch();
        Database.executeBatch(ceb,batchSize); 
    } 
    
    /*
     start Method
     */
    global database.queryLocator start(Database.BatchableContext BC) {
        //system.debug('----------------------------query');
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME + JOB_NAME_SPACE  + Datetime.now();
        jobStatus.Status__c = JOB_STATUS;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Total_RGU_Activations_Processed__c = 0;
        jobStatus.Total_RGU_Orders_Processed__c = 0;
        jobStatus.Total_RGU_ORders_Upserted_Today__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = JOB_COMMENT;
        jobStatus.Number_Of_Fallouts__c = 0;
        Database.insert(jobStatus);  
        jobStatusId = jobStatus.Id; 
        return Database.getQueryLocator(query); //query is set in a Custom Label named ClaimEligibilityBatchLabel
    }
    
    /*
    execute method
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        try{
            for(Order__c ord : (List<Order__c>) scope){
                // update the order if claim is eligible or not
                if(ord!=null){
                    if(ord.OrderCompletedDate__c.addDays( (Integer) ord.Affiliate_Account__r.ClaimEligibilityDuration__c) < Date.Today()){
                        ord.isClaimEligible__c = false;
                    } else if(ord.OrderCompletedDate__c.addDays( (Integer) ord.Affiliate_Account__r.ClaimWaitDuration__c) < Date.Today()){
                        ord.isClaimEligible__c = true;
                    } else {
                        ord.isClaimEligible__c = false;
                    }
                }
            }
            Database.SaveResult[] updateOrders = Database.update(scope,false);
            if(jobStatus!=null && !jobStatus.isEmpty()){
                for(Database.SaveResult result : updateOrders) {
                    jobStatus[0].Total_Records_Processed__c ++;
                    if(!result.isSuccess()){                                                 
                        for(Database.Error error : result.getErrors()){
                            jobStatus[0].Number_Of_Fallouts__c  ++;
                            Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                            String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + NEW_LINE;                                    
                            jobStatus[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;
                        }
                    }      
                }
                Database.update(jobStatus[0]);
            } 
        }
        catch(Exception e){
             if(jobStatus!=null && !jobStatus.isEmpty()){
                    Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                    String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                    
                    jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0]);   
             }           
        }
    }
    
    /*
    finish method - update job status
    */
    
    global void finish(Database.BatchableContext BC) {
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
        if(jobStatus!=null && !jobStatus.isEmpty()){ 
            jobStatus[0].Batch_End_Time__c = Datetime.now(); 
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ; 
            Database.update(jobStatus[0]); 
        }
    }
    
    /*
    Get job status
    */
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
           return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                   Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                   Total_RGU_ORders_Upserted_Today__c 
                   FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId
                   LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
    }   
}