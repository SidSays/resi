/**    
* @Description: Helper class for ApplicationLogTrigger
* @Created By: Deepika
* @Modified Date: 7/05/2017
* @User Story: US1107249 - XC MCAT - Delete contract in MCAT
*/ 
public class ApplicationLogTriggerHelper {
    // Getting the application log for all the contracts and then delete the opportunity.
    public static void deleteOppFromAppLog(List<Application_Log__c> appLogForOppDelete){        
        Set<String> oppIdSet = new Set<String>();       
        for(Application_Log__c appLog : appLogForOppDelete){
            if(appLog.OpportunityID__c != null && appLog.FlagForOpportunity__c && appLog.isSuccess__c){
                oppIdSet.add(appLog.OpportunityID__c);
            }       
        }
        
        if(!oppIdSet.isEmpty()){
            List<Opportunity> oppToBeDeleted = [SELECT Id FROM Opportunity WHERE Id IN: oppIdSet 
                                                    LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())];            
            if(!oppToBeDeleted.isEmpty()){
                Database.delete(oppToBeDeleted,false);
            }
        }
    }
}