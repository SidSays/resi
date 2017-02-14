/***************************************************************************************************************************************
 * Author     : Vivek Patel
 * Date       : 10-Jan-2013
 * Description: This class will update Customer Field on Account after Lead conversion.
 * Requirement: 11 - Lead, Customer information.
 * History
     Version             : 1.0
     Author Last Updated : Vivek Patel 
     PROJECT             : Turnpike
***************************************************************************************************************************************/

public class LeadTriggerController {

    // This method is called from LeadAfterUpdate Trigger to update CustomerId on Account when Lead is converted.
    
    public static void updateAccount(List<Lead> listNewLeads) {
        List<Account> listAccounts = new List<Account>();        
        Map<Id,Id> mapAccountIdAndContactId = new Map<Id,Id>();
        
        for(Lead leadObj: listNewLeads) {                        
            if(leadObj.IsConverted == true) {
                mapAccountIdAndContactId.put(leadObj.convertedAccountId,leadObj.convertedContactId);
            }
        }
        for(Account accObj:[Select Id, Customer__c from Account where Id in :mapAccountIdAndContactId.keySet()]) {
            System.debug(accObj.Customer__c);
            if(accObj.Customer__c == null) {
                accObj.Customer__c = mapAccountIdAndContactId.get(accObj.Id);
                System.debug(mapAccountIdAndContactId.get(accObj.Id));
                listAccounts.add(accObj);          
            }  
        }
        try{
            Database.update(listAccounts);
        }catch(Exception ex) {
            System.debug('Following exception occurred :'+ex);
        }
    }
 /***************************************************************************************************************************************
 * Author     : Raju Patel, Accenture
 * Date       : 11-Nov-2013
 * Description: This method updates the Activated By field on the Lead object.
 * PROJECT             : Enhancements
***************************************************************************************************************************************/
    public static void updateActivatedByOnlead(){
        Set<String> NTLogins = new Set<String>();
        Map<String,ID> SalesIdByUsername = new Map<String,String>();
        for(Lead lead : (List<Lead>)Trigger.new){
            if(lead.NTLoginLead__c != null){
                NTLogins.add(lead.NTLoginLead__c);
            }
        }
        if(!NTLogins.isEmpty()){
            for(User usr : [Select Id, Name, Sales_ID__c from User where Sales_ID__c IN: NTLogins]){
                SalesIdByUsername.put(usr.Sales_ID__c,usr.Id);
            }
            for(Lead lead : (List<Lead>)Trigger.new){
                lead.ActivatedByLead__c = SalesIdByUsername.get(lead.NTLoginLead__c);
            }
        }
    }
}