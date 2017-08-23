/***************************************************************************************************************************************
 * Author     : Erin McGee
 * Date       : 04-Apr-2014
 * Description: This class will Transfer Leads and Expire Leads.
 * Requirement: 23,95 - Lead Transfer, Lead and Opportunity Expiration.
 * History
     Version             : 1.0
     Author Last Updated : Erin McGee
     PROJECT             : Turnpike
***************************************************************************************************************************************/

global class OpportunityTransferAndExpirationBatch implements Database.Batchable<sObject>{

    public String query = 'Select Id, OwnerId, Owner.Profile.Name, CreatedDate, Affiliate_Account__c, Affiliate_Account__r.OpportunityExpirationDuration__c, Affiliate_Account__r.OpportunityTransferDuration__c from Opportunity where (Opportunity_Expiration_Number_Of_Days__c=true OR Opportunity_Transfer_Number_Of_Days__c=true) And IsClosed=false And Owner.Profile.Name=\'Integration User\' order by CreatedDate';

/***********************************************************************************************************************************
     * Author     : Erin McGee
     * Date       : 04-Apr-2014
     * Param      : BatchableContext
     * Return     : Database.querylocator
     * Description: This method is called when the batch process starts and gathers data to tranfer and expire.
************************************************************************************************************************************/
    global Database.querylocator start(Database.BatchableContext BC){        
        return Database.getQueryLocator(query);
    }
    
/***********************************************************************************************************************************
     * Author     : Erin McGee
     * Date       : 04-Apr-2014
     * Param      : Database.BatchableContext, List<Opportunity>
     * Return     : None
     * Description: This method called after the start method to execute batch task. Ttranfers and expires Leads.
************************************************************************************************************************************/    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
    
            List<Opportunity> listOptyToUpdate = new List<Opportunity>();
        // Iterate Leads and Transfer or Expire which meets the criteria.
        for(Opportunity opp : (List<Opportunity>)scope){            
            Integer numberOfDays = opp.CreatedDate.date().daysBetween(Date.today());
            system.debug(numberOfDays);
            system.debug(opp.Affiliate_Account__r.OpportunityExpirationDuration__c);
            system.debug(opp.Affiliate_Account__r.OpportunityTransferDuration__c);
            if(numberOfDays > opp.Affiliate_Account__r.OpportunityExpirationDuration__c) {
                opp.stageName = 'Closed Lost';
                listOptyToUpdate.add(opp);
            }else if(numberOfDays > opp.Affiliate_Account__r.OpportunityTransferDuration__c){
                opp.ownerId = EnvironmentSpecificIds__c.getValues('TransferLeadAndOpty').Id__c;
                listOptyToUpdate.add(opp);
            }
        }
        try {
            Database.update(listOptyToUpdate,false);
        }catch(Exception ex) {
            System.debug('Following exception occurred while updating Opportunities :'+ex);
        }          
    }
    
/***********************************************************************************************************************************
     * Author     : Erin McGee
     * Date       : 04-Apr-2014
     * Param      : Database.BatchableContext
     * Return     : None
     * Description: This method is called at the end after execute method completes for any notification etc. This method is not used in this class but because of Interface which this class implements this methods is present here.
************************************************************************************************************************************/    
    global void finish(Database.BatchableContext BC){
    }
}