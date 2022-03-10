@isTest 
public class batchRenewalBillCreateTest 
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
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        
        QB_Customer__c qbc1 = NEW QB_Customer__c();
        qbc1.Name = 'QBC1';
        qbc1.QB_Customer_Id__c = '50';
        qbc1.Client__c = Ord.Client__c;
        insert qbc1;
        
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
        Insert OI;
        
        
        ptoValidationReqWrapper wp = new ptoValidationReqWrapper();
        wp.countryCode = 'US';
        wp.countryAssets = new List<Order_Item__c>{OI};
        batchRenewalBillCreate cls = New batchRenewalBillCreate(new list<ptoValidationReqWrapper>{wp}, '50');
        database.executebatch(cls,1);
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
        
        Batch_Queue__c objBatchQueue = new  Batch_Queue__c();
        objBatchQueue.Name = 'Order Placed Mail Alert ';
        objBatchQueue.Status__c = 'To Do' ;
        insert objBatchQueue;
        
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Test Status';
        Cl.Contact_Email_Id__c ='juveria.b@maxval.com';
        Insert Cl;
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Insert Ord;
        
        QB_Customer__c qbc1 = NEW QB_Customer__c();
        qbc1.Name = 'QBC1';
        qbc1.QB_Customer_Id__c = '50';
        qbc1.Client__c = Ord.Client__c;
        insert qbc1;
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
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
        
        ptoValidationReqWrapper wp = new ptoValidationReqWrapper();
        wp.countryCode = 'US';
        wp.countryAssets = new List<Order_Item__c>{OI};
        batchRenewalBillCreate cls = New batchRenewalBillCreate(new list<ptoValidationReqWrapper>{wp}, '50\\|\\|100');
        database.executebatch(cls,1);
    }
}