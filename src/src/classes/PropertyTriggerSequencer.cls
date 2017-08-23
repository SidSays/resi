/*
* Name: PropertyTriggerSequencer
* Description: Sequencer class for PropertyTrigger
* Last Modified By: Tejaswini Kasar
* Last Modified Date : 5th MAY 2017
* Desciption : Adding method "sendEmailForExpiredRiskStatusonProperty" of apex class PropertyTriggerOperations  related US978557( XC - Workflow alerts for CARs, CAR manager an XC Analyst).
*/
public class PropertyTriggerSequencer{
  
    /*
    * after update call
    */
    public static void afterUpdate(){
        PropertyTriggerOperations.changeContractUnitOnAddressUpdate();
    } 
    
    /*
    * after update of # Units On Property 
    */
    public static void changeUnitsOnOpportunityProperty(){
        PropertyTriggerOperations.changeUnitsOnOpportunityProperty();
    } 
    
    /*
    * before delete call
    */
    public static void beforeDelete(){
        PropertyTriggerOperations.deleteProperty();
    } 
    
       public static void deletePropertyCheck(List<MDU_Property__c> propList){
        PropertyTriggerOperations.deletePropertyCheck(propList);
    } 
    
        /*
    * before delete call
    */
    public static void beforeInsertUpdate(){
        PropertyTriggerOperations.percentProfileCalculation();
       // PropertyTriggerOperations.OldNewRegionMapping();
    } 
    
    public static void OldNewRegionUpdate(){
        PropertyTriggerOperations.OldNewRegionMapping();
    }
     
    /*Added by : Tejaswini
    * Last Modified Date : 5th MAY 2017
    */
    public static void sendEmailForExpiredRiskStatusonProperty(Map<Id,MDU_Property__c> oldPropMap,List<MDU_Property__c> newPropList){
        PropertyTriggerOperations.sendEmailForExpiredRiskStatusonProperty(oldPropMap,newPropList);
    } 
    

}