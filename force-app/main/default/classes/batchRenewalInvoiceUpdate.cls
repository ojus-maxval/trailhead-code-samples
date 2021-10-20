//renewal/invoice/update
public class batchRenewalInvoiceUpdate implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful
{
    public string query{set;get;}
    public string AccessToken{set;get;}
    public API_Credentials__c credentials{set;get;}
    public List<string> lstCIds{set;get;}
    public string ApiHandleRefId{set;get;}
    public batchRenewalInvoiceUpdate(List<id> clientids)
    {
        SET<id> ids =NEW SET<id>(clientids);
        AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        lstCIds = NEW List<id>(ids);
        system.debug(lstCIds);
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'Renewal Invoice Update'];
        ApiHandleRefId =[SELECT Name FROM API_Auth_Detail__c  WHERE Type_Of_Credential__c ='QB Credential' LIMIT 1].Name;
        query = 'select id from clients__c where id in: lstCIds';
    }
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Clients__c> scope)
    {
        boolean saveAudit = false;
        string strAuditTrail = '';
        try
        {
            strAuditTrail += 'Renewal Invoice Update : ';
            List<Clients__c> clients = scope;
            List<Invoice__c> clientInvoices = [Select id,Name,Order__r.Client__c,API_Request_ID__c,API_Status__c from Invoice__c where API_Status__c='Send Update Request' AND Order__r.Client__c=:clients[0].id];
            //List<Order_Item__c> ois = NEW List<Order_Item__c>();
            //String AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
            Map<String,List<Invoice__c>> ClientInvoiceMap = new Map<String,List<Invoice__c>>();
            for(Invoice__c ci : clientInvoices)
            {
                List<Invoice__c> temp = ClientInvoiceMap.get(ci.Order__r.Client__c);
                if(temp != null)
                {
                    temp.add(ci);
                }
                else
                {
                    ClientInvoiceMap.put(ci.Order__r.Client__c, new List<Invoice__c>{ci});
                }
            }
            for(string keyOI : ClientInvoiceMap.keyset())
            {
                ReqData woi = NEW ReqData();               
                List<objectitem> Items = NEW List<objectitem>();                
                for(Invoice__c ci : ClientInvoiceMap.get(keyOI))
                {
                    objectitem oitem = NEW objectitem();
                    oitem.InvoiceRef = ci.Name;
                    Items.add(oitem);
                }
                woi.ClientRequestHandle = keyOI;
                woi.ApiHandleRef = ApiHandleRefId;
                woi.Items = Items;
                string jsonbody = JSON.serialize(woi);
                //jsonbody ='{"ClientRequestHandle":"8bd2ee6c-ab07-4793-8078-56e338614025","Items":[{"InvoiceRef":"63463"},{"InvoiceRef":"34666"}]}';
                
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
                List<Invoice__c> invoices= NEW List<Invoice__c>();
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201)
                {
                    string strres = res.getBody();
                    responsebody resb = (responsebody)JSON.deserialize(strres, responsebody.Class);
                    for(Invoice__c ci : ClientInvoiceMap.get(keyOI))
                    {
                        responseBodyData rd = resb.Data;
                        ci.API_Request_ID__c = rd.RequestID;
                        if(ci.API_Request_ID__c != null && ci.API_Request_ID__c!='')
                        {
                            ci.API_Status__c = 'Requested';
                        }
                        invoices.add(ci);
                    }
                }            
                update invoices;
            }
        }
        catch(Exception e)
        {
            strAuditTrail += ' || Error :'+e.getMessage();
        }
        finally
        {
            system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('batchRenewalInvoiceUpdate',strAuditTrail,'Success');
        }
    }
    public void finish(Database.BatchableContext BC)
    {
        
    }
    public class ReqData
    {
        public string ClientRequestHandle{get;set;}
        public string ApiHandleRef{get;set;}
        public List<objectitem> Items{get;set;}
    }
    public class objectitem
    {
        public string InvoiceRef{get;set;}
    }
    public class responseBody
    {
        public integer Status{ get; set; }
        public responseBodyData Data{ get; set; }
        public List<responseBodyError> Error{ get; set; }
        public string Warning{ get; set; }

    }
    public class responseBodyData
    {
        public string RequestID{ get; set; }
        public string DuplicateInvoiceReference{ get; set; }
    }
    public class responseBodyError
    {
        public string Code{ get; set; }
        public string Description{ get; set; }
    }    
}