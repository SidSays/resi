/**************************************************************************************************
Name : RegionalBaselineQuotaBatchSchedule
Description : This batch class is created to create Goals and Metric value data on Yearly basis for AE and AE managers 
with Sales Rep Type as Region.
User Story : US680915
Date : 11 May 2016
Author : Sucheta Verma 
***************************************************************************************************/
global class RegionalBaselineQuotaBatchSchedule implements Schedulable{
 /*
   * This method schedule batch class at specified time
   */
   global void execute(SchedulableContext schedulableContext){
        // The query string passed while batch is executed.
        //String query='Select Id,Name,profile.name,Region__c,Sales_Rep_Type__c,Level__c, ManagerId,Manager.ManagerId from User where  IsActive = True AND profile.name IN: profileName and UserPermissionsWorkDotComUserFeature = true ';    
        String queryString = ''; 
        if(System.Label.RegionalBaselineQuotaBatchLabel != Null){
            queryString = System.Label.RegionalBaselineQuotaBatchLabel;
        }
        
        Integer batchSize=200;
        if(System.Label.RegionalBaselineQuotaBatchSize!=null && System.Label.RegionalBaselineQuotaBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.RegionalBaselineQuotaBatchSize);
        }
        
        RegionalBaselineQuotaBatch regionalBaselineQuotaBatchtemp = new RegionalBaselineQuotaBatch(queryString);
        if(!Test.isRunningTest()){ 
            database.executebatch(regionalBaselineQuotaBatchtemp, batchSize);
        }
   }
}