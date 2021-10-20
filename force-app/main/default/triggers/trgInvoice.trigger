trigger trgInvoice on Invoice__c (after insert,before insert, after update)
{
    //EVENT: Before
    if (Trigger.isBefore)
    {
        if (Trigger.isinsert)
        {
            set<string> clientids = NEW set<string>();
            set<string> Orderids = NEW set<string>();
            Map<string,string> mapClientMail = NEW Map<string,string>();
            for(Invoice__c objNewOrder : Trigger.New)
            {
                If(objNewOrder.Order__c!=null){
                    Orderids.add(objNewOrder.Order__c);
                }
            }
            
            if(Orderids.size()>0)
            {
                for(Order__c ots :[SELECT id,Client__c FROM Order__c  where id IN: new List<string>(Orderids) ])
                {
                    clientids .add(ots.Client__c );
                }
            }
            
            if(clientids.size()>0)
            {
                for(clients__c cts :[SELECT id,Contact_Email_Id__c FROM clients__c where id IN: new List<string>(clientids) ])
                {
                    mapClientMail.put(cts.id, cts.Contact_Email_Id__c);
                }
            }
            for (Invoice__c objNewOrder : Trigger.New)
            {    
                if(clientids!=null){
                    for(id clientid: clientids ){
                        If(objNewOrder.Order__c !=null && mapClientMail.containskey(clientid)){
                            objNewOrder.Client_EmailId__c=mapClientMail.get(clientid);       
                        }
                    }
                }
            }
        } 
    }
    string strAuditText = '>';
    
    if(trigger.isAfter)
    {
        if(trigger.isUpdate)
        {
            boolean callInvoiceInfoBatch = false;
            for(Invoice__c invoice : trigger.new)
            {
                Invoice__c oldData =trigger.oldmap.get(invoice.id);
                if(invoice.API_Status__c=='Completed' && oldData.API_Status__c=='Requested')
                {
                    callInvoiceInfoBatch =true;
                }             
            }
            if(callInvoiceInfoBatch)
            {
                batchRenewalInvoiceInfo updateInvoiceReq = NEW batchRenewalInvoiceInfo();
                database.executeBatch(updateInvoiceReq,1);
            }
        }
    }
    
    
    if(trigger.isAfter && trigger.isinsert){
        
        string inoicedetails='';
        for(Invoice__c invoice : trigger.new)
        {
            
            inoicedetails+=' Name   : '    +invoice.name+ '<br/>';
            // inoicedetails+= '\r\n';//+'Invoice Status'+invoice.Invoice_Status__c+'Invoice Amount'+invoice.Invoice_Amount__c+'Invoice Currency'+invoice.Invoice_Currency__c;
            inoicedetails+='Invoice Status  :   '+invoice.Invoice_Status__c+'<br/>';
            inoicedetails+='Invoice Amount  :  '+invoice.Invoice_Amount__c+'<br/>';
            inoicedetails+='Invoice Currency'+invoice.Invoice_Currency__c+'<br/>';
            
        } 
        system.debug('inoicedetails'+inoicedetails);
        IF(inoicedetails!=''){
            List<Invoice_Type_Configuration__c> ObjInvoicetypeconfig=[select id,name,Contact_Persons__c from Invoice_Type_Configuration__c limit 1 ];
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            list<string> toadd=ObjInvoicetypeconfig[0].Contact_Persons__c.split(',');
            message.toAddresses = toadd;
            message.optOutPolicy = 'FILTER';
            message.subject = 'Invoice Details';
            String emailBody = null;
            // emailBody  = InvoiceDetails;
            message.setHtmlBody(inoicedetails);
            //message.plainTextBody = 'This is the message body.';
            //Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            try
            {
                //Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            }
            catch(exception e)
            {
                AuditTrailHelper.UpdateAudit('trgInvoice', e.getMessage(), 'None');
            }
        }
        
    }
    
}