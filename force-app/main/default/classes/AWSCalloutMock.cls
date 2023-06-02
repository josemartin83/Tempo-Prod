@isTest
global class AWSCalloutMock implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"message":"Accepted"}');
        response.setStatusCode(202);
        return response;
    }
}