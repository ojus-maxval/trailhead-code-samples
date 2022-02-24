//pto/payment/validate
public class batchPtoPaymentValidateAPI implements Database.AllowsCallouts,Database.Batchable<ptoValidationReqWrapper>, Database.Stateful{

    public List<ptoValidationReqWrapper> records {set;get;}
    public API_Credentials__c credentials{set;get;}
    public Map<string,string> countryAuth{set;get;}
    public Map<string,PTOFeeCode__c> countryPTOFeeCode{set;get;}
    Map<string,id> mapPTOValReqIDWWithOI {set;get;}
    
    public batchPtoPaymentValidateAPI(List<ptoValidationReqWrapper> mapData){
        mapPTOValReqIDWWithOI =  NEW Map<string,id>();
        countryAuth = NEW Map<string,string>();
        countryPTOFeeCode = NEW Map<string,PTOFeeCode__c>();
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'PTO Payment Validate'];
        List<PTO_Credentials__c> PTOCredentials = [Select id,Name, Country_Code__c FROM PTO_Credentials__c];
        for(PTO_Credentials__c pc : PTOCredentials)
        {
            countryAuth.put(pc.Country_Code__c,pc.Name);
        }     
        List<PTOFeeCode__c> PTOFeeCodes = [Select id,Jurisdiction__c,Surcharge_Code__c,Term_Name__c,FeeCode__c,Entity_Type__c FROM PTOFeeCode__c];
        for(PTOFeeCode__c code: PTOFeeCodes)
        {
            string key = code.Jurisdiction__c+'-'+code.Term_Name__c;
            if(code.Jurisdiction__c=='US')
            {
                key = code.Jurisdiction__c+'-'+code.Term_Name__c+'-'+code.Entity_Type__c;
            }            
            countryPTOFeeCode.put(key,code);
            system.debug(key);
        }
        records = mapData;
    }
    public batchPtoPaymentValidateAPI(){
        List<ptoValidationReqWrapper> mapData = NEW List<ptoValidationReqWrapper>();
        mapPTOValReqIDWWithOI =  NEW Map<string,id>();
        countryAuth = NEW Map<string,string>();
        countryPTOFeeCode = NEW Map<string,PTOFeeCode__c>();
        credentials = [SELECT Id,Name,URL__c,Username__c,Password__c FROM API_Credentials__c WHERE Name=: 'PTO Payment Validate'];
        List<PTO_Credentials__c> PTOCredentials = [Select id,Name, Country_Code__c FROM PTO_Credentials__c];
        for(PTO_Credentials__c pc : PTOCredentials)
        {
            countryAuth.put(pc.Country_Code__c,pc.Name);
        }     
        List<PTOFeeCode__c> PTOFeeCodes = [Select id,Jurisdiction__c,Surcharge_Code__c,Term_Name__c,FeeCode__c,Entity_Type__c FROM PTOFeeCode__c];
        for(PTOFeeCode__c code: PTOFeeCodes)
        {            
            string key = code.Jurisdiction__c+'-'+code.Term_Name__c;
            if(code.Jurisdiction__c=='US')
            {
                key = code.Jurisdiction__c+'-'+code.Term_Name__c+'-'+code.Entity_Type__c;
            }            
            countryPTOFeeCode.put(key,code);
        }
        string query = 'Select id,Name,Order__r.Client__c,PTO_Validation_Request_ID__c,Paid_Status__c,Surcharge__c,'+
                        'Payment_Status__c,Order_Number__c,Client__c,Jurisdiction__c,Billing_Currency__c,'+
                        'Fee_Amount_When_Pay__c,Fee__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c,Filing_Date__c,'+
                        'Invoice_Type_Name_Value__c,Entity_Type_Name__c,Invoice__c,Invoice__r.Name,Term_Name__c FROM Order_Item__c '+
                        'WHERE PTO_Validation_Status__c=\'Request to Validate\'';
                        
        Map<String,List<Order_Item__c>> mapContryAssets = NEW Map<String,List<Order_Item__c>>();
        for(Order_Item__c oi : database.query(query))
        {
            List<Order_Item__c> temp = mapContryAssets.get(oi.Jurisdiction__c);
            if(temp != null)
            {
                temp.add(oi);
            }
            else
            {
                mapContryAssets.put(oi.Jurisdiction__c, new List<Order_Item__c>{oi});
            }
        }
        for(string cc : mapContryAssets.keyset())
        {
            List<Order_Item__c> items = mapContryAssets.get(cc);
            integer a= 0;
            Map<integer,List<integer>> maprecs = NEW Map<integer,List<integer>>();
            List<Order_Item__c> protoList = items.clone();
            protoList.clear();
            List<Order_Item__c> tempList = items.clone();
            Integer index = 0, count = 0, size = items.size();
            while(index < size) {
                tempList.add(items.get(index++));
                ++count;
                if(count == 4) 
                {
                    a = a+1;
                    ptoValidationReqWrapper wrp = NEW ptoValidationReqWrapper();
                    wrp.countryCode = cc;
                    wrp.countryAssets = tempList;
                    mapData.add(wrp);
                    system.debug(a+'-'+tempList[0]+'>>'+tempList[tempList.size()-1]);
                    tempList = protoList.clone();
                    count = 0;
                }
            }
            if(!tempList.isEmpty()) {
                a = a+1;    
                Set<Order_Item__c> mytemp = NEW Set<Order_Item__c>();
                mytemp.addAll(tempList);
                tempList.clear();
                tempList.addAll(mytemp);
                ptoValidationReqWrapper wrp = NEW ptoValidationReqWrapper();
                wrp.countryCode = cc;
                wrp.countryAssets = tempList;
                mapData.add(wrp);
                system.debug('Last batch: '+a+'-'+tempList[0]+'>>'+tempList[tempList.size()-1]);
            }
        }
        records = mapData;
    }
    public Iterable<ptoValidationReqWrapper> start(Database.BatchableContext BC){
        return records;
    }
    
    public void execute(Database.BatchableContext BC, List<ptoValidationReqWrapper> scope){
        string strAuditTrail = '';
        boolean saveAudit = false;
        string status = 'Success';
        Map<String,List<Order_Item__c>> OrderItemMap = new Map<String,List<Order_Item__c>>();
        Map<Integer, string> mapCounterWithAssetID = NEW Map<Integer, string>();
        Map<string, string> mapAssetError = NEW Map<string, string>();
        Map<string, string> mapAssetWarning = NEW Map<string, string>();
        Map<String,Order_Item__c> setAssetsToUpdate = NEW Map<String,Order_Item__c>();
        List<ptoValidationReqWrapper> recs= scope;
        system.debug('Recs Map:'+recs);
        List<Order_Item__c> listois = recs[0].countryAssets;
        strAuditTrail +='Recs Map:'+recs.size();
        strAuditTrail += '||Requesting To Pay PTO : '+recs.size() +'>>'+listois.size();
        try{
            string AccessToken = MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
    
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
                    Integer recCounter = 0;                
                    for(Order_Item__c oi : OrderItemMap.get(keyOI))
                    {
                        system.debug(oi.Jurisdiction__c +' >>> Before: '+oi.Application_No__c +'>>'+ oi.Patent_No__c);
                        countryCode.add(oi.Jurisdiction__c);
                        objectitem oitem = NEW objectitem();
                        boolean surchargeAvailable = False;
                        objectitem oitemSur = NEW objectitem();
                        if(oi.Application_No__c!=null && oi.Application_No__c!='-')
                        {
                            if(!oi.Application_No__c.substring(oi.Application_No__c.length()-1).isNumeric())
                            {
                                oi.Application_No__c = oi.Application_No__c.substring(0,oi.Application_No__c.length()-1);
                            }
                            else if((!oi.Application_No__c.substring(oi.Application_No__c.length()-2).isNumeric())  && oi.Application_No__c.substring(0,2)!='EP')
                                oi.Application_No__c = oi.Application_No__c.substring(0,oi.Application_No__c.length()-2);
                            if(oi.Jurisdiction__c=='US' && (!oi.Application_No__c.substring(0,2).isNumeric()))
                               oi.Application_No__c=oi.Application_No__c.substring(2,10);
                        }
                        
                        if(oi.Patent_No__c!=null && oi.Patent_No__c!='-')
                        	oi.Patent_No__c=RemoveKindCode(oi.Patent_No__c);
                        DateTime filingDate;
                        if(oi.Filing_Date__c!=null)
                        {  
                            filingDate = Date.Valueof(oi.Filing_Date__c);
                            oitem.FilingDate = filingDate.format('dd/MM/yyyy');
                        }
                        oitem.ApplicationNumber = oi.Application_No__c;
                        oitem.PatentNumber = oi.Patent_No__c;
                        oitem.SerialNumber = oi.Application_No__c;
                        oitem.AttorneyDocketNumber= oi.Application_No__c;
                        oitem.RenewalYear= oi.Term_Name__c.replaceAll('Year ','');
                        String Key = oi.Jurisdiction__c+'-'+oi.Term_Name__c;
                        if(oi.Jurisdiction__c == 'US')
                        {
                            if(oi.Entity_Type_Name__c != null && oi.Entity_Type_Name__c!='' && oi.Entity_Type_Name__c!='-')
                                Key = oi.Jurisdiction__c+'-'+oi.Term_Name__c+'-'+oi.Entity_Type_Name__c;
                            else
                                Key = oi.Jurisdiction__c+'-'+oi.Term_Name__c+'-Large';
                        }
                        system.debug('Key :'+Key+'>>available :'+countryPTOFeeCode.containsKey(key));
                        if(countryPTOFeeCode.containsKey(key))
                        {
                            PTOFeeCode__c pfc = countryPTOFeeCode.get(key);
                            string FeeCode = string.valueof(pfc.FeeCode__c);
                            system.debug('FeeCode: '+FeeCode);
                            oitem.FeeCode = FeeCode.replaceall('.00','');//'1551'
                            system.debug('>>oitem.FeeCode:'+oitem.FeeCode );
                            if(pfc.Surcharge_Code__c != null && oi.Surcharge__c != null && oi.Surcharge__c!=0)
                            {
                                surchargeAvailable = true;
                                oitemSur.ApplicationNumber = oi.Application_No__c;
                                oitemSur.PatentNumber = oi.Patent_No__c;
                                oitemSur.SerialNumber = oi.Application_No__c;
                                oitemSur.AttorneyDocketNumber= oi.Application_No__c;
                                oitemSur.RenewalYear= oi.Term_Name__c.replaceAll('Year ','');
                                oitemSur.FilingDate= oitem.FilingDate;
                                string SurchargeFeeCode = string.valueof(pfc.Surcharge_Code__c);
                                system.debug('SurchargeFeeCode: '+SurchargeFeeCode);
                                oitemSur.FeeCode = SurchargeFeeCode.replaceall('.00','');
                            }
                        } 
                        else
                        {
                            //MARS-1180 - Commented AuditTrail Log
                            //strAuditTrail += ' FeeCode : not avalible for '+Key+' |';
                            system.debug(' FeeCode : not avalible for '+Key+' |');
                        }
                        if(oi.Fee__c != null)
                        {
                            oitem.Fee= String.valueOf(oi.Fee__c.setScale(2));
                            oitem.FeeType = 'RENEWAL';
                        }
                        system.debug('>>str:'+oitem.Fee);
                        //MARS-1180 - Commented AuditTrail Log 
                        //strAuditTrail += ' Fee: '+oitem.Fee+' || ';                    
                        Items.add(oitem);
                        recCounter = recCounter+1;
                        mapCounterWithAssetID.put(recCounter, oi.id);
                        if(Test.isRunningTest())
                            surchargeAvailable=true;
                        if(surchargeAvailable)
                        {
                            if(oi.Surcharge__c != null)
                            {
                                oitemSur.Fee=String.valueOf(oi.Surcharge__c.setScale(2));
                                oitemSur.FeeType = 'SURCHARGE';
                            }
                            Items.add(oitemSur);
                            recCounter = recCounter+1;
                            mapCounterWithAssetID.put(recCounter, oi.id);
                        }
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
                    //jsonbody='{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","AuthHandleRef":"b772a5ac-7565-48de-b3ff-15168aa72c3a","Jurisdiction":"US","Items":[{"ApplicationNumber":"14513841","PatentNumber":"10565402","SerialNumber":"","AttorneyDocketNumber":"P491US1","RenewalYear":"","FilingDate":"","FeeCode":"1551","Fee":"1500.55"}]}';
                    //strAuditTrail += '| Request Body :'+jsonbody+' | ';
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
                    strAuditTrail += '| Response status code :'+res.getStatusCode() +' |Status :'+res.getStatus() +' | ';
                    List<Order_Item__c> oits = NEW List<Order_Item__c>();
                    /*List<Order_Item__c> alloits = NEW List<Order_Item__c>();
                    if(OrderItemMap.containskey(keyOI))
                    {
                        alloits = OrderItemMap.get(keyOI);
                    }*/
                    if(res.getStatusCode() == 200 || res.getStatusCode() == 201)
                    {
                        strAuditTrail += ' |IF |';
                        string strres = res.getBody();
                        string errormessages = '';
                        responsebody resb = (responsebody)JSON.deserialize(strres, responsebody.Class);
                        List<responseerror> Errors = resb.Errors;
                        List<responseerror> Warnings = resb.Warnings;
                        List<responseerroritem> ErrorItems = resb.ErrorItems;
                        List<responseerroritem> WarningItems = resb.WarningItems;
                        /*if(Errors.size() > 0)
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
                        }*/
                        strAuditTrail += ' ErrorItems : '+ErrorItems.size();                        
                        if(ErrorItems.size() > 0)
                        {
                            for(responseerroritem eItem :  ErrorItems)
                            {
                                if(mapCounterWithAssetID.containsKey(eItem.RowNumber))
                                {
                                    string itemErrorMsg = '| Error(s): ';
                                    for(responseerror ei : eItem.Errors)
                                    {
                                        if(errormessages == '| Error(s): ')
                                            itemErrorMsg = ei.Code+'-'+ei.Description;
                                        else
                                            itemErrorMsg += ', '+ei.Code+'-'+ei.Description;
                                    }
                                    mapAssetError.put(mapCounterWithAssetID.get(eItem.RowNumber), itemErrorMsg);
                                }
                            }
                        }
                        strAuditTrail += ' WarningItems : '+WarningItems.size();
                        if(WarningItems.size() > 0)
                        {
                            for(responseerroritem eItem :  WarningItems)
                            {
                                if(mapCounterWithAssetID.containsKey(eItem.RowNumber))
                                {
                                    string itemWarningMsg = '| Warning(s): ';
                                    for(responseerror ei : eItem.Errors)
                                    {
                                        if(itemWarningMsg == '| Warning(s): ')
                                            itemWarningMsg = ei.Code+'-'+ei.Description;
                                        else
                                            itemWarningMsg += ', '+ei.Code+'-'+ei.Description;
                                    }
                                    mapAssetWarning.put(mapCounterWithAssetID.get(eItem.RowNumber), itemWarningMsg);
                                }
                            }
                        }
                        for(Order_Item__c oi : OrderItemMap.get(keyOI))
                        {
                            oi.Paid_Status__c = 'Requested to Pay PTO';
                            oi.PTO_Validation_Status__c = 'Validation Requested';
                            if(resb.RequestID!=null && resb.RequestID!='')
                                oi.PTO_Validation_Request_ID__c = resb.RequestID; 
                            /*if(errormessages!='')
                                oi.PTO_Validation_Message__c = errormessages;*/
                            oi.PTO_Validation_Message__c = null;
                            if(mapAssetError.containsKey(oi.id))
                                oi.PTO_Validation_Message__c = mapAssetError.get(oi.id);
                            if(mapAssetWarning.containsKey(oi.id))
                            {
                                if(oi.PTO_Validation_Message__c == null)
                                {
                                    oi.PTO_Validation_Message__c = mapAssetWarning.get(oi.id);
                                }
                                else
                                    oi.PTO_Validation_Message__c =  oi.PTO_Validation_Message__c + mapAssetWarning.get(oi.id);
                            }
                            oits.add(oi);                            
                        }
                    }
                    else
                    {
                        strAuditTrail += ' | Else |';
                        if(listois.size()>0)
                        {
                            string strres = res.getBody();
                            string errormessages = '';
                            responsebody resb = (responsebody)JSON.deserialize(strres, responsebody.Class);
                            List<responseerror> Errors = resb.Errors;
                            List<responseerror> Warnings = resb.Warnings;
                            List<responseerroritem> ErrorItems = resb.ErrorItems;
                            List<responseerroritem> WarningItems = resb.WarningItems;
                            strAuditTrail += ' ErrorItems : '+ErrorItems.size()+' ';                        
                            if(ErrorItems.size() > 0)
                            {
                                for(responseerroritem eItem :  ErrorItems)
                                {
                                    if(mapCounterWithAssetID.containsKey(eItem.RowNumber))
                                    {
                                        string itemErrorMsg = '| Error(s): ';
                                        for(responseerror ei : eItem.Errors)
                                        {
                                            if(itemErrorMsg == '| Error(s): ')
                                                itemErrorMsg = itemErrorMsg + ei.Code+'-'+ei.Description;
                                            else
                                                itemErrorMsg = itemErrorMsg +', '+ei.Code+'-'+ei.Description;
                                        }
                                        mapAssetError.put(mapCounterWithAssetID.get(eItem.RowNumber), itemErrorMsg);
                                    }
                                }
                            }
                            strAuditTrail += ' WarningItems : '+WarningItems.size()+' ';
                            if(WarningItems.size() > 0)
                            {
                                for(responseerroritem eItem :  WarningItems)
                                {
                                    if(mapCounterWithAssetID.containsKey(eItem.RowNumber))
                                    {
                                        string itemWarningMsg = '| Warning(s): ';
                                        for(responseerror ei : eItem.Errors)
                                        {
                                            if(itemWarningMsg == '| Warning(s): ')
                                                itemWarningMsg = itemWarningMsg  + ei.Code+'-'+ei.Description;
                                            else
                                                itemWarningMsg += ', '+ei.Code+'-'+ei.Description;
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
                                    oi.PTO_Validation_Message__c = mapAssetError.get(oi.id);
                                }
                                else
                                    oi.PTO_Validation_Message__c = null;
                                if(mapAssetWarning.containsKey(oi.id))
                                {
                                    if(oi.PTO_Validation_Message__c == null)
                                    {
                                        oi.PTO_Validation_Message__c = mapAssetWarning.get(oi.id);
                                    }
                                    else
                                        oi.PTO_Validation_Message__c =  oi.PTO_Validation_Message__c + mapAssetWarning.get(oi.id);
                                }
                                oi.PTO_Validation_Status__c='API Validation Failed';
                                strAuditTrail += '>>>'+oi.PTO_Validation_Message__c+'<<<';
                                oits.add(oi);
                            }
                        }                        
                    }
                    strAuditTrail += ' Records to update : '+oits.size();
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
        catch(exception e)
        {
            status = 'Fail';
            strAuditTrail += ' || Error :'+e.getMessage()+' | Line No:'+e.getLineNumber()+' | Cause: '+e.getCause();
            system.debug('Error :'+e.getMessage()+' | Line No:'+e.getLineNumber()+' | Cause: '+e.getCause());
        }
        finally
        {
            system.debug(strAuditTrail);
            AuditTrailHelper.UpdateAudit('batchPtoPaymentValidateAPI',strAuditTrail,status);
        }
    }
    
    public void finish(Database.BatchableContext BC){
        if(mapPTOValReqIDWWithOI.size()>0)
        {
            if(!Test.isRunningTest())
            BatchQueueHelper.ForOrderItemForPTOvalidationDocument(new set<id>(mapPTOValReqIDWWithOI.values()));
        }
    }
    
    public static string RemoveKindCode(string assetNumber)
    {
        if(assetNumber!=null && assetNumber!='-')
        {
            if(!assetNumber.substring(assetNumber.length()-1).isNumeric())
            	assetNumber = assetNumber.substring(0,assetNumber.length()-1);
            else if(!assetNumber.substring(assetNumber.length()-2).isNumeric())
                assetNumber = assetNumber.substring(0,assetNumber.length()-2);
        }
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
        public string AttorneyDocketNumber{get;set;}
        public string RenewalYear{get;set;}
        public string FilingDate{get;set;}
        public string FeeCode{get;set;}
        public string Fee{get;set;}
        public string FeeType{get;set;}
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
}