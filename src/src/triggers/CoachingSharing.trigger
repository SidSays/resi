/**
* Trigger Name: CoachingSharing
* Author: Sucheta Verma, Accenture
* Date: 07-29-2015 
* Requirement #US : US491515
* Description: Coaching records will be shared  to the management chain - 'Manager Groups' in SFDC with Edit access
* Last Modified :
*/
trigger CoachingSharing on WorkCoaching (after insert) {
    if(trigger.isInsert)
    {
         CoachingSharingHelper.CoachingShareAccess(trigger.NewMap);
}
}