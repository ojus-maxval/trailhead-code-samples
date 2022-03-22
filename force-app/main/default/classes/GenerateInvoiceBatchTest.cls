@isTest
public class GenerateInvoiceBatchTest {
    static testMethod void testMethod1() 
    {
        test.startTest();
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Sample';
        Insert Cl;
        ClList.add(Cl.id);
        List<Id> ListOrd =new List<Id>();
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Ord.Late_Fee__c = 100.00;
        Ord.Payment_Status__c = 'To be Invoiced';
        Insert Ord;
        ListOrd.add(Ord.id);
        
        /*Invoice__c inv = new Invoice__c();
        inv.Order__c = ord.id;
        inv.Invoice_Amount__c = 100;
        inv.Is_Late_Rush_Fee_Included__c = true;
        insert inv;*/
        
        Batch_Queue__c objBatchQueue = new  Batch_Queue__c();
        objBatchQueue.Name = 'Generate Invoice';
        objBatchQueue.Status__c = 'To Do' ;
        objBatchQueue.Parent_Id__c = ord.Id;
        insert objBatchQueue;
        
        GenerateInvoiceBatch objGenerateInvoiceBatch = new GenerateInvoiceBatch(ListOrd);
        Database.executeBatch(objGenerateInvoiceBatch,1);
        
        test.stopTest();
    }
    static testMethod void testMethod2() 
    {
        
        test.startTest();
        GenerateInvoiceBatch objGenerateInvoiceBatch = new GenerateInvoiceBatch();
        ID batchprocessid = Database.executeBatch(objGenerateInvoiceBatch,1);
        test.stopTest();
    }
    static testMethod void testMethod3() 
    {
        
        test.startTest();
        GenerateInvoiceBatch objGenerateInvoiceBatch = new GenerateInvoiceBatch();
        ID batchprocessid = Database.executeBatch(objGenerateInvoiceBatch,1);
        GenerateInvoiceBatch gib = new GenerateInvoiceBatch(batchprocessid);
        test.stopTest();
    }
    
