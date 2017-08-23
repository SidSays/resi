/*
*  Sequencer class to call PhaseStatsTriggerOperations method
*/
public class PhaseStatsTriggerSequencer{
    
    /*
    * after InsertOrUpdate Operation call for PhaseStats
    */
    public static void afterUpdateOperation(){
        PhaseStatsTriggerOperations.afterUpdatePhaseStats();
    }
    
    /*
    * after Insert Operation call for PhaseStats
    */
    public static void afterInsertOperation(){
        PhaseStatsTriggerOperations.afterInsertPhaseStats();
    }
    
     /*
    * after delete Operation call for PhaseStats
    */
    public static void afterDeleteOperation(){
        PhaseStatsTriggerOperations.afterDeletePhaseStats();
    }

}