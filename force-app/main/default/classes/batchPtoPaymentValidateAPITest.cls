@isTest
public class batchPtoPaymentValidateAPITest {
    @isTest public static void TestMethod1()
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
        OI.PTO_Validation_Request_ID__c='abcdefg';
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
    @isTest public static void TestMethod2()
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
        
        List<Order_Item__c> listOI = NEW List<Order_Item__c>();
        for(integer i =0;i<=4;i++)
        {
            Order_Item__c OI =new Order_Item__c();
            OI.Order__c =Ord.Id;
            OI.PTO_Validation_Status__c='Request to Validate';
            OI.PTO_Validation_Request_ID__c='abcdefg';
            OI.Jurisdiction__c='US';
            OI.Application_Date__c=date.today().addyears(-4);            
            OI.Filing_Date__c=date.today().addyears(-4);
            OI.Application_No__c='US000000'+i;
            OI.Patent_No__c='US000000'+i;
            OI.Term_Name__c='Year 3.7';
            OI.Entity_Type_Name__c='Large';
            listOI.add(OI);
        }
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001A';
        OI.Patent_No__c='US0000001B1';
        OI.Filing_Date__c=date.today().addyears(-4);
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Surcharge__c=13350.00;
        Insert OI;
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
        Insert OI1;
        test.startTest();  
        batchPtoPaymentValidateAPI cls = NEW batchPtoPaymentValidateAPI();
        Test.setMock(HttpCalloutMock.class, new batchPtoPaymentValidateCalloutMock());
        database.executebatch(cls);
        test.stopTest();
    }
    @isTest public static void TestMethod3()
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
        
        List<Order_Item__c> listOI = NEW List<Order_Item__c>();
        for(integer i =0;i<=4;i++)
        {
            Order_Item__c OI =new Order_Item__c();
            OI.Order__c =Ord.Id;
            OI.PTO_Validation_Status__c='Request to Validate';
            OI.PTO_Validation_Request_ID__c='abcdefg';
            OI.Jurisdiction__c='US';
            OI.Application_Date__c=date.today().addyears(-4);
            OI.Application_No__c='US000000'+i;
            OI.Patent_No__c='US000000'+i;
            OI.Term_Name__c='Year 3.7';
            OI.Entity_Type_Name__c='Large';
            listOI.add(OI);
        }
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001';
        OI.Patent_No__c='US0000001A';       
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='';
        OI.Surcharge__c=13350.00;
        Insert OI;
        Order_Item__c OI1 =new Order_Item__c();
        OI1.Order__c =Ord.Id;
        OI1.PTO_Validation_Status__c='Request to Validate';
        OI1.PTO_Validation_Request_ID__c='abcdefg';
        OI1.Jurisdiction__c='US';
        OI1.Application_Date__c=date.today().addyears(-4);
        OI1.Application_No__c='US0000003A2';
        OI1.Patent_No__c='US0000003A2';
        OI1.Term_Name__c='Year 3.7';
        OI1.Entity_Type_Name__c='Large';
        OI1.Surcharge__c=13350.00;
        Insert OI1;
        test.startTest();  
        batchPtoPaymentValidateAPI cls = NEW batchPtoPaymentValidateAPI();
        Test.setMock(HttpCalloutMock.class, new batchPtoPaymentValidateFCalloutMock());
        database.executebatch(cls);
        test.stopTest();
    }
    @isTest public static void TestMethod4()
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
        
        List<Order_Item__c> listOI = NEW List<Order_Item__c>();
        for(integer i =0;i<=4;i++)
        {
            Order_Item__c OI =new Order_Item__c();
            OI.Order__c =Ord.Id;
            OI.PTO_Validation_Status__c='Request to Validate';
            OI.PTO_Validation_Request_ID__c='abcdefg';
            OI.Jurisdiction__c='US';
            OI.Application_Date__c=date.today().addyears(-4);            
            OI.Filing_Date__c=date.today().addyears(-4);
            OI.Application_No__c='US000000'+i;
            OI.Patent_No__c='US000000'+i;
            OI.Term_Name__c='Year 3.7';
            OI.Entity_Type_Name__c='Large';
            listOI.add(OI);
        }
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.PTO_Validation_Status__c='Request to Validate';
        OI.PTO_Validation_Request_ID__c='abcdefg';
        OI.Jurisdiction__c='US';
        OI.Application_Date__c=date.today().addyears(-4);
        OI.Application_No__c='US0000001A';
        OI.Patent_No__c='US0000001B1';
        OI.Filing_Date__c=date.today().addyears(-4);
        OI.Term_Name__c='Year 3.7';
        OI.Entity_Type_Name__c='Large';
        OI.Surcharge__c=13350.00;
        Insert OI;
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
        Insert OI1;
        test.startTest();  
        batchPtoPaymentValidateAPI cls = NEW batchPtoPaymentValidateAPI();
        Test.setMock(HttpCalloutMock.class, new batchPtoPaymentValidateCalloutMock());
        database.executebatch(cls);
        test.stopTest();
    }
}