public with sharing class Orders {  
public Order__c custOrder
{
	get;
	set;
}
List<Order_Line_Item__c> orderLineItemList;

 public void setorderLineItemList(List<Order_Line_Item__c> ordList) {
     	// orderList = new List<Order__c>();  
        orderLineItemList = ordList;
    }
     /*public List<Order_Line_Item__c> getorderList() {
        return orderLineItemList;
    }*/

}