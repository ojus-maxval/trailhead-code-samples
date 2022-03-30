@isTest
public class CreditMemoDatatableTest {
    
    public static testmethod void Method1()
    {
        Clients__c client = new Clients__c();
        client.Name = 'Maxval@123';
        insert client;
        
        Credit_Memo__c cm = new Credit_Memo__c();
        cm.Client__c = client.Id;
        insert cm;
        
        List<Order__c> ordList = new List<Order__c>();
        Order__c ord = new Order__c();
        ord.Client__c = client.Id;
        ordList.add(ord);
        insert ordList;
        
        List<Order_Item__c> oiList = new List<Order_Item__c>();
        Order_Item__c oi = new Order_Item__c();
        oi.Order__c = ord.Id;
        oi.Application_No__c = 'US1233234';
        oi.Patent_No__c = 'US232434';
        oi.Fee_Currency__c = 'USD';
        oi.Billing_Currency__c = 'USD';
        oi.Fee__c = 100;
        oi.Claim_Fee__c = 10;
        oi.Surcharge__c = 10;
        oi.Fee_Unit_Rate__c = 2;
        oi.Billing_Currency_Unit_Rate__c = 2;
        oi.CE_Markup_Percentage__c = 20;
        oi.Credit_Memo__c = cm.Id;
        oi.CreditMemo_Amount__c = 100;
        oiList.add(oi);
        
        insert oiList;
        
        Test.startTest();
        
        PageReference pageRef = Page.vfCreateCreditMemo;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(oiList[0].Id));
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oiList);
        stdSetController.setSelected(oiList);
        CreditMemoDatatable ext = new CreditMemoDatatable(stdSetController);
        system.debug(oiList[0].id);
        ext.GetListViewURL();
        ext.GetSelectedAssetIds();
        ext.getAssets();
        
        Test.stopTest();
    }
        public static testmethod void Method2()
    {
        Clients__c client = new Clients__c();
        client.Name = 'Maxval@123';
        insert client;
        
        Credit_Memo__c cm = new Credit_Memo__c();
        cm.Client__c = client.Id;
        insert cm;
        
        List<Order__c> ordList = new List<Order__c>();
        Order__c ord = new Order__c();
        ord.Client__c = client.Id;
        ordList.add(ord);
        insert ordList;
        
        List<Order_Item__c> oiList = new List<Order_Item__c>();
        Order_Item__c oi = new Order_Item__c();
        oi.Order__c = ord.Id;
        oi.Application_No__c = 'US1233234';
        oi.Patent_No__c = 'US232434';
        oi.Fee_Currency__c = 'USD';
        oi.Billing_Currency__c = 'USD';
        oi.Fee__c = 100;
        oi.Claim_Fee__c = 10;
        oi.Surcharge__c = 10;
        oi.Fee_Unit_Rate__c = 2;
        oi.Billing_Currency_Unit_Rate__c = 2;
        oi.CE_Markup_Percentage__c = 20;
        oiList.add(oi);
        
        insert oiList;
        
        Test.startTest();
        
        PageReference pageRef = Page.vfCreateCreditMemo;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(oiList[0].Id));
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oiList);
        stdSetController.setSelected(oiList);
        CreditMemoDatatable ext = new CreditMemoDatatable(stdSetController);
        system.debug(oiList[0].id);
        ext.GetListViewURL();
        ext.GetSelectedAssetIds();
        ext.getAssets();
        
        Test.stopTest();
    }
    public static testmethod void Method3()
    {
        Clients__c client = new Clients__c();
        client.Name = 'Maxval@123';
        insert client;
        
        Credit_Memo__c cm = new Credit_Memo__c();
        cm.Client__c = client.Id;
        cm.API_Status__c = 'NotRequested';
        insert cm;
        
        List<Order__c> ordList = new List<Order__c>();
        Order__c ord = new Order__c();
        ord.Client__c = client.Id;
        ordList.add(ord);
        insert ordList;
        
        
        List<Order_Item__c> oiList = new List<Order_Item__c>();
        Order_Item__c oi = new Order_Item__c();
        oi.Order__c = ord.Id;
        oi.Application_No__c = 'US1233233';
        oi.Patent_No__c = 'US232433';
        oi.Fee_Currency__c = 'USD';
        oi.Billing_Currency__c = 'USD';
        oi.Fee__c = 100;
        oi.Claim_Fee__c = 10;
        oi.Surcharge__c = 10;
        oi.Fee_Unit_Rate__c = 2;
        oi.Billing_Currency_Unit_Rate__c = 2;
        oi.CE_Markup_Percentage__c = 20;
        oi.Credit_Memo__c = cm.Id;
        oi.CreditMemo_Amount__c = 100;
        oiList.add(oi);
        
        insert oiList;
        
        Test.startTest();
        
        PageReference pageRef = Page.vfCreateCreditMemo;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(oiList[0].Id));
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(oiList);
        stdSetController.setSelected(oiList);
        CreditMemoDatatable ext = new CreditMemoDatatable(stdSetController);
        system.debug(oiList[0].id);
        ext.GetListViewURL();
        ext.GetSelectedAssetIds();
        ext.getAssets();
        
        Test.stopTest();
	}
}