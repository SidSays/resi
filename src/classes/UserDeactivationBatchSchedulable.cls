/**************************************************************************************************
Name : UserDeactivationBatchSchedulable
Description : This batch class created to schedule deactivating users on daily basis.
User Story : US608950
Date : 21/Jan/2016
Author : Radhika Bansal
***************************************************************************************************/
global class UserDeactivationBatchSchedulable implements Schedulable{
 /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        //String query='SELECT Name, Id,LastLoginDate,CreatedDate FROM User WHERE (LastLoginDate < LAST_N_DAYS:45 OR (CreatedDate < LAST_N_DAYS:45 AND LastLoginDate = NUll)) AND IsActive = TRUE ORDER BY LastLoginDate DESC NULLS FIRST';    
        String queryString = ''; 
        if(System.Label.Deactivation_Reason != Null && System.Label.Success_Deactivate_users != Null && System.Label.Failed_Deactivate_User != Null){
            queryString = System.Label.deactivateUsersString;
        }
        UserDeactivationBatch deactivateUsersObj = new UserDeactivationBatch(queryString); 
        database.executebatch(deactivateUsersObj);

   }
}