public class batchFilingReceiptContentDetailsToSymp implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful{
    //--------------------------
    public List<string> recordIDs {set;get;}
    public string query{set;get;}
    //--------------------------
    
    public batchFilingReceiptContentDetailsToSymp(List<string> recid)
    {
        recordIDs = NEW List<string>();
        recordIDs = recid;
        query = 'SELECT id,Name,Filing_Receipt_Uploaded__c,Filing_Receipt_File_Id__c,Order__r.Client__c,Order__r.Client__r.Endpoint_URL__c FROM Order_Item__c where ID IN: recordIDs';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Order_Item__c> scope)
    {
        string strAuditTrail = '';
        string Status = 'Success';
        try
        {
            strAuditTrail += 'Filing Receipt Content Details ToSymp - '; 
            for(Order_Item__c oi : scope)
            {
                List<ContentVersion> cv = [SELECT ID,Title,FileExtension,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: oi.Filing_Receipt_File_Id__c ];
                req r = NEW req();
                if(cv.size()>0)
                {           
                    r.MaRSRenewalID = oi.Name;
                    r.Title = cv[0].Title;
                    r.Extension = cv[0].FileExtension;
                    r.VersionId = cv[0].id;
                    string jsonbody = JSON.serialize(r);
                    system.debug('jsonbody: '+jsonbody);
                    string AccessToken = SymphonyAuthenticaionHelper.SymphonyAuthenticaionHelper(oi.Order__r.Client__c);
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setMethod('POST');
                    req.setEndpoint(oi.Order__r.Client__r.Endpoint_URL__c+'/filingreceipt/detials/');
                    req.setHeader('Authorization', 'Bearer ' + AccessToken);
                    req.setHeader('Content-Type','application/json;charset=UTF-8');
                    req.setHeader('Content-Length', string.valueOf(jsonbody.length()));            
                    req.setBody(jsonbody);
                    HttpResponse res = http.send(req);  
                    system.debug('Response status code :'+res.getStatusCode() +' |Status :'+res.getStatus() +' |Body '+res.getBody());          
                    strAuditTrail += ' |Res Status: '+res.getStatus()+' |Status Code: '+res.getStatusCode()+' |Body: '+res.getBody();
                }
            }
        }
        catch(exception e)
        {
            strAuditTrail += e.getmessage();
            Status = 'Fail';
        }
        finally
        {
            AuditTrailHelper.UpdateAudit('FilingReceiptContentDetailsToSymp', strAuditTrail, Status);
        }
    } 
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
    public class req
    {
        public string MaRSRenewalID{set;get;}
        public string Title{set;get;}
        public string Extension{set;get;}
        public string VersionId{set;get;}
    }
}