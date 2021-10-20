public with sharing class RenewalChatController
{
    @auraEnabled
    public static dataBody getAllMessages(String recID)
    {
        system.debug(recID);
        dataBody db = NEW dataBody();
        string cbURL = '';
        string MaRSRefID = '';
        List<Order_Item__c> oi = [select id,name,Order__r.Client__c,Order__r.Client__r.Endpoint_URL__c from Order_Item__c where id=: recID];
        List<Renewal_Chat__c> chats = NEW List<Renewal_Chat__c>();
        if(oi.size()> 0)
            chats = [SELECT ID,From__c,Chat_Text__c,CreatedDate,From_Symphony__c FROM Renewal_Chat__c WHERE MaRS_Reference_ID__c=: oi[0].Name ORDER BY CreatedDate DESC];
        if(chats.size()>0)
        {
            db.renewalChats = chats;            
            system.debug('Final:'+db.cURL+' MRefID:'+db.MRefID+' renewalChats:'+db.renewalChats.size());
        }
        db.MRefID = oi[0].Name;
        db.cURL = oi[0].Order__r.Client__r.Endpoint_URL__c;
        db.cID = oi[0].Order__r.Client__c;
        return db;
    }
    @auraEnabled
    public static string SendMessages(String MaRSReferenceID, String ChatMessage, String ClientID, string ClientURL)
    {
        string strAuditTrail = '';
        string Status = 'Success';
        try
        {
            strAuditTrail += 'RenewalChatController - SendMessages: For- '+MaRSReferenceID+' Msg-'+ChatMessage; 
            Renewal_Chat__c rc = New Renewal_Chat__c();
            rc.From__c = UserInfo.getName();
            rc.From_UserId__c = UserInfo.getUserId();
            rc.MaRS_Reference_ID__c = MaRSReferenceID;
            rc.Chat_Text__c = ChatMessage; 
            insert rc;
            
            callAPISendMessages(MaRSReferenceID, ChatMessage, ClientURL, ClientID, rc.From_UserId__c, rc.From__c);
        }
        catch(exception e)
        {
            strAuditTrail += e.getmessage();
            Status = 'Fail';
        }
        AuditTrailHelper.UpdateAudit('RenewalChatController', strAuditTrail, Status);
        return Status;
    } 
    @future(callout=true)
    public static void callAPISendMessages(String MaRSReferenceID, String ChatMessage, string ClientURL,String ClientID, string FromUserId, string FromName)
    {
        string strAuditTrail = '';
        string Status = 'Success';
        try
        {
            requestBody r = NEW requestBody();
            r.MaRSReferenceID = MaRSReferenceID;
            r.FromUserID = FromUserId;
            r.FromName = FromName;
            r.ChatMessage = ChatMessage;
            string jsonbody = JSON.serialize(r);
            string AccessToken = SymphonyAuthenticaionHelper.SymphonyAuthenticaionHelper(ClientID);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(ClientURL+'/services/apexrest/renewals/chat/');
            req.setHeader('Authorization', 'Bearer ' + AccessToken);
            req.setHeader('Content-Type','application/json;charset=UTF-8');
            req.setHeader('Content-Length', string.valueOf(jsonbody.length()));            
            req.setBody(jsonbody);
            HttpResponse res = http.send(req);  
            system.debug('Response status code :'+res.getStatusCode() +' |Status :'+res.getStatus() +' |Body '+res.getBody());          
            strAuditTrail += ' |Res Status: '+res.getStatus()+' |Status Code: '+res.getStatusCode()+' |Body: '+res.getBody();
            String jsonString = res.getBody();
            system.debug('Req Body: '+jsonString );
            JSONParser parser = JSON.createParser(jsonString);
            responsebody resb = (responsebody)parser.readValueAs(responsebody.class);
            if(resb.Status)
            {
                Status = 'Success';
            }
            else
            {
                error e = resb.error;
                Status = 'Fail - '+e.Description;
            }
        }
        catch(exception e)
        {
            strAuditTrail += e.getmessage();
            Status = 'Fail';
            system.debug(e.getmessage());
            AuditTrailHelper.UpdateAudit('RenewalChatController', strAuditTrail, Status);
        }
        AuditTrailHelper.UpdateAudit('RenewalChatController', strAuditTrail, Status);
    }
    public class dataBody
    {
        @auraEnabled
        public List<Renewal_Chat__c> renewalChats{set;get;}
        @auraEnabled
        public string cURL{set;get;}
        @auraEnabled
        public string MRefID{set;get;}
        @auraEnabled
        public string cID{set;get;}
    }
    public class requestBody
    {
        public string MaRSReferenceID{set;get;}
        public string FromUserID{set;get;}
        public string FromName{set;get;}
        public string ChatMessage{set;get;}
    }
    public class responsebody
    {
        public boolean Status{set;get;}
        public error Error{set;get;}
    }
    public class error
    {
        public string Description{set;get;}
        public string Code{set;get;}
    }
}