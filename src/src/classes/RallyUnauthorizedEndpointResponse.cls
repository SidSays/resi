@isTest
@TestVisible public class RallyUnauthorizedEndpointResponse implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest request) {
        CalloutException e = (CalloutException)CalloutException.class.newInstance();
        e.setMessage('You have uncommitted work pending. Please commit or rollback before calling out.');
        throw e;
    }
}