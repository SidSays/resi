/***************************************************************************************************************************************
 * Class      : BulkServiceTriggerSequencer
 * Author     : Ashish G. Sonawane, Accenture
 * Date       : 23-January-2015 
 * Description: Sequencer class to call BulkServiceTriggerOperation method.
 */

public class BulkServiceTriggerSequencer{
     /*
    * Description :  Method to create new Bulk Service Record
    * Date        : 23-January-2015 
    * Param       : none   
    * Return      : void.
    */
    public static void afterInsertOperation(){
       BulkServiceTriggerOperation.afterInsertNewBulkservice();
    }
}