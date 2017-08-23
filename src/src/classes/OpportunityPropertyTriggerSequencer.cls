/*
* Name: OpportunityPropertyTriggerSequencer
* Description: Sequencer class for PortfolioPropertyTrigger
*/
public class OpportunityPropertyTriggerSequencer{
   
    public static void beforeInsertOperation(){
    
        OpptyPropertyTriggerOperations.setPrimaryPropeertyOrFireValidation();
    } 
    
    public static void setOpptyPortFolioName(){
    
        OpptyPropertyTriggerOperations.setOpptyPortFolioName();
    }
    
    public static void beforeDeleteOperation(){
    
        OpptyPropertyTriggerOperations.setPrimaryPropeertyOnDelete();
    }  
    
    public static void activeOpptyFlagOnProperty(){
        
        OpptyPropertyTriggerOperations.activeOpptyFlagOnProperty();    
    }  
    
     public static void activeOpptyFlagOnPropertyForDelete(){
        
        OpptyPropertyTriggerOperations.activeOpptyFlagOnPropertyForDelete();    
    }  

}