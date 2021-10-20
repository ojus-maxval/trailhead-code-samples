@isTest
global class RenewalCreditMemoCreateMockResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        string sessionBody = '{"Status":1,"Error":null,"Warning":null,"Data":{"RequestID":"CREDITMEMO-132403956562651712","DuplicateCreditMemoReferences":null}}';
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody(sessionBody);
        res.setStatusCode(200);        
        return res;
    }
}