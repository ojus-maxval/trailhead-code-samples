@isTest
global class batchPtoPaymentValidateFCalloutMock implements HttpCalloutMock 
{
   global HTTPResponse respond(HTTPRequest request)
   {   HttpResponse res = new HttpResponse();
       res.setHeader('Content-Type', 'application/json');
       res.setBody('{"Status":3,"RequestID":null,"Errors":[{"Code":"API.PTO.005","Description":"  Provided Jurisdiction is not supported. Only US is supported"}],"Warnings":[{"Code":"API.PTO.005","Description":"  Provided Jurisdiction is not supported. Only US is supported"}],"ErrorItems":[{"RowNumber":1,"Errors":[{"Code":"API.PTO.008","Description":"ApplicationNumber US1451384 is invalid."},{"Code":"API.PTO.010","Description":"PatentNumber US105654 is invalid."}]}],"WarningItems":[{"Code":"API.PTO.010","Description":"PatentNumber US105654 is invalid."}]}');
       res.setStatusCode(205);
       return res;       
   }
}