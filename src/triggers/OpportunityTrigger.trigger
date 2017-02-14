/*
* Name: OpportunityTrigger
* Description: All Opportunity Triggers execution is managed from here using Sequencer & Operations class call.
*/
trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update, after delete, before delete) {
 
 try{   
        TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('OpportunityTrigger');
        TriggerSettings__c triggerSettingXfinity = TriggerSettings__c.getValues('XfinityOpportunityTrigger');
        if(triggerSetting.isActive__c){
            if(trigger.isBefore){
                if(trigger.isInsert){
                    OpportunityTriggerController.updateActivatedByOnOpportunity();
                    
                    //call to set Date AE and Date Stage based on Assigned AE and Stage field on opportunity
                    if(triggerSettingXfinity.isActive__c){
                        OpportunityTriggerController.beforeUpdateOrInsertOperation();
                    }
                   // Validation for XC AE Contractor change for US738562 
                  
                   OpportunityValidation.AEvalidation(Trigger.new);                      
                }
                else if(trigger.isUpdate){
                    if(triggerSettingXfinity.isActive__c){
                    	OpportunityTriggerController.updateActivatedByOnOpportunity();
                    	OpportunityTriggerController.updateIncrementalFieldValidation(Trigger.New,Trigger.oldMap);
                    
                        //call to set Date AE and Date Stage based on Assigned AE and Stage field on opportunity
                        OpportunityTriggerController.beforeUpdateOrInsertOperation();
                        
                        // call to show validation message when user select opportunity stages on opportunity record above the Contact Made 
                        //but NO property associated with that opportunity
                        OpportunityTriggerController.beforeUpdateOperationOpptyStage();
                        System.debug('before check recursive');
                        if(CheckRecursive.runOnceForClosedWonValidation()){
                             System.debug('in side check recursive'); 
                             OpportunityTriggerController.validateOpportunityOnClosedWon(Trigger.New,Trigger.oldMap);
                        }
                       
                        //Update the Goals 
                        //Preventing From Recursive call
                        /*if(CheckRecursive.runOnce()){ 
                            OpportunityTriggerController.updateGoalOnClosedWon(Trigger.New);
                        }*/
                        // Validation for XC AE Contractor change for US738562
                       
                        // Call the validation class only if AE is getting changed on the opportunity
                        List<Opportunity> oppList =  new List<Opportunity>();
                        
                        for(Opportunity opp : Trigger.new) {
                            if(opp.AssignedAE_ID__c!= Trigger.oldMap.get(opp.Id).AssignedAE_ID__c){
                                oppList.add(opp);
                            }
                        }       
                        if(!oppList.isEmpty()){
                            OpportunityValidation.AEvalidation(oppList);
                        }
                                     
                    }
                } else if(trigger.isDelete){
                    if(triggerSettingXfinity.isActive__c){
                        OpportunityTriggerController.propertyActiveOpptySetkOnDel();
                    }
                    
                }
            }
            else if(trigger.isAfter){
                if(trigger.isInsert){
                    if(triggerSettingXfinity.isActive__c){
                        // Call to add Opportunity Property Record if Property Id is provided                
                        OpportunityTriggerController.afterCreateOperationOppty(); 
                        // Call to set Active Oppty flag and other fields on property 
                        OpportunityTriggerOperations.setActiveOpportunityAndUpdateClosedFields(Trigger.New,Trigger.oldMap);
                        
                        //OpportunityTriggerController.updateGoalOnClosedWon(Trigger.New);
                    }
                  OpportunityTriggerController.oppContractorSharingMgrGrp(Trigger.New);
                }                   
                else if(trigger.isUpdate){
                    //Added by Amit
                     if(CheckRecursive.runOnce()){ 
                            OpportunityTriggerController.updateGoalOnClosedWon(Trigger.New);
                     }
                     
                     if(triggerSettingXfinity.isActive__c){
                         // Call to set Active Oppty check flag on property
                         OpportunityTriggerOperations.setActiveOpportunityAndUpdateClosedFields(Trigger.New,Trigger.oldMap); 
                    }  
                   OpportunityTriggerController.updateOpportunityShares(Trigger.oldMap, Trigger.New);
                } 
        
            } 
        }
    }
    catch(Exception e){
        System.debug('>>>>Error Message'+e.getMessage());
    }
}