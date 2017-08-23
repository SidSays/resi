/***************************************************************************************************************************************
 * Author     : Comcast Resi
 * Date       : 02-Sept-2015
 * Description: Batch Class will be used to update the Plan associated to Inactive User. US513099(Sprint-9)
***************************************************************************************************************************************/

global class UserInactivePlanBatch implements Schedulable{
    
    global void execute(SchedulableContext schContext)
    {
     Database.executeBatch(new UserInactivePlanUpdateBatch(),100);       
    }
}