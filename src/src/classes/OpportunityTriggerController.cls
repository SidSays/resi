/***************************************************************************************************************************************
 * Author     : Raju Patel, Accenture
 * Date       : 07-Nov-2013
 * Description: This class updates the Activated By field on the Opportunity object.
 * History
     Version             : 1.0
     Author Last Updated : Raju Patel, Accenture 
     PROJECT             : Enhancements
    Version             : 1.1
     Author Last Updated : Erin McGee, Acumen Solutions 
     PROJECT             : 14.02 Backlog
     
* Last Modified By : Tejaswini Kasar
* Last Modified Date : 9th MAY 2017 
* User Story: US978554 
* Description : added method "sendEmailToDetermineAssignedCARonProperty" .This method is used to send email to Regional lead of the property's region when Assigned CAR field on Property is NULL and to the CAR manger (Manager of Assigned CAR) when the Assigned CAR field is not NULL.
***************************************************************************************************************************************/
public class OpportunityTriggerController{
/***************************************************************************************************************************************
 * Author     : Raju Patel, Accenture
 * Date       : 11-Nov-2013
 * Description: This method updates the Activated By field on the Opportunity object.
 * PROJECT             : Enhancements
     Version             : 1.1
     Author Last Updated : Erin McGee, Acumen Solutions 
     PROJECT             : 14.02 Backlog
      Date       : 21-Feb-2014
      Description: Updated so that Activated By is populated by NT ID instead of Sales ID, since they can be same in-between regions
***************************************************************************************************************************************/
    /*
    * @Modified: Abhishek Mathur, Accenture 
    * @Description: Modified to check the Record type and update the logic to exclude MDU record type
    */
    private static final string LABEL_NAME_SPLIT = ';';
    
    public static void updateActivatedByOnOpportunity(){
        
        Set<String> NTLogins = new Set<String>();
        Map<String,ID> FedIdByUsername = new Map<String,String>();
        for(Opportunity Oppty : (List<Opportunity>)Trigger.new){
            if(OpportunityTriggerOperations.xfinityOpportunityRecordTypeId != null &&
               OpportunityTriggerOperations.xfinityOpportunityRecordTypeId.equalsIgnoreCase(Oppty.RecordTypeId)){ 
                if(Oppty.NTLoginOpp__c != null){
                    NTLogins.add(Oppty.NTLoginOpp__c);
                }
            }
        }
        if(!NTLogins.isEmpty()){
            for(User usr : [Select Id, Name, FederationIdentifier from User where FederationIdentifier IN: NTLogins]){
                FedIdByUsername.put(usr.FederationIdentifier.toLowerCase(),usr.Id);
            }
            for(Opportunity Oppty : (List<Opportunity>)Trigger.new){
                if(Oppty.NTLoginOpp__c != null){
                    Oppty.ActivatedByOppty__c = FedIdByUsername.get(Oppty.NTLoginOpp__c.toLowerCase());
                }
            }
        }
    }
    
    
    /*
    * call to set Date AE and Date Stage based on Assigned AE and Stage field on opportunity
    */
    public static void beforeUpdateOrInsertOperation(){
        OpportunityTriggerOperations.beforeUpdateOrInsertOperation();
    }
    
    
    /*
    * call to show validation message when user select opportunity stages on opportunity record above the Contact Made 
    * but no property associated with that opportunity
    */
    public static void beforeUpdateOperationOpptyStage(){
        OpportunityTriggerOperations.setOpportunityStagValidation();
    }
    
    /*
    Name : afterCreateOperationOppty
    Description : Create a OpportunityProperty Record if the Property details are passed from the Property object. Also, set the property as Primary property on Opportunity property record
    Parameters : None
    Return : void    
    Author : Abhishek Mathur    
    */ 
    public static void afterCreateOperationOppty(){
        OpportunityTriggerOperations.createOpptyPropertyRecord();
    }
    
    
   /*
    Name : propertyActiveOpportunityCheck
    Description : This method set Active oppty flag on property if property has any open opportunity ,    
    Parameters : Oppty List and flag as true when we call method for OpprtunityTrigger else false when OpptyPropertyTrigger
    Return : void    
    Author : Ashish Sonawane   
    */
    public static void setActiveOpportunityAndUpdateClosedFields(List<Opportunity> opportunityList, Map<Id,Opportunity> oldMap){
        OpportunityTriggerOperations.setActiveOpportunityAndUpdateClosedFields(opportunityList,oldMap);
    }
    
   /*
    Name : propertyActiveOpptySetkOnDel
    Description : This method update Active opportunity flag on property if oppty is deleted 
    Parameters : None
    Return : void    
    Author : Ashish Sonawane   
    */
    public static void propertyActiveOpptySetkOnDel(){
        OpportunityTriggerOperations.propertyActiveOpptySetkOnDel();
    }
     /*
    Name : updateGoalOnClosedWon
    Description : This method update goals whenever the Opportunity stage is changed to "Closed Won"
    Parameters : None
    Return : void
    Author : Lalit Singh
    User Story : US488076 (Quota Attainment)
    */
   
    public static void updateGoalOnClosedWon(List<Opportunity> oppList){
       OpportunityTriggerOperations.updateGoalOnClosedWon(oppList);
    }
    
    /*
    Name : updateopportunityfield
    Description : This method update Incremental Subs Added field based 
    on IPTV field on opportunity and organisation type field on property 
    Parameters : opplist and oldOppMap
    Return : void
    Author : Shalaka Kadwade
    User Story : US689317 (SalesSpace Communties: New field on Opportunity)
    */
    public static void updateIncrementalFieldValidation(List<Opportunity> opplist,Map<Id, Opportunity> oldOppMap){
        OpportunityTriggerOperations.updateIncrementalFieldValidation(opplist , oldOppMap);
    }
    
    
     
    /*
    Author : Shivani Gautam
    Return : void
    Sprint : 34
    User Story : US745492-SalesSpace Communities: Opportunity Edit access for 'AE Contractor' Managers
   */
    
   
    //Description: Methods for sharing opportunity to reporting manager(Contractor_Region_Mapping) when opportunity assigned to Contractor AE
   
    public static void oppContractorSharingMgrGrp(List<Opportunity> newOppList){
        OpportunityTriggerOperations.oppContractorSharingMgrGrp(newOppList);
    }
    
    //Description : Method to recalculate the opportunity sharing when assigned AE (Only for Contractor AE) changes
    
    public static void updateOpportunityShares(Map<Id,Opportunity> oldOppMap,List<Opportunity> newOppList){
        OpportunityTriggerOperations.recalculateOpportunityShares(oldOppMap,newOppList);
    } 
    
    public static void validateOpportunityOnClosedWon(List<Opportunity> newOppList, Map<Id,Opportunity> oldOppMap){
        OpportunityTriggerOperations.validateOpportunityOnClosedWon(newOppList,oldOppMap);
    }
    /*
    Name : sendEmailToDetermineAssignedCARonProperty
    Description : This method is used to send email to Regional lead of the property's region when Assigned CAR field on Property is NULL and to the CAR manger (Manager of Assigned CAR) when the Assigned CAR field is not NULL.
    Return : void
    Author : Tejaswini Kasar
    User Story : US978554 
    */
    public static void sendEmailToDetermineAssignedCARonProperty(Map<Id,Opportunity> oldOppMap,List<Opportunity> newOppList ){
        OpportunityTriggerOperations.sendEmailToDetermineAssignedCARonProperty(oldOppMap,newOppList);
    }
}