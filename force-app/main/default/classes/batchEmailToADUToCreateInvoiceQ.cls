public class batchEmailToADUToCreateInvoiceQ implements Database.AllowsCallouts,Database.Batchable<sObject>, Database.Stateful{
    //public OrgWideEmailAddress[] owea{set;get;}
    public date quarterstartDate {set;get;}
    public date quarterEndDate {set;get;}
    public date thisMonthStartDate {set;get;}
    public date thisMonthEndDate {set;get;}
    public datetime yestDayTime {set;get;}
    public List<Profile> pr {set;get;}
    public boolean sendMailtoClient {set;get;}
    public string query {set;get;}
    public List<User> aduusers{set;get;}
    Public map<string,string> ClientHisItems {set;get;}
    Public map<string,string> ClientidName {set;get;}
    Public map<string,string> ClientidEmail {set;get;}
    //--------------------------
    
    public batchEmailToADUToCreateInvoiceQ()
    {
        system.debug('batchEmailToADUToCreateInvoiceQ');
        sendMailtoClient = false;
        aduusers = NEW List<User>();
        //owea = [select Id from OrgWideEmailAddress ];
        ClientHisItems = NEW map<string,string>();
        ClientidName = NEW map<string,string>();
        ClientidEmail = NEW map<string,string>();
        yestDayTime = datetime.now().addDays(-1);
        pr = [SELECT id,Name from Profile where Name='ADU' Limit 1];
        quarterstartDate =[Select StartDate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].StartDate;
        quarterEndDate = [Select EndDate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].EndDate;
        thisMonthStartDate = system.today().toStartofMonth();
        thisMonthEndDate = thisMonthStartDate.addMonths(1).toStartofMonth().addDays(-1); 
        aduusers = [SELECT id,Name,email from User Where ProfileID=: pr[0].id AND isActive=true];
        query = 'SELECT id,Name,Client_Name__c,Contact_Email_Id__c,Client_Type__c, (SELECT id,Name,Day__c FROM Window_Configurations__r WHERE Name =\'Invoicing Window - Start\') FROM Clients__c ';//WHERE Client_Type__c=\'Quarterly\'
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('batchEmailToADUToCreateInvoiceQ start');
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Clients__c> scope)
    {
        if(aduusers.size()>0)
        {
            system.debug('batchEmailToADUToCreateInvoiceQ execute');
            //List<Clients__c> lst = scope;
            string orgURL = string.valueOf(URL.getSalesforceBaseUrl().toExternalForm());
            for(Clients__c ci : scope)
            {
                List<Window_Configuration__c> wcs = ci.Window_Configurations__r;
                system.debug(wcs);
                if(wcs.size() > 0 && ci.Client_Type__c!=null)
                {
                    //Date closeDate = [Select EndDate From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER].EndDate;
                    Date InvoceWindowStartDate = quarterstartDate.addDays(Integer.valueOf(wcs[0].Day__c));
                    
                    Date Periodstartdate = quarterstartDate;
                    Date PeriodEndate = quarterEndDate;
                    if(ci.Client_Type__c=='Monthly')
                    {
                        InvoceWindowStartDate = thisMonthStartDate.addDays(Integer.valueOf(wcs[0].Day__c));
                        
                        Periodstartdate = thisMonthStartDate;
                        PeriodEndate = thisMonthEndDate;
                    }
                    datetime st = datetime.newInstance(Periodstartdate.year(), Periodstartdate.month(),Periodstartdate.day());
                    datetime et = datetime.newInstance(PeriodEndate.year(), PeriodEndate.month(),PeriodEndate.day());
                    if(System.today() >= InvoceWindowStartDate)
                    {                        
                        System.debug('Dt :'+st+' Client ID'+ci.id);
                        List<Order__c> orders =[SELECT Name FROM Order__c WHERE Client__c =: ci.id AND Payment_Status__c='To be Invoiced' AND Order_Date__c >= : st AND Order_Date__c <= : et];//
                        for(Order__c ord : orders)
                        {
                            string ClientId = ci.id;
                            String listOIs = ClientHisItems.get(ClientId); 
                            if(listOIs == null)
                            {
                                listOIs = '<a href='+orgURL+'/'+ord.id+'>'+ord.Name+'</a>';
                                ClientHisItems.put(ClientId,listOIs);
                            }
                            else
                            {
                                listOIs += ', <a href='+orgURL+'/'+ord.id+'>'+ord.Name+'</a>';
                                ClientHisItems.put(ClientId,listOIs);
                            }
                            ClientidName.put(ClientId,ci.Client_Name__c+'('+ci.Client_Type__c+')');
                            //ClientidEmail.put(ClientId,ord.Contact_Email_Id__c);
                        }
                    }
                    /**/
                }
            }
            if(ClientHisItems.size() > 0)
                sendMailtoClient = true;
        }
    } 
    
    public void finish(Database.BatchableContext BC)
    {
        system.debug('batchEmailToADUToCreateInvoiceQ Finish');
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        String todayDate = Datetime.now().format('yyyy-MM-dd');
        if(sendMailtoClient && ClientHisItems.size()>0)
        {
            
            List<EmailTemplate> emailTemplate = [select Id,Name, Subject, HtmlValue, Body from EmailTemplate where  Name = 'Notify the ADU to generate invoice' Limit 1];
            if(emailTemplate.size()>0)
            {
                for(User usr : aduusers)
                {
                    string mailTableStart = '<table border="1"><tr><th>Client(s)</th><th>Records</th></tr>';
                    string mailTableRows='';
                    string mailTableEnd='</table>';                    
                    for(string clientid : ClientHisItems.keyset())
                    {
                        mailTableRows+='<tr><td>'+ClientidName.get(clientid)+'</td><td>'+ClientHisItems.get(clientid)+'</td></tr>';
                    }
                    List<String> toAddresses = new List<String>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    toAddresses.add(usr.email);
                    //toAddresses.add('harsha@maxval.com');
                    mail.setToAddresses(toAddresses);
                    String subject= emailTemplate[0].Subject;
                    subject= subject.replace('{day}', ' -'+todayDate);
                    String htmlBody = emailTemplate[0].HtmlValue;
                    htmlBody = htmlBody.replace('{ADU}', usr.Name);
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