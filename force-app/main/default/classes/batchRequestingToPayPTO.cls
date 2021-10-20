//pto/payment/validate
public class batchRequestingToPayPTO implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful
{
    public string query{set;get;}
    public string AccessToken{set;get;}
    public API_Credentials__c credentials{set;get;}
    public List<string> lstOIIds{set;get;}
    public List<string> lstPersonIds{set;get;}
    public Map<string,string> countryAuth{set;get;}
    public set<string> lstPersonEmails{set;get;}
    public List<string> disclosureIds{set;get;}
    public batchRequestingToPayPTO(List<string> oiIds)
    {
        AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        lstOIIds = NEW List<string>();
        lstOIIds = oiIds;
        countryAuth = NEW Map<string,string>();
        List<PTO_Credentials__c> PTOCredentials = [Select id,Name, Country_Code__c FROM PTO_Credentials__c];
        for(PTO_Credentials__c pc : PTOCredentials)
        {
            countryAuth.put(pc.Country_Code__c,pc.Name);
        }
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'Pto Payment Validate'];
        //query = 'SELECT id,Name,Paid_Status__c,Payment_Status__c,Order_Number__c,Client__c,Billing_Currency__c,Fee_Amount_When_Pay__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c FROM Order_Item__c where ID IN : lstOIIds';
        query = 'SELECT id,Name,Paid_Status__c,Payment_Status__c,Order_Number__c,Client__c,Jurisdiction__c,Billing_Currency__c,Fee_Amount_When_Pay__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c,Invoice_Type_Name_Value__c,Invoice__c,Invoice__r.Name FROM Order_Item__c where ID IN : lstOIIds';
    }
    public batchRequestingToPayPTO()
    {
        countryAuth = NEW Map<string,string>();
        List<PTO_Credentials__c> PTOCredentials = [Select id,Name, Country_Code__c FROM PTO_Credentials__c];
        for(PTO_Credentials__c pc : PTOCredentials)
        {
            countryAuth.put(pc.Country_Code__c,pc.Name);
        }
        AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'Pto Payment Validate'];
        //query = 'SELECT id,Name,Paid_Status__c,Payment_Status__c,Order_Number__c,Client__c,Billing_Currency__c,Fee_Amount_When_Pay__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c FROM Order_Item__c where Paid_Status__c=\'Requesting to Pay PTO\' AND Payment_Status__c=\'Payment Received\'';
        query = 'SELECT id,Name,Paid_Status__c,Payment_Status__c,Order_Number__c,Client__c,Jurisdiction__c,Billing_Currency__c,Fee_Amount_When_Pay__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c,Invoice_Type_Name_Value__c,Invoice__c,Invoice__r.Name FROM Order_Item__c where Payment_Status__c=\'Payment Received\'';//Paid_Status__c=\'Requesting to Pay PTO\' AND 
        system.debug(query);
    }
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Order_Item__c> scope)
    {
        boolean saveAudit = false;
        string strAuditTrail = '';
        try
        {
            strAuditTrail += 'Requesting To Pay PTO : ';
            List<Order_Item__c> ois = NEW List<Order_Item__c>();
            //String AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
            Map<String,List<Order_Item__c>> OrderItemMap = new Map<String,List<Order_Item__c>>();
            for(Order_Item__c oi : scope)
            {
                List<Order_Item__c> temp = OrderItemMap.get(oi.Invoice__r.Name);
                if(temp != null)
                {
                    temp.add(oi);
                }
                else
                {
                    OrderItemMap.put(oi.Invoice__r.Name, new List<Order_Item__c>{oi});
                }
            }
            for(string keyOI : OrderItemMap.keyset())
            {
                set<string> countryCode = NEW set<string>();
                ReqData woi = NEW ReqData();               
                List<objectitem> Items = NEW List<objectitem>();                
                for(Order_Item__c oi : OrderItemMap.get(keyOI))
                {
                    countryCode.add(oi.Jurisdiction__c);
                    objectitem oitem = NEW objectitem();
                    oitem.ApplicationNumber = oi.Application_No__c;
                    oitem.PatentNumber = oi.Patent_No__c;
                    oitem.SerialNumber = oi.Application_No__c;
                    oitem.PublicationNumber = oi.Application_No__c;
                    oitem.AttorneyDocketNumber= oi.Application_No__c;
                    oitem.RenewalYear= '';
                    oitem.FilingDate= '';
                    oitem.FeeCode= oi.Billing_Currency__c;
                    oitem.Fee= String.valueof(oi.Fee_Amount_When_Pay__c);
                    Items.add(oitem);
                }
                woi.ClientRequestHandle = keyOI;
                list<string> strs = NEW list<string>();
                strs.addall(countryCode);
                string code=strs[0];
                system.debug('C Code:'+code);
                if(countryAuth.containsKey(code))
                    woi.AuthHandleRef = countryAuth.get(code);
                system.debug(woi.AuthHandleRef);
                woi.Jurisdiction = code;
                woi.Items = Items;
                string jsonbody = JSON.serialize(woi);
                //string jsonbody='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","AuthHandleRef":"b772a5ac-7565-48de-b3ff-15168aa72c3a","Jurisdiction":"US","Items":[{"ApplicationNumber":"14513841","PatentNumber":"10565402","SerialNumber":"","PublicationNumber":"","AttorneyDocketNumber":"P491US1","RenewalYear":"","FilingDate":"","FeeCode":"1551","Fee":"1500.55"}]}';
                
                system.debug('Request Body :'+jsonbody);
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint(credentials.URL__c);
                req.setHeader('Authorization', 'Bearer ' + AccessToken);
                req.setHeader('Content-Type','application/json;charset=UTF-8');
                req.setHeader('Content-Length', string.valueOf(jsonbody.length()));            
                req.setBody(jsonbody);
                HttpResponse res = http.send(req);  
                system.debug('Response status code :'+res.getStatusCode() +' |Status :'+res.getStatus() +' |Body '+res.getBody());          
                strAuditTrail += res.getBody();
                List<Order_Item__c> oits = NEW List<Order_Item__c>();
                if(res.getStatusCode() == 200)
                {
                    string strres = res.getBody();
                    responsebody resb = (responsebody)JSON.deserialize(strres, responsebody.Class);
                    for(Order_Item__c oi : OrderItemMap.get(keyOI))
                    {
                        oi.Paid_Status__c = 'Requested to Pay PTO';
                        oi.MV_API_Ref_Id__c = resb.RequestID;
                        oits.add(oi);
                    }
                }            
                update oits;
            }
        }
        catch(Exception e)
        {
            strAuditTrail += ' || Error :'+e.getMessage();
        }
        finally
        {
            system.debug(strAuditTrail);
        }
    }
    public void finish(Database.BatchableContext BC)
    {
        
    }
    public class ReqData
    {
        public string ClientRequestHandle{get;set;}
        public string AuthHandleRef{get;set;}
        public string Jurisdiction{get;set;}
        public List<objectitem> Items{get;set;}
    }
    public class objectitem
    {
        public string ApplicationNumber{get;set;}
        public string PatentNumber{get;set;}
        public string SerialNumber{get;set;}        
        public string PublicationNumber{get;set;}
        public string AttorneyDocketNumber{get;set;}
        public string RenewalYear{get;set;}
        public string FilingDate{get;set;}
        public string FeeCode{get;set;}
        public string Fee{get;set;}
    }
    public class responsebody
    {
        public string RequestID{ get; set; }
    }
    /*
    {
        "ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669",
        "AuthHandleRef":"b772a5ac-7565-48de-b3ff-15168aa72c3a",
        "Jurisdiction":"US",
        "Items":
        [
            {
                "ApplicationNumber":"14513841",
                "PatentNumber":"10565402",
                "SerialNumber":"",
                "PublicationNumber":"",
                "AttorneyDocketNumber":"P491US1",
                "RenewalYear":"",
                "FilingDate":"",
                "FeeCode":"1551",
                "Fee":"1500.55"
            },
            {
                "ApplicationNumber":"14513841",
                "PatentNumber":"10565402",
                "SerialNumber":"",
                "PublicationNumber":"",
                "AttorneyDocketNumber":"P491US1",
                "RenewalYear":"",
                "FilingDate":"",
                "FeeCode":"1551",
                "Fee":"1500.55"
            }
        ]
    }
    */
}