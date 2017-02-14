trigger ContractorRegionMappingTrigger on Contractor_Region_Mapping__c (after insert, after update, after delete) {
   TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('ContractorRegionMappingTrigger'); 
    if(triggerSetting.isActive__c){
       if(trigger.isAfter){
            if(Trigger.isInsert)
            {
                //ContractorRegionMappingController.goalContractorSharingMgrGrp(Trigger.new);
                ContractorRegionMappingController.oppContractorSharingMgrGrp(Trigger.new);
            }
            if(Trigger.isUpdate)
            {
                ContractorRegionMappingController.updategoalContractorSharingMgrGrp(Trigger.new,Trigger.oldMap);
                ContractorRegionMappingController.updateOppContShareMgrGrp(Trigger.OldMap,Trigger.new); 
                ContractorRegionMappingController.updateReportingMgrForGoal(Trigger.OldMap,Trigger.new);  
            }
            if(Trigger.isDelete)
            {
                ContractorRegionMappingController.updategoalContractorSharingMgrGrpOnDelete(Trigger.old);  
                ContractorRegionMappingController.deleteOppContShareMgrGrp(Trigger.Old); 
            }
        }
    }
}