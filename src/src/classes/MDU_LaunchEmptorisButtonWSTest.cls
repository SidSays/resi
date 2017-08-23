/*
* Test class foer MDU_LaunchEmptorisButtonWS - covers the callout to Emptoris system.
*/
@isTest                  
private class MDU_LaunchEmptorisButtonWSTest{
     @isTest static void testCallout() {
        
        
         List<MDU_EmptorisIntegrationCS__c> listCust = TestDataUtility.createIntegrationCS();
         Database.insert(listCust);
         Test.startTest();
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpEmptorisRespGenerator(true));
       
      
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        String url = MDU_LaunchEmptorisButtonWS.launchEmptorisProcess();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpEmptorisRespGenerator(false));
        String url1 = MDU_LaunchEmptorisButtonWS.launchEmptorisProcess();
        Test.stopTest();
       
    }
}