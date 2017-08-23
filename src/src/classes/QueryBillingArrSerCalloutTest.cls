/****************************************************************************************************************************************************
Name: AccountManagementServiceCalloutTest
Description: This class is used to test vf page displaying the Pdf Bill for one month from the esp services.
Author: Lalit Singh (Accenture)
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
29/09/2015 Comcast  
*************************************************************************************************************************************************************/
@isTest
public class QueryBillingArrSerCalloutTest{
   @isTest
    public static void billingMockCallout(){        
        String houseKey = '23060000046653';       ///'37920267405021';
        DSMTestDataUtility.generateAccountManagementServiceCS();
        Test.startTest();                        
        Test.setMock(HttpCalloutMock.class,new MockHttpResponseGeneratorGetBilling(true));
        QueryBillingArrangementServiceCallout.getHttpResponse(houseKey);
        Test.stopTest();
    }
}