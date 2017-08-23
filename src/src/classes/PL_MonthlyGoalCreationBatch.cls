/**************************************************************************************************
Name : PL_MonthlyGoalCreationBatch
Description : This batch class is created to create Goals and Metric value data on Monthly basis for Property lab CAR users
User Story : US619087
Date : 21 Jan 2016
Author : Animesh Datta
Last Modified By : Amit Kumar Pradhan(Calling of "PL_CarMgrMonthlyGoalCreationBatch" batch from finish method and update the custom setting date inside
                                    "PL_CarMgrMonthlyGoalCreationBatch")
Last Modified Date : 8-Sept-2016(US760932)
***************************************************************************************************/
global class PL_MonthlyGoalCreationBatch implements Database.Batchable<sObject>, Database.Stateful{

     /*
    * Data Member 
    */     
    private GoalTemplateDates__c goalDates = null;
    private Id jobStatusId = null;    
    private static final Set<string> ProfileNameSet  = new Set<string>();   
    private String query= PL_Constants.QUERY_INITIAL;
    private Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
    
    /* Constructor for batch class PL_MonthlyGoalCreationBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-  'Select Id, Name, ManagerId,Profile.name from User where  IsActive = True 
     * AND Profile.Name IN: profileNameSet and  UserPermissionsWorkDotComUserFeature = true' 
     */
    global PL_MonthlyGoalCreationBatch(String query){
        this.query = query;    
    }
    /*
    *Query execution to fetch all users based on profiles - Xfinity CAR
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Create Job Status Object
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = PL_Constants.BATCH_JOB_NAME_FOR_CAR + PL_Constants.JOB_NAME_SPACE  + Datetime.now();
        jobStatus.Status__c = PL_Constants.JOB_STATUS_NEW;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Total_RGU_Activations_Processed__c = 0;
        jobStatus.Total_RGU_Orders_Processed__c = 0;
        jobStatus.Total_RGU_ORders_Upserted_Today__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = PL_Constants.JOB_COMMENT;
        jobStatus.Number_Of_Fallouts__c = 0;
        
        Database.insert(jobStatus);
          
        jobStatusId = jobStatus.Id;       
        String profileNames = Label.PL_MonthlyGoalCreationBatchProfile;// Label value  = Xfinity CAR;  
        goalDates = GoalTemplateDates__c.getInstance(Label.PL_MonthlyGoalCreationBatchCusSetData); //Label value = Property Lab CAR
        if(!string.IsBlank(profileNames)){
            for(String profId : profileNames.split(PL_Constants.PROFILE_ID_SEPERATION)){
                ProfileNameSet.add(profId);
            }    
        } 
        return Database.getQueryLocator(query);  
    }   
    /*
    * Execute business logic to insert new Goals,Metrics Data for CAR
    */
    global void execute(Database.BatchableContext BC, List<User> scopeList){
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        try{
            List<Goal> goalList=new List<Goal>();        
            List<Goal> goalStatusUpdateList = new List<Goal>();
            List<Metric> metricUpdateList = new List<Metric>();
            Map<String , Goal> goalSettingMap = new Map<String , Goal>();
            Map<String, Goal> goalMap = new Map<String, Goal>();
            Map<String,List<Metric>> UserIDMetricListMap = new Map<String,List<Metric>>();
            set<Id> userIdSet = new set<Id>(); 
            
            Date preGoalStartDate = goalDates.Current_Period_Start_Date__c.addMonths(1); 
            Date preGoalDueDate =  goalDates.Current_Period_Due_Date__c.addMonths(1);
            
            for(User user:scopeList){
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
                                    
            Map<String,List<Metric>> pfileNamePetricListMap = new Map<String,List<Metric>>();
            
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
           
            for(Goal gol : [SELECT Id,Assigned_To__c,Template_Type__c,DueDate,Name,StartDate,Status,Profile_Name__c,Region__c,
                           (SELECT Id,Name,TargetValue,Sort_Order__c,Status,DueDate,Weight,LastComment FROM Metrics)  
                            FROM Goal WHERE Template_Type__c = : Label.PL_MonthlyGoalCreationBatchGolTempType 
                            AND RecordtypeId =: PL_Constants.GOAL_TEMPLATE_RECORD_TYPE_ID 
                            LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {   
                                         
                goalSettingMap.put((gol.Profile_Name__c + gol.Region__c).trim() , gol);            
                goalMap.put(gol.Id , gol);
            }                                        
            for(User user:scopeList){        
                    Goal goalInst = goalSettingMap.get((user.Profile.name + user.Region__c).trim());
                    if(goalInst != null){
                            String userIDGoalDueDate=String.valueOf(user.Id) + preGoalDueDate;
                            Goal getGoal= goalMap.get(goalInst.id);                         
                            Goal cloneGoal = new Goal();
                            List<Metric> metricList=new List<Metric>();                         
                            cloneGoal=getGoal.Clone(false,true,true,false);                                 
                            if(user.Profile.name == Label.PL_MonthlyGoalCreationBatchProfileCAR) { // Label PL_MonthlyGoalCreationBatchProfileCAR = Xfinity CAR
                                cloneGoal.OwnerId=user.Id;                                                     
                            } 
                            cloneGoal.Assigned_To__c = user.Id;                     
                            cloneGoal.Status=Label.PL_MonthlyGoalGolStatus; //Label PL_MonthlyGoalGolStatus = Published
                            Date d = preGoalDueDate; 
                            String dateString = d.month()+ PL_Constants.DATE_DELIMIT +d.day()+ PL_Constants.DATE_DELIMIT +d.year();                         
                            cloneGoal.Name=user.Name+ PL_Constants.PROPERTY_LAB +dateString;
                            //Put start and due date in the goal to be create                                           
                            cloneGoal.StartDate = preGoalStartDate;    
                            cloneGoal.DueDate = preGoalDueDate;                         
                            cloneGoal.RecordTypeId= PL_Constants.PROPERTY_LAB_RECORD_TYPE_ID ; 
                            goalList.add(cloneGoal);
                                for(Metric metr: cloneGoal.Metrics){
                                    Metric mt = new Metric();
                                    mt=metr.Clone(false,true,true,false);                               
                                    if(Label.Goal_Xfinity_CAR.equalsIgnoreCase(user.Profile.name)) { 
                                        mt.OwnerId=user.Id;
                                    }                           
                                    mt.Status= Label.PL_MonthlyGoalBatchMetricStatus; //Label value = NotStarted 
                                    mt.DueDate = preGoalDueDate;
                                    mt.Sort_Order__c = metr.Sort_Order__c;
                                    metricList.add(mt);
                                }    
                            
                            UserIDMetricListMap.put(userIDGoalDueDate.trim() , metricList);                             
                    }                       
            }                  
            //Inserting new Goals records 
            Database.SaveResult[] insertGoals = Database.Insert(goalList,false);           
            if(jobStatus !=null && !jobStatus.isEmpty()){
                for(Database.SaveResult result : insertGoals) {
                    jobStatus[0].Total_Records_Processed__c ++;
                    if(!result.isSuccess()){                                                 
                        for(Database.Error error : result.getErrors()){
                            jobStatus[0].Number_Of_Fallouts__c  ++;
                            String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? error.getMessage() + PL_Constants.NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + PL_Constants.NEW_LINE;                                    
                            jobStatus[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;
                        }
                    }      
                }
                Database.update(jobStatus[0]);
            }           
            List<Metric> metricInsertList = new List<Metric>();          
            // Assigning metric to goal
            for(Goal goalObj : [SELECT id, OwnerId ,Assigned_To__c, DueDate , Name FROM Goal WHERE Id In : goalList]){
                if(UserIDMetricListMap.get((String.valueOf(goalObj.Assigned_To__c) + goalObj.DueDate).trim()) != null){
                   List<Metric> metricInsertList1 = new List<Metric>();
                   String userIDGoalDueDate=String.valueOf(goalObj.Assigned_To__c) + goalObj.DueDate; 
                   for(Metric metricObj : (List<Metric>) UserIDMetricListMap.get(userIDGoalDueDate.trim())){
                        metricObj.GoalId = goalObj.Id;
                        metricInsertList1.add(metricObj);                     
                   }
                   metricInsertList.addAll(metricInsertList1);       
                }   
            }          
            //Inserting new Metrics
             Database.SaveResult[] insertMetrics = Database.Insert(metricInsertList,false);                      
             if(jobStatus !=null && !jobStatus.isEmpty()){
                for(Database.SaveResult result : insertMetrics) {
                    jobStatus[0].Total_Records_Processed__c ++;
                    if(!result.isSuccess()){                                                 
                        for(Database.Error error : result.getErrors()){
                            jobStatus[0].Number_Of_Fallouts__c  ++;
                            String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? error.getMessage() + PL_Constants.NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + PL_Constants.NEW_LINE;                                    
                            jobStatus[0].Comments__c=(tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;
                         }
                    }       
                }
                Database.update(jobStatus[0],false);
            } 
            
        }
        catch(Exception e) {
             if(jobStatus !=null && !jobStatus.isEmpty()){
                    String tempMsg = String.IsBlank(jobStatus[0].Comments__c) ? PL_Constants.SYSTEM_EXCEPTION + e.getMessage() + PL_Constants.NEW_LINE : jobStatus[0].Comments__c+PL_Constants.SYSTEM_EXCEPTION + e.getMessage()+PL_Constants.NEW_LINE;                                    
                    jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0]);   
             }           
        }           
    }   
    //Execute Finish logic after execution of batch records completed
    global void finish(Database.BatchableContext BC){      
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
        if(jobStatus !=null && !jobStatus.isEmpty()){ 
            jobStatus[0].Batch_End_Time__c = Datetime.now(); 
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? PL_Constants.BATCH_COMPLETE_WITH_SUCCESS :PL_Constants.BATCH_COMPLETE_WITH_FAIL ; 
            Database.update(jobStatus[0]); 
        } 
        
        // Call PL_CarMgrMonthlyGoalCreationBatch AND bypass for Test class        
        String queryString = '';
        if(System.Label.CarMgrMonthlyGoalCreationBatchQuery != null){
            queryString = System.Label.CarMgrMonthlyGoalCreationBatchQuery;
        }
        Integer batchSize=1;
        if(System.Label.CarMgrMonthlyGoalCreationBatchSize!=null && System.Label.CarMgrMonthlyGoalCreationBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.CarMgrMonthlyGoalCreationBatchSize);
        }
        PL_CarMgrMonthlyGoalCreationBatch inst= new PL_CarMgrMonthlyGoalCreationBatch(queryString);
        if(!Test.isRunningTest()){ 
            database.executebatch(inst, batchSize);
        }
    }   
    //Get job status    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
           return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                   Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                   Total_RGU_ORders_Upserted_Today__c 
                   FROM Job_Status__c WHERE Status__c = :PL_Constants.JOB_STATUS_NEW AND ID=: jobStatusId]);
    }
}