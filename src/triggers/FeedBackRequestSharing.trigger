/*
* Trigger Name: CoachingSharing
* Author: Revan Bhadabge, Accenture
* Date: 09-02-2016 
* Requirement #US : US630822
* Description: Feedback Result records will be shared  to the management chain - 'Manager Groups' in SFDC with Read access
* Last Modified :
*/
trigger FeedBackRequestSharing on WorkFeedbackRequest (after insert) {
    if(trigger.isInsert) {
         FeedbackRequestSharingHelper.FeedbackRequestShareAccess(trigger.NewMap);
    }
}