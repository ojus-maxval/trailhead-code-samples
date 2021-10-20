@RestResource(urlMapping='/renewals/chat/*')
global class RenewalsChatServiceClass
{
    @HttpPost
    global static responsebody RenewalsChat() 
    {
        responsebody resp = NEW responsebody();
        try
        {
            system.debug('RenewalsChatServiceClass service called');
            //responcebody res = (responcebody)RestContext.request.requestBody;
            String jsonString = RestContext.request.requestBody.toString();
            system.debug('Req Body: '+jsonString );
            JSONParser parser = JSON.createParser(jsonString);
            requestbody req = (requestbody)parser.readValueAs(requestbody.class);
            if(req != null)
            {
                Renewal_Chat__c rc = NEW Renewal_Chat__c();
                rc.Chat_Text__c = req.ChatMessage;
                rc.From__c = req.FromName;
                rc.From_UserId__c = req.FromUserID;
                rc.From_Symphony__c = true;
                rc.MaRS_Reference_ID__c = req.MaRSReferenceID;
                insert rc;
                resp.Status = true;
            } 
            else
            {
                resp.Status = false;
                error er = NEW error();
                er.Code = 'NO_DATA_FOUND';
                er.Description= 'No data found';
                resp.Error = er;
            }
        }
        catch(exception e)
        {
            resp.Status = false;
            error er = NEW error();
            er.Code = '-';
            er.Description = e.getMessage();
            resp.Error = er;
        }
        return  resp;        
    }
    
    global class requestbody
    {
        global string MaRSReferenceID{set;get;}
        global string FromUserID{set;get;}
        global string FromName{set;get;}
        global string ChatMessage{set;get;}
    }
    global class responsebody
    {
        public boolean Status{set;get;}
        global error Error{set;get;}
    }
    global class error
    {
        global string Description{set;get;}
        global string Code{set;get;}
    }
}