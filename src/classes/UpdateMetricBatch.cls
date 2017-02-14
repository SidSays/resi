/**************************************************************************************************
Name : UpdateMetricBatch 
Description : This batch class is created to update metrics for ASM and SDM.   
User Story : US765271
Date : 20 Sep 2016
Author : Mandeep Singh
***************************************************************************************************/

global class UpdateMetricBatch implements Database.Batchable<sObject>,Database.Stateful{
  
    private final Static String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'UpdateMetricBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private static final string DATE_STRINGS =  '-';
    private static final string ACTIVITY_GOAL_DATES= 'ActivityGoalCommissionCycle'; 
    private Id jobStatusId = null; 
    //private List<Metric> metricList = new List<Metric>();
    private List<Job_Status__c> jobStatusList = new List<Job_Status__c>();
    private GoalTemplateDates__c activityGoalCycleDates = GoalTemplateDates__c.getInstance(ACTIVITY_GOAL_DATES);
    private Date ACTIVITY_GOAL_START_DATES= activityGoalCycleDates.Current_Period_Start_Date__c;
    private Date ACTIVITY_GOAL_END_DATES=  activityGoalCycleDates.Current_Period_Due_Date__c;
    private TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('MetricTriggerBatchCheck');
    private TriggerSettings__c goaltriggerSetting = TriggerSettings__c.getValues('GoalTrigger');
    private List<TriggerSettings__c> triggerList = new List<TriggerSettings__c>();
    public String query;
 
    global UpdateMetricBatch(String query) {
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
        jobStatusList.add(jobStatus);
        Database.insert(jobStatusList);  
        jobStatusId = jobStatus.Id;
                
        triggerSetting.isActive__c = true;
        database.Update(triggerSetting);
        //triggerList.add(triggerSetting);
        goaltriggerSetting.isActive__c = false;
        database.Update(goaltriggerSetting);
        //triggerList.add(goaltriggerSetting);
        
        //database.Update(triggerList);
 
        return Database.getQueryLocator(query);
    } 
  
    global void execute(Database.BatchableContext BC, List<Metric> scopeList){   
        try{
            if(!scopeList.isEmpty()){ 
                Database.SaveResult[] saveResult = Database.Update(scopeList,false);
                if(jobStatusList!=null && !jobStatusList.isEmpty()){
                    for(Database.SaveResult result : saveResult) {
                        jobStatusList[0].Total_Records_Processed__c ++;
                        if(!result.isSuccess()){                                                 
                            for(Database.Error error : result.getErrors()){
                                jobStatusList[0].Number_Of_Fallouts__c  ++;
                                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                                String tempMsg = string.IsBlank(jobStatusList[0].Comments__c) ?  error.getMessage() + NEW_LINE : jobStatusList[0].Comments__c + error.getMessage() + NEW_LINE;                                    
                                jobStatusList[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;                                                                 
                             }
                        } else{}       
                    }
                    Database.update(jobStatusList[0]);
                }
            } 
        }catch(Exception e){
            if(jobStatusList!=null && !jobStatusList.isEmpty()){
                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                String tempMsg = string.IsBlank(jobStatusList[0].Comments__c) ?  SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatusList[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                    
                jobStatusList[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatusList[0]);   
            }           
        }    
    }
      
       
    global void finish(Database.BatchableContext BC){
    
       triggerSetting.isActive__c = false;
       database.Update(triggerSetting);
       //triggerList.add(triggerSetting);
       goaltriggerSetting.isActive__c = true;
       database.Update(goaltriggerSetting);
       //triggerList.add(goaltriggerSetting);
        
       //database.Update(triggerList);
        
    List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
    
    if(jobStatus!=null && !jobStatus.isEmpty()){ 
        //jobStatus[0].Total_Records_Processed__c = count;
        jobStatus[0].Batch_End_Time__c = Datetime.now(); 
        jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ; 
        Database.update(jobStatus[0]); 
        } 
    }
    
    public List<Job_Status__c> getJobStatus(Id jobStatusId){
    return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
    Batch_Start_Time__c, Batch_End_Time__c 
    FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId]);
    }
}