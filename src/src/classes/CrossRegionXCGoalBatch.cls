/**************************************************************************************************
Name : CrossRegionXCGoalBatch
Description : This batch class is created to create Communities Goals and Metric value data on Annual basis for Cross Regional Lead.
User Story : US960508
Date : 24 February 2017
Author : Ashish Srivastava 
***************************************************************************************************/

global class CrossRegionXCGoalBatch implements Database.Batchable<sObject>, Database.Stateful{
    private Id jobStatusId = null;   
    private GoalTemplateDates__c goalDates = null;  
    private String queryString = '';
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    private static final String STRING_COUNT = 'CNT';
    private Map<String,Decimal> regionDateMap;
    
    private static final Set<String> profileNameSet  = new Set<String>{Label.CrossCARXCLeadProfileName}; 
    private Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
    
    global CrossRegionXCGoalBatch(String query){
        this.queryString=query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Job_Status__c job = new Job_Status__c();
        job.Name = PL_Constants.BATCH_JOB_NAME_FOR_CROSS_LEAD_XC + PL_Constants.JOB_NAME_SPACE  + Datetime.now();
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
        goalDates = GoalTemplateDates__c.getInstance('CrossRegionXCGoal');      
        preGoalStartDate = goalDates.Current_Period_Start_Date__c;
        preGoalDueDate = goalDates.Current_Period_Due_Date__c;

        return Database.getQueryLocator(queryString);
    }
    global void execute(Database.BatchableContext BC, List<User> scopeList){
        
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        List <Goal> newGoalList= new List <Goal>(); 
        List<Id> createdGoalList = new List<Id>();
        Set<String> userIdSet =  new Set<String>();
        Set<String> userRegionSet = new Set<String>();
        regionDateMap = new Map<String,Decimal>();
        Date fiscalYearStartDate = goalDates.Current_Period_Start_Date__c;
        Date fiscalYearEndDate = goalDates.Current_Period_Due_Date__c.addMonths(11);
        Database.SaveResult[] insertGoals;            
        
        for(User user:scopeList){
                userRegionSet.add(user.Region__c); 
        }
        
        for(User user: [Select Id, Name From User where isActive = TRUE AND Profile.Name IN ('XC Account Executive','XC Manager') AND Region__c IN: userRegionSet AND UserPermissionsWorkDotComUserFeature = true AND Sales_Rep_Type__c NOT IN ('NAM','NED','Division')]){
            userIdSet.add(user.Id);
        }
            
        for(Goal goalList : [select Id,Assigned_To__c,DueDate,Name,StartDate,Status,Profile_Name__c,Region__c,Sales_Rep_Type__c,(Select Id,Name,TargetValue,Status,DueDate,Weight,LastComment from Metrics) from Goal where RecordtypeId =:PL_Constants.XFINITY_COMMUNITIES_RECORD_TYPE_ID AND Profile_Name__c IN ('XC Account Executive','XC Manager') AND StartDate >=:fiscalYearStartDate AND DueDate <=:fiscalYearEndDate AND OwnerId IN:userIdSet AND Sales_Rep_Type__c NOT IN('NAM','NED','Division','Region') LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {            
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
            for(Integer i=0;i<12;i++){
                String dateString = preGoalDueDate.month()+ PL_Constants.DATE_DELIMIT +preGoalDueDate.day() + PL_Constants.DATE_DELIMIT + preGoalDueDate.year();
                Goal Objgoal= new Goal ();               
                Objgoal.Name= 'Cross Regional Lead'+ '-XC-'+ Usr.Region__c+ '-' + dateString;
                Objgoal.Status = PL_Constants.GOAL_STATUS_PUBLISHED;
                Objgoal.ownerId= Usr.Id;
                Objgoal.Assigned_To__c = Usr.Id;
                Objgoal.Template_Type__c = PL_Constants.TEMPLATE_TYPE_COMMUNITIES;
                objgoal.RecordTypeId = PL_Constants.XFINITY_COMMUNITIES_RECORD_TYPE_ID ;
                objgoal.StartDate = preGoalStartDate;
                objGoal.DueDate = preGoalDueDate;
                objgoal.Region__c = Usr.Region__c;
                objGoal.Profile_Name__c = Usr.profile.name;
                newGoalList.add(Objgoal);
                
                preGoalStartDate = preGoalStartDate.addMonths(1);
                preGoalDueDate = preGoalDueDate.addMonths(1);
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
        newGoalList = [SELECT Id,OwnerId,DueDate,Region__c FROM Goal WHERE Id IN :createdGoalList];
        
        //Creat Metrics for Cross Regional Lead
        createMetrics(newGoalList,jobStatus);
    }
    
    global void finish(Database.BatchableContext BC){
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);      
        if(jobStatus!=null && !jobStatus.isEmpty()){ 
            jobStatus[0].Batch_End_Time__c = Datetime.now(); 
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? PL_Constants.BATCH_COMPLETE_WITH_SUCCESS : PL_Constants.BATCH_COMPLETE_WITH_FAIL ; 
            Database.update(jobStatus[0]); 
        }         
        //Update Custom Setting Date
        goalDates.Current_Period_Start_Date__c=goalDates.Current_Period_Start_Date__c.addMonths(12);
        goalDates.Current_Period_Due_Date__c=goalDates.Current_Period_Due_Date__c.addMonths(12);
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

            ObjMetric = New Metric();       
            ObjMetric.Name = System.Label.Metric_Name_Units;
            ObjMetric.OwnerId = goal.OwnerId;
            objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
            objMetric.DueDate= goal.DueDate;
            ObjMetric.TargetValue = regionDateMap.get(System.Label.Metric_Name_Units+regionDueDateString);  
            ObjMetric.GoalId= goal.id;
            objMetric.Sort_Order__c = 1;
            metricList.add(ObjMetric);                    

            ObjMetric = New Metric();       
            ObjMetric.Name = System.Label.Metric_Name_NewBusiness;
            ObjMetric.OwnerId = goal.OwnerId;
            objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
            objMetric.DueDate= goal.DueDate;
            ObjMetric.TargetValue = regionDateMap.get(System.Label.Metric_Name_NewBusiness+regionDueDateString); 
            ObjMetric.GoalId= goal.id;
            objMetric.Sort_Order__c = 2;
            metricList.add(ObjMetric);

        }
        
        Database.SaveResult[] insertMetrics = Database.insert(metricList,false); 
        executeJob(insertMetrics, jobStatus);
    }
    
}