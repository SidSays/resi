/**************************************************************************************************
Name : CreateFeedbackDataBatch
Description : This batch class created for creation of Feedback Data for all observation forms.
User Story : US913657: OMNI - Coach - Automate Coach Forms  
Date : 12 Jan 2017
Author : Tejaswini Kasar
Last Modified Date : 02-March - 2017
Last Modified By : Animesh Datta
Last Modified Description : Added QuestionSet for Field Observation
Last Modified Date : 24-April - 2017
Last Modified By : Shalaka Kadwade
Last Modified Description : Updated category names as part of "US1026699: Indirect - Edits to Coach for Indirect - Observation Questions - Help Text"
Last Modified By : Malay Desai, 11-Aug-2017
Last Modified Description : Added code to created new Perf cycle, QuestionSet and Question for Retail Store Manager - US1159268
***************************************************************************************************/
global class CreateFeedbackDataBatch implements Database.Batchable<sObject>, Database.Stateful{
    /*
    * Data Member 
    */
    private static final String BATCH_COMPLETE_WITH_SUCCESS = 'Completed Without Errors';
    private static final String BATCH_COMPLETE_WITH_FAIL = 'Completed With Errors';
    private static final string BATCH_JOB_NAME = 'CreateFeedbackDataBatch';
    private static final string JOB_STATUS = 'New';
    private static final string NEW_LINE = '\n';
    private static final string SYSTEM_EXCEPTION = 'System Exception - ';    
    private static final string RECORD_TYPE_SEPERATION = ';';
    private static final string JOB_COMMENT = ' '; 
    private static final string JOB_NAME_SPACE =  ' - ';        
    private String observationFormName='';
    private String formName='';
    private String staticResourceName='';
    private Integer nbrOfWeeks = 0;
    private Id jobStatusId = null; 
    private FeedbackData__c feedbackData;  
    private Date startDate;
    private static final string XSP_WALKALONG =  'XSP Walkalong'; 
    private static final string CAR_EVENT_WALKALONG =  'CAR EVENT Walkalong'; 
    private static final string PROPERTY_VISIT_WALKALONG =  'Property Visit Walkalong'; 
    
    //Constructor
    global CreateFeedbackDataBatch(String form){       
        observationFormName = form;
    }
    //Start
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
        
     
        feedbackData = FeedbackData__c.getInstance(observationFormName);
        formName = feedbackData.Form_Name__c;
        nbrOfWeeks = integer.valueOf(feedbackData.No_of_Weeks__c);
        staticResourceName = feedbackData.Static_Resource_Name__c;
        startDate = feedbackData.Start_Date__c;
      
        String query='SELECT Id, Name FROM User WHERE isActive = True AND Profile.Name = \'System Administrator\' and UserPermissionsWorkDotComUserFeature = true LIMIT 1';
        return Database.getQueryLocator(query);
    }
    //Execute
    global void execute(Database.BatchableContext BC, List<User> userList){ 
    List<Job_Status__c> jobStatus = getJobStatus(jobStatusId);
    final String SETUP = 'Setup', WEEK = ' - Week ', CYCLE_MANAGER = 'CycleManager', STARTS = 'Starts';
    final String OVERALL_NOTES = 'Overall Notes', ACTION_ITEMS = 'Action Items', CONTACTS = 'Contacts';
    final String FREE_TEXT = 'FreeText', COMMON = 'Common',KNOCKS_OBSERVED='Knocks observed';
    final String PERF_CYCLE = 'WorkPerformanceCycle',AREA_OF_FOCUS='Area of Focus',MULTI_CHOICE = 'MultipleChoice';
    final String OBSERVATION_COUNT='Observation Counts', OBSERVATIONS = 'Observations',NOTES=' - Notes';
    final String CHOICE_XSP_RIDEALONG = 'Prepare - Energy\nEngage\nDiscover\nPosition\nClose - Start';
    final String CHOICE_CAR_EVENT='Prep or Engage at Events\nDiscover at Events\nPositioning at Events\nEvent Activations\nAll the Above';
    final String CHOICE_PROPERY_VISIT='Prep or Energy\nEngage with Property Staff\nClose with Property Staff\nAll the Above';
    // Start: US1026699 - commented below line and added new with updated category names.
    //final String CHOICE_INDIRECT_OBSERVATION='Preparation\nSoft Skills\nBranding\nTraining\nTechnology Usage';
    final String CHOICE_INDIRECT_OBSERVATION='Prepare\nEngage\nDiscover\nTraining';
    // End: US1026699
    final String CHOICE_SC_1_1_OBSERVATION='Prep and Messaging\nFeedback Delivery\nUses Multiple Techniques\nSMART Action Plans';
    final String CHOICE_HUDDEL_OBSERVATION='Huddle Preparation\nDuring Huddle\nHuddle Structure\nHuddle Conclusion';
    final String CHOICE_FIELD_OBSERVATION = 'Preparation\nOn-the-Spot Coaching\nInterjects with Purpose\nObservation Debrief';

        try{
            RecordType recType = [SELECT Id,Name FROM RecordType WHERE SObjectType=:PERF_CYCLE AND Name =: formName];        
            List<observationController.Category> categories;
            
            if(staticResourceName != null) {            
                StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name =: staticResourceName  LIMIT 1];
                String jsonStr = sr.Body.toString();
                categories = (List<observationController.Category>)JSON.deserialize(jsonStr,List<observationController.Category>.class);
            }
            
            Date endDate = startDate.addDays(6);

            List<WorkFeedbackQuestion> wfqList = new List<WorkFeedbackQuestion>();
            List<Id> wfqSetIdList = new List<Id>();

            for(Integer nbr=0;nbr<nbrOfWeeks;nbr++){
                WorkPerformanceCycle wpc=new WorkPerformanceCycle();
                wpc.State=SETUP;

                //Naming convention : <Year> <Week Number>
                wpc.Name=startDate.year()+WEEK+(Datetime.newInstance(
                                            startDate.year(),
                                            startDate.month(),
                                            startDate.day())).format('w');
                wpc.ActivityFrom=startDate;
                wpc.ActivityTo=endDate;
                wpc.RecordTypeId=recType.Id;
                insert wpc;
                Integer questionNbr = 1;

                WorkFeedbackQuestionSet wfqset= new WorkFeedbackQuestionSet();
                if(formName.equals(Label.XSP_Ridealong)) {
                    wfqset.Name=XSP_WALKALONG;
                }
                else if(formName.equals(Label.CAR_Event)) {
                    wfqset.Name=CAR_EVENT_WALKALONG;
                }
                else if(formName.equals(Label.Property_Visit)) {
                    wfqset.Name=PROPERTY_VISIT_WALKALONG;
                }
                else if(formName.equals(Label.Indirect_Observation)) {
                    wfqset.Name=Label.Indirect_Observation;
                }
                else if(formName.equals(Label.CAR_Super_Coach_1_1_Observation)) {
                    wfqset.Name=Label.CAR_Super_Coach_1_1_Observation;
                }
                else if(formName.equals(Label.CAR_Manager_Huddle_Observation)) {
                    wfqset.Name=Label.CAR_Manager_Huddle_Observation;
                }
                else if(formName.equals(Label.Field_Observation)) { //added for field observation
                    wfqset.Name=Label.Field_Observation;
                }
                else if(formName.equals(Label.Retail_Manager_Observation)) { //added for US1159268
                    wfqset.Name=Label.Retail_Manager_Observation;
                }
                wfqset.FeedbackType=CYCLE_MANAGER;
                wfqset.PerformanceCycleId=wpc.Id;
                wfqset.DueDate=Date.newInstance(startDate.year(),12,31);
                insert wfqset;

                //Add to master id list
                wfqSetIdList.add(wfqSet.Id);

                WorkFeedbackQuestion wfq;
                
                //if(!formName.equals(Label.CAR_Super_Coach_1_1_Observation)){
                wfq=new WorkFeedbackQuestion();
                if(!formName.equals(Label.Indirect_Observation)){
                    wfq.Name=OVERALL_NOTES;
                    wfq.Text=OVERALL_NOTES;
                }
                else{
                    wfq.Name=ACTION_ITEMS;
                    wfq.Text=ACTION_ITEMS;
                }
                
                //Overall notes is optional for Retail Manager Observation(added for US1159268)
                if(formName.equals(Label.Retail_Manager_Observation)){
                    wfq.IsOptional=true;
                }else{
                    wfq.IsOptional=false;
                }
                
                wfq.Number=questionNbr++;
                wfq.QuestionSetId=wfqset.Id;
                wfq.Type=FREE_TEXT;
                wfq.Section__c = COMMON;
                wfqList.add(wfq);

                
                if(!formName.equals(Label.Retail_Manager_Observation)){
                    wfq=new WorkFeedbackQuestion();
                    wfq.Name=AREA_OF_FOCUS;
                    wfq.Text=AREA_OF_FOCUS;
                    wfq.Number=questionNbr++;
                    if(formName.equals(Label.XSP_Ridealong)) {
                      wfq.Choices = CHOICE_XSP_RIDEALONG;
                    }
                    else if(formName.equals(Label.CAR_Event)) {
                      wfq.Choices = CHOICE_CAR_EVENT;
                    }
                    else if(formName.equals(Label.Property_Visit)) {
                      wfq.Choices = CHOICE_PROPERY_VISIT;
                    }
                    else if(formName.equals(Label.Indirect_Observation)) {
                      wfq.Choices = CHOICE_INDIRECT_OBSERVATION;
                    }
                    else if(formName.equals(Label.CAR_Super_Coach_1_1_Observation)) {
                      wfq.Choices = CHOICE_SC_1_1_OBSERVATION;
                    }
                    else if(formName.equals(Label.CAR_Manager_Huddle_Observation)) {
                      wfq.Choices = CHOICE_HUDDEL_OBSERVATION;
                    }
                    else if(formName.equals(Label.Field_Observation)) { // added for field observation
                      wfq.Choices = CHOICE_FIELD_OBSERVATION;
                    }
                    wfq.QuestionSetId=wfqset.Id;
                    wfq.Type=MULTI_CHOICE;
                    wfq.Section__c = COMMON;
                    wfqList.add(wfq);
                }
                 

                //changes at 13th May 2016
                /*wfq=new WorkFeedbackQuestion();
                wfq.Name='Area of Focus - Notes';
                wfq.Text='Area of Focus - Notes';
                //qfq.IsOptional=true;
                wfq.Number=questionNbr++;
                wfq.QuestionSetId=wfqset.Id;
                wfq.Type='FreeText';
                wfq.Section__c = 'Common';
                wfqList.add(wfq);*/

                if(formName.equals(Label.XSP_Ridealong)){
                    wfq=new WorkFeedbackQuestion();
                    wfq.Name=KNOCKS_OBSERVED;
                    wfq.Text=KNOCKS_OBSERVED;
                    wfq.Number=questionNbr++;
                    wfq.QuestionSetId=wfqset.Id;
                    wfq.Type=FREE_TEXT;
                    wfq.Section__c = OBSERVATION_COUNT;
                    wfqList.add(wfq);

                    wfq=new WorkFeedbackQuestion();
                    wfq.Name=CONTACTS;
                    wfq.Text=CONTACTS;
                    wfq.Number=questionNbr++;
                    wfq.QuestionSetId=wfqset.Id;
                    wfq.Type=FREE_TEXT;
                    wfq.Section__c = OBSERVATION_COUNT;
                    wfqList.add(wfq);

                    wfq=new WorkFeedbackQuestion();
                    wfq.Name=STARTS;
                    wfq.Text=STARTS;
                    wfq.Number=questionNbr++;
                    wfq.QuestionSetId=wfqset.Id;
                    wfq.Type=FREE_TEXT;
                    wfq.Section__c = OBSERVATION_COUNT;
                    wfqList.add(wfq);
                }
                

                for(observationController.Category category: categories){
                    String str1 = 'N/A\nUnacceptable\nNeeds Improvement\nAchieved Expectations\nHighly Effective\nExceptional';
                    String str2 = 'N/A\nNeeds Improvement\nAchieved Expectations\nHighly Effective';
                    String str3 = 'N/A\nStrength\nOpportunity';
                    wfq=new WorkFeedbackQuestion();
                    wfq.Name=category.Text;
                    wfq.Category__c=category.Text;
                    wfq.Text=category.text;
                    wfq.Number=questionNbr++;
                    if(formName.equals(Label.Indirect_Observation) || 
                       formName.equals(Label.Retail_Manager_Observation)){
                        wfq.Choices = str1;
                    }
                    else{
                        wfq.Choices = str2;
                    }
                    wfq.QuestionSetId=wfqset.Id;
                    wfq.Type=MULTI_CHOICE;
                    wfq.Section__c = OBSERVATIONS;
                    //wfq.Weight__c = Integer.valueof(category.weights.trim());
                    wfq.Weight__c = category.weights;
                    wfqList.add(wfq);
                    
                    for(observationController.Question q:category.questions){
                        wfq=new WorkFeedbackQuestion();
                        wfq.Category__c=category.Text;
                        wfq.Name=q.Name;
                        wfq.Text=q.Text;
                        wfq.Number=questionNbr++;
                        wfq.Choices=str3;
                        wfq.QuestionSetId=wfqset.Id;
                        wfq.Type=MULTI_CHOICE;
                        wfq.Section__c = OBSERVATIONS;
                        wfqList.add(wfq);
                        
                        wfq=new WorkFeedbackQuestion();
                        wfq.Name=q.Name+NOTES;
                        wfq.Category__c=category.Text;
                        wfq.Text=q.Name+NOTES;
                        wfq.Number=questionNbr++;
                        wfq.QuestionSetId=wfqset.Id;
                        wfq.Type=FREE_TEXT;
                        wfq.Section__c = OBSERVATIONS;
                        wfq.IsOptional=true;
                        wfqList.add(wfq);   
                    }
                }
                startDate = endDate.addDays(1);
                endDate = startDate.addDays(6);
            }

            //insert wfqList;
            Database.SaveResult[] insertWfq = Database.Insert(wfqList,false);
            /*List<WorkFeedbackQuestion> toUpdt = [   select Id,Name, IsOptional from WorkFeedbackQuestion 
                                                    where Name like '% - Notes'
                                                    and QuestionSetId in :wfqSetIdList
                                                    and Name !='Overall Notes'
                                                    and Name !='Area of Focus - Notes' ] ;

            for(WorkFeedbackQuestion q:toUpdt){
                q.IsOptional=true;
            }*/

            //update toUpdt; 
            executeJob(insertWfq,jobStatus);

        }catch(Exception e) {
            if(jobStatus!=null && !jobStatus.isEmpty()){
                  Integer len= Job_Status__c.Comments__c.getDescribe().getLength();
                  String tempMsg = string.IsBlank(jobStatus[0].Comments__c) ?  SYSTEM_EXCEPTION + e.getMessage() + NEW_LINE : jobStatus[0].Comments__c + SYSTEM_EXCEPTION + e.getMessage() +NEW_LINE;                                    
                  jobStatus[0].Comments__c=(tempMsg.length() > len)?tempMsg.substring(0, len):tempMsg; Database.update(jobStatus[0]);   
            }         
        }  
    }
    //Finish
    global void finish(Database.BatchableContext BC){
        List<Job_Status__c> jobStatus = getJobStatus(jobStatusId); 
        
        if(jobStatus!=null && !jobStatus.isEmpty()){ 
            jobStatus[0].Batch_End_Time__c = Datetime.now(); 
            jobStatus[0].Status__c = String.isBlank(jobStatus[0].Comments__c) ? BATCH_COMPLETE_WITH_SUCCESS : BATCH_COMPLETE_WITH_FAIL ; 
            Database.update(jobStatus[0]); 
        }   
        
          
        feedbackData.Start_Date__c = startDate;
        update feedbackData;
            
        
        CreateFeedbackDataBatchSchedule sch = new CreateFeedbackDataBatchSchedule(observationFormName);
        // Cron expression 
        String expr = '0 0 0 1 12 ?';
        if(!Test.isRunningTest()){
            system.schedule('Feedback Data Job for-'+observationFormName+' '+datetime.now(),expr,sch);
        }
    }
    //Retrieve Job Status
    public List<Job_Status__c> getJobStatus(Id jobStatusId) {
        return [SELECT Total_Records_Processed__c, Comments__c, Number_Of_Fallouts__c, 
                Batch_Start_Time__c, Batch_End_Time__c 
                FROM Job_Status__c WHERE Status__c =: JOB_STATUS AND ID=: jobStatusId];
    }
    
    //Execute Job
    public void executeJob(Database.SaveResult[] insertWfq, List<Job_Status__c> jobStatus)
    {
        if(jobStatus!=null && !jobStatus.isEmpty()){
            for(Database.SaveResult result : insertWfq) {
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
}