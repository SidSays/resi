/***************************************************************************************************************************************
 * Author     : Comcast Resi
 * Date       : 02-Sept-2015
 * Description: Batch Class will be used to update the Addresses associated to Inactive User. US513099(Sprint-9)
***************************************************************************************************************************************/
global class UserInactiveAddressBatch implements Schedulable{
    
    global void execute(SchedulableContext schContext)
    {
     Database.executeBatch(new UserInactiveAddressUpdateBatch(),100);        
    }
}