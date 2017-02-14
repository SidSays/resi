public class CreateXSPFeedbackData {
  private static final String jsonStr = '[{"category": "prepare","text": "Prepare - Energy","rating": "","showNotes": false,"questions": [{"name": "On Time","text": "On Time","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Preparation","text": "Prepared with phone, play list, collateral, pitch strategy, and plan for the day","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Badge","text": "Has Badge and Name tag (if applicable)","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Appearance","text": "Has Professional Appearance","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Attitude","text": "Confidence/Enthusiastic/Winning Attitude","showNotes": false,"rating": "","showHelpText": false,"notes": ""}]},{"category": "engage","text": "Engage","rating": "","showNotes": false,"questions": [{"name": "Introduction","text": "Introduces self, company, and gives a compelling reason for visit; Shows badge","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Attention","text": "Gains the customers attention by using a pattern interrupt or attention getter","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Interest","text": "Creates customer interest and curiosity with a third-party statement","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Objection Handling","text": "Overcomes initial objections ","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Agenda","text": "Set the agenda / customer expectations","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Speak Inside","text": "Asks to speak inside the home","showNotes": false,"rating": "","showHelpText": false,"notes": ""}]},{"category": "discover","text": "Discover","rating": "","showNotes": false,"questions": [{"name": "Customer Use","text": "Asks questions to get the customer to explain how they use the TV, Internet, Home Security & Phone …(All Four)","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Needs","text": "Uses open-ended questions to learn about the customer known and unknown needs ","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Use of 4Cs","text": "Uses the 4Cs: Clarify – Tell me more about how you use the internet /  Confirm – From what you said am I right in thinking you use your phone line mostly in the evening? / Compare – Would you say that multi-room or HD is more important to you?/ Consequences & Benefits – What would the impact be if you couldn’t choose when you watched your favorite shows? How would it feel to be able to watch your favorite shows or movies while away from home at your convenience?","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Active Listening","text": "Displays active listening by restating the customer’s experience","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Current cost","text": "Identifies current provider/cost","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Summary","text": "Gets the customer to acknowledge a need/Summarize and confirm needs","showNotes": false,"rating": "","showHelpText": false,"notes": ""}]},{"category": "position","text": "Position","rating": "","showNotes": false,"questions": [{"name": "Solution","text": "Positions the solution based on customer needs ","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Services","text": "Explains how the customer can use Comcast services to satisfy those needs","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Examples","text": "Uses specific examples to convince customer of Comcast value","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Price and Discounts","text": "Presents standard price before offering discounts","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Confidence","text": "Recognize buying clues, confidently ask for the sale, and overcome any additional objections","showNotes": false,"rating": "","showHelpText": false,"notes": ""}]},{"category": "close_start","text": "Close - Start","rating": "","showNotes": false,"questions": [{"name": "Ask for Sale","text": "Recognize buying clues, confidently ask for the sale, and overcome any additional objections","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Get Verification","text": "Gets verification (email, contact #, order summary, monthly recurring charge, promotional roll to rate & timeline, eligibility/fulfillment of promo items)","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Bill Recap","text": "Bill recap (bill 30 days in advance, prorated charges, re-state monthly recurring charge, one-time fees, such as installation)","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "You Can Start Today","text": "You Can Start Today! (customer account number, XFINITY.com/getstarted, service available prior to install)","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Expectation - Next Steps","text": "Expectations for what is next (order summary email, install information [PRO or SIK], customer guarantee, transfer to TPV, if applicable)","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Ask for Referrals","text": "Asks for Referrals","showNotes": false,"rating": "","showHelpText": false,"notes": ""},{"name": "Generate Excitement","text": "Generates excitement, thanks for choosing Comcast, and documents (SFA)","showNotes": false,"rating": "","showHelpText": false,"notes": ""}]}]';

  public static void createPerformanceCyclesAndQuestions(Integer nbrOfWeeks,Date startingDate){
    List<WalkAlongController.Category> categories = (List<WalkAlongController.Category>)JSON.deserialize(jsonStr,List<WalkAlongController.Category>.class);

    RecordType recType = [  select Id from RecordType 
                            where SObjectType='WorkPerformanceCycle'
                            and Name='XSP Ridealong' 
                        ];

    Date startDate = startingDate;
    Date endDate = startDate.addDays(6);

    List<WorkFeedbackQuestion> wfqList = new List<WorkFeedbackQuestion>();
    List<Id> wfqSetIdList = new List<Id>();

    for(Integer nbr=0;nbr<nbrOfWeeks;nbr++){
        WorkPerformanceCycle wpc=new WorkPerformanceCycle();
        wpc.State='Setup';

        //Naming convention : <Year> <Week Number>
        wpc.Name=startDate.year()+' - Week '+(Datetime.newInstance(
                                    startDate.year(),
                                    startDate.month(),
                                    startDate.day())).format('w');
        wpc.ActivityFrom=startDate;
        wpc.ActivityTo=endDate;
        wpc.RecordTypeId=recType.Id;
        insert wpc;
        Integer questionNbr = 1;

        WorkFeedbackQuestionSet wfqset= new WorkFeedbackQuestionSet();
        wfqset.Name='XSP Walkalong';
        wfqset.FeedbackType='CycleManager';
        wfqset.PerformanceCycleId=wpc.Id;
        wfqset.DueDate=Date.newInstance(startDate.year(),12,31);
        insert wfqset;

        //Add to master id list
        wfqSetIdList.add(wfqSet.Id);

        WorkFeedbackQuestion wfq;

        wfq=new WorkFeedbackQuestion();
        wfq.Name='Overall Notes';
        wfq.Text='Overall Notes';
        //qfq.IsOptional=true;
        wfq.Number=questionNbr++;
        wfq.QuestionSetId=wfqset.Id;
        wfq.Type='FreeText';
        wfqList.add(wfq);

        wfq=new WorkFeedbackQuestion();
        wfq.Name='Area of Focus';
        wfq.Text='Area of Focus';
        wfq.Number=questionNbr++;
        wfq.Choices='Prepare - Energy\nEngage\nDiscover\nPosition\nClose - Start';
        wfq.QuestionSetId=wfqset.Id;
        wfq.Type='MultipleChoice';
        wfqList.add(wfq); 


        wfq=new WorkFeedbackQuestion();
        wfq.Name='Area of Focus - Notes';
        wfq.Text='Area of Focus - Notes';
        //qfq.IsOptional=true;
        wfq.Number=questionNbr++;
        wfq.QuestionSetId=wfqset.Id;
        wfq.Type='FreeText';
        wfqList.add(wfq);


        wfq=new WorkFeedbackQuestion();
        wfq.Name='Knocks';
        wfq.Text='Knocks';
        wfq.Number=questionNbr++;
        wfq.QuestionSetId=wfqset.Id;
        wfq.Type='FreeText';
        wfqList.add(wfq);

        wfq=new WorkFeedbackQuestion();
        wfq.Name='Contacts';
        wfq.Text='Contacts';
        wfq.Number=questionNbr++;
        wfq.QuestionSetId=wfqset.Id;
        wfq.Type='FreeText';
        wfqList.add(wfq);

        wfq=new WorkFeedbackQuestion();
        wfq.Name='Starts';
        wfq.Text='Starts';
        wfq.Number=questionNbr++;
        wfq.QuestionSetId=wfqset.Id;
        wfq.Type='FreeText';
        wfqList.add(wfq);

        for(WalkAlongController.Category category: categories){

            wfq=new WorkFeedbackQuestion();
            wfq.Name=category.Text;
            wfq.Category__c=category.Text;
            wfq.Text=category.text;
            wfq.Number=questionNbr++;
            wfq.Choices='N/A\nNeeds Improvement\nAchieved Expectations\nHighly Effective';
            wfq.QuestionSetId=wfqset.Id;
            wfq.Type='MultipleChoice';
            wfqList.add(wfq);
            
            for(WalkAlongController.Question q:category.questions){
                wfq=new WorkFeedbackQuestion();
                wfq.Category__c=category.Text;
                wfq.Name=q.Name;
                wfq.Text=q.Text;
                wfq.Number=questionNbr++;
                wfq.Choices='N/A\nStrength\nOpportunity';
                wfq.QuestionSetId=wfqset.Id;
                wfq.Type='MultipleChoice';
                wfqList.add(wfq);
                
                wfq=new WorkFeedbackQuestion();
                wfq.Name=q.Name+' - Notes';
                wfq.Category__c=category.Text;
                wfq.Text=q.Name+' - Notes';
                wfq.Number=questionNbr++;
                wfq.QuestionSetId=wfqset.Id;
                wfq.Type='FreeText';
                //qfq.IsOptional=true;
                wfqList.add(wfq);
            }
        }

        startDate = endDate.addDays(1);
        endDate = startDate.addDays(6);
    }

    insert wfqList;

    List<WorkFeedbackQuestion> toUpdt = [   select Id,Name, IsOptional from WorkFeedbackQuestion 
                                            where Name like '% - Notes'
                                            and QuestionSetId in :wfqSetIdList
                                            and Name !='Overall Notes'
                                            and Name !='Area of Focus - Notes' ] ;

    for(WorkFeedbackQuestion q:toUpdt){
        q.IsOptional=true;
    }

    update toUpdt; 



  }
}