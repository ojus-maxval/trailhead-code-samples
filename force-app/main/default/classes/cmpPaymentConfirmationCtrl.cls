public class cmpPaymentConfirmationCtrl {
    @AuraEnabled        
    public static response getPickListValuesIntoList(string pcId){
        response res = NEW response();
        List<String> paymentmethodOptions = new List<String>();
        Schema.DescribeFieldResult fieldResult = Payment_Confirmation__c.Payment_Method__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            paymentmethodOptions.add(pickListVal.getLabel());
        }
        res.paymentmethodOptions = paymentmethodOptions;
        Payment_Confirmation__c pc = [select id,name,Payment_Amount__c, Description__c,Paid_Date__c,Payment_Method__c,WiredConfirmationId__c,WiredConfirmationUploaded__c,PaymentConfirmationId__c,PaymentConfirmationUploaded__c from Payment_Confirmation__c where id =: pcId];
        List<ID> conDOC = NEW List<ID>();
        if(pc.WiredConfirmationId__c != null)
        {
            conDOC.add(pc.WiredConfirmationId__c);
        }
        
        if(pc.PaymentConfirmationId__c !=null)
        {
            conDOC.add(pc.PaymentConfirmationId__c);
        }
        List<ContentVersion> cv = [SELECT ID,Title,FileExtension,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: conDOC];
        if(cv.size()>0)
        {
            for(ContentVersion c:cv)
            {
                if(c.ContentDocumentId == pc.WiredConfirmationId__c)
                {
                    res.wiredcv = c.id;
                    res.wiredTitle = c.Title+'.'+c.FileExtension;
                }
                if(c.ContentDocumentId == pc.PaymentConfirmationId__c)
                {
                    res.paymentcv = c.id;
                    res.paymentTitle = c.Title+'.'+c.FileExtension;
                }
            }
        }
        res.pc = pc;
        return res;
    }
    @AuraEnabled        
    public static string updateRecord(string paymentid,Payment_Confirmation__c rec, string wireconfirmationid, string paymentconfimationid)
    {
        /*boolean updaterec = false;
        system.debug('called: '+paymentid+' > '+wireconfirmationid+' > '+paymentconfimationid);
        Payment_Confirmation__c pc = NEW Payment_Confirmation__c();
        pc.id = paymentid;
        if(wireconfirmationid!=null && wireconfirmationid!='')
        {
            pc.WiredConfirmationId__c = wireconfirmationid;
            pc.WiredConfirmationUploaded__c = true;
            updaterec = true;
        }
        if(paymentconfimationid!=null && paymentconfimationid!='')
        {
            pc.PaymentConfirmationId__c = paymentconfimationid;
            pc.PaymentConfirmationUploaded__c = true;
            updaterec = true;
        }
        if(updaterec)
        {
            try
            {
                update pc;
            }
            catch(exception e)
            {
                return e.getmessage();
            }
        }*/
        update rec;   
        return 'Success';
    }
    @auraenabled
    public static string deleteFileRecord(string pcId, string fileDocId, string typeof)
    {
        ContentDocument cd = NEW ContentDocument();
        cd.id = fileDocId;
        delete cd;
        
        Payment_Confirmation__c pc = NEW Payment_Confirmation__c();
        pc.id = pcId;
        if(typeof == 'wired')
        {
            pc.WiredConfirmationId__c = null;
            pc.WiredConfirmationUploaded__c = false;
        }
        if(typeof == 'payment')
        {
            pc.PaymentConfirmationId__c = null;
            pc.PaymentConfirmationUploaded__c = false;
        }
        update pc;
        return 'Success';
    }
    public class response{
        @AuraEnabled 
        public list<string> paymentmethodOptions{set;get;}
        @AuraEnabled 
        public Payment_Confirmation__c pc{set;get;}
        @AuraEnabled 
        public string wiredcv{set;get;}
        @AuraEnabled 
        public string wiredTitle{set;get;}
        @AuraEnabled 
        public string paymentcv{set;get;}
        @AuraEnabled 
        public string paymentTitle{set;get;}
    }
}