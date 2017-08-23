/**************************************************************************************************
* Name : MduContractAutoRenewBatchSchedule
  Description : This Schedulable class created to schedule batch job that will reschedule contract status (This shall be set nightly at midnight (must run before Risk Status).).   
  User Story : 24
  Date : 16 January 2015
  Author : Ashish Sonawane
* Last Modified By : Amit Kumar Pradhan
  Last Modified Date : 25-Feb-2017
  User Story : US917335
  Description : made the "MduContractAutoRenewBatch" batch class as parameterized 
***************************************************************************************************/

global class MDUContractAutoRenewBatchSchedule implements Schedulable {
  /*
   * This method schedule batch able class at specified time
   */
    global void execute(SchedulableContext schedulableContext){
        //Start : Added By Amit Kumar Pradhan(Part Of US917335)
        /****
        * Calling MduContractAutoRenewBatch
        * The query string passed while batch is executed.
        * 'SELECT Id, Data__c, Renewal_Term__c, Renewal_Term_Unit__c, Sub_Status__c, Effective_Date__c, Expiration_Date__c, Property__r.Id, Auto_Renewal_Limit__c, Contract__c.RecordTypeId, Auto_Renewal_Count__c FROM Contract__c WHERE Expiration_Date__c < = TODAY AND Expiration_Date__c != null AND CALENDAR_YEAR(Expiration_Date__c) > 1970 AND Archived__c != True AND (Renewal_Term__c != null and Renewal_Term__c >= 1) AND Renewal_Term_Unit__c != null AND (Property__r.Comcast_Video_Serviced__c = 'Yes' OR Property__r.Comcast_Voice_Serviced__c = 'Yes' OR Property__r.Comcast_Data_Serviced__c = 'Yes') AND (Data__c = 'Yes' Or Video__c = 'Yes' or Voice__c = 'Yes') AND (Auto_Renewal_Limit__c = null OR Auto_Renewal_Limit__c >= 0) AND IsRenewalCountNotExceed__c = 'true' AND Contract__c.RecordTypeId IN: recordTypeIds'  
        *****/
        String queryString = '';
        if(System.Label.MDUContractAutoRenewBatchLabel != Null){
            queryString = System.Label.MDUContractAutoRenewBatchLabel;
        }
        //End : Added By Amit Kumar Pradhan(Part Of US917335)       
        Integer batchSize=200;
        if(System.Label.XCContractAutoRenewBatchSize!=null && System.Label.XCContractAutoRenewBatchSize.isNumeric()){
            batchSize=Integer.valueOf(System.Label.XCContractAutoRenewBatchSize);
        }
        MduContractAutoRenewBatch contractAutoRenewBatch = new MduContractAutoRenewBatch(queryString);
        database.executebatch(contractAutoRenewBatch,batchSize);
    }
}