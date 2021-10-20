public class SymphonyAuthenticaionHelper
{
    public static string SymphonyAuthenticaionHelper(string clienid)
    {
            string token = '';
            string strAuditText = '';
        try{
            List<Clients__c> credentials = [SELECT Id,Name,AP_Client_Id__c,API_Key__c,API_Secret__c,Endpoint_URL__c,API_Username__c,API_User_Password__c FROM Clients__c WHERE id=: clienid Limit 1];
            strAuditText += credentials.size();
            if(credentials.size() > 0)
            {        
                strAuditText += 'inside if | ';
                String UserCredentials ='grant_type=password&client_id='+credentials[0].API_Key__c+'&client_secret='+credentials[0].API_Secret__c+'&username='+credentials[0].API_Username__c+'&password='+credentials[0].API_User_Password__c;
                strAuditText += 'request body: '+ UserCredentials;
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://test.salesforce.com/services/oauth2/token');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setBody(UserCredentials);
                HttpResponse res = http.send(req);
                strAuditText +='Body:'+res.getBody()+' Res Code:'+res.getstatuscode()+' Res status:'+res.getstatus(); 
                if (res.getStatusCode() == 200) {
                    responseWrapper wResp = (responseWrapper) JSON.deserialize(res.getBody(), responseWrapper.class);
                    strAuditText += wResp.access_token;
            		//AuditTrailHelper.UpdateAudit('SymphonyAuthenticaionHelper', strAuditText, 'None');
                    return wResp.access_token;
                }
                else
                    strAuditText += token;
            		//AuditTrailHelper.UpdateAudit('SymphonyAuthenticaionHelper', strAuditText, 'None');
                    return token;
            }
            
        }catch(Exception e)
        {
            strAuditText += '|| Exception: ' + e.getMessage() + ' at Line no: ' + e.getLineNumber();
            //AuditTrailHelper.UpdateAudit('SymphonyAuthenticaionHelper', strAuditText, 'None');
        }
            return token;
    }
    public class responseWrapper 
    {
        public string id;
        public string access_token;
        public string instance_url;
    }
}