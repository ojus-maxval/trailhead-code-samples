@isTest
public class batchPtoPaymentValidateAPITest {
    @isTest public static void ValidResponse()
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
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='PTO-3847646278932388374';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001';
        OI.Patent_No__c='US0000001';
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Surcharge__c=13350.00;
        Insert OI;
        ptoValidationReqWrapper wrp = NEW ptoValidationReqWrapper();
        wrp.countryCode = 'US';
        wrp.countryAssets = NEW List<Order_Item__c>{OI};
        test.startTest();
        batchPtoPaymentValidateAPI cls = NEW batchPtoPaymentValidateAPI(new List<ptoValidationReqWrapper>{wrp});
        Test.setMock(HttpCalloutMock.class, new batchPtoPaymentValidateCalloutMock());
        database.executebatch(cls);
        test.stopTest();
    }
    @isTest public static void ValidatingFields()
    {
        PTO_Credentials__c pc  = NEW PTO_Credentials__c();
        pc.Country_Code__c = 'EP';
        insert pc;
        PTOFeeCode__c pfc = NEW PTOFeeCode__c();
        pfc.Jurisdiction__c = 'EP';
        pfc.Term_Name__c = 'Year 3';
        pfc.FeeCode__c = '033';
        pfc.Surcharge_Code__c = '33';
        pfc.Entity_Type__c ='Large';
        insert pfc;
        
        API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name ='PTO Payment Validate';
        ObjAPI1.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI1;
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='EP';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='EP0000001A';
        OI.Patent_No__c='EP0000001A';
        OI.Filing_Date__c=system.today();
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='';
        OI.Surcharge__c=13350.00;
        Insert OI;
        test.startTest();  
        batchPtoPaymentValidateAPI cls = NEW batchPtoPaymentValidateAPI();
        Test.setMock(HttpCalloutMock.class, new batchPtoPaymentValidateFCalloutMock());
        database.executebatch(cls);
        test.stopTest();
    }
    
    @isTest public static void ValidateWithSurcharge()
    {
        PTO_Credentials__c pc  = NEW PTO_Credentials__c();
        pc.Country_Code__c = 'US';
        insert pc;
        PTOFeeCode__c pfc = NEW PTOFeeCode__c();
        pfc.Jurisdiction__c = 'US';
        pfc.Term_Name__c = 'Year 3.5';
        pfc.FeeCode__c = '33';
        pfc.Surcharge_Code__c = '33';
        pfc.Entity_Type__c ='Large';
        insert pfc;
        
        API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name ='PTO Payment Validate';
        ObjAPI1.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI1;
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='PTO-3847646278932388374';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001A2';
        OI.Patent_No__c='US0000001A2';
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Surcharge__c=13350.00;
        Insert OI;
        
        test.startTest();  
        batchPtoPaymentValidateAPI cls = NEW batchPtoPaymentValidateAPI();
        Test.setMock(HttpCalloutMock.class, new batchPtoPaymentValidateFCalloutMock());
        database.executebatch(cls);
        test.stopTest();
    }
    @isTest public static void ValidateWithVariousJurisdiction()
    {
        API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name ='PTO Payment Validate';
        ObjAPI1.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI1;
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='sneha.b@maxval.com';
        Insert Cl;
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='PTO-3847646278932388374';
        OI.Jurisdiction__c='NZ';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='NZ0000001A2';
        OI.Patent_No__c=null;
        OI.Term_Name__c='Year 3';
        OI.Entity_Type_Name__c='Large';
        OI.Surcharge__c=13350.00;
        Insert OI;
        
        test.startTest();  
        batchPtoPaymentValidateAPI cls = NEW batchPtoPaymentValidateAPI();
        Test.setMock(HttpCalloutMock.class, new batchPtoPaymentValidateCalloutMock());
        database.executebatch(cls);
        test.stopTest();
    }
	@isTest public static void ValidateMulitpleAssets()
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
        
        API_Credentials__c ObjAPI1 = new API_Credentials__c();
        ObjAPI1.Password__c ='Test@1234';
        ObjAPI1.Username__c ='MaxvalAPI';
        ObjAPI1.Name ='PTO Payment Validate';
        ObjAPI1.URL__c ='https://login.salesforce.com/services/oauth2/token';
        insert ObjAPI1;
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='sneha.b@maxval.com';
        Insert Cl;
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='PTO-3847646278932388374';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001';
        OI.Patent_No__c='-';
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Surcharge__c=13350.00;
        Insert OI;
        List<Order_Item__c> listOI = NEW List<Order_Item__c>{new Order_Item__c(Jurisdiction__c='US',Surcharge__c=13350.00,Application_Date__c=date.today().addyears(-4),Application_No__c='US0000001',Order__c =Ord.Id,PTO_Validation_Request_ID__c ='PTO-3847646278932388374',Payment_Status__c ='Payment Received'),
        new Order_Item__c(Order__c =Ord.Id,Jurisdiction__c='US',Surcharge__c=13350.00,Entity_Type_Name__c='Large',Application_Date__c=date.today().addyears(-4),Application_No__c='US0000001',PTO_Validation_Request_ID__c ='PTO-3847646278932388374',Payment_Status__c ='Payment Received'),
        new Order_Item__c(Order__c =Ord.Id,Jurisdiction__c='US',Surcharge__c=13350.00,Entity_Type_Name__c='Large',Application_Date__c=date.today().addyears(-4),Application_No__c='US0000001',PTO_Validation_Request_ID__c ='PTO-3847646278932388374',Payment_Status__c ='Payment Received'),
            new Order_Item__c(Order__c =Ord.Id,Jurisdiction__c='US',Surcharge__c=13350.00,Entity_Type_Name__c='Large',Application_Date__c=date.today().addyears(-4),Application_No__c='US0000001',PTO_Validation_Request_ID__c ='PTO-3847646278932388374',Payment_Status__c ='Payment Received'),
            new Order_Item__c(Order__c =Ord.Id,Jurisdiction__c='US',Surcharge__c=13350.00,Entity_Type_Name__c='Large',Application_Date__c=date.today().addyears(-4),Application_No__c='US0000001',PTO_Validation_Request_ID__c ='PTO-3847646278932388374',Payment_Status__c ='Payment Received')};
        Insert listOI;
        ptoValidationReqWrapper wrp = NEW ptoValidationReqWrapper();
        wrp.countryCode = 'US';
        wrp.countryAssets = listOI;
        test.startTest();
        batchPtoPaymentValidateAPI cls = NEW batchPtoPaymentValidateAPI(new List<ptoValidationReqWrapper>{wrp});
        Test.setMock(HttpCalloutMock.class, new batchPtoPaymentValidateCalloutMock());
        database.executebatch(cls);
        test.stopTest();
    }
}