/**
* Class Name: CoachingSharingHelper
* Author: Sucheta Verma, Accenture
* Date: 07-29-2015 
* Requirement #US : US491515
* Description: Coaching records will be available for visibility to the management chain - 'Manager Groups' with Edit Access
* Last Modified :
*/
public with sharing class CoachingSharingHelper{
    public static void CoachingShareAccess(Map<Id, WorkCoaching > workcoachingdata){
        List<WorkCoachingShare> wShares = new List<WorkCoachingShare>();
        Set<Id> personCoached = new Set<Id>();
        for(WorkCoaching coachng : workcoachingdata.values()){
          personCoached.add(coachng.CoachedId);
        }
        Map<Id, Id> groupMap = new Map<Id, Id>();
        for(Group g : [SELECT Id, RelatedId,Type FROM Group WHERE Type = 'Manager' AND RelatedId IN :personCoached]){
            groupMap.put(g.RelatedId, g.Id);
        }
        for(WorkCoaching coachng : workcoachingdata.values()){
            if(!groupMap.isEmpty() && groupMap.get(coachng.CoachedId)!=null){
                WorkCoachingShare wcRecord = new WorkCoachingShare();
                wcRecord.ParentId = coachng.Id;
                wcRecord.userorgroupId = groupMap.get(coachng.CoachedId);
                wcRecord.AccessLevel = 'Edit';
                wcRecord.rowCause = Schema.WorkCoachingShare.rowCause.Manual;
                wShares.add(wcRecord);
            }
        }
        if(!wShares.isEmpty()){
            Database.SaveResult[] CoachingShareInsertResult = Database.insert(wShares ,false);
        }
    }
}