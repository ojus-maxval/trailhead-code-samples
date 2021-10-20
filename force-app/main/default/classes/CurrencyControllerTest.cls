/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sanjay Ram M, Sept 2021
 */
@isTest
public class CurrencyControllerTest 
{
    public static testmethod void GetExchangeRateTest()
    {
        Currency__c objCurrency = new Currency__c();
        objCurrency.Name = 'USD';
        objCurrency.Exchange_Rate__c = 1.0;
        Insert objCurrency;
        
        Currency_Exchange_Rate__c objCEX = new Currency_Exchange_Rate__c();
        objCEX.Auth__c = '919663192171:B390B451:365';
        objCEX.EndpointURL__c = 'https://api.annuitypayer.com/MaxvalAPServices.svc/GetCurrencyRates';
        Insert objCEX;
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml;charset=UTF-8');
        res.setBody('<CurrencyRateListResponse xmlns="MaxvalAPNS" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">'+
                    '<CurrencyRateList>'+
                    '<APICurrencyRate>'+
                    '<Code>USD</Code>'+
                    '<CurrencyExchangeRateId>166157</CurrencyExchangeRateId>'+
                    '<CurrencyId>1</CurrencyId>'+
                    '<ExchangeRate>1.00000</ExchangeRate>'+
                    '<RatesDate>Aug 30 2021  1:00PM</RatesDate>'+
                    '</APICurrencyRate>'+
                    '<APICurrencyRate>'+
                    '<Code>EUR</Code>'+
                    '<CurrencyExchangeRateId>166158</CurrencyExchangeRateId>'+
                    '<CurrencyId>2</CurrencyId>'+
                    '<ExchangeRate>0.84780</ExchangeRate>'+
                    '<RatesDate>Aug 30 2021  1:00PM</RatesDate>'+
                    '</APICurrencyRate>'+
                    '<APICurrencyRate>'+
                    '<Code>GBP</Code>'+
                    '<CurrencyExchangeRateId>166159</CurrencyExchangeRateId>'+
                    '<CurrencyId>3</CurrencyId>'+
                    '<ExchangeRate>0.72695</ExchangeRate>'+
                    '<RatesDate>Aug 30 2021  1:00PM</RatesDate>'+
                    '</APICurrencyRate>'+
                    '<APICurrencyRate>'+
                    '<Code>AFN</Code>'+
                    '<CurrencyExchangeRateId>166160</CurrencyExchangeRateId>'+
                    '<CurrencyId>4</CurrencyId>'+
                    '<ExchangeRate>79.92906</ExchangeRate>'+
                    '<RatesDate>Aug 30 2021  1:00PM</RatesDate>'+
                    '</APICurrencyRate>'+
                    '</CurrencyRateList>'+
                    '</CurrencyRateListResponse>');
        res.setStatusCode(200);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CurrencyController.GetExchangeRate();
        Test.stopTest();
    }
    public static testmethod void GetExchangeRateTest2()
    {  
         Test.startTest();
        try
        {
            CurrencyController.GetExchangeRate();
            
        }
        catch(Exception e) 
        {
            String strAuditText;
            strAuditText += 'Error:' + e.getMessage() + '|' + e.getStacktraceString();
        }
        Test.stopTest(); 
    }
}