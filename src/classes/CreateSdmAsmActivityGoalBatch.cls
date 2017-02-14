/**************************************************************************************************
Name : CreateSdmAsmActivityGoalBatch
Description : This batch class creates and updates activity goals of SDM and ASM on monthly basis. 
User Story : US573832 & US573830
Date : 02 December 2015
Author : Pranjal Singh
***************************************************************************************************/
global class CreateSdmAsmActivityGoalBatch implements Database.Batchable<sObject>, Database.Stateful{
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'CreateSdmAsmActivityGoalBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private Id jobStatusId = null;   
    
    private final set<string> profileName = new Set<String>{System.Label.DS_Supervisor,System.Label.DS_Manager};
    private String queryString='';
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    private final string GOAL_STATUS_COMPLETE = 'Completed'; 
    private final set<string> goalType = new Set<String>{'%Activity%'};
    private static final String directSalesRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();
    private date todaysDate;
    private string ActivityGoalCommissionCycle='ActivityGoalCommissionCycle';
   
      global CreateSdmAsmActivityGoalBatch(String query)
    {
        this.queryString=query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Job_Status__c job = new Job_Status__c();
        job.Name = BATCH_JOB_NAME + JOB_NAME_SPACE  + Datetime.now();
        job.Status__c = JOB_STATUS;
        job.Total_Records_Processed__c = 0;
        job.Total_RGU_Activations_Processed__c = 0;
        job.Total_RGU_Orders_Processed__c = 0;
        job.Total_RGU_ORders_Upserted_Today__c = 0;
        job.Batch_Start_Time__c = Datetime.now();
        //job.Batch_End_Time__c = Datetime.now();
        job.Comments__c = JOB_COMMENT;
        job.Number_Of_Fallouts__c = 0;
        Database.insert(job);  
        jobStatusId = job.Id;
        
      //  queryString= 'Select id,Name,profile.name from user where Isactive=TRUE AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true and (Id=\'00516000005cPHY\' or Id=\'005G0000004IbAA\')';
        GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(ActivityGoalCommissionCycle);
        preGoalStartDate = goalDates.Current_Period_Start_Date__c;
        preGoalDueDate =  goalDates.Current_Period_Due_Date__c;
        preGoalStartDate=preGoalStartDate.addMonths(1);
        preGoalDueDate=preGoalDueDate.addMonths(1);
        todaysDate=system.today();
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<User> userList){   
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        List<Goal> goalStatusUpdateList = new List<Goal>();
        List <Goal> newGoalList= New List <Goal>(); 
        Metric ObjMetric;
        List<Metric> metricList = new List<Metric> ();
        //old goals
         Map<ID,Goal> goalsIdObjectMap = new Map<ID,Goal>([SELECT Id,Name,DueDate,Status FROM Goal 
                                                    WHERE OwnerId IN:userList AND Status !=: GOAL_STATUS_COMPLETE AND DueDate <: todaysDate AND Name LIKE :goalType]);         
         //old metrics
        List<Metric> metric = [SELECT Id,Name,Status FROM Metric WHERE GoalId IN:goalsIdObjectMap.keySet() AND Status !=: GOAL_STATUS_COMPLETE AND DueDate <: todaysDate];
         for(Goal goalTemp : goalsIdObjectMap.values()){
                goalTemp.Status = GOAL_STATUS_COMPLETE;
                goalStatusUpdateList.add(goalTemp);
            }
        //update old goal
            Database.SaveResult[] updateGoals = Database.Update(goalStatusUpdateList,false);
            executeJob(updateGoals, jobStatus);
         for(Metric metricTemp : metric){  
                metricTemp.Status = GOAL_STATUS_COMPLETE;  
            }            
        //update old metric
            Database.SaveResult[] updateMetrics = Database.Update(metric,false); 
            executeJob(updateMetrics, jobStatus);
        //Create Goals
            Datetime dtStartDate = datetime.newInstance(preGoalStartDate.year(), preGoalStartDate.month(),preGoalStartDate.day());
            For(User Usr:userList){            
                Goal Objgoal= new Goal ();               
                Objgoal.Name= Usr.Name+'-Activity-'+ dtStartDate.formatGMT('MMM-yyyy');
                Objgoal.Status= 'Published';
                Objgoal.ownerId= Usr.Id;
                objgoal.RecordTypeId=directSalesRecordTypeId;
                objgoal.StartDate=preGoalStartDate;
                objGoal.DueDate=preGoalDueDate;
                objGoal.Profile_Name__c=usr.profile.name;                
                newGoalList.add(Objgoal);                
            }
            Database.SaveResult[] insertGoals = Database.insert(newGoalList,true); 
            executeJob(insertGoals, jobStatus);
           
                map<id,AggregateResult> idcountMap = New map<id,AggregateResult> ([Select managerId Id,Count(Id)xsp From User where Isactive=TRUE and UserPermissionsWorkDotComUserFeature = true and managerId in: userList group by managerId ]);
               //create metrics
        For(Goal goal:newGoalList)
                {
                    if(goal.Profile_Name__c==System.Label.DS_Supervisor){
                                ObjMetric = New Metric();       
                                ObjMetric.Name = System.Label.Coaching;
                                ObjMetric.OwnerId = goal.ownerId ;
                                objMetric.Status = 'NotStarted';
                                objMetric.StartDate=preGoalStartDate;
                                objMetric.DueDate=preGoalDueDate;
                                ObjMetric.TargetValue = Integer.valueOf(System.Label.Target_SDM_Coaching);//9 per week
                                ObjMetric.GoalId=goal.id;
                                metricList.add(ObjMetric);
                        
                                ObjMetric = New Metric();
                                ObjMetric.Name = System.Label.Team_Huddles;
                                ObjMetric.OwnerId = goal.ownerId;
                                objMetric.Status = 'NotStarted';
                                objMetric.StartDate=preGoalStartDate;
                                objMetric.DueDate=preGoalDueDate;
                                ObjMetric.TargetValue = Integer.valueOf(System.Label.Target_SDM_Team_Huddles);//2 per week
                                ObjMetric.GoalId=goal.id;
                                metricList.add(ObjMetric);
                        
                                if(idcountMap.containsKey(goal.ownerId)){
                                    ObjMetric = New Metric();
                                ObjMetric.Name = System.Label.Walkalongs;
                                ObjMetric.OwnerId = goal.ownerId;
                                objMetric.Status = 'NotStarted';
                                objMetric.StartDate=preGoalStartDate;
                                objMetric.DueDate=preGoalDueDate;
                                ObjMetric.GoalId=goal.id;
                                ObjMetric.TargetValue = Integer.valueOf((idcountMap.get(goal.ownerId)).get('xsp'))*2;//no of xsp *2
                                metricList.add(ObjMetric);
                                }
                                
                    }else{
                                ObjMetric = New Metric();        
                                ObjMetric.Name = System.Label.Team_Forums;
                                ObjMetric.OwnerId = goal.ownerId ;
                                objMetric.Status = 'NotStarted';
                                objMetric.StartDate=preGoalStartDate;
                                objMetric.DueDate=preGoalDueDate;        
                                ObjMetric.TargetValue = Integer.valueOf(System.Label.Target_ASM_Team_Forums);//2 per month
                                ObjMetric.GoalId=goal.id;
                                metricList.add(ObjMetric);    
                                
                               if(idcountMap.containsKey(goal.ownerId)){
                                ObjMetric = New Metric();
                                ObjMetric.Name = System.Label.Coaching;
                                ObjMetric.OwnerId = goal.ownerId ;
                                objMetric.Status = 'NotStarted';
                                objMetric.StartDate=preGoalStartDate;
                                objMetric.DueDate=preGoalDueDate;
                                ObjMetric.GoalId=goal.id;
                                ObjMetric.TargetValue = Integer.valueOf((idcountMap.get(goal.ownerId)).get('xsp'))*2;//no. of sdm * 2
                                metricList.add(ObjMetric); 
                               }
                                
                    }
                    
                   }
                Database.SaveResult[] insertMetrics = Database.insert(metricList,true); 
                executeJob(insertMetrics, jobStatus);            
    }
         //Execute Finish logic after execution of batch records completed
    global void finish(Database.BatchableContext BC){ 
    
        GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(ActivityGoalCommissionCycle);
        goalDates.Current_Period_Start_Date__c = goalDates.Current_Period_Start_Date__c.addMonths(1);        
        goalDates.Current_Period_Due_Date__c = goalDates.Current_Period_Due_Date__c.addMonths(1);        
        Database.update(goalDates);
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
        if(jobStatus!=null && !jobStatus.isEmpty()){ 
            jobStatus[0].Batch_End_Time__c = Datetime.now(); 
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ; 
            Database.update(jobStatus[0]); 
        }   
    }

    
      //Get job status    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
           return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                   Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                   Total_RGU_ORders_Upserted_Today__c 
                   FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId]);
    }
    //update jobstatus
     public void executeJob(Database.SaveResult[] updateGoals, List<Job_Status__c> jobStatus)
    {
        if(jobStatus!=null && !jobStatus.isEmpty()){
                for(Database.SaveResult result : updateGoals) {
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