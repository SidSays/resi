@isTest
private class OrdersChartTest {
    static testMethod void OrderChartmethod() {
        RGU_Order__c testsRGUOrder = new RGU_Order__c();
            testsRGUOrder.Store_ID__c = '123456';
            testsRGUOrder.Affiliate__c = 'Test Affiliate Store';
            testsRGUOrder.Activity_Status__c  = 'Activated';
            testsRGUOrder.Order_Date__c = Date.today().addDays(-1);
            testsRGUOrder.Activation_Date__c = Date.today();
        
            RGU_Order__c testsRGUOrde = new RGU_Order__c();
            testsRGUOrde.Store_ID__c = '12345';
            testsRGUOrde.Affiliate__c = 'Test Affiliate';
            testsRGUOrde.Activity_Status__c  = 'Activated';
            testsRGUOrde.Order_Date__c = Date.today().addDays(-2);
            testsRGUOrde.Activation_Date__c = Date.today();
        
        
            RGU_Order__c testsRGUOrd = new RGU_Order__c();
            testsRGUOrd.Store_ID__c = '1234';
            testsRGUOrd.Affiliate__c = 'Test';
            testsRGUOrd.Activity_Status__c  = 'Activated';
            testsRGUOrd.Order_Date__c = Date.today().addDays(-3);
            testsRGUOrd.Activation_Date__c = Date.today();        
            
            RGU_Order__c testsRGUOrd1 = new RGU_Order__c();
            testsRGUOrd1.Store_ID__c = '123';
            testsRGUOrd1.Affiliate__c = 'Test aff';
            testsRGUOrd1.Activity_Status__c  = 'Activated';
            testsRGUOrd1.Order_Date__c = Date.today().addDays(-4);
            testsRGUOrd1.Activation_Date__c = Date.today();        
            
            RGU_Order__c testsRGUOrd2 = new RGU_Order__c();
            testsRGUOrd2.Store_ID__c = '12';
            testsRGUOrd2.Affiliate__c = 'Test affi';
            testsRGUOrd2.Activity_Status__c  = 'Activated';
            testsRGUOrd2.Order_Date__c = Date.today().addDays(-5);
            testsRGUOrd2.Activation_Date__c = Date.today();
        
        List<RGU_Order__c> RGUlistOC = new List<RGU_order__c>();
        RGUlistOC.add(testsRGUOrder);
        RGUlistOC.add(testsRGUOrde);
        RGUlistOC.add(testsRGUOrd);
        RGUlistOC.add(testsRGUOrd1);
        RGUlistOC.add(testsRGUOrd2);
        OrdersChart oc =new OrdersChart(RGUlistOC);
  
}

}