/***********************************************************
* Class Name: OrderTriggerControllerTest
* Author: Raju Patel, Accenture
* Date: 24-Oct-2013 
* * Description: This class does the test coverage
*              for OrderTriggerController class.
***********************************************************/
@isTest
public class OrderTriggerControllerTest{
    
    public static testMethod void TestSalespersonID() {
        SetupTestData.createCustomSettingRecords();
        SetupTestData.createUsers();
        system.runAs(SetupTestData.businessAdminUser){
            //Create a new order.
            Order__c order = new Order__c();
            order.Name = 'TestOrder';
            order.Order_Number__c = '1';  
            order.NTLoginOrder__c = 'FedId4';//Giving the NT ID of the user.
            insert order;
            Order__c ord = [select id , Name ,ActivatedBy__c from order__c where id =: order.id];
            System.AssertEquals(ord.ActivatedBy__c, SetupTestData.dsrUser.id);
            }
        }
}