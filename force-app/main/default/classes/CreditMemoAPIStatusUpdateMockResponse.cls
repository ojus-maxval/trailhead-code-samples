@isTest
global class CreditMemoAPIStatusUpdateMockResponse implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        
        string sessionBody = '{"Status":true,"Error":[]}';
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody(sessionBody);
        res.setStatusCode(200);        
        return res;
    }
}