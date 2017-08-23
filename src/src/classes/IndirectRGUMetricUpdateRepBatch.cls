/**************************************************************************************************
* Name : IndirectRGUMetricUpdateRepBatch
* Description : This batch class created to update RGU metrics Target and Actuals in daily basis for Retail Sales Rep in Indirect Channel
* User Story : US1024537(Indirect - Coach for Indirect - Retail Sales Rep - RGU Goal - Metric Targets and Actuals)
* Date : 19 April 2017
* Author : Animesh Datta
***************************************************************************************************/

global class IndirectRGUMetricUpdateRepBatch implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts{//adding Database.AllowsCallouts to overcome limitation
    private static final String BATCH_JOB_NAME = 'IndirectRGUMetricUpdateRepBatch';
    private static final String JOB_NAME_SPACE  = ' - ';
    private static final String NEW_SATAUS = 'New';
    private static final String SPACE_BLANK  = '';
    private static final List<String> PROFILE_NAME_LIST_REP = new List<String>{System.Label.Retail_Sales_Rep_ProfileName};
    private static final String ONTRACK_STATUS = 'OnTrack';
    private static final String BEHIND_STATUS = 'Behind';
    private static final String CRITICAL_STATUS = 'Critical';  
    public Map<String,Metric> keyVsRGUMetric = new Map<String,Metric>();
    private Date beginPayrollPeriod;
    private Date endPayrollPeriod;
    private String queryString = '';
    private Id jobstatusId = null;
    //Constructor, call from Scheduler
    global IndirectRGUMetricUpdateRepBatch(String queryString){//List of users
        this.queryString = queryString;
    }
    
    //Start Method
    //Query: Select Id, Name, ManagerId,Profile.name,Region__c,PERNR__c from User where IsActive = True AND Profile.Name IN: PROFILE_NAME_LIST_REP and UserPermissionsWorkDotComUserFeature = true
    global Database.QueryLocator start(Database.BatchableContext bContext){//Generate queryLocator. List of reltail sales rep
        //Create Job Status Object
        //Populate neccessary fields in Job Status
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME + JOB_NAME_SPACE + Datetime.now();
        jobStatus.Status__c = NEW_SATAUS;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = SPACE_BLANK;
        jobStatus.Number_Of_Fallouts__c = 0;
        //Initialize before fetching data
        MetricsPerformanceData mPD = new MetricsPerformanceData();
        //Get Custom Settings Data for Indirect Channel
        //will be passed as parameters
        RGU_Goal_Target_Actual__c targetActualCS = RGU_Goal_Target_Actual__c.getInstance(Indirect_Constants.CUSTOMSET_INDIRECT);//add in label
        if(targetActualCS != null){
            beginPayrollPeriod = targetActualCS.Payroll_Start_Date__c;//payroll start date
            endPayrollPeriod = targetActualCS.Payroll_End_Date__c;//payroll end date
            String salesChannel = targetActualCS.Name;//Channel name - Indirect
            Integer saqlOffset = Integer.valueOf(targetActualCS.Offset__c);//Offset value
            Integer saqlLimit = Integer.valueOf(targetActualCS.SAQL_Limit__c);//Limit of SAQL query
            //Save wave data into map keyVsRGUMetric
            try{
                keyVsRGUMetric = mPD.getRGUPerformanceData(salesChannel, beginPayrollPeriod, endPayrollPeriod, saqlOffset, saqlLimit);
            }catch(Exception ex){
                System.debug('Exception: '+ex.getMessage());}
        }
        //create job status record. To overcome limitation inserting record after call out
        //insert jobStatus;
        Database.insert(jobStatus,false);
        jobStatusId = jobStatus.Id;     
        //pass userlist to execute method
        return Database.getQueryLocator(queryString);
    }
    
    //Execute Method
    //userlist will have list of active users who has work.com access and profile = Retail Sales Rep
    //Fetch user's current RGU metrics and update them with Wave data
    global void execute(Database.BatchableContext bContext, List<User> userList){
        List<Job_Status__c> jobStatus;
        List<Metric> metricToUpdateList = new List<Metric>();//populate this metric list and update at the end of execute method
        Map<String,List<Metric>> ownerIdVsMetricListMap = new Map<String,List<Metric>>();//Map of Goal/Metric. Owner Id Vs List of RGU Metric against that User
        try{
            if(!keyVsRGUMetric.isEmpty()){//enter only list is not empty
                jobStatus = getJobStatus(jobStatusId);
                //Fetch Goal
                //Get Indirect RGU Metrics for current fiscal month based on payroll start end date in custom setings 
                if(!userList.isEmpty() && beginPayrollPeriod != null && endPayrollPeriod != null){
                    for(Goal goalObj : [SELECT Id, Name, DueDate, StartDate, Status, OwnerId,Region__c, Profile_Name__c, Template_Type__c, 
                                        (SELECT Id, Name, RGU_Actual_Update_Date__c, CurrentValue, DueDate, StartDate, TargetValue, Exception__c,
                                                ExternalId__c, Status FROM Metrics) FROM Goal
                                        WHERE OwnerId IN : userList AND RecordTypeId =: Indirect_Constants.INDIRECT_RECORD_TYPE_ID 
                                        AND Status =: Indirect_Constants.GOAL_STATUS_PUBLISHED
                                        AND Template_Type__c =: Indirect_Constants.RGU_STRING AND StartDate = : beginPayrollPeriod 
                                        AND DueDate = : endPayrollPeriod LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                            
                        if(goalObj.Metrics != null && !goalObj.Metrics.isEmpty()){
                            ownerIdVsMetricListMap.put(goalObj.OwnerId,goalObj.Metrics); //put rep id and their metric list  
                        }
                    }
                }               
                //iterate list of users in scope
                for(User userObj : userList){
                    if(userObj.PERNR__c != null){
                        if(ownerIdVsMetricListMap != null && !ownerIdVsMetricListMap.isEmpty() && ownerIdVsMetricListMap.containsKey(userObj.Id)){
                            for(Metric metricObj : ownerIdVsMetricListMap.get(userObj.Id)){
                                boolean isValueChanged = false;//when there is a change then only set flag to true. initial value = false
                                String pernrMetricNameKey = userObj.PERNR__c + String.valueOf(endPayrollPeriod).remove('-') + metricObj.Name;//key of Pernr number, payroll end date and metric name coming from Wave data set
                                Metric metricDataFromWave = keyVsRGUMetric.get(pernrMetricNameKey);//get data from keyVsRGUMetric map
                                if(metricDataFromWave != null){
                                    //Metric already has minimum target as 1 at the time of creation. target cannot be less than 1
                                    if(metricDataFromWave.TargetValue != null && metricDataFromWave.TargetValue > 1){
                                        if(metricObj.TargetValue != metricDataFromWave.TargetValue){//update if value has changed
                                            metricObj.TargetValue = metricDataFromWave.TargetValue;//if target is greater than 1 then only update metric as target must be >=1
                                            isValueChanged = true;//when there is change set flag to true
                                        }
                                    }
                                    if(metricDataFromWave.CurrentValue != null && metricDataFromWave.CurrentValue > 0){//update only if current value is greater than zero
                                        if(metricObj.CurrentValue != metricDataFromWave.CurrentValue){//update if value has changed
                                            metricObj.CurrentValue = metricDataFromWave.CurrentValue;
                                            isValueChanged = true;//when there is change set flag to true
                                        }
                                    }
                                    if(metricObj.Exception__c != metricDataFromWave.Exception__c || metricObj.ExternalId__c != metricDataFromWave.ExternalId__c){
                                        //update exception field on metric
                                        metricObj.Exception__c = metricDataFromWave.Exception__c;
                                        //update external id
                                        metricObj.ExternalId__c = metricDataFromWave.ExternalId__c;
                                        isValueChanged = true;//when there is a change set flag to true
                                    }
                                    
                                    Metric finalUpdateMetric = updateMetricStatus(metricObj);//call method updateMetricStatus for color coding logic
                                    //if status is changed then only update metric
                                    if(finalUpdateMetric.Status != metricObj.Status){
                                        isValueChanged = true;//when there is a change set flag to true
                                    }
                                    
                                    if(isValueChanged){//update only if value has changed
                                        finalUpdateMetric.RGU_Actual_Update_Date__c = metricDataFromWave.RGU_Actual_Update_Date__c;//if there is any change in current value,target value, exception, external id field then only update this field
                                        metricToUpdateList.add(finalUpdateMetric);
                                    }
                                }
                            }
                        }
                    }
                }
                
                //Update Metric List
                if(metricToUpdateList != null && !metricToUpdateList.isEmpty()){
                    Database.saveResult[] srResult = Database.update(metricToUpdateList,false);
                    executeJob(srResult,jobStatus);//update job status record
                }
            }              
        }catch(Exception e){
            if(jobStatus !=null && !jobStatus.isEmpty()){//update job status if any failure
                Integer len = Job_Status__c.Comments__c.getDescribe().getLength();
                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  Indirect_Constants.SYSTEM_EXCEPTION + e.getMessage() + Indirect_Constants.NEW_LINE : jobStatus[0].Comments__c + Indirect_Constants.SYSTEM_EXCEPTION + e.getMessage() +Indirect_Constants.NEW_LINE;                                    
                jobStatus[0].Comments__c = (tempMsg.length() > len) ? tempMsg.substring(0, len) : tempMsg; 
                Database.update(jobStatus[0],false);   
            }     
        }
    }  
    
    //Finish Method
    //Call another batch from finish method. 2nd batch is for target and actual update for manager
    global void finish(Database.BatchableContext bContext){                   
        try{
            //update job status
            List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
            if(jobStatus != null && !jobStatus.isEmpty()){ 
                jobStatus[0].Batch_End_Time__c = Datetime.now(); 
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? Indirect_Constants.BATCH_COMPLETE_WITH_SUCCESS : Indirect_Constants.BATCH_COMPLETE_WITH_FAIL ; 
                Database.update(jobStatus[0],false); 
            }   
            
            /****
            * Calling IndirectRGUMetricUpdateManagerBatch 
            * The query string passed while batch is executed.
            * 'SELECT Id, Name, ManagerId, Profile.name FROM User WHERE IsActive = True AND Profile.name IN: MGR_PROFILE_NAME AND UserPermissionsWorkDotComUserFeature = true'
            *****/
            String queryString = '';
            if(System.Label.IndirectRGUMetricUpdateManagerBatchQuery != null){
                queryString = System.Label.IndirectRGUMetricUpdateManagerBatchQuery;
            }              
            Integer batchSize = 200;
            if(System.Label.IndirectRGUMetricUpdateManagerBatchSize != null && System.Label.IndirectRGUMetricUpdateManagerBatchSize.isNumeric()){
                batchSize = Integer.valueOf(System.Label.IndirectRGUMetricUpdateManagerBatchSize);
            }       
            if(!Test.isRunningTest()){ 
                database.executebatch(new IndirectRGUMetricUpdateManagerBatch(queryString), batchSize);
            }
        }  
        catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }       
    }
    
    //Get job status    
    private List<Job_Status__c> getJobStatus(Id jobStatusId) { //get job status record by passing jobstatus id       
        return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, Batch_Start_Time__c, Batch_End_Time__c 
                    FROM Job_Status__c WHERE Status__c =: Indirect_Constants.JOB_STATUS_NEW AND ID =: jobStatusId]);        
    }
    
    //update jobstatus
    private void executeJob(Database.SaveResult[] updateMetrics, List<Job_Status__c> jobStatus)
    {        
        if(jobStatus!=null && !jobStatus.isEmpty()){
            for(Database.SaveResult result : updateMetrics) {
                jobStatus[0].Total_Records_Processed__c ++;
                if(!result.isSuccess()){                                                 
                    for(Database.Error error : result.getErrors()){
                        jobStatus[0].Number_Of_Fallouts__c ++;
                        Integer len = Job_Status__c.Comments__c.getDescribe().getLength();
                        String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + Indirect_Constants.NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + Indirect_Constants.NEW_LINE;                                    
                        jobStatus[0].Comments__c = (tempMsg.length()>len)?tempMsg.substring(0,len):tempMsg;                                                                 
                     }
                }       
            }
            Database.update(jobStatus[0],false);//job status update
        }            
    }
    
    /************
    * @Description: This method update Metric status as per the currentValue, targetValue and remaining days.
    * @Author: Animesh Datta
    * @Date: 21-April-2017
    * @Param: Metric
    * @Return: Metric
    **************/
    private static Metric updateMetricStatus(Metric metricObj){
        Decimal progessPercVal = 0;
        Integer remainingDays = metricObj.DueDate !=null ? System.today().daysBetween(metricObj.DueDate) : 0;//get remaining days. days between due date and today    
        if(metricObj.targetvalue != null && metricObj.targetvalue > 0 && metricObj.currentvalue != null){
            progessPercVal = (metricObj.currentValue*100)/metricObj.targetvalue; //calculate percentage of progress
        }       
        if(progessPercVal<=25){
            metricObj.Status=remainingDays >=20?BEHIND_STATUS:CRITICAL_STATUS;                                  
        }else if(25<progessPercVal && progessPercVal<=75){
            if(remainingDays >=20){
                metricObj.Status = ONTRACK_STATUS;               
            }else{
                 metricObj.Status=remainingDays >=10 && remainingDays<20?BEHIND_STATUS:CRITICAL_STATUS;                 
            }                          
        }else if(75<progessPercVal && progessPercVal<100){
            metricObj.Status = remainingDays >=10?ONTRACK_STATUS:BEHIND_STATUS;           
        }else {
            metricObj.Status = ONTRACK_STATUS;          
        }
        return metricObj;
    }
    
}