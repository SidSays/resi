/**************************************************************************************************
Name : IndirectMonthlyGoalCreationBatch
Description : This batch class created to update Goals and Metric status data as 'Completed' for previous cycle
and insert Activity  Metrics on monthly basis for Retail Sales Rep profile Users for current cycle.
User Story : US1024513/ US1041420
Date : 22/03/2017
Author : Tejaswini Kasar
Modified : Tejaswini Kasar 19-Apr-2017
Description: US1072960: Indirect - Coach for Indirect - Retail Sales Rep - RGU Goal Naming & Creation.
Updated batch class to update Goals and Metric status data as 'Completed' for previous cycle for Activity goals
and insert Activity and RGU Goals and Metrics on monthly basis for Retail Sales Rep profile Users for current cycle

***************************************************************************************************/
global class IndirectMonthlyGoalCreationBatch implements Database.Batchable<sObject>, Database.Stateful
{
    private static final set<string> PROFILENAME = new Set<String>{System.Label.Retail_Sales_Rep_ProfileName};
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    private Id jobStatusId = null;    
    private map<String, Goal> goaltemplateIdMap = new Map<String, Goal>();
    private map<String , Goal> goalTemplateNameMap = new map<String , Goal>();  
    private String query = Indirect_Constants.QUERY_INITIAL;
    private GoalTemplateDates__c goalDatesMonthly;
   
    /* Constructor for batch class IndirectMonthlyGoalCreationBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-  'Select Id,Name,profile.name,Region__c,Level__c from User where  IsActive = True AND profile.name IN: PROFILENAME and UserPermissionsWorkDotComUserFeature = true '
     */
    global IndirectMonthlyGoalCreationBatch(String query) 
    {
        this.query=query;        
    }
    
    /*
    * Query execution to fetch all users based on profiles - Retail Sales Rep
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Create Job Status Object
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = Indirect_Constants.BATCH_JOB_NAME_FOR_INDIRECT + Indirect_Constants.JOB_NAME_SPACE  + Datetime.now();
        jobStatus.Status__c = Indirect_Constants.JOB_STATUS_NEW;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = Indirect_Constants.JOB_COMMENT;
        jobStatus.Number_Of_Fallouts__c = 0;
        Database.insert(jobStatus , false);  
        jobStatusId = jobStatus.Id;
        
        //Generate goal data from Template for Retail Sales Rep 
        for(Goal goal : [SELECT Id,DueDate,Name,StartDate,Status,Profile_Name__c,OrigGoalId__c,Template_Type__c,Region__c,Sales_Rep_Type__c,RecordTypeId,Level__c,
                        (SELECT Id,Name,TargetValue,Status,DueDate,Weight,LastComment,Sort_Order__c FROM Metrics)FROM Goal WHERE Profile_Name__c IN: PROFILENAME 
                        AND recordtypeId =: Indirect_Constants.GOAL_TEMPLATE_RECORD_TYPE_ID 
                        AND Template_Type__c LIKE :Indirect_Constants.GOALTYPE]){
                            
            goaltemplateIdMap.put(goal.Id , goal);          
            goalTemplateNameMap.put((goal.Profile_Name__c +goal.Template_Type__c).trim() , goal); 
        }               
        //Fetching Monthly Goal Template Custom Setting Data 
        goalDatesMonthly = GoalTemplateDates__c.getInstance(Indirect_Constants.INDIRECT_MONTHLY_CS_RECORD);   
        preGoalStartDate = goalDatesMonthly.Current_Period_Start_Date__c;
        preGoalDueDate =  goalDatesMonthly.Current_Period_Due_Date__c;
        preGoalStartDate=preGoalStartDate.addMonths(1);
        preGoalDueDate=preGoalDueDate.addMonths(1);
                 
        return Database.getQueryLocator(query);
    }
    
    /*
     * Execute business logic to update Goals,Metrics to 'completed' status and insert new Activity Goals,Metrics
     */
    global void execute(Database.BatchableContext BC, List<User> userList){   
        List<Job_Status__c> jobStatus = new List<Job_Status__c>();
        List<Goal> goalList=new List<Goal>();                          
        List<Goal> goalStatusUpdateList = new List<Goal>();
        List<String> insertedGoalIdList = new List<String>();
        List<Metric> metricInsertList = new List<Metric>();
        Map<String,List<Metric>> userIdVsMetricListMap = new Map<String,List<Metric>>();        
        
        try {
            jobStatus = getJobStatus(jobStatusId);          
            /* Collect Activity goal's only that are to be mark as status completed */
            Map<ID,Goal> goalsIdObjectMap = new Map<ID,Goal>([SELECT Id,Name,DueDate,Template_Type__c,Status FROM Goal 
                                                              WHERE OwnerId IN:userList AND Id NOT IN:goaltemplateIdMap.keySet()  
                                                              AND Status !=: Indirect_Constants.GOAL_STATUS_COMPLETE 
                                                              AND DueDate <: System.today() 
                                                              AND Template_Type__c =: Indirect_Constants.ACTIVITY_STRING 
                                                              AND recordtypeId =: Indirect_Constants.INDIRECT_RECORD_TYPE_ID]);         
            if(goalsIdObjectMap != null && !goalsIdObjectMap.isEmpty()){
                //Fetching related metric's that are to be mark as status completed
                List<Metric> oldMetricList = [SELECT Id,Name,Status FROM Metric 
                                      WHERE GoalId IN:goalsIdObjectMap.keySet() 
                                      AND Status !=: Indirect_Constants.GOAL_STATUS_COMPLETE 
                                      AND DueDate <: System.today()];   
               
                
                /* Update 'goalStatusUpdateList' that are in previous commission cycle and status is not 'Completed' */
                for(Goal goalTemp : goalsIdObjectMap.values()){
                    goalTemp.Status = Indirect_Constants.GOAL_STATUS_COMPLETE;
                    goalStatusUpdateList.add(goalTemp);
                }  
                if(goalStatusUpdateList != NULL && !goalStatusUpdateList.isEmpty()){            
                    Database.SaveResult[] updateGoals = Database.Update(goalStatusUpdateList,false);
                    executeJob(updateGoals, jobStatus); // Added to update job status from one method    
                }           
                
                            
                /* Update metrics that are in previous commission cycle and status is not 'Completed' for respective Goals */
                if(oldMetricList != null && !oldMetricList.isEmpty()){
                    for(Metric metricTemp : oldMetricList){  
                        metricTemp.Status = Indirect_Constants.GOAL_STATUS_COMPLETE;                     
                    }                         
                    Database.SaveResult[] updateMetrics = Database.Update(oldMetricList,false);
                    executeJob(updateMetrics, jobStatus); // Added to update job status from one method                                   
                }
            } 
                             
            //RGU and Activity goal creation for Retail Sales Rep          
            for(User user:userList){
                Goal activityGoalTemp = new Goal();
                Goal activityGoal = new Goal();
                Goal rguGoalTemp = new Goal();
                Goal rguGoal = new Goal();
                if(user.profile.name == System.Label.Retail_Sales_Rep_ProfileName){
                //Code Refactored for "Activity" and "RGU" goals creation as a part of US1072960
                //Start
                    String UserprofileName = user.profile.name;
                    //Activity Goal Creation
                    if(goalTemplateNameMap.get((UserprofileName +Indirect_Constants.ACTIVITY_STRING).trim()) != null){                       
                        activityGoalTemp = goalTemplateNameMap.get((UserprofileName +Indirect_Constants.ACTIVITY_STRING).trim());
                        activityGoal = activityOrRguGoalCreation(true,activityGoalTemp.clone(false,true,true,false),user);//Get goal data from activityOrRguGoalCreation method ,boolean 'true' for activity goals
                        if(activityGoal != null){
                            goalList.add(activityGoal); 
                        }
                    } 
                    //Activity Metric Creation
                    List<Metric> activityMetricList = new List<Metric>();                                      
                    for(Metric metricTemp : activityGoal.Metrics){
                        Metric newMetricActivity = new Metric();
                        newMetricActivity = activityOrRguMetricCreation(metricTemp.Clone(false,true,true,false), user, metricTemp.Sort_Order__c);//Get metric data from activityOrRguGoalCreation method for Activity goals
                        activityMetricList.add(newMetricActivity);
                    } 
                    userIdVsMetricListMap.put(String.valueOf(user.Id) + activityGoal.Template_Type__c, activityMetricList);//Put activityMetricList in Map
                    
                    //RGU Goal Creation
                    if(goalTemplateNameMap.get((UserprofileName +Indirect_Constants.RGU_STRING).trim()) != null){
                        rguGoalTemp = goalTemplateNameMap.get((UserprofileName +Indirect_Constants.RGU_STRING).trim());
                        rguGoal = activityOrRguGoalCreation(false,rguGoalTemp.clone(false,true,true,false),user);//Get goal data from activityOrRguGoalCreation method ,boolean 'false' for RGU goals
                        if(rguGoal != null){
                            goalList.add(rguGoal); 
                        }
                    }
                    //RGU metric Creation                                                             
                    List<Metric> rguMetricList = new List<Metric>();
                    for(Metric metricTemp: rguGoal.Metrics){
                        Metric newMetricRgu = new Metric();
                        newMetricRgu = activityOrRguMetricCreation(metricTemp.Clone(false,true,true,false),user, metricTemp.Sort_Order__c);//Get metric data from activityOrRguGoalCreation method for RGU goals
                        rguMetricList.add(newMetricRgu); 
                    }               
                         
                    userIdVsMetricListMap.put(String.valueOf(user.Id) + rguGoal.Template_Type__c, rguMetricList);//Put rguMetricList in Map
                //End                   
                }                
            }
            //Insert new goal For Activity and RGU;  
            Database.SaveResult[] insertGoals = Database.Insert(goalList,false);
            executeJob(insertGoals, jobStatus); // Added to update job status from one method
            
            for(Database.SaveResult sr : insertGoals){
                if(sr.isSuccess()){
                    insertedGoalIdList.add(sr.getId());
                }
            }     
            
            if(insertedGoalIdList != null && !insertedGoalIdList.isEmpty()){
                for(Goal goalObj : [SELECT Id, OwnerId, Name, Template_Type__c FROM Goal WHERE Id In : goalList]){                
                    if(userIdVsMetricListMap.get(String.valueOf(goalObj.OwnerId) + goalObj.Template_Type__c) != null){
                       for(Metric metricObj : (List<Metric>) userIdVsMetricListMap.get(String.valueOf(goalObj.OwnerId) + goalObj.Template_Type__c)){
                            metricObj.GoalId = goalObj.Id;
                            metricInsertList.add(metricObj);                     
                       }               
                    }             
                }
            }
            
            //Insert new Metric For Activity and RGU;  
            if(metricInsertList != NULL && !metricInsertList.isEmpty()){
                Database.SaveResult[] insertMetrics = Database.Insert(metricInsertList,false); 
                executeJob(insertMetrics, jobStatus); // Added to update job status from one method   
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
            
            //Call IndirectRetailManagerActivityGoalBatch AND bypass for Test class 
            String queryString = '';
            if(System.Label.IndirectRetailManagerActivityGoalBatchQuery != Null){
                queryString = System.Label.IndirectRetailManagerActivityGoalBatchQuery;
            }
            Integer batchSize=1;
            if(System.Label.IndirectRetailManagerActivityGoalBatchSize!=null && System.Label.IndirectRetailManagerActivityGoalBatchSize.isNumeric()){
                batchSize=Integer.valueOf(System.Label.IndirectRetailManagerActivityGoalBatchSize);
            }
            IndirectRetailManagerActivityGoalBatch inst= new IndirectRetailManagerActivityGoalBatch(queryString); 
            if(!Test.isRunningTest()){ 
                database.executebatch(inst, batchSize);
            }
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }           
            
    }
   
    //Get job status    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
       return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
               Batch_Start_Time__c, Batch_End_Time__c FROM Job_Status__c 
               WHERE Status__c =: Indirect_Constants.JOB_STATUS_NEW AND ID=: jobStatusId]);
    }
    /**
    * @Description: This method contains goal data to be cloned for Retail Sales Rep.This method is to be called wherever goal creation is done
    * @Author: Tejaswini kasar
    * @Date: 19-APR-2017
    */
    public Goal activityOrRguGoalCreation(Boolean isActivityGoal, Goal cloneGoal, User user){                                        
        cloneGoal.OwnerId = user.Id;
        cloneGoal.Region__c = user.Region__c;       
        cloneGoal.Status = Indirect_Constants.GOAL_STATUS_PUBLISHED;
        cloneGoal.RecordTypeId = Indirect_Constants.INDIRECT_RECORD_TYPE_ID;
        Datetime dtDueDate = datetime.newInstance(preGoalDueDate.year(), preGoalDueDate.month(),preGoalDueDate.day());
        //Put start and due date in the goal to be created                
        cloneGoal.StartDate = preGoalStartDate;
        cloneGoal.DueDate = preGoalDueDate;
        cloneGoal.Level__c = user.Level__c;
        //For RGU Goal      
        if(!isActivityGoal){
            cloneGoal.Name = user.Name+Indirect_Constants.RGU_TEMPLATE + dtDueDate .formatGMT(Indirect_Constants.DATE_FORMAT_STR);
        }else{
        //For Activity Goal
            cloneGoal.Name = user.Name+Indirect_Constants.ACTIVITY_TEMPLATE + dtDueDate .formatGMT(Indirect_Constants.DATE_FORMAT_STR);
        }
        return cloneGoal;
    }
    
    /**
    * @Description: This method contains metric data to be cloned for Retail Sales Rep.This method is to be called wherever metric creation is done
    * @Author: Tejaswini kasar
    * @Date: 19-APR-2017
    */
    public Metric activityOrRguMetricCreation(Metric newMetric, User user, Decimal sortOrder){ 
        newMetric.ownerId = user.Id;
        newMetric.DueDate = preGoalDueDate;
        newMetric.Status = Indirect_Constants.METRIC_STATUS_NOTSTARTED;
        newMetric.Sort_Order__c = sortOrder;
        return newMetric;
        
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