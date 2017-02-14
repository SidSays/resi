public class CreateFeedbackData {
    public static void createPerformanceCyclesAndQuestions(Integer nbrOfWeeks,Date startingDate,String formName){
        RecordType recType = [SELECT Id,Name FROM RecordType WHERE SObjectType='WorkPerformanceCycle' AND Name =: formName];
        List<observationController.Category> categories;
        if(formName.equals(Label.XSP_Ridealong)) {
            
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'WalkalongObs' LIMIT 1];
            String jsonWalkAlongStr = sr.Body.toString();
            categories = (List<observationController.Category>)JSON.deserialize(jsonWalkAlongStr,List<observationController.Category>.class);
        }
        else if(formName.equals(Label.CAR_Event)) {
            StaticResource sr1 = [SELECT Id, Body FROM StaticResource WHERE Name = 'CAREventObs' LIMIT 1];
            String jsonCarEventStr = sr1.Body.toString();
            categories = (List<observationController.Category>)JSON.deserialize(jsonCarEventStr,List<observationController.Category>.class);
        }
        else if(formName.equals(Label.Property_Visit)) {
            StaticResource sr2 = [SELECT Id, Body FROM StaticResource WHERE Name = 'PropertyVisitObservation' LIMIT 1];
            String jsonPropertyVisitStr = sr2.Body.toString();
            categories = (List<observationController.Category>)JSON.deserialize(jsonPropertyVisitStr,List<observationController.Category>.class);
        }
        else if(formName.equals(Label.Indirect_Observation)) {
            StaticResource sr3 = [SELECT Id, Body FROM StaticResource WHERE Name = 'indirectObservation' LIMIT 1];
            String jsonIndirectObservationStr = sr3.Body.toString();
            categories = (List<observationController.Category>)JSON.deserialize(jsonIndirectObservationStr,List<observationController.Category>.class);
        }
        else if(formName.equals(Label.CAR_Super_Coach_1_1_Observation)) {
            StaticResource sr4 = [SELECT Id, Body FROM StaticResource WHERE Name = 'CARSupercoach' LIMIT 1];
            String jsonCARSuperCoachStr = sr4.Body.toString();
            categories = (List<observationController.Category>)JSON.deserialize(jsonCARSuperCoachStr,List<observationController.Category>.class);
        }
        else if(formName.equals(Label.CAR_Manager_Huddle_Observation)) {
            StaticResource sr5 = [SELECT Id, Body FROM StaticResource WHERE Name = 'CARManagerHuddle' LIMIT 1];
            String jsonCARManagerHuddleStr = sr5.Body.toString();
            categories = (List<observationController.Category>)JSON.deserialize(jsonCARManagerHuddleStr,List<observationController.Category>.class);
        }
        system.debug('^^^^^^^' +JSON.serialize(categories));
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
            if(formName.equals(Label.XSP_Ridealong)) {
                wfqset.Name='XSP Walkalong';
            }
            else if(formName.equals(Label.CAR_Event)) {
                wfqset.Name='CAR EVENT Walkalong';
            }
            else if(formName.equals(Label.Property_Visit)) {
                wfqset.Name='Property Visit Walkalong';
            }
            else if(formName.equals(Label.Indirect_Observation)) {
                wfqset.Name='Indirect Observation';
            }
            else if(formName.equals(Label.CAR_Super_Coach_1_1_Observation)) {
                wfqset.Name='1-1 Super Coach';
            }
            else if(formName.equals(Label.CAR_Manager_Huddle_Observation)) {
                wfqset.Name='CAR Manager Huddle Observation';
            }
            wfqset.FeedbackType='CycleManager';
            wfqset.PerformanceCycleId=wpc.Id;
            wfqset.DueDate=Date.newInstance(startDate.year(),12,31);
            insert wfqset;

            //Add to master id list
            wfqSetIdList.add(wfqSet.Id);

            WorkFeedbackQuestion wfq;
            
            //if(!formName.equals(Label.CAR_Super_Coach_1_1_Observation)){
                wfq=new WorkFeedbackQuestion();
                wfq.Name='Overall Notes';
                wfq.Text='Overall Notes';
                //qfq.IsOptional=true;
                wfq.Number=questionNbr++;
                wfq.QuestionSetId=wfqset.Id;
                wfq.Type='FreeText';
                wfq.Section__c = 'Common';
                wfqList.add(wfq);

                wfq=new WorkFeedbackQuestion();
                wfq.Name='Area of Focus';
                wfq.Text='Area of Focus';
                wfq.Number=questionNbr++;
                if(formName.equals(Label.XSP_Ridealong)) {
                    wfq.Choices='Prepare - Energy\nEngage\nDiscover\nPosition\nClose - Start';
                }
                else if(formName.equals(Label.CAR_Event)) {
                    wfq.Choices='Prep or Engage at Events\nDiscover at Events\nPositioning at Events\nEvent Activations\nAll the Above';
                }
                else if(formName.equals(Label.Property_Visit)) {
                    wfq.Choices='Prep or Energy\nEngage with Property Staff\nClose with Property Staff\nAll the Above';
                }
                else if(formName.equals(Label.Indirect_Observation)) {
                    wfq.Choices='Preparation\nSoft Skills\nBranding\nTraining\nTechnology Usage';
                }
                else if(formName.equals(Label.CAR_Super_Coach_1_1_Observation)) {
                    wfq.Choices='Prep and Messaging\nFeedback Delivery\nUses Multiple Techniques\nSMART Action Plans';
                }
                else if(formName.equals(Label.CAR_Manager_Huddle_Observation)) {
                    wfq.Choices='Huddle Preparation\nDuring Huddle\nHuddle Structure\nHuddle Conclusion';
                }
                wfq.QuestionSetId=wfqset.Id;
                wfq.Type='MultipleChoice';
                wfq.Section__c = 'Common';
                wfqList.add(wfq);
            //}
             

           //changes at 13th May 2016
           /* wfq=new WorkFeedbackQuestion();
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
                wfq.Name='Knocks observed';
                wfq.Text='Knocks observed';
                wfq.Number=questionNbr++;
                wfq.QuestionSetId=wfqset.Id;
                wfq.Type='FreeText';
                wfq.Section__c = 'Observation Counts';
                wfqList.add(wfq);

                wfq=new WorkFeedbackQuestion();
                wfq.Name='Contacts';
                wfq.Text='Contacts';
                wfq.Number=questionNbr++;
                wfq.QuestionSetId=wfqset.Id;
                wfq.Type='FreeText';
                wfq.Section__c = 'Observation Counts';
                wfqList.add(wfq);

                wfq=new WorkFeedbackQuestion();
                wfq.Name='Starts';
                wfq.Text='Starts';
                wfq.Number=questionNbr++;
                wfq.QuestionSetId=wfqset.Id;
                wfq.Type='FreeText';
                wfq.Section__c = 'Observation Counts';
                wfqList.add(wfq);
            }
            

            for(observationController.Category category: categories){
               // System.debug('The value of weight' +category.weights);
                wfq=new WorkFeedbackQuestion();
                wfq.Name=category.Text;
                wfq.Category__c=category.Text;
                wfq.Text=category.text;
                wfq.Number=questionNbr++;
                if(formName.equals(Label.Indirect_Observation) || formName.equals(Label.CAR_Super_Coach_1_1_Observation) || formName.equals(Label.CAR_Manager_Huddle_Observation)){
                    wfq.Choices='N/A\nUnacceptable\nNeeds Improvement\nAchieved Expectations\nHighly Effective\nExceptional';
                }
                else{
                    wfq.Choices='N/A\nNeeds Improvement\nAchieved Expectations\nHighly Effective';
                }
                wfq.QuestionSetId=wfqset.Id;
                wfq.Type='MultipleChoice';
                wfq.Section__c = 'Observations';
                //wfq.Weight__c = Integer.valueof(category.weights.trim());
                wfq.Weight__c = category.weights;
                wfqList.add(wfq);
                
                for(observationController.Question q:category.questions){
                    wfq=new WorkFeedbackQuestion();
                    wfq.Category__c=category.Text;
                    wfq.Name=q.Name;
                    wfq.Text=q.Text;
                    wfq.Number=questionNbr++;
                    wfq.Choices='N/A\nStrength\nOpportunity';
                    wfq.QuestionSetId=wfqset.Id;
                    wfq.Type='MultipleChoice';
                    wfq.Section__c = 'Observations';
                    wfqList.add(wfq);
                    
                    wfq=new WorkFeedbackQuestion();
                    wfq.Name=q.Name+' - Notes';
                    wfq.Category__c=category.Text;
                    wfq.Text=q.Name+' - Notes';
                    wfq.Number=questionNbr++;
                    wfq.QuestionSetId=wfqset.Id;
                    wfq.Type='FreeText';
                    wfq.Section__c = 'Observations';
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