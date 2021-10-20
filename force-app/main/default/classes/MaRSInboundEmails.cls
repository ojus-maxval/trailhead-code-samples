global class MaRSInboundEmails implements Messaging.InboundEmailHandler 
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {    
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        try
        {
        system.debug('Inbound Email Start: Subject' + email.subject);
        if(email.subject != null && email.subject.contains('-'))
        {
            list<EmailMessage> lstmsg = new list<EmailMessage>();
            string allstring = '';
            list<string> lstsub = new list<string>();
            list<string> lstTerms = new list<string>();
            String EmailSub = email.subject;
            EmailSub = EmailSub.replaceAll( '\\s+', '');
            MAP<string,string> mapAppTerm = NEW MAP<string,string>();
            List<string> listAppNo = NEW List<string>(); 
            Set<string> AppNowithTerm= new Set<string>();
            if(email.subject.contains(','))
            {
                List<String> A= EmailSub.split(',');
                AppNowithTerm.addAll(A);
            }
            else
            {
                AppNowithTerm.add(email.subject);
            }
            for(string str : AppNowithTerm)
            {
                List<String> lstStr = str.split('-');
                lstsub.add(lstStr[0]);
                lstTerms.add(lstStr[1]);
                mapAppTerm.put(lstStr[0],lstStr[1]);
            }            
            string usernam =' ';
            List<string> lststrUser = new List<string>(); 
            boolean check = True;
            list<User> u =[Select Name from user where Email =: email.fromAddress];
            for(user s: u){                    
                lststrUser.add(s.Name);
            }
            system.debug('User'+u);
            if(u != null)
            {
                for(String s: lststrUser){
                    if(check==False){
                        usernam +=',';
                    }
                    usernam += s;
                    check = false;                    
                }
            }
            else{
                usernam = Null;
            }
            system.debug('Sender Name: ' + usernam);
            string AssetQuerySelect;
            string wherefind='';
            if(lstsub.size()>0)
            {                    
                //wherefind = AssetMail.Subject_Contains_Field__c+ ' IN (\'' + String.join(lstsub,'\',\'')+'\')';
                wherefind += ' Application_No__c IN (\''+String.join(lstsub,'\',\'')+'\')';
                system.debug('wherefind>>>>>'+wherefind);                    
            }
            /*if(lstTerms.size()>0 && wherefind!='')
            {
                wherefind += ' AND Term_Name__c IN (\''+String.join(lstTerms,'\',\'')+'\')';
            }*/
            
           // string query ='Select id'+AssetQuerySelect+' from Order_Item__c where '+wherefind;
            string query ='Select id,Application_No__c,Term_Name__c from Order_Item__c where '+wherefind;
            List<Order_Item__c> OIlist =Database.query(query);
            if(OIlist.size()>0)
            {
                for(Order_Item__c oi :OIlist)
                {
                    string term = mapAppTerm.get(oi.Application_No__c);
                    if(oi.Term_Name__c.contains(term))
                    {
                        if(email.ccAddresses != null)
                        {
                            allstring = string.join(email.ccAddresses,',');                        
                        }
                        
                        EmailMessage createEmail = new EmailMessage(
                                                                Subject = email.Subject 
                                                                ,Status = '1'
                                                                ,CcAddress = allstring
                                                                ,FromAddress = email.fromAddress
                                                                ,FromName = usernam
                                                                ,Headers = JSON.serialize( email.headers )
                                                                ,HtmlBody = email.htmlBody
                                                                ,TextBody = email.plainTextBody
                                                                ,Incoming = true
                                                                ,MessageDate = DateTime.now()
                                                                ,RelatedToId = oi.id                        
                                                            );                        
                        lstmsg.add(createEmail);
                        
                        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
                            for (integer x = 0 ; x < email.binaryAttachments.size() ; x++) {
                                Attachment attachment = new Attachment();
                                attachment.ParentId = oi.Id;
                                attachment.Name = email.binaryAttachments[x].filename;
                                attachment.Body = email.binaryAttachments[x].body;
                                insert attachment;
                            }
                        }
                    }
                }
                try{
                    insert lstmsg;
                }
                catch(exception ex){
                    system.debug('Error: '+ex.getMessage());
                }
            }            
        }
        }
        catch(exception e)
        {
            system.debug(e.getmessage());
            //AuditTrailHelper.UpdateAudit('batchPtoPaymentValidate',strAuditTrail,status);
        }
        return result;
    }
}