/**************************************************************************************************
Name : QM_QuotaAnnualBaselineBatch
Description : This batch class is created to create Goals and Metric value data on Yearly basis for AE and AE managers.
User Story : US481446
Date : 10 Aug 2015
Author : Suchita Sharma
Last Modified By : Suchita Sharma(Constructor defined for batch which should take query string as parameter for execution.) 
***************************************************************************************************/
global class QM_QuotaAnnualBaselineBatch implements Database.Batchable<sObject>, Database.Stateful{

     /*
    * Data Member 
    */  
    
    private final Static String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'QM_QuotaAnnualBaselineBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string RECORD_TYPE_SEPERATION = ';';
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
     private static final String GOAL_STATUS_PUBLISHED = 'Published';
    private Id jobStatusId = null;    
    private GoalTemplateDates__c goalDates = null;
    private static final string PROFILE_ID_SEPERATION = ';';    
    private static final Set<string> profileNameSet  = new Set<string>();   
    Public String query='';
    //public String query='Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND Profile.Name IN: profileNameSet and UserPermissionsWorkDotComUserFeature = true';
    
    /* Constructor for batch class QM_QuotaAnnualBaselineBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-  'Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND Profile.Name IN: profileNameSet and UserPermissionsWorkDotComUserFeature = true' 
     */
    global QM_QuotaAnnualBaselineBatch(String query)
    {
        this.query=query;
        System.debug('query+++++++' +query);
    }
    /*
    *Query execution to fetch all users based on profiles - XC Account Executive and XC Manager
    */
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
        goalDates = GoalTemplateDates__c.getInstance('Default_Communities');
        String profileNames = System.Label.Communities_ProfileId;  
        if(!string.IsBlank(profileNames)){
            for(String profId : profileNames.split(PROFILE_ID_SEPERATION)){
                profileNameSet.add(profId);
                System.debug('profileNameSet++++++' + profileNameSet);
            }    
        } 
        
        return Database.getQueryLocator(query);  
    }
    
    
    /*
    * Execute business logic to insert new Goals,Metrics Data for AE and AE managers
    */
    global void execute(Database.BatchableContext BC, List<User> scopeList){ 
    System.debug('scopeList+++++++' + scopeList)   ;
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        try{
            String userProfileName;  
            String userRegion;
            String goalId;
            String userRepType;
            List<Goal> goalList=new List<Goal>();        
            Map<String , Goal> goalSettingMap = new Map<String , Goal>();
            Map<String, Goal> goalMap = new Map<String, Goal>();
            Map<String,List<Metric>> UserIDMetricListMap = new Map<String,List<Metric>>();
            Map<String,GoalShare> userIDGoalShareMap = new Map<String,GoalShare>();
            
            set<String> goalIds = new set<String>();
            set<Id> userIdSet = new set<Id>();
            
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
            List<GoalShare> WGShares = new List<GoalShare>();
           
            for(User user:scopeList){
                userIdSet.add(user.id);  
            }
                                    
            for(User user:scopeList){                     
                    userProfileName=user.Profile.name;             
                    userRegion=user.Region__c;                                       
                    Goal goalInst = goalSettingMap.get((userProfileName+userRegion).trim());
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
                            cloneGoal.Reporting_Manager__c=user.ManagerId;} // added for US814543
                            cloneGoal.Assigned_To__c = user.Id;                     
                            cloneGoal.Status = GOAL_STATUS_PUBLISHED;
                            Date d = preGoalStartDate; // 22/12/2014
                            String dateString = d.month()+'-'+d.day()+'-'+d.year();                         
                            cloneGoal.Name=user.Name+' - '+user.Region__c+' - '+preGoalDueDateTime.formatGMT('MMMM yyyy');                         
                            //Put start and due date in the goal to be create                                           
                            cloneGoal.StartDate = preGoalStartDate; //22/12/2014    
                            cloneGoal.DueDate = preGoalDueDate;                         
                            cloneGoal.RecordTypeId=XfinityCommunitiesRecordTypeId ; 
                            goalList.add(cloneGoal);
                                for(Metric metr: cloneGoal.Metrics){
                                    Metric mt = new Metric();
                                    mt=metr.Clone(false,true,true,false);                                                                  
                                    mt.OwnerId=user.Id;                                                                                                                                              
                                    //mt.ownerId=user.Id;
                                    mt.Status='NotStarted';
                                    mt.DueDate = preGoalDueDate;
                                    metricList.add(mt);
                                }    
                            
                            UserIDMetricListMap.put(UserIDGoalDueDate.trim() , metricList);                       
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
            
            List<Metric> metricInsertList = new List<Metric>();
            List<GoalShare> goalshareList = new List<GoalShare>();
            // Assigning metric to goal
            for(Goal goalObj : [select id, OwnerId ,Assigned_To__c, DueDate , Name FROM Goal WHERE Id In : goalList]){
                if(UserIDMetricListMap.get((String.valueOf(goalObj.Assigned_To__c) + goalObj.DueDate).trim()) != null){
                   List<Metric> metricInsertList1 = new List<Metric>();
                   String UserIDGoalDueDate=String.valueOf(goalObj.Assigned_To__c) + goalObj.DueDate; 
                   for(Metric metricObj : (List<Metric>) UserIDMetricListMap.get(UserIDGoalDueDate.trim())){
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
            if(!goalshareList.isEmpty()){
                Database.SaveResult[] GoalShareInsertResult = Database.insert(goalshareList ,false);
            }
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