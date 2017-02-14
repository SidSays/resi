global class ObservationUtils {
    
    private static  final  String SUBMITTEDSTRING = 'Submitted';
    private static  final  String DRAFTSTRING = 'Draft';
    private static  final  String READSTRING = 'Read';
    private static  final  String MANUALSTRING = 'Manual';
    private static  final  String COMISSIONCYCLESTRING = 'ActivityGoalCommissionCycle';
    private static  final  String PUBLISHEDSTRING = 'Published';
    private static  final  String ACTIVITYSTRING = '%Activity%';
    private static  final  String WALKALONGSTRING = '%Walkalongs%';
    private static  final  String AreaofFocusNotes = 'Area of Focus - Notes';
    private static  final  String FieldObservationForm = 'Field Observation Form';
    private static  final  String MultipleChoice = 'MultipleChoice';
    private static  final  String FreeText = 'FreeText';
    private static  final  String Submitted = 'Submitted';
    private static  final  String Finished = 'Finished';
    private static  final  String Observations = 'Observations';
    private static  final  String Common = 'Common';
    private static  final  String ObservationCounts = 'Observation Counts';
    private static  final  String Completed = 'Completed';
    private static  final  String INDIRECT_OBS_RECORD_TYPE = 'Indirect Observation';
    private static  final  String SUPER_CAR_COACH_1_1_RECORDTYPE = 'Super CAR Coach 1_1';
    private static  final  String CAR_MANAGER_HUDDLE_RECORDTYPE = 'CAR Manager Huddle Observation';
    private static final Set<String> FIVE_POINTER_RECORDTYPES = new Set<String>{'Indirect Observation','Super CAR Coach 1_1','CAR Manager Huddle Observation'};
    private static final String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(FieldObservationForm).getRecordTypeId();  
    private static final String xspwalkalongRecordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get(Label.XSP_Ridealong).getRecordTypeId(); 
    private static final String oneOnOneRecordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get('Super CAR Coach 1_1').getRecordTypeId();
    private static final String carHuddleObservationRecordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get('CAR Manager Huddle Observation').getRecordTypeId();
    
    global static ObservationController.WalkAlongData getFeedbackForXsp(String xspUserId, String formName, String cocheeId, String activityId){
            List<String> propNameList1 = new List<String>();
            String propString = null;
            String nameString = '{"name": ';
            
            for(MDU_Property__c propObj :[SELECT Id, Name, Complex_ID__c FROM MDU_Property__c WHERE Assigned_CAR__c =:xspUserId]){
                propNameList1.add('  '+propObj.Name+ ' - ' +propObj.Complex_ID__c);
            }
            
            if(formName=='XSP Walkalong') {
                formName = Label.XSP_Ridealong;  
            }
                
            String recordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get(formName).getRecordTypeId();
            List<WorkFeedbackRequest> wfrList;
            if(recordTypeId == oneOnOneRecordTypeId){
                wfrList = [SELECT Id, Person_Coach__c, Huddle_Id__c, Related_1_1_Coaching__c, LastModifiedDate, SelectedProperty__c, PerformanceCycle.RecordType.Name from WorkFeedbackRequest where FeedbackRequestState=: DRAFTSTRING and SubjectId=:xspUserId and PerformanceCycle.RecordTypeId=:recordTypeId and Person_Coach__c =:cocheeId and  Related_1_1_Coaching__c =: activityId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            }
            else if(recordTypeId == carHuddleObservationRecordTypeId){
                wfrList = [SELECT Id, Person_Coach__c, Huddle_Id__c, Related_1_1_Coaching__c, LastModifiedDate, SelectedProperty__c, PerformanceCycle.RecordType.Name from WorkFeedbackRequest where FeedbackRequestState=: DRAFTSTRING and SubjectId=:xspUserId and PerformanceCycle.RecordTypeId=:recordTypeId and  Huddle_Id__c =: activityId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            }
            else{
                wfrList = [SELECT Id, Person_Coach__c, Huddle_Id__c, Related_1_1_Coaching__c, LastModifiedDate, SelectedProperty__c, PerformanceCycle.RecordType.Name from WorkFeedbackRequest where FeedbackRequestState=: DRAFTSTRING and SubjectId=:xspUserId and PerformanceCycle.RecordTypeId=:recordTypeId];
            }
            
           
            
            //ObservationController.WalkAlongData data = new ObservationController.WalkAlongData();
            ObservationController.WalkAlongData tempData = new ObservationController.WalkAlongData();
            
            
            

            if(wfrList.size()==1){
                ObservationController.WalkAlongData data = new ObservationController.WalkAlongData();               
                data.selectedXSP = xspUserId;
                data.selectedRecordType = formName;
                if(wfrList[0].PerformanceCycle.RecordType.Name == 'Super CAR Coach 1_1'){
                    data.selectedPersonCoach = wfrList[0].Person_Coach__c;
                    data.selectedActivity = wfrList[0].Related_1_1_Coaching__c;
                }
                if(wfrList[0].PerformanceCycle.RecordType.Name == 'CAR Manager Huddle Observation'){
                    data.selectedActivity = wfrList[0].Huddle_Id__c;
                }
                
                data.requestId = wfrList[0].Id;
                data.lastSavedDate = wfrList[0].LastModifiedDate.format();
                data.showNotes = false;
                data.propString = wfrList[0].SelectedProperty__c;                
                data.recordTypeName = wfrList[0].PerformanceCycle.RecordType.Name;                
                data.propNameList = propNameList1;
                
                Map<String,List<WorkFeedback>> xspFeedbacks = new Map<String,List<WorkFeedback>>();
                List<WorkFeedback> feedbackList = [SELECT Id, Question.Name, Question.Id,Question.Text,Question.Weight__c,Question.Category__c,Question.Section__c,
                                                   Feedback,Question.Number,Question.Type
                                                   from WorkFeedback 
                                                   where RequestId=:wfrList[0].Id 
                                                   order by Question.Number];
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
                        question.notes = '';
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
                                                           PerformanceCycle.ActivityTo, PerformanceCycle.Name 
                                                           from WorkFeedbackRequest 
                                                           where SubjectId= :xspUserId and PerformanceCycle.RecordTypeId=:recordTypeId
                                                           and FeedbackRequestState=: Submitted and Person_Coach__c =:cocheeId and  Related_1_1_Coaching__c =: activityId
                                                           order by PerformanceCycle.ActivityFrom desc limit 1];
                }
                                           
                else if(recordTypeId == carHuddleObservationRecordTypeId){
                    submittedReqs = [SELECT Id, FeedbackRequestState, SelectedProperty__c, PerformanceCycle.RecordType.Name, PerformanceCycle.ActivityFrom,
                                                           PerformanceCycle.ActivityTo, PerformanceCycle.Name 
                                                           from WorkFeedbackRequest 
                                                           where SubjectId= :xspUserId and PerformanceCycle.RecordTypeId=:recordTypeId
                                                           and FeedbackRequestState=: Submitted and Huddle_Id__c =: activityId
                                                           order by PerformanceCycle.ActivityFrom desc limit 1];
                }                                          
                
                else{
                    submittedReqs = [SELECT Id, FeedbackRequestState, SelectedProperty__c, PerformanceCycle.RecordType.Name, PerformanceCycle.ActivityFrom,
                                                           PerformanceCycle.ActivityTo, PerformanceCycle.Name 
                                                           from WorkFeedbackRequest 
                                                           where SubjectId= :xspUserId and PerformanceCycle.RecordTypeId=:recordTypeId
                                                           and FeedbackRequestState=: Submitted 
                                                           order by PerformanceCycle.ActivityFrom desc limit 1];
                }
                
                WorkPerformanceCycle cycle = new  WorkPerformanceCycle ();
                if(submittedReqs.size() > 0){
                    //There is a previously submitted request
                    //Get the next performance cycle that is great than then activity from date of the last submitted 
                    //request                    
                    cycle = [SELECT Name, Id, ActivityFrom, ActivityTo, RecordType.Name 
                             from WorkPerformanceCycle  
                             where ActivityFrom > :submittedReqs[0].PerformanceCycle.ActivityFrom 
                             and State !=:Finished and RecordTypeId =:recordTypeId
                             order by ActivityFrom
                             limit 1];                    
                }else
                {
                    //Get the Performance Cycle that has ActivityFrom <= TODAY and ActivityTo >= TODAY
                    cycle  = [SELECT Name, Id, ActivityFrom, ActivityTo, RecordType.Name 
                              from WorkPerformanceCycle  
                              where ActivityFrom <=TODAY 
                              and ActivityTo>=TODAY 
                              and State !=:Finished and RecordTypeId =:recordTypeId
                              order by ActivityFrom ];
                }
                WorkFeedbackQuestionSet wfqset = [SELECT Id from WorkFeedbackQuestionSet where PerformanceCycleId=:cycle.Id][0];     
                List<WorkFeedbackQuestion> questionlist = [SELECT Choices, Id, Name, Number, Text, Type, Weight__c, Category__c, Section__c
                                                           FROM WorkFeedbackQuestion where QuestionSetId=:wfqset.Id order by Number LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                //ObservationController.WalkAlongData tempData = new ObservationController.WalkAlongData();
                tempData.selectedXSP = xspUserId;
                tempData.selectedRecordType = formName;
                
                if(cycle.RecordType.Name == 'Super CAR Coach 1_1'){
                    tempData.selectedPersonCoach = cocheeId;
                    tempData.selectedActivity = activityId;
                }
                
                if(cycle.RecordType.Name == 'CAR Manager Huddle Observation'){
                    tempData.selectedActivity = activityId;
                }
                
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
                            question.rating = 'None';
                        }else{
                            question.rating = '';
                        }    
                        question.notes = '';
                        question.showNotes=false;
                        // question.qnId = feedbackQuestion.id;
                        question.qnId ='';
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
                            category.rating = '';
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
                                question.rating = '';
                                question.notes = '';
                                question.showNotes=false;
                                //question.qnId = feedbackQuestion.id;
                                question.qnId = '';                                
                            }else if(feedbackQuestion.Type == FreeText){                                
                                //Once notes comes up add the question and reset the current question
                                category.addQuestion(question);
                            }else{
                                //Something is not right
                            }
                        }   
                       
                    }                    
                }
                return tempData;
                //No Feedback Request exists
            }        
        return null;
    }
    
    global static ObservationController.WalkAlongData saveSubmitFeedback(ObservationController.WalkAlongData walkAlongData, String propString, Boolean isSubmitted){

        if(propString =='@@@@@Test@@@@'){
            propString ='';
        }       
         
        WorkPerformanceCycle cycle;
        //Get the list of Feedback requests for the selected XSP
        String xspName = [select Name From User Where Id = :walkAlongData.selectedXsp][0].Name;
        
        List<WorkFeedbackRequest> submittedReqs = [SELECT Id, FeedbackRequestState, PerformanceCycle.ActivityFrom,
                                                   PerformanceCycle.ActivityTo, PerformanceCycle.Name 
                                                   from WorkFeedbackRequest 
                                                   where SubjectId = :walkAlongData.selectedXsp and PerformanceCycle.RecordType.Name =:walkAlongData.selectedRecordType
                                                   and FeedbackRequestState='Submitted' 
                                                   order by PerformanceCycle.ActivityFrom desc LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        if(submittedReqs.size() > 0){
            //There is a previously submitted request
            //Get the next performance cycle that is great than then activity from date of the last submitted 
            //request
            cycle = [SELECT Name, Id, ActivityFrom, ActivityTo 
                     FROM WorkPerformanceCycle  
                     WHERE ActivityFrom > :submittedReqs[0].PerformanceCycle.ActivityFrom 
                     and State !=:Finished
                     and recordType.Name =:walkAlongData.selectedRecordType
                     order by ActivityFrom
                     limit 1];
            
        }else{
            //Get the Performance Cycle that has ActivityFrom <= TODAY and ActivityTo >= TODAY
            cycle  = [SELECT Name, Id, ActivityFrom, ActivityTo 
                      FROM WorkPerformanceCycle  
                      WHERE ActivityFrom <= TODAY 
                      and ActivityTo>=TODAY 
                      and State !=:Finished
                      and recordType.Name =:walkAlongData.selectedRecordType
                      order by ActivityFrom LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        }
        WorkFeedbackQuestionSet wfqset= [SELECT Id FROM WorkFeedbackQuestionSet WHERE PerformanceCycleId=:cycle.Id][0];
        Map<String,WorkFeedback> feedbackList = new Map<String,WorkFeedback>();
        WorkFeedbackRequest wfr;
        if(walkAlongData.requestId == null){
            wfr=new WorkFeedbackRequest();
            wfr.SubjectId=walkAlongData.selectedXsp;
            wfr.RecipientId=UserInfo.getUserId();
            wfr.SubmitFeedbackToId=UserInfo.getUserId();
            wfr.FeedbackRequestState=DRAFTSTRING;
            wfr.PerformanceCycleId=cycle.Id;
            wfr.FeedbackType='CycleManager';
            wfr.QuestionSetId=wfqset.Id;
            
            if(walkAlongData.recordTypeName=='Property Visit'){
                wfr.SelectedProperty__c = propString;
            }
            if(walkAlongData.recordTypeName=='Super CAR Coach 1_1'){
                wfr.Person_Coach__c = walkAlongData.selectedPersonCoach;
                wfr.Related_1_1_Coaching__c = walkAlongData.selectedActivity;
            }
            
            if(walkAlongData.recordTypeName=='CAR Manager Huddle Observation'){
                wfr.Huddle_Id__c = walkAlongData.selectedActivity;
            }
            
            insert wfr;
        }else{
            wfr = [SELECT Id, SelectedProperty__c, Person_Coach__c, Related_1_1_Coaching__c, Huddle_Id__c, name FROM WorkFeedbackRequest where Id=:walkAlongData.requestId LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        }
        Map<String,Id> questionNameToId = new Map<String,Id>(); 
        if(walkAlongData.requestId == null){
            for(WorkFeedbackQuestion question: [SELECT Choices,Id,Name,Number,Text,Category__c
                                                FROM WorkFeedbackQuestion 
                                                WHERE QuestionSetId=:wfqset.Id
                                                order by Number LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){                               
                                                    if(question.Category__c!=null){
                                                        questionNameToId.put(question.Category__c+'_'+question.Name,question.Id);
                                                    }else{
                                                        questionNameToId.put(question.Name,question.Id);
                                                        
                                                    }
                                                }
        }
        
        WorkFeedback feedback = new WorkFeedback ();
        
        for(ObservationController.Section section : walkAlongData.sections){
            if(section.name!=NULL) {
                if(section.name.equals(Common) || section.name.equals(ObservationCounts)){                   
                    for(ObservationController.Question question : section.questions){
                        feedback = new WorkFeedback(RequestId=wfr.Id,
                                                    QuestionId=questionNameToId.get(question.name),
                                                    Feedback=question.rating);            
                        if(question.qnId!=''){
                            feedback.Id=question.qnId;
                            
                        }
                        feedbackList.put(question.name,feedback);
                    }
                }
                    
                
                if(section.name.equals(Observations)){
                    for(ObservationController.Category category : section.categories){
                       
                        feedback = new WorkFeedback(RequestId=wfr.Id,
                                                    QuestionId=questionNameToId.get(category.Text+'_'+category.Text),
                                                    Feedback=(category.rating==null||category.rating.length()==0)?'N/A':category.rating,
                                                    Feedback__c=(category.rating==null||category.rating.length()==0)?'N/A':category.rating);    
                        if(category.categoryQnId!=null){
                            feedback.Id=category.categoryQnId;
                        }
                        feedbackList.put(category.Text+'_'+category.Text,feedback);
                        for(ObservationController.Question question: category.questions){
                           
                            feedback = new WorkFeedback(RequestId=wfr.Id,
                                                        QuestionId=questionNameToId.get(category.Text+'_'+question.Name),
                                                        Feedback=(question.rating==null || question.rating.length()==0)?'N/A':question.rating,
                                                        Feedback__c=(question.rating==null || question.rating.length()==0)?'N/A':question.rating);
                            if(question.qnId!=''){
                                feedback.Id=question.qnId;
                            }
                            feedbackList.put(category.Text+'_'+question.Name,feedback);
                            
                            feedback = new WorkFeedback(RequestId=wfr.Id,
                                                        QuestionId=questionNameToId.get(category.Text+'_'+question.Name+' - Notes'),
                                                        Feedback=question.notes); 
                            if(question.qnNotesId!=''){
                                feedback.Id=question.qnNotesId;
                            }
                            feedbackList.put(category.Text+'_'+question.Name+' - Notes',feedback);
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
                        category.categoryQnId = feedbackList.get(category.Text+'_'+category.Text).id;
                        for(ObservationController.Question question: category.questions){
                            if(question.Name!=null) {
                                question.qnId = feedbackList.get(category.Text+'_'+question.Name).id;
                                question.qnNotesId = feedbackList.get(category.Text+'_'+question.Name+' - Notes').id;
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
            Database.insert (wfRequestShareXSP);
            List<WorkFeedbackShare> wfRequestShareXSPList = new List<WorkFeedbackShare>();
            for(WorkFeedback response:[select Id from WorkFeedback where RequestId=:wfr.Id]){
                wfRequestShareXSPList.add(new WorkFeedbackShare(ParentID=response.Id,AccessLevel=READSTRING,RowCause=MANUALSTRING,UserOrGroupId =walkAlongData.selectedXsp));
            }
            Database.insert (wfRequestShareXSPList,false);
            if(walkAlongData.selectedRecordType == xspwalkalongRecordTypeId){
                GoalTemplateDates__c monthlyStartEndDateDates = GoalTemplateDates__c.getInstance(COMISSIONCYCLESTRING);
                Date monthlyStartDate = monthlyStartEndDateDates.Current_Period_Start_Date__c;
                Date monthlyEndDate =  monthlyStartEndDateDates.Current_Period_Due_Date__c;
                //Add one day in end date so that all time will capture for task for end date
                List<Goal> goalList = [select id,(select id,CurrentValue,targetvalue from Metrics where Name like :WALKALONGSTRING) FROM Goal where StartDate = :monthlyStartDate and DueDate= : monthlyEndDate 
                                       AND Name like :ACTIVITYSTRING AND Status =: PUBLISHEDSTRING AND OwnerId=:UserInfo.getUserId()];
                
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
                newTask.ownerid= walkAlongData.selectedXsp;
                newTask.ActivityDate= System.today();
                newTask.subject= 'WalkAlong With '+xspName;
                newTask.recordtypeid = taskRecordTypeId;
                taskList.add(newTask);
            }       
        }
        walkAlongData.score=calculateScore(walkAlongData);
        wfr.Score__c = walkAlongData.score;
        wfr.SelectedProperty__c = propString;       
        database.update(wfr,false);
        List<feeditem> FIList = new List<feeditem>();
        WorkFeedbackRequest objwfr = [Select id, name,SubjectId,RecipientId, FeedbackRequestState, SubmittedDate, PerformanceCycle.RecordType.name from WorkFeedbackRequest where id =: wfr.id  limit 1];      
        String xspstr;
        if(objwfr.FeedbackRequestState =='Submitted')
        {
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
            //Display Observation on coaching feed if coaching record exist
            if(objwfr.PerformanceCycle.RecordType.name == 'CAR Event' || objwfr.PerformanceCycle.RecordType.name == 'Property Visit') {
                List<WorkCoaching> workCoach = [select id,Coach.id,Coached.id from workcoaching where Coach.id =: objwfr.RecipientId and Coached.id =: objwfr.SubjectId LIMIT 1];
                if(!workCoach.isEmpty()){
                    FeedItem FI2 = new FeedItem();
                    String URL3 = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/CompletedObservationViaChatterPost?SubjectId='+ walkAlongData.selectedXsp + '&FeedbackId='+objwfr.Id;
                    FI2.Title =  objwfr.Name+' - '+objwfr.PerformanceCycle.RecordType.name+' - '+objwfr.SubmittedDate.Month()+'/'+objwfr.SubmittedDate.Day()+'/'+objwfr.SubmittedDate.Year();
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
        return null;
    }
    
    //Score calculation logic for Observation
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
                if(section.name!=null && section.name.equals('Observations')){                   
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
    
    
}