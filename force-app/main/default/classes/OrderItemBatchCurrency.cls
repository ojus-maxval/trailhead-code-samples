global with sharing class OrderItemBatchCurrency implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator([SELECT Id, Name, Exchange_Rate__c FROM Currency__c]); 
    }
    global void execute(Database.BatchableContext BC, List<Currency__c > objCurrencyList )
    {
        string strAuditText = '';
      Map<string, Currency__c> mapCurrencies = new Map<string, Currency__c>();
     for(Currency__c objCurrency : objCurrencyList)
     {
         if (mapCurrencies.containsKey(objCurrency.Name)==false) 
                    mapCurrencies.put(objCurrency.Name, objCurrency);
     }
     String serviceuri = 'https://symphony.maxval-ip.com/api/MaxvalAPServices.svc/GetCurrencyRates';
            String body = '';
            String length = String.valueOf(body.length());
            string auth = '919663192171:B390B451:365';
            Blob bauth = Blob.valueOf(auth);
            String headerval = EncodingUtil.base64Encode(bauth);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(serviceuri);
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
                //strAuditText += '[ CurrencyRateList Parsed, Count:' + CurrencyRateList.size() +']';   
                
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
                //strAuditText += '[ objCurrencyNewList:' + objCurrencyNewList + ' ]'; 

            }
            for(Currency__c objCurrencyNew : objCurrencyNewList)
            {
                if (mapCurrencies.containsKey(objCurrencyNew.Name))
                {
                    Currency__c objCurrencyToBeUpdated = mapCurrencies.get(objCurrencyNew.Name);
                    objCurrencyToBeUpdated.Exchange_Rate__c = objCurrencyNew.Exchange_Rate__c; 
                }
            }
            UPDATE mapCurrencies.values();
          
    }
    
    global void finish(Database.BatchableContext BC){
                //AuditTrailHelper.UpdateAudit('CurrencyController-GetExchangeRate', strAuditText, 'None');

    }
       
}