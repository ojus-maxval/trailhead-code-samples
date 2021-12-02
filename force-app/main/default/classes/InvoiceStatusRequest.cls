@RestResource(urlMapping = '/renewal/invoice/request/status/*')
global class InvoiceStatusRequest
{
    @HttpPost
    global static resp InvoiceStatus() 
    {
        string status = 'Success';
        string strAuditTrail = '';
        system.debug('renewal/invoice/request');   
        String jsonString = RestContext.request.requestBody.toString();
        system.debug('Req Body: '+jsonString);
        strAuditTrail+='Req Body: '+jsonString+'||' ;
        JSONParser parser = JSON.createParser(jsonString);
        requestbody res = (requestbody)parser.readValueAs(requestbody.class);
        MAP<string,data> mapitems= NEW MAP<string,data>();
        set<string> InvRef=new set<string>();
        resp reslst = NEW resp();
        List<resError> errors = NEW List<resError>();
        list<Invoice__c> finalInvupdate=new list<Invoice__c>();
        string strclintbody='';
        strclintbody=res.ClientRequestHandle;
        system.debug(strclintbody);
        if(strclintbody != '' && strclintbody != null && strclintbody != 'null')
        {
            string ReqID='';
            ReqID=res.RequestID;
            if(ReqID != '' && ReqID != null && ReqID != 'null')
            {
                if(res.Data!=null)
                {
                    for(data itm : res.Data)
                    {
                        InvRef.add(itm.InvoiceRef);
                        if(mapitems.containskey(itm.InvoiceRef))
                        {
                            resError er = NEW resError();
                            reslst.Status = false;
                            er.Code = 'Duplicate_Invoice';
                            er.Description= 'Duplicate Invoice No cant be processed.';
                            errors.add(er);
                            reslst.Error=errors;
                            return reslst;
                        }                            
                        else
                            mapitems.put(itm.InvoiceRef, itm); 
                    }
                }
                system.debug('mapitems'+mapitems);
                list<Invoice__c> ObjInvoice= [SELECT id,Name,Order__r.name,LEDES_Message__c,LEDES_Status__c from Invoice__c WHERE name IN:InvRef];// and Order__r.Client__c=:strclintbody
                
                if(ObjInvoice.size()>0)
                {
                    List<string> assetId=new List<string>();
                    for(Invoice__c inv : ObjInvoice){
                        if(mapitems.containsKey(inv.Name))
                        {
                            data rItem = mapitems.get(inv.Name);
                            system.debug('rItem '+rItem );
                            if(rItem.Status =='1')
                                inv.Invoice_Status__c='To Do';
                            if(rItem.Status =='2')
                                inv .Invoice_Status__c=' In Progress';
                            if(rItem.Status =='3')
                            {
                                inv .Invoice_Status__c='Completed';
                                inv .API_Status__c='Completed';
                                List<Order_Item__c> orderItemId=[Select id,Order__r.name from Order_Item__c where Order__r.name=:inv.Order__r.name];
                                if(orderItemId.size()>0)
                                {
                                    for(Order_Item__c item:orderItemId)
                                    {
                                        assetId.add(item.Id);
                                    }
                                }
                            }
                            if(rItem.Status =='4')
                                inv .Invoice_Status__c='Completed and Posted';
                            if(rItem.Status =='5')
                                inv .Invoice_Status__c='Posting Failed';
                            if(rItem.Status =='6')
                                inv .Invoice_Status__c='Failed';
                            LEDESResponse ledes=rItem.LEDESResponse;
                            if(ledes!=null)
                            {
                                inv.LEDES_Status__c=ledes.LEDESStatus;
                                string warningMessage='';
                                if(ledes.warning.size()>0)
                                {
                                    for(resError ledesWarning :ledes.warning)
                                    {
                                        if(warningMessage == '')
                                            warningMessage = ledesWarning.Code+'-'+ledesWarning.Description;
                                        else
                                            warningMessage += ', '+ledesWarning.Code+'-'+ledesWarning.Description;
                                    }
                                    inv.LEDES_Message__c=warningMessage;
                                }  
                            }
                            inv .Invoice_No__c=rItem.InvoiceNo;
                            finalInvupdate.add(inv);
                            if(inv.Invoice_Status__c== 'Completed')
                            {
                                strAuditTrail +='Invoice Generated for InvoiceRef - '+inv.Name+'||';
                                batchInstructionStatusUpdate CA = NEW batchInstructionStatusUpdate(assetId, 'Invoice Generated');
                				database.executebatch(CA, 1);
                                strAuditTrail+='Invoice Status updated to Symphony';
                            }
                        }
                    }
                }
                try
                {
                    if(finalInvupdate!=null && finalInvupdate.size()>0){                
                        update finalInvupdate;
                        reslst.Status = true;
                    }
                    else{
                        resError er = NEW resError();
                        reslst.Status = false;
                        er.Code = 'NO_DATA_FOUND';
                        er.Description= 'No data found';
                        errors.add(er);
                    }
                }
                catch(exception e)
                {
                    strAuditTrail += ' || Error :'+e.getMessage();
                    status = 'Fail';
                    resError er = NEW resError();
                    er.Code = '-';
                    er.Description = e.getMessage();
                    errors.add(er);            
                }
            }
            else{
                resError er = NEW resError();
                status = 'Fail';
                er.Code = 'REQ_ID_EMPTY';
                er.Description= 'RequestId is null or empty.';
                errors.add(er);
            }
        }
        else{
            resError er = NEW resError();
            status = 'Fail';
            er.Code = 'REQ_HNDL_EMPTY';
            er.Description= 'ClientRequestHandle content is null or empty.';
            errors.add(er);
        }
        reslst.Error=errors;
        AuditTrailHelper.UpdateAudit('InvoiceStatusRequest',strAuditTrail,status);
        return  reslst;  
    }
    /* {
"ClientRequestHandle": "a002E00000k8s3p_a022E00000bMtUd_USD",
"RequestID": "28c30658-28c30658-28c30658-28c30658",
"Status": 2,
"Error": [],
"Data":[
{
"InvoiceRef": "INV-36",
"Status": 3,
"InvoiceNo": "A202008001",
"Error": [],
"Warning":[]
},
{
"InvoiceRef": "INV-37",
"Status": 3,
"InvoiceNo": "A202008002",
"Error": [],
"Warning":[]
}
]
}*/
    global class requestbody
    {
        global string ClientRequestHandle{set;get;}
        global string RequestID{set;get;}
        global integer Status{set;get;}
        global List<data> Data{set;get;}
    }
    global class data
    {
        global string InvoiceRef{set;get;}
        global string InvoiceNo{set;get;}
        global string Status{set;get;}
        global List<error> Error{set;get;}
        global List<warning> warning{set;get;}
        global LEDESResponse LEDESResponse{set;get;}
    }
    global class LEDESResponse
    {
        global string LEDESStatus{set;get;}
        global List<resError> warning{set;get;}
    }
    global class errorbody
    {
        global string Description{set;get;}
    }
    global class error
    {
        global string Description{set;get;}
        global string Staus{set;get;}
    }
    global class warning
    {
        global string Description{set;get;}
    }
    global class resp
    {
        public boolean Status{set;get;}
        Public List<resError> Error{set;get;}
    }
    global class resError
    {
        public string Code{set;get;}
        public string Description{set;get;}
    }
}