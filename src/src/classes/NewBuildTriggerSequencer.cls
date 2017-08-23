/*
*  Sequencer class to call NewBuildTriggerOperations method
*/
public class NewBuildTriggerSequencer{
    
    /*
    * after Update Operation call for New Build
    */
    public static void afterUpdateOperation(){
        NewBuildTriggerOperations.afterUpdateNewBuild();
    }
    
    /*
    * after Insert Operation call for New Build
    */
    public static void afterInsertOperation(){
        NewBuildTriggerOperations.afterInsertNewBuild();
    }
    
      /*
    * after delete Operation call for New Build
    */
    public static void afterDeleteOperation(){
        NewBuildTriggerOperations.afterDeleteNewBuild();
    }
}