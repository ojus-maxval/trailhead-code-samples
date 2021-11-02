trigger trgOrder on Order__c (before update,before insert, after Insert, after update) 
{
    string strAuditText = '>';
    try
    {      
        //ACTION: Read old records
        Map<Id,Order__c> mapOldOrders = new Map<Id,Order__c>();
        if (Trigger.isUpdate)
        {
            for (Order__c objOrder : Trigger.Old)
            {
                if (mapOldOrders.containsKey(objOrder.Id)==false) 
                    mapOldOrders.put(objOrder.Id, objOrder);
            }
        }
        //EVENT: Before
        if (Trigger.isBefore)
        {
            if (Trigger.isinsert)
            {
                set<string> clientids = NEW set<string>();
                Map<string,string> mapClientMail = NEW Map<string,string>();
                for(Order__c objNewOrder : Trigger.New)
                {
                    If(objNewOrder.Client__c !=null){
                        clientids.add(objNewOrder.Client__c);
                    }
                }
                if(clientids.size()>0)
                {
                    for(clients__c cts :[SELECT id,Contact_Email_Id__c FROM clients__c where id IN: new List<string>(clientids) ])
                    {
                        mapClientMail.put(cts.id, cts.Contact_Email_Id__c);
                    }
                }
                for (Order__c objNewOrder : Trigger.New)
                {
                    If(objNewOrder.Client__c !=null && mapClientMail.containskey(objNewOrder.Client__c)){
                        objNewOrder.Client_EmailId__c=mapClientMail.get(objNewOrder.Client__c);       
                    }
                }
            }
            if (Trigger.isUpdate)
            {
                //for (Order__c objNewOrder : Trigger.New)
                //{
                //    Order__c objOldOrder = null;
                //    if (mapOldOrders.containsKey(objNewOrder.Id)==true)
                //        objOldOrder = mapOldOrders.get(objNewOrder.Id);
                //}
                List<AsyncApexJob> lst = [select ApexClassId, Id, JobItemsProcessed, JobType, Status, NumberOfErrors, MethodName from AsyncApexJob where JobType in ('GenerateInvoiceBatch','BatchApex') AND (Status!='Completed' AND Status!='Aborted' AND Status!='Failed')];
                system.debug('>>>'+lst.size());
                for(Order__c objNewOrder : Trigger.New)
                {
                    Order__c objOldOrder = trigger.oldmap.get(objNewOrder.Id);
                    if(objOldOrder.Is_Sent_Invoice__c==false && objNewOrder.Is_Sent_Invoice__c==true)
                    {
                        if(lst.size()>0)
                        {
                            objNewOrder.adderror('Please wait for a while, there is another invoice(s) is in-process');
                        }
                    }
                }
            }
        }
        
        //EVENT: After
        if(Trigger.isAfter)
        {
            strAuditText += ' trigger.isafter > ';
            if (Trigger.isUpdate)
            {
                string invoiceDetails='';
                List<Id> lstOrderIdsToGenerateInvoice = new List<Id>();
                for (Order__c objNewOrders : Trigger.New )
                {
                    if(trigger.oldmap.get(objNewOrders.id).Is_Sent_Invoice__c==true)
                    {
                        invoiceDetails=invoiceDetails+'Name'+objNewOrders.name+'number'+objNewOrders.Is_Sent_Invoice__c;
                        if(invoiceDetails!=Null)
                        {
                            List<Invoice_Type_Configuration__c> ObjInvoicetypeconfig=[select id,name,Contact_Persons__c from Invoice_Type_Configuration__c ];
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            list<string> toadd=ObjInvoicetypeconfig[0].Contact_Persons__c.split(',');
                            message.toAddresses = toadd;
                            message.optOutPolicy = 'FILTER';
                            message.subject = 'Renewel';
                            String emailBody = '';
                            // emailBody  = InvoiceDetails;
                            message.setHtmlBody(emailBody);
                            //message.plainTextBody = 'This is the message body.';                            
                            try{
                                //Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                                  //  Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                            }
                            catch(exception e)
                            {
                                strAuditText += '| Email Failed After Update: '+e.getMessage();
                            }
                        }
                    }
                    strAuditText += ' trigger.isupdate > ';
                    
                    Order__c objOldOrder = null;
                    if (mapOldOrders.containsKey(objNewOrders.Id)==true)
                        objOldOrder = mapOldOrders.get(objNewOrders.Id);
                    if (objOldOrder != null)
                    {
                        //ACTION:Assign renewals team for un-inoviced order 
                        if(objNewOrders.Payment_Status__c== 'To be Invoiced' && (objOldOrder.Renewal_Team__c == null && objNewOrders.Renewal_Team__c != null))
                        {
                            objNewOrders.addError('Renewal team can be assigned to orders which invoiced');
                        }
                        //ACTION:Send Invoices
                        if (objOldOrder.Is_Sent_Invoice__c == false && objNewOrders.Is_Sent_Invoice__c==true)
                        {
                            strAuditText += 'Create Invoice>';                            
                            lstOrderIdsToGenerateInvoice.add(objNewOrders.Id);
                        }
                    }
                    
                }
                if (lstOrderIdsToGenerateInvoice!=null && lstOrderIdsToGenerateInvoice.size()>0)
                {
                    strAuditText += ' Invoices to be generated for the order:' + lstOrderIdsToGenerateInvoice + ' > ';
                    BatchQueueHelper.CreateBatchQueueForInvoiceGeneration(lstOrderIdsToGenerateInvoice);
                }
                else
                	strAuditText += ' No invoices to be generated > ';
                if(Trigger.isInsert)
                {
                    strAuditText += ' trigger.isinsert > ';
                    List<Id> lstOrderIdsCreated =  new List<Id>();
                    Map<Id, Id> mapOrderIds =  new Map<Id, Id>();
                    Map<Id, Id> mapClientIds =  new Map<Id, Id>();
                    for (Order__c objOrder : Trigger.New )
                    {
                        if (mapOrderIds.containsKey(objOrder.Id)==false)
                            mapOrderIds.put(objOrder.Id, objOrder.Id);
                        if (mapClientIds.containsKey(objOrder.Client__r.Id)==false)
                            mapClientIds.put(objOrder.Client__r.Id, objOrder.Client__r.Id);
                        
                    }
                    if (lstOrderIdsCreated != null && lstOrderIdsCreated.size()>0)
                    {
                        strAuditText += ' New orders received:' + lstOrderIdsCreated + ' > ';
                        BatchQueueHelper.CreateBatchQueueForOrderPlaced(mapClientIds.keySet());
                        BatchQueueHelper.CreateBatchQueueForOrderReceived(mapOrderIds.keySet());
                        //EmailController.SendToADU_WhenNewOrderReceived(lstOrderIdsCreated);
                        //EmailController.SendToClient_WhenNewOrderReceived(lstOrderIdsCreated);
                    }
                    else
                    {
                        strAuditText += ' No new orders received > ';
                    }
                }
            }
        }
    }
    catch(Exception exp)
    {
        strAuditText += ' ERROR:' + exp.getMessage() + '|' + exp.getStacktraceString() + ' > ';
    }
    finally
    {
        AuditTrailHelper.UpdateAudit('trgOrder', strAuditText, 'None');
    }
}   