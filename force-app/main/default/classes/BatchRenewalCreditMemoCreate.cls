/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Saranyaa C, August 2021
 */
//renewal/invoice/create
public class BatchRenewalCreditMemoCreate implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful
{
    public string query{set;get;}
    public string AccessToken{set;get;}
    public API_Credentials__c credentials{set;get;}
    public List<id> lstCreditMemoIds{set;get;}
    public string ApiHandleRefId{set;get;}
    string strAuditTrail = '';
    public BatchRenewalCreditMemoCreate(List<Id> creditMemoIds)
    {
        AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        if(AccessToken != ''){
        	strAuditTrail += 'AccessToken generated | ';
        }else{
        	strAuditTrail += 'AccessToken generation failed | ';            
        }
        lstCreditMemoIds = NEW List<id>(creditMemoIds);
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'Renewal CreditMemo Create'];
        ApiHandleRefId =[SELECT Name FROM API_Auth_Detail__c  WHERE Type_Of_Credential__c ='QB Credential' LIMIT 1].Name;
        query = 'select id,name from Credit_Memo__c where id IN: lstCreditMemoIds';
    } 
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    /*
     * Makes API Call to create CreditMemo.
	*/
    public void execute(Database.BatchableContext BC, List<Credit_Memo__c> creditMemos)
    {
        try{
            strAuditTrail += 'BatchRenewalCreditMemoCreate executing started | ';
            for(Credit_Memo__c creditMemo : creditMemos){
                ReqData woi = NEW ReqData();               
                List<ObjectItem> Items = NEW List<ObjectItem>();  
                ObjectItem oitem = NEW ObjectItem();
                oitem.CreditMemoRef = creditMemo.Name;
                Items.add(oitem);
                woi.ClientRequestHandle = creditMemo.Name;
                woi.ApiHandleRef = ApiHandleRefId;
                woi.Items = Items;
                string jsonbody = JSON.serialize(woi);
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint(credentials.URL__c);
                req.setHeader('Authorization', 'Bearer ' + AccessToken);
                req.setHeader('Content-Type','application/json;charset=UTF-8');
                req.setHeader('Content-Length', string.valueOf(jsonbody.length()));            
                req.setBody(jsonbody);
                HttpResponse res = http.send(req);          
                strAuditTrail += 'API request sent to the endpoint: ' + credentials.URL__c + ' | ';
                string strres = res.getBody();
                strAuditTrail += 'Response body: ' + strres + ' | ';            
                ResponseBody resb = (ResponseBody)JSON.deserialize(strres, ResponseBody.Class);
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201)
                {
                    ResponseBodyData rd = resb.Data;
                    creditMemo.API_Request_ID__c = rd.RequestID;
                    creditMemo.API_Status__c = 'Requested';
                    creditMemo.API_Message__c = 'API Request successfully placed.';
                    strAuditTrail += 'API Request successfully placed.RequestId - '+ rd.RequestID +' | ';
                } 
                else{                
                    creditMemo.API_Request_ID__c = '';
                    creditMemo.API_Status__c = 'NotRequested';
                    creditMemo.API_Message__c = 'API Request failed. Error: ' + GetAPIErrorMessage(resb.Error);
                    strAuditTrail += 'API Request failed. Error: ' + GetAPIErrorMessage(resb.Error);
                }     
            }
            update creditMemos;
            strAuditTrail += 'Updated CreditMemo with the APIRequestId, APIStatus and APIStatusMessage | ';
        }
        catch(Exception e){
            strAuditTrail += 'Exception: ' + e.getMessage() + 'at line no: '+ e.getLineNumber() +' | ';
        }
    }
    public void finish(Database.BatchableContext BC)
    {        
        AuditTrailHelper.UpdateAudit('BatchRenewalCreditMemoCreate',strAuditTrail,'');
    }
    
    /*
     * Concatenates all the errors with code and description sent in the request as a string.
	*/
    public String GetAPIErrorMessage(List<ResponseBodyError> errors){
       String apiErrorMessage = '';
       for(ResponseBodyError error : errors) 
       {
           apiErrorMessage += error.Code + ':' + error.Description + '; ';
       }
        return apiErrorMessage;
    }
    
    public class ReqData
    {
        public string ClientRequestHandle{get;set;}
        public string ApiHandleRef{get;set;}
        public List<objectitem> Items{get;set;}
    }
    public class ObjectItem
    {
        public string CreditMemoRef{get;set;}
    }
    public class ResponseBody
    {
        public integer Status{ get; set; }
        public responseBodyData Data{ get; set; }
        public List<responseBodyError> Error{ get; set; }
        public string Warning{ get; set; }
    }
    public class ResponseBodyData
    {
        public string RequestID{ get; set; }
        public string DuplicateInvoiceReference{ get; set; }
    }
    public class ResponseBodyError
    {
        public string Code{ get; set; }
        public string Description{ get; set; }
    }    
}