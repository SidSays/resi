/*
* Name: OpportunityTrigger
* Description: All Opportunity Triggers execution is managed from here using Sequencer & Operations class call.
* * Last Modified By : Tejaswini Kasar
* Last Modified Date : 9th MAY 2017 
* User Story: US978554 
* Description : added method "sendEmailToDetermineAssignedCARonProperty" .This method is used to send email to Regional lead of the property's region when Assigned CAR field on Property is NULL and to the CAR manger (Manager of Assigned CAR) when the Assigned CAR field is not NULL.
* Last Modified Date : 1st June 2017 
* User Story: US990966 
* Description : added method "sendEmailToCAROnOpportunityProperty" which sends email alerts to CARs from Opportunity when Opportunity Stage changes
* Last Modified By : Deepika Jain
* Last Modified Date : 14th Aug 2017 
* User Story: US1167685 (XC - Wifi Ready Fields in Opportunity) 
* Description : added methods to put validation on Opportunity to restrict the editing of fields on insertion and updation.
* Last Modified By : Deepika Jain
* Last Modified Date : 22nd Aug 2017 
* User Story: US1166692 and US1166808 (XC -  Video Equipment by Industry) and (XC -  Marketing Rights)
* Description : Added methods to put validation on Opportunity fields 'Marketing Rights' and 'Type of video equipment' fields.
*/
trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update, after delete, before delete) {
 
 try{   
        TriggerSettings__c triggerSetting = TriggerSettings__c.getValues(ConstantHandler.OPPORTUNITY_TRIGGER);
        TriggerSettings__c triggerSettingXfinity = TriggerSettings__c.getValues(ConstantHandler.XFINITY_OPPORTUNITY_TRIGGER);
        if(triggerSetting.isActive__c){
            if(trigger.isBefore){
                if(trigger.isInsert){
                    OpportunityTriggerController.updateActivatedByOnOpportunity();
                    
                    //call to set Date AE and Date Stage based on Assigned AE and Stage field on opportunity
                    if(triggerSettingXfinity.isActive__c){
                        OpportunityTriggerController.beforeUpdateOrInsertOperation();
                        OpportunityTriggerHelper.restrictEditWifiReadyFieldInsert(Trigger.New); // Added as part of US1167685. Added by Deepika
                        OpportunityTriggerHelper.validateOpportunityFieldsOnInsert(Trigger.New); // Added as part of US1166692 and US1166808. Added by Deepika
                    }
                   // Validation for XC AE Contractor change for US738562                   
                   OpportunityValidation.AEvalidation(Trigger.new);                      
                }
                else if(trigger.isUpdate){
                    OpportunityTriggerController.updateActivatedByOnOpportunity();
                    OpportunityTriggerController.updateIncrementalFieldValidation(Trigger.New,Trigger.oldMap);
                    if(triggerSettingXfinity.isActive__c){
                        //call to set Date AE and Date Stage based on Assigned AE and Stage field on opportunity
                        OpportunityTriggerController.beforeUpdateOrInsertOperation();
                        if(OpportunityTriggerHelper.allowOppValidation){ // Added as part of US1167685. Added by Deepika
                            OpportunityTriggerHelper.restrictEditWifiReadyFieldsUpdate(Trigger.New,Trigger.oldMap);
                        }
                        OpportunityTriggerHelper.validateOpportunityFieldsOnUpdate(Trigger.New); // Added as part of US1166692 and US1166808. Added by Deepika
                        // call to show validation message when user select opportunity stages on opportunity record above the Contact Made 
                        //but NO property associated with that opportunity
                        OpportunityTriggerController.beforeUpdateOperationOpptyStage();
                        if(CheckRecursive.runOnceForClosedWonValidation()){
                             OpportunityTriggerController.validateOpportunityOnClosedWon(Trigger.New,Trigger.oldMap);
                        }
                       
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
                    boolean recursiveCheck = CheckRecursive.runOnce();
                     if(recursiveCheck){ 
                           OpportunityTriggerController.updateGoalOnClosedWon(Trigger.New);                          
                     }
                     
                     boolean runningTest = Test.isrunningTest();
                     if(runningTest || recursiveCheck)
                     {
                         //US990966 : Start 
                         OpportunityTriggerHelper.sendEmailToCAROnOpportunityProperty(Trigger.oldMap,Trigger.New);
                         //US990966 : End
                     }
                     
                     if(triggerSettingXfinity.isActive__c){
                         // Call to set Active Oppty check flag on property
                         OpportunityTriggerOperations.setActiveOpportunityAndUpdateClosedFields(Trigger.New,Trigger.oldMap); 
                    }  
                   OpportunityTriggerController.updateOpportunityShares(Trigger.oldMap, Trigger.New);
                   OpportunityTriggerController.sendEmailToDetermineAssignedCARonProperty(Trigger.oldMap,Trigger.New);
                   
                } 
        
            } 
        }
    }
    catch(Exception e){
        System.debug('>>>>Error Message'+e.getMessage());
    }
}