trigger Metrictrigger on Metric (before insert, before update) {
 TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('MetricTrigger');
 TriggerSettings__c batchCheck = TriggerSettings__c.getValues('MetricTriggerBatchCheck');
    if(triggerSetting.isActive__c){
        if(trigger.isBefore){
            if(trigger.isUpdate){
              MetricTriggerController.metricValidation();
              if((System.isBatch() != true && System.isFuture() != true)||batchCheck.isActive__c){              
                  MetricTriggerController.updateMetricStatus(Trigger.new);                  
              }    
            }
        } 
    }
}