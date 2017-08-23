/**************************************************************************************************
Name : CrossRegionXCGoalBatchSchedule
Description : This scheduler class is created to schedule CrossRegionXCGoalBatch to create Xfinity Communities Goals and Metric value data on Annual basis for Cross Regional Lead.
User Story : US960508
Date : 24 February 2017
Author : Ashish Srivastava
***************************************************************************************************/
global class CrossRegionXCGoalBatchSchedule implements Schedulable{
 /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        //String query = 'Select Id, Name, Region__c, Profile.Name from User where IsActive = True AND Profile.Name IN: profileNameSet and UserPermissionsWorkDotComUserFeature = true';
        String queryString = ''; 
        if(System.Label.CrossRegionXCGoalBatchQuery != Null){
            queryString = System.Label.CrossRegionXCGoalBatchQuery;
        }
        
        Integer batchSize=200;
        if(System.Label.CrossRegionXCGoalBatchSize!=null && System.Label.CrossRegionXCGoalBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.CrossRegionXCGoalBatchSize);
        }
        
        CrossRegionXCGoalBatch crossRegionXCGoalBatchtemp = new CrossRegionXCGoalBatch(queryString);
        if(!Test.isRunningTest()){ 
            database.executebatch(crossRegionXCGoalBatchtemp, batchSize);
        }
   }
}