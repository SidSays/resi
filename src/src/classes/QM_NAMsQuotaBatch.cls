/**************************************************************************************************
Name : QM_NAMsQuotaBatch 
Description : This batch class created to set up Quota for NAMs User 
User Story : US680953
Date : 9 May 2016
Author : Mangesh Wanjari
 
***************************************************************************************************/

global class QM_NAMsQuotaBatch implements Database.Batchable<sObject>, Database.Stateful{
    
   /*
    * Data Member 
    */  
    
    private final Static String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'QM_NAMsQuotaBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string RECORD_TYPE_SEPERATION = ';';
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private static final String GOAL_STATUS_PUBLISHED = 'Published';
    private Id jobStatusId = null;   
    private String query= null;
     public String sRTString ='NAM';
     private GoalTemplateDates__c goalDates = null;
    // public String query='Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND  Sales_Rep_Type__c =:sRTString  and UserPermissionsWorkDotComUserFeature = true';

    global QM_NAMsQuotaBatch(String query)
    {
        this.query=query;
    }
     global Database.QueryLocator start(Database.BatchableContext BC){
         
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
        
        //Fetch Custom setting records(Goal Startdate and Duedate) 
        goalDates = GoalTemplateDates__c.getInstance('NAMs_Quota');
        return Database.getQueryLocator(query);  
     }
     
      global void execute(Database.BatchableContext BC, List<User> scopeList){ 
              List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        try{
               List<Goal> goalList=new List<Goal>();  
               Map<String, Goal> goalMap = new Map<String, Goal>(); 
               Map<String , Goal> goalSettingMap = new Map<String , Goal>();
               Map<String,List<Metric>> UserIDMetricListMap = new Map<String,List<Metric>>();
               List<Metric> metricInsertList = new List<Metric>();
               
               Date preGoalStartDate = goalDates.Current_Period_Start_Date__c; // 22/12/2015
               Date preGoalDueDate =  goalDates.Current_Period_Due_Date__c; //21/01/2016
               system.debug('preGoalStartDate'+preGoalStartDate);
               system.debug('preGoalStartDate'+preGoalStartDate);
               
               DateTime preGoalStartDateTime = goalDates.Current_Period_Start_Date__c; 
               DateTime preGoalDueDateTime = goalDates.Current_Period_Due_Date__c;                 
               String Goal_Template_RecordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId();
               String XfinityCommunitiesRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId(); 
               
                for(Goal gol : [select Id,Assigned_To__c,Template_Type__c,DueDate,Name,StartDate,Status,Profile_Name__c,Region__c,Sales_Rep_Type__c,(Select Id,Name,TargetValue,Status,DueDate,Weight,LastComment from Metrics)  from Goal where Template_Type__c =: system.label.Goal_Template_Type_Communities and Sales_Rep_Type__c =:sRTString and RecordtypeId =: Goal_Template_RecordtypeId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) { 
                    goalSettingMap.put(gol.Profile_Name__c, gol);             
                    goalMap.put(gol.Id , gol);
                }
                
                 for(User user:scopeList){ 
                        Goal goalInst = goalSettingMap.get(user.Profile.name);
                        if(goalInst != null){
                           //Logic to create 12 months goal
                            for(integer i=0;i<12;i++){
                                String UserIDGoalDueDate=String.valueOf(user.Id) + preGoalDueDate;
                                Goal getGoal= goalMap.get(goalInst.id);                         
                                Goal cloneGoal = new Goal();
                                List<Metric> metricList=new List<Metric>();                         
                                cloneGoal=getGoal.Clone(false,true,true,false);                                                                                         
                                cloneGoal.OwnerId=user.Id; 
                                   if(user.ManagerId != null){
                                cloneGoal.Reporting_Manager__c=user.ManagerId;}  //added for US814543                                                                                                                                                                                                                           
                                cloneGoal.Status = GOAL_STATUS_PUBLISHED;                                                                                
                                cloneGoal.Name= user.Name+'_NAM Quota_'+preGoalDueDateTime.formatGMT('MMMM yyyy');                         
                                //Put start and due date in the goal to be create                                           
                                cloneGoal.StartDate = preGoalStartDate; //22/12/2015    
                                cloneGoal.DueDate = preGoalDueDate;                         
                                cloneGoal.RecordTypeId = XfinityCommunitiesRecordTypeId ; 
                                goalList.add(cloneGoal);
                                    for(Metric metr: cloneGoal.Metrics){
                                        Metric mt = new Metric();
                                        mt=metr.Clone(false,true,true,false);                                                                  
                                        mt.OwnerId=user.Id;                                                                                                                                                                                
                                        mt.Status='NotStarted';
                                        mt.StartDate = preGoalStartDate;
                                        mt.DueDate = preGoalDueDate;
                                        metricList.add(mt);
                                    }    
                                
                                UserIDMetricListMap.put(UserIDGoalDueDate, metricList);                       
                                preGoalStartDate =preGoalStartDate.addMonths(1);
                                preGoalDueDate = preGoalDueDate.addMonths(1);
                                preGoalStartDateTime=preGoalStartDateTime.addMonths(1);
                                preGoalDueDateTime=preGoalDueDateTime.addMonths(1);
                            }
                            
                            //For resetting the StartDate and EndDate
                            preGoalStartDate= goalDates.Current_Period_Start_Date__c;
                            preGoalDueDate=goalDates.Current_Period_Due_Date__c; 
                            preGoalStartDateTime=goalDates.Current_Period_Start_Date__c; 
                            preGoalDueDateTime=goalDates.Current_Period_Due_Date__c;                        
                        }                       
                }
                system.debug('goalList****'+goalList);
                //Inserting new Goals records 
                Database.SaveResult[] insertGoals = Database.Insert(goalList,false);
                
                
                
            if(jobStatus!=null && !jobStatus.isEmpty()){
                for(Database.SaveResult result : insertGoals) {
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
                
                
               
                // Assigning metric to goal
                for(Goal goalObj : goalList){
                    if(UserIDMetricListMap.get(String.valueOf(goalObj.OwnerId) + goalObj.DueDate) != null){
                       List<Metric> metricInsertList1 = new List<Metric>();
                       String UserIDGoalDueDate = String.valueOf(goalObj.OwnerId) + goalObj.DueDate; 
                       for(Metric metricObj : (List<Metric>) UserIDMetricListMap.get(UserIDGoalDueDate)){
                            metricObj.GoalId = goalObj.Id;
                            metricInsertList1.add(metricObj);                     
                       }
                       metricInsertList.addAll(metricInsertList1);       
                    }                              
                }
                system.debug('metricInsertList****'+metricInsertList);
                //Inserting new Metrics
                Database.SaveResult[] insertMetrics = Database.Insert(metricInsertList,false);
                
                 if(jobStatus!=null && !jobStatus.isEmpty()){
                for(Database.SaveResult result : insertMetrics) {
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
                
            }catch(Exception e){
                 if(jobStatus!=null && !jobStatus.isEmpty()){
                    Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                    String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                    
                    jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0]);   
                 }           
            }
      }
      
       global void finish(Database.BatchableContext BC){ 
            
            List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
            if(jobStatus!=null && !jobStatus.isEmpty()){ 
                jobStatus[0].Batch_End_Time__c = Datetime.now(); 
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ; 
                Database.update(jobStatus[0]); 
            } 
             //Update Custom Setting Date
            goalDates.Current_Period_Start_Date__c=goalDates.Current_Period_Start_Date__c.addMonths(12);
            goalDates.Current_Period_Due_Date__c=goalDates.Current_Period_Due_Date__c.addMonths(12);           
            update goalDates;
       }
       
        //Get job status    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
           return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                   Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                   Total_RGU_ORders_Upserted_Today__c 
                   FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId]);
    }
}