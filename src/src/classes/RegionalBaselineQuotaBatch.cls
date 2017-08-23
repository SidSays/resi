/**************************************************************************************************
Name : RegionalBaselineQuotaBatch
Description : This batch class is created to create Goals and Metric value data on Yearly basis for AE and AE managers 
with Sales Rep Type as Region.
User Story : US680915
Date : 9th May 2016
Author : Sucheta Verma
Last updated By : Amit Kumar Pradhan(Commenting the Xoc and Units Contractors metrics for Regional Lead)
Date : 14th Dec 2016
***************************************************************************************************/
global class RegionalBaselineQuotaBatch implements Database.Batchable<sObject>, Database.Stateful{  
    
    private final Static String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'RegionalBaselineQuotaBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string RECORD_TYPE_SEPERATION = ';';
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private static final String GOAL_STATUS_PUBLISHED = 'Published';
    private Id jobStatusId = null;
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    private date todaysDate = null;
    private datetime preGoalStartDateTime = null;
    private datetime preGoalDueDateTime = null;    
    private date fiscalYearStartDate = null;
    private date fiscalYearEndDate = null;    
    private static final string PROFILE_ID_SEPERATION = ';';  
    private static final string SALES_REP_TYPE = ';';
    private static final Set<string> profileNameSet  = new Set<string>();  
    private static final Set<string> salesRepTypeNameSet  = new Set<string>();  
    private GoalTemplateDates__c goalDates = null;
    private String sRTString = 'Region';
    private static final String GoalRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Xfinity Communities').getRecordTypeId();
    private String query= null;
    
    //Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name, ProfileId,Region__c,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND  Sales_Rep_Type__c =:sRTString  and UserPermissionsWorkDotComUserFeature = true';
    global RegionalBaselineQuotaBatch(String query)
    {
        this.query=query;
    }
    
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
        goalDates = GoalTemplateDates__c.getInstance('Regional_Baseline_Quota');
        preGoalStartDate = goalDates.Current_Period_Start_Date__c;
        preGoalDueDate =  goalDates.Current_Period_Due_Date__c;
        preGoalStartDateTime = goalDates.Current_Period_Start_Date__c;
        preGoalDueDateTime = goalDates.Current_Period_Due_Date__c;
        String salesRepType = system.Label.Sales_Rep_Type;
        if(!string.IsBlank(salesRepType)){
            for(String SRTId : salesRepType.split(SALES_REP_TYPE)){
                salesRepTypeNameSet.add(SRTId.trim());
            }          
        }        
        return Database.getQueryLocator(query);  
    }
    
    global void execute(Database.BatchableContext BC, List<User> scopeList){  
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
         
        try{              
            String userProfileName;
            String userRegion;
            Metric ObjMetric;
            Set<String> userRegionSet =  new Set<String>();
            Set<String> userIdSet =  new Set<String>();                
            Map<Id,Goal> goalMap = new Map<Id,Goal>();
            List<Goal> newGoalList = new List<Goal>();
            List<Metric> metricList = new List<Metric> ();
            Map<Id,Metric> metricTargetmap = new Map<Id,Metric>();
            Map<String,Map<Id,List<Goal>>> RegionAEGoalMap = new Map<String,Map<Id,List<Goal>>>();
            Map<Id,List<Goal>> tempAEGoalMap = new Map<Id,List<Goal>>();
            List<Goal> AEGoalList = new List<Goal>();
            List<Metric> metricTargetList = new List<Metric>();
            Map<String,Goal> goalSettingMap = new Map<String,Goal>();
            Map<String,List<Metric>> UserIDMetricListMap = new  Map<String,List<Metric>>();
            Map<String,Decimal> RegionDateMap = new Map<String,Decimal>();
            Map<String,Decimal> RegionDateManagerMap = new Map<String,Decimal>();
            List<GoalShare> goalShares = new List<GoalShare>();
            //Get Fisical Year Start Date And end date      
            fiscalYearStartDate = goalDates.Current_Period_Start_Date__c;
            fiscalYearEndDate = goalDates.Current_Period_Due_Date__c.addMonths(11);         
            Group groupTemp = [SELECT Id,Name,RelatedId,Type FROM Group WHERE Type = 'Regular' and Name = 'Super User Group'];
            Database.SaveResult[] insertGoals;
            Database.SaveResult[] insertMetrics;
            //Code for find out XC Manager List and XC AE List
            for(User user:scopeList){
                userRegionSet.add(user.Region__c); 
            }
             
            if(!userRegionSet.isEmpty()){
                for(User userObj : [Select Id, Name From User where isActive = TRUE AND Profile.Name IN('XC Manager','XC Account Executive') AND region__c IN:userRegionSet AND     Sales_Rep_Type__c NOT IN('NAM','NED','Division')]){
                    userIdSet.add(userObj.Id);
                }
            }

            
            for(Goal goalList : [select Id,Assigned_To__c,DueDate,Name,StartDate,Status,Profile_Name__c,Region__c,Sales_Rep_Type__c,(Select Id,Name,TargetValue,Status,DueDate,Weight,LastComment from Metrics)  from Goal where RecordtypeId =: GoalRecordTypeId and Sales_Rep_Type__c NOT IN('NAM','NED','Division','Region') AND Profile_Name__c In('XC Manager','XC Account Executive') AND StartDate >=:fiscalYearStartDate AND DueDate <=:fiscalYearEndDate AND OwnerId IN:userIdSet LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {            
                for(Metric metricObj : goalList.Metrics){
                    if(goalList.Region__c != '' && goalList.DueDate != Null && metricObj.Name !=Null){
                        if(RegionDateMap.containsKey(metricObj.Name+goalList.Region__c + goalList.DueDate))
                        {
                            RegionDateMap.put((metricObj.Name + goalList.Region__c + goalList.DueDate), RegionDateMap.get(metricObj.Name + goalList.Region__c + goalList.DueDate)+metricObj.TargetValue);                         
                        } else{
                            RegionDateMap.put((metricObj.Name + goalList.Region__c + goalList.DueDate) , metricObj.TargetValue);                             
                        }
                        
                    }
                }  

                      
                /*else if(goalList.Profile_Name__c == 'XC Manager'){
                for(Metric metricObj : goalList.Metrics){
                    
                   //goalSettingMap.put((goalList.Profile_Name__c + goalList.Region__c).trim() , goalList); 
                    
                    if(RegionDateManagerMap.containsKey(goalList.Region__c + goalList.DueDate))
                    {
                       RegionDateManagerMap.put((goalList.Region__c + goalList.DueDate), RegionDateManagerMap.get(goalList.Region__c + goalList.DueDate)+metricObj.TargetValue);
                      
                    } else{
                      RegionDateManagerMap.put((goalList.Region__c + goalList.DueDate) , metricObj.TargetValue); 
                    }
                }   
                }*/
            }
               
            //creating 12 months goal for Regional Lead
            for(User Usr:scopeList){  
                userProfileName=Usr.Profile.name;             
                userRegion=Usr.Region__c;                           
                for(integer i=0;i<12;i++){  
                    String UserIDGoalDueDate=String.valueOf(user.Id) + preGoalDueDate;              
                    Goal Objgoal= new Goal ();               
                    Objgoal.Name= 'Regional Quota_'+ Usr.Region__c+'_'+preGoalDueDateTime.formatGMT('MMMM yyyy');
                    Objgoal.Status = GOAL_STATUS_PUBLISHED;
                    Objgoal.ownerId= Usr.Id;
                    Objgoal.Assigned_To__c = Usr.Id;
                    Objgoal.Template_Type__c = 'Communities';
                    objgoal.RecordTypeId=GoalRecordTypeId;
                    objgoal.StartDate=preGoalStartDate;
                    objGoal.DueDate=preGoalDueDate;
                    objgoal.Region__c = userRegion;
                    objgoal.Sales_Rep_Type__c = 'Region';
                    objGoal.Profile_Name__c=usr.profile.name;
                    newGoalList.add(Objgoal);
                    
                    preGoalStartDate =preGoalStartDate.addMonths(1);
                    preGoalDueDate = preGoalDueDate.addMonths(1);
                    preGoalStartDateTime=preGoalStartDateTime.addMonths(1);
                    preGoalDueDateTime=preGoalDueDateTime.addMonths(1);
                }
                preGoalStartDate= goalDates.Current_Period_Start_Date__c;
                preGoalDueDate=goalDates.Current_Period_Due_Date__c; 
                preGoalStartDateTime=goalDates.Current_Period_Start_Date__c;  
                preGoalDueDateTime=goalDates.Current_Period_Due_Date__c;                                  
            }
            
            //Inserting new Goals records
            if(!newGoalList.isEmpty()){
                insertGoals = Database.Insert(newGoalList,false);
            }
            //Creating metrics for each Goal and sharing the Goal with super user group
            for(Goal goal : newGoalList){
                String regionDueDateString = goal.Region__c+ goal.DueDate;

                ObjMetric = New Metric();       
                ObjMetric.Name = 'Total Units';
                ObjMetric.OwnerId = goal.OwnerId;
                objMetric.Status = 'NotStarted';
                objMetric.DueDate= goal.DueDate;
                ObjMetric.TargetValue = RegionDateMap.get('Units'+regionDueDateString);  
                ObjMetric.GoalId= goal.id;
                metricList.add(ObjMetric);                    

                ObjMetric = New Metric();       
                ObjMetric.Name = 'New Business';
                ObjMetric.OwnerId = goal.OwnerId;
                objMetric.Status = 'NotStarted';
                objMetric.DueDate= goal.DueDate;  //preGoalDueDate;
                ObjMetric.TargetValue = RegionDateMap.get('New Business'+regionDueDateString); 
                ObjMetric.GoalId= goal.id;
                metricList.add(ObjMetric);
                
                /*
                ObjMetric = New Metric();       
                ObjMetric.Name = 'XoC';
                ObjMetric.OwnerId = goal.OwnerId;
                objMetric.Status = 'NotStarted';
                objMetric.DueDate= goal.DueDate; //preGoalDueDate;
                ObjMetric.TargetValue = Decimal.valueOf(System.Label.XoC_Value);
                ObjMetric.GoalId= goal.id;
                metricList.add(ObjMetric);      
                            
                ObjMetric = New Metric();       
                ObjMetric.Name = 'Units_Contractors';
                ObjMetric.OwnerId = goal.OwnerId;
                objMetric.Status = 'NotStarted';
                objMetric.DueDate= goal.DueDate; //preGoalDueDate;
                ObjMetric.TargetValue = Decimal.valueOf(System.Label.Units_Contractors);
                ObjMetric.GoalId= goal.id;
                metricList.add(ObjMetric);           
                */  
                GoalShare goalRecord = new GoalShare();
                goalRecord.ParentId = goal.Id;
                goalRecord.userorgroupId = groupTemp.Id;
                goalRecord.AccessLevel = 'Read';
                goalRecord.rowCause = Schema.GoalShare.rowCause.Manual;
                goalShares.add(goalRecord);
            }
            
            //Inserting metrics records
            if(!metricList.isEmpty()){
                insertMetrics = Database.insert(metricList,false); 
            }
            
            //Inserting Goal share records
            if(!goalShares.isEmpty()){
                Database.SaveResult[] GoalShareInsertResult = Database.insert(goalShares,false);                
            }
                
                
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
               Batch_Start_Time__c, Batch_End_Time__c  
               FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId]);
    } 
}