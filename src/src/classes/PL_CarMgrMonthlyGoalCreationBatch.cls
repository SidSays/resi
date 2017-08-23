/**************************************************************************************************
Name : PL_CarMgrMonthlyGoalCreationBatch
Description : This batch class creates goals and metrics of Car Manager on monthly basis. 
User Story : US760932
Date : 01 Sept 2016
Author : Amit Kumar Pradhan
Modified : Radhika Bansal 23-Feb-2017
Description : US931782 : CAR Manager Coaching Activity: Targets
Last Modified By : Amit Kumar Pradhan 10-July-2017
User Story : US1108731(Coach for CAR Leaders: Populate Goal field 'Region')
Last Modified By : Tejaswini Kasar 07-Aug-2017
User Story : US1159795(Coach for CAR - Additional Activity Metrics for CAR Managers)
***************************************************************************************************/
global class PL_CarMgrMonthlyGoalCreationBatch implements Database.Batchable<sObject>, Database.Stateful{
    private Id jobStatusId = null;   
    private GoalTemplateDates__c goalDates = null;  
    private String queryString = '';
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    private static final String STRING_COUNT = 'CNT';
    private Set<Id> CARDirectorOrSrManagersIds = new Set<Id>(); // Contains CAR Director/Sr Manager
    private static final Set<String> profileNameSet  = new Set<String>{Label.Xfinity_CARmanager_ProfileName}; 
    private Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
    
   
    /* Constructor for batch class PL_CarMgrMonthlyGoalCreationBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-  'Select Id, Name, ManagerId,Profile.Name, ProfileId from User where  IsActive = True AND Profile.Name IN: profileNameSet and   
     * UserPermissionsWorkDotComUserFeature = true' 
     */
    global PL_CarMgrMonthlyGoalCreationBatch(String query){
        this.queryString=query;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Job_Status__c job = new Job_Status__c();
        job.Name = PL_Constants.BATCH_JOB_NAME_FOR_CARMGR + PL_Constants.JOB_NAME_SPACE  + Datetime.now();
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
                                                WHERE PermissionSet.Name = :PL_Constants.PERM_SET_FOR_CAR_DIR_SR_MGR]){
                    // CAR Director/Sr Manager (Do not necessarily have "Xfinity CAR Manager" profile)
                    CARDirectorOrSrManagersIds.add(psa.AssigneeId); 
        }
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<User> userList){
        
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        List <Goal> newGoalList= new List <Goal>(); 
        List<Id> createdGoalList = new List<Id>();
        Set<Id> CARManagerIds = new Set<Id>(); //Contains CAR Managers Ids
        Map<Id,Integer> MgrVsCARCount = new Map<Id,Integer>(); //Contains Id of CAR Director/Sr Manager and number of CARs under them
        Map<Id,AggregateResult> carCountMap;
        List<Goal> goalStatusUpdateList = new List<Goal>();
        List<Metric> metricUpdateList = new List<Metric>();
        
        String dateString = preGoalDueDate.month()+ PL_Constants.DATE_DELIMIT +preGoalDueDate.day() + 
              PL_Constants.DATE_DELIMIT + preGoalDueDate.year(); 
        Integer carCount;
        Goal goalInst;
        Database.SaveResult[] insertGoals;
        
        try{            
           for(User u : userList){
               CARManagerIds.add(u.Id);         
           }
        Map<ID,Goal> goalsIdObjectMap = new Map<ID,Goal>([SELECT Id,Name,DueDate,Status FROM Goal 
                                                    WHERE OwnerID IN : CARManagerIds AND Status !=: PL_Constants.GOAL_STATUS_COMPLETE 
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
            
           CARManagerIds.removeAll(CARDirectorOrSrManagersIds);  // CARManagersOnly i.e. CAR Manager who are not CAR Director/Sr Manager
            //Create Goals for CAR ManagersOnly i.e. CAR Manager who are not CAR Director/Sr Manager
            if(CARManagerIds != null && !CARManagerIds.isEmpty()){
              carCountMap = new Map<Id,AggregateResult> ( [SELECT ManagerId Id,Count(Id) CNT FROM User 
                                         WHERE isActive=TRUE 
                                                         AND Profile.Name =: Label.Xfinity_CAR_ProfileName 
                                                         AND ManagerId IN :CARManagerIds AND UserPermissionsWorkDotComUserFeature = true
                                                          GROUP BY ManagerId 
                                                          LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
              for(Id carMgrId : carCountMap.keySet()){
                  carCount = Integer.valueOf(carCountMap.get(carMgrId).get(STRING_COUNT));
                  MgrVsCARCount.put(carMgrId,carCount);
              }
              
              for(User carManager : userList){ 
                  if(carCountMap.containsKey(carManager.Id)){
                      goalInst = new Goal();               
                      goalInst.Name = carManager.Name + PL_Constants.PROPERTY_LAB + dateString;
                      goalInst.Status = PL_Constants.GOAL_STATUS_PUBLISHED;
                      goalInst.ownerId = carManager.Id;
                      goalInst.RecordTypeId = PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID;
                      goalInst.StartDate = preGoalStartDate;
                      goalInst.DueDate = preGoalDueDate;
                      goalInst.Profile_Name__c = carManager.Profile.Name;
                      goalInst.Region__c = carManager.Region__c;//Added by Amit Kumar Pradhan(US1108731:Populate Goal field 'Region')
                      goalInst.Template_Type__c = PL_Constants.TEMPLATE_TYPE_PROPERTYLAB;
                      newGoalList.add(goalInst);
                  }
              }
              
              insertGoals = Database.insert(newGoalList,false); 
                          
              executeJob(insertGoals,jobStatus);
              
              for(Database.SaveResult sr : insertGoals){
                  if(sr.isSuccess()){
                      createdGoalList.add(sr.getId());
                  }
              }
              newGoalList = [SELECT Id, OwnerId FROM Goal WHERE Id IN :createdGoalList];
              //Creat Metrics for CAR Managers who are not CAR Director/Sr Manager
              createMetrics(newGoalList,MgrVsCARCount,jobStatus);
            }
            
        }catch(Exception e){
             if(jobStatus!=null && !jobStatus.isEmpty()){
                    String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? PL_Constants.SYSTEM_EXCEPTION + e.getMessage() + PL_Constants.NEW_LINE : jobStatus[0].Comments__c + PL_Constants.SYSTEM_EXCEPTION + e.getMessage() +PL_Constants.NEW_LINE;                                    
                    jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; 
                    Database.update(jobStatus[0]);   
             } 
        }   
    }
     
    //Execute Finish logic after execution of batch records completed
    global void finish(Database.BatchableContext BC){ 
        try{
            List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
            if(jobStatus!=null && !jobStatus.isEmpty()){ 
                jobStatus[0].Batch_End_Time__c = Datetime.now(); 
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? PL_Constants.BATCH_COMPLETE_WITH_SUCCESS : PL_Constants.BATCH_COMPLETE_WITH_FAIL ; 
                Database.update(jobStatus[0]); 
            } 
        }catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }   
        // Call PL_CARDirectorMonthlyGoalCreationBatch AND bypass for Test class        
        String queryString = '';
        if(Label.PL_CARDirectorMonthlyGoalCreationBatch != null){
            queryString = Label.PL_CARDirectorMonthlyGoalCreationBatch;
        }
        Integer batchSize=1;
        if(System.Label.CarMgrMonthlyGoalCreationBatchSize!=null && System.Label.CarMgrMonthlyGoalCreationBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.CarMgrMonthlyGoalCreationBatchSize);
        }
        if(!Test.isRunningTest()){ 
        database.executebatch(new PL_CARDirectorMonthlyGoalCreationBatch(queryString), batchSize);
        }
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
    
    private void createMetrics(List<Goal> newGoalList, Map<Id,Integer> MgrVsCARCount,
                             List<Job_Status__c> jobStatus){
        List<Metric> metricList = new List<Metric> ();
        Metric objMetric;
        Integer carCount;
        for(Goal goal:newGoalList){
                //CAR Count
                carCount = MgrVsCARCount.get(goal.ownerId);
                
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
                
                //Added by Radhika Bansal for US931782 - CAR Manager Coaching Activity: Targets on 23-Feb-2017
                //1:1 coaching metric 
        //commenting code as Activity Goal is not going live on 15th March, 2017
                objMetric = new Metric();
                objMetric.Name = PL_Constants.METRIC_NAME_1_1_COACHING;
                objMetric.OwnerId = goal.ownerId;
                objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                objMetric.StartDate = preGoalStartDate;
                objMetric.DueDate = preGoalDueDate;
                objMetric.GoalId = goal.id;
                objMetric.Sort_Order__c = 5;
                objMetric.TargetValue = carCount*4;
                metricList.add(objMetric);
                
                //Observations metric 
                objMetric = new Metric();
                objMetric.Name = PL_Constants.METRIC_NAME_OBSERVATION;
                objMetric.OwnerId = goal.ownerId;
                objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                objMetric.StartDate = preGoalStartDate;
                objMetric.DueDate = preGoalDueDate;
                objMetric.GoalId = goal.id;
                objMetric.Sort_Order__c = 6;
                objMetric.TargetValue = carCount;
                metricList.add(objMetric);
                
                //Huddles               
                objMetric = new Metric();
                objMetric.Name = PL_Constants.METRIC_NAME_HUDDLES;
                objMetric.OwnerId = goal.ownerId;
                objMetric.Status = PL_Constants.METRIC_STATUS_NOTSTARTED;
                objMetric.StartDate = preGoalStartDate;
                objMetric.DueDate = preGoalDueDate;
                objMetric.GoalId = goal.id;
                objMetric.Sort_Order__c = 7;
                objMetric.TargetValue = 4;
                metricList.add(objMetric);
            }      
            
            Database.SaveResult[] insertMetrics = Database.insert(metricList,false); 
            executeJob(insertMetrics, jobStatus);
    }
}