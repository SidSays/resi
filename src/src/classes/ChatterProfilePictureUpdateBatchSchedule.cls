global class ChatterProfilePictureUpdateBatchSchedule implements Schedulable {
    /*
    * This method schedule batch class at specified time
    */
    global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        /*String query='Select Id,CreatedDate,Name,ProfileId,Region__c,FullPhotoUrl from User where  IsActive = True AND CreatedDate < LAST_N_DAYS:60 AND FullPhotoUrl like \'%/profilephoto/005/F%\' AND SmallPhotoUrl like \'%/profilephoto/005/T%\' AND Chatter_Enabled__c = TRUE';*/
        String queryString = ''; 
        if(System.Label.ChatterProfilePictureUpdateBatchQuery != Null){
            queryString = System.Label.ChatterProfilePictureUpdateBatchQuery;
        }
        ChatterProfilePictureUpdateBatch ChatterProfileBatch = new ChatterProfilePictureUpdateBatch(queryString); 
        database.executebatch(ChatterProfileBatch,1);
    }
}