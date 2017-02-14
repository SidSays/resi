@isTest
public class TemporaryCallOutControllerTest{

 @isTest static void TestClass() {
 
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
          
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        TemporaryCallOutController obj = new TemporaryCallOutController();
        obj.retString = '';
        obj.auth = '';
        obj.SoapXMLBody = '';
        obj.test();
    }
}