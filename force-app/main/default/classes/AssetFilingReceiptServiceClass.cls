@RestResource(urlMapping='/renewals/filingreceipt/*')
global without sharing class AssetFilingReceiptServiceClass
{
    @HttpGet
    global static String AssetFilingReceiptService() 
    {
        system.debug('PTOCredentialsService service called');
        String AssetName = '';
        String strLeadSource = '';
        RestRequest restReq = RestContext.request;
        RestResponse restRes = RestContext.response;
        system.debug('Req URL: '+restReq.requestURI);
        string req =  restReq.requestURI;
        AssetName =req.substring(req.lastIndexOf('/') + 1);
        system.debug('1 : '+AssetName);
        strLeadSource = restReq.requestURI.substring(restReq.requestURI.lastIndexOf('&') + 1);
        List<Order_Item__c> ois = [select id, Filing_Receipt_Uploaded__c, Filing_Receipt_File_Id__c FROM Order_Item__c where Name =: AssetName Limit 1];
        rep r = new rep();
        if (ois != null && ois.size()>0)
        {
            if(ois[0].Filing_Receipt_File_Id__c!=null && ois[0].Filing_Receipt_Uploaded__c)
            {
                List<ContentVersion> cv = [SELECT ID,Title,FileExtension,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: ois[0].Filing_Receipt_File_Id__c ];
                if(cv.size()>0)
                {
                    r.Title = cv[0].Title;
                    r.Extension = cv[0].FileExtension;
                    r.VersionId = cv[0].id;
                    string strRes = Json.serialize(r);
                    system.debug(strRes);
                    return strRes;
                }
                else
                    return  '{"errorCode": "NOT_FOUND", "message": "Could not find a match for request..." }';
            }
            else
                return  '{"errorCode": "NOT_FOUND", "message": "Could not find a match for request..." }';
        }
        else
            return  '{"errorCode": "NOT_FOUND", "message": "Could not find a match for request..." }';
    }
    global class rep
    {
        public string Title{set;get;}
        public string Extension{set;get;}
        public string VersionId{set;get;}
    }
}