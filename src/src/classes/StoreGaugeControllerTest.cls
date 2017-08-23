/**
 * Test Class for Store Gauge Controller
 *
 * @author Ryan Sayles <rsayles@acumensolutions.com> 
 * @date 12/15/14
 */

@isTest
private class StoreGaugeControllerTest {
    static testMethod void controllerTest() {
        SetupTestData.createCustomSettingRecords();

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        UserRole role=[Select Id, DeveloperName, Name From UserRole WHERE Name='Xfinity Sales Rep'];
        RecordType recordType = [SELECT Id FROM RecordType WHERE Name = :'Store'];

        User testUser = StoreTestUtility.createUser('storetestuser@comcast.mi.com', p.Id, 'SNU');
        testUser.UserRoleId = role.Id;
        insert testUser;
        
        User usr = [select Id from User where Id = :UserInfo.getUserId() limit 1];
        
        system.runAs(usr){
        Account testParentAccount = StoreTestUtility.createAccount(testUser.Id);
        testParentAccount.Name = 'Test Affiliate Store';
        insert testParentAccount;
        Account queriredTestParentAccount = [SELECT Id FROM Account WHERE Id = :testParentAccount.Id];
        
         Account parentaccnt = new Account();
          parentaccnt .Name = 'test';
          parentaccnt .Phone = '1234567890';
          parentaccnt .RGU_Orders_This_Fiscal_Month__c =0;
          parentaccnt .RGU_Activations_This_Fiscal_Month__c = 0;
          //parentaccnt .RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Store').getRecordTypeId(); 
          parentaccnt .Store_Type__c = 'Dealer';
          parentaccnt .Store_Location__Latitude__s = 12;
          parentaccnt .Store_Location__Longitude__s= 12;
          insert parentaccnt ;
          
          Parent_Account__c settng = new Parent_Account__c(Name = 'TestAccnt', Parent_Store_Id__c = parentaccnt.Id);
          insert settng;
          
          TriggerSettings__c trgSettng = new TriggerSettings__c(Name = 'RGUOrderTrigger', isActive__c = true);
          insert trgSettng;
        
        Account testAccount = StoreTestUtility.createAccount(testUser.Id);
        testAccount.AccountNumber = '123456';
        testAccount.RecordTypeId = recordType.Id;
        testAccount.ParentId = queriredTestParentAccount.Id;
        testAccount.Monthly_RGU_Order_Goal__c = 30;
        testAccount.RGU_Orders_This_Fiscal_Month__c = 23;
        testAccount.Monthly_RGU_Activations_Goal__c = 20;
        testAccount.RGU_Activations_This_Fiscal_Month__c = 14;
        testAccount.Parent_Account_Dropdown__c = 'TestAccnt';
        insert testAccount;

        RGU_Order__c testRGUOrder = new RGU_Order__c();
        testRGUOrder.Store_ID__c = '123456';
        testRGUOrder.Affiliate__c = 'Test Affiliate Store';
        testRGUOrder.Activity_Status__c  = 'Activated';
        testRGUOrder.Order_Date__c = Date.today().addDays(-1);
        testRGUOrder.Activation_Date__c = Date.today().addDays(-1);
        insert testRGUOrder;

        ApexPages.StandardController stdCon = new ApexPages.StandardController(testAccount);

        Test.startTest();
            StoreGaugeController controller = new StoreGaugeController(stdCon);
            OrdersGauge oVGGauge = controller.OrdersVsGoalGauge;
            OrdersGauge tOVGGauge = controller.TrendingOrdersVsGoalGauge;
            OrdersGauge aVGGauge = controller.ActivationsVsGoalGauge; 
            OrdersGauge tAVGGauge = controller.TrendingActivationsVsGoalGauge;
            OrdersChart pSDChart = controller.PastSevenDaysChart; 
        Test.stopTest();

        System.assertEquals(23, oVGGauge.Actual, 'Actual number of orders should be 23');   
        System.assertEquals(30, tOVGGauge.Goal, 'Goal should be 30');
        System.assertEquals(14, aVGGauge.Actual, 'Actual number of activations should be 14');
        System.assertEquals(20, tAVGGauge.Goal, 'Goal should be 20');
        //System.assertEquals(1, pSDChart.FirstDayOrderCount, 'There should be 1 order from yesterday');
        }
    }
}