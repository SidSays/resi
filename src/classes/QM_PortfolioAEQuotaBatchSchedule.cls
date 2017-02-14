/**************************************************************************************************
Name : QM_PortfolioAEQuotaBatchSchedule
Description : This batch class created to schedule QM_PortfolioAEQuotaBatch
User Story : US681279
Date : 10 May 2016
Author : Prateek Saxena 
***************************************************************************************************/
global class QM_PortfolioAEQuotaBatchSchedule implements Schedulable{
 /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        //String query='Select Id, Name, ManagerId,Profile.name,Manager.Profile.Name,Comcast_Division__c,ProfileId,Sales_Rep_Type__c,UserPermissionsWorkDotComUserFeature from User where  IsActive = True AND  Sales_Rep_Type__c =:portRepType  and UserPermissionsWorkDotComUserFeature = true';    
        String queryString = ''; 
        if(System.Label.CreatePortfolioAEQuotaBatchQueryStringLabel != Null){
            queryString = System.Label.CreatePortfolioAEQuotaBatchQueryStringLabel;
        }
        
        Integer batchSize=200;
        if(System.Label.QM_PortfolioAEQuotaBatchSize!=null && System.Label.QM_PortfolioAEQuotaBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.QM_PortfolioAEQuotaBatchSize);
        }
        
        QM_PortfolioAEQuotaBatch portfolioAEBatch = new QM_PortfolioAEQuotaBatch(queryString);
        if(!Test.isRunningTest()){ 
            database.executebatch(portfolioAEBatch, batchSize);      
        }
   }
}