/***************************************************************************************************************************************
 * Author     :Lalit Singh, Accenture
 * Date       : 05-June-2015
 * Description: This is Test class for "TestWSController" Class
 * History
     Version             : 1.0
     Author Last Updated : Lalit, Accenture 
     PROJECT             : Residential Salesforce
***************************************************************************************************************************************/
@isTest
private class TestWSControllerTest {

    static testMethod void callPingTest() {
        //String reString = MockHttpResponseGeneratorForWsController.respond();
        /*RestRequest req = new RestRequest();
        if (!isApexTest){
        HttpResponse res = h.send(req);
        reString = res.toString();
        system.debug('value of the return string'+reString );
        } */
        Test.startTest();
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForWsController(true));
        TestWSController t = new TestWSController(); 
        t.callPing();
        Test.stopTest();
        
    }
}