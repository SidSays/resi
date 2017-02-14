/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 23-Oct-2013
 * Description: This class updates the Activated By field on the order object.
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal, Accenture 
     PROJECT             : Enhancements
    Version             : 1.1
     Author Last Updated : Erin McGee, Acumen Solutions 
     PROJECT             : 14.02 Backlog
***************************************************************************************************************************************/
public class OrderTriggerController{
/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal, Accenture
 * Date       : 23-Oct-2013
 * Description: This method updates the Activated By field on the order object.
 * PROJECT             : Enhancements
  Version             : 1.1
     Author Last Updated : Erin McGee, Acumen Solutions 
     PROJECT             : 14.02 Backlog
      Date       : 21-Feb-2014
      Description: Updated so that Activated By is populated by NT ID instead of Sales ID, since they can be same in-between regions
***************************************************************************************************************************************/
    public static void updateActivatedByOnOrder(){
        Set<String> NTLogins = new Set<String>();
        Map<String,ID> FedIdByUsername = new Map<String,ID>();
        for(Order__c ord : (List<Order__c>)Trigger.new){
            if(ord.NTLoginOrder__c != null){
                NTLogins.add(ord.NTLoginOrder__c);
            }
        }
        if(!NTLogins.isEmpty()){
            for(User usr : [Select Id, Name, FederationIdentifier from User where FederationIdentifier IN: NTLogins]){
                FedIdByUsername.put(usr.FederationIdentifier.toLowerCase(),usr.Id);
            }
            for(Order__c ord : (List<Order__c>)Trigger.new){
                if(ord.NTLoginOrder__c!=null){
                    ord.ActivatedBy__c = FedIdByUsername.get(ord.NTLoginOrder__c.toLowerCase());
                }
            }
        }
    }
}