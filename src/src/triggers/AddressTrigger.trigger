/***************************************************************************************************************************************
 * Author              : 
 * Date                : 
 * Modified By: Animesh
 * Modified Date: 25-Jul-2017
 * Modification Details: US1137083 - System Engineering : Apex CPU Limit Exceed Error when updating Plan Details. Bypassing trigger when PlanEdit is executed
 * Modified By: Srini Bhattiprolu
 * Modified Date: 15-Aug-2017
 * Modification Details: US1129121 - Direct - Dynamic Turf and DSM Limits. Bypassing trigger when PlanEdit is executed
***************************************************************************************************************************************/
trigger AddressTrigger on Customer_Address__c (before insert, before update, after insert, after update) {
    TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('AddressTrigger');
    if(triggerSetting != null && triggerSetting.isActive__c){       
        if(Trigger.isBefore){
            if(Trigger.isInsert){
                AddressTerritoryHandler.addAddressToTerritoryOnInsert(Trigger.New);
                AddressTriggerController.setIsNewOnAddress(Trigger.new);
            }
            else if(Trigger.isUpdate){
                //Added to fix the production issue where update on Census block was not populating the Territory.---*******START****************US1101237
                if(Variable_Setting__c.getInstance('Address_link_to_Territory_Update') !=null && Variable_Setting__c.getInstance('Address_link_to_Territory_Update').Value__c !=null && Variable_Setting__c.getInstance('Address_link_to_Territory_Update').Value__c =='True'){
                    if(AddressTriggerController.byPassFromPlanEdit){//US1137083 - Animesh - 25-Jul-2017. Bypass Trigger Logic from PlanEdit
                        AddressTerritoryHandler.addAddressToTerritoryOnUpdate(Trigger.New,Trigger.Old);//BYPASS from PlanEdit    
                    }else{}
                }
                //Added to fix the production issue where update on Census block was not populating the Territory.---*******END****************US1101237
                if(AddressTriggerController.byPassFromPlanEdit){//US1137083 - Animesh - 25-Jul-2017. Bypass Trigger Logic from PlanEdit
                    AddressTriggerController.setFlagOnRemovingParentAddress(Trigger.New, Trigger.oldMap);//BYPASS from PlanEdit          
                    //US1096534------Set address plan to null and change the owner of the address.------START
                    AddressTriggerController.removeaddressfromplan(Trigger.New, Trigger.oldMap);//BYPASS from PlanEdit 
                    //US1096534------Set address plan to null and change the owner of the address.------END
               }else{}
            }
            if(AddressTriggerController.byPassFromPlanEdit){//US1137083 - Animesh - 25-Jul-2017. Bypass Trigger Logic from PlanEdit
                AddressTriggerController.setCheckboxes(Trigger.New);//BYPASS from PlanEdit 
                AddressTriggerController.setAddressDivisionAndDisconnected(Trigger.New);//BYPASS from PlanEdit 
                AddressTriggerController.setPropertyToAddress(Trigger.New);//BYPASS from PlanEdit 
                AddressTriggerController.removePropertyFromAddress(Trigger.New);//BYPASS from PlanEdit 
                //US1096537- Dynamically Add Targeted Address to Turf
                AddressTriggerController.addAddressToPlan(Trigger.New, Trigger.OldMap);//BYPASS from PlanEdit 
            }else{}
            //AddressTerritoryHandler.updateTargetedIndicator(Trigger.New);
        }
        else{   
            if(Trigger.isInsert){
               // AddressTriggerController.shareAddressWithinRegionalGroups(Trigger.New);
            }
            if(Trigger.isUpdate){
                AddressTriggerController.AddressShareAccess(Trigger.New);
                //AddressTriggerController.updateAddressSharingOnRegionChange(Trigger.New, Trigger.oldMap);
                if(AddressTriggerController.byPassFromPlanEdit){//US1137083 - Animesh - 25-Jul-2017. Bypass Trigger Logic from PlanEdit
                    AddressTriggerController.updateTotalWorkedAddrOnPlan(Trigger.New, Trigger.oldMap);//BYPASS from PlanEdit 
                }else{}
                //START: US1105183 - Update Plan 'Address Details' when Turf Updates
                if(AddressTriggerController.byPassFromPlanEdit){//US1129121 - Srini Bhattiprolu - 15-Aug-2017. Bypass Trigger Logic from PlanEdit
                    AddressTriggerController.updatePlanOnAddressAddToTurf(Trigger.New, Trigger.oldMap);
                }   
                AddressTriggerController.updatePlanOnAddressRemovalFromTurf(Trigger.New, Trigger.oldMap);
                //END: US1105183 - Update Plan 'Address Details' when Turf Updates
            }    
        }
    }
}