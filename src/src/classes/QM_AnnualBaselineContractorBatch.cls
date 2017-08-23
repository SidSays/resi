/**************************************************************************************************
Name : QM_AnnualBaselineContractorBatch
Description : This batch class is created to create Goals and Metric value data on Yearly basis for AE Contractors based on records
              in Contractor Region Mapping Object.
User Story : US776812
Date : 05 Oct 2016
Author : Animesh Datta
Last Modified By : 
***************************************************************************************************/
global class QM_AnnualBaselineContractorBatch implements Database.Batchable<sObject>, Database.Stateful{

     /*
    * Data Member 
    */  
    
    private final Static String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'QM_AnnualBaselineContractorBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string RECORD_TYPE_SEPERATION = ';';
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private static final String GOAL_STATUS_PUBLISHED = 'Published';
    private static final String EMPTY_STRING = '';
    private static final String HYPHEN_STRING = '-';
    private static final String MONTH_YEAR_FORMAT = 'MMMM yyyy';
    private static final String METRIC_STATUS = 'NotStarted';
    
    private Id jobStatusId = null;    
    private GoalTemplateDates__c goalDates = null;
    //private static final string PROFILE_ID_SEPERATION = ';';    
    //private static final Set<string> profileNameSet  = new Set<string>();   
    Public String query=EMPTY_STRING;
    //public String query='SELECT Id, Name, AE_Contractor__c, AE_Contractor__r.UserPermissionsWorkDotComUserFeature,AE_Contractor__r.Profile.Name, AE_Contractor__r.Name, Reporting_Manager__c, Region__c, Region_Mapping_Key__c, Region_Formula__c FROM Contractor_Region_Mapping__c WHERE AE_Contractor__r.Profile.name = \'XC AE Contractors\' AND AE_Contractor__r.UserPermissionsWorkDotComUserFeature = true AND AE_Contractor__r.isActive = true';
    //public String query='Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND Profile.Name IN: profileNameSet and UserPermissionsWorkDotComUserFeature = true';
    
    /* Constructor for batch class QM_AnnualBaselineContractorBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-  'Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND Profile.Name IN: profileNameSet and UserPermissionsWorkDotComUserFeature = true' 
     */
    global QM_AnnualBaselineContractorBatch(String query)
    {
        this.query=query;
        System.debug('query+++++++' +query);
    }
    /*
    *Query execution to fetch all Contractor Region Mapping Data based on profile - XC AE Contractor 
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Create Job Status Object
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME + JOB_NAME_SPACE  + Datetime.now();
        jobStatus.Status__c = JOB_STATUS;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = JOB_COMMENT;
        jobStatus.Number_Of_Fallouts__c = 0;
        Database.insert(jobStatus);  
        jobStatusId = jobStatus.Id;
        goalDates = GoalTemplateDates__c.getInstance(System.Label.QM_AnnualBaselineBatchContractorCusSetData);
        //String profileNames = System.Label.Communities_ProfileId;  
       /* if(!string.IsBlank(profileNames)){
            for(String profId : profileNames.split(PROFILE_ID_SEPERATION)){
                profileNameSet.add(profId);
                System.debug('profileNameSet++++++' + profileNameSet);
            }    
        } */
        
        return Database.getQueryLocator(query);  
    }
    
    
    /*
    * Execute business logic to insert new Goals,Metrics Data for AE Contractors
    */
    
    global void execute(Database.BatchableContext BC, List<Contractor_Region_Mapping__c> scopeList){ 
    System.debug('scopeList+++++++' + scopeList)   ;
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        try{
            String userProfileName;  
            String userRegion;
            String goalId;
            //String userRepType;
            List<Goal> goalList=new List<Goal>();        
            Map<String , Goal> goalSettingMap = new Map<String , Goal>();
            Map<String, Goal> goalMap = new Map<String, Goal>();
            Map<String,List<Metric>> userIDMetricListMap = new Map<String,List<Metric>>();
            //Map<String,GoalShare> userIDGoalShareMap = new Map<String,GoalShare>();
            
            Set<String> goalIds = new Set<String>();
            //set<Id> userIdSet = new set<Id>();
            
            //Get the Fiscal Year Date period goal start/due dates                       
            Date preGoalStartDate = goalDates.Current_Period_Start_Date__c; // 22/12/2014
            Date preGoalDueDate =  goalDates.Current_Period_Due_Date__c; //21/01/2015
            DateTime preGoalStartDateTime = goalDates.Current_Period_Start_Date__c;  
            DateTime preGoalDueDateTime = goalDates.Current_Period_Due_Date__c;         
            String Goal_Template_RecordtypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.Goal_Goal_Template_Recordtype).getRecordTypeId();
            for(Goal gol : [select Id,Assigned_To__c,Template_Type__c,DueDate,Name,StartDate,Status,Profile_Name__c,Region__c,Sales_Rep_Type__c,(Select Id,Name,TargetValue,Status,DueDate,Weight,LastComment from Metrics)  from Goal where Template_Type__c =: system.label.Goal_Template_Type_Communities and RecordtypeId =: Goal_Template_RecordtypeId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) { 
                goalSettingMap.put((gol.Profile_Name__c + gol.Region__c).trim() , gol);           
                goalMap.put(gol.Id , gol);
            }
            String XfinityCommunitiesRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(system.label.Goal_Xfinity_Communities_Recordtype).getRecordTypeId(); 
            //Goal records shared to Manager's.
            //List<GoalShare> WGShares = new List<GoalShare>();
           
           /* for(User user:scopeList){
                userIdSet.add(user.id);  
            }*/
                                    
            for(Contractor_Region_Mapping__c contRegionMapObj:scopeList){                     
                    userProfileName=contRegionMapObj.AE_Contractor__r.Profile.name;             
                    userRegion=contRegionMapObj.Region__c;                                       
                    Goal goalInst = goalSettingMap.get((userProfileName+userRegion).trim());
                    if(goalInst != null){
                       //Logic to create 12 months goal
                        for(integer i=0;i<12;i++){
                            String UserIDGoalDueDate=String.valueOf(contRegionMapObj.AE_Contractor__r.Id) + preGoalDueDate;
                            Goal getGoal= goalMap.get(goalInst.id);                         
                            Goal cloneGoal = new Goal();
                            List<Metric> metricList=new List<Metric>();                         
                            cloneGoal=getGoal.Clone(false,true,true,false);                                                                                         
                            cloneGoal.OwnerId=contRegionMapObj.AE_Contractor__r.Id;
                            cloneGoal.Assigned_To__c = contRegionMapObj.AE_Contractor__r.Id;
                            cloneGoal.Reporting_Manager__c = contRegionMapObj.Reporting_Manager__c;
                            cloneGoal.Status = GOAL_STATUS_PUBLISHED;
                            Date d = preGoalStartDate;
                            //String dateString = d.month()+EMPTY_STRING+d.day()+EMPTY_STRING+d.year();                         
                            cloneGoal.Name=contRegionMapObj.AE_Contractor__r.Name+JOB_NAME_SPACE+contRegionMapObj.Region__c+JOB_NAME_SPACE+preGoalDueDateTime.formatGMT(MONTH_YEAR_FORMAT);
                            //Put start and due date in the goal to be create                                           
                            cloneGoal.StartDate = preGoalStartDate;    
                            cloneGoal.DueDate = preGoalDueDate;                         
                            cloneGoal.RecordTypeId=XfinityCommunitiesRecordTypeId ; 
                            goalList.add(cloneGoal);
                                for(Metric metr: cloneGoal.Metrics){
                                    Metric mt = new Metric();
                                    mt=metr.Clone(false,true,true,false);                                                                  
                                    mt.OwnerId=contRegionMapObj.AE_Contractor__r.Id;
                                    //mt.ownerId=user.Id;
                                    mt.Status=METRIC_STATUS;
                                    mt.DueDate = preGoalDueDate;
                                    metricList.add(mt);
                                }    
                            
                            userIDMetricListMap.put(UserIDGoalDueDate.trim() , metricList);                       
                            preGoalStartDate =preGoalStartDate.addMonths(1);
                            preGoalDueDate = preGoalDueDate.addMonths(1);
                            preGoalStartDateTime=preGoalStartDateTime.addMonths(1);
                            preGoalDueDateTime = preGoalDueDateTime.addMonths(1);
                        }
                        preGoalStartDate= goalDates.Current_Period_Start_Date__c;
                        preGoalDueDate=goalDates.Current_Period_Due_Date__c; 
                        preGoalStartDateTime=goalDates.Current_Period_Start_Date__c;  
                        preGoalDueDateTime=goalDates.Current_Period_Due_Date__c;                    
                    }                       
            }
             system.debug('goalList'+goalList);     
            //Inserting new Goals records 
            Database.SaveResult[] insertGoals = Database.Insert(goalList,false);
            
            

            if(!jobStatus.isEmpty()){
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
            
            List<Metric> metricInsertList = new List<Metric>();
            List<GoalShare> goalshareList = new List<GoalShare>();
            // Assigning metric to goal
            for(Goal goalObj : [select id, OwnerId ,Assigned_To__c, DueDate , Name FROM Goal WHERE Id In : goalList]){
                if(userIDMetricListMap.get((String.valueOf(goalObj.Assigned_To__c) + goalObj.DueDate).trim()) != null){
                   List<Metric> metricInsertList1 = new List<Metric>();
                   String UserIDGoalDueDate=String.valueOf(goalObj.Assigned_To__c) + goalObj.DueDate; 
                   for(Metric metricObj : (List<Metric>) userIDMetricListMap.get(UserIDGoalDueDate.trim())){
                        metricObj.GoalId = goalObj.Id;
                        metricInsertList1.add(metricObj);                     
                   }
                   metricInsertList.addAll(metricInsertList1);       
                }                              
            }
            system.debug('metricInsertList'+metricInsertList);
            //Inserting new Metrics
             Database.SaveResult[] insertMetrics = Database.Insert(metricInsertList,false);
            
            //Inserting new Goals records and shared to Manager.
            /*if(!goalshareList.isEmpty()){
                Database.SaveResult[] GoalShareInsertResult = Database.insert(goalshareList ,false);
            }*/
             if(!jobStatus.isEmpty()){
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
        }
        catch(Exception e) {
             if(!jobStatus.isEmpty()){
                    Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                    String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                    
                    jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0]);   
             }           
        }   
              
    }   

    //Execute Finish logic after execution of batch records completed
    
    global void finish(Database.BatchableContext BC){      
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
        if(!jobStatus.isEmpty()){ 
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
                   Batch_Start_Time__c, Batch_End_Time__c 
                   FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId]);
    }
}