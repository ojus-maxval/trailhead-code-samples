//renewal/invoice/info/{invoiceref}/{type}/download
public class batchRenewalInvoiceInfo implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful
{
    public string query{set;get;}
    public boolean callAttachmentsBatch{set;get;}
    public string AccessToken{set;get;}
    public API_Credentials__c credentials{set;get;}
    public batchRenewalInvoiceInfo()
    {
        //AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        callAttachmentsBatch = false;
        AccessToken = '';
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'Invoice Info' Limit 1];
        query = 'Select id,Name,Order__r.Client__c,API_Request_ID__c,API_Status__c from Invoice__c where API_Status__c=\'Completed\'';
    }
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Invoice__c> scope)
    {
        AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        boolean saveAudit = false;
        string strAuditTrail = '';
        string status = 'Success';
        try
        {
            strAuditTrail +='Renewal Invoice Info : ';
            if(scope.size()>0)
            	List<Clients__c> clientConfig =[SELECT 	Id,Is_LEDES_Required__c FROM Clients__c WHERE id=:scope[0].Order__r.Client__c ];
            for(Invoice__c ci : scope)
            {
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                string URL = credentials.URL__c;
                URL = URL.replaceAll('\\*',ci.Name);
                //URL = 'https://api-dev.maxval.com/v1/renewal/invoice/info/A-09876/download';
                system.debug(URL);
                req.setEndpoint(URL);
                req.setHeader('Authorization', 'Bearer ' + AccessToken);
                req.setHeader('Content-Type','application/json;charset=UTF-8');
                req.setHeader('Content-Length', '0');
                req.setTimeout(120000);
                HttpResponse res = http.send(req);  
                strAuditTrail +=' |Res Status:'+res.getStatus()+' Code:'+res.getStatusCode();
                if(res.getstatusCode() == 200)
                {
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S';
                    //conVer.PathOnClient = cvResp.Title+'.' + cvResp.Extension;
                    //conVer.Title = cvResp.Title; // Display name of the files
                    conVer.PathOnClient ='Invoice-'+ ci.Name+' INFO.csv';
                    conVer.Title ='Invoice-'+ ci.Name+' INFO'; // Display name of the files
                    conVer.VersionData = res.getBodyAsBlob(); // converting your binary string to Blog
                    insert conVer;
                    System.debug(conVer.Id);
                    Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                    ContentDocumentLink cDe = new ContentDocumentLink();
                    cDe.ContentDocumentId = conDoc;
                    cDe.LinkedEntityId = ci.id; // you can use objectId,GroupId etc
                    cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
                    // cDe.Visibility = 'ALL';
                    insert cDe;
                    ci.API_Status__c = 'Downloaded Info';
                    callAttachmentsBatch = true;
                }
            }
            if(callAttachmentsBatch)
                update scope;
        }
        catch(Exception e)
        {
            strAuditTrail += ' || Error :'+e.getMessage();
            status = 'Fail';
        }
        finally
        {
            system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('batchRenewalInvoiceInfo',strAuditTrail,status);
        }
    }
    public void finish(Database.BatchableContext BC)
    {
        if(callAttachmentsBatch)
        {
            batchRenewalInvoiceAttachment ab = NEW batchRenewalInvoiceAttachment();
            database.executeBatch(ab,1);
        }
    }
}