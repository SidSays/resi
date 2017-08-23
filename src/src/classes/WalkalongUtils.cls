global class WalkalongUtils {

    private static  final  String SUBMITTEDSTRING = 'Submitted';
    private static  final  String DRAFTSTRING = 'Draft';
    private static  final  String READSTRING = 'Read';
    private static  final  String MANUALSTRING = 'Manual';
    private static  final  String COMISSIONCYCLESTRING = 'ActivityGoalCommissionCycle';
    private static  final  String PUBLISHEDSTRING = 'Published';
    private static  final  String ACTIVITYSTRING = '%Activity%';
    private static  final  String WALKALONGSTRING = '%Walkalongs%';
    private static final String taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Field Observation Form').getRecordTypeId();  
    private static final String wpcRecordTypeId = Schema.SObjectType.WorkPerformanceCycle.getRecordTypeInfosByName().get('XSP Ridealong').getRecordTypeId();  
    global static WalkalongController.WalkAlongData getFeedbackForXsp(String xspUserId){
        System.debug('***************GET FEEDBACK##########************'+xspUserId);
        List<WorkFeedbackRequest> wfrList = [select Id,LastModifiedDate from WorkFeedbackRequest where FeedbackRequestState='Draft' and SubjectId=:xspUserId and PerformanceCycle.RecordTypeId=:wpcRecordTypeId];
        System.debug('******WTRF******'+wfrList);
        System.debug('wfrList.size()'+wfrList.size());
        if(wfrList.size()==1){
            WalkalongController.WalkAlongData data = new WalkalongController.WalkAlongData();
            data.selectedXSP = xspUserId;
            data.requestId=wfrList[0].Id;
            data.lastSavedDate=wfrList[0].LastModifiedDate.format();
            data.showNotes=false;
            Map<String,List<WorkFeedback>> xspFeedbacks = new Map<String,List<WorkFeedback>>();
            List<WorkFeedback> feedbackList = [ select  Id,Question.Name,Question.Text,Question.Category__c,
                                                        Feedback,Question.Number,Question.Type
                                                from WorkFeedback 
                                                where RequestId=:wfrList[0].Id
                                                order by Question.Number];
            Integer currIdx=0;
            System.debug('>>>>>>>>>>>>>>>>Feedbcak List'+feedbackList);
            //Overallnotes
            data.overallNotes=feedbackList[currIdx].feedback;
            data.overallNotesQnId=feedbackList[currIdx].Id;

            //Area of Focus is the first two questions
            currIdx++;
            data.areaOfFocus=feedbackList[currIdx].feedback;
            data.areaOfFocusQnId=feedbackList[currIdx].Id;

            currIdx++;
            data.areaOfFocusNotes=feedbackList[currIdx].feedback;
            data.areaOfFocusQnNotesId=feedbackList[currIdx].Id;

            //Knocks
            currIdx++;
            data.knocks=feedbackList[currIdx].feedback;
            data.knocksQnId=feedbackList[currIdx].Id;

            //Contacts
            currIdx++;
            data.contacts=feedbackList[currIdx].feedback;
            data.contactsQnId=feedbackList[currIdx].Id;

            //Starts
            currIdx++;
            data.starts=feedbackList[currIdx].feedback;
            data.startsQnId=feedbackList[currIdx].Id;

            currIdx++;
            System.debug('************feedbackList******'+currIdx);
            WalkalongController.Category category;
            WalkalongController.Question question;
            System.debug('>>>>>>>> data:'+Json.serialize(data));
            //Categories and questions
            for(Integer idx=currIdx;idx<feedbackList.size();idx++){
                WorkFeedback feedback = feedbackList[idx];
                System.debug('>>>>>>>>>> idx:'+idx+',feedback:'+feedback+',Question:'+feedback.Question);
                System.debug('>>>>>>>>>> CAtegory__c'+feedback.question.Category__c+'>>>>>>>>>> Question'+feedback.question.Name);
                if(feedback.question.Name == feedback.question.Category__c){
                    //This is the question corresponding to the Category
                    category = new WalkalongController.Category();
                    category.category=feedback.Question.Category__c;
                    category.rating=feedback.Feedback;
                    category.text=feedback.Question.Text;
                    category.categoryQnId=feedback.Id;
                    System.debug('*****feedback.Question.Text.replace******'+category.category);
                    System.debug('*****feedback.Question.Text.replace******'+feedback.Question.Text);
                    if(!Test.isRunningTest()){
                        category.category=feedback.Question.Text.replace(' ','_');}
                    category.showNotes=false;
                    data.addCategory(category);
                }else{
                    //This is the questions within a category
                    if(feedback.question.Type =='MultipleChoice'){
                        question = new WalkalongController.Question();
                        question.name=feedback.question.Name;
                        question.text=feedback.question.Text;
                        question.rating=feedback.Feedback;
                        question.qnId=feedback.Id;
                        question.showNotes=false;
                        question.showHelpText=false;

                    }else if(feedback.question.Type =='FreeText'){
                        System.debug('>>>>>>>>>> idx:'+idx+',feedback:'+feedback+',Question:'+feedback.Question);
                        System.debug('>>>>>>>>>> current Question:'+question);
                        System.debug('>>>>>>>>>>>>feedback ID'+feedback.Id);
                        System.debug('>>>>>>>>>>>>Feedback feedback'+feedback.Feedback);
                      if(feedback.Feedback!=null)
                            question.notes=feedback.Feedback;
                   //     System.debug('>>>>>>>>>>>>Feedback feedback'+question.notes);
                        question.qnNotesId=feedback.Id;
                        //Once notes comes up add the question and reset the current question
                        category.addQuestion(question);
                       // question = new WalkalongController.Question();
                    }else{
                        //Something is not right
                    }
                    
                }

            }
            System.debug('>>>>>>>>>> WalkAlongData:'+Json.serialize(data));
            return data;
        }else{
            List<WorkFeedbackRequest> submittedReqs = [select    Id,FeedbackRequestState, PerformanceCycle.ActivityFrom,
                                                                PerformanceCycle.ActivityTo,PerformanceCycle.Name 
                                                                from WorkFeedbackRequest 
                                                                where SubjectId= :xspUserId and PerformanceCycle.RecordTypeId=:wpcRecordTypeId
                                                                and FeedbackRequestState='Submitted' 
              order by PerformanceCycle.ActivityFrom desc limit 1];
             WorkPerformanceCycle cycle;
        if(submittedReqs.size() > 0){
            //There is a previously submitted request
            //Get the next performance cycle that is great than then activity from date of the last submitted 
            //request
           
            cycle = [   select Name,Id,ActivityFrom,ActivityTo 
                        from WorkPerformanceCycle  
                        where ActivityFrom > :submittedReqs[0].PerformanceCycle.ActivityFrom 
                        and State !='Finished' and RecordTypeId=:wpcRecordTypeId
                        order by ActivityFrom
                        limit 1];

        }else{
            system.debug('new feedback');
            //Get the Performance Cycle that has ActivityFrom <= TODAY and ActivityTo >= TODAY
            cycle  = [  select Name,Id,ActivityFrom,ActivityTo 
                        from WorkPerformanceCycle  
                        where ActivityFrom <= TODAY 
                        and ActivityTo>=TODAY 
                        and State !='Finished' and RecordTypeId=:wpcRecordTypeId
                        order by ActivityFrom];
        }

                        
            WorkFeedbackQuestionSet wfqset= [select Id from WorkFeedbackQuestionSet where PerformanceCycleId=:cycle.Id][0];     
            
            List<WorkFeedbackQuestion> questionlist = [SELECT Choices,Id,Name,Number,Text,Type,Category__c
                                        FROM WorkFeedbackQuestion where QuestionSetId=:wfqset.Id and Category__c!=null order by Number];
            
            WalkalongController.WalkAlongData tempData = new WalkalongController.WalkAlongData();
            
            tempData.selectedXSP = xspUserId;
            tempData.knocks = 'None';
            tempData.contacts = 'None';
            tempData.starts = 'None';
            tempData.areaOfFocus = '';
            tempData.areaOfFocusNotes = '';
            tempData.showNotes = false;
            tempData.overallNotes = '';
            WalkalongController.Category category;
            WalkalongController.Question question;
            
            for(Integer idx=0;idx<questionlist.size();idx++){
                WorkFeedbackQuestion feedbackQuestion = questionlist[idx];
               
                if(feedbackQuestion.Name == feedbackQuestion.Category__c){
                    //This is the question corresponding to the Category
                    category = new WalkalongController.Category();
                    category.category = feedbackQuestion.Category__c;
                    if(!Test.isRunningTest()){
                        category.category=feedbackQuestion.Text.replace(' ','_');}
                    category.rating = '';
                    category.text = feedbackQuestion.Text;
                    category.showNotes = false;
                    
                    tempData.addCategory(category);
                }else{
                    //This is the questions within a category
                    if(feedbackQuestion.Type =='MultipleChoice'){
                        question = new WalkalongController.Question();
                        question.name = feedbackQuestion.Name;
                        question.text = feedbackQuestion.Text;
                        question.rating = '';
                        question.notes = '';
                        question.showNotes=false;

                    }else if(feedbackQuestion.Type =='FreeText'){
                        
                        //Once notes comes up add the question and reset the current question
                        category.addQuestion(question);
                     }else{
                        //Something is not right
                    }
                    
                }

            }
            System.debug('>>>>>>>>>> WalkAlongData:'+tempData);
            return tempData;
            //No Feedback Request exists
        }
    }
    
    
    global static WalkalongController.WalkAlongData saveSubmitFeedback(WalkalongController.WalkAlongData walkAlongData,Boolean isSubmitted){
        WorkPerformanceCycle cycle;
        //Get the list of Feedback requests for the selected XSP
        
        String xspName = [select Name From User Where id = :walkAlongData.selectedXsp][0].Name;
       
        List<WorkFeedbackRequest> submittedReqs = [select    Id,FeedbackRequestState, PerformanceCycle.ActivityFrom,
                                                                PerformanceCycle.ActivityTo,PerformanceCycle.Name 
                                                                from WorkFeedbackRequest 
                                                                where SubjectId= :walkAlongData.selectedXsp
                                                                and FeedbackRequestState='Submitted' and PerformanceCycle.RecordTypeId=:wpcRecordTypeId
                                                                order by PerformanceCycle.ActivityFrom desc];
        if(submittedReqs.size() > 0){
            //There is a previously submitted request
            //Get the next performance cycle that is great than then activity from date of the last submitted 
            //request
            cycle = [   select Name,Id,ActivityFrom,ActivityTo 
                        from WorkPerformanceCycle  
                        where ActivityFrom > :submittedReqs[0].PerformanceCycle.ActivityFrom 
                        and State !='Finished' and RecordTypeId=:wpcRecordTypeId
                        order by ActivityFrom
                        limit 1];

        }else{
            //Get the Performance Cycle that has ActivityFrom <= TODAY and ActivityTo >= TODAY
            cycle  = [  select Name,Id,ActivityFrom,ActivityTo 
                        from WorkPerformanceCycle  
                        where ActivityFrom <= TODAY 
                        and ActivityTo>=TODAY 
                        and State !='Finished' and RecordTypeId=:wpcRecordTypeId
                        order by ActivityFrom];
        }

        System.debug('>>>>>>>>>> cycle:'+cycle);
        WorkFeedbackQuestionSet wfqset= [select Id from WorkFeedbackQuestionSet where PerformanceCycleId=:cycle.Id][0];


        Map<String,WorkFeedback> feedbackList = new Map<String,WorkFeedback>();
        WorkFeedbackRequest wfr;
        if(walkAlongData.requestId == null){
            wfr=new WorkFeedbackRequest();
            wfr.SubjectId=walkAlongData.selectedXsp;
            wfr.RecipientId=UserInfo.getUserId();
            wfr.SubmitFeedbackToId=UserInfo.getUserId();
            wfr.FeedbackRequestState='Draft';
            wfr.PerformanceCycleId=cycle.Id;
            wfr.FeedbackType='CycleManager';
            wfr.QuestionSetId=wfqset.Id;

            insert wfr;
        }else{
            wfr = [select Id from WorkFeedbackRequest where Id=:walkAlongData.requestId];

        }

        Map<String,Id> questionNameToId = new Map<String,Id>(); 

        if(walkAlongData.requestId == null){

            for(WorkFeedbackQuestion question: [SELECT Choices,Id,Name,Number,Text,Category__c
                                                FROM WorkFeedbackQuestion 
                                                where QuestionSetId=:wfqset.Id 
                                                order by Number]){
                if(question.Category__c!=null){
                    questionNameToId.put(question.Category__c+'_'+question.Name,question.Id);
                }else{
                    questionNameToId.put(question.Name,question.Id);

                }
            }
            System.debug('>>>>>>>>> questionNameToId = '+Json.serialize(questionNameToId));
        }

        WorkFeedback feedback;

        //Overall Notes
        feedback = new WorkFeedback(RequestId=wfr.Id,
                                    QuestionId=questionNameToId.get('Overall Notes'),
                                    Feedback=walkAlongData.overallNotes);
        if(walkAlongData.overallNotesQnId!=null){
            feedback.Id=walkAlongData.overallNotesQnId;
        }
        feedbackList.put('Overall Notes',feedback);

        System.debug('>>>>>>>>> overall notes:'+feedback);

        //Area of Focus
        feedback = new WorkFeedback(RequestId=wfr.Id,
                                    QuestionId=questionNameToId.get('Area of Focus'),
                                    Feedback=walkAlongData.areaOfFocus);
        if(walkAlongData.areaOfFocusQnId!=null){
            feedback.Id=walkAlongData.areaOfFocusQnId;
        }
        feedbackList.put('Area of Focus',feedback);
        feedback = new WorkFeedback(RequestId=wfr.Id,
                                    QuestionId=questionNameToId.get('Area of Focus - Notes'),
                                    Feedback=walkAlongData.areaOfFocusNotes);
        if(walkAlongData.areaOfFocusQnNotesId!=null){
            feedback.Id=walkAlongData.areaOfFocusQnNotesId;
        }
        feedbackList.put('Area of Focus - Notes',feedback);

        // Knocks, Contacts & Starts
        feedback = new WorkFeedback(RequestId=wfr.Id,
                                    QuestionId=questionNameToId.get('Knocks'),
                                    Feedback=walkAlongData.knocks);
        if(walkAlongData.knocksQnId!=null){
            feedback.Id=walkAlongData.knocksQnId;
        }
        feedbackList.put('Knocks',feedback);

        feedback = new WorkFeedback(RequestId=wfr.Id,
                                    QuestionId=questionNameToId.get('Contacts'),
                                    Feedback=walkAlongData.contacts);
        if(walkAlongData.contactsQnId!=null){
            feedback.Id=walkAlongData.contactsQnId;
        }
        feedbackList.put('Contacts',feedback);

        feedback = new WorkFeedback(RequestId=wfr.Id,
                                    QuestionId=questionNameToId.get('Starts'),
                                    Feedback=walkAlongData.starts);
        if(walkAlongData.startsQnId!=null){
            feedback.Id=walkAlongData.startsQnId;
        }
        feedbackList.put('Starts',feedback);


        //Categories and Questions
        for(WalkalongController.Category category:walkAlongData.categories){
            System.debug('>>>>>>>>>>> Category:'+category.Text+',category.rating:'+category.rating);
            feedback = new WorkFeedback(RequestId=wfr.Id,
                                        QuestionId=questionNameToId.get(category.Text+'_'+category.Text),
                                        Feedback=(category.rating==null||category.rating.length()==0)?'N/A':category.rating,
                                        Feedback__c=(category.rating==null||category.rating.length()==0)?'N/A':category.rating);
            if(category.categoryQnId!=null){
                feedback.Id=category.categoryQnId;
            }
            feedbackList.put(category.Text+'_'+category.Text,feedback);
            System.debug('>>>>>>>>>>> Category Feedback:'+feedback);

            for(WalkalongController.Question question: category.questions){
                System.debug('>>>>>>>>>>> Question:'+question);
                feedback = new WorkFeedback(RequestId=wfr.Id,
                                            QuestionId=questionNameToId.get(category.Text+'_'+question.Name),
                                            Feedback=(question.rating==null || question.rating.length()==0)?'N/A':question.rating,
                                            Feedback__c=(question.rating==null || question.rating.length()==0)?'N/A':question.rating);

                if(question.qnId!=null){
                    feedback.Id=question.qnId;
                }
                feedbackList.put(category.Text+'_'+question.Name,feedback);

                feedback = new WorkFeedback(RequestId=wfr.Id,
                                            QuestionId=questionNameToId.get(category.Text+'_'+question.Name+' - Notes'),
                                            Feedback=question.notes);

                if(question.qnNotesId!=null){
                    feedback.Id=question.qnNotesId;
                }
                feedbackList.put(category.Text+'_'+question.Name+' - Notes',feedback);
            }
        }
        System.debug('>>>>>>>>>>> FeedbackToInsert:'+JSON.serialize(feedbackList));
        upsert feedbackList.values();
        System.debug('>>>>>>>>>>>>feedbackList= '+feedbackList);
        walkAlongData.areaOfFocusQnId = feedbackList.get('Area of Focus').id;
        walkAlongData.areaOfFocusQnNotesId = feedbackList.get('Area of Focus - Notes').id;
        walkAlongData.knocksQnId = feedbackList.get('Knocks').id;
        walkAlongData.contactsQnId = feedbackList.get('Contacts').id;
        walkAlongData.startsQnId = feedbackList.get('Starts').id;
        walkAlongData.overallNotesQnId = feedbackList.get('Overall Notes').id;

        if(walkAlongData.requestId == null){
            for(WalkalongController.Category category:walkAlongData.categories){
                category.categoryQnId = feedbackList.get(category.Text+'_'+category.Text).id;
                for(WalkalongController.Question question: category.questions){
                    question.qnId = feedbackList.get(category.Text+'_'+question.Name).id;
                    question.qnNotesId = feedbackList.get(category.Text+'_'+question.Name+' - Notes').id;
                }
            } 
        }  
        walkAlongData.requestId=wfr.id; 
        walkAlongData.lastSavedDate=System.now().format(); 
        wfr.FeedbackRequestState=isSubmitted?SUBMITTEDSTRING:DRAFTSTRING;   
        //Share Walkalong Feedback with XSP
        List<Task> taskList = new List<Task>();
        if(isSubmitted){   
            
                                                    
            WorkFeedbackRequestShare wfRequestShareXSP = new WorkFeedbackRequestShare(ParentID=wfr.Id,AccessLevel=READSTRING,RowCause=MANUALSTRING,UserOrGroupId=walkAlongData.selectedXsp);
            Database.insert (wfRequestShareXSP);
            
            List<WorkFeedbackShare> wfRequestShareXSPList = new List<WorkFeedbackShare>();
            for(WorkFeedback response:[select Id from WorkFeedback where RequestId=:wfr.Id]){
                wfRequestShareXSPList.add(new WorkFeedbackShare(ParentID=response.Id,AccessLevel=READSTRING,RowCause=MANUALSTRING,UserOrGroupId = walkAlongData.selectedXsp));
            }
            Database.insert (wfRequestShareXSPList);
            
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
            newTask.Status = 'Completed';
            newTask.ownerid= walkAlongData.selectedXsp;
            newTask.ActivityDate= System.today();
            newTask.subject= 'WalkAlong With '+xspName;
            newTask.recordtypeid = taskRecordTypeId;
            taskList.add(newTask);
            
            
                    
        }
        walkAlongData.score=calculateScore(walkAlongData);
        wfr.Score__c = walkAlongData.score;
        database.update(wfr);
        database.insert (taskList);
        return walkAlongData;
    }

    private static Double calculateScore(WalkalongController.WalkAlongData walkAlongData){
        Map<String,Integer> weights = new Map<String,Integer>();
        weights.put('Prepare - Energy',10);
        weights.put('Engage',30);
        weights.put('Discover',30);
        weights.put('Position',20);
        weights.put('Close - Start',10);
        Double score = 0.0;

        Decimal notNARatingCnt =0,naRatingWeightSum=0;
        for(WalkalongController.Category category:walkAlongData.categories){
            System.debug('>>>>>> calculateScore():category:'+category.Text+',category.rating='+category.rating);
            if(category.rating == null || category.rating == '' || category.rating=='N/A'){
                naRatingWeightSum += weights.get(category.text);
            }else{
                notNARatingCnt++;
            }
        }
        System.debug('>>>>>> naRatingWeightSum = '+naRatingWeightSum+',notNARatingCnt='+notNARatingCnt);
        if(notNARatingCnt>0){
            Decimal additionalWeight = naRatingWeightSum / notNARatingCnt;
            System.debug('>>>>>>>additionalWeight='+additionalWeight);
            Decimal rating=0;
            for(WalkalongController.Category category:walkAlongData.categories){
                rating = 0;
                if(category.rating !='N/A'){
                    Decimal weight = weights.get(category.text);
                    System.debug('***************************Weights*****'+category.text);
                    System.debug('***************************Weights*****'+weight);
                    weight +=additionalWeight;
                    System.debug('>>>>>>>category='+category.Text+', weight:'+weight+',rating='+rating+'RATING'+category.rating);
                    if(category.rating == 'Needs Improvement'){
                        rating = 1;
                    }else if (category.rating == 'Achieved Expectations'){
                      rating = 2;
                    }else if (category.rating == 'Highly Effective'){
                        rating = 3;
                    }
                    weight = weight/100;
                    System.debug('>>>>>>>category='+category.Text+', weight:'+weight+',rating='+rating);
                    score += rating * weight;
                }
            }
                   
        }
        System.debug('>>>>>>>score='+score);
        return score;

    }
    
    
}