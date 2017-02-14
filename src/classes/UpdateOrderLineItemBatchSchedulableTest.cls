/***************************************************************************************************************************************
* @Author: Apurva Gandhi, Accenture
    * @Description: This is test class for UpdateOrderLineItemBatchSchedulable & UpdateOrderLineItemBatch
    * @Request id:456 (Develop batch job to update existing records with the new Recon Activity Status.)
    * @Date: 2-Dec-2013
***************************************************************************************************************************************/
@isTest
private class UpdateOrderLineItemBatchSchedulableTest{
    public static String CRON_EXP = '0 0 0 3 9 ? 2022';
    private static testMethod void testUpdateOrderLineItemBatchScheduble(){
        Test.StartTest();
        UpdateOrderLineItemBatchSchedulable UpdateOrderLineItemBatchSchedulableObj = new UpdateOrderLineItemBatchSchedulable();
        String scheduledJobId = System.schedule('testScheduledApex', CRON_EXP, UpdateOrderLineItemBatchSchedulableObj);
        Test.StopTest();
    }

    private static testMethod void testUpdateOrderLineItemBatch(){
        SetupTestData.createCustomSettingRecords();
        Customer_Address__c address1 = new Customer_Address__c();
        address1.Address__c = 'Test Address Line1';
        address1.City__c = 'Test city';
        address1.State__c = 'Test State';
        address1.PostalCode__c = '98564';
        address1.Country__c = 'Test Country';
        address1.Corp__c = '111111';
        address1.Route_Code__c = '1111111111';
        address1.Node__c = '1111';
        address1.Assigned_Date__c = Date.today()-10;
        address1.Latitude__c = 11.1111;
        address1.Longitude__c = 22.2222;
        address1.Last_Knock_Date__c = System.now();
        address1.Most_Recent_Disposition__c = 'Contact';
        insert address1; 
    
        Account acc = new Account();
        acc.Name = 'TestAccount';
        acc.Customer_Status__c = 'Active';
        acc.Installation_Status__c = 'Active';
        acc.Region__c = null;
        acc.Service_Address__c = address1.Id;
        insert acc;   

        Order__c order = new Order__c();
        order.Name = 'TestOrder';
        order.Order_Number__c = '1';  
        order.Salesperson_ID__c = 'abc1111';//Giving the sales ID of the user.
        order.Account__c = acc.Id;
        insert order;
    
        Order_Line_Item__c orderLineItem = new Order_Line_Item__c();
        orderLineItem.Order__c = order.Id;
        insert orderLineItem;

        Test.startTest();
        UpdateOrderLineItemBatch uolib = new UpdateOrderLineItemBatch();
        uolib.query='SELECT id,RECON_Status__c,Order__c from Order_Line_Item__c where Id=\''+orderLineItem.Id+'\'';
        database.executebatch(uolib);
        Test.stopTest();
    }

}