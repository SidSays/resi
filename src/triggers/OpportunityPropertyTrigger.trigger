/**
* Trigger Name: OpportunityPropertyTrigger 
* Author: Abhishek Mathur, Accenture
* User story : 051/054
* Date: 26-December-2014 
* Requirement # Request Id: USer Story 
* Description: 1. To set Property as Primary Property if Opportunity has not other Property associated.
               2. To validate that no property, associated with any other open opportunity, can be added to an Opportunity
               3. To set new primary property on existing opportuntiy property before deleting opportunity property which has primary property on it
               4. Show validation message to set Portfolio Name before adding more Property on Opportunity
*/
trigger OpportunityPropertyTrigger on Opportunity_Property__c (before insert, after insert,after update, before delete, after delete) {
  TriggerSettings__c triggerSetting = TriggerSettings__c.getValues('OpportunityPropertyTrigger');
    if(triggerSetting.isActive__c) {
       if(Trigger.isBefore && Trigger.IsInsert) {
            OpportunityPropertyTriggerSequencer.beforeInsertOperation();
            //Show validation message to set Portfolio Name before adding more Property on Opportunity;
            OpportunityPropertyTriggerSequencer.setOpptyPortFolioName();     
       }
       else if(Trigger.isBefore && Trigger.IsDelete)  {
              OpportunityPropertyTriggerSequencer.beforeDeleteOperation();
            // Remove the related region's public group from the manual sharing of opportunity
            } 
       else if(Trigger.isAfter){
         if(Trigger.isUpdate){
            OpportunityShares oppShr = new OpportunityShares();
            oppShr.addRegionShare(trigger.old); 
            // PrimaryPropertyForOpportuntySequencer.afterInsertOperation();     
          }else if(Trigger.isInsert){
            OpportunityShares oppShr = new OpportunityShares();
            oppShr.addRegionShare(trigger.new);
            //Set Active Opportunuty flag on Property records
            OpportunityPropertyTriggerSequencer.activeOpptyFlagOnProperty();  
            //Set Current Opportunity field on Property object with latest opportunity
            OpportunityPropertyTriggerSequencer.updatePropertyField();      
          }else if(Trigger.isDelete){
              //Set Active Opportunuty flag on Property records for delete
            OpportunityPropertyTriggerSequencer.activeOpptyFlagOnPropertyForDelete();
            OpportunityShares oppShr = new OpportunityShares();
            oppShr.deleteShare(trigger.old);
          }
       } 
       else{}
    }
  }