    static testMethod void testMethod4() 
    {
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Sample';
        Cl.Invoice_Type__c = 'Regular Invoice';
        Insert Cl;
        ClList.add(Cl.id);
        
        Invoice_Type_Configuration__c ITC =new Invoice_Type_Configuration__c();
        ITC.Contact_Persons__c = 'pratyush.r@maxval.com';
        ITC.Client__c =Cl.id;
        insert ITC;
        
        List<Id> ListOrd =new List<Id>();
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Ord.Payment_Status__c = 'Invoiced';
        Insert Ord;
        ListOrd.add(Ord.id);
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Billing_Currency__c = 'USD';
        OI.Path__c = null;
        OI.Invoice_Type_Name__c = '-';
        Insert OI;
        
        Currency__c cur = new Currency__c();
        cur.Name = 'US';
        cur.Exchange_Rate__c = 75;
        Insert cur;
        
        Invoice__c inv = new Invoice__c();
        inv.Order__c = ord.id;
        inv.Invoice_Date__c = Datetime.now();
        inv.Invoice_Status__c = 'Created';
        inv.Is_Active__c = true;
        inv.Invoice_Currency__c = 'USD';
        inv.Invoice_Type__c = 'ABC123';
        inv.Invoice_Type_Name__c = ord.Client__r.Id + '_' + ord.Id + '_' + oi.Billing_Currency__c;
        inv.Invoice_No__c = 'INV001';
        inv.Invoice_Amount__c = 100.00;
        inv.Invoice_Config_Type__c = 'Maxval123';
        inv.Is_Late_Rush_Fee_Included__c = true;
        inv.API_Status__c = 'Completed';
        Insert inv;
        
        test.startTest();
        GenerateInvoiceBatch objGenerateInvoiceBatch = new GenerateInvoiceBatch(ListOrd);
        Database.executeBatch(objGenerateInvoiceBatch,1);
        
        test.stopTest();
    }
    static testMethod void testMethod5() 
    {
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Sample';
        Cl.Invoice_Type__c = 'Regular Invoice';
        Insert Cl;
        ClList.add(Cl.id);
        
        Invoice_Type_Configuration__c ITC =new Invoice_Type_Configuration__c();
        ITC.Contact_Persons__c = 'pratyush.r@maxval.com';
        ITC.Client__c =Cl.id;
        insert ITC;
        
        List<Id> ListOrd =new List<Id>();
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Ord.Payment_Status__c = 'Invoiced';
        Insert Ord;
        ListOrd.add(Ord.id);
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Billing_Currency__c = 'USD';
        OI.Path__c = null;
        OI.Invoice_Type_Name__c = 'INV001_';
        Insert OI;
        
        Currency__c cur = new Currency__c();
        cur.Name = 'US';
        cur.Exchange_Rate__c = 75;
        Insert cur;
        
        Invoice__c inv = new Invoice__c();
        inv.Order__c = ord.id;
        inv.Invoice_Date__c = Datetime.now();
        inv.Invoice_Status__c = 'Created';
        inv.Is_Active__c = true;
        inv.Invoice_Currency__c = 'USD';
        inv.Invoice_Type__c = 'ABC123';
        inv.Invoice_Type_Name__c = ord.Client__r.Id + '_' + ord.Id + '_' + oi.Billing_Currency__c;
        inv.Invoice_No__c = 'INV001';
        inv.Invoice_Amount__c = 100.00;
        inv.Invoice_Config_Type__c = 'Maxval123';
        inv.Is_Late_Rush_Fee_Included__c = true;
        inv.API_Status__c = 'Completed';
        Insert inv;
        
        test.startTest();
        GenerateInvoiceBatch objGenerateInvoiceBatch = new GenerateInvoiceBatch(ListOrd);
        Database.executeBatch(objGenerateInvoiceBatch,1);
        
        test.stopTest();
    }
    static testMethod void testMethod6() 
    {
        
        List<Id > ClList =new List<Id>();
        Clients__c  Cl =new Clients__c ();
        Cl.Client_Name__c = 'Sample';
        Cl.Invoice_Type__c = 'Regular Invoice';
        Insert Cl;
        ClList.add(Cl.id);
        
        Invoice_Type_Configuration__c ITC =new Invoice_Type_Configuration__c();
        ITC.Contact_Persons__c = 'pratyush.r@maxval.com';
        ITC.Client__c =Cl.id;
        insert ITC;
        
        List<Id> ListOrd =new List<Id>();
        
        Order__c  Ord =new Order__c ();
        Ord.Client__c =Cl.id;
        Ord.Payment_Status__c = 'Invoiced';
        Insert Ord;
        ListOrd.add(Ord.id);
        
        Order_Item__c OI =new Order_Item__c();
        OI.Order__c =Ord.Id;
        OI.Billing_Currency__c = 'USD';
        OI.Path__c = null;
        OI.Invoice_Type_Name__c = '_INV001';
        Insert OI;
        
        Currency__c cur = new Currency__c();
        cur.Name = 'US';
        cur.Exchange_Rate__c = 75;
        Insert cur;
        
        Invoice__c inv = new Invoice__c();
        inv.Order__c = ord.id;
        inv.Invoice_Date__c = Datetime.now();
        inv.Invoice_Status__c = 'Created';
        inv.Is_Active__c = true;
        inv.Invoice_Currency__c = 'USD';
        inv.Invoice_Type__c = 'ABC123';
        inv.Invoice_Type_Name__c = ord.Client__r.Id + '_' + ord.Id + '_' + oi.Billing_Currency__c;
        inv.Invoice_No__c = 'INV001';
        inv.Invoice_Amount__c = 100.00;
        inv.Invoice_Config_Type__c = 'Maxval123';
        inv.Is_Late_Rush_Fee_Included__c = true;
        inv.API_Status__c = 'Completed';
        Insert inv;
        
        test.startTest();
        GenerateInvoiceBatch objGenerateInvoiceBatch = new GenerateInvoiceBatch(ListOrd);
        Database.executeBatch(objGenerateInvoiceBatch,1);
        
        test.stopTest();
    }
}