public class MaxValAPIAuthenticaionHelper
{
    public static string MaxValAPIAuthenticaionHelper()
    {
        string token = '';
        List<API_Credentials__c> credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'MaxvalAPI' Limit 1];
        if(credentials.size() > 0)
        {        
            String UserCredentials ='client_id='+credentials[0].Username__c+'&client_secret='+credentials[0].Password__c+'&grant_type=client_credentials';
            system.debug(UserCredentials);
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(credentials[0].URL__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody(UserCredentials);
            HttpResponse res = http.send(req);
            //system.debug('Body:'+res.getBody()+' Res Code:'+res.getstatuscode()+' Res status:'+res.getstatus()); 
            if (res.getStatusCode() == 200) {
                deserializeResponse resp = (deserializeResponse)JSON.deserialize(res.getbody(),deserializeResponse.class);
                //system.debug('@@@@access_token@@ = '+resp.access_token );
                token = resp.access_token;
            }
        }
        return token;
    }
    public class deserializeResponse
    {
        public String id;
        public String access_token;
    }
}