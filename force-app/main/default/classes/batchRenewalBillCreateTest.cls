@isTest 
global class batchRenewalBillCreateTest 
{
    global class MockHttpResponse implements HttpCalloutMock {
    private Integer statusCode;

    public MockHttpResponse(Integer statusCode){
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"foo":"bar"}');
        res.setStatusCode(this.statusCode);
        return res;
    }
}
    static testMethod void testMethod1() 
    {
        PTO_Credentials__c pc  = NEW PTO_Credentials__c();
        pc.Country_Code__c = 'US';
        insert pc;
        PTOFeeCode__c pfc = NEW PTOFeeCode__c();
        pfc.Jurisdiction__c = 'US';
        pfc.Term_Name__c = 'Year 3.7';
        pfc.FeeCode__c = '31';
        pfc.Surcharge_Code__c = '33';
        pfc.Entity_Type__c ='Large';
        insert pfc;
        QB_Account__c qba = NEW QB_Account__c();
        qba.Account_Type__c = 'Bank';
        qba.QB_Account_Id__c = '50';
        insert qba;
        QB_Account__c qba1 = NEW QB_Account__c();
        qba1.Account_Type__c = 'Credit Card';
        qba1.QB_Account_Id__c = '51';
        insert qba1;
        API_Credentials__c ObjAPI = new API_Credentials__c();
        ObjAPI.Password__c ='Test@1234';
        ObjAPI.Username__c ='MaxvalAPI';
        ObjAPI.Name ='Renewal Bill Create';
        ObjAPI.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI;
        
        API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name ='PTO Payment Validate';
        ObjAPI1.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI1;
        
        Batch_Queue__c objBatchQueue = new  Batch_Queue__c();
        objBatchQueue.Name = 'Order Placed Mail Alert';
        objBatchQueue.Status__c = 'To Do' ;
        insert objBatchQueue;
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        ClList.add(Cl.id);
        
        List<Id> ListOrd =new List<Id>();
        Set<Id > OrdSet =new Set<Id>();
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        OrdSet.add(Ord.id);
        ListOrd.add(Ord.id);
        
        QB_Customer__c qbc1 = NEW QB_Customer__c();
        qbc1.Name = 'QBC1';
        qbc1.QB_Customer_Id__c = '50';
        qbc1.Client__c = Ord.Client__c;
        qbc1.Active__c = true;
        insert qbc1;
        
        QB_Supplier__c qsc1 = NEW QB_Supplier__c();
        qsc1.Name = 'QBC1';
        qsc1.QB_Supplier_Id__c = '50';
        qsc1.Jurisdiction__c = 'US';
        qsc1.Active__c = true;
        insert qsc1;
        
        Payment_Confirmation__c pc1 = NEW Payment_Confirmation__c();
        
        pc1.Name = 'ABC123';
        pc1.Payment_Currency__c = 'USD';
        pc1.Payment_Amount__c = 4848;
        pc1.Amount_for_selected_Assets__c = 24;
        pc1.Payment_Method__c = 'Wire Transfer';
        insert pc1;  
        /*
        List<Payment_Confirmation__c> PaymentC = [SELECT id, Name, Payment_Currency__c, Amount_for_selected_Assets__c, Payment_Method__c, Exchange_Rate__c FROM Payment_Confirmation__c WHERE id =: pc1.id ];
        system.debug('PaymentC:' + PaymentC[0].id + ' ' + PaymentC[0].Payment_Currency__c + ' ' + PaymentC[0].Amount_for_selected_Assets__c + ' ' + PaymentC[0].Payment_Method__c + ' ' + PaymentC[0].Exchange_Rate__c + ' ');
        system.debug('PC1_id:' + pc1.id);
        system.debug('Exchange rate:' + string.ValueOf(pc1.Exchange_Rate__c));
        */
         
        List<Order_Item__c> listOI = NEW List<Order_Item__c>();
        /*
        Order_Item__c OI1 =new Order_Item__c();
        OI1.Order__c =Ord.Id;
        OI1.PTO_Validation_Status__c='Request to Validate';
        OI1.PTO_Validation_Request_ID__c='abcdefg';
        OI1.Jurisdiction__c='US';
        OI1.Application_Date__c=date.today().addyears(-4);
        OI1.Application_No__c='US0000003';
        OI1.Patent_No__c='US0000003';
        OI1.Term_Name__c='Year 3.7';
        OI1.Entity_Type_Name__c='Large';
        OI1.Surcharge__c=13350.00;
        listOI.add(OI1); 
		*/
        
        test.startTest();
       // insert listOI;
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment_Mode__c = 'Wire Transfer';
        OI.Payment_Confirmation__c = pc1.id;
        //OI.Payment_Confirmation__r.Payment_Method__c = OI.Payment_Mode__c;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001';
        OI.Patent_No__c='US0000001';
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Surcharge__c=13350.00;
        OI.Fee__c=Double.valueOf('1234');
        //Insert OI;
        listOI.add(OI);
        insert listOI;
        /*
        List<Order_Item__c> Check_Order = [SELECT id, Payment_Confirmation__r.Exchange_Rate__c FROM Order_Item__c WHERE id =: OI.id];
        system.debug(Check_Order[0].id + ' ' + Check_Order[0].Payment_Confirmation__r.Exchange_Rate__c);
        */
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        ptoValidationReqWrapper wp = new ptoValidationReqWrapper();
        wp.countryCode = 'US';
        wp.countryAssets = listOI;
        batchRenewalBillCreate cls = New batchRenewalBillCreate(new list<ptoValidationReqWrapper>{wp}, '50');
        
        database.executebatch(cls,1);
        Test.stopTest();
    }
    
    static testMethod void testMethod2() 
    {
        
        PTO_Credentials__c pc  = NEW PTO_Credentials__c();
        pc.Country_Code__c = 'US';
        insert pc;
        PTOFeeCode__c pfc = NEW PTOFeeCode__c();
        pfc.Jurisdiction__c = 'US';
        pfc.Term_Name__c = 'Year 3.7';
        pfc.FeeCode__c = '31';
        pfc.Surcharge_Code__c = '33';
        pfc.Entity_Type__c ='Large';
        insert pfc;
        QB_Account__c qba = NEW QB_Account__c();
        qba.Name = 'QBA1';
        qba.Account_Type__c = 'Bank';
        qba.QB_Account_Id__c = '50';
        qba.Jurisdiction__c = 'US';
        qba.Active__c = true;
        insert qba;
        QB_Account__c qba1 = NEW QB_Account__c();
        qba1.Name = 'QBA1';
        qba1.Account_Type__c = 'Credit Card';
        qba1.QB_Account_Id__c = '51';
        qba1.Jurisdiction__c = 'US';
        qba1.Active__c = true; 
        insert qba1;
        
        API_Credentials__c ObjAPI = new API_Credentials__c();
        ObjAPI.Password__c ='Test@1234';
        ObjAPI.Username__c ='MaxvalAPI';
        ObjAPI.Name ='Renewal Bill Create';
        ObjAPI.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI;
        
        API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name ='PTO Payment Validate';
        ObjAPI1.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI1;
        
        API_Auth_Detail__c aad = NEW API_Auth_Detail__c();
        aad.Auth_Code__c = 'AAD1';
        aad.ClientId__c	= aad.id;
        
        Batch_Queue__c objBatchQueue = new  Batch_Queue__c();
        objBatchQueue.Name = 'Order Placed Mail Alert ';
        objBatchQueue.Status__c = 'To Do' ;
        insert objBatchQueue;
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
		ClList.add(Cl.id);        
        
        List<Id> ListOrd =new List<Id>();
        Set<Id > OrdSet =new Set<Id>();
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        OrdSet.add(Ord.id);
        ListOrd.add(Ord.id);
        
        QB_Customer__c qbc1 = NEW QB_Customer__c();
        qbc1.Name = 'QBC1';
        qbc1.QB_Customer_Id__c = '50';
        qbc1.Client__c = Ord.Client__c;
        qbc1.Active__c = true;
        insert qbc1;
        
        QB_Supplier__c qsc1 = NEW QB_Supplier__c();
        qsc1.Name = 'QBC1';
        qsc1.QB_Supplier_Id__c = '50';
        qsc1.Jurisdiction__c = 'US';
        qsc1.Active__c = true;
        insert qsc1;
        
        Payment_Confirmation__c pc1 = NEW Payment_Confirmation__c();
        pc1.Payment_Amount__c = 4848;
        pc1.Amount_for_selected_Assets__c = 24;
        pc1.Payment_Method__c = 'Wire Transfer';
        insert pc1;  
        system.debug('Exchange rate:' + string.valueOf(pc1.Exchange_Rate__c));
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment_Confirmation__c = pc1.id;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001';
        OI.Patent_No__c='0000001EP';
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Fee__c=Double.valueOf('1234');
        OI.Surcharge__c=13350.00;
        Insert OI;
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        ptoValidationReqWrapper wp = new ptoValidationReqWrapper();
        wp.countryCode = 'US';
        wp.countryAssets = new List<Order_Item__c>{OI};
        batchRenewalBillCreate cls = New batchRenewalBillCreate(new list<ptoValidationReqWrapper>{wp}, '50||100||150');
        database.executebatch(cls,1);
        
        Test.stopTest();
    }
    
    static testMethod void testMethod3() 
    {
        test.startTest();
        
        batchRenewalBillCreate.ReqData rd = new batchRenewalBillCreate.ReqData();
        rd.APIHandleRef = 'MaxVal123';
        rd.PaymentType = 'Wire Transfer';
        
        batchRenewalBillCreate.objectitem oit = new batchRenewalBillCreate.objectitem();
        oit.Fee = '100';
        
        batchRenewalBillCreate.objBankFee obf = new batchRenewalBillCreate.objBankFee();
        obf.Items = null;
        rd.BankFee = obf;
        
        batchRenewalBillCreate.objBankFeeItem obfi = new batchRenewalBillCreate.objBankFeeItem();
        obfi.AccountToRef = 'String1';
        obfi.Billable = true;
        obfi.Description = 'Empty';
        obfi.Fee = '100';
        obfi.FeeClass = 'USD';
        
        batchRenewalBillCreate.responsebody rb = new batchRenewalBillCreate.responsebody();
        rb.Status = 3;
        rb.RequestID = 'ABC123';
        rb.BankFeeErrorItems = null;
        rb.BankFeeWarningItems = null;
        rb.ErrorItems = null;
        rb.Errors = null;
        rb.WarningItems = null;
        rb.Warnings = null;
        
        batchRenewalBillCreate.responseerror re = new batchRenewalBillCreate.responseerror();
        re.Code = 'Empty';
        re.Description = 'Empty';
        
        batchRenewalBillCreate.responseerroritem rei = new batchRenewalBillCreate.responseerroritem();
        rei.RowNumber = 3;
        rei.Errors = null;
        
        batchRenewalBillCreate.apiResponse aR = new batchRenewalBillCreate.apiResponse();
        aR.Message = 'Empty';
        aR.Description = 'Empty';
        
        Test.stopTest();
    }
    static testMethod void testMethod4() 
    {
        PTO_Credentials__c pc  = NEW PTO_Credentials__c();
        pc.Country_Code__c = 'US';
        insert pc;
        PTOFeeCode__c pfc = NEW PTOFeeCode__c();
        pfc.Jurisdiction__c = 'US';
        pfc.Term_Name__c = 'Year 3.7';
        pfc.FeeCode__c = '31';
        pfc.Surcharge_Code__c = '33';
        pfc.Entity_Type__c ='Large';
        insert pfc;
        QB_Account__c qba = NEW QB_Account__c();
        qba.Name = 'QBA1';
        qba.Account_Type__c = 'Bank';
        qba.QB_Account_Id__c = '50';
        qba.Jurisdiction__c = 'US';
        qba.Active__c = true;
        insert qba;
        QB_Account__c qba1 = NEW QB_Account__c();
        qba1.Name = 'QBA1';
        qba1.Account_Type__c = 'Credit Card';
        qba1.QB_Account_Id__c = '51';
        qba1.Jurisdiction__c = 'US';
        qba1.Active__c = true; 
        insert qba1;
        
        API_Credentials__c ObjAPI = new API_Credentials__c();
        ObjAPI.Password__c ='Test@1234';
        ObjAPI.Username__c ='MaxvalAPI';
        ObjAPI.Name ='Renewal Bill Create';
        ObjAPI.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI;
        
        API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name ='PTO Payment Validate';
        ObjAPI1.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI1;
        
        API_Auth_Detail__c aad = NEW API_Auth_Detail__c();
        aad.Auth_Code__c = 'AAD1';
        aad.ClientId__c	= aad.id;
        
        Batch_Queue__c objBatchQueue = new  Batch_Queue__c();
        objBatchQueue.Name = 'Order Placed Mail Alert ';
        objBatchQueue.Status__c = 'To Do' ;
        insert objBatchQueue;
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
		ClList.add(Cl.id);        
        
        List<Id> ListOrd =new List<Id>();
        Set<Id > OrdSet =new Set<Id>();
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        OrdSet.add(Ord.id);
        ListOrd.add(Ord.id);
        
        QB_Customer__c qbc1 = NEW QB_Customer__c();
        qbc1.Name = 'QBC1';
        qbc1.QB_Customer_Id__c = '50';
        qbc1.Client__c = Ord.Client__c;
        qbc1.Active__c = true;
        insert qbc1;
        
        QB_Supplier__c qsc1 = NEW QB_Supplier__c();
        qsc1.Name = 'QBC1';
        qsc1.QB_Supplier_Id__c = '50';
        qsc1.Jurisdiction__c = 'US';
        qsc1.Active__c = true;
        insert qsc1;
        
        Payment_Confirmation__c pc1 = NEW Payment_Confirmation__c();
        pc1.Payment_Amount__c = 4848;
        pc1.Amount_for_selected_Assets__c = 24;
        pc1.Payment_Method__c = 'Wire Transfer';
        insert pc1;  
        system.debug('Exchange rate:' + string.valueOf(pc1.Exchange_Rate__c));
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment_Confirmation__c = pc1.id;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001';
        OI.Patent_No__c='0000001EP';
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Fee__c=Double.valueOf('1234');
        OI.Surcharge__c=13350.00;
        Insert OI;
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(404));
        MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        ptoValidationReqWrapper wp = new ptoValidationReqWrapper();
        wp.countryCode = 'US';
        wp.countryAssets = new List<Order_Item__c>{OI};
        batchRenewalBillCreate cls = New batchRenewalBillCreate(new list<ptoValidationReqWrapper>{wp}, '150');
        database.executebatch(cls,1);
        
        Test.stopTest();
    
    } 
    static testMethod void testMethod5() 
    {
        PTO_Credentials__c pc  = NEW PTO_Credentials__c();
        pc.Country_Code__c = 'US';
        insert pc;
        PTOFeeCode__c pfc = NEW PTOFeeCode__c();
        pfc.Jurisdiction__c = 'US';
        pfc.Term_Name__c = 'Year 3.7';
        pfc.FeeCode__c = '31';
        pfc.Surcharge_Code__c = '33';
        pfc.Entity_Type__c ='Large';
        insert pfc;
        QB_Account__c qba = NEW QB_Account__c();
        qba.Name = 'QBA1';
        qba.Account_Type__c = 'Bank';
        qba.QB_Account_Id__c = '50';
        qba.Jurisdiction__c = 'US';
        qba.Active__c = true;
        insert qba;
        QB_Account__c qba1 = NEW QB_Account__c();
        qba1.Name = 'QBA1';
        qba1.Account_Type__c = 'Credit Card';
        qba1.QB_Account_Id__c = '51';
        qba1.Jurisdiction__c = 'US';
        qba1.Active__c = true; 
        insert qba1;
        
        API_Credentials__c ObjAPI = new API_Credentials__c();
        ObjAPI.Password__c ='Test@1234';
        ObjAPI.Username__c ='MaxvalAPI';
        ObjAPI.Name ='Renewal Bill Create';
        ObjAPI.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI;
        
        API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name ='PTO Payment Validate';
        ObjAPI1.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI1;
        
        API_Auth_Detail__c aad = NEW API_Auth_Detail__c();
        aad.Auth_Code__c = 'AAD1';
        aad.ClientId__c	= aad.id;
        
        Batch_Queue__c objBatchQueue = new  Batch_Queue__c();
        objBatchQueue.Name = 'Order Placed Mail Alert ';
        objBatchQueue.Status__c = 'To Do' ;
        insert objBatchQueue;
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
		ClList.add(Cl.id);        
        
        List<Id> ListOrd =new List<Id>();
        Set<Id > OrdSet =new Set<Id>();
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        OrdSet.add(Ord.id);
        ListOrd.add(Ord.id);
        
        QB_Customer__c qbc1 = NEW QB_Customer__c();
        qbc1.Name = 'QBC1';
        qbc1.QB_Customer_Id__c = '50';
        qbc1.Client__c = Ord.Client__c;
        qbc1.Active__c = true;
        insert qbc1;
        
        QB_Supplier__c qsc1 = NEW QB_Supplier__c();
        qsc1.Name = 'QBC1';
        qsc1.QB_Supplier_Id__c = '50';
        qsc1.Jurisdiction__c = 'US';
        qsc1.Active__c = true;
        insert qsc1;
        
        Payment_Confirmation__c pc1 = NEW Payment_Confirmation__c();
        pc1.Payment_Amount__c = 4848;
        pc1.Amount_for_selected_Assets__c = 24;
        pc1.Payment_Method__c = 'Wire Transfer';
        insert pc1;  
        system.debug('Exchange rate:' + string.valueOf(pc1.Exchange_Rate__c));
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment_Confirmation__c = pc1.id;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001';
        OI.Patent_No__c='0000001EP';
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Fee__c=Double.valueOf('1234');
        OI.Surcharge__c=13350.00;
        Insert OI;
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(500));
        MaxValAPIAuthenticaionHelper.MaxValAPIAuthenticaionHelper();
        ptoValidationReqWrapper wp = new ptoValidationReqWrapper();
        wp.countryCode = 'US';
        wp.countryAssets = new List<Order_Item__c>{OI};
        batchRenewalBillCreate cls = New batchRenewalBillCreate(new list<ptoValidationReqWrapper>{wp}, '150');
        database.executebatch(cls,1);
        
        Test.stopTest();
    
    } 
}