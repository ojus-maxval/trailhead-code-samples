public class batchInstructionStatusUpdate implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful{
    //--------------------------
    public List<string> recordIDs {set;get;}
    public string query{set;get;}
    public string recordStatus{set;get;}
    //--------------------------
    
    public batchInstructionStatusUpdate(List<string> recid,String recStatus)
    {
        system.debug('>> Id\'s: '+recid+' Status:'+  recStatus);
        recordIDs = NEW List<string>();
        recordIDs = recid;
        recordStatus = '';
        recordStatus = recStatus;
        query = 'SELECT id,Name,Filing_Receipt_Uploaded__c,Filing_Receipt_File_Id__c,Order__r.Client__c,Order__r.Client__r.Endpoint_URL__c,Cancellation_Approval__c  FROM Order_Item__c where ID IN: recordIDs';
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
            List<Order_Item__c> orderItems=new List<Order_Item__c>();
            for(Order_Item__c oi : scope)
            {
                req r = NEW req();     
                r.OrderName = oi.Name;
                r.Status = recordStatus;                
                string jsonbody = JSON.serialize(r);
                strAuditTrail += 'jsonbody: '+jsonbody;
                string AccessToken = SymphonyAuthenticaionHelper.SymphonyAuthenticaionHelper(oi.Order__r.Client__c);
                strAuditTrail+='>>>'+AccessToken;
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint(oi.Order__r.Client__r.Endpoint_URL__c+'/statusupdate/instructionstatus/');
                //system.debug('>>>'+oi.Order__r.Client__r.Endpoint_URL__c+'/statusupdate/instructionstatus/');
                strAuditTrail += 'URL - '+oi.Order__r.Client__r.Endpoint_URL__c+'/statusupdate/instructionstatus/';
                req.setHeader('Authorization', 'Bearer ' + AccessToken);
                req.setHeader('Content-Type','application/json;charset=UTF-8');
                req.setHeader('Content-Length', string.valueOf(jsonbody.length()));            
                req.setBody(jsonbody);
                HttpResponse res = http.send(req);  
                //strAuditTrail+='Response status code :'+res.getStatusCode() +' |Status :'+res.getStatus() +' |Body '+res.getBody();          
                strAuditTrail += 'Req:'+jsonbody+' |Res Status: '+res.getStatus()+' |Status Code: '+res.getStatusCode()+' |Body: '+res.getBody();               
                if(recordStatus=='Rejected')
                {
                    oi.Cancellation_Rejected_Date__c = System.today();
                    orderItems.add(oi);
                }   
                else if(recordStatus=='Approved')
                {
                    oi.Cancellation_Approved_Date__c=System.today();
                    orderItems.add(oi);
                }
            }
            if(orderItems.size()>0)
            	update orderItems;
        }
        catch(exception e)
        {
            strAuditTrail += e.getmessage()+'||'+e.getLineNumber();
            Status = 'Fail';
        }
        finally
        {
            AuditTrailHelper.UpdateAudit('batchInstructionStatusUpdate', strAuditTrail, Status);
        }
    } 
    
    
    public void finish(Database.BatchableContext BC)
    {
        
    }
    public class req
    {
        public string OrderName{set;get;}
        public string Status{set;get;}
        
    }
}