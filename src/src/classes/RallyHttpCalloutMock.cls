@isTest
global class RallyHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"CreateResult":{"Object": {"FormattedID": "US1049569", "ScheduleState": "Backlog", "c_KanbanState": "Backlog", "Errors": [], "Warnings": []}}}');
        response.setStatusCode(200);
        return response; 
    }
}