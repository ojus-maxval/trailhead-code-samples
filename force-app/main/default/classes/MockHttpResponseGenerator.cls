@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        string sessionBody = '{"access_token": "rjuJr-uvMXnRT1eZg-u-wgC05x87XOvhemohxQg6nyKx35Ol6PqRSmS6SpCitijQ3Y0Wsx2t2it5inVSFapOyLT6vGaUwAPfUBEC67j1DloKKsjZVcGQNYPfqmEby6l_opRiI99I4Qc5IRIt-4Vje229reo8J-FJjAh7RXz3pGRXxRwZnix88isEcB4tFz1g2y5pCeeEmenmp6t8ZKgSWTYqWK421aZaAmffXhhx34-LlxjUf85GZFVxtUjG5o5ScagN0-QKXo_3OXmYrUSN0G4BnN2StWkg9WtLY3s3u4Y",    "token_type": "bearer",    "expires_in": 1799}';
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody(sessionBody);
        res.setStatusCode(200);        
        return res;
    }
}