/****************************************************************************************************************************************************
Name: RetrieveAccountHistoryRESTServiceTest
Description: This class is used to test accountmanagementrest class.
Author: Animesh Datta
Date: 18 Jan 2016
*************************************************************************************************************************************************************/
@isTest
Public class RetrieveAccountHistoryRESTServiceTest {
   //test method for calling the rest class RetrieveAccountHistoryRESTService and pass address id
    public static testMethod void testRetrieveAccountHistory(){
        Test.startTest();
        Restrequest req = new Restrequest();
        req.requestURI = '/services/apexrest/RetrieveAccountHistoryRESTService/';
        req.httpMethod = 'GET';
        req.addParameter('Id', '42105900088251');
        RestContext.request = req;
        System.assert(RetrieveAccountHistoryRESTService.getAccountHistory() != null, 'activityList was null');
        Test.StopTest();
    }
}