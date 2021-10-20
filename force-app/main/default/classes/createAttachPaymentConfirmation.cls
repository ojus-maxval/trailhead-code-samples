public with sharing class createAttachPaymentConfirmation {
    private ApexPages.StandardSetController standardController;
    Public list<String> selectedids{Set;Get;}
    Public String listviewURL{Set;Get;}
    Public Boolean openCmp{Set;Get;}
    Public createAttachPaymentConfirmation(ApexPages.StandardSetController controller) {
        this.standardController = controller;
        /* MARS-753 When user completes Attach Payment Confirmation, System should show the Assets screens with Make Payment Filter.
        Added by Saranyaa */
        //Get the return url if it's in Lightning view
        listviewURL = ApexPages.currentPage().getParameters().get('vfRetURLInSFX');
        If(listviewURL == null || listviewURL == '')
        {
            //Get the return url if it's in classic view
            listviewURL = ApexPages.currentPage().getParameters().get('retURL');
            If(listviewURL == null || listviewURL == ''){
                listviewURL = '/lightning/o/Order_Item__c/list?filterName=All';
            }
        }
        system.debug('listviewURL :'+listviewURL); 
        openCmp = True;
        selectedids = New List < String > ();
        list<Order_Item__c> SelectedrederItems = new list<Order_Item__c>();
        /* MARS-795 Error Message should be Added when User clicks on Attach Payment Confirmation in other List view
        Added by Saranyaa */
        if(listviewURL.contains('00B5e00000AYumVEAT'))//00B5e00000AYumVEAT - id of MakePayments listview; Add order ids only when assets are from Make Payments listview
        {
            SelectedrederItems = (Order_Item__c[])controller.getSelected();
            if(SelectedrederItems!=null && SelectedrederItems.size()>0)
            {            
                for(Order_Item__c orderitem : SelectedrederItems)
                {
                  selectedids.add(orderitem.Id);
                }
            }
        }
    }
    @auraenabled
    public static myDataWrapper getDetails(string sids)
    {
        sids = sids.replaceAll( '\\s+', '');
        system.debug('before: '+sids);
        sids = sids.substring( 1, sids.length()-1);
        system.debug('after: '+sids);
        List<string> ids = NEW List<string>();
        list<myPickListWrapper> pOptions = new list<myPickListWrapper>();
        list<myPickListWrapper> pmOptions = new list<myPickListWrapper>();
        list<myPickListWrapper> bOptions = new list<myPickListWrapper>();
        list<myPickListWrapper> ccOptions = new list<myPickListWrapper>();
        myPickListWrapper nonePickValue= NEW myPickListWrapper(); 
        nonePickValue.label = '--Select--';
        nonePickValue.value = '';
        pOptions.add(nonePickValue);
        pmOptions.add(nonePickValue);            
        bOptions.add(nonePickValue);
        ccOptions.add(nonePickValue);
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
            
        myPayConf pc = NEW myPayConf();
        pc.Name='';
        pc.AmtForSelected=0;
        pc.payCurrency='';
        pc.AmtPaid=0;
        pc.exgRate=0;
        pc.payType='';
        pc.BAcc='';
        pc.CCAcc='';
        pc.WireBankFee=0;
        pc.pdate = date.today();
        pc.pcMemo='';
        myDataWrapper mydata = NEW myDataWrapper();
        Decimal a = 0;
        mydata.AssetIDs = ids;
        if(sids != '')
        {
            list<Order_Item__c> paymentRecievedItems = NEW list<Order_Item__c>();
            list<Order_Item__c> paymentNotRecievedItems = NEW list<Order_Item__c>();
            boolean errorInData = false;
            system.debug('>>Condition');
            set<string> Jurisdictions= NEW set<string>();
            /*MARS-775 Proper Error Message should be shown
            * Added by Saranyaa */
            string orderItemNamewithError = '';
            string paymentConfirmationName = '';
            boolean ispaymentConfirmationAvailable = false;
            boolean isMultipleErrors = false;
            for(Order_Item__c oi : [SELECT id,Name,Fee__c,Jurisdiction__c,Payment__c,Payment_Approval_Status__c,Renewal_Status__c,Payment_Status__c,Payment_Confirmation__c FROM Order_Item__c WHERE ID IN: ids])
            {
                a = a + oi.Fee__c;
                Jurisdictions.add(oi.Jurisdiction__c);    
                if(oi.Payment__c == null && oi.Payment_Approval_Status__c != 'Approved')
                {
                	system.debug('Payment Confirmation can be attached only for assets after Recording the Payment. Payment__c - ' + oi.Renewal_Status__c + ' Payment_Approval_Status__c' + oi.Payment_Approval_Status__c);
                    errorInData = true;
                    mydata.errorMessage = 'Payment Confirmation can be attached only for assets after Recording the Payment.';
                }
                else if(oi.Renewal_Status__c == 'Asset Renewed' || oi.Payment_Status__c == 'PTO/Agent Payments Completed')
                {
                   system.debug('Payment Confirmation cannot be attached for assets that are Renewed. Renewal status - ' + oi.Renewal_Status__c);
                   errorInData = true;
                   mydata.errorMessage = 'Payment Confirmation cannot be attached for assets that are Renewed';
                }
                else if(oi.Payment_Confirmation__c != null){
                   	system.debug('Payment Confirmation already attached.');
                    errorInData = true;
                    orderItemNamewithError = oi.Name;
                    List<Payment_Confirmation__c> pc1 = [SELECT Name FROM Payment_Confirmation__c WHERE Id =: oi.Payment_Confirmation__c];
                    if(pc1.size() > 0){
                        system.debug('RefNo. - ' + pc1[0].Name);
                        paymentConfirmationName = pc1[0].Name;
                        if(ispaymentConfirmationAvailable)
                            isMultipleErrors = true;
                        ispaymentConfirmationAvailable = true;
                    }
                }
            }
            if(errorInData == false)
            {
                system.debug('Selected assets have no error');
                pc.AmtForSelected = a;
            }   
            else if(Jurisdictions.size() > 1)
            {
                system.debug('Assets with different jurisdictions are selected');
                mydata.errorInData = true;
                mydata.errorMessage = 'Please select single jurisdiction assets';
            }            
            else if(ispaymentConfirmationAvailable == true)
            {
                if(isMultipleErrors == true)
                {
                    mydata.errorInData = true;
                    mydata.errorMessage = 'The Assets already have Payment Confirmation Attachment';
                }
                else{                         
                    mydata.errorInData = true;
                    mydata.errorMessage = 'The Asset - '+ orderItemNamewithError +' already has Payment Confirmation Attachment - ' + paymentConfirmationName;
                }
            }else
            {
            	mydata.errorInData = true;
            }
            Schema.DescribeFieldResult fieldResultPC = Payment_Confirmation__c.Payment_Currency__c.getDescribe();
            List<Schema.PicklistEntry> pValuesPC = fieldResultPC.getPicklistValues();
            for (Schema.PicklistEntry p: pValuesPC) {
                myPickListWrapper op = NEW myPickListWrapper();
                op.label = p.getLabel();
                op.value = p.getValue();
                pOptions.add(op);
            }
            Schema.DescribeFieldResult fieldResultPM = Payment_Confirmation__c.Payment_Method__c.getDescribe();
            List<Schema.PicklistEntry> pValuesPM = fieldResultPM.getPicklistValues();
            for (Schema.PicklistEntry p: pValuesPM) {
                myPickListWrapper op = NEW myPickListWrapper();
                op.label = p.getLabel();
                op.value = p.getValue();
                pmOptions.add(op);
            }
            mydata.PaymentCurrencyPickList = pOptions;
            mydata.PaymentMethodPickList = pmOptions;
            List<QB_Account__c> lstQBA = [Select id,Name,QB_Account_Id__c,Account_Type__c FROM QB_Account__c WHERE Account_Type__c IN('Bank','Credit Card')];
            if(lstQBA.size()>0)
            {
                for(QB_Account__c qba : lstQBA)
                {
                    myPickListWrapper op = NEW myPickListWrapper();
                    op.label = qba.Name;
                    op.value = qba.Name+'||'+qba.QB_Account_Id__c;
                    if(qba.Account_Type__c == 'Bank')
                    {
                        bOptions.add(op);
                    }
                    if(qba.Account_Type__c == 'Credit Card')
                    {
                        ccOptions.add(op);
                    }                
                }
                mydata.BankAccsPickList = bOptions;
                mydata.CCAccsPickList = ccOptions;
            }
            else
            {
                //mydata.errorInData = true;
                //mydata.errorMessage = 'There are no Bank/Credit Card QB Accounts';
            }
            mydata.payAtt = pc;            
        }else{
            mydata.errorInData = true;
            mydata.errorMessage = 'Please select atleast one asset from the listview - Make Payments';        
        }
        system.debug(mydata);
        return mydata;
    }
    @auraenabled
    public static string createPaymentConfirmation (List<ID> OIIds, myPayConf pc)
    {
        system.debug('OIIds :'+OIIds+' >> pc : '+pc);
        string returnString = 'Success';
        try
        {
            Payment_Confirmation__c recPC = NEW Payment_Confirmation__c();
            recPC.Name = pc.Name;
            recPC.Amount_for_selected_assets__c = pc.AmtForSelected;
            system.debug('Amount_for_selected_assets__c: '+recPC.Amount_for_selected_assets__c);
            recPC.Payment_Currency__c = pc.payCurrency;
            
            recPC.Payment_Amount__c = pc.AmtPaid;
            recPC.Payment_Method__c = pc.payType;
            system.debug(pc.BAcc +'>>'+pc.CCAcc);
            //recPC.Name = pc.BAcc;
            //recPC.Name = pc.CCAcc;
            recPC.Wire_Bank_Fee__c = pc.WireBankFee;
            recPC.Payment_Date__c = pc.pdate;
            recPC.Description__c = pc.pcMemo;
            insert recPC;
            List<Order_Item__c> listOIs = NEW List<Order_Item__c>();
            for(ID assetId : OIIds)
            {
                Order_Item__c oi =NEW Order_Item__c();
                oi.id = assetId;
                oi.Payment_Confirmation__c = recPC.id;
                oi.Paid_On__c = recPC.Payment_Date__c;
                oi.Is_PTO_Fee_Paid__c = true;	
                listOIs.add(oi);
                system.debug(oi);
            }
            if(listOIs.size() > 0) 
            {
               system.debug('listsize : '+listOIs.size());
               update listOIs; 
            }
                
            List<ptoValidationReqWrapper> wrplst = NEW List<ptoValidationReqWrapper>();
            List<Order_Item__c> listOI = [Select id,Name,Order__r.Client__c,PTO_Validation_Request_ID__c,Paid_Status__c,Surcharge__c,
                                          Payment_Status__c,Order_Number__c,Client__c,Jurisdiction__c,Billing_Currency__c,Entity_Type_Name__c,
                                          Fee_Amount_When_Pay__c,Application_No__c,Patent_No__c,MV_API_Ref_Id__c,
                                          Invoice_Type_Name_Value__c,Invoice__c,Invoice__r.Name,Term_Name__c,Fee__c,Invoice__r.Invoice_No__c,Order__r.Name,Payment_API_Message__c 
                                          ,Payment_Confirmation__c,Payment_Confirmation__r.Payment_API_Message__c,Payment_Confirmation__r.Payment_Amount__c,Payment_Confirmation__r.Payment_Method__c,Payment_Confirmation__r.Description__c,Payment_Confirmation__r.Exchange_Rate__c,Payment_Confirmation__r.Wire_Bank_Fee__c
                                          from Order_Item__c WHERE ID IN: OIIds];
            ptoValidationReqWrapper wrp = NEW ptoValidationReqWrapper();
            wrp.countryCode = listOI[0].Jurisdiction__c;
            wrp.countryAssets = listOI;
            wrplst.add(wrp);
            if(!test.isRunningTest())
            {
                system.debug('pc.BAcc :'+pc.BAcc+' >> pc.CCAcc : '+pc.CCAcc );
                if(pc.BAcc != null && pc.BAcc!='')
                {
                    batchRenewalBillCreate cls = NEW batchRenewalBillCreate(wrplst, pc.BAcc);
                    database.executeBatch(cls,1);
                }
                if(pc.CCAcc != null && pc.CCAcc!='')
                {
                    batchRenewalBillCreate cls = NEW batchRenewalBillCreate(wrplst, pc.CCAcc);
                    database.executeBatch(cls,1);
                }
            }
            returnString = returnString+'-'+recPC.Id;
            return returnString;
        }
        catch(exception e)
        {
            returnString = 'Error : '+ e.getMessage() +' Line: '+e.getLineNumber()+' Cause: '+e.getCause();
            return returnString;
        }
    }
    public class myDataWrapper
    {
        @auraenabled
        public boolean errorInData{set;get;}
        @auraenabled
        public string errorMessage{set;get;}
        @auraenabled
        public List<myPickListWrapper> PaymentCurrencyPickList{set;get;}
        @auraenabled
        public List<myPickListWrapper> PaymentMethodPickList{set;get;}
        @auraenabled
        public List<myPickListWrapper> BankAccsPickList{set;get;}
        @auraenabled
        public List<myPickListWrapper> CCAccsPickList{set;get;}
        @auraenabled
        public List<string> AssetIDs{set;get;}
        @auraenabled
        public myPayConf payAtt{set;get;}
    }
    public class myPickListWrapper
    {
        @auraenabled
        public string label{set;get;}
        @auraenabled
        public string value{set;get;}
    }
    public class myPayConf
    {
        @auraenabled
        public string Name{set;get;}
        @auraenabled
        public Decimal AmtForSelected{set;get;}
        @auraenabled
        public string payCurrency{set;get;}
        @auraenabled
        public Decimal AmtPaid{set;get;}
        @auraenabled
        public Decimal exgRate{set;get;}
        @auraenabled
        public string payType{set;get;}
        @auraenabled
        public string BAcc{set;get;}
        @auraenabled
        public string CCAcc{set;get;}
        @auraenabled
        public Decimal WireBankFee{set;get;}
        @auraenabled
        public date pdate{set;get;}
        @auraenabled
        public string pcMemo{set;get;}
    }
}