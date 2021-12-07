//renewal/invoice/info/{invoiceref}/download/{type}
public class batchRenewalInvoiceInfo implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful
{
    public string query{set;get;}
    public boolean callAttachmentsBatch{set;get;}
    public string AccessToken{set;get;}
    public API_Credentials__c credentials{set;get;}
    public string strAuditTrail = '';
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
        string status = 'Success';
        try
        {
            strAuditTrail +='Renewal Invoice Info : ';
            List<Clients__c> clientConfig=new List<Clients__c>();
            if(scope.size()>0)
            	clientConfig =[SELECT 	Id,Is_LEDES_Required__c FROM Clients__c WHERE id=:scope[0].Order__r.Client__c ];
            for(Invoice__c ci : scope)
            {
                string fileName='';
                HttpResponse res=new HttpResponse();
                string URL = credentials.URL__c;                
                string ledesURL=URL.replace('invoiceref',ci.Name).replace('type','ledes');
                URL=URL.replace('invoiceref',ci.Name).replace('/type','');
                strAuditTrail +='Invoice file download URL - '+URL;
                res = CallAPI(URL,AccessToken);
                if(clientConfig.size()>0 && clientConfig[0].Is_LEDES_Required__c)
                {
                    AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
                    strAuditTrail +='LEDES file download URL - '+ledesURL;
                    HttpResponse ledesResponse = new HttpResponse();
                    ledesResponse = CallAPI(ledesURL,AccessToken);
                    fileName='LEDESInvoice-'+ ci.Name+' INFO';
                    callAttachmentsBatch=UploadFile(ledesResponse,ci.Name,ci.Id,fileName);
                }
                fileName='Invoice-'+ ci.Name+' INFO';
                callAttachmentsBatch=UploadFile(res,ci.Name,ci.Id,fileName);
                if(callAttachmentsBatch)
                	ci.API_Status__c = 'Downloaded Info';
            }
            if(callAttachmentsBatch)
            	update scope;
        }
        catch(Exception e)
        {
            strAuditTrail += ' || Error :'+e.getMessage()+'|| Stacktrace-'+e.getStackTraceString()+'|| linenumber-'+e.getLineNumber();
            status = 'Fail';
        }
        finally
        {
            system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('batchRenewalInvoiceInfo-download',strAuditTrail,status);
        }
    }
    
    //Makes a call to the MaxvalAPI to get the csv file
    public HttpResponse CallAPI(string URL,string AccessToken)
    {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(URL);
        req.setHeader('Authorization', 'Bearer ' + AccessToken);
        req.setHeader('Content-Type','application/json;charset=UTF-8');
        req.setHeader('Content-Length', '0');
        req.setTimeout(120000);
        HttpResponse res = http.send(req);
        return res;
    }
    
    //This function is used to upload the file against the particular order
    public boolean UploadFile(HttpResponse response,string invoiceRef,Id invoiceID,string fileName)
    {
        boolean callAttachmentsBatch=false;
        if(response.getstatusCode() == 200)
        {
            strAuditTrail +=' |Res Status:'+response.getStatus()+' Code:'+response.getStatusCode();
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S';
            conVer.PathOnClient =fileName+'.csv';
            conVer.Title =fileName; // Display name of the files
            conVer.VersionData = response.getBodyAsBlob(); // converting your binary string to Blog
            insert conVer;
            System.debug(conVer.Id);
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDoc;
            cDe.LinkedEntityId = invoiceID; // you can use objectId,GroupId etc
            cDe.ShareType = 'I'; // Inferred permission, checkout description of ContentDocumentLink object for more details
            insert cDe;
            callAttachmentsBatch = true;
        }
        return callAttachmentsBatch;
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