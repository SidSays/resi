/****************************************************************************************************************************************************
Name: AccountManagementServiceCalloutTest
Description: This class is used to test vf page displaying the Pdf Bill for one month from the esp services.
Author: Lalit Singh (Accenture)
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
04/10/2015 Comcast  
*************************************************************************************************************************************************************/
@isTest
public class AccountManagementServiceCalloutTest{
    
   
    public static testMethod void accountServiceMockCallout(){        
        String billingAccountNumber = '8242105900088251';
        DSMTestDataUtility.generateAccountManagementServiceCS();
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class,new MockHttpResponseGeneratorAccountMgmt());
        AccountManagementServiceCallout accntMgmtObj = new AccountManagementServiceCallout();
        accntMgmtObj.getHttpResponse(billingAccountNumber);
        Test.stopTest();
    }
   
     public static testMethod void accountServiceMockCallouterror(){        
        String billingAccountNumber = '8242103vvv088251';
        DSMTestDataUtility.generateAccountManagementServiceCSerror();
        Test.startTest();                        
        Test.setMock(HttpCalloutMock.class,new MockHttpResponseGeneratorAccountMgmt());
        AccountManagementServiceCallout accntMgmtObj = new AccountManagementServiceCallout();
        accntMgmtObj.getHttpResponse(billingAccountNumber);
        Test.stopTest();
    }
}