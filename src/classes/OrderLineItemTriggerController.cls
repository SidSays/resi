/***************************************************************************************************************************************
 * Author     : Gaurav Aggarwal
 * Date       : 25-April-2013
 * Description: Contains Supporting actions for OrderLineItem Triggers
 * Requirement:
 * History
     Version             : 1.0
     Author Last Updated : Gaurav Aggarwal
     PROJECT             : Enhancements
***************************************************************************************************************************************/
public class OrderLineItemTriggerController{
 /**
    * @Description: This method sets Activity Status on Order.
    * @Author: Gaurav Aggarwal, Accenture
    * @Date: 13-May-2013
    * @Param: None
    * @Return: void.
    */
    public static void populateActivityStatusOnOrder(){
        Map<String,String> activityByReconMap = new Map<String,String>();
        Map<Id,String>  orderIdByActivityMap = new Map<Id,String>();
        List<Order__c> odrList = new List<Order__c>();
        List<Integer> odrLineList = new List<Integer>();
        Map<String,Integer> activityStatusPriorityMap = new Map<String,Integer>();
        activityStatusPriorityMap.put('ACTIVATED',1);
        activityStatusPriorityMap.put('CANCELLED',2);
        activityStatusPriorityMap.put('ABANDONED',3);
        activityStatusPriorityMap.put('DUPLICATE',4);
        activityStatusPriorityMap.put('EXISTING',5);
        activityStatusPriorityMap.put('PENDING',6);
        activityByReconMap.put('Abandoned','ABANDONED');
        activityByReconMap.put('Paid','ACTIVATED');
        activityByReconMap.put('Paid Disconnected','ACTIVATED');
        activityByReconMap.put('Paid Final','ACTIVATED');
        activityByReconMap.put('Pending Payment','ACTIVATED');
        activityByReconMap.put('Cancelled','CANCELLED');
        activityByReconMap.put('Worklist Canceled','CANCELLED');
        activityByReconMap.put('Worklist Cancelled','CANCELLED');
        activityByReconMap.put('Charged back','CANCELLED');
        activityByReconMap.put('Partial Charge Back','CANCELLED');
        activityByReconMap.put('Pending Chargeback','CANCELLED');
        activityByReconMap.put('Pending Chargeback Disc','CANCELLED');
        activityByReconMap.put('Pending Not Eligible','CANCELLED');
        activityByReconMap.put('Pending Partial Chargeback','CANCELLED');
        activityByReconMap.put('Duplicate','DUPLICATE');
        activityByReconMap.put('Not Eligible','EXISTING');
        activityByReconMap.put('Completed','PENDING');
        activityByReconMap.put('Pending','PENDING');
        activityByReconMap.put('Pending Cancelled','PENDING');
        activityByReconMap.put('Pending Duplicate','PENDING');
        activityByReconMap.put('Pending Payment Disc','PENDING');
        activityByReconMap.put('Worklist Initiated','PENDING');
        if(Trigger.isInsert){
            for(Order_Line_Item__c  oli : (List<Order_Line_Item__C>)Trigger.new){
                if(!orderIdByActivityMap.containsKey (oli.Order__c)){
                    orderIdByActivityMap.put(oli.Order__c,activityByReconMap.get(oli.Recon_Status__c)); 
                } else {
                    if(activityStatusPriorityMap.get(orderIdByActivityMap.get(oli.Order__c)) > activityStatusPriorityMap.get(activityByReconMap.get(oli.Recon_Status__c))){
                        orderIdByActivityMap.put(oli.Order__c,activityByReconMap.get(oli.Recon_Status__c)); 
                    }
                }
            }   
            if(!orderIdByActivityMap.IsEmpty()){
                for (Order__c ord : [select Id, Name, Activity_Status__c from Order__c where Id=:orderIdByActivityMap.Keyset()]){
                    if(ord.Activity_Status__c != null){
                        if(activityStatusPriorityMap.get(orderIdByActivityMap.get(ord.Id)) < activityStatusPriorityMap.get(ord.Activity_Status__c)){
                            ord.Activity_Status__c = orderIdByActivityMap.get(ord.Id);
                            odrList.add(ord);
                        }                   
                    } else {
                            ord.Activity_Status__c = orderIdByActivityMap.get(ord.Id);
                            odrList.add(ord);
                    }
                }
            }
        }
        
        if(Trigger.IsUpdate){
            set<Id> OrderIds = new set<Id>();
            for(Order_Line_Item__c  oli : (List<Order_Line_Item__C>)Trigger.new){
                    OrderIds.add(oli.Order__c);
            }
            if(!OrderIds.IsEmpty()){
                for(Order_Line_Item__c  oli : [Select Id, Name, Recon_status__c,Order__c FROM Order_Line_Item__c WHERE Recon_status__c != null AND Order__c IN: 
                                                                    OrderIds]){
                    if(!orderIdByActivityMap.containsKey (oli.Order__c)){
                        orderIdByActivityMap.put(oli.Order__c,activityByReconMap.get(oli.Recon_Status__c)); 
                    } else {
                        if(activityStatusPriorityMap.get(orderIdByActivityMap.get(oli.Order__c)) >  activityStatusPriorityMap.get(activityByReconMap.get(oli.Recon_Status__c))){
                            orderIdByActivityMap.put(oli.Order__c,activityByReconMap.get(oli.Recon_Status__c)); 
                        }
                    }                                                   
                }
            }
            for (Order__c ord : [select Id, Name, Activity_Status__c from Order__c where Id=:orderIdByActivityMap.Keyset()]){
                if(ord.Activity_Status__c != null){
                    if(activityStatusPriorityMap.get(orderIdByActivityMap.get(ord.Id)) != activityStatusPriorityMap.get(ord.Activity_Status__c)){
                        ord.Activity_Status__c = orderIdByActivityMap.get(ord.Id);
                        odrList.add(ord);
                    }                 
                }else {
                    ord.Activity_Status__c = orderIdByActivityMap.get(ord.Id);
                    odrList.add(ord);
                }
            }
        }
        if(!odrList.isEmpty()){
            Database.SaveResult[] saveResult;
            try {           
                saveResult = Database.update(odrList, false);
            } catch(Exception ex) {         
                System.debug('Following exception occurred while updating Order :'+ex);
            }
            
            for (Integer i = 0; i < saveResult.size(); i++) {
                if (saveResult[i].isSuccess()) {
                    System.debug('Successfully updated record ID: '+ saveResult[i].getId());
                } else {
                    System.debug('The error reported was: '+ saveResult[i].getErrors()[0].getMessage() + '\n');           
                }
            }
        }
    }
}