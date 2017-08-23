/**************************************************************************************************
* Name : IndirectRGUMetricUpdateManagerBatch
* Description : This batch class created to update RGU metrics Target and Actuals in daily basis for Indirect channel
* User Story : US1024564(ndirect - Coach for Indirect - Retail Sales Manager - RGU Goal - Metric Targets and Actuals)
* Date : 17 April 2017
* Author : Amit Kumar Pradhan
***************************************************************************************************/

global class IndirectRGUMetricUpdateManagerBatch implements Database.Batchable<sObject>, Database.Stateful{
    private static final List<String> MGR_PROFILE_NAME = new List<String>{System.Label.Retail_Sales_Manager_ProfileName};
    private static final String BATCH_JOB_NAME = 'IndirectRGUMetricUpdateManagerBatch';
    private static final String JOB_NAME_SPACE  = ' - ';
    private static final String NEW_SATAUS = 'New';
    private static final String SPACE_BLANK = '';
    private static final String ONTRACK_STATUS = 'OnTrack';
    private static final String BEHIND_STATUS = 'Behind';
    private static final String CRITICAL_STATUS = 'Critical'; 
    private String queryString = SPACE_BLANK;
    private Id jobstatusId = null;
    private RGU_Goal_Target_Actual__c targetActualCS;
    private Date beginPayrollPeriod;
    private Date endPayrollPeriod;
    
    /*********************************
     * Constructor for batch class IndirectRGUMetricUpdateManagerBatch with query as argument.
     * Pass the query while executing the batch in the below manner otherwise batch will not execute.
     * Sample query :- 'SELECT Id, Name, ManagerId, Profile.name FROM User WHERE IsActive = True 
                            AND Profile.name IN: MGR_PROFILE_NAME AND UserPermissionsWorkDotComUserFeature = true'
    **********************************/
    
    global IndirectRGUMetricUpdateManagerBatch(String queryString){
        this.queryString = queryString;
    }
    
    /*********************************
     * Overriding start method of Database.Batchable interface
     * Creating job status record inside start method
     * Fetching RGU_Goal_Target_Actual__c custom setting record for payroll start date and end date
    **********************************/
    global Database.QueryLocator start(Database.BatchableContext bContext){
        //Create Job Status Object
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME + JOB_NAME_SPACE + Datetime.now();
        jobStatus.Status__c = NEW_SATAUS;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = SPACE_BLANK;
        jobStatus.Number_Of_Fallouts__c = 0;
        insert jobStatus;
        jobStatusId = jobStatus.Id;
        
        //Get Custom Settings Data for Indirect Channel
        targetActualCS = RGU_Goal_Target_Actual__c.getInstance(Indirect_Constants.CUSTOMSET_INDIRECT );
        if(targetActualCS != null){
            beginPayrollPeriod = targetActualCS.Payroll_Start_Date__c;//payroll start date
            endPayrollPeriod = targetActualCS.Payroll_End_Date__c;//payroll end date
        }
        
        return Database.getQueryLocator(queryString);
    }
    
    /*********************************
     * Overriding execute method of Database.Batchable interface
     * Added business logic for calculating metric Target and Actuals of Retail Sales Manager from Retail Sales Rep metric
    **********************************/
    global void execute(Database.BatchableContext bContext, List<User> userList){
        List<Job_Status__c> jobStatus;
        Map<String, String> repUserIdVsMgrIdMap = new Map<String, String>();
        Map<String, Decimal> mgrIdVsTargetTotalMap = new Map<String, Decimal>();
        Map<String, Decimal> mgrIdVsCurrentTotalMap = new Map<String, Decimal>();
        List<Metric> metricToUpdateList = new List<Metric>();
        try{
            jobStatus = getJobStatus(jobStatusId); //Calling getJobStatus method for current job status for every execution
            //Fetching all Rep User records using the scopelist(manager list)
            for(User userObj : [SELECT Id, managerId, Name FROM User WHERE managerId IN: userList 
                                    AND Profile.Name =: System.Label.Retail_Sales_Rep_ProfileName
                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                repUserIdVsMgrIdMap.put(userObj.Id,userObj.managerId);//Putting all rep id and manager id
            }
           
            if(repUserIdVsMgrIdMap != null && !repUserIdVsMgrIdMap.isEmpty()){
                
                //Fetching Retail Sales Rep Metrics and Calculating total Target and Current Value for Retail Sales Manager
                for(Goal goalObj : [SELECT Id, Name, OwnerId, (SELECT Id, Name, Status, TargetValue, CurrentValue, DueDate FROM Metrics) FROM Goal 
                                        WHERE RecordtypeId =: Indirect_Constants.INDIRECT_RECORD_TYPE_ID 
                                        AND StartDate =: beginPayrollPeriod AND DueDate =: endPayrollPeriod 
                                        AND OwnerId IN: repUserIdVsMgrIdMap.keySet() AND Template_Type__c =: Indirect_Constants.RGU_STRING 
                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                               
                    if(repUserIdVsMgrIdMap != null && !repUserIdVsMgrIdMap.isEmpty() && repUserIdVsMgrIdMap.get(goalObj.OwnerId) != null){
                        if(goalObj.Metrics != null){
                            for(Metric metricObj : goalObj.Metrics){
                                //Creating key as a combination of manager Id(fetching from repUserIdVsMgrIdMap) and metric Name
                                String mgrIdANDMetricName = repUserIdVsMgrIdMap.get(goalObj.OwnerId) + metricObj.Name;
                                
                                //Total Target calculation per Retail Sales Manager
                                if(metricObj.TargetValue != null){
                                    Decimal tempTargetTotal = 0.00;                                 
                                    if(mgrIdVsTargetTotalMap.get(mgrIdANDMetricName) != null){
                                        tempTargetTotal = mgrIdVsTargetTotalMap.get(mgrIdANDMetricName);//Fetching privious Target value for same manager and same metric
                                    }
                                
                                    tempTargetTotal += metricObj.TargetValue;//Add current Target to privious Target(if exists)
                                    mgrIdVsTargetTotalMap.put(mgrIdANDMetricName,tempTargetTotal);//Putting key(manager + metric Name) and updated target value
                                }
                                
                                //Total Actuals calculation per Retail Sales Manager
                                if(metricObj.CurrentValue != null){
                                    Decimal tempCurrentTotal = 0.00;
                                    if(mgrIdVsCurrentTotalMap.get(mgrIdANDMetricName) != null){
                                        tempCurrentTotal = mgrIdVsCurrentTotalMap.get(mgrIdANDMetricName);//Fetching privious Actuals value for same manager and same metric
                                    }
                                
                                    tempCurrentTotal += metricObj.CurrentValue;//Add current Target to privious Actuals(if exists)
                                    mgrIdVsCurrentTotalMap.put(mgrIdANDMetricName,tempCurrentTotal);//Putting key(manager + metric Name) and updated Actuals value
                                }   
                            }
                        }   
                    }   
                } 
                
                //Fetch and Update metrics for Retail Sales Manager
                for(Goal goalObj : [SELECT Id, Name, OwnerId, (SELECT Id, OwnerId, Name, Status, TargetValue, CurrentValue, DueDate FROM Metrics) FROM Goal 
                                        WHERE RecordtypeId =: Indirect_Constants.INDIRECT_RECORD_TYPE_ID 
                                        AND StartDate =: beginPayrollPeriod AND DueDate =: endPayrollPeriod 
                                        AND OwnerId IN: userList AND Template_Type__c =: Indirect_Constants.RGU_STRING 
                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    
                    if(goalObj.Metrics != null){
                        for(Metric metricObj : goalObj.Metrics){
                            //Creating key as a combination of owner Id and metric Name
                            String mgrIdANDMetricName = goalObj.OwnerId + metricObj.Name;
                            boolean isValueChange = false;//Boolean flag to check metric records has changed or not(Default as false)
                            
                            //Updating Target Value
                            if(mgrIdVsTargetTotalMap != null && !mgrIdVsTargetTotalMap.isEmpty() 
                                                             && mgrIdVsTargetTotalMap.get(mgrIdANDMetricName) != null){
                                                                 
                                //Check Target Value has changed OR not(If Yes mark isValueChange = true)
                                if(metricObj.TargetValue != mgrIdVsTargetTotalMap.get(mgrIdANDMetricName)){
                                    metricObj.TargetValue = mgrIdVsTargetTotalMap.get(mgrIdANDMetricName);
                                    isValueChange = true;//change the boolean flag to true
                                }
                            }
                            
                            //Updating Current Value
                            if(mgrIdVsCurrentTotalMap != null && !mgrIdVsCurrentTotalMap.isEmpty() 
                                                             && mgrIdVsCurrentTotalMap.get(mgrIdANDMetricName) != null){
                                                                 
                                //Check Current Value has changed OR not(If Yes mark isValueChange = true)
                                if(metricObj.CurrentValue != mgrIdVsCurrentTotalMap.get(mgrIdANDMetricName)){
                                    metricObj.CurrentValue = mgrIdVsCurrentTotalMap.get(mgrIdANDMetricName);
                                    isValueChange = true;//change the boolean flag to true
                                }
                            }
                            Metric updatedMetric = updateStatus(metricObj);//Calling updateStatus method for updating metric status(color coding)
                            //Check Status has changed OR not(If Yes mark isValueChange = true)                         
                            if(metricObj.Status != updatedMetric.Status){
                                isValueChange = true;//change the boolean flag to true
                            }
                            
                            //If metric record has changed then only add into "metricToUpdateList" list
                            if(isValueChange){
                                metricToUpdateList.add(updatedMetric);
                            }   
                        }
                    }
                                            
                }
                //Updating the metrics of Retail Sales Manager
                if(metricToUpdateList != null && !metricToUpdateList.isEmpty()){
                    Database.SaveResult[] updateMetrics = Database.update(metricToUpdateList,false);
                    //Calling executeJob method to update job status record
                    executeJob(updateMetrics, jobStatus);    
                }
            }            
        }catch(Exception e){
            //Update job status record if any exception occured during the excution
            if(jobStatus !=null && !jobStatus.isEmpty()){
                Integer len = Job_Status__c.Comments__c.getDescribe().getLength();
                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  Indirect_Constants.SYSTEM_EXCEPTION + e.getMessage() + Indirect_Constants.NEW_LINE : jobStatus[0].Comments__c + Indirect_Constants.SYSTEM_EXCEPTION + e.getMessage() +Indirect_Constants.NEW_LINE;                                    
                jobStatus[0].Comments__c = (tempMsg.length() > len) ? tempMsg.substring(0, len) : tempMsg; 
                Database.update(jobStatus[0],false);   
            }     
        }
    }
   
    /*********************************
     * Overriding finish method of Database.Batchable interface
     * Updating current job status with propper status(Completed with/without error)
     * Updating "RGU_Goal_Target_Actual__c" custom setting record if today date equal to sum of endPayrollPeriod and lagDays
    **********************************/
    global void finish(Database.BatchableContext bContext){                   
        try{            
            List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);//Calling getJobStatus method for current job status and update with propper status(Completed with/without error)
            if(jobStatus != null && !jobStatus.isEmpty()){ 
                jobStatus[0].Batch_End_Time__c = Datetime.now(); 
                jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? Indirect_Constants.BATCH_COMPLETE_WITH_SUCCESS : Indirect_Constants.BATCH_COMPLETE_WITH_FAIL ; 
                Database.update(jobStatus[0],false); 
            }

            //Update start date and end date in custom settings on last day that is not fixed as of now. Say if end date is 22nd and data has 2 days lag, on 24th custom settings date will be updated
            if(targetActualCS != null){
                Integer lagDays = Integer.valueOf(targetActualCS.Lagging_Days__c);            
                if(Date.today() == endPayrollPeriod.addDays(lagDays)){
                    targetActualCS.Payroll_Start_Date__c = targetActualCS.Payroll_Start_Date__c.addMonths(1);
                    targetActualCS.Payroll_End_Date__c = targetActualCS.Payroll_End_Date__c.addMonths(1);
                    Database.update(targetActualCS,false);
                }
            }   
        }  
        catch(Exception e){
            System.debug('Exception : '+e.getMessage());
        }       
    }
    
    /***********************
    * @Description: This method return job status 
    * @Author: Amit Kumar Pradhan, Accenture
    * @Date: 17-April-2017
    * @Param: Id
    * @Return: List<Job_Status__c>
    ***********************/ 
    
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {        
        return ([SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, Batch_Start_Time__c, Batch_End_Time__c 
                    FROM Job_Status__c WHERE Status__c =: Indirect_Constants.JOB_STATUS_NEW AND ID =: jobStatusId]);        
    }
    
    /***********************
    * @Description: This method update job current status record 
    * @Author: Amit Kumar Pradhan, Accenture
    * @Date: 17-April-2017
    * @Param: Database.SaveResult[],List<Job_Status__c>
    * @Return: void
    ***********************/
    
    public void executeJob(Database.SaveResult[] updateMetrics, List<Job_Status__c> jobStatus)
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
            Database.update(jobStatus[0],false);
        }            
    }
    
    /***********************
    * @Description: This method update Metric status as per the currentValue, targetValue and remaining days.
    * @Author: Amit Kumar Pradhan, Accenture
    * @Date: 17-April-2017
    * @Param: Metric
    * @Return: Metric
    ***********************/
    
    private static Metric updateStatus(Metric metricObj){       
        Integer remainingDays = metricObj.DueDate != null ? System.today().daysBetween(metricObj.DueDate) : 0;//Calculating remaining days from today to Due date
        Decimal progessPercVal = 0;                     
        if(metricObj.targetvalue != null && metricObj.targetvalue > 0 && metricObj.currentvalue != null){
            progessPercVal = (metricObj.currentValue*100)/metricObj.targetvalue;  
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