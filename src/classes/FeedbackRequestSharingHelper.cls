/**
* Class Name: FeedbackRequestSharingHelper
* Author: Revan Bhadange, Accenture
* Date: 08-02-2016 
* Description: FeedBack Result records will be available for visibility to the management chain - 'Manager Groups' with Read Access
* Last Modified :
*/
public with sharing class FeedbackRequestSharingHelper{
    public static void FeedbackRequestShareAccess(Map<Id, WorkFeedBackRequest> workfeedbackrequestdata){
        List<WorkFeedbackRequestShare> wShares = new List<WorkFeedbackRequestShare>();
        Set<Id> personFeedbackReq = new Set<Id>();
        for(WorkFeedbackRequest feedbackreq : workfeedbackrequestdata.values()){
          personFeedbackReq.add(feedbackreq.SubjectId);
        System.debug('>>>>> feedbackreq.SubjectId'+feedbackreq.SubjectId);
        }
        Map<Id, Id> groupMap = new Map<Id, Id>();
        for(Group g : [SELECT Id, RelatedId,Type FROM Group WHERE Type = 'Manager' AND RelatedId IN :personFeedbackReq]){
            groupMap.put(g.RelatedId, g.Id);
        }
        System.debug('>>>> groupMap'+groupMap);
        for(WorkFeedbackRequest feedbackreq : workfeedbackrequestdata.values()){
            if(!groupMap.isEmpty() && groupMap.get(feedbackreq.SubjectId)!=null){
                WorkFeedbackRequestShare wcRecord = new WorkFeedbackRequestShare();
                wcRecord.ParentId = feedbackreq.Id;
                wcRecord.userorgroupId = groupMap.get(feedbackreq.SubjectId);
                wcRecord.AccessLevel = 'Read';
                wcRecord.rowCause = Schema.WorkFeedbackRequestShare.rowCause.Manual;
                wShares.add(wcRecord);
            }
        }
        if(!wShares.isEmpty()){
            Database.SaveResult[] CoachingShareInsertResult = Database.insert(wShares ,false);
        }
    }
}