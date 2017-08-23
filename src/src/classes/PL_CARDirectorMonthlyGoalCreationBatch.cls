/**************************************************************************************************
Name : PL_CARDirectorMonthlyGoalCreationBatch
Description : This batch class creates goals and metrics of CAR Director/ Sr Manager on monthly basis. 
User Story : US932258
Date : 09 Feb 2017
Author : Malay Desai
Last Modified By/Date/Description : Animesh Datta/15-May-2017 - SP54 - US1087049 - Adding +2 months with 
                                    pregoalDuedate in Quarterly Metric(Field Observation)
Last Modified By : Amit Kumar Pradhan 10-July-2017
User Story : US1108731(Coach for CAR Leaders: Populate Goal field 'Region')
***************************************************************************************************/
global class PL_CARDirectorMonthlyGoalCreationBatch implements Database.Batchable<sObject>, Database.Stateful{
    private Id jobStatusId = null;   
    private GoalTemplateDates__c goalDates = null;  
    private String queryString = '';
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    private static final String STRING_COUNT = 'CNT';
    private static final String STRING_MGR = 'MGR';
    private static final String STRING_PNAME = 'PNAME';
    private static Set<Id> CARDirectorOrSrManagersIds = new Set<Id>(); // Contains CAR Director/Sr Manager
    
   
    /* Constructor for batch class PL_CARDirectorMonthlyGoalCreationBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-  'SELECT Id, Name, Profile.Name FROM User WHERE Id IN :CARDirectorOrSrManagersIds 
     * AND UserPermissionsWorkDotComUserFeature = true' 
     */
    global PL_CARDirectorMonthlyGoalCreationBatch(String query){ 
        this.queryString=query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) { 
        Job_Status__c job = new Job_Status__c();
        job.Name = PL_Constants.BATCH_JOB_NAME_FOR_CARDIR + PL_Constants.JOB_NAME_SPACE  + Datetime.now();
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
        goalDates = GoalTemplateDates__c.getInstance(Label.PL_MonthlyGoalCreationBatchCusSetData); //Label value = Property Lab CAR       
        preGoalStartDate = goalDates.Current_Period_Start_Date__c.addMonths(1);
        preGoalDueDate = goalDates.Current_Period_Due_Date__c.addMonths(1);
        
        for(PermissionSetAssignment psa :  [SELECT AssigneeId FROM PermissionSetAssignment 
                                            WHERE PermissionSet.Name = :PL_Constants.PERM_SET_FOR_CAR_DIR_SR_MGR 
                                            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
              // CAR Director/Sr Manager (Do not necessarily have "Xfinity CAR Manager" profile)
              CARDirectorOrSrManagersIds.add(psa.AssigneeId); 
        }
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<User> userList){ 
        
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        List <Goal> newGoalList = new List <Goal>(); 
        List<Id> createdGoalList = new List<Id>();
        Set<Id> CARManagerIds = new Set<Id>(); //Contains CAR Managers Ids
        Map<Id,Integer> MgrVsCARCount = new Map<Id,Integer>(); //Contains Id of CAR Director/Sr Manager and number of CARs under them
        Map<Id,Integer> MgrVsTotalCount = new Map<Id,Integer>();
        Map<Id,Integer> MgrVsCARMgrCount = new Map<Id,Integer>();
        Map<Id,AggregateResult> carCountMap;
        List<Goal> goalStatusUpdateList = new List<Goal>();
        List<Metric> metricUpdateList = new List<Metric>();
        set<Id> userIdSet = new set<Id>();
        
        String monthlyDateString = preGoalDueDate.month()+ PL_Constants.DATE_DELIMIT +preGoalDueDate.day() + 
                    PL_Constants.DATE_DELIMIT + preGoalDueDate.year();
        String quaterlyDateString = preGoalDueDate.addMonths(2).month() + PL_Constants.DATE_DELIMIT +preGoalDueDate.day() + 
                    PL_Constants.DATE_DELIMIT + preGoalDueDate.year();
        Integer carCount;
        Goal goalInst;
        Database.SaveResult[] insertGoals;
        
        try{
            
            for(User user:userList){
                userIdSet.add(user.id);  
            }
            
            /* Mark Previous Goal and Metric as completed */
            Map<ID,Goal> goalsIdObjectMap = new Map<ID,Goal>([SELECT Id,Name,DueDate,Status FROM Goal 
                                                    WHERE OwnerID IN : userIdSet AND Status !=: PL_Constants.GOAL_STATUS_COMPLETE 
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
            //Create Goals for CAR Director/Sr Manager i.e.  
            if(userList != null && !userList.isEmpty()){
                
                //Following query will only give "Count of CARs" for whom CAR Director/Sr Manager is their Manager of Manager.
                carCountMap = new Map<Id,AggregateResult> ([SELECT Manager.ManagerId Id,Count(Id) CNT FROM User 
                                                            WHERE isActive=TRUE AND Profile.Name =: Label.Xfinity_CAR_ProfileName 
                                                            AND Manager.ManagerId IN :userList 
                                                            AND UserPermissionsWorkDotComUserFeature = true
                                                            GROUP BY Manager.ManagerId 
                                                            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
                
                 // Build a Map of CAR Director/Sr Managers ID vs initial "Count of CAR" 
                for(Id dirId : carCountMap.keySet()){
                    carCount = Integer.valueOf(carCountMap.get(dirId).get(STRING_COUNT));
                    MgrVsCARCount.put(dirId,carCount);
                }
                system.debug('carCountMap1>>>'+carCountMap);
                
               // Following query will give "Count of CARs"  for whom CAR Director/Sr Manager is their Direct Manager.
               
               carCountMap = 
                    new Map<Id,AggregateResult>([SELECT ManagerId Id,Count(Id) CNT FROM User WHERE isActive=TRUE 
                                                     AND Profile.Name =: Label.Xfinity_CAR_ProfileName 
                                                     AND ManagerId IN :userList 
                                                     AND UserPermissionsWorkDotComUserFeature = true
                                                     GROUP BY ManagerId 
                                                     LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
                // Build a Map of CAR Director/Sr Managers ID vs their total "Count of CAR"    
                system.debug('carCountMap2>>>'+carCountMap);
                Integer existingCount;                                     
                for(Id dirId : carCountMap.keySet()){
                    carCount = Integer.valueOf(carCountMap.get(dirId).get(STRING_COUNT));
                    existingCount = MgrVsCARCount.get(dirId);
                    if(existingCount != null){
                        MgrVsCARCount.put(dirId,existingCount + carCount);
                    } else{
                        MgrVsCARCount.put(dirId,carCount);
                    }
                }
               
                List<AggregateResult> carCountList = 
                    new List<AggregateResult>([SELECT ManagerId MGR, Profile.Name PNAME,  Count(Id) CNT FROM User WHERE isActive=TRUE
                                                AND Profile.Name IN (:Label.Xfinity_CAR_ProfileName, :Label.Xfinity_CARmanager_ProfileName)
                                                AND ManagerId IN : userList AND UserPermissionsWorkDotComUserFeature = true
                                                GROUP BY ManagerId, Profile.Name LIMIT :(Limits.getLimitQueryRows()-Limits.getQueryRows())]);
                Integer subCount=0; existingCount=0;                    
                for(AggregateResult ar : carCountList){
                    String dirId = (String) ar.get(STRING_MGR);
                    existingCount = MgrVsTotalCount.get(dirId);
                    subCount = Integer.valueOf(ar.get(STRING_COUNT));
                    if(existingCount != null){
                        MgrVsTotalCount.put(dirId, existingCount + subCount);
                    } else{
                        MgrVsTotalCount.put(dirId, subCount);       
                    }
                    
                    if(ar.get(STRING_PNAME) == Label.Xfinity_CARmanager_ProfileName){
                        MgrVsCARMgrCount.put(dirId, subCount );
                    }
                }   
                                                
                for(User carDirector : userList){
                    goalInst = new Goal();               
                    goalInst.Name = carDirector.Name + PL_Constants.PROPERTY_LAB + PL_Constants.MONTHLY_GOAL + monthlyDateString;
                    goalInst.Status = PL_Constants.GOAL_STATUS_PUBLISHED;
                    goalInst.ownerId = carDirector.Id;
                    goalInst.RecordTypeId = PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID;
                    goalInst.StartDate = preGoalStartDate;
                    goalInst.DueDate = preGoalDueDate;
                    goalInst.Profile_Name__c = carDirector.Profile.Name;
                    goalInst.Region__c = carDirector.Region__c;//Added by Amit Kumar Pradhan(US1108731:Populate Goal field 'Region')
                    goalInst.Template_Type__c = PL_Constants.TEMPLATE_TYPE_PROPERTYLAB;
                    newGoalList.add(goalInst);
                    system.debug('newGoalList>>>'+newGoalList);
                    if(Math.mod(Integer.valueOf(preGoalStartDate.month()),3) == 0){
                        goalInst = new Goal();               
                        goalInst.Name = carDirector.Name + PL_Constants.PROPERTY_LAB + PL_Constants.QUATERLY_GOAL + quaterlyDateString;
                        goalInst.Status = PL_Constants.GOAL_STATUS_PUBLISHED;
                        goalInst.ownerId = carDirector.Id;
                        goalInst.RecordTypeId = PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID;
                        goalInst.StartDate = preGoalStartDate;
                        goalInst.DueDate = preGoalDueDate.addMonths(2);
                        goalInst.Profile_Name__c = carDirector.Profile.Name;
                        goalInst.Region__c = carDirector.Region__c;//Added by Amit Kumar Pradhan(US1108731:Populate Goal field 'Region')
                        goalInst.Template_Type__c = PL_Constants.TEMPLATE_TYPE_PROPERTYLAB;
                        newGoalList.add(goalInst);
                    }
                }
                
                insertGoals = Database.insert(newGoalList,true); 
                            
                executeJob(insertGoals,jobStatus);
                
                for(Database.SaveResult sr : insertGoals){
                    if(sr.isSuccess()){
                        createdGoalList.add(sr.getId());
                    }
                }
                system.debug('createdGoalList>>>'+createdGoalList);
                newGoalList = [SELECT Id, Name, OwnerId FROM Goal WHERE Id IN :createdGoalList];
                //Creat Metrics for CAR Managers who are not CAR Director/Sr Manager
                createMetrics(newGoalList,MgrVsCARCount, MgrVsTotalCount, MgrVsCARMgrCount, jobStatus);
            } 
               
        }catch(Exception e){
             if(jobStatus!=null && !jobStatus.isEmpty()){
                    Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                    String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ?  
                                     PL_Constants.SYSTEM_EXCEPTION + e.getMessage() + PL_Constants.NEW_LINE :jobStatus[0].Comments__c + PL_Constants.SYSTEM_EXCEPTION + e.getMessage() +PL_Constants.NEW_LINE;                                    
                    jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; 
                    Database.update(jobStatus[0]);   
             } 
        }   
    }
     
    //Execute Finish logic after execution of batch records completed
    global void finish(Database.BatchableContext BC){ //
        try{
            goalDates.Current_Period_Start_Date__c = goalDates.Current_Period_Start_Date__c.addMonths(1);        
            goalDates.Current_Period_Due_Date__c = goalDates.Current_Period_Due_Date__c.addMonths(1);        
            Database.update(goalDates, false);
            List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
            if(jobStatus!=null && !jobStatus.isEmpty()){ 
                jobStatus[0].Batch_End_Time__c = Datetime.now(); 
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? PL_Constants.BATCH_COMPLETE_WITH_SUCCESS : PL_Constants.BATCH_COMPLETE_WITH_FAIL ; 
                Database.update(jobStatus[0]); 
            } 
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }

        String queryString = ''; 
        if(System.Label.CrossRegionCARGoalBatchQuery != Null){
            queryString = System.Label.CrossRegionCARGoalBatchQuery;
        }
        
        Integer batchSize=200;
        if(System.Label.CrossRegionCARGoalBatchSize!=null && System.Label.CrossRegionCARGoalBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.CrossRegionCARGoalBatchSize);
        }
        
        CrossRegionCARGoalBatch crossRegionCARGoalBatchtemp = new CrossRegionCARGoalBatch(queryString);
        if(!Test.isRunningTest()){ 
            database.executebatch(new CrossRegionCARGoalBatch(queryString), batchSize);
        }
        
    }

    
    //Get job status    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) { //
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
                            Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                            String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ?  
                                             error.getMessage() + PL_Constants.NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + PL_Constants.NEW_LINE;                                    
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
    
    private void createMetrics(List<Goal> newGoalList, Map<Id,Integer> MgrVsCARCount,
                             Map<Id, Integer> MgrVsTotalCount, Map<Id, Integer> MgrVsCARMgrCount,List<Job_Status__c> jobStatus){//
        List<Metric> metricList = new List<Metric> ();
        Metric objMetric;
        system.debug('inside metric>>>');
        Integer carCount, totalCount, mgrCount;
        for(Goal goal:newGoalList){
            system.debug('insde for goal>>>');
                //CAR Count
                carCount = MgrVsCARCount.get(goal.ownerId);
                totalCount = MgrVsTotalCount.get(goal.ownerId);
                mgrCount = MgrVsCARMgrCount.get(goal.ownerId);
                if(goal.Name.contains(PL_Constants.MONTHLY_GOAL)){
                    //Total Property Visits per Month Metric
                    objMetric = new Metric();       
                    objMetric.Name = System.Label.Metric_Name_TotalPropertyVisitsperMonth;
                    objMetric.OwnerId = goal.ownerId ;
                    objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                    objMetric.StartDate = preGoalStartDate;
                    objMetric.DueDate = preGoalDueDate;
                    objMetric.GoalId=goal.id;
                    objMetric.Sort_Order__c = 1;
                    objMetric.TargetValue = carCount*Integer.valueOf(System.Label.Target_TotalPropertyVisitsperMonth);
                    metricList.add(objMetric);
                    
                    //Average Property Visits per Day Metric
                    objMetric = new Metric();
                    objMetric.Name = System.Label.Metric_Name_AveragePropertyVisitsperDay;
                    objMetric.OwnerId = goal.ownerId;
                    objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                    objMetric.StartDate = preGoalStartDate;
                    objMetric.DueDate = preGoalDueDate;
                    objMetric.GoalId = goal.id;
                    objMetric.Sort_Order__c = 2;
                    objMetric.TargetValue = carCount*Integer.valueOf(System.Label.Target_AveragePropertyVisitsperDay);            
                    metricList.add(objMetric);
                    
                    //Profile Completness Metric
                    objMetric = new Metric();
                    objMetric.Name = System.Label.Metric_Name_ProfileCompletionPercent;
                    objMetric.OwnerId = goal.ownerId;
                    objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                    objMetric.StartDate = preGoalStartDate;
                    objMetric.DueDate = preGoalDueDate;
                    objMetric.GoalId = goal.id;
                    objMetric.TargetValue = 100;
                    objMetric.Sort_Order__c = 3;
                    metricList.add(objMetric);
                    
                    //Event Metric
                    objMetric = new Metric();
                    objMetric.Name = System.Label.Metric_Name_Events;
                    objMetric.OwnerId = goal.ownerId;
                    objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                    objMetric.StartDate = preGoalStartDate;
                    objMetric.DueDate = preGoalDueDate;
                    objMetric.GoalId = goal.id;
                    objMetric.Sort_Order__c = 4;
                    objMetric.TargetValue = carCount*Integer.valueOf(System.Label.Target_Events);
                    metricList.add(objMetric);
                    
                    //1:1 Coaching Metric
                    objMetric = new Metric();
                    objMetric.Name = System.Label.Metric_Name_OneToOneCoaching;
                    objMetric.OwnerId = goal.ownerId;
                    objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                    objMetric.StartDate = preGoalStartDate;
                    objMetric.DueDate = preGoalDueDate;
                    objMetric.GoalId = goal.id;
                    objMetric.Sort_Order__c = 5;
                    objMetric.TargetValue = totalCount*Integer.valueOf(System.Label.Target_Coaching);
                    metricList.add(objMetric);
                    
                    //1:1 Super Coach Observation Metric
                    objMetric = new Metric();
                    objMetric.Name = System.Label.Metric_Name_OneToOneSuperCoachObservation;
                    objMetric.OwnerId = goal.ownerId;
                    objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                    objMetric.StartDate = preGoalStartDate;
                    objMetric.DueDate = preGoalDueDate;
                    objMetric.GoalId = goal.id;
                    objMetric.Sort_Order__c = 6;
                    objMetric.TargetValue = mgrCount*Integer.valueOf(System.Label.Target_SuperCoachObservation);
                    metricList.add(objMetric);
                    
                    //Forum Metric
                    objMetric = new Metric();
                    objMetric.Name = System.Label.Metric_Name_Forum;
                    objMetric.OwnerId = goal.ownerId;
                    objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                    objMetric.StartDate = preGoalStartDate;
                    objMetric.DueDate = preGoalDueDate;
                    objMetric.GoalId = goal.id;
                    objMetric.Sort_Order__c = 7;
                    objMetric.TargetValue = Integer.valueOf(System.Label.Target_Forum);
                    metricList.add(objMetric);
                    
                    //Huddle Observation Metric
                    objMetric = new Metric();
                    objMetric.Name = System.Label.Metric_Name_HuddleObservation;
                    objMetric.OwnerId = goal.ownerId;
                    objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                    objMetric.StartDate = preGoalStartDate;
                    objMetric.DueDate = preGoalDueDate;
                    objMetric.GoalId = goal.id;
                    objMetric.Sort_Order__c = 8;
                    objMetric.TargetValue = mgrCount*Integer.valueOf(System.Label.Target_HuddleObservation);
                    metricList.add(objMetric);
                }
                if(goal.Name.contains(PL_Constants.QUATERLY_GOAL)){
                    //Field Observation Super Coach Metric
                    objMetric = new Metric();       
                    objMetric.Name = System.Label.Metric_Name_FieldObservationSuperCoach;
                    objMetric.OwnerId = goal.ownerId ;
                    objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                    objMetric.StartDate = preGoalStartDate;
                    //Start - US1087049 - SP54 - Animesh
                    //objMetric.DueDate = preGoalDueDate;
                    objMetric.DueDate = preGoalDueDate.addMonths(2);//US1087049 - SP54 commmented line "objMetric.DueDate = preGoalDueDate;". Added this line to correct Duedate
                    //US1087049 - SP54 - Animesh
                    objMetric.GoalId=goal.id;
                    objMetric.Sort_Order__c = 1;
                    objMetric.TargetValue = mgrCount*Integer.valueOf(System.Label.Target_FieldObservation);
                    metricList.add(objMetric);
                }
            }      
            system.debug('metricList>>>>>'+metricList);
            Database.SaveResult[] insertMetrics = Database.insert(metricList,false); 
            executeJob(insertMetrics, jobStatus);
    }
}