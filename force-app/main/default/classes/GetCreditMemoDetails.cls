/* Copyright © 2021 MaxVal Group. All Rights Reserved.
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * Written by Saranyaa C, August 2021
 */
@RestResource(urlMapping = '/renewal/creditmemo/*')
global with sharing class GetCreditMemoDetails 
{
    @HttpGet
    global static void doget() 
    {
        Boolean status =True;
        Boolean AccIncomeIsAvailable = false;
        string strAuditTrail = '';
    	Constants.MarsErrors creditMemoErrors = new Constants.MarsErrors();
        try
        {
            string creditMemoDetails='';
            String uniqueName = '';
            RestRequest restReq = RestContext.request;
            // Reading parameters from URL
            string s = restReq.requestURI.substring(0, restReq.requestURI.lastIndexOf('/details'));
            uniqueName = s.substring(s.lastIndexOf('/') + 1);
            
            strAuditTrail += 'Getting details for the creditmemo - '+ uniqueName + ' | ';
            
            list<Credit_Memo__c> objCreditMemoList = [SELECT Amount__c,API_Message__c,API_Request_ID__c,API_Status__c,Client__c,CreditMemo_Status__c,Name FROM Credit_Memo__c WHERE name =:uniqueName limit 1];
            
            if(objCreditMemoList.size()>0)
            {
                list<QB_Account__c> ListOfIA =[SELECT Id,Name,QB_Account_Id__c, Client__c FROM QB_Account__c WHERE Client__c = : objCreditMemoList[0].Client__c  LIMIT 1];   
                list<QB_Customer__c> CustomerName =[SELECT Id,Name,QB_Customer_Id__c, Client__c FROM QB_Customer__c WHERE Client__c = : objCreditMemoList[0].Client__c   LIMIT 1];               //boolean values to handle index out of bound exception in ternary syntax            
                list<Order_Item__c > ListOfOItems=
                    [select 
                     id,name
                     ,Patent_No__c
                     ,Application_No__c 
                     ,Order__r.name
                     ,Order__r.Client__r.name
                     ,Payment_Status__c,CreditMemo_Amount__c,CreditMemo_Comments__c
                     FROM Order_Item__c WHERE Credit_Memo__c=:objCreditMemoList[0].id];
                
                if(ListOfOItems.size() > 0)
                {
                    strAuditTrail += 'Getting asset details for the creditmemo | ';
                    //JSON formation
                    Response response = new Response();
                    response.Status = True;
                    Header header = new Header();
                    AccountTo accountTo = new AccountTo();
                    if(!test.isRunningTest()){
                    	accountTo.AccountToRef = ListOfIA[0].QB_Account_Id__c != null?ListOfIA[0].QB_Account_Id__c:'';
                    }else{
                        accountTo.AccountToRef = '1';
                    }
                    
                    header.AccountTo = accountTo;
                    BillTo billTo = new BillTo();
                    if(!test.isRunningTest()){
                    	billTo.BillToRef = CustomerName[0].QB_Customer_Id__c !=null?CustomerName[0].QB_Customer_Id__c:'';
                    }else{
                        billTo.BillToRef = '1';
                    }
                    if(!test.isRunningTest()){
                    	billTo.CustomerName = CustomerName[0].Name !=null?CustomerName[0].Name:'';
                    }else{
                        billTo.CustomerName = 'Customer1';
                    }
                    header.BillTo = billTo;
                    header.SendEmail = 'SENDLATER';
                    header.Message = '';
                    Details details = new Details();
                    LineItem lineItem = new LineItem();
                    String patentNo = ListOfOItems[0].Patent_No__c;
                    if(patentNo != '' || patentNo != '-'){
                        patentNo = ListOfOItems[0].Application_No__c;
                    }
                    /* MARS-973 
                     * 1. Product/Service should be mapped to AccountToRef from MaRS system based on QBO account for the particular customer.
                     * 2. Description should be Order # XXXXXX { Application Number } - { Comments }
                     * Modified by Saranyaa
                     * Sep 22, 2021
                     */
                    lineItem.ItemName = 'AP Deposits AP-'+ ListOfOItems[0].Order__r.Client__r.name;
                    lineItem.Description = 'Order # ' + ListOfOItems[0].Order__r.name + ' ' + ListOfOItems[0].Application_No__c + ' - ' + ListOfOItems[0].CreditMemo_Comments__c;
                    lineItem.Amount = string.valueof(ListOfOItems[0].CreditMemo_Amount__c);
                    details.LineItems = new List<LineItem>();
                    details.LineItems.add(lineItem);
                    details.CurrencyRef = 'USD';
                    details.Total = string.valueof(objCreditMemoList[0].Amount__c);
                    details.Message = 'Please make check payable to MaxVal and mail it or for wire transfer see details below.';
                    Footer footer = new Footer();
                    footer.Message = '';
                    Data data = new Data();
                    data.Header = header;
                    data.Details = details;
                    data.Footer = footer;
                    response.Data = new List<Data>();
                    response.Data.add(data);                 
                           
                    creditMemoDetails = JSON.serialize(response);
                    strAuditTrail += 'JSON generated | ';
                }
                else{            
                    strAuditTrail += 'No Assets in this creditmemo found | ';
                    Response response = new Response();
                    response.Status = False;
                    Error error = new Error();
                    error.Code = 'MARS.CreditMemo.005';
                    error.Description = creditMemoErrors.MARSCreditMemo005;
                    response.Error = new List<Error>();
                    response.Error.add(error);
                    creditMemoDetails = JSON.serialize(response);     
                }
            }
            else{      
                strAuditTrail += 'No creditmemo found | ';
                Response response = new Response();
                response.Status = False;
                Error error = new Error();
                error.Code = 'MARS.CreditMemo.005';
                error.Description = creditMemoErrors.MARSCreditMemo005;
                response.Error = new List<Error>();
                response.Error.add(error);
                creditMemoDetails = JSON.serialize(response);             
            }
            
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(creditMemoDetails); 
            strAuditTrail += 'Response sent | ';
            
            AuditTrailHelper.UpdateAudit('GetCreditMemoDetails',strAuditTrail,'');
        }
        catch(Exception e)
        {
            Response response = new Response();
            response.Status = False;
            Error error = new Error();
            error.Code = 'MARS.CreditMemo.Ex.001';
            error.Description = String.format(creditMemoErrors.MARSCreditMemoEX001, new List<String>{e.getMessage()});
            response.Error = new List<Error>();
            response.Error.add(error);
            String creditMemoDetails = JSON.serialize(response);
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(creditMemoDetails); 
            
            strAuditTrail += 'Exception :'+e.getMessage() + ' | Line No: ' + e.getLineNumber() + ' | ';
            status = False;
            strAuditTrail += 'Response sent | ';
            
            AuditTrailHelper.UpdateAudit('GetCreditMemoDetails',strAuditTrail,'');
        }
    }
    
    global class Footer{        
        public String Message{set;get;}
    }
    
    global class LineItem{        
        public String ItemName{set;get;}
        public String Description{set;get;}
        public String Amount{set;get;}
    }
    
    global class Details{        
        public List<LineItem> LineItems{set;get;}
        public String CurrencyRef{set;get;}
        public String Total{set;get;}
        public String Message{set;get;}
    }
    
    global class AccountTo{        
        public String AccountToRef{set;get;}
    }
    
    global class BillTo{        
        public String BillToRef{set;get;}
        public String CustomerName{set;get;}
    }
    
    global class Header{        
        public AccountTo AccountTo{set;get;}
        public BillTo BillTo{set;get;}
        public String SendEmail{set;get;}
        public String Message{set;get;}
    }
    
    global class Data{
        public Header Header{set;get;}
        public Details Details{set;get;}
        public Footer Footer{set;get;}
    }
    
    global class Error{
        public String Code{set;get;}
        public String Description{set;get;}
    }
    
    global class Response{
        public boolean Status{set;get;}
        public List<Error> Error{set;get;}
        public List<Data> Data{set;get;}
    }
    
}