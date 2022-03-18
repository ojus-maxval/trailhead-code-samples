@isTest 
public class createAttachPaymentConfirmationTest 
{
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
        qba.QB_Account_Id__c = '51';
        insert qba1;
        API_Credentials__c ObjAPI = new API_Credentials__c();
        ObjAPI.Password__c ='Test@1234';
        ObjAPI.Username__c ='MaxvalAPI';
        ObjAPI.Name ='PTO Payment File';
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
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        
        List<Order_Item__c> listOI = NEW List<Order_Item__c>();
        Order_Item__c OI1 =new Order_Item__c();
        OI1.Order__c =Ord.Id;
        OI1.PTO_Validation_Status__c='Request to Validate';
        OI1.PTO_Validation_Request_ID__c='abcdefg';
        OI1.Jurisdiction__c='US';
        OI1.Application_Date__c=date.today().addyears(-4);
        OI1.Application_No__c='US0000003';
        OI1.Patent_No__c='US0000003';
        OI1.Term_Name__c='Year 3.7';
        OI1.Fee__c=Double.valueOf('1234');
        OI1.Entity_Type_Name__c='Large';
        OI1.Surcharge__c=13350.00;
        listOI.add(OI1);
        test.startTest();
        insert listOI;
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
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
        Insert OI;
        pagereference pref=page.vfAttachPaymentConfirmation;
        test.setCurrentPage(pref);
        apexpages.standardsetcontroller std=new apexpages.StandardSetController(listOI);
        std.setselected(listOI);
        createAttachPaymentConfirmation cls =NEW createAttachPaymentConfirmation(std);
        createAttachPaymentConfirmation.createPaymentConfirmation(new list<id>{OI.id},createAttachPaymentConfirmation.getDetails('['+OI.id+']').payAtt);
        test.stopTest();
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
        qba.Account_Type__c = 'Bank';
        qba.QB_Account_Id__c = '50';
        insert qba;
        QB_Account__c qba1 = NEW QB_Account__c();
        qba1.Account_Type__c = 'Credit Card';
        qba.QB_Account_Id__c = '51';
        insert qba1;
        API_Credentials__c ObjAPI = new API_Credentials__c();
        ObjAPI.Password__c ='Test@1234';
        ObjAPI.Username__c ='MaxvalAPI';
        ObjAPI.Name ='PTO Payment File';
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
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        
        Payment__c payc = new Payment__c();
        payc.Name = 'Maxval123';
        insert payc;
        
        Payment_Confirmation__c pc1 = new Payment_confirmation__c();
        pc1.Name = 'ABC123';
        insert pc1;
        
