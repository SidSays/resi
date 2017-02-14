/**************************************************************************************************
Name : PL_CarMgrMonthlyGoalCreationBatch
Description : This batch class creates goals and metrics of Car Manager on monthly basis. 
User Story : US760932
Date : 01 Sept 2016
Author : Amit Kumar Pradhan
***************************************************************************************************/
global class PL_CarMgrMonthlyGoalCreationBatch implements Database.Batchable<sObject>, Database.Stateful{
    //private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    //private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    //private static final String BATCH_JOB_NAME = 'PL_CarMgrMonthlyGoalCreationBatch';
    //private static final String JOB_STATUS_NEW = 'New';
    //private static final String NEW_LINE = '\n';
    //private static final String SYSTEM_EXCEPTION = 'System Exception - ';    
    //private static final String JOB_COMMENT = ' ';
    //private static final String JOB_NAME_SPACE =  ' - ';
    private Id jobStatusId = null;   
    private GoalTemplateDates__c goalDates = null;  
    //private static final String PROPERTY_LAB =  ' - PL - ';
    //private static final String DATE_DELIMIT =  '-';
    private String queryString = '';
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    //private static final String GOAL_STATUS_COMPLETE = 'Completed';
    //private static final String GOAL_STATUS_PUBLISHED = 'Published';
    //private static final String METRIC_STATUS_NOTSTARTED = 'NotStarted';
    //private static final String TEMPLATE_TYPE_PROPERTYLAB = 'Property Lab';
    private static final String STRING_COUNT = 'CNT';
    private Set<Id> CARDirectorOrSrManagersIds = new Set<Id>(); // Contains CAR Director/Sr Manager
    //private static final set<String> GOALTYPE = new Set<String>{'% - PL - %'}; 
    private static final Set<String> profileNameSet  = new Set<String>{Label.Xfinity_CARmanager_ProfileName}; 
    
    //private static final String PROPERTY_LAB_RECORD_TYPE_ID = Schema.SObjectType.Goal.getRecordTypeInfosByName().get(Label.PL_MonthlyGoalCreationBatchGolTempType).getRecordTypeId();
    private date todaysDate;
    
   
    /* Constructor for batch class PL_CarMgrMonthlyGoalCreationBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-  'Select Id, Name, ManagerId from User where  IsActive = True AND Profile.Name IN: profileNameSet and   
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
        todaysDate=system.today();
        
        for(PermissionSetAssignment psa :  [SELECT AssigneeId FROM PermissionSetAssignment 
                                                WHERE PermissionSet.Name = :PL_Constants.PERM_SET_FOR_CAR_DIR_SR_MGR]){
                    // CAR Director/Sr Manager (Do not necessarily have "Xfinity CAR Manager" profile)
                    CARDirectorOrSrManagersIds.add(psa.AssigneeId); 
        }
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<User> userList){
        
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        //List<Goal> goalStatusUpdateList = new List<Goal>();
        List <Goal> newGoalList= new List <Goal>(); 
        List<Id> createdGoalList = new List<Id>();
        Set<Id> CARManagerIds = new Set<Id>(); //Contains CAR Managers Ids
        Map<Id,Integer> MgrVsCARCount = new Map<Id,Integer>(); //Contains Id of CAR Director/Sr Manager and number of CARs under them
        Map<Id,AggregateResult> carCountMap;
        String dateString = preGoalDueDate.month()+ PL_Constants.DATE_DELIMIT +preGoalDueDate.day() + 
        			PL_Constants.DATE_DELIMIT + preGoalDueDate.year(); 
        Integer carCount;
        Goal goalInst;
        Database.SaveResult[] insertGoals;
        
        try{            
           for(User u : userList){
               CARManagerIds.add(u.Id);
           } 
            
           CARManagerIds.removeAll(CARDirectorOrSrManagersIds);  // CARManagersOnly i.e. CAR Manager who are not CAR Director/Sr Manager
            
            //Create Goals for CAR ManagersOnly i.e. CAR Manager who are not CAR Director/Sr Manager
            if(CARManagerIds != null && !CARManagerIds.isEmpty()){
	            carCountMap = new Map<Id,AggregateResult> ( [SELECT ManagerId Id,Count(Id) CNT FROM User 
			                    							 WHERE isActive=TRUE 
		                                                     AND Profile.Name =: Label.Xfinity_CAR_ProfileName 
		                                                     AND ManagerId IN :CARManagerIds 
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
                    Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                    String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ?  
                    				 PL_Constants.SYSTEM_EXCEPTION + e.getMessage() + PL_Constants.NEW_LINE : 
                    				 jobStatus[0].Comments__c + PL_Constants.SYSTEM_EXCEPTION + e.getMessage() +PL_Constants.NEW_LINE;                                    
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
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? 
            							 PL_Constants.BATCH_COMPLETE_WITH_SUCCESS : 
            							 PL_Constants.BATCH_COMPLETE_WITH_FAIL ; 
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
    	database.executebatch(new PL_CARDirectorMonthlyGoalCreationBatch(queryString), batchSize);
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
                            Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                            String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ?  
                        					 error.getMessage() + PL_Constants.NEW_LINE : 
                        					 jobStatus[0].Comments__c + error.getMessage() + PL_Constants.NEW_LINE;                                    
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
            }      
            
            Database.SaveResult[] insertMetrics = Database.insert(metricList,false); 
            executeJob(insertMetrics, jobStatus);
    }
}