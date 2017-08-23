/**
 *This controller is used to query the content for displaying the charts on Indirect Store
 *
 * @author Radhika Bansal
 * @date 6/May/2016
 */

public with sharing class IndirectStoreGaugeController {

  @AuraEnabled
  public Account store;
  @AuraEnabled
  public static IndirectOrdersChart PastSevenDaysChart {get;set;}

   @AuraEnabled
  public static IndirectOrdersChart getPastSevenDaysChart(String storeId) {  
    PastSevenDaysChart = new IndirectOrdersChart(getOrders(storeId));    
      return PastSevenDaysChart;
  }
  
   @AuraEnabled 
  public static List<RGU_Order__c> getOrders(Id storeId) {  
      try {
      return [
        Select Id, Store__c, Activity_Status__c, Activation_Date__c, Order_Date__c
        FROM RGU_Order__c
        WHERE Store__c = :storeId
        AND (Order_Date__c = LAST_N_DAYS:8
        OR Activation_Date__c = LAST_N_DAYS:8)];
    }
    catch(QueryException ex) {      
      List<RGU_Order__c> dummyList = new List<RGU_Order__c>();
      dummyList.add(new RGU_Order__c());        
      return dummyList;
    }
  }

}