/**************************************************************************************************
Name : IndirectRetailManagerActivityGoalBatch
Description : This batch class creates and updates activity goals of Retail Sales Manger on monthly basis. 
User Story : US1024560
Date : 20/03/2017   
Author : Suchita Sharma
Modified : Srini Bhattiprolu 21-Mar-2017
Description : US1041443: Indirect - Coach for Indirect - Completed Observations & 1:1s - Metric Targets
Modified : Tejaswini Kasar 19-Apr-2017
Description: US1073377: Indirect - Coach for Indirect - Retail Sales Manager - RGU Goal Naming & Creation
***************************************************************************************************/
global class IndirectRetailManagerActivityGoalBatch implements Database.Batchable<sObject>, Database.Stateful{
  
    private Id jobStatusId = null; 
    private final set<string> PROFILENAME = new Set<String>{System.Label.Retail_Sales_Manager_ProfileName};
    public String query = Indirect_Constants.QUERY_INITIAL;
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    private date todaysDate;
    private String queryString ='';
    private GoalTemplateDates__c goalDates;
    
    /* Constructor for batch class IndirectRetailManagerActivityGoalBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-  'Select Id,Name,profile.name,Region__c from User where  IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true '
     */
    global IndirectRetailManagerActivityGoalBatch(String query)
    {
        this.queryString=query;
       
    }
    
    /*
    *Query execution to fetch all users based on profiles - Retail Sales Manager
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Job_Status__c job = new Job_Status__c();
        job.Name = Indirect_Constants.BATCH_JOB_NAME_FOR_MGR_ACTIVITY + Indirect_Constants.JOB_NAME_SPACE  + Datetime.now();
        job.Status__c = Indirect_Constants.JOB_STATUS_NEW ;
        job.Total_Records_Processed__c = 0;       
        job.Batch_Start_Time__c = Datetime.now();
        job.Comments__c = Indirect_Constants.JOB_COMMENT ;
        job.Number_Of_Fallouts__c = 0;
        Database.insert(job);  
        jobStatusId = job.Id;
        todaysDate=system.today();
        
        //Fetching Monthly Goal Template Custom Setting Data 
        goalDates = GoalTemplateDates__c.getInstance(Indirect_Constants.INDIRECTACTIVITYGOALCOMMISSIONCYCLE);   
        preGoalStartDate = goalDates.Current_Period_Start_Date__c;
        preGoalDueDate =  goalDates.Current_Period_Due_Date__c;
        preGoalStartDate=preGoalStartDate.addMonths(1);
        preGoalDueDate=preGoalDueDate.addMonths(1);
        
        return Database.getQueryLocator(queryString);
    }
    
    /*
    * Execute business logic to insert new Goals,Metrics Data for Retail Sales Manager
    */
    global void execute(Database.BatchableContext BC, List<User> userList){   
        List<Job_Status__c> jobStatus = new List<Job_Status__c>();
        List<Goal> goalStatusUpdateList = new List<Goal>();
        List<Goal> newGoalList= new List<Goal>(); 
        List<String> insertedGoalIdList =new List<String>();        
        List<Metric> metricList = new List<Metric> ();
        Metric ObjMetric;
        
        try{
            jobStatus = getJobStatus(jobStatusId);
            //old goals 
            Map<ID,Goal> goalsIdObjectMap = 
                        new Map<ID,Goal>([SELECT Id, Name, DueDate,Status FROM Goal 
                                          WHERE OwnerId IN:userList AND Status !=: Indirect_Constants.GOAL_STATUS_COMPLETE 
                                          AND DueDate <: todaysDate AND Template_Type__c =:Indirect_Constants.ACTIVITY_STRING  
                                          AND recordtypeId =: Indirect_Constants.INDIRECT_RECORD_TYPE_ID LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);         
            //old metrics
            if(goalsIdObjectMap != null && !goalsIdObjectMap.isEmpty()){
                List<Metric> metric =  [SELECT Id,Name,Status FROM Metric 
                                        WHERE GoalId IN:goalsIdObjectMap.keySet() 
                                        AND Status !=: Indirect_Constants.GOAL_STATUS_COMPLETE AND DueDate <: todaysDate LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                for(Goal goalTemp : goalsIdObjectMap.values()){
                        goalTemp.Status = Indirect_Constants.GOAL_STATUS_COMPLETE;
                        goalStatusUpdateList.add(goalTemp);
                }
                //update old goal to mark status as commpleted
                if(!goalStatusUpdateList.isEmpty()){
                    Database.SaveResult[] updateGoals = Database.Update(goalStatusUpdateList,false);
                    executeJob(updateGoals, jobStatus);
                }
                //update old Metric to mark status as commpleted
                if(metric != null && !metric.isEmpty()){
                    for(Metric metricTemp : metric){  
                            metricTemp.Status = Indirect_Constants.GOAL_STATUS_COMPLETE;  
                    }
                    //update old metric to mark status as commpleted
                    Database.SaveResult[] updateMetrics = Database.Update(metric,false); 
                    executeJob(updateMetrics, jobStatus);
                }
            }
            //Create Goals for Retail Sales Manager
            Datetime dtDueDate = datetime.newInstance(preGoalDueDate.year(), preGoalDueDate.month(),preGoalDueDate.day());
            for(User Usr:userList){
                //Activity Goals
                Goal ObjgoalActivity = new Goal (); 
                ObjgoalActivity = activityOrRguGoalCreation(true, Usr);
                newGoalList.add(ObjgoalActivity);
           
                //RGU Goals
                Goal ObjgoalRGU = new Goal (); 
                ObjgoalRGU = activityOrRguGoalCreation(false, Usr);
                newGoalList.add(ObjgoalRGU);
                
            }
            
            Database.SaveResult[] insertGoals = Database.insert(newGoalList,false); 
            executeJob(insertGoals, jobStatus);
            if(insertGoals != null && !insertGoals.isEmpty()){
                for(Database.SaveResult sr : insertGoals){
                    if(sr.isSuccess()){
                        insertedGoalIdList.add(sr.getId());
                    }
                }
            }
            
            
            map<id,AggregateResult> idcountMap = 
                new map<id,AggregateResult> ([SELECT managerId Id,Count(Id)Rep 
                                              FROM User WHERE Isactive=TRUE AND UserPermissionsWorkDotComUserFeature = true 
                                              AND managerId in: userList GROUP BY managerId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            
            //create metrics
            if(!insertedGoalIdList.isEmpty()){
                for(Goal goal:[SELECT id,Profile_Name__c,Template_Type__c,ownerId FROM Goal WHERE Id IN: insertedGoalIdList LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(goal.Profile_Name__c==System.Label.Retail_Sales_Manager_ProfileName){
                       //For Activity Metrics
                       if(goal.Template_Type__c == Indirect_Constants.ACTIVITY_STRING){
                            if(idcountMap.containsKey(goal.ownerId)){
                                //Total number of store visits
                                //Modified Sorting Number by Kiran to implement US1097894 *START*-->
                                ObjMetric = New Metric();
                                ObjMetric =  metricCreation(goal,System.Label.TotalNumberOfStoreVisitsMetricName,1,Integer.valueOf((idcountMap.get(goal.ownerId)).get(Indirect_Constants.REP_COUNT))*Integer.valueOf(System.Label.Target_RetailManager_TotalNumberOfStoreVisits));
                                metricList.add(ObjMetric);
                                /*
                                ObjMetric.Name = System.Label.TotalNumberOfStoreVisitsMetricName;
                                ObjMetric.OwnerId = goal.ownerId;
                                objMetric.Status = Indirect_Constants.METRIC_STATUS_NOTSTARTED;
                                objMetric.StartDate=preGoalStartDate;
                                objMetric.DueDate=preGoalDueDate;
                                ObjMetric.GoalId=goal.id;
                                ObjMetric.TargetValue = Integer.valueOf((idcountMap.get(goal.ownerId)).get(Indirect_Constants.REP_COUNT))*Integer.valueOf(System.Label.Target_RetailManager_TotalNumberOfStoreVisits);//no of Rep *40
                                ObjMetric.Sort_Order__c = 2;*/
                                
                                /*
                                For all the activity metrics for Retail Sales Manager,Replaced the above code part.Instead code refactored using metricCreation method as part of US1073377
                                */
                                
                                //Average store visit duration
                            ObjMetric = New Metric();
                            ObjMetric =  metricCreation(goal,System.Label.AverageStoreVisitDurationMetricName,2,Integer.valueOf(System.Label.Target_RetailManager_AverageStoreVisitDuration));
                            metricList.add(ObjMetric);
                                  
                                //Number of 1:1s
                                ObjMetric = New Metric();
                                ObjMetric =  metricCreation(goal,System.Label.NumberOf1_1s,3,Integer.valueOf((idcountMap.get(goal.ownerId)).get(Indirect_Constants.REP_COUNT ))*Integer.valueOf(System.Label.Target_RetailManager_NumberOf1_1s));
                                metricList.add(ObjMetric);
                                
                            }
                             //Completed Observations
                                ObjMetric = New Metric();
                                ObjMetric =  metricCreation(goal,System.Label.CompletedObservations,4,Integer.valueOf((idcountMap.get(goal.ownerId)).get(Indirect_Constants.REP_COUNT))*Integer.valueOf(System.Label.Target_RetailManager_CompletedObservations));
                                metricList.add(ObjMetric);
                                  //Modified by Kiran to implement US1097894 *END*-->
                        //For RGU Metrics (as part of US1073377)
                        }else if(goal.Template_Type__c == Indirect_Constants.RGU_STRING){
                            //Video 
                            ObjMetric = New Metric();
                            ObjMetric =  metricCreation(goal,System.Label.Video,1,1);
                            metricList.add(ObjMetric);
                            
                            //Internet
                            ObjMetric = New Metric();
                            ObjMetric =  metricCreation(goal,System.Label.HSD,2,1);
                            metricList.add(ObjMetric);
                            
                            //Voice
                            ObjMetric = New Metric();
                            ObjMetric = metricCreation(goal,System.Label.Voice,3,1);
                            metricList.add(ObjMetric);
                            
                            //XH
                            ObjMetric = New Metric();
                            ObjMetric = metricCreation(goal,System.Label.XH,4,1);
                            metricList.add(ObjMetric);
                            
                            //Total
                            ObjMetric = new Metric();
                            ObjMetric = metricCreation(goal,System.Label.Total,5,1);
                            metricList.add(ObjMetric);
                        }else{}
                    }else{}
                    
                }
                Database.SaveResult[] insertMetrics = Database.insert(metricList,false); 
                executeJob(insertMetrics, jobStatus);  
            }
        }catch(Exception e){
             if(jobStatus!=null && !jobStatus.isEmpty()){
                  Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                  String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  Indirect_Constants.SYSTEM_EXCEPTION + e.getMessage() + Indirect_Constants.NEW_LINE : jobStatus[0].Comments__c + Indirect_Constants.SYSTEM_EXCEPTION + e.getMessage() +Indirect_Constants.NEW_LINE;                                    
                  jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0]);   
            }       
        }
    }
    
    /*
    * Execute Finish logic after execution of batch records completed
    */   
    global void finish(Database.BatchableContext BC){ 
        try{
           
            goalDates.Current_Period_Start_Date__c = goalDates.Current_Period_Start_Date__c.addMonths(1);        
            goalDates.Current_Period_Due_Date__c = goalDates.Current_Period_Due_Date__c.addMonths(1);        
            Database.update(goalDates);
            
            List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
            if(jobStatus!=null && !jobStatus.isEmpty()){ 
                jobStatus[0].Batch_End_Time__c = Datetime.now(); 
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? Indirect_Constants.BATCH_COMPLETE_WITH_SUCCESS : Indirect_Constants.BATCH_COMPLETE_WITH_FAIL ; 
                Database.update(jobStatus[0]); 
            }  
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }
    }
    
     
    /*
    * Get job status  
    */   
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
     return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
               Batch_Start_Time__c, Batch_End_Time__c FROM Job_Status__c 
               WHERE Status__c =: Indirect_Constants.JOB_STATUS_NEW AND ID=: jobStatusId]);
    }
    
    /**
    * @Description: This method contains goal data for Retail Sales Rep.This method is to be called wherever goal creation is done
    * @Author: Tejaswini kasar
    * @Date: 19-APR-2017
    */
    public Goal activityOrRguGoalCreation(Boolean isActivityGoal, User user){
        Goal goal = new goal();      
        goal.OwnerId = user.Id;
        goal.Region__c = user.Region__c;       
        goal.Status = Indirect_Constants.GOAL_STATUS_PUBLISHED;
        goal.RecordTypeId = Indirect_Constants.INDIRECT_RECORD_TYPE_ID;
        Datetime dtDueDate = datetime.newInstance(preGoalDueDate.year(), preGoalDueDate.month(),preGoalDueDate.day());
        //Put start and due date in the goal to be create                
        goal.StartDate = preGoalStartDate;
        goal.DueDate = preGoalDueDate;
        goal.Profile_Name__c = user.profile.name; 
                
        if(!isActivityGoal){
            goal.Name = user.Name+Indirect_Constants.RGU_TEMPLATE + dtDueDate .formatGMT(Indirect_Constants.DATE_FORMAT_STR);
            goal.Template_Type__c = Indirect_Constants.RGU_STRING;
        }else{
            goal.Name = user.Name+Indirect_Constants.ACTIVITY_TEMPLATE + dtDueDate .formatGMT(Indirect_Constants.DATE_FORMAT_STR);
            goal.Template_Type__c = Indirect_Constants.ACTIVITY_STRING;
        }
        return goal;
    }
    /**
    * @Description: This method contains metric data for Retail Sales Rep.This method is to be called wherever metric creation is done
    * @Author: Tejaswini kasar
    * @Date: 19-APR-2017
    */
    public Metric metricCreation(Goal goal, String metricName, Decimal sortOrder, Integer TargetValue){
        Metric newMetric = new Metric();        
        newMetric.name = metricName;
        newMetric.ownerId = goal.ownerId;
        newMetric.Status = Indirect_Constants.METRIC_STATUS_NOTSTARTED;
        newMetric.StartDate=preGoalStartDate;
        newMetric.DueDate=preGoalDueDate;
        newMetric.TargetValue = TargetValue;
        newMetric.Sort_Order__c = sortOrder;
        newMetric.GoalId=goal.id;
        return newMetric;

    }

    /* 
    * update jobstatus
    */
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
            Database.update(jobStatus[0]);
        }
    }
}