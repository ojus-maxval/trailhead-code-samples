//pto/payment/validate
public class batchPtoPaymentValidate implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful
{
    public string query{set;get;}
    public string AccessToken{set;get;}
    public API_Credentials__c credentials{set;get;}
    public List<string> lstCIds{set;get;}
    public List<string> lstPersonIds{set;get;}
    Map<string,id> mapPTOValReqIDWWithOI {set;get;}
    public Map<string,string> countryAuth{set;get;}
    public Map<string,PTOFeeCode__c> countryPTOFeeCode{set;get;}
    public set<string> lstPersonEmails{set;get;}
    public List<string> disclosureIds{set;get;}
    public batchPtoPaymentValidate(List<string> cIds)
    {
        mapPTOValReqIDWWithOI =  NEW Map<string,id>();
        lstCIds = NEW List<string>();
        lstCIds = cIds;
        countryAuth = NEW Map<string,string>();
        List<PTO_Credentials__c> PTOCredentials = [Select id,Name, Country_Code__c FROM PTO_Credentials__c];
        for(PTO_Credentials__c pc : PTOCredentials)
        {
            countryAuth.put(pc.Country_Code__c,pc.Name);
        }
        countryPTOFeeCode = NEW Map<string,PTOFeeCode__c>();
        List<PTOFeeCode__c> PTOFeeCodes = [Select id,Jurisdiction__c,Surcharge_Code__c,Term_Name__c,FeeCode__c FROM PTOFeeCode__c];
        for(PTOFeeCode__c code: PTOFeeCodes)
        {
            countryPTOFeeCode.put(code.Jurisdiction__c+'-'+code.Term_Name__c,code);
        }
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'PTO Payment Validate'];
        query = 'select id from clients__c where id in: lstCIds';
    }
    public batchPtoPaymentValidate()
    {
        mapPTOValReqIDWWithOI =  NEW Map<string,id>();
        countryAuth = NEW Map<string,string>();
        List<PTO_Credentials__c> PTOCredentials = [Select id,Name, Country_Code__c FROM PTO_Credentials__c];
        for(PTO_Credentials__c pc : PTOCredentials)
        {
            countryAuth.put(pc.Country_Code__c,pc.Name);
        }
        //AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'Pto Payment Validate'];
        //query = 'SELECT id,Name,Paid_Status__c,Payment_Status__c,Order_Number__c,Client__c,Billing_Currency__c,Fee_Amount_When_Pay__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c FROM Order_Item__c where Paid_Status__c=\'Requesting to Pay PTO\' AND Payment_Status__c=\'Payment Received\'';
        query = 'select id from clients__c';// where id in:(SELECT Order__r.Client__c FROM Order_Item__c WHERE PTO_Validation_Status__c=\'Request to Validate\')
        system.debug(query);
    }
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<Clients__c> scope)
    {
        if(!test.isRunningTest())
            AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        else
            AccessToken = 'Test_Token';
        boolean saveAudit = false;
        string strAuditTrail = '';
        string status = 'Success';
        try
        {
            strAuditTrail += 'Requesting To Pay PTO : ';
            List<Order_Item__c> ois = NEW List<Order_Item__c>();
            //String AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
            Map<String,List<Order_Item__c>> OrderItemMap = new Map<String,List<Order_Item__c>>();
            
            List<Clients__c> clients = scope;
            List<Order_Item__c> listois = [Select id,Name,Order__r.Client__c,PTO_Validation_Request_ID__c,Paid_Status__c,Payment_Status__c,Order_Number__c,Client__c,Jurisdiction__c,Billing_Currency__c,Fee_Amount_When_Pay__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c,Invoice_Type_Name_Value__c,Invoice__c,Invoice__r.Name,Term_Name__c FROM Order_Item__c WHERE PTO_Validation_Status__c='Request to Validate' AND Order__r.Client__c=:scope[0].id];
            if(listois.size() > 0)
            {
                for(Order_Item__c oi : listois)
                {
                    List<Order_Item__c> temp = OrderItemMap.get(oi.Order__r.Client__c+'-'+oi.Jurisdiction__c);
                    if(temp != null)
                    {
                        temp.add(oi);
                    }
                    else
                    {
                        OrderItemMap.put(oi.Order__r.Client__c+'-'+oi.Jurisdiction__c, new List<Order_Item__c>{oi});
                    }
                }
                for(string keyOI : OrderItemMap.keyset())
                {
                    set<string> countryCode = NEW set<string>();
                    ReqData woi = NEW ReqData();               
                    List<objectitem> Items = NEW List<objectitem>();                
                    for(Order_Item__c oi : OrderItemMap.get(keyOI))
                    {
                        system.debug(oi.Jurisdiction__c +' >>> Before: '+oi.Application_No__c +'>>'+ oi.Patent_No__c);
                        countryCode.add(oi.Jurisdiction__c);
                        objectitem oitem = NEW objectitem();
                        if(oi.Application_No__c!=null && oi.Application_No__c!='-')
                        {
                            if(!oi.Application_No__c.substring(oi.Application_No__c.length()-1).isNumeric())
                            {
                                oi.Application_No__c = oi.Application_No__c.substring(0,oi.Application_No__c.length()-1); 
                        		strAuditTrail+= 'ApplicationNumber1 - '+oi.Application_No__c;
                            }
                        else if((!oi.Application_No__c.substring(oi.Application_No__c.length()-2).isNumeric())  && oi.Application_No__c.substring(0,2)!='EP')
                                oi.Application_No__c = oi.Application_No__c.substring(0,oi.Application_No__c.length()-2); 
                        }
                             
                        
                        if(oi.Patent_No__c!=null && oi.Patent_No__c!='-')
                        	oi.Patent_No__c=RemoveKindCode(oi.Patent_No__c);
                        else
                        	oi.Patent_No__c=RemoveKindCode(oi.Publication_No__c);
                        DateTime filingDate;
                        if(!Test.isRunningTest())
                        {
                            filingDate = Date.Valueof(oi.Filing_Date__c);
                        	oitem.FilingDate = filingDate.format('dd/MM/yyyy');
                        }
                         
                        
                        oitem.ApplicationNumber = oi.Application_No__c;
                        oitem.PatentNumber = oi.Patent_No__c;
                        oitem.SerialNumber = oi.Application_No__c;
                        if(!Test.isRunningTest())
                        {
                            if(oi.Publication_No__c==null || oi.Publication_No__c=='-')
                                oitem.PublicationNumber = oi.Patent_No__c;
                            else
                            {
                                oi.Publication_No__c=RemoveKindCode(oi.Publication_No__c);                       
                                oitem.PublicationNumber = oi.Publication_No__c;
                            }
                        }
                            
                        oitem.AttorneyDocketNumber= oi.Application_No__c;
                        oitem.RenewalYear= '';
                        oitem.FilingDate= '';
                        //oitem.FeeCode= oi.Billing_Currency__c;
                        String Key = oi.Jurisdiction__c+'-'+oi.Term_Name__c;
                        system.debug('Key :'+Key+'>>available :'+countryPTOFeeCode.containsKey(key));
                        if(countryPTOFeeCode.containsKey(key))
                        {
                            PTOFeeCode__c pfc = countryPTOFeeCode.get(key);
                            string FeeCode = string.valueof(pfc.FeeCode__c);
                            system.debug(FeeCode);
                            oitem.FeeCode = FeeCode.replaceall('.00','');//'1551'
                            system.debug('>>oitem.FeeCode:'+oitem.FeeCode );
                        } 
                        else
                        {
                            strAuditTrail += ' FeeCode : not avalible for '+Key+' |';
                             system.debug(' FeeCode : not avalible for '+Key+' |');
                        }
                        oitem.Fee= String.valueof(oi.Fee_Amount_When_Pay__c);
                        Items.add(oitem);
                        system.debug('After: '+oitem.ApplicationNumber +'>>'+ oitem.PatentNumber);
                    }
                    woi.ClientRequestHandle = keyOI;
                    list<string> strs = NEW list<string>();
                    strs.addall(countryCode);
                    string code=strs[0];
                    system.debug('C Code:'+code);
                    if(countryAuth.containsKey(code))
                        woi.AuthHandleRef = countryAuth.get(code);
                    system.debug(woi.AuthHandleRef);
                    woi.Jurisdiction = code;
                    woi.Items = Items;
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
                    List<Order_Item__c> alloits = NEW List<Order_Item__c>();
                    if(OrderItemMap.containskey(keyOI))
                    {
                        alloits = OrderItemMap.get(keyOI);
                    }
                    if(res.getStatusCode() == 200 || res.getStatusCode() == 201)
                    {
                        string strres = res.getBody();
                        string errormessages = '';
                        responsebody resb = (responsebody)JSON.deserialize(strres, responsebody.Class);
                        List<responseerror> Errors = resb.Errors;
                        List<responseerror> Warnings = resb.Warnings;
                        List<responseerroritem> ErrorItems = resb.ErrorItems;
                        List<responseerroritem> WarningItems = resb.WarningItems;
                        if(Errors.size() > 0)
                        {
                            errormessages += '| Errors : ';
                            for(responseerror ei :Errors)
                            {
                                if(errormessages == '')
                                    errormessages = ei.Code+'-'+ei.Description;
                                else
                                    errormessages += ', '+ei.Code+'-'+ei.Description;
                            }
                        }
                        if(Warnings.size() > 0)
                        {
                            errormessages += '| Warnings : ';
                            for(responseerror ei :Warnings)
                            {
                                if(errormessages == '')
                                    errormessages = ei.Code+'-'+ei.Description;
                                else
                                    errormessages += ', '+ei.Code+'-'+ei.Description;
                            }
                        }
                        for(Order_Item__c oi : OrderItemMap.get(keyOI))
                        {
                            oi.Paid_Status__c = 'Requested to Pay PTO';
                            oi.PTO_Validation_Status__c = 'Validation Requested';
                            if(resb.RequestID!=null && resb.RequestID!='')
                            	oi.PTO_Validation_Request_ID__c = resb.RequestID; 
                            if(errormessages!='')
                            	oi.PTO_Validation_Message__c = errormessages;
                            oits.add(oi);
                            
                        }
                    }
                    else
                    {
                        if(alloits.size()>0)
                        {
                            for(Order_Item__c oi : alloits)
                            {
                                oi.PTO_Validation_Message__c = 'Response status code :'+res.getStatusCode() +' |Status :'+res.getStatus() +' |Body '+res.getBody();
                                oits.add(oi);
                            }
                        }                        
                    }
                    if(oits.size()>0)
                    {
                    	update oits;
                        for(Order_Item__c pi : oits)
                        {
                            if(pi.PTO_Validation_Request_ID__c!=null && pi.PTO_Validation_Request_ID__c!='')
                            	mapPTOValReqIDWWithOI.put(pi.PTO_Validation_Request_ID__c,pi.id);
                        }
                    }
                }
            }
        }
        catch(Exception e)
        {
            status = 'Fail';
            strAuditTrail += ' || Error :'+e.getMessage();
            system.debug('Error :'+e.getMessage());
        }
        finally
        {
            system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('batchPtoPaymentValidate',strAuditTrail,status);
        }
    }
    public void finish(Database.BatchableContext BC)
    {
        if(mapPTOValReqIDWWithOI.size()>0)
        {
            BatchQueueHelper.ForOrderItemForPTOvalidationDocument(new set<id>(mapPTOValReqIDWWithOI.values()));
        }
    }
    public static string RemoveKindCode(string assetNumber)
    {
        if(!assetNumber.substring(assetNumber.length()-1).isNumeric())
            assetNumber = assetNumber.substring(0,assetNumber.length()-1);
        else if(!assetNumber.substring(assetNumber.length()-2).isNumeric())
            assetNumber = assetNumber.substring(0,assetNumber.length()-2);
        return assetNumber;
    }
    public class ReqData
    {
        public string ClientRequestHandle{get;set;}
        public string AuthHandleRef{get;set;}
        public string Jurisdiction{get;set;}
        public List<objectitem> Items{get;set;}
    }
    public class objectitem
    {
        public string ApplicationNumber{get;set;}
        public string PatentNumber{get;set;}
        public string SerialNumber{get;set;}        
        public string PublicationNumber{get;set;}
        public string AttorneyDocketNumber{get;set;}
        public string RenewalYear{get;set;}
        public string FilingDate{get;set;}
        public string FeeCode{get;set;}
        public string Fee{get;set;}
    }
    public class responsebody
    {
        public string RequestID{ get; set; }
        public List<responseerror> Errors{ get; set; }
        public List<responseerror> Warnings{ get; set; }
        public List<responseerroritem> ErrorItems{ get; set; }
        public List<responseerroritem> WarningItems{ get; set; }
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
    /*
    {
        "ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669",
        "AuthHandleRef":"b772a5ac-7565-48de-b3ff-15168aa72c3a",
        "Jurisdiction":"US",
        "Items":
        [
            {
                "ApplicationNumber":"14513841",
                "PatentNumber":"10565402",
                "SerialNumber":"",
                "PublicationNumber":"",
                "AttorneyDocketNumber":"P491US1",
                "RenewalYear":"",
                "FilingDate":"",
                "FeeCode":"1551",
                "Fee":"1500.55"
            },
            {
                "ApplicationNumber":"14513841",
                "PatentNumber":"10565402",
                "SerialNumber":"",
                "PublicationNumber":"",
                "AttorneyDocketNumber":"P491US1",
                "RenewalYear":"",
                "FilingDate":"",
                "FeeCode":"1551",
                "Fee":"1500.55"
            }
        ]
    }
	*/
}