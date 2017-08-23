/**
 * Controller for the visual gauge on the store detail page
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 12/5/14
 */

public with sharing class StoreGaugeController {

	public Account store;
	public OrdersGauge OrdersVsGoalGauge {get;set;}
	public OrdersGauge TrendingOrdersVsGoalGauge {get;set;}
	public OrdersGauge ActivationsVsGoalGauge {get;set;}
	public OrdersGauge TrendingActivationsVsGoalGauge {get;set;}
	public OrdersChart PastSevenDaysChart {get;set;}

	public StoreGaugeController(ApexPages.StandardController stdCon) {
		Id storeId = stdCon.getId();
		this.store = getStore(storeId);
		OrdersVsGoalGauge = new OrdersGauge(this.store.Monthly_RGU_Order_Goal__c, this.store.RGU_Orders_This_Fiscal_Month__c);
		TrendingOrdersVsGoalGauge = new OrdersGauge(this.store.Monthly_RGU_Order_Goal__c, this.store.RGU_Order_Flash_Rate__c);
		ActivationsVsGoalGauge = new OrdersGauge(this.store.Monthly_RGU_Activations_Goal__c, this.store.RGU_Activations_This_Fiscal_Month__c);
		TrendingActivationsVsGoalGauge = new OrdersGauge(this.store.Monthly_RGU_Activations_Goal__c, this.store.RGU_Activation_Flash_Rate__c);
		PastSevenDaysChart = new OrdersChart(getOrders(storeId));
		
	}

	public Account getStore(Id storeId) {
		return [ 
			SELECT Monthly_RGU_Activations_Goal__c, Monthly_RGU_Order_Goal__c, RGU_Activations_This_Fiscal_Month__c, 
				RGU_Orders_This_Fiscal_Month__c, RGU_Order_Flash_Rate__c, RGU_Activation_Flash_Rate__c
			FROM Account
			WHERE Id = :storeId];
	}

	public List<RGU_Order__c> getOrders(Id storeId) {
		try {
			return [
				Select Id, Store__c, Activity_Status__c, Activation_Date__c, Order_Date__c
				FROM RGU_Order__c
				WHERE Store__c = :storeId
				AND (Order_Date__c = LAST_N_DAYS:8
				OR Activation_Date__c = LAST_N_DAYS:8)];
		}
		catch(QueryException ex) {
			System.debug('#################################################################################################');
			List<RGU_Order__c> dummyList = new List<RGU_Order__c>();
			dummyList.add(new RGU_Order__c());
			return dummyList;
		}
	}

}