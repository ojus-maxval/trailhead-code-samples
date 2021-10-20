public class batchFailedInstructionStatusUpdate implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful{
    //--------------------------
    public List<string> recordIDs {set;get;}
    public string query{set;get;}
    public API_Credentials__c credentials{set;get;}
    //--------------------------
    
    public batchFailedInstructionStatusUpdate(List<string> recid)
    {
        system.debug('>> Id\'s: '+recid);
        recordIDs = NEW List<string>();
        recordIDs = recid;
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'Symphony - Failed Instructions'];
        query = 'SELECT id,Name,Order__r.Client__c,Order__r.Client__r.Endpoint_URL__c,Cancellation_Approval__c,Instruction_Message__c,Payment_Status__c FROM Order_Item__c where ID IN: recordIDs';
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
            // strAuditTrail += 'Filing Receipt Content Details ToSymp - '; 
            if(credentials!=null && credentials.URL__c!=null && credentials.URL__c!='')
            {
                for(Order_Item__c oi : scope)
                {
                    req r = NEW req();     
                    r.OrderName = oi.Name;
                    r.Status = oi.Payment_Status__c;
                    r.Message = oi.Instruction_Message__c;                 
                    string jsonbody = JSON.serialize(r);
                    system.debug('jsonbody: '+jsonbody);
                    string AccessToken = SymphonyAuthenticaionHelper.SymphonyAuthenticaionHelper(oi.Order__r.Client__c);
                    system.debug('>>>'+AccessToken);
                    Http http = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setMethod('POST');
                    req.setEndpoint(oi.Order__r.Client__r.Endpoint_URL__c+credentials.URL__c);
                    system.debug('>>>'+oi.Order__r.Client__r.Endpoint_URL__c+credentials.URL__c);
                    req.setHeader('Authorization', 'Bearer ' + AccessToken);
                    req.setHeader('Content-Type','application/json;charset=UTF-8');
                    req.setHeader('Content-Length', string.valueOf(jsonbody.length()));            
                    req.setBody(jsonbody);
                    HttpResponse res = http.send(req);  
                    system.debug('Response status code :'+res.getStatusCode() +' |Status :'+res.getStatus() +' |Body '+res.getBody());          
                    strAuditTrail += ' |Res Status: '+res.getStatus()+' |Status Code: '+res.getStatusCode()+' |Body: '+res.getBody();               
                }
            }
            else
            {
                strAuditTrail += ' | There is no API Credentials named \'Symphony - Failed Instructions\' with Path of URL |';
            }
        }
        catch(exception e)
        {
            strAuditTrail += e.getmessage();
            Status = 'Fail';
        }
        finally
        {
            AuditTrailHelper.UpdateAudit('batchFailedInstructionStatusUpdate', strAuditTrail, Status);
        }
    }     
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
    public class req
    {
        public string OrderName{set;get;}
        public string Status{set;get;}
        public string Message{set;get;}
    }
}