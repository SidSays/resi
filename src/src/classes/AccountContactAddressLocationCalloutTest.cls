/****************************************************************************************************************************************************
Name: AccountContactAddressLocationCalloutTest
Description: This class is used to test vf page displaying acccount contact information
Author: Ashish Sonawane (Accenture)
Date PRJ/DFCT/ENHC# Summary of Changes 
--------------- ------------------ ------------------------------
29/09/2015 Comcast  
*************************************************************************************************************************************************************/
@isTest                        
private class AccountContactAddressLocationCalloutTest{
    
    //Test for Search Interview method
    @isTest static void accountContactMockCallout(){
          DSMTestDataUtility.generateAccountManagementServiceCS();  
        
          Test.startTest();                        
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorAccountCont());
          AccountContactAddressLocationCallout.generateHttpResponse();          
          Test.stopTest();
    }

}