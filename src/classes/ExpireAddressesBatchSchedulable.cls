/**
* Class Name: ExpireAddressesBatchSchedulable 
* Author: Amitkumar Bangad, Accenture
* Date: 02-May-2013 
* Requirement # Request Id: 218
* Description: This is schedulable class for ExpireAddressBatch Class.
* Last Modified :
*/
global with sharing class ExpireAddressesBatchSchedulable implements Schedulable {
    
  /**  public Integer batchSize {get;set;} **/
    
    /**
     * @description - Constructor, initialises the batch size.
     */
  /**  global ExpireAddressesBatchSchedulable() {
        batchSize = 1;
    } **/
    
    /**
     * @description - Calls batch process with configured batch size.
     * @param SchedulableContext schContext 
     */
     
        
    global void execute(SchedulableContext schContext) {
        Integer batchSize=200;
        if(System.Label.ExpireAddressesBatchSize!=null && System.Label.ExpireAddressesBatchSize.isNumeric()){
           batchSize=Integer.valueOf(System.Label.ExpireAddressesBatchSize);
        } 
      //  ID batchProcessId;
        ExpireAddressesBatch expAddObj = new ExpireAddressesBatch();
        Database.executeBatch(expAddObj, batchSize);
    }
}