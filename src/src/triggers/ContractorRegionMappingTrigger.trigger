/*
* Name: ContractorRegionMappingTrigger 
* Description: All Contractor Region Mapping Trigger execution is managed from here using controller class call.
* Last Modify : Suchita Sharma ,UserStrory : US1149452 XC - Contractor Roles
* Last Modify Date : 27-July-2017 
*/
trigger ContractorRegionMappingTrigger on Contractor_Region_Mapping__c (after insert, after update, after delete) {
   TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('ContractorRegionMappingTrigger'); 
    if(triggerSetting.isActive__c){
       if(trigger.isAfter){
            if(Trigger.isInsert)
            {
                //ContractorRegionMappingController.goalContractorSharingMgrGrp(Trigger.new);
                ContractorRegionMappingController.oppContractorSharingMgrGrp(Trigger.new);
                //START US1149452
                String triggerNewjsonString = json.serialize(Trigger.NEW);
                 // Pass the JSON String to the Future method
               	ContractorRegionMappingController.contractorPublicGrpAssignment(triggerNewjsonString);
                //END US1149452
            }
            if(Trigger.isUpdate)
            {
                ContractorRegionMappingController.updategoalContractorSharingMgrGrp(Trigger.new,Trigger.oldMap);
                ContractorRegionMappingController.updateOppContShareMgrGrp(Trigger.OldMap,Trigger.new); 
                ContractorRegionMappingController.updateReportingMgrForGoal(Trigger.OldMap,Trigger.new);
                //START US1149452
                ContractorRegionMappingController.contractorPublicGrpAssignmentRecalculate(Trigger.OldMap,Trigger.newMap);
                //END US1149452
            }
            if(Trigger.isDelete)
            {
                ContractorRegionMappingController.updategoalContractorSharingMgrGrpOnDelete(Trigger.old);  
                ContractorRegionMappingController.deleteOppContShareMgrGrp(Trigger.Old); 
                 //START US1149452
                 String triggerOldjsonString = json.serialize(Trigger.old);
                 // Pass the JSON String to the Future method
               	contractorRegionMappingController.contractorPublicGrpAssignmentRemoval(triggerOldjsonString);
                //END US1149452 
            }
        }
    }
}