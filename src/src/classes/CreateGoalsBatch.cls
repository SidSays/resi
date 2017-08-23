/**************************************************************************************************
Name : CreateGoalsBatch
Description : This batch class created to update Goals and Metric status data as 'Completed' 
and insert Goals and Metrics on monthly basis
User Story : US491514
Date : 27 July 2015
Author : Rahul Prabhakar
Last Modified By : Ashish Sonawane(Roll up XSP target values to SDM target value and Code optimisation) 
Last Modified By : Suchita Sharma(Constructor defined for batch which should take query string as parameter for execution.)
Last Modified By : Amit Kumar Pradhan(Creating Goals and Metrics for Director)
Last Modified Date : 29-Dec-2016(US872123,US872120,US872118,US872117)
Last Modified By : Animesh Datta(West Division ASM/SDM/XSP RGU and Activity Goals to Monthly) 
***************************************************************************************************/
global class CreateGoalsBatch implements Database.Batchable<sObject>, Database.Stateful
{
    /*
    * Data Member 
    */
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'CreateGoalsBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string RECORD_TYPE_SEPERATION = ';';
    private static final string JOB_COMMENT = ' ';
    private static final string JOB_NAME_SPACE =  ' - ';
    private static final set<string> goalType = new Set<String>{'%RGU%', '%Activity%'};
    private static final set<string> profileName = new Set<String>{System.Label.DSRProfileName};
    private static final String GoalTemplateRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Goal Template').getRecordTypeId();
    private static final String directSalesRecordTypeId = Schema.SObjectType.Goal.getRecordTypeInfosByName().get('Direct Sales').getRecordTypeId();  
    private static final string GOAL_STATUS_COMPLETE = 'Completed';
    private static final string GOAL_STATUS_PUBLISHED = 'Published';
    private static final string METRIC_STATUS_NOTSTARTED = 'NotStarted';
    
    private static final string BIWEEKLY_CS_RECORD = 'ByWeeklyStartAndEndDate';
    private static final string MONTHLY_CS_RECORD = 'MonthlyStartAndEndDateDS';
    
    private date preGoalStartDate = null;
    private date preGoalDueDate = null;
    private Id jobStatusId = null;    
    private map<String, Goal> templateGoalMap = new Map<String, Goal>();
    private map<String , Goal> goalSettingMap = new map<String , Goal>();  
    public String query='';
    private boolean isWestDivision = false;
    //public String query='Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c, Comcast_Division__c, ManagerId, Manager.ManagerId  from User where  IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true ';    
    /* Constructor for batch class CreateGoalsBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :-  'Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c, Comcast_Division__c, ManagerId, Manager.ManagerId from User where  IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true '
     */
    global CreateGoalsBatch(String query,Boolean isWest)
    {
        this.query=query;
        isWestDivision = isWest;
    }

    /*
    * Query execution to fetch all users based on profiles - XFINITY Sales Professional(XSP),Supervisor(SDM)
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
        
        //Generate goal data from Template for XSP 
        for(Goal gol : [SELECT Id,DueDate,Name,StartDate,Status,Profile_Name__c,OrigGoalId__c,Template_Type__c,Region__c,Sales_Rep_Type__c,RecordTypeId,Level__c,
                            (SELECT Id,Name,TargetValue,Status,DueDate,Weight,LastComment,Sort_Order__c from Metrics)  FROM Goal where Profile_Name__c IN: profileName and recordtypeId =: GoalTemplateRecordTypeId and Template_Type__c LIKE :goalType]) {
            templateGoalMap.put(gol.Id , gol);           
            goalSettingMap.put((gol.Profile_Name__c + gol.Region__c + gol.Sales_Rep_Type__c+gol.Level__c+gol.Template_Type__c).trim() , gol);            
        } 
                          
        //Get the commission cycle start and end date period from custom settings for Biweekly commission cycle 
        
        
        if(isWestDivision){
                GoalTemplateDates__c goalDatesMonthly = GoalTemplateDates__c.getInstance(MONTHLY_CS_RECORD); //Fetching Monthly Goal Template Custom Setting Data   
                preGoalStartDate = goalDatesMonthly.Current_Period_Start_Date__c;
                preGoalDueDate =  goalDatesMonthly.Current_Period_Due_Date__c;
                preGoalStartDate=preGoalStartDate.addMonths(1);
                preGoalDueDate=preGoalDueDate.addMonths(1);
            }
        else{
                GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(BIWEEKLY_CS_RECORD); //Fetching Biweekly Goal Template Custom Setting Data 
                preGoalStartDate = goalDates.Current_Period_Start_Date__c;
                preGoalDueDate =  goalDates.Current_Period_Due_Date__c;
                preGoalStartDate=preGoalStartDate.addDays(14);
                preGoalDueDate=preGoalDueDate.addDays(14);
            }
                    
        return Database.getQueryLocator(query);
    }
    
    
    /*
     * Execute business logic to update Goals,Metrics to 'completed' status and insert new Goals,Metrics
     */
    global void execute(Database.BatchableContext BC, List<User> userList){   
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
    try { 
            String userRegion;
            String goalId;
            String userRepType;
            String userLevel;
            List<Goal> goalList=new List<Goal>();                          
            List<Goal> goalStatusUpdateList = new List<Goal>();
            List<Metric> metricUpdateList = new List<Metric>();
            List<Metric> metricExistUpdateList = new List<Metric>();
            Map<Id,Metric> metIdUpdateList = new Map<Id,Metric>();
            Map<Id,Metric> ASMmetIdUpdateList = new Map<Id,Metric>();
            Map<Id,Metric> directorMetIdUpdateMap = new Map<Id,Metric>();
            
            Set<Id> userIdSet = new Set<Id>();
            Set<Id> ASMIdSet = new Set<Id>();
            Map<Id,Id> userIdManagerIdMap = new Map<Id,Id>();
            Map<Id,Id> ManagerIdMap = new Map<Id,Id>();
            Map<Id,Id> asmIdDirectorIdMap = new Map<Id,Id>();// Added By Amit
            Map<Id,Id> ASMIdManagerIdMap = new Map<Id,Id>(); // Added by Radhika
            Map<Id,List<Metric>> superIdMetricListMap = new Map<Id,List<Metric>>();
            Map<Id,List<Metric>> ASMsuperIdMetricListMap = new Map<Id,List<Metric>>();
            Map<Id,List<Metric>> directorSuperIdMetricListMap = new Map<Id,List<Metric>>();
            Map<Id,List<Metric>> superIdUpdatedMetricListMap = new Map<Id,List<Metric>>();
            

            for(User userObj : userList){
                userIdSet.add(userObj.Id);                 
                if(userObj.ManagerId != null){
                    userIdManagerIdMap.put(userObj.Id,userObj.ManagerId);   
                    userIdSet.add(userObj.ManagerId);               
                
                    //Added By Radhika: Start
                    if(userObj.Manager.ManagerId != null){
                        ManagerIdMap.put(userObj.ManagerId, userObj.Manager.ManagerId);   
                        userIdSet.add(userObj.Manager.ManagerId); // Added to add ASM Goals
                        
                        //Added By Amit
                        if(userObj.Manager.Manager.ManagerId != null){
                            asmIdDirectorIdMap.put(userObj.Manager.ManagerId, userObj.Manager.Manager.ManagerId);   
                            userIdSet.add(userObj.Manager.Manager.ManagerId); // Added to Create Director RGU Goals                 
                        }   
                        //End                       
                    }   
                    //End
                }
            }
                   
                      
            //Get manager user information
            Map<Id,User> managerIdUserObjMap = new Map<Id,User>([SELECT Id, Name, Profile.Name, Region__c 
                                                                    FROM User WHERE IsActive = true AND UserPermissionsWorkDotComUserFeature = true AND Id IN: userIdManagerIdMap.values()]);
                                                                                                                                 
            //Added by Radhika
            //Start         
            Map<Id, User> ASMIdUserObjMap = new Map<Id, User>([Select Id, ManagerId, Name, Profile.Name, Region__c 
                                                                    FROM User WHERE IsActive = true AND UserPermissionsWorkDotComUserFeature = true AND Id IN: ManagerIdMap.values()]);
                                                                               
            //End
            
            //Added by Amit : Start        
            Map<Id, User> directorIdUserObjMap = new Map<Id, User>([Select Id, Name, Profile.Name, Region__c FROM User WHERE IsActive = true AND UserPermissionsWorkDotComUserFeature = true 
                                                                        AND Id IN: asmIdDirectorIdMap.values() AND Profile.Name = :System.Label.DirectSalesDirectorProfile]);
                                                                               
            //End
                
            /* Collect goal's and metric's that are to be mark as status completed   */
            Map<ID,Goal> goalsIdObjectMap = new Map<ID,Goal>([SELECT Id,Name,DueDate,Status FROM Goal 
                                                    WHERE OwnerId IN:userIdSet AND Id NOT IN:templateGoalMap.keySet() AND Status !=: GOAL_STATUS_COMPLETE AND DueDate <: System.today() AND Name LIKE :goalType]);         
                                     
            List<Metric> metric = [SELECT Id,Name,Status FROM Metric WHERE GoalId IN:goalsIdObjectMap.keySet() AND Status !=: GOAL_STATUS_COMPLETE AND DueDate <: System.today()];   
            Map<String,List<Metric>> pfileNamePetricListMap = new Map<String,List<Metric>>();
            
            /* Update 'goalStatusUpdateList' that are in previous commission cycle and status is not 'Completed' */
            for(Goal goalTemp : goalsIdObjectMap.values()){
                goalTemp.Status = GOAL_STATUS_COMPLETE;
                goalStatusUpdateList.add(goalTemp);
            }                   
            Database.SaveResult[] updateGoals = Database.Update(goalStatusUpdateList,false);  
            executeJob(updateGoals, jobStatus); // Added by Radhika to update job status from one method    
                        
            /* Update metricUpdateList that are in previous commission cycle and status is not 'Completed' for respective Goals */
            for(Metric metricTemp : metric){  
                metricTemp.Status = GOAL_STATUS_COMPLETE;  
                metricUpdateList.add(metricTemp); 
            }                       
            Database.SaveResult[] updateMetrics = Database.Update(metricUpdateList,false);            
            executeJob(updateMetrics, jobStatus); // Added by Radhika to update job status from one method  
            
             /* Collect All Metrics created during previous execute method that can use in further */
            for(Goal sdmGoalTemp : [SELECT Id, Status, ownerId, (SELECT Id, Name, Status, TargetValue FROM Metrics) FROM Goal 
                                                WHERE Status = :GOAL_STATUS_PUBLISHED AND StartDate =: preGoalStartDate AND DueDate =: preGoalDueDate AND OwnerId IN : userIdManagerIdMap.values()]){
                superIdMetricListMap.put(sdmGoalTemp.OwnerId,sdmGoalTemp.Metrics);               
            }
            
            //Added by Radhika: Start
            /* Collect All Metrics created during previous execute method  that can use in further */
            for(Goal sdmGoalTemp : [SELECT Id, Status, ownerId, (SELECT Id, Name, Status, TargetValue FROM Metrics) FROM Goal 
                                                WHERE Status = :GOAL_STATUS_PUBLISHED AND StartDate =: preGoalStartDate AND DueDate =: preGoalDueDate AND OwnerId IN : managerIdMap.values()]){
                ASMsuperIdMetricListMap.put(sdmGoalTemp.OwnerId,sdmGoalTemp.Metrics);               
            }
            //End
           
            //Added by Amit: Start
            for(Goal directorGoal : [SELECT Id, Status, ownerId, (SELECT Id, Name, Status, TargetValue FROM Metrics) FROM Goal 
                                                WHERE Status = :GOAL_STATUS_PUBLISHED AND StartDate =: preGoalStartDate AND DueDate =: preGoalDueDate AND OwnerId IN : asmIdDirectorIdMap.values()]){
                directorSuperIdMetricListMap.put(directorGoal.OwnerId,directorGoal.Metrics);               
            }
            //End
           
            // create RGU Goal Record
            for(User user : userList){                 
                userLevel = user.Level__c;      
                userRegion = user.Region__c;
                userRepType = user.Sales_Rep_Type__c;
                String UserprofileName = user.profile.name;  
                Goal goal = goalSettingMap.get((UserprofileName + userRegion + userRepType + userLevel+'RGU').trim()); 
                
                if(goal != null){
                    Goal getGoal= templateGoalMap.get(goal.Id); 
                    Goal cloneGoal = new Goal();
                    Goal sdmGoal = new Goal();   
                    Goal asmGoal = new Goal(); // Added by Radhika 
                    Goal directorGoal = new Goal(); // Added by Amit                    
                    List<Metric> metricList = new List<Metric>();
                    List<Metric> sdmMetricList = new List<Metric>(); 
                    List<Metric> asmMetricList = new List<Metric>();
                    List<Metric> directorMetricList = new List<Metric>();  
                    
                    List<Metric> manCloneMetricList = new List<Metric>();
                    cloneGoal = getGoal.Clone(false,true,true,false);               
                    Goal xspGoal = XspOrSdmGoalCreation(true, getGoal.Clone(false,true,true,false), user);                                                         
                    goalList.add(xspGoal); 
                     
                    if(user.ManagerId != null && managerIdUserObjMap.containsKey(user.ManagerId) 
                       && !superIdMetricListMap.containsKey(user.ManagerId)){                                             
                        sdmGoal = XspOrSdmGoalCreation(false, getGoal.Clone(false,true,true,false), managerIdUserObjMap.get(user.ManagerId));
                        goalList.add(sdmGoal);                              
                    }
                    //Added by Radhika: Start
                    if(user.Manager.ManagerId != null && ASMIdUserObjMap.containsKey(user.Manager.ManagerId)
                        && !ASMsuperIdMetricListMap.containsKey(user.Manager.ManagerId)){
                        asmGoal = XspOrSdmGoalCreation(false, getGoal.Clone(false,true,true,false), ASMIdUserObjMap.get(user.Manager.ManagerId));
                        goalList.add(asmGoal);                              
                    }
                    //End
                    
                    //Added by Amit: Start
                    //For Director Goal
                    if(user.Manager.Manager.ManagerId != null && directorIdUserObjMap.containsKey(user.Manager.Manager.ManagerId)
                        && !directorSuperIdMetricListMap.containsKey(user.Manager.Manager.ManagerId)){
                        directorGoal = XspOrSdmGoalCreation(false, getGoal.Clone(false,true,true,false), directorIdUserObjMap.get(user.Manager.Manager.ManagerId));
                        goalList.add(directorGoal);                              
                    }
                    //End
                    
                   
                    for(Metric metricTemp: cloneGoal.Metrics){
                        Metric newMetric = new Metric();
                        newMetric = metricTemp.Clone(false,true,true,false); 
                        
                        Metric cloneMetric = XspOrSdmMetricCreation(metricTemp.Clone(false,true,true,false), user, metricTemp.Sort_Order__c);
                        metricList.add(cloneMetric); 
                         
                        
                        if(user.ManagerId != null){                         
                            if(superIdMetricListMap.containsKey(user.ManagerId)){                               
                                for(Metric metricTempInner : superIdMetricListMap.get(user.ManagerId)){                                    
                                    if(metricTempInner.Name.equalsIgnoreCase(newMetric.Name)){                                       
                                        metricTempInner.TargetValue = metricTempInner.TargetValue!=null?metricTempInner.TargetValue+newMetric.TargetValue:newMetric.TargetValue;
                                        sdmMetricList.add(metricTempInner);                                         
                                        if(metricTempInner.Id != null){                                                    
                                            metIdUpdateList.put(metricTempInner.Id,metricTempInner);                                            
                                        }                                   
                                    }                               
                                }                           
                            }else{
                                if(managerIdUserObjMap.containsKey(user.ManagerId)){
                                    Metric sdmCloneMetric = XspOrSdmMetricCreation(metricTemp.Clone(false,true,true,false), managerIdUserObjMap.get(user.ManagerId), metricTemp.Sort_Order__c); 
                                    sdmMetricList.add(sdmCloneMetric); 
                                }                               
                            }
                        } 
                        
                        //Added by Radhika: Start
                        if(user.Manager.ManagerId != null){                         
                            if(ASMsuperIdMetricListMap.containsKey(user.Manager.ManagerId)){                               
                                for(Metric metricTempInner : ASMsuperIdMetricListMap.get(user.Manager.ManagerId)){                                   
                                    if(metricTempInner.Name.equalsIgnoreCase(newMetric.Name)){                                       
                                        metricTempInner.TargetValue = metricTempInner.TargetValue!=null?metricTempInner.TargetValue+newMetric.TargetValue:newMetric.TargetValue;
                                        asmMetricList.add(metricTempInner);                                         
                                        if(metricTempInner.Id != null){                                                    
                                            ASMmetIdUpdateList.put(metricTempInner.Id,metricTempInner);                                            
                                        }                                   
                                    }                               
                                }                           
                            }else{
                                if(ASMIdUserObjMap.containsKey(user.Manager.ManagerId)){
                                    Metric asmCloneMetric = XspOrSdmMetricCreation(metricTemp.Clone(false,true,true,false), ASMIdUserObjMap.get(user.Manager.ManagerId), metricTemp.Sort_Order__c); 
                                    asmMetricList.add(asmCloneMetric); 
                                }                               
                            }
                        } 
                        //End 

                        //Added by Amit: Start
                        //Updating Director's metrics
                        if(user.Manager.Manager.ManagerId != null){                         
                            if(directorSuperIdMetricListMap.containsKey(user.Manager.Manager.ManagerId)){                               
                                for(Metric metricTempInner : directorSuperIdMetricListMap.get(user.Manager.Manager.ManagerId)){                                   
                                    if(metricTempInner.Name.equalsIgnoreCase(newMetric.Name)){                                       
                                        metricTempInner.TargetValue = metricTempInner.TargetValue!=null?metricTempInner.TargetValue+newMetric.TargetValue:newMetric.TargetValue;
                                        directorMetricList.add(metricTempInner);                                                                            
                                        if(metricTempInner.Id != null){                                                    
                                            directorMetIdUpdateMap.put(metricTempInner.Id,metricTempInner);                                            
                                        }                                   
                                    }                               
                                }                           
                            }else{
                                if(directorIdUserObjMap.containsKey(user.Manager.Manager.ManagerId)){
                                    Metric directorCloneMetric = XspOrSdmMetricCreation(metricTemp.Clone(false,true,true,false), directorIdUserObjMap.get(user.Manager.Manager.ManagerId), metricTemp.Sort_Order__c); 
                                    directorMetricList.add(directorCloneMetric); 
                                }                               
                            }
                        } 
                        //End      
                    }

                    superIdMetricListMap.put(user.ManagerId, sdmMetricList);
                    ASMsuperIdMetricListMap.put(user.Manager.ManagerId, asmMetricList); // Added by Radhika
                    directorSuperIdMetricListMap.put(user.Manager.Manager.ManagerId,directorMetricList);// Added by Amit
                    pfileNamePetricListMap.put(user.Id,metricList);                     
                    pfileNamePetricListMap.put(user.ManagerId ,sdmMetricList);
                    pfileNamePetricListMap.put(user.Manager.ManagerId ,asmMetricList); // Added by Radhika
                    pfileNamePetricListMap.put(user.Manager.Manager.ManagerId ,directorMetricList); // Added by Amit                   
                }
            }           
      
            //Insert new Goal Record for RGU;
           
            Database.SaveResult[] insertGoals = Database.Insert(goalList,false);
            executeJob(insertGoals, jobStatus); // Added by Radhika to update job status from one method    
            
    
            List<Metric> metricInsertList = new List<Metric>();
            for(Goal goalObj : [select id, OwnerId , Name FROM Goal WHERE Id In : goalList]){                
                if(pfileNamePetricListMap.get(goalObj.OwnerId) != null){
                   List<Metric> metricInsertList1 = new List<Metric>();                   
                   for(Metric metricObj : (List<Metric>) pfileNamePetricListMap.get(goalObj.OwnerId)){
                        metricObj.GoalId = goalObj.Id;
                        metricInsertList1.add(metricObj);                     
                   }
                   metricInsertList.addAll(metricInsertList1);                    
                }             
            }
           
            //Insert new Metric record for RGU;
            Database.SaveResult[] insertMetrics = Database.Insert(metricInsertList,false); 
            executeJob(insertMetrics, jobStatus); // Added by Radhika to update job status from one method  
            
            
            /* Update existing SDM Metric During further batch execution */  
            Database.SaveResult[] updateNewMetrics = Database.Update((List<Metric>)metIdUpdateList.values(),false);            
            executeJob(updateNewMetrics, jobStatus); // Added by Radhika to update job status from one method   
            
            /* Update existing ASM Metric During further batch execution */ 
            Database.SaveResult[] updateASMNewMetrics = Database.Update((List<Metric>)ASMmetIdUpdateList.values(),false);            
            executeJob(updateASMNewMetrics, jobStatus); // Added by Radhika to update job status from one method    
           
           
            /* Update existing Director Metric During further batch execution */
            Database.SaveResult[] updateDirectorNewMetrics = Database.Update((List<Metric>)directorMetIdUpdateMap.values(),false);            
            executeJob(updateDirectorNewMetrics, jobStatus); 
           
            
            // User Story: US495623 , Sprint 8 Change, Date : 8/17/2015, Author : Pranjal Singh
            // added This code block to create activity goals as well for XFINITY Sales Professional
            //Activity goal creation
            goalList.clear();
            pfileNamePetricListMap.clear();
                for(User user:userList){                    
                    if(user.profile.name == System.Label.DSRProfileName){                       
                        userLevel = user.Level__c;            
                        userRegion = user.Region__c;
                        userRepType = user.Sales_Rep_Type__c;
                        String UserprofileName = user.profile.name; 
                        Goal goal = goalSettingMap.get((UserprofileName + userRegion + userRepType + userLevel+'Activity').trim());
                        if(goal != null){
                            Goal getGoal = templateGoalMap.get(goal.Id);
                            Goal cloneGoal = new Goal();
                            List<Metric> metricList = new List<Metric>();
                            cloneGoal = getGoal.Clone(false,true,true,false);               
                            cloneGoal.OwnerId = user.Id;  
                            cloneGoal.Status = GOAL_STATUS_PUBLISHED;
                            cloneGoal.RecordTypeId = directSalesRecordTypeId; 
                            Date d = preGoalDueDate;
                            String dateString = d.month()+'-'+d.day()+'-'+d.year();
                            cloneGoal.Name = user.Name+'-Activity-'+dateString;
                            //Put start and due date in the goal to be create                
                            cloneGoal.StartDate = preGoalStartDate;
                            cloneGoal.DueDate = preGoalDueDate;
                            cloneGoal.Level__c=user.Level__c;
                            goalList.add(cloneGoal); 
                            for(Metric metricTemp: cloneGoal.Metrics){
                                Metric newMetric = new Metric();
                                newMetric = metricTemp.Clone(false,true,true,false); 
                                newMetric.ownerId = user.Id;
                                newMetric.DueDate = preGoalDueDate;
                                newMetric.Status = METRIC_STATUS_NOTSTARTED;
                                newMetric.Sort_Order__c = metricTemp.Sort_Order__c;
                                metricList.add(newMetric); 
                            }                                         
                            pfileNamePetricListMap.put(user.Id,metricList);  
                        }              
                    }                
                }
            //Insert new Goal Record for Activity; 
            insertGoals = null;
            insertGoals = Database.Insert(goalList,false);
            executeJob(insertGoals, jobStatus); // Added by Radhika to update job status from one method    
               
            metricInsertList = new List<Metric>();
            for(Goal goalObj : [select id, OwnerId , Name FROM Goal WHERE Id In : goalList]){                
                if(pfileNamePetricListMap.get(goalObj.OwnerId) != null){
                   List<Metric> metricInsertList1 = new List<Metric>();                   
                   for(Metric metricObj : (List<Metric>) pfileNamePetricListMap.get(goalObj.OwnerId)){
                        metricObj.GoalId = goalObj.Id;
                        metricInsertList1.add(metricObj);                     
                   }                     
                   metricInsertList.addAll(metricInsertList1);                    
                }             
            }
            
            //Insert new Metric For Activity;  
            insertMetrics=null;            
            insertMetrics = Database.Insert(metricInsertList,false);
            executeJob(insertMetrics, jobStatus); // Added by Radhika to update job status from one method   
        }
        catch(Exception e) {
            if(jobStatus!=null && !jobStatus.isEmpty()){
                  Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                  String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                    
                  jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0], false);   
            }         
        }   
              
    }   

    //Execute Finish logic after execution of batch records completed
    global void finish(Database.BatchableContext BC){             
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
        if(jobStatus!=null && !jobStatus.isEmpty()){ 
            jobStatus[0].Batch_End_Time__c = Datetime.now(); 
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ; 
            Database.update(jobStatus[0],false); 
        } 
        
        //Update the current period start/due dates for current commission cycle(Both for Monthly and Biweekly)
        if(isWestDivision){
            GoalTemplateDates__c goalDatesMonthly = GoalTemplateDates__c.getInstance(MONTHLY_CS_RECORD); 
            goalDatesMonthly.Current_Period_Start_Date__c = goalDatesMonthly.Current_Period_Start_Date__c.addMonths(1);        
            goalDatesMonthly.Current_Period_Due_Date__c = goalDatesMonthly.Current_Period_Due_Date__c.addMonths(1);       
            Database.update(goalDatesMonthly, false); 
         }
         else{
            GoalTemplateDates__c goalDates = GoalTemplateDates__c.getInstance(BIWEEKLY_CS_RECORD);
            goalDates.Current_Period_Start_Date__c = goalDates.Current_Period_Start_Date__c.addDays(14);        
            goalDates.Current_Period_Due_Date__c = goalDates.Current_Period_Due_Date__c.addDays(14);        
            Database.update(goalDates, false);
         }
                    
        // Logic to set the scheduler to run every 14 days.(Other then west division)
        if(!isWestDivision){
            CreateGoalsBatchSchedule sch = new CreateGoalsBatchSchedule();
            Date dt = system.Today();
            Date newDate = dt.addDays(14);
            Integer day = newDate.day();
            Integer month = newDate.month();
            String dayHr = System.label.BiweeklyGoalsBatchHourOfDay;
            if(dayHr==null || dayHr==''){
                dayHr='3';
            }
            // Cron expression for batch schedule after 14 days.
            String expr = '0 0 ' +dayHr+ ' '+day+' '+ month +' ?';
            if(!Test.isRunningTest()){
                system.schedule('SalesSpace Coach Goal BiWeekly Job-'+datetime.now(), expr, sch);
            }
        }
        
    }
   
    //Get job status    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
           return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                   Batch_Start_Time__c, Batch_End_Time__c, Total_RGU_Activations_Processed__c, Total_RGU_Orders_Processed__c,
                   Total_RGU_ORders_Upserted_Today__c 
                   FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId]);
    }
    
    /*
    *  Create XSp or ASM Goal base on boolean pass to method
    */
    public Goal XspOrSdmGoalCreation(Boolean isXspGoal, Goal cloneGoal, User user){                                        
        cloneGoal.OwnerId = user.Id;                            
        cloneGoal.Status = GOAL_STATUS_PUBLISHED;
        cloneGoal.RecordTypeId = directSalesRecordTypeId;
        
        Date d = preGoalDueDate;
        String dateString = d.month()+'-'+d.day()+'-'+d.year();
        cloneGoal.Name=user.Name+'-RGU-'+dateString;
        //Put start and due date in the goal to be create                
        cloneGoal.StartDate = preGoalStartDate;
        cloneGoal.DueDate = preGoalDueDate;       
        if(!isXspGoal){
            cloneGoal.Level__c = null;
            cloneGoal.Sales_Rep_Type__c = null;
            cloneGoal.Profile_Name__c = user.profile.Name;
            cloneGoal.Region__c = user.Region__c;
        }
        return cloneGoal;
    }
    
    /*
    *  Create XSp or ASM Metric records
    */
    public Metric XspOrSdmMetricCreation(Metric newMetric, User user, Decimal sortOrder){ 
        newMetric.ownerId = user.Id;
        newMetric.DueDate = preGoalDueDate;
        newMetric.Status = METRIC_STATUS_NOTSTARTED;
        newMetric.Sort_Order__c = sortOrder;
        return newMetric;
    
    }
    
    public void executeJob(Database.SaveResult[] updateGoals, List<Job_Status__c> jobStatus)
    {
        if(jobStatus!=null && !jobStatus.isEmpty()){
                for(Database.SaveResult result : updateGoals) {
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
                Database.update(jobStatus[0],false);
            }   
    }
}