        List<Order_Item__c> listOI = NEW List<Order_Item__c>();
        Order_Item__c OI1 =new Order_Item__c();
        OI1.Order__c =Ord.Id;
        OI1.Payment__c = payc.Id;
        OI1.Payment_Confirmation__c = pc1.Id;
        OI1.Renewal_Status__c = 'Asset Renewed';
        OI1.Payment_Approval_Status__c = 'Requested to Approve';
        OI1.Payment_Status__c = 'Asset Renewed';
        OI1.PTO_Validation_Status__c='Request to Validate';
        OI1.PTO_Validation_Request_ID__c='abcdefg';
        OI1.Jurisdiction__c='US';
        OI1.Application_Date__c=date.today().addyears(-4);
        OI1.Application_No__c='US0000003';
        OI1.Patent_No__c='US0000003';
        OI1.Term_Name__c='Year 3.7';
        OI1.Fee__c=Double.valueOf('1234');
        OI1.Entity_Type_Name__c='Large';
        OI1.Surcharge__c=13350.00;
        listOI.add(OI1);
        test.startTest();
        insert listOI;
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment__c = payc.Id;
        OI.Payment_Confirmation__c = pc1.Id;
        OI.Renewal_Status__c = 'Asset Renewed';
        OI.Payment_Approval_Status__c = 'Requested to Approve';
        OI.Payment_Status__c = 'Asset Renewed';
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001';
        OI.Patent_No__c='US000000';
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Surcharge__c=13350.00;
        OI.Fee__c=Double.valueOf('1234');
        Insert OI;
        pagereference pref=page.vfAttachPaymentConfirmation;
        test.setCurrentPage(pref);
        apexpages.standardsetcontroller std=new apexpages.StandardSetController(listOI);
        std.setselected(listOI);
        createAttachPaymentConfirmation cls =NEW createAttachPaymentConfirmation(std);
        createAttachPaymentConfirmation.myDataWrapper mdw = new createAttachPaymentConfirmation.myDataWrapper();
        mdw.errorInData = false;
        mdw.errorMessage = 'No error';
        createAttachPaymentConfirmation.createPaymentConfirmation(new list<id>{OI.id},createAttachPaymentConfirmation.getDetails('['+OI.id+']').payAtt);
        test.stopTest();
    }
    static testMethod void testMethod3() 
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
        qba.QB_Account_Id__c = '51';
        insert qba1;
        API_Credentials__c ObjAPI = new API_Credentials__c();
        ObjAPI.Password__c ='Test@1234';
        ObjAPI.Username__c ='MaxvalAPI';
        ObjAPI.Name ='PTO Payment File';
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
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        
        Payment__c payc = new Payment__c();
        payc.Name = 'Maxval123';
        insert payc;
        
        Payment_Confirmation__c pc1 = new Payment_confirmation__c();
        pc1.Name = 'ABC123';
        insert pc1;
        
        List<Order_Item__c> listOI = NEW List<Order_Item__c>();
        Order_Item__c OI1 =new Order_Item__c();
        OI1.Order__c =Ord.Id;
        OI1.Payment__c = payc.Id;
        OI1.Payment_Confirmation__c = pc1.Id;
        OI1.Renewal_Status__c = 'Instruction Received';
        OI1.Payment_Approval_Status__c = 'Requested to Approve';
        OI1.Payment_Status__c = 'Asset Renewed';
        OI1.PTO_Validation_Status__c='Request to Validate';
        OI1.PTO_Validation_Request_ID__c='abcdefg';
        OI1.Jurisdiction__c='US';
        OI1.Application_Date__c=date.today().addyears(-4);
        OI1.Application_No__c='US0000003';
        OI1.Patent_No__c='US0000003';
        OI1.Term_Name__c='Year 3.7';
        OI1.Fee__c=Double.valueOf('1234');
        OI1.Entity_Type_Name__c='Large';
        OI1.Surcharge__c=13350.00;
        listOI.add(OI1);
        test.startTest();
        insert listOI;
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment__c = payc.Id;
        OI.Payment_Confirmation__c = pc1.Id;
        OI.Renewal_Status__c = 'Instruction Received';
        OI.Payment_Approval_Status__c = 'Requested to Approve';
        OI.Payment_Status__c = 'Asset Renewed';
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001';
        OI.Patent_No__c='US000000';
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Surcharge__c=13350.00;
        OI.Fee__c=Double.valueOf('1234');
        Insert OI;
        pagereference pref=page.vfAttachPaymentConfirmation;
        test.setCurrentPage(pref);
        apexpages.standardsetcontroller std=new apexpages.StandardSetController(listOI);
        std.setselected(listOI);
        createAttachPaymentConfirmation cls =NEW createAttachPaymentConfirmation(std);
        createAttachPaymentConfirmation.createPaymentConfirmation(new list<id>{OI.id},createAttachPaymentConfirmation.getDetails('['+OI.id+']').payAtt);
        test.stopTest();
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
        qba.Account_Type__c = 'Bank';
        qba.QB_Account_Id__c = '50';
        insert qba;
        QB_Account__c qba1 = NEW QB_Account__c();
        qba1.Account_Type__c = 'Credit Card';
        qba.QB_Account_Id__c = '51';
        insert qba1;
        API_Credentials__c ObjAPI = new API_Credentials__c();
        ObjAPI.Password__c ='Test@1234';
        ObjAPI.Username__c ='MaxvalAPI';
        ObjAPI.Name ='PTO Payment File';
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
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        
        Payment__c payc = new Payment__c();
        payc.Name = 'Maxval123';
        insert payc;
        
        Payment_Confirmation__c pc1 = new Payment_confirmation__c();
        pc1.Name = 'ABC123';
        insert pc1;
        
        List<Order_Item__c> listOI = NEW List<Order_Item__c>();
        Order_Item__c OI1 =new Order_Item__c();
        OI1.Order__c =Ord.Id;
        OI1.Payment__c = payc.Id;
        OI1.Payment_Confirmation__c = pc1.Id;
        OI1.Renewal_Status__c = 'Instruction Received';
        OI1.Payment_Approval_Status__c = 'Requested to Approve';
        OI1.Payment_Status__c = 'Asset Renewed';
        OI1.PTO_Validation_Status__c='Request to Validate';
        OI1.PTO_Validation_Request_ID__c='abcdefg';
        OI1.Jurisdiction__c='US';
        OI1.Application_Date__c=date.today().addyears(-4);
        OI1.Application_No__c='US0000003';
        OI1.Patent_No__c='US0000003';
        OI1.Term_Name__c='Year 3.7';
        OI1.Fee__c=Double.valueOf('1234');
        OI1.Entity_Type_Name__c='Large';
        OI1.Surcharge__c=13350.00;
        listOI.add(OI1);
        test.startTest();
        insert listOI;
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment__c = payc.Id;
        OI.Payment_Confirmation__c = pc1.Id;
        OI.Renewal_Status__c = 'Instruction Received';
        OI.Payment_Approval_Status__c = 'Requested to Approve';
        OI.Payment_Status__c = 'Asset Renewed';
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001';
        OI.Patent_No__c='US000000';
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Surcharge__c=13350.00;
        OI.Fee__c=Double.valueOf('1234');
        Insert OI;
        pagereference pref=page.vfAttachPaymentConfirmation;
        test.setCurrentPage(pref);
        apexpages.standardsetcontroller std=new apexpages.StandardSetController(listOI);
        std.setselected(listOI);
        createAttachPaymentConfirmation cls =NEW createAttachPaymentConfirmation(std);
        createAttachPaymentConfirmation.createPaymentConfirmation(new list<id>{OI.id},createAttachPaymentConfirmation.getDetails('['+']').payAtt);
        test.stopTest();
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
        qba.Account_Type__c = 'Bank';
        qba.QB_Account_Id__c = '50';
        insert qba;
        QB_Account__c qba1 = NEW QB_Account__c();
        qba1.Account_Type__c = 'Credit Card';
        qba.QB_Account_Id__c = '51';
        insert qba1;
        API_Credentials__c ObjAPI = new API_Credentials__c();
        ObjAPI.Password__c ='Test@1234';
        ObjAPI.Username__c ='MaxvalAPI';
        ObjAPI.Name ='PTO Payment File';
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
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        
        Payment__c payc = new Payment__c();
        payc.Name = 'Maxval123';
        insert payc;
        
        Payment_Confirmation__c pc1 = new Payment_confirmation__c();
        pc1.Name = 'ABC123';
        insert pc1;
        
        List<Order_Item__c> listOI = NEW List<Order_Item__c>();
        Order_Item__c OI1 =new Order_Item__c();
        OI1.Order__c =Ord.Id;
        OI1.Payment__c = payc.Id;
        OI1.Payment_Confirmation__c = pc1.Id;
        OI1.Renewal_Status__c = 'Instruction Received';
        OI1.Payment_Approval_Status__c = 'Requested to Approve';
        OI1.Payment_Status__c = 'Asset Renewed';
        OI1.PTO_Validation_Status__c='Request to Validate';
        OI1.PTO_Validation_Request_ID__c='abcdefg';
        OI1.Jurisdiction__c='US';
        OI1.Application_Date__c=date.today().addyears(-4);
        OI1.Application_No__c='US0000003';
        OI1.Patent_No__c='US0000003';
        OI1.Term_Name__c='Year 3.7';
        OI1.Fee__c=Double.valueOf('1234');
        OI1.Entity_Type_Name__c='Large';
        OI1.Surcharge__c=13350.00;
        listOI.add(OI1);
        test.startTest();
        insert listOI;
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Payment__c = payc.Id;
        OI.Renewal_Status__c = 'Instruction Received';
        OI.Payment_Approval_Status__c = 'Requested to Approve';
        OI.Payment_Status__c = 'Asset Renewed';
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001';
        OI.Patent_No__c='US000000';
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Surcharge__c=13350.00;
        OI.Fee__c=Double.valueOf('1234');
        Insert OI;
        pagereference pref=page.vfAttachPaymentConfirmation;
        test.setCurrentPage(pref);
        apexpages.standardsetcontroller std=new apexpages.StandardSetController(listOI);
        std.setselected(listOI);
        createAttachPaymentConfirmation cls =NEW createAttachPaymentConfirmation(std);
        createAttachPaymentConfirmation.createPaymentConfirmation(new list<id>{OI.id},createAttachPaymentConfirmation.getDetails('['+OI.id+']').payAtt);
        test.stopTest();
    }
}