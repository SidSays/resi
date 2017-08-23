/**************************************************************************************************
Name : UpdateMetricBatch 
Description : This batch class is created to update metrics for ASM and SDM.   
User Story : US765271
Date : 20 Sep 2016
Author : Mandeep Singh
Description : Updating the activity metrics of Property Lab and Indirect channel metrics in daily basis 
              as status will update as per remaining days logic(US1096500)
Last Modified By : Amit Kumar Pradhan
Last Modified Date : 16th May 2017
***************************************************************************************************/
global class UpdateMetricBatch implements Database.Batchable<sObject>,Database.Stateful{
  
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final String BATCH_JOB_NAME = 'UpdateMetricBatch';
    private static final String JOB_STATUS = 'New';
    private static final String NEW_LINE = '\n';
    private static final String SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final String JOB_COMMENT = ' ';
    private static final String JOB_NAME_SPACE = ' - ';
    //private static final String DATE_STRINGS = '-';//unused variable(Commented By Amit Kumar Pradhan)
    //private static final String ACTIVITY_GOAL_DATES= 'ActivityGoalCommissionCycle';//unused variable(Commented By Amit Kumar Pradhan)
    
    /****************************
    * Start User Story: US1096500
    * Description : Added constant variable and static variable
    * Auther : Amit Kumar Pradhan
    * Date : 16th May 2017
    *****************************/  
    private static final String COMMA_SEPARATION = ',';
    private static final String METRIC_TRIGGER_BATCH_CHECK = 'MetricTriggerBatchCheck';
    private static final String GOAL_TRIGGER = 'GoalTrigger';
    private static final String PROFILE_CHECK = 'ProfileCheckForActivityMetricUpdate';
    private static final String JOB_TYPE = 'BatchApex';
    private static final Set<String> JOB_STATUS_SET = new Set<String>{'Holding','Queued','Preparing','Processing'};     
    private static final String BLANK_INITIALIZATION = '';
    private Set<String> profileNameSet = new Set<String>();
    private Set<String> metricNameSet = new Set<String>();
    private Date yesterdayDate = Date.today().addDays(-1);
    /***************************
    * End User Story: US1096500
    ****************************/
    
    private Id jobStatusId = null; 
    private List<Job_Status__c> jobStatusList = new List<Job_Status__c>();
       
    /****************************
    * Start User Story: US1096500
    * Modified : 1.Commented activityGoalCycleDates, goalStartDate and goalEndDate variables as it is not used.
                 2.Replacing hardcoding value with constant(METRIC_TRIGGER_BATCH_CHECK,GOAL_TRIGGER).
                 3.Commented "triggerList" variable as it is not used.
                 4.Initialization of query variable.
    * Last Modified By : Amit Kumar Pradhan
    * Last Modified Date : 16th May 2017
    *****************************/
    //private GoalTemplateDates__c activityGoalCycleDates = GoalTemplateDates__c.getInstance(ACTIVITY_GOAL_DATES);  
    //private Date goalStartDate = activityGoalCycleDates.Current_Period_Start_Date__c; 
    //private Date goalEndDate =  activityGoalCycleDates.Current_Period_Due_Date__c;  
    private TriggerSettings__c triggerSetting = TriggerSettings__c.getValues(METRIC_TRIGGER_BATCH_CHECK);
    private TriggerSettings__c goaltriggerSetting = TriggerSettings__c.getValues(GOAL_TRIGGER);
    //private List<TriggerSettings__c> triggerList = new List<TriggerSettings__c>();
    private String query = BLANK_INITIALIZATION;
    /****************************
    * End User Story: US1096500
    *****************************/
    
    /*********************************
     * Constructor for batch class UpdateMetricBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :- 'SELECT Id FROM Metric WHERE Name IN: metricNameSet AND Owner.Profile.Name IN: profileNameSet 
                        AND Goal.Duedate >=: yesterdayDate AND Owner.IsActive = true'
     * Description : Fetching the metrics which have "Goal.Duedate >=: yesterdayDate" because batch class scheduled at 1 AM of every day 
                     and we need to update privious month goal on 22(start date of every month).
                     It will not impact the current month Goals becacuse goal creation batches(for all channels) are scheduled after 3 AM.              
    **********************************/
    global UpdateMetricBatch(String query){
        this.query = query;
    }
    
    /*********************************
     * Overriding start method of Database.Batchable interface
     * Creating job status record inside start method
    **********************************/
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<TriggerSettings__c> triggerList = new List<TriggerSettings__c>();
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
        
        /****************************
        * Start User Story: US1096500
        * Modified : 1.commented indivisual update of trigger setting variable. Now added in a list and update the list
                     2.Added profile check while querying the metrics.
        * Last Modified By : Amit Kumar Pradhan
        * Last Modified Date : 16th May 2017
        *****************************/
        //"MetricTriggerBatchCheck" trigger setting is activated
        if(triggerSetting != null){
            triggerSetting.isActive__c = true;
            //database.Update(triggerSetting);
            triggerList.add(triggerSetting);
        }else{}
        //Goal trigger setting is deactivated
        if(goaltriggerSetting != null){
            goaltriggerSetting.isActive__c = false;
            //database.Update(goaltriggerSetting);
            triggerList.add(goaltriggerSetting);
        }else{}
        //Updating triggerList
        if(!triggerList.isEmpty()){
            Database.update(triggerList,false);
        }else{}
        
        //Fetching profiles from variable setting
        Variable_Setting__c profileNames = Variable_Setting__c.getInstance(PROFILE_CHECK); 
        if(profileNames != null){
            profileNameSet.addAll(profileNames.Value__c.split(COMMA_SEPARATION));
        }else{}
        
        //Fetching Metric Names from custom setting
        List<Metric_Name_Setting__c> metricNameList = Metric_Name_Setting__c.getall().values(); 
        if(metricNameList != null){
            for(Metric_Name_Setting__c metricName : metricNameList){
                metricNameSet.add(metricName.Metric_Name__c);
            }            
        }else{}       
        /****************************
        * End User Story: US1096500
        *****************************/
        
        return Database.getQueryLocator(query);
    } 
    
    /*********************************
     * Overriding execute method of Database.Batchable interface
     * Blank updating the metric record to updating correct status as per the remaining logic.
    **********************************/
    global void execute(Database.BatchableContext BC, List<Metric> scopeList){   
        try{
            if(!scopeList.isEmpty()){ 
                Database.SaveResult[] saveResult = Database.Update(scopeList,false);
                if(jobStatusList!=null && !jobStatusList.isEmpty()){
                    for(Database.SaveResult result : saveResult) {
                        jobStatusList[0].Total_Records_Processed__c ++;
                        if(!result.isSuccess()){                                                 
                            for(Database.Error error : result.getErrors()){
                                jobStatusList[0].Number_Of_Fallouts__c ++;Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                                String errorMsg = error.getMessage() + NEW_LINE;String incrErrorMsg = jobStatusList[0].Comments__c + errorMsg;
                                String tempMsg = String.IsBlank(jobStatusList[0].Comments__c)? errorMsg : incrErrorMsg;                                    
                                jobStatusList[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;                                                                 
                            }
                        }else{}       
                    }
                    Database.update(jobStatusList[0],false);
                }else{}
            }else{} 
        }catch(Exception e){
            if(jobStatusList!=null && !jobStatusList.isEmpty()){
                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                String errorMsg = SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE;String incrErrorMsg = jobStatusList[0].Comments__c + errorMsg;
                String tempMsg = string.IsBlank(jobStatusList[0].Comments__c) ? errorMsg : incrErrorMsg;                                    
                jobStatusList[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg;Database.update(jobStatusList[0],false);   
            }else{}           
        }    
    }
      
    /*********************************
     * Overriding finish method of Database.Batchable interface
     * Updating current job status with propper status(Completed with/without error)
     * Updating Trigger setting records.
    **********************************/   
    global void finish(Database.BatchableContext BC){   
        /*****************************
         * Start User Story: US1096500
         * Description : Fetching AsyncApexJob record count for MetricDailyUpdateBatchNew batch class to check wheather
                            we need to deactivate the Goal Trigger or not. Also added try..catch.
         * Last Updated By : Amit Kumar Pradhan
         * Last Updated Date : 16th May 2017
        *****************************/
        try{    
            List<TriggerSettings__c> triggerSettingList = new List<TriggerSettings__c>();
            //Fetching AsyncApexJob record count for MetricDailyUpdateBatchNew batch class to check wheather we need to deactivate the Goal Trigger or not.
            //If count is > 0 then don't deactivate the Goal trigger.
            Integer jobCount = [SELECT count() FROM AsyncApexJob WHERE ApexClassID =: System.Label.MetricDailyUpdateBatchNewId 
                                AND JobType =: JOB_TYPE AND CreatedDate = Today AND Status IN: JOB_STATUS_SET 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            
            //deactivated "MetricTriggerBatchCheck" trigger setting     
            if(triggerSetting != null){       
                triggerSetting.isActive__c = false; 
                triggerSettingList.add(triggerSetting);
            }else{}
            
            //Activate Goal Trigger if jobCount == 0        
            if(jobCount == 0 && goaltriggerSetting != null){      
                goaltriggerSetting.isActive__c = true;
                triggerSettingList.add(goaltriggerSetting);
            }else{}
            //Updating triggerSettingList
            if(!triggerSettingList.isEmpty()){
                Database.update(triggerSettingList,false);
            }else{} 
        /***************************
         * End User Story: US1096500
        ****************************/
            
            List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);     
            if(jobStatus!=null && !jobStatus.isEmpty()){ 
                //jobStatus[0].Total_Records_Processed__c = count;
                jobStatus[0].Batch_End_Time__c = Datetime.now(); 
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ; 
                Database.update(jobStatus[0],false); 
            }else{}
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }
    }
    
    /***********************
    * @Description: This method return job status 
    * @Author: Mandeep Singh, Accenture
    * @Date: 20 Sept 2016
    * @Param: Id
    * @Return: List<Job_Status__c>
    ***********************/ 
    private List<Job_Status__c> getJobStatus(Id jobStatusId){
        return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, Batch_Start_Time__c, Batch_End_Time__c 
                    FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID =: jobStatusId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
    }
}