//renewal/bill/create
public class batchRenewalBillCreate implements Database.AllowsCallouts,Database.Batchable<ptoValidationReqWrapper>, Database.Stateful
{
    public List<ptoValidationReqWrapper> records {set;get;}
    public string AccountRef{set;get;}
    public string AccessToken{set;get;}
    public API_Credentials__c credentials{set;get;}
    public List<string> lstPersonIds{set;get;}
    Map<string,id> mapPTOValReqIDWWithOI {set;get;}
    Map<string,QB_Account__c> mapQBAccount {set;get;}
    Map<string,QB_Customer__c> mapQBCustomer {set;get;}
    public Map<string,string> countryAuth{set;get;}
    public Map<string,API_Auth_Detail__c> APIAuth{set;get;}
    public API_Auth_Detail__c APIAuthRec{set;get;}
    public Map<string,PTOFeeCode__c> countryPTOFeeCode{set;get;}
    public set<string> lstPersonEmails{set;get;}
    public List<string> disclosureIds{set;get;}
    public batchRenewalBillCreate(List<ptoValidationReqWrapper> mapData,string paymentAccRef)
    {
        mapPTOValReqIDWWithOI =  NEW Map<string,id>();
        mapQBAccount = NEW Map<string,QB_Account__c>();
        mapQBCustomer = NEW Map<string,QB_Customer__c>();   
        AccountRef = '';
        AccountRef = paymentAccRef;
        APIAuth = NEW Map<string,API_Auth_Detail__c>();
        APIAuthRec = NEW API_Auth_Detail__c();
        //UserAuth = NEW Map<string,User_Auth_Detail__c>();
        countryAuth = NEW Map<string,string>();
        List<PTO_Credentials__c> PTOCredentials = [Select id,Name, Country_Code__c FROM PTO_Credentials__c];
        for(PTO_Credentials__c pc : PTOCredentials)
        {
            countryAuth.put(pc.Country_Code__c,pc.Name);
        }
        List<API_Auth_Detail__c> APIAuthDetails = [Select id,Name, Auth_Code__c,Client_Secret__c,ClientId__c,GrantType__c,Refresh_Token__c,Refresh_Token_Expiry__c FROM API_Auth_Detail__c WHERE Type_Of_Credential__c=:'QB Credential'];
        for(API_Auth_Detail__c aad : APIAuthDetails)
        {
            APIAuth.put(aad.ClientId__c,aad);
            APIAuthRec = aad;
        }
        /*List<User_Auth_Detail__c> UserAuthDetails = [Select id,Name,User_Name__c,Password__c,Secret_Key__c FROM User_Auth_Detail__c];
        for(User_Auth_Detail__c uad : UserAuthDetails)
        {
        UserAuth.put(uad.User_Name__c,uad);
        }*/
        countryPTOFeeCode = NEW Map<string,PTOFeeCode__c>();
        List<PTOFeeCode__c> PTOFeeCodes = [Select id,Jurisdiction__c,Surcharge_Code__c,Term_Name__c,FeeCode__c FROM PTOFeeCode__c];
        for(PTOFeeCode__c code: PTOFeeCodes)
        {
            countryPTOFeeCode.put(code.Jurisdiction__c+'-'+code.Term_Name__c,code);
        }
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'Renewal Bill Create'];
        
        
        //QB_Supplier__c
        records = mapData;
    }
    public Iterable<ptoValidationReqWrapper> start(Database.BatchableContext BC)
    {
        return records;
    }
    public void execute(Database.BatchableContext BC, List<ptoValidationReqWrapper> scope)
    {
        
        AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        boolean saveAudit = false;
        string strAuditTrail = '';
        string status = 'Success';
        List<ptoValidationReqWrapper> recs= scope;
        set<string> clientIDS = NEW set<string>();
        Map<string, string> mapClientQBCustomer = NEW Map<string, string>();
        List<Order_Item__c> listois = NEW List<Order_Item__c>();
        Map<Integer, string> mapCounterWithAssetID = NEW Map<Integer, string>();
        Map<string, string> mapAssetError = NEW Map<string, string>();
        Map<string, string> mapAssetWarning = NEW Map<string, string>();
        Map<String,List<Order_Item__c>> OrderItemMap = new Map<String,List<Order_Item__c>>();
        OrderItemMap.put(recs[0].countryCode,recs[0].countryAssets);
        try
        {
            system.debug('Country :'+recs[0].countryCode);
            List<QB_Account__c> JurisdictionQBA = [Select id,Name,QB_Account_Id__c,Account_Type__c FROM QB_Account__c WHERE Jurisdiction__c INCLUDES (:recs[0].countryCode) AND Active__c=true Limit 1];            
            List<QB_Customer__c> JurisdictionQBC = [Select id,Name,QB_Customer_Id__c,Jurisdiction__c FROM QB_Customer__c WHERE Jurisdiction__c =: recs[0].countryCode AND Active__c=true Limit 1];
            List<QB_Supplier__c> JurisdictionQBS = [Select id,Name,QB_Supplier_Id__c,Jurisdiction__c FROM QB_Supplier__c WHERE Jurisdiction__c =: recs[0].countryCode AND Active__c=true Limit 1];
            
            List<QB_Customer__c> qbCustomers = NEW List<QB_Customer__c>();
            for(string keyOI : OrderItemMap.keyset())
            {
                for(Order_Item__c oi : OrderItemMap.get(keyOI))
                {
                    clientIDS.add(oi.Order__r.Client__c);
                }
            }
            if(clientIDS.size()>0)
            {
                for(QB_Customer__c qbc : [select id,Name,Client__c,QB_Customer_Id__c from QB_Customer__c where Client__c IN: clientIDS])
                {
                    if(qbc.QB_Customer_Id__c != null)
                        mapClientQBCustomer.put(qbc.Client__c,qbc.QB_Customer_Id__c);
                }
            }
            for(string keyOI : OrderItemMap.keyset())
            {
                set<string> countryCode = NEW set<string>();
                set<string> setClientRequestHandle = NEW set<string>();
                string pcID = '';
                //set<string> setPaymentType = NEW set<string>();
                ReqData woi = NEW ReqData();               
                List<objectitem> Items = NEW List<objectitem>();
                Integer recCounter = 0;  
                listois = OrderItemMap.get(keyOI); 
                pcID = listois[0].Payment_Confirmation__c;
                List<String> lstAlpha = AccountRef.split('\\|\\|');
                for(Order_Item__c oi : OrderItemMap.get(keyOI))
                {
                    system.debug(oi.Jurisdiction__c +' >>> Before: '+oi.Application_No__c +'>>'+ oi.Patent_No__c+'>>'+oi.Payment_Confirmation__c);
                    setClientRequestHandle.add(oi.Payment_Confirmation__c+'-'+oi.Jurisdiction__c);
                    //setPaymentType.add(oi.Payment_Confirmation__r.Payment_Method__c);
                    countryCode.add(oi.Jurisdiction__c);
                    objectitem oitem = NEW objectitem();
                    boolean surchargeAvailable = False;
                    objectitem oitemSur = NEW objectitem();
                    if(oi.Application_No__c!= null)
                        oi.Application_No__c= oi.Application_No__c.replaceAll(oi.Jurisdiction__c,'');
                    String CC = oi.Jurisdiction__c;
                    String patNo = oi.Patent_No__c;
                    if(patNo != '-' && patNo != '' && patNo != null)
                    {
                         strAuditTrail += 'patNo: '+patNo;
                         strAuditTrail += 'CC: '+CC;
                        patNo = patNo.replaceall(CC,'');
                        system.debug('Country Code removed : '+patNo);
                        integer i = patNo.length()-1;
                        system.debug('length()-1 : '+ i);
                        i = patNo.length()-2;
                        system.debug('length()-2 : '+ i);
                        //string checkChar = patNo.substring(i);
                        string checkChar = patNo;
                        system.debug('checkChar : '+checkChar);
                        if(!checkChar.isNumeric())
                            patNo = patNo.substring(0,patNo.length()-2);
                    }
                    system.debug('patNo : '+patNo);
                    //if(oi.Patent_No__c!= null)
                    //    oi.Patent_No__c = oi.Patent_No__c.replaceAll(oi.Jurisdiction__c,'');
                    
                    oitem.PatentNo = patNo;
                    oitem.OrderNo = oi.Order__r.Name;
                    oitem.InvoiceNo = oi.Invoice__r.Invoice_No__c;
                    oitem.Billable = true;
                    oitem.ItemClass = 'MaxVal Group - 10:100';
                    string qbc = mapClientQBCustomer.get(oi.Order__r.Client__c);
                    if(qbc!=null)
                        oitem.CustomerRef = qbc;
                    else
                        oitem.CustomerRef = '';
                    
                    if(JurisdictionQBA.size() > 0)
                        oitem.AccountToRef = JurisdictionQBA[0].QB_Account_Id__c;
                    
                    /*MARS-715 Create Bill - Line Item Fee should be multiplied by the exchange rate
                     * Added by Saranyaa */
                    decimal feeWithExchangeRate = (oi.Fee__c * oi.Payment_Confirmation__r.Exchange_Rate__c).setScale(2,System.RoundingMode.CEILING);
                    oitem.Fee = string.valueOf(feeWithExchangeRate);
                    strAuditTrail += '| Calculated Line Item Fee: '+ feeWithExchangeRate;

                    Items.add(oitem);
                    recCounter = recCounter+1;
                    mapCounterWithAssetID.put(recCounter, oi.id);
                }
                system.debug('setClientRequestHandle :'+setClientRequestHandle);
                list<string> lstClientRequestHandle= NEW List<string>();
                lstClientRequestHandle.addAll(setClientRequestHandle);
                woi.ClientRequestHandle = lstClientRequestHandle[0];
                BillToCls cls = NEW BillToCls();
                cls.BillToRef = '';
                woi.BillTo = cls;
                //system.debug('setPaymentType :'+setPaymentType);
                //list<string> lstPaymentType= NEW List<string>();
                //lstPaymentType.addAll(setPaymentType);
                //system.debug('lstPaymentType[0] :'+lstPaymentType[0]);
                //woi.PaymentType=lstPaymentType[0]
                system.debug('>>'+lstAlpha);
                if(lstAlpha.size()>0)
                {
                    if(lstAlpha.size()>1)
                        woi.PaymentAccountRef = lstAlpha[1];//lstAlpha[0];
                    if(listois[0].Payment_Confirmation__r.Payment_Method__c == 'Wire Transfer')
                    {
                        woi.PaymentType= 'Bank'; 
                        /*MARS-749 Create Bill UI - Wire/Bank Fee field is enabled when user selects Payment type as Credit card
                        * MARS-751 Bank/Wire Fee need not to be passed to QBO if not applicable or fee is 0.00
                     	* Modified by Saranyaa */
                        if(listois[0].Payment_Confirmation__r.Wire_Bank_Fee__c != null && listois[0].Payment_Confirmation__r.Wire_Bank_Fee__c != 0.0)
                        {
                			strAuditTrail += '| Bank Item creation started';
                            objBankFeeItem BankItem = NEW objBankFeeItem();
                            if(JurisdictionQBA.size()>0)
                            {
                                BankItem.AccountToRef = JurisdictionQBA[0].QB_Account_Id__c;                            
                                BankItem.Billable = false;
                                BankItem.Description = 'Bank/Wire Fee';
                                BankItem.FeeClass = 'MaxVal Group - 10:100';
                                BankItem.Fee = string.valueOf(listois[0].Payment_Confirmation__r.Wire_Bank_Fee__c);
                                objBankFee bItems = NEW objBankFee();
                                bItems.Items = NEW List<objBankFeeItem>{BankItem};
                                woi.BankFee = bItems;
                                strAuditTrail += '| Completed';
                            }
                            else{
                                strAuditTrail += '| AccountRef is NOT available for the Jurisdiction';
                            }
                        }
                        else{
                            strAuditTrail += '| BankFeeItems is not sent as the Wire_Bank_Fee__c is 0 or null';
                        }
                    }
                    if(listois[0].Payment_Confirmation__r.Payment_Method__c == 'Credit Card')
                    {
                        woi.PaymentType= 'CreditCard'; 
                    }                        
                }
                woi.Memo = listois[0].Payment_Confirmation__r.Description__c;
                system.debug('countryCode :'+countryCode);
                list<string> strs = NEW list<string>();
                strs.addall(countryCode);
                string code=strs[0];
                system.debug('C Code:'+code);
                if(countryAuth.containsKey(code))
                    woi.AuthHandleRef = countryAuth.get(code);
                system.debug(woi.AuthHandleRef);
                if(APIAuthRec!=null && APIAuthRec.Name!= null)
                    woi.APIHandleRef = APIAuthRec.Name;
                woi.Items = Items;
                
                if(JurisdictionQBS.size()>0)
                {
                    BillToCls bt = NEW BillToCls();
                    bt.BillToRef = JurisdictionQBS[0].QB_Supplier_Id__c;
                    woi.BillTo = bt;
                }
                
                string jsonbody = JSON.serialize(woi);
                //jsonbody='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","AuthHandleRef":"b772a5ac-7565-48de-b3ff-15168aa72c3a","Jurisdiction":"US","Items":[{"ApplicationNumber":"14513841","PatentNumber":"10565402","SerialNumber":"","PublicationNumber":"","AttorneyDocketNumber":"P491US1","RenewalYear":"","FilingDate":"","FeeCode":"1551","Fee":"1500.55"}]}';
                strAuditTrail += '| Request Body :'+jsonbody+' | ';
                system.debug('Request Body :'+jsonbody);
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setEndpoint(credentials.URL__c);
                req.setHeader('Authorization', 'Bearer ' + AccessToken);
                req.setHeader('Content-Type','application/json;charset=UTF-8');
                req.setHeader('Content-Length', string.valueOf(jsonbody.length()));            
                req.setBody(jsonbody);
                req.setTimeout(120000);
                HttpResponse res = http.send(req);  
                system.debug('Response status code :'+res.getStatusCode() +' |Status :'+res.getStatus() +' |Body '+res.getBody());          
                strAuditTrail += '| Response status code :'+res.getStatusCode() +' |Status :'+res.getStatus() +' |Body '+res.getBody()+' | ';
                List<Order_Item__c> oits = NEW List<Order_Item__c>();
                Payment_Confirmation__c pc = NEW Payment_Confirmation__c();
                /*List<Order_Item__c> alloits = NEW List<Order_Item__c>();
                if(OrderItemMap.containskey(keyOI))
                {
                alloits = OrderItemMap.get(keyOI);
                }*/
                responsebody resb;
                List<responseerror> Errors = NEW List<responseerror>();
                List<responseerror> Warnings = NEW List<responseerror>();
                List<responseerroritem> ErrorItems = NEW List<responseerroritem>();
                List<responseerroritem> WarningItems = NEW List<responseerroritem>();
                List<responseerroritem> BankFeeErrorItems = NEW List<responseerroritem>();
                List<responseerroritem> BankFeeWarningItems = NEW List<responseerroritem>();
                
                string strres = res.getBody();
                resb = (responsebody)JSON.deserialize(strres, responsebody.Class);
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201)
                {
                    strAuditTrail += ' |IF |';
                    string errormessages = '';                    
                    for(Order_Item__c oi : OrderItemMap.get(keyOI))
                    {
                        //oi.Paid_Status__c = 'Requested to Pay PTO';
                        //oi.PTO_Validation_Status__c = 'Validation Requested';
                        //if(resb.RequestID!=null && resb.RequestID!='')
                        //    oi.PTO_Validation_Request_ID__c = resb.RequestID; 
                        /*if(errormessages!='')
                        oi.PTO_Validation_Message__c = errormessages;*/
                        oi.Payment_API_Message__c = null;
                        if(mapAssetError.containsKey(oi.id))
                            oi.Payment_API_Message__c = mapAssetError.get(oi.id);
                        if(mapAssetWarning.containsKey(oi.id))
                        {
                            if(oi.Payment_API_Message__c == null)
                            {
                                oi.Payment_API_Message__c = mapAssetWarning.get(oi.id);
                            }
                            else
                                oi.Payment_API_Message__c =  oi.Payment_API_Message__c + mapAssetWarning.get(oi.id);
                        }
                        oits.add(oi);                            
                    }
                    if(resb.status == 1)
                    {
                        pc.Status__c= 'Requested';
                    }
                    else if(resb.status == 2)
                    {
                        pc.Status__c= 'Validation Failed';
                    }
                    else if(resb.status == 3)
                    {
                        pc.Status__c= 'Validation Failed';
                    }
                    
                }
                else if(res.getStatusCode() == 404)
                {
                    apiResponse resbFail = (apiResponse)JSON.deserialize(strres, apiResponse.Class);
                    pc.Payment_API_Message__c = resbFail.Message;
                    pc.Status__c= 'Failed';
                }
                else
                {
                    strAuditTrail += ' | Else |';
                    if(listois.size()>0 && resb!= null)
                    {
                        pc.Status__c= 'Failed';
                        Errors = resb.Errors;
                        Warnings = resb.Warnings;
                        ErrorItems = resb.ErrorItems;
                        WarningItems = resb.WarningItems;
                        BankFeeErrorItems = resb.BankFeeErrorItems;
                        BankFeeWarningItems = resb.BankFeeWarningItems;
                        strAuditTrail += ' ErrorItems : '+ErrorItems.size();                        
                        if(ErrorItems.size() > 0)
                        {
                            for(responseerroritem eItem :  ErrorItems)
                            {
                                string itemErrorMsg = 'Error(s): ';
                                for(responseerror ei : eItem.Errors)
                                {
                                    itemErrorMsg = ei.Code+': '+ei.Description + '; ';
                                }
                                mapAssetError.put(mapCounterWithAssetID.get(eItem.RowNumber), itemErrorMsg);                            
                                strAuditTrail += itemErrorMsg;
                            }
                        }
                        strAuditTrail += ' WarningItems : '+WarningItems.size();
                        if(WarningItems.size() > 0)
                        {
                            for(responseerroritem eItem :  WarningItems)
                            {
                               // if(mapCounterWithAssetID.containsKey(eItem.RowNumber))
                                {
                                    string itemWarningMsg = '   Warning(s): ';
                                    for(responseerror ei : eItem.Errors)
                                    {
                                        itemWarningMsg += ', '+ei.Code+'-'+ei.Description + '; ';
                                    }
                                    mapAssetWarning.put(mapCounterWithAssetID.get(eItem.RowNumber), itemWarningMsg);
                                }
                            }                        
                        }
                        strAuditTrail += ' BankFeeErrorItems : '+BankFeeErrorItems.size();                        
                        if(BankFeeErrorItems.size() > 0)
                        {
                            for(responseerroritem eItem :  BankFeeErrorItems)
                            {
                                string itemErrorMsg = 'BankFeeError(s): ';
                                for(responseerror ei : eItem.Errors)
                                {
                                    itemErrorMsg = ei.Code+': '+ei.Description + '; ';
                                }
                                mapAssetError.put(mapCounterWithAssetID.get(eItem.RowNumber), itemErrorMsg);                            
                                strAuditTrail += itemErrorMsg;
                            }
                        }
                        strAuditTrail += ' BankFeeWarningItems : '+BankFeeWarningItems.size();
                        if(BankFeeWarningItems.size() > 0)
                        {
                            for(responseerroritem eItem :  BankFeeWarningItems)
                            {
                               // if(mapCounterWithAssetID.containsKey(eItem.RowNumber))
                                {
                                    string itemWarningMsg = '   BankFeeWarning(s): ';
                                    for(responseerror ei : eItem.Errors)
                                    {
                                        itemWarningMsg += ', '+ei.Code+'-'+ei.Description + '; ';
                                    }
                                    mapAssetWarning.put(mapCounterWithAssetID.get(eItem.RowNumber), itemWarningMsg);
                                }
                            }                        
                        }
                        for(Order_Item__c oi : listois)
                        {
                            strAuditTrail += ' Errors are there for '+oi.id+' '+mapAssetError.containsKey(oi.id)+' ';
                            strAuditTrail += ' Warnings are there for '+oi.id+' '+mapAssetWarning.containsKey(oi.id)+' ';
                            if(mapAssetError.containsKey(oi.id))
                            {
                                oi.Bill_API_Message__c = mapAssetError.get(oi.id);
                            }
                            else
                                oi.Bill_API_Message__c = 'Bill creation request placed';
                            if(mapAssetWarning.containsKey(oi.id))
                            {
                                if(oi.Bill_API_Message__c == null)
                                {
                                    oi.Bill_API_Message__c = mapAssetWarning.get(oi.id);
                                }
                                else
                                    oi.Bill_API_Message__c =  oi.Bill_API_Message__c + mapAssetWarning.get(oi.id);
                            }
                            strAuditTrail += '>>>'+oi.Payment_API_Message__c+'<<<';
                            oits.add(oi);
                        }
                    }                    
                }
                strAuditTrail += ' Records to update : '+oits.size();
                pc.id = pcID;
                if(res.getStatusCode() != 404)
                {
                    pc.Payment_API_Message__c= null;
                    string errormessage = ''; 
                    if(Errors.size()>0)
                    {
                        for(responseerror re : Errors)
                        {
                            errormessage+='Error Code: '+re.Code+' Description: '+re.Description+' |';
                        }
                    }
                    if(Warnings.size()>0)
                    {
                        for(responseerror re : Warnings)
                        {
                            errormessage+='Warning Code: '+re.Code+' Description: '+re.Description+' |';
                        }
                    }
                    if(errormessage != '')
                        pc.Payment_API_Message__c= errormessage;
                }
                if(resb !=null && resb.RequestID!=null && resb.RequestID!='')
                    pc.Bill_Request_ID__c = resb.RequestID;
                update pc;
                if(oits.size()>0)
                {
                    update oits;
                }
            }            
        }
        catch(Exception e)
        {
            status = 'Fail';
            strAuditTrail += ' || Error :'+e.getMessage()+' Line :'+e.getLineNumber();
            system.debug('Error :'+e.getMessage()+' Line :'+e.getLineNumber());
        }
        finally
        {
            system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('batchRenewalBillCreate',strAuditTrail,status);
        }
    }
    public void finish(Database.BatchableContext BC)
    {
        
    }
    public class ReqData
    {
        public string ClientRequestHandle{get;set;}
        public string AuthHandleRef{get;set;}
        public string APIHandleRef{get;set;}
        public List<objectitem> Items{get;set;}
        public BillToCls BillTo{get;set;}
        public objBankFee BankFee{get;set;}
        public string Memo{get;set;}
        public string PaymentType{get;set;}
        public string PaymentAccountRef{get;set;}
    }
    public class BillToCls
    {
        public string BillToRef{get;set;}
    }
    public class objectitem
    {
        public string PatentNo{get;set;}
        public string OrderNo{get;set;}
        public string InvoiceNo{get;set;}        
        public boolean Billable{get;set;}
        public string ItemClass{get;set;}
        //public string Class{get;set;}
        public string CustomerRef{get;set;}
        public string AccountToRef{get;set;}
        public string Fee{get;set;}
    }
    public class objBankFee
    {
        public List<objBankFeeItem> Items{get;set;}
    }
    public class objBankFeeItem
    {
        public string AccountToRef{get;set;}
        public boolean Billable{get;set;}
        public string Description{get;set;}
        public string FeeClass{get;set;}
        public string Fee{get;set;}     
    }
    public class responsebody
    {
        public integer Status{get;set;}
        public string RequestID{get;set;}
        public List<responseerror> Errors{get;set;}
        public List<responseerror> Warnings{ get;set;}
        public List<responseerroritem> ErrorItems{ get; set; }
        public List<responseerroritem> WarningItems{ get; set; }
        public List<responseerroritem> BankFeeErrorItems{ get; set; }
        public List<responseerroritem> BankFeeWarningItems{ get; set; }
    }
    public class responseerror
    {
        public string Code{ get; set; }
        public string Description{ get; set; }
    }
    public class responseerroritem
    {
        public integer RowNumber{ get; set; }
        public List<responseerror> Errors{ get; set; }
    }
    public class apiResponse
    {
        public string Message{ get; set; }
        public string Description{ get; set; }
    }
}