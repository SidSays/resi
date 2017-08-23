/**************************************************************************************************
* Name : MDUAccountDeleteBatchSchedule
  Description : This Schedulable class created to schedule batch job that will autodelete account
  User Story : 78
  Date : 16 January 2015
  Author : Ashish Sonawane
* Last Modified By : Amit Kumar Pradhan
  Last Modified Date : 25-Feb-2017
  User Story : US917335
  Description : made the "MDUAccountDeleteBatchbatch" batch class as parameterized 
***************************************************************************************************/

global class MDUAccountDeleteBatchSchedule implements Schedulable {
  /*
   * This method schedule batch able class at specified time
   */
   global void execute(SchedulableContext schedulableContext) {
        //Start : Added By Amit Kumar Pradhan(Part Of US917335)
        /****
        * Calling MDUAccountDeleteBatch
        * The query string passed while batch is executed.
        * 'SELECT Id, Is_Parent_Organization__c, Name FROM Account WHERE Is_Parent_Organization__c = false and RecordTypeId IN: recordTypeIds'   
        *****/
        String queryString = '';
        if(System.Label.MDUAccountDeleteBatchLabel != Null){
            queryString = System.Label.MDUAccountDeleteBatchLabel;
        }
        //End : Added By Amit Kumar Pradhan(Part Of US917335)
        Integer batchSize=200;
        if(System.Label.XCAccountDeleteBatchSize!=null && System.Label.XCAccountDeleteBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.XCAccountDeleteBatchSize);
        }
        MDUAccountDeleteBatch propertyAccountDeleteBatch = new MDUAccountDeleteBatch(queryString); 
        database.executebatch(propertyAccountDeleteBatch, batchSize);
   }
}