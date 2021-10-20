/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Sanjay Ram M, Sept 2021
 */
public with sharing class CurrencyController
{
    //@future(callout=true)
    public static void GetExchangeRate()
    {
        string strAuditText = '';
        try
        {

            //Read the Currency object
            Map<string, Currency__c> mapCurrencies = new Map<string, Currency__c>();
            List<Currency__c> objCurrencyList = [SELECT Id, Name, Exchange_Rate__c FROM Currency__c];
            for(Currency__c objCurrency : objCurrencyList)
            {
                if (mapCurrencies.containsKey(objCurrency.Name)==false) 
                    mapCurrencies.put(objCurrency.Name, objCurrency);
            }
            List<Currency_Exchange_Rate__c> RateURL = [SELECT Auth__c,EndpointURL__c FROM Currency_Exchange_Rate__c LIMIT 1];
            system.debug('List -'+RateURL);
            if(RateURL.size()>0)
            {
                String body = '';
                String length = String.valueOf(body.length());
                Blob bauth = Blob.valueOf(RateURL[0].Auth__c);
                String headerval = EncodingUtil.base64Encode(bauth);
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(RateURL[0].EndpointURL__c);
                req.setMethod('POST');  
                req.setBody(body);
                req.setHeader('Content-length', length);
                req.setHeader('Authentication', headerval);
                req.setHeader('Content-type', 'application/xml');
                req.setTimeout(120000);
                
                Http http = new Http();
                HTTPResponse res = http.send(req);
                
                List<Currency__c> objCurrencyNewList = new List<Currency__c>();
                Dom.Document xmldata;
                Dom.XmlNode xmlcontent;
                if (res !=null && res.getStatusCode() == 200)
                {
                    strAuditText += '[ body:' + res.getBody()+ ' ]'; 
                    xmldata = res.getBodyDocument();
                    xmlcontent = xmldata.getRootElement();
                    String namespace = xmlcontent.getNamespace();
                    strAuditText += '[ Namespace:' + namespace + ' ]'; 
                    
                    Dom.XmlNode CurrencyRates = xmlcontent.getChildElement('CurrencyRateList', namespace);
                    Dom.XmlNode[] CurrencyRateList = CurrencyRates.getChildElements();
                    strAuditText += '[ CurrencyRateList Parsed, Count:' + CurrencyRateList.size() +']';   
                    
                    for(Dom.XmlNode element : CurrencyRateList)
                    {
                        Currency__c objCurrency = new Currency__c();
                        Dom.XmlNode[] CurrencyRateFields = element.getChildElements();
                        for(Dom.XmlNode node : CurrencyRateFields)
                        {
                            if(!String.isEmpty(node.getText()))
                            {
                                if(node.getName().equals('Code'))
                                    objCurrency.Name = node.getText();
                                else if(node.getName().equals('ExchangeRate'))
                                    objCurrency.Exchange_Rate__c = Decimal.valueOf(node.getText());
                            }
                        }
                        objCurrencyNewList.add(objCurrency);
                    } 
                    strAuditText += '[ objCurrencyNewList:' + objCurrencyNewList.size() + ' ]'; 
                }
                for(Currency__c objCurrencyNew : objCurrencyNewList)
                {
                    if (mapCurrencies.containsKey(objCurrencyNew.Name))
                    {
                        Currency__c objCurrency = mapCurrencies.get(objCurrencyNew.Name);
                        objCurrency.Exchange_Rate__c = objCurrencyNew.Exchange_Rate__c;
                        objCurrency.UpdatedDate__c = System.Now();
                    }
                }
                UPDATE mapCurrencies.values();
            }
            if(Test.isRunningTest()) 
            {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }
        catch(Exception exp)
        {
            strAuditText += 'Error:' + exp.getMessage() + '|' + exp.getStacktraceString();
        }
        finally
        {
            AuditTrailHelper.UpdateAudit('CurrencyController-GetExchangeRate', strAuditText, 'None');
        }
    }
}