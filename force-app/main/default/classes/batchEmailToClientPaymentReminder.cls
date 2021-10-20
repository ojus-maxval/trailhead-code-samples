public class batchEmailToClientPaymentReminder implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful{
    //public OrgWideEmailAddress[] owea{set;get;}
    public datetime yestDayTime{set;get;}
    public boolean sendMailtoClient{set;get;}
    public string query{set;get;}
    Public map<string,List<objWrapper>> ClientHisItems {set;get;}
    Public map<string,string> ClientidName {set;get;}
    Public map<string,string> ClientidEmail {set;get;}
    //--------------------------
    
    public batchEmailToClientPaymentReminder()
    {   
        system.debug('batchEmailToClientOnPaidToPTO');
        sendMailtoClient = false;
        //owea = [select Id from OrgWideEmailAddress ];
        ClientHisItems = NEW map<string,List<objWrapper>>();
        ClientidName = NEW map<string,string>();
        ClientidEmail = NEW map<string,string>();
        yestDayTime = datetime.now().addDays(-1);
        query = 'SELECT id,Client_Name__c,Client_Type__c,Contact_Email_Id__c FROM Clients__c where Status__c = \'Active\' AND Contact_Email_Id__c != null';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('batchEmailToClientOnPaidToPTO start');
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Clients__c> scope)
    {
        system.debug('batchEmailToClientOnPaidToPTO execute');
        List<Clients__c> clients = scope;
        List<Order_Item__c> orderitemsForNextCycle;
        if(clients[0].Client_Type__c == 'Quarterly')
        {
            orderitemsForNextCycle = [SELECT id,Name,Application_No__c,Term_Name__c FROM Order_Item__c WHERE Order__r.Client__c = : clients[0].id AND Due_Date__c = NEXT_QUARTER AND Payment__c=null AND Invoice__c!=null];
        }
        if(clients[0].Client_Type__c == 'Monthly')
        {
            orderitemsForNextCycle = [SELECT id,Name,Application_No__c,Term_Name__c FROM Order_Item__c WHERE Order__r.Client__c = : clients[0].id AND Due_Date__c = NEXT_MONTH AND Payment__c=null AND Invoice__c!=null];
        }
        if(orderitemsForNextCycle !=null && orderitemsForNextCycle.size()>0)
        {
            
            for(Order_Item__c oi : orderitemsForNextCycle)
            {
                System.debug('>>'+oi); 
                List<objWrapper> listOIs = ClientHisItems.get(clients[0].id); 
                objWrapper obj = NEW objWrapper();
                if(listOIs == null)
                {
                    obj.assetName = oi.Name;
                    obj.applicationNo = oi.Application_No__c;
                    obj.termName = oi.Term_Name__c;
                    ClientHisItems.put(clients[0].id,new List<objWrapper>{obj});
                }
                else
                {
                    obj.assetName = oi.Name;
                    obj.applicationNo = oi.Application_No__c;
                    obj.termName = oi.Term_Name__c;
                    listOIs.add(obj);
                }                
            }
            ClientidName.put(clients[0].id,clients[0].Client_Name__c);
            ClientidEmail.put(clients[0].id,clients[0].Contact_Email_Id__c);
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
            
            List<EmailTemplate> emailTemplate = [select Id,Name, Subject, HtmlValue, Body from EmailTemplate where  Name = 'Notify the Client Pay The Invoice Amount' Limit 1];
            if(emailTemplate.size()>0)
            {
                for(string clientid : ClientHisItems.keyset())
                {
                    string mailTableStart = '<table border="1"><tr><th>MaRS Renewal Id</th><th>Application No.</th><th>Term Name</th></tr>';
                    string mailTableRows='';
                    string mailTableEnd='</table>';
                    List<objWrapper> applicatioNos = ClientHisItems.get(clientid);
                    for(objWrapper obj : applicatioNos)
                    {
                        //mailTableRows += '<tr><td>'+applicatioNos+'</td></tr>';
                        mailTableRows += '<tr><td>'+obj.assetName+'</td><td>'+obj.applicationNo+'</td><td>'+obj.termName+'</td></tr>';
                    }
                    List<String> toAddresses = new List<String>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    toAddresses.add(ClientidEmail.get(clientid));
                    toAddresses.add('harsha@maxval.com');
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
    public class objWrapper
    {
        public string assetName{set;get;}
        public string applicationNo{set;get;}
        public string termName{set;get;}
    }
}