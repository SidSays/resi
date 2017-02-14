/*
* Name: ContractTriggerSequencer
* Description: Sequencer class for ContractTrigger
*/
public class ContractTriggerSequencer{
    /*
    * after Insert/update call , here in same mothod we are writing business for insert or update 
    */ 
    public static void atferOperation(){       
        ContractTriggerOperations.afterContractInsertOperation();  
    } 
    
    /*
    * before delete call
    */
    public static void beforeDelete(){
        ContractTriggerOperations.deleteContract();
    }
    
    /*
    * before Insert Or Update call
    */
    public static void expireDateSetInBefore(){
        ContractTriggerOperations.expireDateSetInBefore();
    }   
    /*
    * after Insert/Update/delete call
    */   
    public static void updateCoterminousCheck() {
        ContractTriggerOperations.afterInsertUpdateDelCotermOpp();
    }
}