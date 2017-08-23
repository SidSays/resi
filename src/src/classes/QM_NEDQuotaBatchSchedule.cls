/**************************************************************************************************
Name : QM_NEDQuotaBatchSchedule
Description : This batch class is created to create Goals and Metric value data on Yearly basis for AE and AE managers 
with Sales Rep Type as Region.
User Story : US680963 - Coach - Quota Mgmt: Quota for NED Small Property Team
Date : 11 May 2016
Author : Sucheta Verma 
***************************************************************************************************/
global class QM_NEDQuotaBatchSchedule implements Schedulable{
 /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        
        String queryString = ''; 
        if(System.Label.QM_NEDQuotaBatchLabel != Null){
            queryString = System.Label.QM_NEDQuotaBatchLabel;
        }
        
        Integer batchSize=200;
        if(System.Label.QM_NEDQuotaBatchSize!=null && System.Label.QM_NEDQuotaBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.QM_NEDQuotaBatchSize);
        }
        
        QM_NEDQuotaBatch qmNEDQuotabatch = new QM_NEDQuotaBatch(queryString);
        if(!Test.isRunningTest()){ 
            database.executebatch(qmNEDQuotabatch, batchSize);
        }
   }
}