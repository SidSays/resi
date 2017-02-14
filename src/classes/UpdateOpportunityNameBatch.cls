/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal
 * Date       : 11-October-2013
 * Description: This batch will run daily to update the Opportunity names.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal
     PROJECT             : Enhancements
***************************************************************************************************************************************/
public class UpdateOpportunityNameBatch implements Database.Batchable<sObject> {
/***********************************************************************************************************************************
     * Author     : Gaurav Aggarwal
     * Date       : 11-October-2013
     * Param      : BatchableContext
     * Return     : Database.querylocator
     * Description: This method is called when the batch process starts and gathers Opportunities for processing.
************************************************************************************************************************************/
    public Database.QueryLocator start(Database.BatchableContext bc) {       
        String queryString = 'Select Id, Account.Name, Name from Opportunity where Name = \'LASTNAME HOME\' OR Name = \'Last Name Home\''; 
        return Database.getQueryLocator(queryString);
    }
/***********************************************************************************************************************************
     * Author     : Gaurav Aggarwal
     * Date       : 11-October-2013
     * Param      : Database.BatchableContext, List<sObject>
     * Return     : None
     * Description: This method called after the start method to update opportunity name.
************************************************************************************************************************************/           
    public void execute(Database.BatchableContext bc, List<sObject>  scope) {  
        List<Opportunity> oppList = scope;
        for(Opportunity opp : oppList){
            opp.Name = opp.Account.Name;
        }
        try {
            Database.update(oppList, false);
        } catch(Exception ex) {
            System.debug('Following exception occurred :'+ex.getMessage());
        }   
    }
/***********************************************************************************************************************************
     * Author     : Gaurav Aggarwal
     * Date       : 11-October-2013
     * Param      : Database.BatchableContext
     * Return     : None
     * Description: This method is called at the end and is not used here.
************************************************************************************************************************************/ 
    public void finish(Database.BatchableContext bc) {
    }
}