public class batchEmailToClientOnPaidToPTO implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful{
    //public OrgWideEmailAddress[] owea{set;get;}
    public datetime yestDayTime{set;get;}
    public boolean sendMailtoClient{set;get;}
    public string query{set;get;}
    Public map<string,string> ClientHisItems {set;get;}
    Public map<string,string> ClientidName {set;get;}
    Public map<string,string> ClientidEmail {set;get;}
    //--------------------------
    
    public batchEmailToClientOnPaidToPTO()
    {   
        system.debug('batchEmailToClientOnPaidToPTO');
        sendMailtoClient = false;
        //owea = [select Id from OrgWideEmailAddress ];
        ClientHisItems = NEW map<string,string>();
        ClientidName = NEW map<string,string>();
        ClientidEmail = NEW map<string,string>();
        yestDayTime = datetime.now().addDays(-1);
        query = 'SELECT id,Name,Client__c,Order__r.Client__c,Order__c,Order__r.Client__r.Contact_Email_Id__c,Application_No__c,Patent_No__c,PTO_fee_paid_status_updated_on__c FROM Order_Item__c where PTO_fee_paid_status_updated_on__c >=: yestDayTime';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('batchEmailToClientOnPaidToPTO start');
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Order_Item__c> scope)
    {
        system.debug('batchEmailToClientOnPaidToPTO execute');
        List<Order_Item__c> lst = scope;
        string orgURL = string.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
        for(Order_Item__c oi : scope)
        {
            string CientId = oi.Order__r.Client__c;
            String listOIs = ClientHisItems.get(CientId); 
            if(listOIs == null)
            {
                listOIs = oi.Application_No__c;
                ClientHisItems.put(CientId,listOIs);
            }
            else
            {
                listOIs += ', '+oi.Application_No__c;
                ClientHisItems.put(CientId,listOIs);
            }
            ClientidName.put(CientId,oi.Client__c);
            ClientidEmail.put(CientId,oi.Order__r.Client__r.Contact_Email_Id__c);
        }
        if(ClientHisItems.size() > 0)
            sendMailtoClient = true;
    } 
    
    public void finish(Database.BatchableContext BC)
    {
        system.debug('batchEmailToClientOnPaidToPTO Finish');
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        String todayDate = Datetime.now().format('yyyy-MM-dd');
        if(sendMailtoClient && ClientHisItems.size()>0)
        {
            
            List<EmailTemplate> emailTemplate = [select Id,Name, Subject, HtmlValue, Body from EmailTemplate where  Name = 'Notify the Client that PTO fee paid' Limit 1];
            if(emailTemplate.size()>0)
            {
                for(string clientid : ClientHisItems.keyset())
                {
                    string mailTableStart = '<table border="1"><tr><th>Records</th></tr>';
                    string mailTableRows='';
                    string mailTableEnd='</table>';
                    string applicatioNos = ClientHisItems.get(clientid);
                    mailTableRows='<tr><td>'+applicatioNos+'</td></tr>';

                    List<String> toAddresses = new List<String>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    toAddresses.add(ClientidEmail.get(clientid));
                    //toAddresses.add('harsha@maxval.com');
                    mail.setToAddresses(toAddresses);
                    String subject= emailTemplate[0].Subject;
                    subject= subject.replace('{day}', ' -'+todayDate);
                    String htmlBody = emailTemplate[0].HtmlValue;
                    htmlBody = htmlBody.replace('{Client}', ClientidName.get(clientid));
                    htmlBody = htmlBody.replace('mailTableStart', mailTableStart);
                    htmlBody = htmlBody.replace('mailTableRows', mailTableRows);
                    htmlBody = htmlBody.replace('mailTableEnd', mailTableEnd);
                    htmlBody =htmlBody.replace('<![CDATA[','');
                    htmlBody = htmlBody.replace(']]>','</div>'); 
                    mail.setSubject(subject);
                    mail.setHtmlBody(htmlBody);
                    /*if ( owea.size() > 0 ) {
                        mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }*/
                    allMails.add(mail);
                }
                system.debug(allMails.size());
                if(!test.isRunningTest() && allMails.size()>0)
                    Messaging.sendEmail(allMails);
            } 
        }
    }
}