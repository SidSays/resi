/***********************************************************
* Class Name: OrderLineItemTriggerControllerTest
* Author: Raju Patel, Accenture
* Date: 24-Oct-2013 
* Description: This class does the test coverage
*              for OrderLineItemTriggerController class.
***********************************************************/
@isTest
private class OrderLineItemTriggerControllerTest{
    
    public static testMethod void TestActivityStatusOnOrder() {
    SetupTestData.createCustomSettingRecords();

    //Creating new Order.
    Order__c ord = new Order__c();
    ord.Name = 'TestOrder';
    ord.Order_Number__c = '1';  
    insert ord;
    //Creating New Order Line Item related to the order created above.
    Order_Line_Item__c oli = new Order_Line_Item__c();
    oli.Name = 'Test Orderlineitem';
    oli.Order__c = ord.Id;
    oli.RECON_Status__c = 'Pending';
    insert oli;
    
    
    //Creating New Order Line Item related to the order created above.
    Order_Line_Item__c oli1 = new Order_Line_Item__c();
    oli1.Name = 'Test Orderlineitem1';
    oli1.Order__c = ord.Id;
    oli1.RECON_Status__c = 'Not Eligible';
    insert oli1;
    
    
    //Creating New Order Line Item related to the order created above.
    Order_Line_Item__c oli2 = new Order_Line_Item__c();
    oli2.Name = 'Test Orderlineitem2';
    oli2.Order__c = ord.Id;
    oli2.RECON_Status__c = 'Duplicate';
    insert oli2;
    
    oli2.RECON_Status__c = 'Abandoned';
    update oli2;//Updating the Order Line Item.
    Order__C CurrentOrder1 = [Select Id, Name, Activity_Status__c from Order__C where Id =: ord.id];
    system.debug('activity status>>>>>' + CurrentOrder1.Activity_Status__c);
    Order_Line_Item__c oli3 = new Order_Line_Item__c();
    oli3.Name = 'Test Orderlineitem3';
    oli3.Order__c = CurrentOrder1.Id;
    oli3.RECON_Status__c = 'Pending Chargeback';
    insert oli3;
   
    Order__C CurrentOrder = [Select Id, Name, Activity_Status__c from Order__C where Id =: ord.id];
    system.debug('>>>>>>oli3 Current Activity Status : ' + CurrentOrder.Activity_Status__c);
    system.AssertEquals(CurrentOrder.Activity_Status__c, 'CANCELLED');
    }
}