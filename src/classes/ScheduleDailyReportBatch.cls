/***************************************************************************************************************************************
 * Author     : Vivek Patel
 * Date       : 26-June-2013
 * Description: This class will be scheduled using 'Schedule Apex' feature of salesforce.
 * Requirement: 
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel 
     PROJECT             : Direct Sales
***************************************************************************************************************************************/
global class ScheduleDailyReportBatch implements Schedulable{

/***********************************************************************************************************************************
     * Author     : Vivek Patel
     * Date       : 26-June-2013
     * Param      : SchedulableContext 
     * Return     : None
     * Description: This method will start the batch process that creates or updates Reporting Metric records on daily basis for each DSR.
************************************************************************************************************************************/
   global void execute(SchedulableContext sc) {
      ReportingMetricDailyBatch reportingMetricDailyBatchObj = new ReportingMetricDailyBatch(); 
      database.executebatch(reportingMetricDailyBatchObj, 10);
   }
}