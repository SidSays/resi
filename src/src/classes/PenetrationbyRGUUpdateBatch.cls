/**************************************************************************************************
* Name : PenetrationbyRGUUpdateBatch
  Description : This batch class is created to update # RGU penetration value on Property 
  User Story : US1125026
  Date : 21 August 2017
  Author : Animesh Datta
***************************************************************************************************/
global class PenetrationbyRGUUpdateBatch implements Database.Batchable<sObject>, Database.Stateful {
    //Start - Declaring variables
    private static final string BATCH_JOB_NAME = System.Label.Property_RGU_Penetration_Batch_Name;
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final String NEW_VAL = System.Label.JOB_StatusNew;
    private static final String SPACE_BLANK = ' ';
    private static final String NEW_LINE = '\n\r';  
    private static final String LABEL_NAME_SPLIT = ';';
    private static final String SYSTEM_EXCEPTION = 'System Exception - ';
    private Id jobStatusId=null;
    private String query='';
    private static final Set<String> RECORDTYPEIDS= new Set<String>();
    private static final String HYPHEN_STR = ' - ';
    //End - Declaring variables
    
    /***************************************************
        Description : Constructor for batch query 
        User Story : US1125026
        Date : 21 August 2017
        Author : Animesh Datta
    ****************************************************/
    global PenetrationbyRGUUpdateBatch(String query){//passed from finish method of another batch MDUPropertySegmentationTypeAutoSetBatch
        this.query=query;
    }
    
    /******************************************************************************
        Description : Start methood of batch 
        User Story : US1125026
        Date : 21 August 2017
        Author : Animesh Datta
    ******************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext bContext) {
        //Create Job Status Object record
        Job_Status__c jobStatus = new Job_Status__c();
        jobStatus.Name = BATCH_JOB_NAME+ HYPHEN_STR + Datetime.now();
        jobStatus.Status__c = NEW_VAL;
        jobStatus.Total_Records_Processed__c = 0;
        jobStatus.Batch_Start_Time__c = Datetime.now();
        jobStatus.Batch_End_Time__c = Datetime.now();
        jobStatus.Comments__c = SPACE_BLANK;
        jobStatus.Number_Of_Fallouts__c = 0;
        insert jobStatus;//create job status record
        jobStatusId = jobStatus.Id;
        String labelName = System.Label.XfinityPropertyRecordType;//property record types     
        if(!string.IsBlank(labelName)){
            for(String str : labelName.split(LABEL_NAME_SPLIT)){
                RECORDTYPEIDS.add(Schema.SObjectType.MDU_Property__c.getRecordTypeInfosByName().get(str).getRecordTypeId());
            }
        }                                           
        return Database.getQueryLocator(query);//record in scope of batch
    }
    
    /**************************************************************************************************
        Description : Execute methood of batch 
        User Story : US1125026
        Date : 21 August 2017
        Author : Animesh Datta
    ***************************************************************************************************/
    global void execute(Database.BatchableContext bContext, LIST<MDU_Property__c> propertyList){
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        try{
            List<MDU_Property__c> propToUpdateList = new List<MDU_Property__c>();
            Map<String,Integer> voiceCountMap = new Map<String,Integer>();//map to put property and total count of voice penetration against the property
            Map<String,Integer> videoCountMap = new Map<String,Integer>();//map to put property and total count of video penetration against the property
            Map<String,Integer> xhCountMap = new Map<String,Integer>();//map to put property and total count of xfinity home penetration against the property
            Map<String,Integer> hsiCountMap = new Map<String,Integer>();//map to put property and total count of internet penetration against the property
            Integer voiceCount = null;//temporary variable used to count total voice count
            Integer videoCount = null;//temporary variable used to count total video count
            Integer xhCount = null;//temporary variable used to count total xfinity home count
            Integer hsiCount = null;//temporary variable used to count total internet count
            Boolean isCountChanged = null;//this variable is to varify if there is change in old and new value of voice,video,xh,hsi for a property
            for(Customer_Address__c addressObj : [SELECT Id,HSI_Active1__c, Video_Active1__c, 
                                                Voice_Active1__c, XH_Active1__c, Property__c 
                                                FROM Customer_Address__c 
                                                WHERE Property__c In : propertyList 
                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){//
                //reset to '0' in each iteration
                voiceCount = 0;
                videoCount = 0;
                xhCount = 0;
                hsiCount = 0;
                //populate corresponding maps
                if(addressObj.Voice_Active1__c){//is this if loop, populating voiceCountMap
                    if(!voiceCountMap.isEmpty() && voiceCountMap.containsKey(addressObj.Property__c)){//if already map has value for this property
                        voiceCount = voiceCountMap.get(addressObj.Property__c);
                    }
                    voiceCount++;
                    voiceCountMap.put(addressObj.Property__c,voiceCount);
                }
                if(addressObj.Video_Active1__c){//is this if loop, populating videoCountMap
                    if(!videoCountMap.isEmpty() && videoCountMap.containsKey(addressObj.Property__c)){//if already map has value for this property
                        videoCount = videoCountMap.get(addressObj.Property__c);
                    }
                    videoCount++;
                    videoCountMap.put(addressObj.Property__c,videoCount);
                }
                if(addressObj.XH_Active1__c){//is this if loop, populating xhCountMap
                    if(!xhCountMap.isEmpty() && xhCountMap.containsKey(addressObj.Property__c)){//if already map has value for this property
                        xhCount = xhCountMap.get(addressObj.Property__c);
                    }
                    xhCount++;
                    xhCountMap.put(addressObj.Property__c,xhCount);
                }
                if(addressObj.HSI_Active1__c){//is this if loop, populating hsiCountMap
                    if(!hsiCountMap.isEmpty() && hsiCountMap.containsKey(addressObj.Property__c)){//if already map has value for this property
                        hsiCount = hsiCountMap.get(addressObj.Property__c);
                    }
                    hsiCount++;
                    hsiCountMap.put(addressObj.Property__c,hsiCount);
                }
            }
            
            for(MDU_Property__c prop : propertyList){//iterate all property in scope of execution
                isCountChanged = false;//fisrt set it to false for each property
                if(voiceCountMap.containsKey(prop.Id)){
                    if(prop.Voice_Penetration__c != voiceCountMap.get(prop.Id)){//check if old value and new value are not same for voice
                        isCountChanged = true;//setting flag to true as there is a change in voice penetration
                        prop.Voice_Penetration__c = voiceCountMap.get(prop.Id);//update voice penetration with new value
                    }
                }
                if(videoCountMap.containsKey(prop.Id)){
                    if(prop.Video_Penetration__c != videoCountMap.get(prop.Id)){//check if old value and new value are not same for video
                        isCountChanged = true;//setting flag to true as there is a change in video penetration
                        prop.Video_Penetration__c = videoCountMap.get(prop.Id);//update video penetration with new value
                    }
                }
                if(xhCountMap.containsKey(prop.Id)){
                    if(prop.XH_Penetration__c != xhCountMap.get(prop.Id)){//check if old value and new value are not same for xfinity home
                        isCountChanged = true;//setting flag to true as there is a change in xfinity home penetration
                        prop.XH_Penetration__c = xhCountMap.get(prop.Id);//update xfinity home penetration with new value
                    }
                }
                if(hsiCountMap.containsKey(prop.Id)){
                    if(prop.HSI_Penetration__c != hsiCountMap.get(prop.Id)){//check if old value and new value are not same for internet
                        isCountChanged = true;//setting flag to true as there is a change in internet penetration
                        prop.HSI_Penetration__c = hsiCountMap.get(prop.Id);//update internet penetration with new value
                    }
                }
                if(isCountChanged){//add to list only when there is a change in any of the 4 types of penetration
                    propToUpdateList.add(prop);
                }
            }
            if(!propToUpdateList.isEmpty()){
                Database.SaveResult[] saveResult = Database.Update(propToUpdateList,false);//update properties
                if(jobStatus!=null && !jobStatus.isEmpty()){
                    for (Database.SaveResult result : saveResult) {
                        jobStatus[0].Total_Records_Processed__c ++;
                        if(!result.isSuccess()){                                                
                            for (Database.Error error : result.getErrors()) {
                                jobStatus[0].Number_Of_Fallouts__c  ++;
                                Integer len = Job_Status__c.Comments__c.getDescribe().getLength();
                                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  error.getMessage() + NEW_LINE : jobStatus[0].Comments__c + error.getMessage() + NEW_LINE;                                    
                                jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg;
                            }
                        }      
                    }
                    database.update(jobStatus[0]);//update job status record
                }
            }
        }catch(Exception exp){
            if(jobStatus!=null && !jobStatus.isEmpty()){
                Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ? SYSTEM_EXCEPTION + exp.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + exp.getMessage() + NEW_LINE;                                    
                jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg;                          
                database.update(jobStatus[0]);//update job status record
            }
        }       
    }
   
    /**************************************************************************************************
        Description : Finish methood of batch 
        User Story : US1125026
        Date : 21 August 2017
        Author : Animesh Datta
    ***************************************************************************************************/
    global void finish(Database.BatchableContext bContext){
        //Add Job Status       
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
        if(jobStatus!=null && !jobStatus.isEmpty()){
            jobStatus[0].Batch_End_Time__c = Datetime.now();
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ;   
            database.update (jobStatus[0]);//update job status record
        }        
    }
    
    /**************************************************************************************************
        Description : Get job status 
        User Story : US1125026
        Date : 21 August 2017
        Author : Animesh Datta
    ***************************************************************************************************/
    private List<Job_Status__c> getJobStatus(Id jobStatusId) {
        return [SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                Batch_Start_Time__c, Batch_End_Time__c
                 FROM Job_Status__c WHERE Status__c =: NEW_VAL AND ID=: jobStatusId LIMIT 1];
    } 

}