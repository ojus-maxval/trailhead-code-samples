public with sharing class updateOrderItemsOnPayToPTO {
    private ApexPages.StandardSetController standardController;
    public list<string> selectedids{set;get;}
    public string listviewURL{set;get;}
    public boolean openCmp{set;get;}
    public updateOrderItemsOnPayToPTO(ApexPages.StandardSetController controller) {
        this.standardController = controller;
        
        listviewURl = ApexPages.currentPage().getParameters().get('retURL');
        if(listviewURl == null || listviewURl == '')
        {
            listviewURL = '/lightning/o/Order_Item__c/list?filterName=All';
        }
        openCmp = true;
        selectedids = NEW List<string>();
        list<Order_Item__c> SelectedrederItems = new list<Order_Item__c>();
        SelectedrederItems = (Order_Item__c[])controller.getSelected();
        if(SelectedrederItems!=null && SelectedrederItems.size()>0)
        {            
            for(Order_Item__c orderitem : SelectedrederItems)
            {
              selectedids.add(orderitem.Id);
            }
        }
        /*if(selectedids.size()>0)
        {
              listviewURL = '/'+selectedids[0].substring(0, 3)+'/o';
        }
        else
        {
             listviewURL = '/lightning/o/Order_Item__c/list?filterName=All';
        }*/
        /*if(selectedids.size()>0)
        {
            integer nonPayed = 0;
            integer payed = 0;
            for(Order_Item__c oi : [SELECT id,Payment_Status__c,Paid_Status__c,Renewal_Instruction__c FROM Order_Item__c WHERE ID IN: selectedids])
            {            
                if(oi.Payment_Status__c == 'Payment Received' && oi.Renewal_Instruction__c == 'Renew' && oi.Suggested_Open_Date_To_Pay__c <= date.TODAY() && oi.Suggested_Close_Date_To_Pay__c>=date.TODAY())
                {
                    payed = payed+1;
                }
                else if(oi.Payment_Status__c != 'Payment Received')
                {
                    nonPayed = nonPayed+1;
                }
            }
            if(selectedids.size() == nonPayed)
            {
                openCmp = true;
            }
            if(selectedids.size() == payed)
            {
                openCmp = false;
            }
        }*/
    }
    /*public PageReference updateRecs()
    {
        list<Order_Item__c> SelectedrederItemstoUpdate = NEW list<Order_Item__c>();
        List<string> lstOrderItemIds = NEW List<string>();
        list<Order_Item__c> SelectedrederItems = new list<Order_Item__c>();
        SelectedrederItems = (Order_Item__c[])standardController.getSelected();
        if(SelectedrederItems!=null && SelectedrederItems.size()>0)
        {            
            for(Order_Item__c orderitem : SelectedrederItems)
            {
                lstOrderItemIds.add(orderitem.Id);
            }
        }
        system.debug('>>'+SelectedrederItems);
        if(lstOrderItemIds.size()>0)
        {
            for(Order_Item__c oi : [SELECT id,Payment_Status__c,Paid_Status__c,Renewal_Instruction__c FROM Order_Item__c WHERE ID IN:lstOrderItemIds AND (Suggested_Open_Date_To_Pay__c <= TODAY AND Suggested_Close_Date_To_Pay__c>=TODAY )])
            {
                if(oi.Payment_Status__c == 'Payment Received' && oi.Renewal_Instruction__c == 'Renew')
                {
                    oi.Payment_Status__c = 'Payment Received';
                    oi.Paid_Status__c = 'Requesting to Pay PTO';
                    SelectedrederItemstoUpdate.add(oi);
                }
            }
        }
        if(SelectedrederItemstoUpdate.size()>0) 
            update SelectedrederItemstoUpdate;
        /*if(SelectedrederItems == null)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select atleast one record'));*
        return new ApexPages.Action('{!List}').invoke();
    }*/
    @auraenabled
    public static myDataWrapper getRecords(string sids)
    {
        sids = sids.replaceAll( '\\s+', '');
        system.debug('before: '+sids);
        sids = sids.substring( 1, sids.length()-1);
        system.debug('after: '+sids);
        List<string> ids = NEW List<string>();
        if(sids.contains(','))
        {
            list<string> sssids =sids.split(',');
            for(string str : sssids)
            {
                String s = str.trim();
                ids.add(s);
                system.debug(s.length());
            }
        }
        else
            ids.add(sids.trim());
        myDataWrapper mydata = NEW myDataWrapper();
        User u = [Select id,Is_ADU_Manager__c from User where ID =: UserInfo.getUserId()];
        mydata.isMngr = u.Is_ADU_Manager__c;
        system.debug('>>'+ids);
        if(ids.size()>0)
        {
            list<Order_Item__c> paymentRecievedItems = NEW list<Order_Item__c>();
            list<Order_Item__c> paymentNotRecievedItems = NEW list<Order_Item__c>();
            system.debug('>>Condition');
            for(Order_Item__c oi : [SELECT id,Payment_Status__c,Paid_Status__c,Renewal_Instruction__c,Application_No__c,Payment_Approval_Status__c FROM Order_Item__c WHERE ID IN: ids])
            {
                system.debug('>>loop'+oi.Payment_Status__c+'-'+oi.Renewal_Instruction__c);
                if(oi.Payment_Status__c == 'Payment Received' && oi.Renewal_Instruction__c == 'Renew' && (oi.Payment_Approval_Status__c == null || oi.Payment_Approval_Status__c == '') && (oi.Paid_Status__c == null || oi.Paid_Status__c == ''))
                {
                    system.debug('>>Payment Received');
                    paymentRecievedItems.add(oi);
                }
                else if(oi.Payment_Status__c == 'Payment Requested' && oi.Renewal_Instruction__c == 'Renew' && (oi.Payment_Approval_Status__c == null || oi.Payment_Approval_Status__c == '') && (oi.Paid_Status__c == null || oi.Paid_Status__c == ''))
                {
                    system.debug('>>Payment Requested');
                    paymentNotRecievedItems.add(oi);
                }
            }
            mydata.paymentRecievedItems = paymentRecievedItems;
            mydata.paymentNotRecievedItems = paymentNotRecievedItems;
        }
        system.debug(mydata);
        return mydata;
    }
    @auraenabled
    public static string updateRecords(List<Order_Item__c> ois,string actiontype, boolean mgr)
    {
        list<Order_Item__c> SelectedrederItemstoUpdate = NEW list<Order_Item__c>();
        system.debug('actiontype :'+actiontype);
        system.debug('>>'+ois);
        List<string> ids = NEW List<string>();
        string msg = 'Something went wrong';
        if(ois!= null && ois.size()>0)
        {
            if(actiontype == 'payToPTO')
            {
                for(Order_Item__c oi : ois)
                {
                    if(oi.Payment_Status__c == 'Payment Received' && oi.Renewal_Instruction__c == 'Renew')
                    {
                        oi.Payment_Status__c = 'Payment Received';
                        oi.Paid_Status__c = 'Requesting to Pay PTO';
                        SelectedrederItemstoUpdate.add(oi);
                        ids.add(oi.id);
                    }
                }
                if(ids.size()>0)
                {
                    batchPtoPaymentValidate bc = NEW batchPtoPaymentValidate(ids);
                    database.executeBatch(bc,1);
                }
            }
            if(actiontype == 'reqToMngr')
            {
                for(Order_Item__c oi : ois)
                {
                    if(oi.Payment_Status__c == 'Payment Requested' && oi.Renewal_Instruction__c == 'Renew')
                    {
                        if(!mgr)
                        	oi.Payment_Approval_Status__c = 'Requested to Approve';
                        else
                            oi.Payment_Approval_Status__c = 'Approved';
                        SelectedrederItemstoUpdate.add(oi);
                    }
                }
            }
            try{
                if(SelectedrederItemstoUpdate.size()>0) 
                    update SelectedrederItemstoUpdate;
                if(actiontype == 'payToPTO')
                {
                    if(ids.size()>0)
                    {
                        batchPtoPaymentValidate bc = NEW batchPtoPaymentValidate();
                        database.executeBatch(bc,1);
                    }
                }
                if(actiontype == 'reqToMngr' && mgr == false)
            	{
                    List<string> groupMbrMails = getEmailAddresses();
                    if(groupMbrMails.size()>0)
                    {
                        sendEmailtoMgr(groupMbrMails, ois);
                    }
                }
            }
            catch(exception e)
            {
                msg= e.getmessage();
            }
            /*if(SelectedrederItems == null)
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select atleast one record'));*/
            msg = 'Success';
        }
        
        
        return msg ;
    }
    
    public class myDataWrapper
    {
        @auraenabled
        public boolean isMngr{set;get;}
        @auraenabled
        public list<Order_Item__c> paymentRecievedItems{set;get;}
        @auraenabled
        public list<Order_Item__c> paymentNotRecievedItems{set;get;}
        @auraenabled
        public list<Order_Item__c> paymentThroughWireFrame{set;get;}
    }
    public static void sendEmailtoMgr(List<String> toaddrs,  list<Order_Item__c> objitems)
    {
        List<EmailTemplate> emailTemplate = [select Id,Name, Subject, HtmlValue, Body from EmailTemplate where  Name = 'Notify the ADU Mgr that Approve Renewals' Limit 1];
        if(emailTemplate.size()>0)
        {
            string orgURL = string.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
            string mailTableStart = '<table border="1"><tr><th>Application No.</th></tr>';
            string mailTableRows='';
            string mailTableEnd='</table>';
            string mailTableRowsItems='';
            for(Order_Item__c oi : objitems)
            {
                //mailTableRowsItems += '<li>'+oi.Application_No__c+'</li>';
                mailTableRowsItems +='<tr><td><a href='+orgURL+'/'+oi.id+'>'+oi.Application_No__c+'</a></td></tr>';
            }
            //mailTableRows+='<tr><td>'+mailTableRowsItems+'</td></tr>';
            mailTableRows+=mailTableRowsItems;
            List<String> toAddresses = new List<String>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            toAddresses = toaddrs;
            toAddresses.add('harsha@maxval.com');
            mail.setToAddresses(toAddresses);
            String subject= emailTemplate[0].Subject;
            subject= subject.replace('{day}', '');
            String htmlBody = emailTemplate[0].HtmlValue;
            htmlBody = htmlBody.replace('{ADU}', 'Managers');
            htmlBody = htmlBody.replace('mailTableStart', mailTableStart);
            htmlBody = htmlBody.replace('mailTableRows', mailTableRows);
            htmlBody = htmlBody.replace('mailTableEnd', mailTableEnd);
            htmlBody = htmlBody.replace('{from}', UserInfo.getName());
            htmlBody =htmlBody.replace('<![CDATA[','');
            htmlBody = htmlBody.replace(']]>','</div>'); 
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            /*if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
            }*/
            allMails.add(mail);
            if(!test.isRunningTest() && allMails.size()>0)
                Messaging.sendEmail(allMails);
        }
    }
    public static List<String> getEmailAddresses() {
        List<String> mailToAddresses = new List<String>();
        List<User> users = [SELECT Email FROM User WHERE Id IN (
            SELECT UserOrGroupId
            FROM GroupMember
            WHERE Group.Name = : 'ADU Managers'
        )];
        
        for(User u : users)
            mailToAddresses.add(u.email);
        
        return mailToAddresses;
    }
}