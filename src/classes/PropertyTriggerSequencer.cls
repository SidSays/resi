/*
* Name: PropertyTriggerSequencer
* Description: Sequencer class for PropertyTrigger
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
    

}