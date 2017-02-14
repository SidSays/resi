/** **********************************************************************
* Name: PhaseStatsTriggerOperations
* Author: Ashish Sonawane
* User Story :
* Description: This class is used to perform operations for PhaseStats Trigger events
    Date                 PRJ/DFCT/ENHC#            Summary of Changes 
  -------------         -----------------       ------------------------------
  23-January-2015        Comcast Resi(MDU)              Initial Release 
  
**************************************************************************/
public class PhaseStatsTriggerOperations{
    
     /* Data Member */
    private static final string COMPLETE_STATUS = System.Label.NewBuild_Status_Complete;
    private static final string ACTIVE_STATUS = System.Label.NewBuild_Status_Active;
    
    /*
    * Changes the new Build Status based on child records Completed Status after update
    */
    public static void afterUpdatePhaseStats(){
        Set<id> newBuildIdSet = new Set<id>();
        Map<id,Phase_Stats__c> oldPhaseStatsMap = (Map<id,Phase_Stats__c>) Trigger.OldMap;
        for(Phase_Stats__c tempPhaseStats : (List<Phase_Stats__c>)Trigger.New){
            //Check whether Completed status on new new phase change 
            if(oldPhaseStatsMap.get(tempPhaseStats.id).Completed_Status__c != tempPhaseStats.Completed_Status__c){
                newBuildIdSet.add(tempPhaseStats.New_Build__c);
            }else{
                //future code
            }          
        }                                   
        updateStatus(newBuildIdSet);
    }   
    
    /*
    * Changes the new Build Status based on child records Completed Status after insert
    */
    public static void afterInsertPhaseStats(){
        List<Phase_Stats__c> phaseStatsList = (List<Phase_Stats__c>)Trigger.New;
        Set<Id> newBuildIdSet = new Set<Id>();
        for(Phase_Stats__c phaseStatObj : phaseStatsList){
            newBuildIdSet.add(phaseStatObj.New_Build__c);
        }
        updateStatus(newBuildIdSet);
    }
    
    /*
    * Changes the new Build Status based on child records Completed Status after delete
    */
    public static void afterDeletePhaseStats(){
        List<Phase_Stats__c> deletePhaseStatsList = (List<Phase_Stats__c>)Trigger.Old;
        Set<Id> newBuildIdSet = new Set<Id>();
        for(Phase_Stats__c phaseStatObj : deletePhaseStatsList){
            newBuildIdSet.add(phaseStatObj.New_Build__c);
        }
        updateStatusOnDelete(newBuildIdSet);
    }
    
    /*
    *   This method is use to set Active Status for New Build on insert/update of phase status
    */
    public static void updateStatus(Set<id> newBuildIdSet){
    
        // check in after update if saved record gets the new value on Query.
        Set<Id> phaseStatsNonCompletedIdSet = new Set<Id>(); 
        Set<Id> phaseStatsCompletedIdSet = new Set<Id>(); 
        for(Phase_Stats__c tempPhaseStats : [SELECT Id, Completed_Status__c, New_Build__c 
                                               FROM Phase_Stats__c 
                                               WHERE Completed_Status__c = false and New_Build__c IN: newBuildIdSet
                                               LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            phaseStatsNonCompletedIdSet.add(tempPhaseStats.New_Build__c);
        }
                   
        // Update the status on New Build Parent object base on condition
        List<New_Build__c> toUpdateList = new List<New_Build__c>();       
        for(New_Build__c tempNewBuild: [SELECT Id, Phase_Completed_Date__c, Status__c 
                                          FROM New_Build__c WHERE Id IN: newBuildIdSet
                                         LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            if(phaseStatsNonCompletedIdSet.contains(tempNewBuild.Id) ){
                if(!ACTIVE_STATUS.equalsIgnoreCase(tempNewBuild.Status__c)){ 
                    tempNewBuild.Status__c = ACTIVE_STATUS;
                    tempNewBuild.Phase_Completed_Date__c = null;
                    toUpdateList.add(tempNewBuild);
                } else{}  
            } else {
                if(!COMPLETE_STATUS.equalsIgnoreCase(tempNewBuild.Status__c)) {
                    tempNewBuild.Status__c = COMPLETE_STATUS;
                    tempNewBuild.Phase_Completed_Date__c = Date.Today();
                    toUpdateList.add(tempNewBuild);
                } else {}
            }
        }   
        
        // execute dml Update operation here     
        Database.SaveResult[] saveresultUpdate = Database.update(toUpdateList, false);
    }
    
    
    /*
    * This method is use to set Status for New Build on delete of phase status
    */
    public static void updateStatusOnDelete(Set<id> newBuildIdSet){
    
        // check in after update if saved record gets the new value on Query.
        Set<Id> phaseStatsNonCompletedIdSet = new Set<Id>(); 
        Set<Id> phaseStatsCompletedIdSet = new Set<Id>(); 
        for(Phase_Stats__c tempPhaseStats : [SELECT Id, Completed_Status__c, New_Build__c 
                                               FROM Phase_Stats__c 
                                               WHERE New_Build__c IN: newBuildIdSet
                                               LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            if(!tempPhaseStats.Completed_Status__c){
                phaseStatsNonCompletedIdSet.add(tempPhaseStats.New_Build__c);
            } else {
                phaseStatsCompletedIdSet.add(tempPhaseStats.New_Build__c);
            }
        }        
        // Update the status on New Build Parent object base on condition
        List<New_Build__c> toUpdateList = new List<New_Build__c>();       
        for(New_Build__c tempNewBuild: [SELECT Id, Phase_Completed_Date__c, Status__c 
                                          FROM New_Build__c WHERE Id IN: newBuildIdSet
                                         LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            if(phaseStatsNonCompletedIdSet.contains(tempNewBuild.Id) 
                || (phaseStatsNonCompletedIdSet.isEmpty() && phaseStatsCompletedIdSet.isEmpty())){               
                if(!ACTIVE_STATUS.equalsIgnoreCase(tempNewBuild.Status__c)){ 
                    tempNewBuild.Status__c = ACTIVE_STATUS;
                    tempNewBuild.Phase_Completed_Date__c = null;
                    toUpdateList.add(tempNewBuild);
                } else{}  
            } else if(phaseStatsCompletedIdSet.contains(tempNewBuild.Id)){                
                if(!COMPLETE_STATUS.equalsIgnoreCase(tempNewBuild.Status__c)) {
                    tempNewBuild.Status__c = COMPLETE_STATUS;
                    tempNewBuild.Phase_Completed_Date__c = Date.Today();
                    toUpdateList.add(tempNewBuild);
                } else {}
            }
        }   
        
        // execute dml Update operation here     
        Database.SaveResult[] saveresultUpdate = Database.update(toUpdateList, false);
    }

}