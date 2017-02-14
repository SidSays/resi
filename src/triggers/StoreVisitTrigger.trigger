/**
*   Trigger for store visit object
*
*   @author Sahil Grover    <sgrover@acumensolutions.com>
*/
trigger StoreVisitTrigger on Store_Visit__c (before insert,before update, after insert, after update) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('StoreVisitTrigger');
    if(triggerSetting.isActive__c){
        if (Trigger.IsAfter) {
            if (Trigger.IsInsert || Trigger.IsUpdate) {
                StoreVisitTriggerHelper.removeStartedEvents(Trigger.New, Trigger.OldMap);
                 StoreVisitTriggerHelper.storeVisitStatusIndicator(Trigger.New);
            }
            if (Trigger.IsUpdate) {
                StoreVisitSummaryNEWController.automaticEmailAtMidnight(Trigger.New);
            }
            if (Trigger.IsInsert) {
                StoreVisitTriggerHelper.setLastStoreVisitDate(Trigger.New);   
            }
        }
        if(trigger.IsBefore){
            StoreVisitTriggerHelper.setVisitCutOffDatetime(Trigger.New);
            //for (Store_Visit__c visit : trigger.new) {
              // DateTime dt = DateTime.newInstance((system.now()).year(),(system.now()).month(),(system.now()).day(), 23, 59, 0);
             //  visit.visit_cutoff_datetime__c=dt;
            
           // }
           if(Trigger.IsUpdate){
              StoreVisitTriggerHelper.setCompletedAllRequiredActivities(Trigger.New);
           }
        }
    }
}