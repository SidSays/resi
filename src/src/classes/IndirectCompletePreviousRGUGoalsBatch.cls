/**************************************************************************************************
Name : IndirectCompletePreviousRGUGoalsBatch
Description : This batch class created to update monthly RGU Goals as 'Completed' for previous cycle for Retail Sales Rep and Retail Sales Manager profile users
User Story : 
Date : 19-Apr-2017
Author : Tejaswini Kasar

***************************************************************************************************/

global class IndirectCompletePreviousRGUGoalsBatch implements Database.Batchable<sObject>, Database.Stateful
{  
    private static final List<string> PROFILENAME = new List<String>{System.Label.Retail_Sales_Rep_ProfileName,System.Label.Retail_Sales_Manager_ProfileName};
    private Map<String, Goal> goaltemplateIdMap = new Map<String, Goal>();
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    private Id jobStatusId = null;    
    private String query = '';
    private GoalTemplateDates__c goalDatesMonthly;
      
    /* Constructor for batch class IndirectCompletePreviousRGUGoalsBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-  'Select Id,Name,profile.name,Region__c from User where  IsActive = True AND profile.name IN: PROFILENAME 
                            AND UserPermissionsWorkDotComUserFeature = true '
    */
     
    global IndirectCompletePreviousRGUGoalsBatch(String query) 
    {
        this.query = query;        
    }
    
    /*
    * Query execution to fetch all active users based on profiles - Retail Sales Rep and Retail Sales Manager
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Create Job Status Object
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = Indirect_Constants.BATCH_JOB_NAME_FOR_INDIRECT_COMPLETE_PREVIOUS_RGU_GOAL + Indirect_Constants.JOB_NAME_SPACE  + Datetime.now();
        jobStatus.Status__c = Indirect_Constants.JOB_STATUS_NEW;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = Indirect_Constants.JOB_COMMENT;
        jobStatus.Number_Of_Fallouts__c = 0;
        Database.insert(jobStatus , false);  
        jobStatusId = jobStatus.Id;
                    
        //Fetching Monthly Goal Template Custom Setting Data 
        goalDatesMonthly = GoalTemplateDates__c.getInstance(Indirect_Constants.INDIRECT_MONTHLY_RGU_RECORD);   
        preGoalStartDate = goalDatesMonthly.Current_Period_Start_Date__c;
        preGoalDueDate =  goalDatesMonthly.Current_Period_Due_Date__c;
        preGoalStartDate = preGoalStartDate.addMonths(1);
        preGoalDueDate = preGoalDueDate.addMonths(1);
                 
        return Database.getQueryLocator(query);
    }
    
    /*
     * Execute business logic to update Goals,Metrics to 'completed' status of previous cycle.
    */
    global void execute(Database.BatchableContext BC, List<User> userList){   
        List<Job_Status__c> jobStatus = new  List<Job_Status__c>();
        List<Goal> goalStatusUpdateList = new List<Goal>();
        Set<id> goalIdSet = new Set<id>();
        try {   
            jobStatus = getJobStatus(jobStatusId);      
            /* Update 'goalStatusUpdateList' that are in previous commission cycle and status is not 'Completed' */
            for(Goal goalTemp : [SELECT Id,Name,DueDate,Template_Type__c,Status FROM Goal 
                                                              WHERE OwnerId IN:userList AND Status !=: Indirect_Constants.GOAL_STATUS_COMPLETE 
                                                              AND DueDate =: preGoalDueDate AND startDate =: preGoalStartDate
                                                              AND Template_Type__c =:Indirect_Constants.RGU_STRING 
                                                              AND recordtypeId =: Indirect_Constants.INDIRECT_RECORD_TYPE_ID]){
                goalTemp.Status = Indirect_Constants.GOAL_STATUS_COMPLETE;
                goalIdSet.add(goalTemp.id);//Adding goal id in set
                goalStatusUpdateList.add(goalTemp);
            }
            
            if(goalStatusUpdateList != null && !goalStatusUpdateList.isEmpty()){            
                Database.SaveResult[] updateGoals = Database.Update(goalStatusUpdateList,false);//Updating goal record
                executeJob(updateGoals, jobStatus); // Added to update job status from one method    
            }  
            /* Collect RGU metric's that are to be mark as status completed */
            if(!goalIdSet.isEmpty()){
                List<Metric> oldMetricList = [SELECT Id,Name,Status FROM Metric WHERE GoalId IN: goalIdSet];//Fetching related metrics                                          
                /* Update metricUpdateList that are in previous commission cycle and status is not 'Completed' for respective Goals */
                if(oldMetricList != null && !oldMetricList.isEmpty()){
                    for(Metric metricTemp : oldMetricList){  
                        metricTemp.Status = Indirect_Constants.GOAL_STATUS_COMPLETE;                     
                    }                         
                    Database.SaveResult[] updateMetrics = Database.Update(oldMetricList,false);
                    executeJob(updateMetrics, jobStatus); // Added to update job status from one method                                   
                } 
            }               
        } 
        catch(Exception e) {
            if(jobStatus!=null && !jobStatus.isEmpty()){
                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  Indirect_Constants.SYSTEM_EXCEPTION + e.getMessage() + Indirect_Constants.NEW_LINE : jobStatus[0].Comments__c + Indirect_Constants.SYSTEM_EXCEPTION + e.getMessage() +Indirect_Constants.NEW_LINE;                                    
                jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; 
                Database.update(jobStatus[0],false);   
            }         
        }   
              
    }
    
    //Execute Finish logic after execution of batch records completed
    global void finish(Database.BatchableContext BC){
        try{      
            List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
            if(jobStatus!=null && !jobStatus.isEmpty()){ 
                jobStatus[0].Batch_End_Time__c = Datetime.now(); 
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? Indirect_Constants.BATCH_COMPLETE_WITH_SUCCESS : Indirect_Constants.BATCH_COMPLETE_WITH_FAIL ; 
                Database.update(jobStatus[0],false); 
            } 
            
            //Update the current period start/due dates for current commission cycle for Monthly             
            goalDatesMonthly.Current_Period_Start_Date__c = goalDatesMonthly.Current_Period_Start_Date__c.addMonths(1);        
            goalDatesMonthly.Current_Period_Due_Date__c = goalDatesMonthly.Current_Period_Due_Date__c.addMonths(1);
            Database.update(goalDatesMonthly,false);
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }           
            
    }
    
     //Get job status    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
       return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
               Batch_Start_Time__c, Batch_End_Time__c FROM Job_Status__c 
               WHERE Status__c =: Indirect_Constants.JOB_STATUS_NEW AND ID =: jobStatusId]);
    
    }
    
    //update jobstatus
    public void executeJob(Database.SaveResult[] upsertGoals, List<Job_Status__c> jobStatus)
    {
        if(jobStatus!=null && !jobStatus.isEmpty()){
            for(Database.SaveResult result : upsertGoals) {
                jobStatus[0].Total_Records_Processed__c ++;
                if(!result.isSuccess()){                                                 
                    for(Database.Error error : result.getErrors()){
                        jobStatus[0].Number_Of_Fallouts__c  ++;
                        Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                        String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + Indirect_Constants.NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + Indirect_Constants.NEW_LINE;                                    
                        jobStatus[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;                                                                 
                     }
                }       
            }
            Database.update(jobStatus[0],false);
        } 
    }
}