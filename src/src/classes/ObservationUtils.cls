/******************************************************************************************************
* Class Name: ObservationUtils
* Author: 
* Date: 
* Description: Util class for ObservationController
* Version : 1.0
  Author Last Updated : Amit Kumar Pradhan, Accenture(Code Refactoring XSP Walkalong)
  PROJECT : Coach for CAR
* Version : 2.0
  Author Last Updated : Revan Bhadange and Amit Kumar Pradhan, Accenture(Combined Car Event and Property Visit Observation)
  PROJECT : Coach for CAR
* Version : 3.0
  Author Last Updated : Animesh Datta and Amit Kumar Pradhan, Accenture(Combined Indirect Observation)
  PROJECT : Coach for Indirect
* Version : 4.0
  Author Last Updated : Animesh Datta, Accenture(Combined Super Coach Observation)
  PROJECT : Super Coach for CAR 
* Version : 5.0
  Author Last Updated : Animesh Datta and Amit Kumar Pradhan, Accenture(Combined Car Event and Property Visit Observation for Super Coach Observation)
  PROJECT : Super Coach for CAR  
* Modification Decription: US1024559: Added the Indirect Completed Observation Metric update for RSM 
  Date: 04032017
  Modified By: Amit Kumar
  PROJECT : Coach for Indirect  
* Modification Decription: US1094059: Indirect - Coach - Post Completed Observations to Chatter 
  Date: 27-April-2017
  Modified By: Animesh Datta
* Modification Decription: Added custom label to capture the Auto Save interval
  User Story: US1149786: Coach for Indirect - Autosave Observation form 
  Date: 3-Aug-2017
  Modified By: Srini Bhattiprolu
* Modification Decription: Fetching transaction types picklist values to show in observation form
  User Story: US1165802: Coach for Retail: As a manager, allow transaction type to be recorded as part of an observation 
  Date: 21-Aug-2017
  Modified By: Amit Kumar Pradhan
********************************************************************************************************/
global class ObservationUtils{    
    private static final String SUBMITTEDSTRING = 'Submitted';
    private static final String DRAFTSTRING = 'Draft';
    private static final String READSTRING = 'Read';
    private static final String MANUALSTRING = 'Manual';
    private static final String COMISSIONCYCLESTRING = 'ActivityGoalCommissionCycle';
    private static final String PUBLISHEDSTRING = 'Published';
    private static final String ACTIVITYSTRING = '%Activity%';
    private static final String WALKALONGSTRING = '%Walkalongs%';
    private static final String OBSERVATIONSTRING = '%'+PL_Constants.PROPERTY_LAB+'%';
    private static final String AreaofFocusNotes = 'Area of Focus - Notes';
    private static final String FieldObservationForm = 'Field Observation Form';
    private static final String MultipleChoice = 'MultipleChoice';
    private static final String FreeText = 'FreeText';
    private static final String Submitted = 'Submitted';
    private static final String Finished = 'Finished';
    private static final String Observations = 'Observations';
    private static final String Common = 'Common';
    private static final String ObservationCounts = 'Observation Counts';
    private static final String Completed = 'Completed';
    private static final String XSP_WALKALONG = 'XSP Walkalong';
    private static final String INDIRECT_OBS_RECORD_TYPE = 'Indirect Observation';
    private static final String SUPER_CAR_COACH_1_1_RECORDTYPE = 'CAR Manager 1:1 Observation';
    private static final String CAR_MANAGER_HUDDLE_RECORDTYPE = 'CAR Manager Huddle Observation';
    private static final String FIELD_OBSERVATION_RECORDTYPE = 'CAR Manager Field Observation';
    private static final String SPACE_STRING = '  ';
    private static final String PROPERTY_NAME_SPACE = ' - ';
    private static final String EMPTY_STRING = '';
    private static final String NONE_RATING_STRING = 'None';
    private static final String OBSERVATION_STRING = 'Observation';
    private static final String TASK_SUBJECT_STRING = 'WalkAlong With ';
    private static final String FEEDBACK_TYPE_CYCLE_MANAGER = 'CycleManager';
    private static final String QUESTION_NOTES_STRING = ' - Notes';
    private static final String TEXT_SEPARATION = '_';
    private static final String NA_RATING = 'N/A'; 
    private static final String PAGEURL_STRING = '/apex/CompletedObservationNavigation?SubjectId=';
    private static final String PARAM_STRING = '&FeedbackId=';
    private static final String RETAIL_MGR_OBSERVATION = 'Retail Manager Observation';//Added part of US1165802
    private static final Set<String> FIVE_POINTER_RECORDTYPES = new Set<String>{'Indirect Observation','Retail Manager Observation'};
            
    private static String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(FieldObservationForm).getRecordTypeId();  
    private static String xspwalkalongRecordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get(Label.XSP_Ridealong).getRecordTypeId(); 
    private static String oneOnOneRecordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get(SUPER_CAR_COACH_1_1_RECORDTYPE).getRecordTypeId();
    private static String carHuddleObservationRecordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get(CAR_MANAGER_HUDDLE_RECORDTYPE).getRecordTypeId();
    private static String carFieldObservationRecordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get(FIELD_OBSERVATION_RECORDTYPE).getRecordTypeId();
    private static String propertyVisitRecordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get(Label.Property_Visit).getRecordTypeId();
    private static String carEventRecordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get(Label.CAR_Event).getRecordTypeId();
    
    /****************************************************
    * @Description: This method returns Observation Data(ObservationController.WalkAlongData wrapper) if Feedback Request Status exists in draft states
                                                    or from new performance cycle data
    * @Param: String, String, String, String, String
    * @Return: ObservationController.WalkAlongData
    
    * LastModified By : Animesh Datta
    * LastModified Date : 02-March-2017
    * LastModified Description : Added logic for Field Observation
    
    * LastModified By : Amit Kumar Pradhan
    * LastModified Date : 24-March-2017
    * Description : CAR Directors can create Super Coach(Super Coach Huddles/Super Coach 1:1s/Super Coach CAR Manager Field Obs) 
                    & CAR Manager(CAR Event/Property Visit) Observations
    * User Story : US1028099
    
    * LastModified By : Amit Kumar Pradhan
    * LastModified Date : 21-Aug-2017
    * Decription: Fetching transaction types picklist values to show in observation form
    * User Story: US1165802: Coach for Retail: As a manager, allow transaction type to be recorded as part of an observation 
    *****************************************************/   
    global static ObservationController.WalkAlongData getFeedbackForXsp(String formName, String xspUserId, String cocheeId, String activityId, String personCAR){
        List<String> propNameList1 = new List<String>();
        String propString = null;
        String recordTypeId;        
        try{
            if(formName != '' && formName != null && xspUserId != '' && xspUserId != null){                
                for(MDU_Property__c propObj :[SELECT Id, Name, Complex_ID__c FROM MDU_Property__c WHERE Assigned_CAR__c =:xspUserId 
                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    propNameList1.add(SPACE_STRING + propObj.Name + PROPERTY_NAME_SPACE + propObj.Complex_ID__c);
                }
                
                if(formName==XSP_WALKALONG){
                    formName = Label.XSP_Ridealong;  
                }
                
                recordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get(formName).getRecordTypeId();
                List<WorkFeedbackRequest> wfrList;
                if(recordTypeId == oneOnOneRecordTypeId){
                    wfrList = [SELECT Id, Person_Coach__c, Huddle_Id__c, Related_1_1_Coaching__c, LastModifiedDate,Private_Notes__c, 
                                SelectedProperty__c, PerformanceCycle.RecordType.Name FROM WorkFeedbackRequest 
                                WHERE FeedbackRequestState=: DRAFTSTRING AND SubjectId=:xspUserId 
                                AND PerformanceCycle.RecordTypeId=:recordTypeId AND Person_Coach__c =:cocheeId 
                                AND Related_1_1_Coaching__c =: activityId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                }
                else if(recordTypeId == carHuddleObservationRecordTypeId){
                    wfrList = [SELECT Id, Person_Coach__c, Huddle_Id__c, Related_1_1_Coaching__c, LastModifiedDate,Private_Notes__c, 
                                SelectedProperty__c, PerformanceCycle.RecordType.Name FROM WorkFeedbackRequest 
                                WHERE FeedbackRequestState=: DRAFTSTRING AND SubjectId=:xspUserId 
                                AND PerformanceCycle.RecordTypeId=:recordTypeId AND  Huddle_Id__c =: activityId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                }
                else if(recordTypeId == carFieldObservationRecordTypeId){
                    wfrList = [SELECT Id, LastModifiedDate, Person_CAR_in_Field_Observation__c,Private_Notes__c, 
                                Field_Observation_Feedback_Request__c, SelectedProperty__c, PerformanceCycle.RecordType.Name 
                                FROM WorkFeedbackRequest WHERE FeedbackRequestState=: DRAFTSTRING AND SubjectId=:xspUserId 
                                AND PerformanceCycle.RecordTypeId=:recordTypeId 
                                AND Field_Observation_Feedback_Request__c =: activityId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                }
                else{
                    //Included Property Visit and CAR Event Obs for CAR Directors(Part of US1028099)
                    //Last Modified By : Amit Kumar Pradhan
                    wfrList = [SELECT Id, Person_Coach__c, Huddle_Id__c, Related_1_1_Coaching__c,Private_Notes__c, 
                                LastModifiedDate, Transaction_types__c, SelectedProperty__c, PerformanceCycle.RecordType.Name
                                FROM WorkFeedbackRequest WHERE FeedbackRequestState =: DRAFTSTRING AND SubjectId=:xspUserId 
                                AND PerformanceCycle.RecordTypeId=:recordTypeId 
                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                }
               
                ObservationController.WalkAlongData tempData = new ObservationController.WalkAlongData();
                //US1149786: Coach for Indirect - Autosave Observation form
                //Added by Srini Bhattiprolu Custom label to capture the Auto save interval
                Integer interval = 300000;
                if(System.Label.ObservationAutoSaveInterval !=null && System.Label.ObservationAutoSaveInterval.isNumeric()){
                    interval = Integer.valueOf(System.Label.ObservationAutoSaveInterval);
                }
                if(wfrList.size()==1){
                    ObservationController.WalkAlongData data = new ObservationController.WalkAlongData();               
                    data.selectedXSP = xspUserId;
                    data.selectedRecordType = formName;
                    if(wfrList[0].PerformanceCycle.RecordType.Name == SUPER_CAR_COACH_1_1_RECORDTYPE){
                        data.selectedPersonCoach = wfrList[0].Person_Coach__c;
                        data.selectedActivity = wfrList[0].Related_1_1_Coaching__c;
                    }
                    if(wfrList[0].PerformanceCycle.RecordType.Name == CAR_MANAGER_HUDDLE_RECORDTYPE){
                        data.selectedActivity = wfrList[0].Huddle_Id__c;
                    }
                    if(wfrList[0].PerformanceCycle.RecordType.Name == FIELD_OBSERVATION_RECORDTYPE){
                        data.selectedActivity = wfrList[0].Field_Observation_Feedback_Request__c;
                        data.selectedPersonObserved = wfrList[0].Person_CAR_in_Field_Observation__c;
                    }
                    //US1165802: Coach for Retail: allow transaction type to be recorded as part of an observation
                    //Added by Amit Kumar Pradhan (Fetching Transaction types value from feedbackrequest)
                    if(wfrList[0].PerformanceCycle.RecordType.Name == RETAIL_MGR_OBSERVATION){
                        data.selectedTransactionTypes  = wfrList[0].Transaction_types__c;
                        data.transactionTypes = getTransactionTypes();//fetching picklist values from getTransactionTypes method
                    }

                    data.requestId = wfrList[0].Id;
                    data.lastSavedDate = wfrList[0].LastModifiedDate.format();
                    data.showNotes = false;
                    data.propString = wfrList[0].SelectedProperty__c;                
                    data.recordTypeName = wfrList[0].PerformanceCycle.RecordType.Name;                
                    data.propNameList = propNameList1;
                    data.privateNotes = wfrList[0].Private_Notes__c;
                    data.autoSaveInterval = interval;
                                       
                    Map<String,List<WorkFeedback>> xspFeedbacks = new Map<String,List<WorkFeedback>>();
                    List<WorkFeedback> feedbackList = [SELECT Id, Question.Name, Question.Id, Question.Text, Question.Weight__c, 
                                                        Question.Category__c, Question.Section__c, Feedback, Question.Number, Question.Type
                                                        FROM WorkFeedback WHERE RequestId=:wfrList[0].Id order by Question.Number 
                                                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                    ObservationController.Category category;
                    ObservationController.Question question;
                    ObservationController.Section section;
                    Map<String,ObservationController.Section> sectionMap = new Map<String,ObservationController.Section>();             
                    for(Integer idx=0;idx<feedbackList.size();idx++){
                        WorkFeedback feedback = feedbackList[idx];
                        if(feedback.question.Category__c == null) {                        
                            if(!sectionMap.ContainsKey(feedback.question.Section__c)){
                                section = new ObservationController.Section();
                                section.name = feedback.question.Section__c;
                                section.categories = null;
                                section.showSection = false;
                                sectionMap.put(feedback.question.Section__c,section);
                                data.addSection(section);
                            }   
                            question = new ObservationController.Question();
                            question.name = feedback.question.Name;
                            question.text = feedback.question.Text;
                            question.section = feedback.question.Section__c;                       
                            question.rating = feedback.Feedback;
                            question.notes = EMPTY_STRING;
                            question.showNotes=false;
                            question.qnId = feedback.id;
                            //question.qnId = '';
                            sectionMap.get(feedback.question.Section__c).addQuestion(question);                     
                        }else{                        
                            if(!sectionMap.ContainsKey(feedback.question.Section__c)){
                                section = new ObservationController.Section();
                                section.name = feedback.question.Section__c;
                                section.questions = null;
                                section.showSection = false;
                                sectionMap.put(feedback.question.Section__c,section);
                                data.addSection(section);
                            }
                            if(feedback.question.Name == feedback.question.Category__c){                                              
                                //This is the question corresponding to the Category
                                category = new ObservationController.Category();
                                category.category = feedback.question.Category__c;
                                category.rating = feedback.Feedback;
                                category.text = feedback.question.Text;
                                category.categoryQnId = feedback.Id;
                                category.weights = feedback.question.Weight__c;
                                if(!Test.isRunningTest()){
                                    category.category = feedback.question.Text.replace(' ','_');
                                }                            
                                category.showNotes = false;                            
                                section.addCategory(category);
                            }else{
                                //This is the questions within a category
                                if(feedback.question.Type == MultipleChoice){
                                    question = new ObservationController.Question();
                                    question.name = feedback.question.Name;
                                    question.text = feedback.question.Text;
                                    question.section = feedback.question.Section__c;
                                    question.rating = feedback.Feedback;
                                    question.showNotes=false;
                                    question.showHelpText=false;
                                    question.qnId = feedback.id;
                                    //question.qnId = '';                                
                                }else if(feedback.question.Type == FreeText){                                
                                    if(feedback.Feedback!=null)
                                        question.notes=feedback.Feedback;
                                    category.addQuestion(question);
                                    question.qnNotesId=feedback.Id;
                                }else{
                                    //Something is not right
                                }
                            }                           
                        }                    
                    }                   
                    return data;              
                }else{
                    List<WorkFeedbackRequest> submittedReqs;
                    if(recordTypeId == oneOnOneRecordTypeId){
                        submittedReqs = [SELECT Id, FeedbackRequestState, SelectedProperty__c, PerformanceCycle.RecordType.Name, PerformanceCycle.ActivityFrom,
                                           PerformanceCycle.ActivityTo, PerformanceCycle.Name,Private_Notes__c 
                                           FROM WorkFeedbackRequest 
                                           WHERE SubjectId= :xspUserId AND PerformanceCycle.RecordTypeId=:recordTypeId
                                           AND FeedbackRequestState=: Submitted AND Person_Coach__c =:cocheeId AND  Related_1_1_Coaching__c =: activityId
                                           ORDER BY PerformanceCycle.ActivityFrom DESC LIMIT 1];
                    }
                                               
                    else if(recordTypeId == carHuddleObservationRecordTypeId){
                        submittedReqs = [SELECT Id, FeedbackRequestState, SelectedProperty__c, PerformanceCycle.RecordType.Name, PerformanceCycle.ActivityFrom,
                                            PerformanceCycle.ActivityTo, PerformanceCycle.Name,Private_Notes__c 
                                            FROM WorkFeedbackRequest 
                                            WHERE SubjectId= :xspUserId AND PerformanceCycle.RecordTypeId=:recordTypeId
                                            AND FeedbackRequestState=: Submitted AND Huddle_Id__c =: activityId
                                            ORDER BY PerformanceCycle.ActivityFrom DESC LIMIT 1];
                    }
                    
                    else if(recordTypeId == carFieldObservationRecordTypeId){
                        submittedReqs = [SELECT Id, FeedbackRequestState, SelectedProperty__c, PerformanceCycle.RecordType.Name, PerformanceCycle.ActivityFrom,
                                           PerformanceCycle.ActivityTo, PerformanceCycle.Name,Private_Notes__c 
                                           FROM WorkFeedbackRequest 
                                           WHERE SubjectId= :xspUserId AND PerformanceCycle.RecordTypeId=:recordTypeId
                                           AND FeedbackRequestState=: Submitted AND Field_Observation_Feedback_Request__c =: activityId
                                           ORDER BY PerformanceCycle.ActivityFrom DESC LIMIT 1];
                    }
                    
                    else{
                        //Included Property Visit and CAR Event Obs for CAR Directors(Part of US1028099)
                        //Last Modified By : Amit Kumar Pradhan
                        submittedReqs = [SELECT Id, FeedbackRequestState, SelectedProperty__c, PerformanceCycle.RecordType.Name, PerformanceCycle.ActivityFrom,
                                           PerformanceCycle.ActivityTo, PerformanceCycle.Name,Private_Notes__c 
                                           FROM WorkFeedbackRequest 
                                           WHERE SubjectId= :xspUserId AND PerformanceCycle.RecordTypeId=:recordTypeId
                                           AND FeedbackRequestState=: Submitted 
                                           ORDER BY PerformanceCycle.ActivityFrom DESC LIMIT 1];
                    }
                    WorkPerformanceCycle cycle = new  WorkPerformanceCycle ();
                    if(submittedReqs.size() > 0){
                        //There is a previously submitted request
                        //Get the next performance cycle that is great than then activity from date of the last submitted request                    
                        cycle = [SELECT Name, Id, ActivityFrom, ActivityTo, RecordType.Name 
                                 FROM WorkPerformanceCycle  
                                 WHERE ActivityFrom > :submittedReqs[0].PerformanceCycle.ActivityFrom 
                                 AND State !=:Finished AND RecordTypeId =:recordTypeId
                                 ORDER BY ActivityFrom
                                 LIMIT 1];                    
                    }else
                    {
                        //Get the Performance Cycle that has ActivityFrom <= TODAY and ActivityTo >= TODAY
                        cycle  = [SELECT Name, Id, ActivityFrom, ActivityTo, RecordType.Name 
                                  FROM WorkPerformanceCycle  
                                  WHERE ActivityFrom <=TODAY 
                                  AND ActivityTo>=TODAY 
                                  AND State !=:Finished AND RecordTypeId =:recordTypeId
                                  ORDER BY ActivityFrom 
                                  LIMIT 1];
                    }
                   
                    WorkFeedbackQuestionSet wfqset = [SELECT Id FROM WorkFeedbackQuestionSet WHERE PerformanceCycleId=:cycle.Id][0];                        
                    List<WorkFeedbackQuestion> questionlist = [SELECT Choices, Id, Name, Number, Text, Type, Weight__c, Category__c, Section__c
                                                                FROM WorkFeedbackQuestion WHERE QuestionSetId=:wfqset.Id ORDER BY Number 
                                                                LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];

                    tempData.selectedXSP = xspUserId;
                    tempData.selectedRecordType = formName;
                    
                    if(cycle.RecordType.Name == SUPER_CAR_COACH_1_1_RECORDTYPE){
                        tempData.selectedPersonCoach = cocheeId;
                        tempData.selectedActivity = activityId;
                    }
                    
                    if(cycle.RecordType.Name == CAR_MANAGER_HUDDLE_RECORDTYPE){
                        tempData.selectedActivity = activityId;
                    }
                    
                    if(cycle.RecordType.Name == FIELD_OBSERVATION_RECORDTYPE){
                        tempData.selectedPersonObserved = personCAR;
                        tempData.selectedActivity = activityId;
                    }
                    
                    //US1165802: Coach for Retail: allow transaction type to be recorded as part of an observation
                    //Added by Amit Kumar Pradhan (Fetching picklist values from Transaction types custom field)
                    if(cycle.RecordType.Name == RETAIL_MGR_OBSERVATION){
                        tempData.transactionTypes = getTransactionTypes();
                    }
                    
                    tempData.autoSaveInterval = interval;
                    tempData.propNameList = propNameList1;              
                    tempData.recordTypeName=cycle.RecordType.Name;                
                    ObservationController.Category category;
                    ObservationController.Question question;
                    ObservationController.Section section;
                
                    Map<String,ObservationController.Section> sectionMap = new Map<String,ObservationController.Section>();
                    for(Integer idx=0;idx<questionlist.size();idx++){
                        WorkFeedbackQuestion feedbackQuestion = questionlist[idx];
                        if(feedbackQuestion.Category__c == null){                        
                            if(!sectionMap.ContainsKey(feedbackQuestion.Section__c)){
                                section = new ObservationController.Section();
                                section.name = feedbackQuestion.Section__c;
                                section.categories = null;
                                section.showSection = false;
                                sectionMap.put(feedbackQuestion.Section__c,section);
                                tempData.addSection(section);
                            }   
                            question = new ObservationController.Question();
                            question.name = feedbackQuestion.Name;
                            question.text = feedbackQuestion.Text;
                            question.section = feedbackQuestion.Section__c;
                            if(feedbackQuestion.Section__c == ObservationCounts){
                                question.rating = NONE_RATING_STRING;
                            }else{
                                question.rating = EMPTY_STRING;
                            }    
                            question.notes = EMPTY_STRING;
                            question.showNotes=false;
                            //question.qnId = feedbackQuestion.id;
                            question.qnId = EMPTY_STRING;
                            sectionMap.get(feedbackQuestion.Section__c).addQuestion(question);                        
                        }else{                        
                            if(!sectionMap.ContainsKey(feedbackQuestion.Section__c)){
                                section = new ObservationController.Section();
                                section.name = feedbackQuestion.Section__c;
                                section.questions = null;
                                section.showSection = false;
                                sectionMap.put(feedbackQuestion.Section__c,section);
                                tempData.addSection(section);
                            }                        
                            if(feedbackQuestion.Name == feedbackQuestion.Category__c){                                              
                                //This is the question corresponding to the Category
                                category = new ObservationController.Category();
                                category.category = feedbackQuestion.Category__c;
                                if(!Test.isRunningTest()){
                                    category.category=feedbackQuestion.Text.replace(' ','_');
                                }
                                category.rating = EMPTY_STRING;
                                category.text = feedbackQuestion.Text;
                                category.weights = feedbackQuestion.Weight__c;
                                category.showNotes = false;                            
                                section.addCategory(category);
                            }else{
                                //This is the questions within a category
                                if(feedbackQuestion.Type == MultipleChoice){
                                    question = new ObservationController.Question();
                                    question.name = feedbackQuestion.Name;
                                    question.text = feedbackQuestion.Text;
                                    question.section = feedbackQuestion.Section__c;
                                    question.rating = EMPTY_STRING;
                                    question.notes = EMPTY_STRING;
                                    question.showNotes=false;
                                    //question.qnId = feedbackQuestion.id;
                                    question.qnId = EMPTY_STRING;                                
                                }else if(feedbackQuestion.Type == FreeText){                                
                                    //Once notes comes up add the question and reset the current question
                                    category.addQuestion(question);
                                }else{
                                    //Something is not right
                                }
                            }                          
                        }                    
                    }
                }
                return tempData;
                //No Feedback Request exists
            }
        }catch(Exception e){
            System.debug('***Following exception has occured***'+e.getMessage());
        }
        return null;
    }
    
    /****************************************************
    * @Description: This method updates Feedback Request data and as well as related metrics when observation is submitted
    * @Param: ObservationController.WalkAlongData, String, Boolean
    * @Return: ObservationController.WalkAlongData
    
    * LastModified By : Animesh Datta
    * LastModified Date : 02-March-2017
    * LastModified Description : Added logic for Field Observation
    
    * LastModified By : Amit Kumar Pradhan
    * LastModified Date : 24-March-2017
    * Description : CAR Directors can create Super Coach(Super Coach Huddles/Super Coach 1:1s/Super Coach CAR Manager Field Obs) 
                    & CAR Manager(CAR Event/Property Visit) Observations
    * User Story : US1028099
    
    * LastModified By : Amit Kumar Pradhan
    * LastModified Date : 21-Aug-2017
    * Decription: Updating transaction type field in feedback request record.
    * User Story: US1165802: Coach for Retail: As a manager, allow transaction type to be recorded as part of an observation 
    *****************************************************/    
    global static ObservationController.WalkAlongData saveSubmitFeedback(ObservationController.WalkAlongData walkAlongData, String propString, Boolean isSubmitted){     
        WorkPerformanceCycle cycle;     
        try{
            String xspName = [SELECT Name FROM User WHERE Id = :walkAlongData.selectedXsp][0].Name;
            //Get the list of Feedback requests for the selected XSP
            List<WorkFeedbackRequest> submittedReqs = [SELECT Id, FeedbackRequestState, PerformanceCycle.ActivityFrom, PerformanceCycle.ActivityTo, 
                                                        PerformanceCycle.Name, Private_Notes__c FROM WorkFeedbackRequest 
                                                        WHERE SubjectId = :walkAlongData.selectedXsp 
                                                        AND PerformanceCycle.RecordType.Name =:walkAlongData.selectedRecordType 
                                                        AND FeedbackRequestState=:SUBMITTEDSTRING 
                                                       ORDER BY PerformanceCycle.ActivityFrom DESC];                                                   
            if(submittedReqs.size() > 0){
                //There is a previously submitted request
                //Get the next performance cycle that is great than then activity from date of the last submitted request
                cycle = [SELECT Name, Id, ActivityFrom, ActivityTo 
                         FROM WorkPerformanceCycle  
                         WHERE ActivityFrom > :submittedReqs[0].PerformanceCycle.ActivityFrom 
                         AND State !=:Finished
                         AND recordType.Name =:walkAlongData.selectedRecordType
                         order by ActivityFrom
                         limit 1];
                
            }else{
                //Get the Performance Cycle that has ActivityFrom <= TODAY and ActivityTo >= TODAY
                cycle  = [SELECT Name, Id, ActivityFrom, ActivityTo 
                          FROM WorkPerformanceCycle  
                          WHERE ActivityFrom <= TODAY 
                          AND ActivityTo>=TODAY 
                          AND State !=:Finished
                          AND recordType.Name =:walkAlongData.selectedRecordType
                          order by ActivityFrom LIMIT 1];
            }
            WorkFeedbackQuestionSet wfqset= [SELECT Id FROM WorkFeedbackQuestionSet WHERE PerformanceCycleId=:cycle.Id][0];
            Map<String,WorkFeedback> feedbackList = new Map<String,WorkFeedback>();
            WorkFeedbackRequest wfr;
            if(walkAlongData.requestId == null){
                wfr = new WorkFeedbackRequest();
                wfr.SubjectId = walkAlongData.selectedXsp;
                wfr.RecipientId = UserInfo.getUserId();
                wfr.SubmitFeedbackToId = UserInfo.getUserId();
                wfr.FeedbackRequestState = DRAFTSTRING;
                wfr.PerformanceCycleId = cycle.Id;
                wfr.FeedbackType = FEEDBACK_TYPE_CYCLE_MANAGER;
                wfr.Private_Notes__c = walkAlongData.privateNotes;
                wfr.QuestionSetId = wfqset.Id;
                
                if(walkAlongData.recordTypeName == Label.Property_Visit){
                    wfr.SelectedProperty__c = propString;
                }
                if(walkAlongData.recordTypeName == SUPER_CAR_COACH_1_1_RECORDTYPE){
                    wfr.Person_Coach__c = walkAlongData.selectedPersonCoach;
                    wfr.Related_1_1_Coaching__c = walkAlongData.selectedActivity;
                }                
                if(walkAlongData.recordTypeName == FIELD_OBSERVATION_RECORDTYPE){
                    wfr.Person_CAR_in_Field_Observation__c = walkAlongData.selectedPersonObserved;
                    //wfr.Field_Observation_Feedback_Request__c = walkAlongData.selectedActivity;
                }                
                if(walkAlongData.recordTypeName == CAR_MANAGER_HUDDLE_RECORDTYPE){
                    wfr.Huddle_Id__c = walkAlongData.selectedActivity;
                }
                
                //US1165802: Coach for Retail: allow transaction type to be recorded as part of an observation
                //Added by Amit Kumar Pradhan (Updating transaction type field in feedback request record)
                if(walkAlongData.recordTypeName == RETAIL_MGR_OBSERVATION){
                    wfr.Transaction_types__c = walkAlongData.selectedTransactionTypes;
                }
                //Replacing insert wfr with database.insert(wfr,false)(Part of US1028099)
                //Last Modified By : Amit Kumar Pradhan
                database.insert(wfr,false);
            }else{
                wfr = [SELECT Id, SelectedProperty__c, Person_Coach__c, Related_1_1_Coaching__c, Huddle_Id__c, 
                        Field_Observation_Feedback_Request__c, Person_CAR_in_Field_Observation__c, Private_Notes__c, Name 
                        FROM WorkFeedbackRequest WHERE Id=:walkAlongData.requestId 
                        LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            }
            Map<String,Id> questionNameToId = new Map<String,Id>(); 
            if(walkAlongData.requestId == null){
                for(WorkFeedbackQuestion question: [SELECT Choices, Id, Name, Number, Text, Category__c FROM WorkFeedbackQuestion 
                                                    WHERE QuestionSetId=:wfqset.Id 
                                                    order by Number LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                                        
                    if(question.Category__c!=null){
                        questionNameToId.put(question.Category__c+TEXT_SEPARATION+question.Name,question.Id);
                    }else{
                        questionNameToId.put(question.Name,question.Id);                                                        
                    }
                }
            }
            
            WorkFeedback feedback = new WorkFeedback();        
            for(ObservationController.Section section : walkAlongData.sections){
                if(section.name!=NULL){
                    if(section.name.equals(Common) || section.name.equals(ObservationCounts)){                   
                        for(ObservationController.Question question : section.questions){
                            feedback = new WorkFeedback(RequestId=wfr.Id,
                                                        QuestionId=questionNameToId.get(question.name),
                                                        Feedback=question.rating);            
                            if(question.qnId != ''){
                                feedback.Id=question.qnId;
                                
                            }
                            feedbackList.put(question.name,feedback);
                        }
                    }
                                        
                    if(section.name.equals(Observations)){
                        for(ObservationController.Category category : section.categories){
                            //Included Property Visit and CAR Event Obs for CAR Directors(Part of US1028099)
                            //Last Modified By : Amit Kumar Pradhan
                            feedback = new WorkFeedback(RequestId=wfr.Id,
                                                        QuestionId=questionNameToId.get(category.Text+TEXT_SEPARATION+category.Text),
                                                        Feedback=(category.rating==null||category.rating.length()==0)?NA_RATING:category.rating,
                                                        Feedback__c=(category.rating==null||category.rating.length()==0)?NA_RATING:category.rating);    
                            if(category.categoryQnId!=null){
                                feedback.Id=category.categoryQnId;
                            }
                            feedbackList.put(category.Text+TEXT_SEPARATION+category.Text,feedback);
                            for(ObservationController.Question question: category.questions){
                                //Included Property Visit and CAR Event Obs for CAR Directors(Part of US1028099)
                                //Last Modified By : Amit Kumar Pradhan
                                feedback = new WorkFeedback(RequestId=wfr.Id,
                                                            QuestionId=questionNameToId.get(category.Text+TEXT_SEPARATION+question.Name),
                                                            Feedback=(question.rating==null || question.rating.length()==0)?NA_RATING:question.rating,
                                                            Feedback__c=(question.rating==null || question.rating.length()==0)?NA_RATING:question.rating);
                                if(question.qnId!=''){
                                    feedback.Id=question.qnId;
                                }
                                feedbackList.put(category.Text+TEXT_SEPARATION+question.Name,feedback);
                                
                                //Included Property Visit and CAR Event Obs for CAR Directors(Part of US1028099)
                                //Last Modified By : Amit Kumar Pradhan
                                feedback = new WorkFeedback(RequestId=wfr.Id,
                                                            QuestionId=questionNameToId.get(category.Text+TEXT_SEPARATION+question.Name+QUESTION_NOTES_STRING),
                                                            Feedback=question.notes); 
                                if(question.qnNotesId!=''){
                                    feedback.Id=question.qnNotesId;
                                }
                                feedbackList.put(category.Text+TEXT_SEPARATION+question.Name+QUESTION_NOTES_STRING,feedback);
                            }                       
                        }
                    }                
                }
            }
            
            Database.upsert(feedbackList.values(),false); 
            
            if(walkAlongData.requestId == null && walkAlongData!=null){
                for(ObservationController.Section section : walkAlongData.sections){
                    if(section.name.equals(Common) || section.name.equals(ObservationCounts)){
                        if(section.questions != null){
                            for(ObservationController.Question question : section.questions){
                                question.qnId = feedbackList.get(question.Name).id;
                            }
                        }
                    }
                    if(section.name.equals(Observations)){
                        for(ObservationController.Category category : section.categories){
                            category.categoryQnId = feedbackList.get(category.Text+TEXT_SEPARATION+category.Text).id;
                            for(ObservationController.Question question: category.questions){
                                if(question.Name!=null) {
                                    question.qnId = feedbackList.get(category.Text+TEXT_SEPARATION+question.Name).id;
                                    question.qnNotesId = feedbackList.get(category.Text+TEXT_SEPARATION+question.Name+QUESTION_NOTES_STRING).id;
                                }
                            }
                        } 
                    }
                }
            }
            walkAlongData.requestId = wfr.id; 
            walkAlongData.lastSavedDate = System.now().format();      
            wfr.FeedbackRequestState=isSubmitted?SUBMITTEDSTRING:DRAFTSTRING;
            
            //Share Walkalong Feedback with XSP and creation of One Task Record
            List<Task> taskList = new List<Task>();     
            if(isSubmitted){
                WorkFeedbackRequestShare wfRequestShareXSP = new WorkFeedbackRequestShare(ParentID=wfr.Id,AccessLevel=READSTRING,RowCause=MANUALSTRING,UserOrGroupId = walkAlongData.selectedXsp);
                Database.insert(wfRequestShareXSP,false);
                List<WorkFeedbackShare> wfRequestShareXSPList = new List<WorkFeedbackShare>();
                for(WorkFeedback response:[SELECT Id FROM WorkFeedback WHERE RequestId=:wfr.Id]){
                    wfRequestShareXSPList.add(new WorkFeedbackShare(ParentID=response.Id,AccessLevel=READSTRING,RowCause=MANUALSTRING,UserOrGroupId =walkAlongData.selectedXsp));
                }
                Database.insert (wfRequestShareXSPList,false);
                if(walkAlongData.selectedRecordType == Label.XSP_Ridealong){
                    GoalTemplateDates__c monthlyStartEndDateDates = GoalTemplateDates__c.getInstance(COMISSIONCYCLESTRING);
                    Date monthlyStartDate = monthlyStartEndDateDates.Current_Period_Start_Date__c;
                    Date monthlyEndDate =  monthlyStartEndDateDates.Current_Period_Due_Date__c;
                    //Add one day in end date so that all time will capture for task for end date
                    List<Goal> goalList = 
                        [SELECT id,(SELECT id,CurrentValue,targetvalue FROM Metrics WHERE Name LIKE :WALKALONGSTRING) FROM Goal 
                         WHERE StartDate = :monthlyStartDate AND DueDate= : monthlyEndDate 
                         AND Name LIKE :ACTIVITYSTRING AND Status =: PUBLISHEDSTRING AND OwnerId=:UserInfo.getUserId()];
                    
                    if(goalList.size()>0 && goalList[0].Metrics.size()>0){
                        Integer daysRemaining = monthlyEndDate!=null?System.today().daysBetween(monthlyEndDate):0;
                        MetricTriggerController.allowValidation = false;
                        Metric metricRecord = goalList[0].Metrics[0];
                        metricRecord.CurrentValue= metricRecord.CurrentValue!=null?metricRecord.CurrentValue+1:1;               
                        MetricStatusUpdateUtil.updateSdmAsmStatusPickList(metricRecord,daysRemaining);
                        Database.update(metricRecord,false);                 
                    }       
                    Task newTask = new Task();
                    newTask.Status = Completed;
                    newTask.ownerid = walkAlongData.selectedXsp;
                    newTask.ActivityDate = System.today();
                    newTask.subject= TASK_SUBJECT_STRING + xspName;
                    newTask.recordtypeid = taskRecordTypeId;
                    taskList.add(newTask);
                }
                else if(walkAlongData.selectedRecordType == Label.Property_Visit           || 
                        walkAlongData.selectedRecordType == Label.CAR_Event                ||
                        walkAlongData.selectedRecordType == SUPER_CAR_COACH_1_1_RECORDTYPE || 
                        walkAlongData.selectedRecordType == CAR_MANAGER_HUDDLE_RECORDTYPE  || 
                        walkAlongData.selectedRecordType == FIELD_OBSERVATION_RECORDTYPE){
                
                    GoalTemplateDates__c monthlyStartEndDateDates = GoalTemplateDates__c.getInstance(Label.PL_MonthlyGoalCreationBatchCusSetData);
                    Date monthlyStartDate = monthlyStartEndDateDates.Current_Period_Start_Date__c;
                    Date monthlyEndDate =  monthlyStartEndDateDates.Current_Period_Due_Date__c;
                    Date quarterlyStartDate, quarterlyEndDate;
                    Integer quarter, monthOfStartDate = monthlyStartDate.month(), year = System.today().year();
                    if(monthOfStartDate == 12 || monthOfStartDate == 1 || monthOfStartDate == 2 ){ //Q1
                        if(monthOfStartDate == 12 && System.today().day() > 21 ){
                            quarterlyStartDate = Date.newInstance(year,12,22);
                        //  quarterlyEndDate = Date.newInstance(year+1,3,21);
                        } else{
                            quarterlyStartDate = Date.newInstance(year-1,12,22);
                            //quarterlyEndDate = Date.newInstance(year,3,21);
                        }
                    } else if(monthOfStartDate == 3|| monthOfStartDate == 4 || monthOfStartDate == 5 ){//Q2
                        quarterlyStartDate = Date.newInstance(year,3,22);
                        //quarterlyEndDate = Date.newInstance(year,6,21);
                    } else if(monthOfStartDate == 6|| monthOfStartDate == 7 || monthOfStartDate == 8 ){//Q3
                        quarterlyStartDate = Date.newInstance(year,6,22);
                        //quarterlyEndDate = Date.newInstance(year,9,21);
                    } else{//Q4
                        quarterlyStartDate = Date.newInstance(year,9,22);
                        //quarterlyEndDate = Date.newInstance(year,12,21);
                    }
                    quarterlyEndDate = quarterlyStartDate.addMonths(3).addDays(-1); 
                    
                    List<Goal> goalList = 
                        [SELECT Id,(SELECT Id,Name,CurrentValue,TargetValue FROM Metrics WHERE Name IN (:PL_Constants.METRIC_NAME_OBSERVATION,
                         :PL_Constants.METRIC_NAME_1_1_SUPER_COACH_OBSERVATION,:PL_Constants.METRIC_NAME_FIELD_OBSERVATION_SUPER_COACH,
                         :PL_Constants.METRIC_NAME_HUDDLE_OBSERVATION)) 
                         FROM Goal WHERE ((StartDate = :monthlyStartDate AND DueDate= : monthlyEndDate) OR (StartDate = :quarterlyStartDate AND DueDate= : quarterlyEndDate))
                         AND Name LIKE :OBSERVATIONSTRING 
                         AND Status =: PUBLISHEDSTRING AND OwnerId=:UserInfo.getUserId()];
                         
                    if(goalList != null && goalList.size() > 0){
                       MetricTriggerController.allowValidation = false;
                       Metric metricToUpdate;
                       for(Goal g : goalList){
                            List<Metric> metricList = g.Metrics;
                            if(metricList != null && metricList.size() > 0){
                                for(Metric m : metricList){
                                    if(walkAlongData.selectedRecordType == Label.Property_Visit && m.Name == PL_Constants.METRIC_NAME_OBSERVATION){
                                        m.CurrentValue = (m.CurrentValue!=null)?m.CurrentValue+1:1; metricToUpdate = m;
                                    } else if(walkAlongData.selectedRecordType == Label.CAR_Event && m.Name == PL_Constants.METRIC_NAME_OBSERVATION){
                                        m.CurrentValue = (m.CurrentValue!=null)?m.CurrentValue+1:1; metricToUpdate = m;
                                    } else if(walkAlongData.selectedRecordType == SUPER_CAR_COACH_1_1_RECORDTYPE && 
                                        m.Name == PL_Constants.METRIC_NAME_1_1_SUPER_COACH_OBSERVATION){
                                        m.CurrentValue = (m.CurrentValue!=null)?m.CurrentValue+1:1; metricToUpdate = m;
                                    } else if(walkAlongData.selectedRecordType == CAR_MANAGER_HUDDLE_RECORDTYPE && 
                                        m.Name == PL_Constants.METRIC_NAME_HUDDLE_OBSERVATION){
                                        m.CurrentValue = (m.CurrentValue!=null)?m.CurrentValue+1:1; metricToUpdate = m;
                                    } else{
                                        if(walkAlongData.selectedRecordType == FIELD_OBSERVATION_RECORDTYPE && 
                                            m.Name == PL_Constants.METRIC_NAME_FIELD_OBSERVATION_SUPER_COACH){
                                            m.CurrentValue = (m.CurrentValue!=null)?m.CurrentValue+1:1; metricToUpdate = m;
                                        } else{}
                                    }
                                }
                            }
                        }
                        try{
                            if(metricToUpdate != null){
                                Database.update(metricToUpdate,false);
                            } else{}
                        } catch (Exception ex){
                            System.debug('Exception : ' + ex.getMessage());
                        }
                    }  
                }//  US1024559: Added the Indirect Completed Observation Metric update for RSM  -----START---------------- 
                else if(walkAlongData.selectedRecordType == ConstantHandler.indirectobsrecordtypename){
                    GoalTemplateDates__c monthlyStartEndDateDates = GoalTemplateDates__c.getInstance(Indirect_Constants.INDIRECTACTIVITYGOALCOMMISSIONCYCLE);
                    Date monthlyStartDate = monthlyStartEndDateDates.Current_Period_Start_Date__c;
                    Date monthlyEndDate =  monthlyStartEndDateDates.Current_Period_Due_Date__c;
                    //Fetch the GOAL and Metric record for RSM.
                    List<Goal> goalList = 
                        [SELECT id,(SELECT id,CurrentValue,targetvalue FROM Metrics WHERE Name =:(System.Label.CompletedObservations).trim()) FROM Goal 
                         WHERE StartDate = :monthlyStartDate AND DueDate= : monthlyEndDate 
                         AND Name LIKE:'%'+Indirect_Constants.ACTIVITY_TEMPLATE +'%' AND Status =: PUBLISHEDSTRING AND OwnerId=:UserInfo.getUserId()];
                    if(!goalList.isempty() && goalList[0].Metrics.size()>0){
                        //Integer daysRemaining = monthlyEndDate!=null?System.today().daysBetween(monthlyEndDate):0;
                        MetricTriggerController.allowValidation = false;
                        Metric metricRecord = goalList[0].Metrics[0];
                        metricRecord.CurrentValue= metricRecord.CurrentValue!=null?metricRecord.CurrentValue+1:1; 
                        //MetricStatusUpdateUtil.updateSdmAsmStatusPickList(metricRecord,daysRemaining);                     
                        Database.update(metricRecord,false);                 
                    }       
                }
                //  US1024559: Added the Indirect Completed Observation Metric update for RSM  -----END---------------- 
            }
            walkAlongData.score=calculateScore(walkAlongData);
            wfr.Score__c = walkAlongData.score;
            wfr.SelectedProperty__c = propString;
            wfr.Private_Notes__c = walkAlongData.privateNotes;
            
            //US1165802: Coach for Retail: allow transaction type to be recorded as part of an observation
            //Added by Amit Kumar Pradhan (Updating transaction type field in feedback request record)
            if(walkAlongData.recordTypeName == RETAIL_MGR_OBSERVATION){
                wfr.Transaction_types__c = walkAlongData.selectedTransactionTypes;
            }
            database.update(wfr,false);
            List<feeditem> FIList = new List<feeditem>();
            WorkFeedbackRequest objwfr = [SELECT id, name, SubjectId, RecipientId, FeedbackRequestState, SubmittedDate, 
                                          PerformanceCycle.RecordType.name FROM WorkFeedbackRequest WHERE id =: wfr.id  LIMIT 1];      
            String xspstr;
            if(objwfr.FeedbackRequestState == SUBMITTEDSTRING)
            {   
                //start of comment - Code was commented as chatter post was not required
                /*
                if(objwfr.PerformanceCycle.RecordType.name == 'XSP Ridealong')
                {
                    xspstr = 'Observation';
                }
                else
                {
                    xspstr = objwfr.PerformanceCycle.RecordType.name;
                }
                if(objwfr.PerformanceCycle.RecordType.name == 'XSP Ridealong'){
                    FeedItem FI = new FeedItem();
                    String URL2 = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/CompletedObservationViaChatterPost?SubjectId='+ walkAlongData.selectedXsp + '&FeedbackId='+objwfr.Id;
                    FI.Title =  objwfr.Name+' - '+xspstr+' - '+objwfr.SubmittedDate.Month()+'/'+objwfr.SubmittedDate.Day()+'/'+objwfr.SubmittedDate.Year();
                    FI.LinkUrl = URL2;
                    FI.ParentId = objwfr.SubjectId;
                    
                    FIList.add(FI);
                    
                    String URL1 = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/CompletedObservationViaChatterPost?SubjectId='+ walkAlongData.selectedXsp + '&FeedbackId='+objwfr.Id;
                    FeedItem FI1 = new FeedItem();
                    FI1.Title =  objwfr.Name+' - '+xspstr+' - '+objwfr.SubmittedDate.Month()+'/'+objwfr.SubmittedDate.Day()+'/'+objwfr.SubmittedDate.Year();
                    FI1.LinkUrl = URL1;
                    
                    FI1.ParentId = objwfr.RecipientId;
                    FIList.add(FI1);
                } 
                */
                //end of comment - Code was commented as chatter post was not required
                
                //Display Observation on coaching feed if coaching record exist
                //US1094059 - Adding check for Indirect record type to extend chatter post functionality for Indirect Channel
                if(objwfr.PerformanceCycle.RecordType.name == Label.CAR_Event || objwfr.PerformanceCycle.RecordType.name == Label.Property_Visit || objwfr.PerformanceCycle.RecordType.name == Label.XSP_Ridealong ||objwfr.PerformanceCycle.RecordType.name == ConstantHandler.indirectobsrecordtypename) { // US1024559: Added the Indirect Completed Observation Metric update for RSM
                    List<WorkCoaching> workCoach = [SELECT id,Coach.id,Coached.id FROM workcoaching WHERE Coach.id =: objwfr.RecipientId AND Coached.id =: objwfr.SubjectId LIMIT 1];
                    if(!workCoach.isEmpty()){
                        if(objwfr.PerformanceCycle.RecordType.name == Label.XSP_Ridealong)
                        {
                            xspstr = OBSERVATION_STRING;
                        }
                        else
                        {
                            xspstr = objwfr.PerformanceCycle.RecordType.name;
                        }
                        //Changed the Navigation URL
                        //Last Modified by Ashish Srivastava for DE174163
                        FeedItem FI2 = new FeedItem();
                        //String URL3 = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/CompletedObservationViaChatterPost?SubjectId='+ walkAlongData.selectedXsp + '&FeedbackId='+objwfr.Id;
                        String URL3 = PAGEURL_STRING + walkAlongData.selectedXsp + PARAM_STRING +objwfr.Id;
                        FI2.Title =  objwfr.Name+' - '+xspstr+' - '+objwfr.SubmittedDate.Month()+'/'+objwfr.SubmittedDate.Day()+'/'+objwfr.SubmittedDate.Year();
                        FI2.LinkUrl = URL3;
                        FI2.ParentId = workCoach[0].id;
                        FIList.add(FI2);
                    }
                }             
            }
            if(!FIList.isEmpty()){
                database.insert(FIList,false);
            }
            if(!taskList.isEmpty()){
                database.insert (taskList,false);
            }
            return walkAlongData;
        }catch(Exception e){
            System.debug('***Following exception has occured##***'+e.getMessage());
        }
        return null;
    }
    
    /****************************************************
    * @Description: Score calculation logic for Observation
    * @Param: ObservationController.WalkAlongData
    * @Return: Double
    * LastModified By : Animesh Datta
    * LastModified Date : 02-March-2017
    *****************************************************/    
    @testvisible private static Double calculateScore(ObservationController.WalkAlongData walkAlongData){
        Double score = 0.0;
        Decimal notNARatingCnt =0,naRatingWeightSum=0;
        //Logic for find out weight sum of naRating and notNArating
        for(ObservationController.Section section : walkAlongData.sections){
            if(section.name!=null && section.name.equals(Observations)) {
                for(ObservationController.Category category : section.categories){
                    if(category.weights!=null) {
                        if(category.rating == null || category.rating == '' || category.rating == System.Label.Observation_Rating_NA){
                            naRatingWeightSum += category.weights;
                        }else{
                            notNARatingCnt++;
                        }
                    }
                }               
            }
        }
        //Overall calcualtion
        if(notNARatingCnt>0){
            Decimal additionalWeight = naRatingWeightSum / notNARatingCnt;
            Decimal rating = 0;
            for(ObservationController.Section section : walkAlongData.sections){
                if(section.name!=null && section.name.equals(Observations)){                   
                    for(ObservationController.Category category : section.categories){
                        rating = 0;
                        if(category.rating != System.Label.Observation_Rating_NA && category.weights!=null){
                            Decimal weight = category.weights;
                            weight +=additionalWeight;//revise weight if NA rating exist
                            if(category.rating == System.Label.Observation_Rating_Unacceptable){
                                rating = 1;//for 5 pointer scale
                            }else if(category.rating == System.Label.Observation_Rating_NeedsImprovement){
                                if(FIVE_POINTER_RECORDTYPES.contains(walkAlongData.recordTypeName)){
                                    rating = 2;//for 5 pointer scale
                                }else{
                                    rating = 1;//for 3 pointer scale
                                }                               
                            }else if (category.rating == System.Label.Observation_Rating_AchievedExpectations){                                
                                if(FIVE_POINTER_RECORDTYPES.contains(walkAlongData.recordTypeName)){
                                    rating = 3;//for 5 pointer scale
                                }else{
                                    rating = 2;//for 3 pointer scale
                                }
                            }else if (category.rating == System.Label.Observation_Rating_HighlyEffective){
                                if(FIVE_POINTER_RECORDTYPES.contains(walkAlongData.recordTypeName)){
                                    rating = 4;//for 5 pointer scale
                                }else{
                                    rating = 3;//for 3 pointer scale
                                }
                            }else if (category.rating == System.Label.Observation_Rating_Exceptional){
                                rating = 5;//for 5 pointer scale
                            }
                            weight = weight/100;                            
                            score += rating * weight;
                        }
                    }                   
                }
            }
        }
        return score;        
    }
    
    /****************************************************
    * @Description: geting picklist values of Transaction Types
    * @Param: null
    * @Return: List<String>
    * @Auther : Amit Kumar Pradhan
    * @Date : 21-Aug-2017
    *****************************************************/ 
    public Static List<String> getTransactionTypes(){
        List<String> options = new List<String>();        
        Schema.DescribeFieldResult fieldResult = WorkFeedbackRequest.Transaction_types__c.getDescribe();
        List<Schema.PicklistEntry> pickListValues = fieldResult.getPicklistValues(); 
        for(Schema.PicklistEntry picklistEntry : pickListValues)
        {
            options.add(picklistEntry.getValue());
        }       
        return options;
    }
}