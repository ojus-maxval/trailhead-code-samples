@isTest
global class GetCreditMemoDetailsMockErrorResponse implements HttpCalloutMock{
global HTTPResponse respond(HTTPRequest req) {
        
        string sessionBody = '{"Status":false,"Error":[{"Description":"No data found.","Code":"MARS.CreditMemo.005"}],"Data":null}';
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody(sessionBody);
        res.setStatusCode(200);        
        return res;
    }
}