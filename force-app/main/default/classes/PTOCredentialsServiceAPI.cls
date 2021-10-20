@RestResource(urlMapping='/pto/authentication/*')
global class PTOCredentialsServiceAPI
{
    @HttpGet
    global static resp getCredentials() 
    {
        String UniqueName = '';
        String strLeadSource = '';
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        // Reading parametrs from URL
        system.debug('Req URL: '+restReq.requestURI);
        string req =  restReq.requestURI;
        integer li= req.lastIndexOf('/detail');
        string s = req.substring(0, li);
        UniqueName =s.substring(s.lastIndexOf('/') + 1);
        system.debug('1 : '+UniqueName);
        strLeadSource = restReq.requestURI.substring(restReq.requestURI.lastIndexOf('&') + 1);
        //List<Order_Item__c > orderItems = [SELECT id,Name,Paid_Status__c,Payment_Status__c,Order_Number__c,Client__c,Billing_Currency__c,Fee_Amount_When_Pay__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c FROM Order_Item__c WHERE MV_API_Ref_Id__c = :MVRefId];
        List<PTO_Credentials__c> ptocreds = [SELECT id,Name,Country_Code__c,Username__c,Password__c FROM PTO_Credentials__c WHERE Name =: UniqueName];
        //list<rep> reslst = NEW list<rep>();
        resp reslst = NEW resp();
        List<Error> errors = NEW List<Error>();
        try
        {
            reslst.Status = true;            
            if (ptocreds != null && ptocreds.size()>0)
            {                
                reslst.Username = ptocreds[0].Username__c;
                reslst.Password = ptocreds[0].Password__c;
                system.debug(Json.serialize(reslst));
            }
            else
            {
                Error er = NEW Error();
                er.ErrorCode = 'NOT_FOUND';
                er.Message= 'Could not find a match for request...';
                errors.add(er);
            }
        }
        catch(exception e)
        {
            Error er = NEW Error();
            er.ErrorCode = '-';
            er.Message= e.getMessage();
            errors.add(er);            
        }
        finally
        {
            reslst.error = errors;
            if(errors.size()>0)
                reslst.Status = false;            
        }
        return  reslst;
        //return  Json.serialize(reslst);
    }
    global class resp
    {
        public boolean Status{set;get;}
        public string Username{set;get;}
        public string Password{set;get;}
        Public List<Error> Error{set;get;}
    }
    global class Error
    {
        public string ErrorCode{set;get;}
        public string Message{set;get;}
    }
}