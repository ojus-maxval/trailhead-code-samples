@RestResource(urlMapping='/pto/payment/validate/status/*')
global class PTOFeePaidServiceClass
{
    @HttpPost
    global static resp PTOFeePaid() 
    {
        resp reslst = NEW resp();        
        string strAuditTrail='';
        List<resError> errors = NEW List<resError>();
        try
        { 
            strAuditTrail+='PTOFeePaidServiceClass service called||';
            String jsonString = RestContext.request.requestBody.toString();
            strAuditTrail+='Req Body: '+jsonString+'||';
            JSONParser parser = JSON.createParser(jsonString);
            requestbody res = (requestbody)parser.readValueAs(requestbody.class);
            MAP<string,requestbodyItem> mapitems= NEW MAP<string,requestbodyItem>();
            MAP<string,requestbodyItem> mapBillError= NEW MAP<string,requestbodyItem>();
            //Bill Details
            string Billerrormessages = '';
            reqBillDetails rbd = res.BillDetails;
            if(rbd != null)
            {
                system.debug('inside rbd');
                List<billerror> lstrerror = rbd.Error;
                if(lstrerror.size() > 0)
                {
                    system.debug('lstrerror');
                    for(billerror ei :rbd.Error)
                    {
                        if(Billerrormessages == '')
                            Billerrormessages = ei.Code+'-'+ei.Description;
                        else
                            Billerrormessages += ', '+ei.Code+'-'+ei.Description;
                    }
                }
            }
            /*if(res.Items!=null)
            {
                for(requestbodyItem itm : res.Items){
                    if(mapitems.containskey(itm.ApplicationNumber+'-'+itm.PatentNumber))
                    {
                        resError er = NEW resError();
                        reslst.Status = false;
                        er.Code = '';
                        er.Description= 'Duplicate InvoiceNo cant be processed.';
                        errors.add(er);
                        reslst.Error=errors;
                        return reslst;
                    }
                    else
                        mapitems.put(itm.ApplicationNumber+'-'+itm.PatentNumber, itm);
                }
            }*/
            String ClientReqID = res.ClientRequestHandle;
            if(ClientReqID!=null && ClientReqID!='null' && ClientReqID!='')
            {
                system.debug('ClientReqID-'+ClientReqID);
                String MVRequestID = res.RequestID;
                system.debug('MVRefId :'+MVRequestID +' |Body :'+res);
                if(MVRequestID!=null && MVRequestID!='null' && MVRequestID!='')
                {
                    List<Order_Item__c > updateOI = NEW List<Order_Item__c >();
                    List<Order_Item__c > orderItems = [SELECT id,Jurisdiction__c,Name,Paid_Status__c,PTO_Validation_Request_ID__c,Payment_Status__c,Order_Number__c,Client__c,Fee_Amount_When_Pay__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c,PTO_Validation_Status__c,PTO_Validation_Message__c,Bill_No__c,Bill_Status__c,Bill_API_Code__c,Bill_API_Message__c FROM Order_Item__c WHERE PTO_Validation_Request_ID__c =: MVRequestID];
                    system.debug(orderItems.size());
                    if (orderItems.size()>0)
                    {
                        if(res.Items!=null)
                        {
                            system.debug('inside res.items');
                            for(requestbodyItem itm : res.Items){
                                string applicationNumber='';
                                string patentNumber='';
                                if(itm.ApplicationNumber!=null && itm.ApplicationNumber!='')
                                	applicationNumber=itm.ApplicationNumber.replaceAll(orderItems[0].Jurisdiction__c,'');
                                if(itm.PatentNumber!=null && itm.PatentNumber!='')
                                	patentNumber = itm.PatentNumber.replaceAll(orderItems[0].Jurisdiction__c,'');
                                
                                mapitems.put(applicationNumber+'-'+patentNumber, itm);
                                system.debug(applicationNumber+'-'+patentNumber);
                            }
                        }
                        for(Order_Item__c oi : orderItems)
                        {
                            system.debug(oi.id+'-'+oi.Patent_No__c);
                            String patentCode;
                            String applicationCode;
                            if(!oi.Application_No__c.substring(oi.Application_No__c.length()-1).isNumeric())
                            {
                                oi.Application_No__c = oi.Application_No__c.substring(0,oi.Application_No__c.length()-1);
                            }
                            else if((!oi.Application_No__c.substring(oi.Application_No__c.length()-2).isNumeric())  && oi.Application_No__c.substring(0,2)!='EP')
                                oi.Application_No__c = oi.Application_No__c.substring(0,oi.Application_No__c.length()-2);
                        	if(oi.Jurisdiction__c=='US' && (!oi.Application_No__c.substring(0,2).isNumeric()))
                           		oi.Application_No__c=oi.Application_No__c.substring(2,10);
                            if(oi.Patent_No__c!=null && oi.Patent_No__c!='-')
                                oi.Patent_No__c=RemoveKindCode(oi.Patent_No__c);
                            if(!oi.Application_No__c.substring(0,2).isNumeric() && oi.Application_No__c.substring(0,2)!=oi.Jurisdiction__c)
                                applicationCode=oi.Application_No__c.substring(0,2);
                            else
                                applicationCode=oi.Jurisdiction__c;
                            if(!oi.Patent_No__c.substring(0,2).isNumeric() && oi.Patent_No__c.substring(0,2)!=oi.Jurisdiction__c)
                                patentCode=oi.Patent_No__c.substring(0,2);
                            else
                                patentCode=oi.Jurisdiction__c;
                            system.debug(oi.Application_No__c.replaceAll(applicationCode,'')+'-'+oi.Patent_No__c.replaceAll(patentCode,''));
                            if(mapitems.containsKey(oi.Application_No__c.replaceAll(applicationCode,'')+'-'+oi.Patent_No__c.replaceAll(patentCode,'')))
                            {
                                system.debug('inside mapitems');
                                requestbodyItem rItem = mapitems.get(oi.Application_No__c.replaceAll(applicationCode,'')+'-'+oi.Patent_No__c.replaceAll(patentCode,''));
                                if(rItem.Status == 'VP')
                                    oi.PTO_Validation_Status__c = 'Validation Passed';
                                if(rItem.Status == 'VF')
                                    oi.PTO_Validation_Status__c = 'Validation Failed';
                                /*if(rItem.Status == 'PS')
                                    oi.PTO_Validation_Status__c = 'Payment Success';
                                if(rItem.Status == 'PF')
                                    oi.PTO_Validation_Status__c = 'Payment Failed';
                                
                                if(oi.PTO_Validation_Status__c == 'Payment Success')
                                {
                                    oi.Payment_Status__c = 'PTO/Agent Payments Completed';
                                    oi.PTO_fee_paid_status_updated_on__c = system.now();
                                    oi.Paid_Status__c = null;
                                }*/
                                if(rItem.Error.size()>0)
                                {
                                    string errormessages = '';
                                    for(errorbody ei :rItem.Error)
                                    {
                                        if(errormessages == '')
                                            errormessages = ei.Description;
                                        else
                                            errormessages += ', '+ei.Description;
                                    }
                                    oi.PTO_Validation_Message__c = errormessages;
                                }
                                else
                                {
                                    oi.PTO_Validation_Message__c = null;
                                }
                                //Bill Details
                                //reqBillDetails rbd = rItem.BillDetails;
                                if(rbd!=null)
                                {
                                    oi.Bill_No__c = rbd.BillNo;
                                    oi.Bill_Status__c = rbd.Status;
                                    List<resError> lstrerror = NEW List<resError>();
                                    if(lstrerror!=null)
                                    {
                                        //oi.Bill_API_Code__c= lstrerror[0].Code;
                                        if(Billerrormessages != '')
                                        	oi.Bill_API_Message__c = Billerrormessages;
                                    }
                                }
                            }
                            updateOI.add(oi);
                        }
                        try
                        {                            
                            reslst.Status = true; 
                            if(updateOI.size()>0)
                            {
                                update updateOI;
                                Map<string,id> mapPTOValReqIDWWithOI =  NEW Map<string,id>();
                                for(Order_Item__c pi : updateOI)
                                {
                                    if(pi.PTO_Validation_Request_ID__c!=null && pi.PTO_Validation_Request_ID__c!='' && (pi.PTO_Validation_Status__c == 'Validation Passed' || pi.PTO_Validation_Status__c == 'Validation Failed'))
                                        mapPTOValReqIDWWithOI.put(pi.PTO_Validation_Request_ID__c,pi.id);
                                }
                                if(mapPTOValReqIDWWithOI.size()>0)
                                {
                                    BatchQueueHelper.ForOrderItemForPTOvalidationDocument(new set<id>(mapPTOValReqIDWWithOI.values()));
                                }
                            }
                            else
                            {
                                system.debug('Internal Else: ');
                                reslst.Status = false;
                                resError er = NEW resError();
                                er.Code = 'NO_DATA_FOUND';
                                er.Description= 'No data found';
                                errors.add(er);
                            }
                        }
                        catch(exception e)
                        {
                            reslst.Status = false;
                            resError er = NEW resError();
                            er.Code = '-';
                            er.Description = e.getMessage();
                            errors.add(er);    
                            system.debug('Error: '+e.getMessage());
                        }            
                    }
                    else
                    {
                        system.debug('Else: ');
                        reslst.Status = false;
                        resError er = NEW resError();
                        er.Code = 'NO_DATA_FOUND';
                        er.Description= 'No data found';
                        errors.add(er); 
                    }
                }
                else
                {
                    reslst.Status = false;
                    resError er = NEW resError();
                    er.Code = 'REQ_ID_EMPTY';
                    er.Description= 'RequestId is null or empty.';
                    errors.add(er);
                }
            }
            else
            {
                reslst.Status = false;
                resError er = NEW resError();
                er.Code = 'REQ_HNDL_EMPTY';
                er.Description= 'ClientRequestHandle content is null or empty.';
                errors.add(er);
            }
        }
        catch(exception e)
        {
            reslst.Status = false;
            resError er = NEW resError();
            er.Code = '-';
            er.Description = e.getMessage();
            errors.add(er);    
            system.debug('Error: '+e.getMessage());
            strAuditTrail+='ExceptionStackTrace - '+e.getStackTraceString()+'||Message-'+e.getMessage();
        }
        finally
        {
            AuditTrailHelper.UpdateAudit('PTO Validation Status', strAuditTrail, '');
        }
        if(errors.size()>0)
            reslst.Status = false;
        /*else
        {
            system.debug('Else: ');
            resError er = NEW resError();
            er.Code = 'NO_DATA_FOUND';
            er.Description= 'No data found';
            errors.add(er); 
        }*/
        reslst.Error = errors;
        system.debug(reslst);
        return  reslst;        
    }
    public static string RemoveKindCode(string assetNumber)
    {
        if(!assetNumber.substring(assetNumber.length()-1).isNumeric())
            assetNumber = assetNumber.substring(0,assetNumber.length()-1);
        else if(!assetNumber.substring(assetNumber.length()-2).isNumeric())
            assetNumber = assetNumber.substring(0,assetNumber.length()-2);
        return assetNumber;
    }
    
    /*{"ClientRequestHandle":"d0cb82fc-a85a-42ea-b549-27ee7a3d3669","RequestID":"28c30658-9c8d-4c43-8135-4afc2e649d6f","Status":3,
* "Items":[{"ApplicationNumber":"14513841","PatentNumber":"10565402","Status":"VP","Error":[]},
* {"ApplicationNumber":"78901234","PatentNumber":"8543217","Status":"VF","Error":[{"Description":"Amount is missing"}]}],
* "Error":[],"Warning":[]
* }*/  
    
    global class responcebody
    {
        global string MVRefId{set;get;}
        global string Status{set;get;}
    }
    global class requestbody
    {
        global string ClientRequestHandle{set;get;}
        global string RequestID{set;get;}
        global integer Status{set;get;}
        global List<requestbodyItem> Items{set;get;}
        global reqBillDetails BillDetails{set;get;}
        global List<error> Error{set;get;}
        global List<warning> Warning{set;get;}
    }
    global class requestbodyItem
    {
        global string ApplicationNumber{set;get;}
        global string PatentNumber{set;get;}
        global string Status{set;get;}
        global List<errorbody> Error{set;get;}
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
    global class billerror
    {
        global string Description{set;get;}
        global string Code{set;get;}
    }
    global class warning
    {
        global string Description{set;get;}
    }
    global class resp
    {
        global boolean Status{set;get;}
        global List<resError> Error{set;get;}
    }
    global class resError
    {
        global string Code{set;get;}
        global string Description{set;get;}
    }
    global class reqBillDetails
    {
        global string Status{set;get;}
        global string BillNo{set;get;}
        global List<billerror> Error{set;get;}
        global List<billerror> Warning{set;get;}
    }
}