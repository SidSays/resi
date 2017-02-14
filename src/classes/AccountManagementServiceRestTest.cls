/****************************************************************************************************************************************************
Name: AccountManagementServiceRestTest
Description: This class is used to test accountmanagementrest class.
Author: Lalit Singh (Accenture)
--------------- ------------------ ------------------------------
13/10/2015 Comcast  
*************************************************************************************************************************************************************/
@isTest
Public class AccountManagementServiceRestTest {
   //test method for calling the rest class method and passing it the billingaccountnumber
   public static testMethod void testAccountManagement(){
        
        Restrequest req = new Restrequest();
        req.addHeader('Content-Type', 'application/json');
        req.requestURI = '/services/apexrest/AccountManagementServiceRest/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestResponse res = new RestResponse();
        RestContext.response = res;
        DSMTestDataUtility.generateAccountManagementServiceCS();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,new MockHttpResponseGeneratorAccountMgmt());
        AccountManagementServiceRest.addBillingAccountNumber('8242105900088251');
        Test.StopTest();
   }
}