/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal
 * Date       : 11-October-2013
 * Description: This class will be scheduled using 'Schedule Apex' feature of salesforce.
 * Requirement: 
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal 
     PROJECT             : Enhancements
***************************************************************************************************************************************/
global class ScheduleUpdateOpportunityNameBatch implements Schedulable{ 
/***********************************************************************************************************************************
     * Author     : Gaurav Aggarwal
     * Date       : 11-October-2013
     * Param      : SchedulableContext 
     * Return     : None
     * Description: This method will start the batch process that updates opportunity names on daily basis.
************************************************************************************************************************************/
    global void execute(SchedulableContext sc) {
      UpdateOpportunityNameBatch UpdateOpportunityNameBatchObj = new UpdateOpportunityNameBatch(); 
      database.executebatch(UpdateOpportunityNameBatchObj);
   }
}