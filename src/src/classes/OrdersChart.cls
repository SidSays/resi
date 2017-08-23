/**
 * Decorator Class for RGU Orders and Activations Chart
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com>
 * @date 12/12/14
 */
public with sharing class OrdersChart {

	public Integer SeventhDayOrderCount {get; private set;}
	public Integer SeventhDayActivationCount {get; private set;}
	public Integer SixthDayOrderCount {get; private set;}
	public Integer SixthDayActivationCount {get; private set;}
	public Integer FifthDayOrderCount {get; private set;}
	public Integer FifthDayActivationCount {get; private set;}
	public Integer FourthDayOrderCount {get; private set;}
	public Integer FourthDayActivationCount {get; private set;}
	public Integer ThirdDayOrderCount {get; private set;}
	public Integer ThirdDayActivationCount {get; private set;}
	public Integer SecondDayOrderCount {get; private set;}
	public Integer SecondDayActivationCount {get; private set;}
	public Integer FirstDayOrderCount {get; private set;}
	public Integer FirstDayActivationCount {get; private set;}
	
	private final String ACTIVITY_STATUS = 'Activated';

	public OrdersChart(List<RGU_Order__c> orders) {
		System.debug('#####################################################################: ' + orders);
		this.SeventhDayOrderCount = 0;
		this.SeventhDayActivationCount = 0;
		this.SixthDayOrderCount = 0;
		this.SixthDayActivationCount = 0;
		this.FifthDayOrderCount = 0;
		this.FifthDayActivationCount = 0;
		this.FourthDayOrderCount = 0;
		this.FourthDayActivationCount = 0;
		this.ThirdDayOrderCount = 0;
		this.ThirdDayActivationCount = 0;
		this.SecondDayOrderCount = 0;
		this.SecondDayActivationCount = 0;
		this.FirstDayOrderCount = 0;
		this.FirstDayActivationCount = 0;

		List<Date> dateList = pastSevenDaysList();

		for (RGU_Order__c order : orders) {
			//count Orders
			if (order.Order_Date__c == dateList.get(6)){
				this.SeventhDayOrderCount ++;
			}
			else if (order.Order_Date__c == dateList.get(5)) {
				this.SixthDayOrderCount ++;
			}
			else if (order.Order_Date__c == dateList.get(4)) {
				this.FifthDayOrderCount ++;
			}
			else if (order.Order_Date__c == dateList.get(3)) {
				this.FourthDayOrderCount ++;
			}
			else if (order.Order_Date__c == dateList.get(2)) {
				this.ThirdDayOrderCount ++;
			}
			else if (order.Order_Date__c == dateList.get(1)) {
				this.SecondDayOrderCount ++;
			}
			else if (order.Order_Date__c == dateList.get(0)) {
				this.FirstDayOrderCount ++;
			}

			//count Activations
			if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(6)){
				this.SeventhDayActivationCount ++;
			}
			else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(5)) {
				this.SixthDayActivationCount ++;
			}
			else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(4)) {
				this.FifthDayActivationCount ++;
			}
			else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(3)) {
				this.FourthDayActivationCount ++;
			}
			else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(2)) {
				this.ThirdDayActivationCount ++;
			}
			else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(1)) {
				this.SecondDayActivationCount ++;
			}
			else if (isOrderActivated(order) && order.Activation_Date__c == dateList.get(0)) {
				this.FirstDayActivationCount ++;
			}
		}

	}

	public List<Date> pastSevenDaysList() {
		List<Date> dateList = new List<Date>();
		for (Integer i = 1; i < 8; i++) {
			dateList.add(Date.today().addDays(-i));
		}

		return dateList;
	}

	public Boolean isOrderActivated(RGU_Order__c order) {
		return order.Activity_Status__c == ACTIVITY_STATUS;
	}

}