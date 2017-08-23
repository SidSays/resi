/**********************************************************************************************************************************
Name : RGUMetricResetBatch
Description : This batch class created to reset RGU Metric data on daily basis
Date : 19-Aug-2016
Author : Ritesh Saxena
Last Modified By:Tejaswini Kasar(Metric daily update batch automation for handling Goal Trigger)
Last Modified Date : 25-Aug-2016
Last Modified Date : 29-Dec-2016(US872123,US872120,US872118,US872117)
Last Modified By : Animesh Datta(West Division ASM/SDM/XSP RGU and Activity Goals to Monthly) 
***********************************************************************************************************************************/
global class RGUMetricResetBatch implements Database.Batchable<sObject>, Database.StateFul { 

    /*
    * Data Member 
    */      
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'RGUMetricResetBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string RECORD_TYPE_SEPERATION = ';';
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private Id jobStatusId = null; 
    private TriggerSettings__c goalTriggerSetting ;
    private boolean isWestDivision = false;
    //Select all task with any sold lob 
    private static final string BIWEEKLY_STARTEND_CUST_SET = 'ByWeeklyStartAndEndDate';
    private static final string MONTHLY_STARTEND_CUST_SET = 'MonthlyStartAndEndDateDS';
    Date COMMISION_START_DATE = null;
    Date COMMISION_END_DATE = null;

    /* Constructor for batch class MetricDailyUpdateBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample queryString :-'SELECT Id,Status, CurrentValue FROM Metric where Goal.RecordTypeId=: GOAL_DIRECTSALES_RECORD_ID and Goal.Name like '%RGU%' and Goal.DueDate =: BYWEEK_COMMISION_END_DATE' '
     */
     
    public String queryString= '';
    
    /*
    * Constructor call
    */
    global RGUMetricResetBatch(String query, Boolean isWest)
    {
        this.queryString = query;
        isWestDivision = isWest;
    }
    
   /*
    * Query execution to fetch all RGU Metric
    */
  /*
   *US753588:GoalTrigger set to 'inactive' in 'Start' method.
   */
    global Database.QueryLocator start(Database.BatchableContext bContext){                               
        goalTriggerSetting = TriggerSettings__c.getInstance('GoalTrigger');
        If(goalTriggerSetting != NULL){
        goalTriggerSetting.isActive__c = false;
        update goalTriggerSetting; 
        }
        //Create Job Status Object
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
        String GOAL_DIRECTSALES_RECORD_ID = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId(); 
        
        GoalTemplateDates__c startEndDateDates; 
        
        if(isWestDivision){
            startEndDateDates = GoalTemplateDates__c.getInstance(MONTHLY_STARTEND_CUST_SET); //Fetching Monthly Goal Template Custom Setting Data 
        }
        if(!isWestDivision){
            startEndDateDates = GoalTemplateDates__c.getInstance(BIWEEKLY_STARTEND_CUST_SET); //Fetching Biweakly Goal Template Custom Setting Data 
        }
        
        COMMISION_START_DATE = startEndDateDates.Current_Period_Start_Date__c;
        COMMISION_END_DATE =  startEndDateDates.Current_Period_Due_Date__c;
        
        if(Test.isRunningTest()) {
            queryString+= ' Limit 10';
        } 
                
        return Database.getQueryLocator(queryString);              
    }
    
   /*
    * Execute business logic to update Metrics
    */
    global void execute(Database.BatchableContext bContext, List<Metric> metricList){

        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);  
        try{                    

            Map<Id, Metric> metricUpdateMap = new Map<Id, Metric>();
                       
            for(Metric mObj : metricList){
                mObj.CurrentValue=0;
                mObj.Status='NotStarted';
                metricUpdateMap.put(mObj.id, mObj);                                              
            }           
           
            /* Update Metric Data And Job Status */
            if(!metricUpdateMap.isEMpty()){ 
                Database.SaveResult[] saveResult = Database.Update(metricUpdateMap.values(),false);
                if(jobStatus!=null && !jobStatus.isEmpty()){
                    for(Database.SaveResult result : saveResult) {
                        jobStatus[0].Total_Records_Processed__c ++;
                        if(!result.isSuccess()){                                                 
                            for(Database.Error error : result.getErrors()){
                                jobStatus[0].Number_Of_Fallouts__c  ++;
                                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + NEW_LINE;                                    
                                jobStatus[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;                                                                 
                             }
                        } else{}       
                    }

                    Database.update(jobStatus[0]);
                }
            }             
           
        }catch(Exception e) {
            if(jobStatus!=null && !jobStatus.isEmpty()){
                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                    
                jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0]);   
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
        //Execute if 'Goal Trigger' is inactive
        if(goalTriggerSetting.isActive__c == false){
        // Call Metric Daily Update batch 1 other then West Division Users
        if(!isWestDivision){
            String queryString = '';
        if(System.Label.MetricDailyBatchQueryNew1!= Null){
            queryString = System.Label.MetricDailyBatchQueryNew1;
        }
        Integer batchSize=200;
        if(System.Label.MetricDailyNewBatchSize1!=null && System.Label.MetricDailyNewBatchSize1.isNumeric()){
            batchSize=Integer.valueOf(System.Label.MetricDailyNewBatchSize1);
        }
        MetricDailyUpdateBatchNew inst= new MetricDailyUpdateBatchNew(queryString,false); 
        database.executebatch(inst, batchSize);
        }
        // Call Metric Daily Update batch 2 for other then West Division Users
        if(!isWestDivision){
            String queryString2 = '';
        if(System.Label.MetricDailyBatchQueryNew2!= Null){
            queryString2 = System.Label.MetricDailyBatchQueryNew2;
        }
        Integer batchSize2=200;
        if(System.Label.MetricDailyNewBatchSize2!=null && System.Label.MetricDailyNewBatchSize2.isNumeric()){
            batchSize2=Integer.valueOf(System.Label.MetricDailyNewBatchSize2);
        }
        MetricDailyUpdateBatchNew inst2= new MetricDailyUpdateBatchNew(queryString2,false); 
        database.executebatch(inst2, batchSize2);
        }
        // Call Metric Daily Update batch 3 for West Division Users
        if(isWestDivision){
            String queryString3 = '';
        if(System.Label.MetricDailyBatchQueryNew3!= Null){
            queryString3 = System.Label.MetricDailyBatchQueryNew3;
        }
        Integer batchSize3=200;
        if(System.Label.MetricDailyNewBatchSize3!=null && System.Label.MetricDailyNewBatchSize3.isNumeric()){
            batchSize3=Integer.valueOf(System.Label.MetricDailyNewBatchSize3);
        }
        MetricDailyUpdateBatchNew inst3= new MetricDailyUpdateBatchNew(queryString3,true); 
        database.executebatch(inst3, batchSize3);
        } 
    }  
}
       
   /* 
    * Get job status 
    */           
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        return [SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                Total_RGU_ORders_Upserted_Today__c 
                FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId];
    } 
}