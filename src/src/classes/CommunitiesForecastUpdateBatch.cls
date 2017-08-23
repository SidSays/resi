/**************************************************************************************************
Name : CommunitiesForecastUpdateBatch
Description : This batch class created to update Metric's Forecasted Units field with Total Units field on Opportunity
User Story : US670614
Date : 25 April 2016
Author : Sucheta Verma
***************************************************************************************************/

global class CommunitiesForecastUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    
     /*
    * Data Member 
    */
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'CommunitiesForecastUpdateBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string RECORD_TYPE_SEPERATION = ';';
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private static final string PROPERTY_LAB_CAR = 'Forecast_Setting';
    
    private static final string CLOSE_WON_STAGE = 'Closed Won';
    private static final String OpportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Xfinity Opportunity Record Type').getRecordTypeId();
    private static final String GoalRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
    private static final string METRIC_NAME = 'Units';
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    private Id jobStatusId = null;
    private String queryString = null;
    
   
    
    set<ID> oppAEId = new set<ID>();
    set<ID> goalListID = new set<ID>();
    Map<ID,ID> goalMetricIdMap = new  Map<ID,ID>();
    Map<Id,Decimal> mapIdString= new Map<Id,Decimal>();
    Map<Id,Opportunity> UserIdOppMap = new Map<Id,Opportunity>();
    private GoalTemplateDates__c goalDates = null;
    
     
    
    
     //public String queryString = 'Select id,name,profile.Name from User where profile.Name = \'XC Account Executive\' 
     //and IsActive = True and UserPermissionsWorkDotComUserFeature = true';
    
    /* Constructor for batch class CommunitiesForecastUpdateBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-   'Select id,name,profile.Name from User where profile.Name = \'XC Account Executive\' 
     and IsActive = True and UserPermissionsWorkDotComUserFeature = true';
     */
    
    global CommunitiesForecastUpdateBatch(String queryString){
        this.queryString = queryString;
    }
    
   /*
    * Query execution to fetch all users based on profiles - XC Account Executive
    */
    global Database.QueryLocator start(Database.BatchableContext bContext){
        
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
       
        //Get the commission cycle start and end date period from custom settings for BPROPERTY_LAB_CAR  commission cycle
        goalDates = GoalTemplateDates__c.getInstance(PROPERTY_LAB_CAR);
      //  preGoalStartDate = goalDates.Current_Period_Start_Date__c;
       // preGoalDueDate =  goalDates.Current_Period_Due_Date__c;
        return Database.getQueryLocator(queryString);
      }
      
     
     /*
     * Execute business logic to update Goals,Metrics Forecasted Units field with Total Units field on Opportunity 
     */
    global void execute(Database.BatchableContext bContext,List<User> scopeUser){
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        set<ID> userAEId = new set<ID>();
        List<Opportunity> opp = new List<Opportunity>();
    	List<Goal> goalList = new List<Goal>();
    	List<Metric> metricList = new List<Metric>();
    	List<Metric> finalResult =  new List<Metric>();
     
      try{ 
            
            for(User user : scopeUser){
               userAEId.add(user.Id) ;
                 
            }
             Date preGoalStartDate = goalDates.Current_Period_Start_Date__c; // 22/12/2015
             Date preGoalDueDate =  goalDates.Current_Period_Due_Date__c;
           
          
            if(userAEId!=null && !userAEId.isEmpty()){
             opp = [SELECT Id,Name,AssignedAE_ID__c,CompletionForecastDate__c,Number_of_Units__c,StageName,Goal__c,recordtype.name,recordtypeId from opportunity where 
                   AssignedAE_ID__c IN: userAEId and CompletionForecastDate__c >=: preGoalStartDate AND CompletionForecastDate__c <=: preGoalDueDate and recordtypeId =: OpportunityRecordTypeId];				   
               }
          
            for(Opportunity opptyId :opp){
                UserIdOppMap.put(opptyId.AssignedAE_ID__c,opptyId);
                oppAEId.add(opptyId.AssignedAE_ID__c);
                      
            }
          
            if(oppAEId!=null && !oppAEId.isEmpty()){
                goalList = [SELECT Id,recordtype.name,Owner.Name,OwnerId,DueDate,Name,StartDate,RecordTypeId FROM Goal  
                            where  recordtypeId =: GoalRecordTypeId and OwnerId IN: UserIdOppMap.keyset() and StartDate =: preGoalStartDate AND DueDate =: preGoalDueDate];                
               }
          
            for(Goal goalId : goalList){
                goalListID.add(goalId.Id);
				}
          
            if(goalList!=null && !goalList.isEmpty()){ 
                metricList = [SELECT Id,Name,OwnerID,TargetValue,Status,DueDate,Forecasted_Units_I__c from Metric where GoalId  IN: goalListID and Name =: METRIC_NAME];
                  
                }
          
            for(Opportunity oppty : opp){
               Decimal unit=oppty.Number_of_Units__c;
                  if(mapIdString.containsKey(oppty.AssignedAE_ID__c)){
                     mapIdString.put(oppty.AssignedAE_ID__c,mapIdString.get(oppty.AssignedAE_ID__c)+oppty.Number_of_Units__c);
                      
                    }else{
                         mapIdString.put(oppty.AssignedAE_ID__c,oppty.Number_of_Units__c);                       
                    }
                }
                
           for(User usr : scopeUser){              
                for(Metric metricUnits : metricList){                     
                    if(usr.id == metricUnits.OwnerId ){                     
						Decimal Units = mapIdString.get(metricUnits.OwnerId);                     
						metricUnits.Forecasted_Units_I__c = Units;                       
						finalResult.add(metricUnits);                        
                    }
                }
             }
            Database.SaveResult[] updateMetrics = Database.Update(finalResult,false);           
            executeJob(updateMetrics, jobStatus);
         }  
        
        catch(Exception e) {
             if(jobStatus!=null && !jobStatus.isEmpty()){
                    Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                    String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                    
                    jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0]);   
             }           
        } 
        
    }
    
    //Execute Finish logic after execution of batch records completed
     global void finish(Database.BatchableContext BC){ 
         List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
        if(jobStatus!=null && !jobStatus.isEmpty()){ 
            jobStatus[0].Batch_End_Time__c = Datetime.now(); 
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ; 
            Database.update(jobStatus[0]); 
        
        } 
           goalDates.Current_Period_Start_Date__c=goalDates.Current_Period_Start_Date__c.addMonths(1);
           goalDates.Current_Period_Due_Date__c=goalDates.Current_Period_Due_Date__c.addMonths(1);           
           update goalDates;
     }
    
    //Get job status    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
           return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                   Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                   Total_RGU_ORders_Upserted_Today__c 
                   FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId]);
    }
    
    
    public void executeJob(Database.SaveResult[] updateMetrics, List<Job_Status__c> jobStatus)
    {
        if(jobStatus!=null && !jobStatus.isEmpty()){
                for(Database.SaveResult result : updateMetrics) {
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
}