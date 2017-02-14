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

global class LeadTransferAndExpirationBatch implements Database.Batchable<sObject>{

    public string query = 'Select Id, OwnerId, Owner.Profile.Name, CreatedDate, Affiliate_Account__c, Affiliate_Account__r.LeadExpirationDuration__c, Affiliate_Account__r.LeadTransferDuration__c from Lead where IsConverted=false And Status!=\'Closed\' And Owner.Profile.Name=\'Integration User\'';
/***********************************************************************************************************************************
     * Author     : Erin McGee
     * Date       : 04-Apr-2014
     * Param      : BatchableContext
     * Return     : Database.querylocator
     * Description: This method is called when the batch process starts and gathers data to tranfer and expire.
************************************************************************************************************************************/
    global Database.querylocator start(Database.BatchableContext BC){
        system.debug(query);        
        return Database.getQueryLocator(query);
    }
    
/***********************************************************************************************************************************
     * Author     : Erin McGee
     * Date       : 04-Apr-2014
     * Param      : Database.BatchableContext, List<Lead>
     * Return     : None
     * Description: This method called after the start method to execute batch task. Ttranfers and expires Leads.
************************************************************************************************************************************/    
    global void execute(Database.BatchableContext BC, List<Lead> scope){
    
            List<Lead> listLeadsToUpdate = new List<Lead>();
        // Iterate Leads and Transfer or Expire which meets the criteria.
        for(Lead lead : (List<Lead>)scope){
            if(lead.Affiliate_Account__r.LeadExpirationDuration__c!=null || lead.Affiliate_Account__r.LeadTransferDuration__c!=null){
                Integer numberOfDays = lead.CreatedDate.date().daysBetween(Date.today());
                if(lead.Affiliate_Account__r.LeadExpirationDuration__c!=null && numberOfDays > lead.Affiliate_Account__r.LeadExpirationDuration__c){
                    lead.status = 'Closed';
                    listLeadsToUpdate.add(lead);
                }else if(lead.Affiliate_Account__r.LeadTransferDuration__c!=null && numberOfDays > lead.Affiliate_Account__r.LeadTransferDuration__c){
                    lead.OwnerId = EnvironmentSpecificIds__c.getValues('TransferLeadAndOpty').Id__c;
                    listLeadsToUpdate.add(lead);
                }
            }
        }
        
        try {
            Database.update(listLeadsToUpdate,false);
        }catch(Exception ex) {
            System.debug('Following exception occurred while updating Leads:'+ex);
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