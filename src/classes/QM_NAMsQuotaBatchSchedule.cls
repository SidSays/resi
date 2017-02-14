/**************************************************************************************************
Name : QM_NAMsQuotaBatchSchedule
Description : This batch class is created to create Goals and Metric value data on Yearly basis for AE and AE managers 
with Sales Rep Type as NAM.
User Story : US680953 - Coach - Quota Mgmt: Quota for NAMs
Date : 11 May 2016
Author : Sucheta Verma 
***************************************************************************************************/
global class QM_NAMsQuotaBatchSchedule implements Schedulable{
 /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        
        String queryString = ''; 
        if(System.Label.QM_NAMsQuotaBatchLabel != Null){
            queryString = System.Label.QM_NAMsQuotaBatchLabel;
        }
        
        Integer batchSize=200;
        if(System.Label.QM_NAMsQuotaBatchSize!=null && System.Label.QM_NAMsQuotaBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.QM_NAMsQuotaBatchSize);
        }       
       
        QM_NAMsQuotaBatch qmNAMQuotabatch = new QM_NAMsQuotaBatch(queryString);         
        if(!Test.isRunningTest()){
            database.executebatch(qmNAMQuotabatch, batchSize);
        }       
   }
}