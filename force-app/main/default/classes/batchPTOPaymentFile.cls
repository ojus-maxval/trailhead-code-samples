//GET pto/payment/file/{requestid}/download
public class batchPTOPaymentFile implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful
{
    public string query{set;get;}
    public List<id> orderItemIds{set;get;}
    public string AccessToken{set;get;}
    public API_Credentials__c credentials{set;get;}
    public batchPTOPaymentFile(List<Id> OIds)
    {
        //AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        AccessToken = '';
        orderItemIds = OIds;
        system.debug('orderItemIds'+orderItemIds);
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'PTO Payment File' Limit 1];
        query = 'Select id,Name,PTO_Validation_Request_ID__c,Order__r.Client__c,Client__c from Order_Item__c where ID IN: orderItemIds AND  PTO_Validation_Request_ID__c!=null';
    }
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug(query);
        system.debug('orderItemIds'+orderItemIds);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Order_Item__c> scope)
    {
        if(!test.isRunningTest())
        	AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        else
            AccessToken = 'Test_Token';
        boolean saveAudit = false;
        string status = 'Success';
        string strAuditTrail = '';
        try
        {
            strAuditTrail +='PTO Payment File : ';
            List<Order_Item__c> oiToUpdatte = NEW List<Order_Item__c>();
            for(Order_Item__c oi : scope)
            {
                List<Order_Item__c> relatedOIS = [SELECT id,Name,PTO_Validation_Document__c,PTO_Validation_Request_ID__c,Order__r.Client__c,Client__c FROM Order_Item__c where PTO_Validation_Request_ID__c=:oi.PTO_Validation_Request_ID__c];
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                string URL = credentials.URL__c;
                URL = URL.replaceAll('\\*',oi.PTO_Validation_Request_ID__c);
                //URL = 'https://api-dev.maxval.com/v1/pto/payment/file/PTO-132405100318514108/download';
                system.debug(URL);
                req.setEndpoint(URL);
                req.setHeader('Authorization', 'Bearer ' + AccessToken);
                req.setHeader('Content-Type','application/json;charset=UTF-8');
                req.setHeader('Content-Length', '0');
                HttpResponse res = http.send(req);  
                strAuditTrail +=' |Res Status:'+res.getStatus()+' Code:'+res.getStatusCode();
                if(res.getstatusCode() == 200)
                {
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S';
                    //conVer.PathOnClient = cvResp.Title+'.' + cvResp.Extension;
                    //conVer.Title = cvResp.Title; // Display name of the files
                    conVer.PathOnClient =oi.Client__c+ oi.PTO_Validation_Request_ID__c+' File.csv';
                    conVer.Title =oi.Client__c+ oi.PTO_Validation_Request_ID__c+' File'; // Display name of the files
                    conVer.VersionData = res.getBodyAsBlob(); // converting your binary string to Blog
                    insert conVer;
                    System.debug(conVer.id);
                    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                    ContentDocumentLink cDe = new ContentDocumentLink();
                    cDe.ContentDocumentId = conDoc;
                    cDe.LinkedEntityId = oi.Order__r.Client__c; // you can use objectId,GroupId etc
                    cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                    // cDe.Visibility = 'ALL';
                    insert cDe;
                    for(Order_Item__c roi: relatedOIS)
                    {
                        roi.PTO_Validation_Document__c=cDe.ContentDocumentId;
                        oiToUpdatte.add(roi);
                    }
                    //oi.API_Status__c = 'Downloaded Attachment';
                }
            }
            if(oiToUpdatte.size()>0)
            	update oiToUpdatte;
        }
        catch(Exception e)
        {
            strAuditTrail += ' || Error :'+e.getMessage();
            status = 'Fail';
        }
        finally
        {
            system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('batchPTOPaymentFile',strAuditTrail,status);
        }
    }
    public void finish(Database.BatchableContext BC)
    {
        
    }
}