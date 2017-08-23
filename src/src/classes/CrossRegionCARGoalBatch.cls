/**************************************************************************************************
Name : CrossRegionCARGoalBatch
Description : This batch class is created to create Property Lab Goals and Metric value data on Monthly basis for Cross Regional Lead.
User Story : US960508
Date : 24 February 2017
Author : Animesh Datta
Last Modified By: Animesh Datta/ US1137734 - Fixed issue found during testing when there is no CAR in region who has goal, then do not create Goal/Metrics
Last Modified Date: 17-Jul-2017 
***************************************************************************************************/
global class CrossRegionCARGoalBatch implements Database.Batchable<sObject>, Database.Stateful{
    private Id jobStatusId = null;   
    private GoalTemplateDates__c goalDates = null;  
    private String queryString = '';
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    private Map<String,Decimal> regionDateMap;
    
    private static final Set<String> profileNameSet  = new Set<String>{Label.CrossCARXCLeadProfileName}; 
    private Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
    
    /* Constructor for batch class CrossRegionCARGoalBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     */  
    global CrossRegionCARGoalBatch(String query){
        this.queryString=query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Job_Status__c job = new Job_Status__c();
        job.Name = PL_Constants.BATCH_JOB_NAME_FOR_CROSS_LEAD_CAR + PL_Constants.JOB_NAME_SPACE  + Datetime.now();
        job.Status__c = PL_Constants.JOB_STATUS_NEW;
        job.Total_Records_Processed__c = 0;
        job.Total_RGU_Activations_Processed__c = 0;
        job.Total_RGU_Orders_Processed__c = 0;
        job.Total_RGU_ORders_Upserted_Today__c = 0;
        job.Batch_Start_Time__c = Datetime.now();
        job.Comments__c = PL_Constants.JOB_COMMENT;
        job.Number_Of_Fallouts__c = 0;
        
        Database.insert(job);  
        jobStatusId = job.Id;      
        goalDates = GoalTemplateDates__c.getInstance(Label.CrossRegionCARGoal_Custom_Settings);      
        preGoalStartDate = goalDates.Current_Period_Start_Date__c.addMonths(1);
        preGoalDueDate = goalDates.Current_Period_Due_Date__c.addMonths(1);

        return Database.getQueryLocator(queryString);
    }
    /****************
    Last Modified By: Animesh Datta/ US1137734 - Fixed issue found during testing when there is no CAR in region who has goal, then do not create Goal/Metrics
    Last Modified Date: 17-Jul-2017
    ***************/
    global void execute(Database.BatchableContext BC, List<User> scopeList){
        
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        List <Goal> newGoalList= new List <Goal>(); 
        List<Id> createdGoalList = new List<Id>();
        Set<String> userIdSet =  new Set<String>();
        Set<String> userRegionSet = new Set<String>();
        regionDateMap = new Map<String,Decimal>();
        set<Id> crossChanneluserIdSet = new set<Id>();
        List<Goal> goalStatusUpdateList = new List<Goal>();
        List<Metric> metricUpdateList = new List<Metric>();
        
        String dateString = preGoalDueDate.month()+ PL_Constants.DATE_DELIMIT +preGoalDueDate.day() + 
              PL_Constants.DATE_DELIMIT + preGoalDueDate.year();
        Database.SaveResult[] insertGoals = new List<Database.SaveResult>();//US1137734 - Issue found during testing. initialized.            
        
        for(User user:scopeList){
                userRegionSet.add(user.Region__c); 
                crossChanneluserIdSet.add(user.Id);
        }
        /* Mark Previous Goal and Metric as completed */
            Map<ID,Goal> goalsIdObjectMap = new Map<ID,Goal>([SELECT Id,Name,DueDate,Status FROM Goal 
                                                    WHERE OwnerID IN : crossChanneluserIdSet AND Status !=: PL_Constants.GOAL_STATUS_COMPLETE 
                                                    AND RecordtypeId =: PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID 
                                                    AND DueDate <: System.today() 
                                                    AND Name LIKE :PL_Constants.GOALTYPE 
                                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);    
                                                    
            List<Metric> metric = [SELECT Id,Name,Status FROM Metric WHERE GoalId IN:goalsIdObjectMap.keySet() 
                                    AND Status !=: PL_Constants.GOAL_STATUS_COMPLETE AND DueDate <: System.today() 
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];   
                                    
            
            /* Update 'goalStatusUpdateList' that are in previous commission cycle and status is not 'Completed' */
            for(Goal goalTemp : goalsIdObjectMap.values()){
                goalTemp.Status = PL_Constants.GOAL_STATUS_COMPLETE; 
                goalStatusUpdateList.add(goalTemp);
            }                   
            Database.SaveResult[] updateGoals = Database.Update(goalStatusUpdateList,false);  
            
            /* Update metricUpdateList that are in previous commission cycle and status is not 'Completed' for respective Goals */
            for(Metric metricTemp : metric){  
                metricTemp.Status = PL_Constants.GOAL_STATUS_COMPLETE;  
                metricUpdateList.add(metricTemp); 
            }                       
            Database.SaveResult[] updateMetrics = Database.Update(metricUpdateList,false);
        
        
        for(User user: [Select Id, Name,Region__c From User where isActive = TRUE AND Profile.Name = 'Xfinity CAR' AND Region__c IN: userRegionSet AND UserPermissionsWorkDotComUserFeature = true]){
                //for(User userObj : [Select Id, Name From User where isActive = TRUE AND Profile.Name = 'Xfinity CAR']){
            userIdSet.add(user.Id);
        }
            //}
            
        for(Goal goalList : [select Id,Assigned_To__c,DueDate,Name,StartDate,Status,Profile_Name__c,Region__c,Sales_Rep_Type__c,(Select Id,Name,TargetValue,Status,DueDate,Weight,LastComment from Metrics) from Goal where RecordtypeId = :PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID AND Profile_Name__c = 'Xfinity CAR' AND StartDate >=:preGoalStartDate AND DueDate <=:preGoalDueDate AND OwnerId IN:userIdSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {            
            for(Metric metricObj : goalList.Metrics){
                if(goalList.Region__c != '' && goalList.DueDate != Null && metricObj.Name !=Null){
                    if(regionDateMap.containsKey(metricObj.Name+goalList.Region__c + goalList.DueDate)) {
                        regionDateMap.put((metricObj.Name + goalList.Region__c + goalList.DueDate), regionDateMap.get(metricObj.Name + goalList.Region__c + goalList.DueDate)+metricObj.TargetValue);                         
                    } else{
                        regionDateMap.put((metricObj.Name + goalList.Region__c + goalList.DueDate) , metricObj.TargetValue);                             
                    }
                }
            }  
        }
        
        for(User Usr:scopeList){
            //Start - Animesh - US1137734 - Fixed issue found during testing when there is no CAR in region who has goal, then do not create Goal/Metrics
            if(!regionDateMap.isEmpty() && regionDateMap.containsKey(System.Label.Metric_Name_TotalPropertyVisitsperMonth + Usr.Region__c + preGoalDueDate) &&
            regionDateMap.containsKey(System.Label.Metric_Name_Events + Usr.Region__c + preGoalDueDate) && 
            regionDateMap.containsKey(System.Label.Metric_Name_AveragePropertyVisitsperDay + Usr.Region__c + preGoalDueDate)){
            //End - Animesh  - US1137734 - Fixed issue found during testing when there is no CAR in region who has goal, then do not create Goal/Metrics
                Goal objGoal= new Goal ();               
                objGoal.Name= 'Cross Regional Lead' + ' - PL - '+ Usr.Region__c+' - '+ dateString;
                objGoal.Status = PL_Constants.GOAL_STATUS_PUBLISHED;
                objGoal.ownerId= Usr.Id;
                objGoal.Assigned_To__c = Usr.Id;
                objGoal.Template_Type__c = PL_Constants.TEMPLATE_TYPE_PROPERTYLAB;
                objGoal.RecordTypeId = PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID;
                objGoal.StartDate=preGoalStartDate;
                objGoal.DueDate=preGoalDueDate;
                objGoal.Region__c = Usr.Region__c;
                objGoal.Profile_Name__c=usr.profile.name;
                newGoalList.add(objGoal);                                 
            }
        }
        
        if(!newGoalList.isEmpty()){
            insertGoals = Database.Insert(newGoalList,false);
        }
            
        executeJob(insertGoals,jobStatus);
          
        for(Database.SaveResult sr : insertGoals){
            if(sr.isSuccess()){
                createdGoalList.add(sr.getId());
            }
        }
        newGoalList = [SELECT Id, OwnerId,Region__c,DueDate FROM Goal WHERE Id IN :createdGoalList];
        
        //Creat Metrics for Cross Regional Lead
        createMetrics(newGoalList,jobStatus);
        
    }
    
    //Execute Finish logic after execution of batch records completed
    global void finish(Database.BatchableContext BC){
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);      
        if(jobStatus!=null && !jobStatus.isEmpty()){ 
            jobStatus[0].Batch_End_Time__c = Datetime.now(); 
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? PL_Constants.BATCH_COMPLETE_WITH_SUCCESS : PL_Constants.BATCH_COMPLETE_WITH_FAIL ; 
            Database.update(jobStatus[0]); 
        }         
        //Update Custom Setting Date
        goalDates.Current_Period_Start_Date__c=goalDates.Current_Period_Start_Date__c.addMonths(1);
        goalDates.Current_Period_Due_Date__c=goalDates.Current_Period_Due_Date__c.addMonths(1);
        update goalDates;
    }
    
    //Get job status
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        try{
            return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c,Batch_Start_Time__c, Batch_End_Time__c, 
               Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c, Total_RGU_ORders_Upserted_Today__c 
                     FROM Job_Status__c WHERE Status__c =: PL_Constants.JOB_STATUS_NEW 
                     AND ID= :jobStatusId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
            return null;
        }
    }
    
    //update jobstatus
    public void executeJob(Database.SaveResult[] updateGoals, List<Job_Status__c> jobStatus){
        try{
            if(jobStatus!=null && !jobStatus.isEmpty()){
                for(Database.SaveResult result : updateGoals) {
                    jobStatus[0].Total_Records_Processed__c ++;
                    if(!result.isSuccess()){                                                 
                        for(Database.Error error : result.getErrors()){
                            jobStatus[0].Number_Of_Fallouts__c  ++;
                            String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? error.getMessage() + PL_Constants.NEW_LINE :jobStatus[0].Comments__c + error.getMessage() + PL_Constants.NEW_LINE;                                    
                            jobStatus[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;                                                                 
                         }
                    }       
                }
                Database.update(jobStatus[0]);
            } 
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }
    }
    
    private void createMetrics(List<Goal> newGoalList, List<Job_Status__c> jobStatus){
        
        List<Metric> metricList = new List<Metric> ();
        Metric objMetric;
        for(Goal goal : newGoalList){
            String regionDueDateString = goal.Region__c+ goal.DueDate;
            
            //Total Property Visits per Month Metric
            ObjMetric = New Metric();       
            ObjMetric.Name = System.Label.Metric_Name_TotalPropertyVisitsperMonth;
            ObjMetric.OwnerId = goal.OwnerId;
            objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
            objMetric.DueDate= goal.DueDate;
            ObjMetric.TargetValue = regionDateMap.get(System.Label.Metric_Name_TotalPropertyVisitsperMonth+regionDueDateString);  
            ObjMetric.GoalId= goal.id;
            objMetric.Sort_Order__c = 1;
            metricList.add(ObjMetric);                    
            
            //Average Property Visits per Day Metric
            ObjMetric = New Metric();       
            ObjMetric.Name = System.Label.Metric_Name_AveragePropertyVisitsperDay;
            ObjMetric.OwnerId = goal.OwnerId;
            objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
            objMetric.DueDate= goal.DueDate;
            ObjMetric.TargetValue = regionDateMap.get(System.Label.Metric_Name_AveragePropertyVisitsperDay+regionDueDateString); 
            ObjMetric.GoalId= goal.id;
            objMetric.Sort_Order__c = 2;
            metricList.add(ObjMetric);
            
            //Profile Completness Metric
            ObjMetric = New Metric();       
            ObjMetric.Name = System.Label.Metric_Name_ProfileCompletionPercent;
            ObjMetric.OwnerId = goal.OwnerId;
            objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
            objMetric.DueDate= goal.DueDate;
            ObjMetric.TargetValue = 100;
            ObjMetric.GoalId= goal.id;
            objMetric.Sort_Order__c = 3;
            metricList.add(ObjMetric);
            
            //Event Metric
            ObjMetric = New Metric();       
            ObjMetric.Name = System.Label.Metric_Name_Events;
            ObjMetric.OwnerId = goal.OwnerId;
            objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
            objMetric.DueDate= goal.DueDate;
            ObjMetric.TargetValue = RegionDateMap.get(System.Label.Metric_Name_Events+regionDueDateString); 
            ObjMetric.GoalId= goal.id;
            objMetric.Sort_Order__c = 4;
            metricList.add(ObjMetric);
        }
        
        Database.SaveResult[] insertMetrics = Database.insert(metricList,false); 
        executeJob(insertMetrics, jobStatus);
    }
    
}