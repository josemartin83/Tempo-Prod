@isTest
global class AWSCalloutMockFaillure implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"message":"Something went wrong!"}');
        response.setStatusCode(404);
        return response;
    }
}