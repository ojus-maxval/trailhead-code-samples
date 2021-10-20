@isTest
global class RenewalCreditMemoCreateMockErrorResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        string sessionBody = '{"Status":3,"Error":[{"Code":"API.CreditMemo.005","Description":"APIHandleRef is null or empty"}],"Warning":null,"Data":{"RequestID":null,"DuplicateCreditMemoReferences":null}}';
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody(sessionBody);
        res.setStatusCode(400);        
        return res;
    }
}