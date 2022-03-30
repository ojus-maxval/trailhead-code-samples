@isTest
public class CreateInvoiceWithVarianceControllerTest {
    
    public static testmethod void Method1()
    {
        Clients__c client = new Clients__c();
        client.Name = 'Maxval@123';
        insert client;
        
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
        system.debug('Fee'+ oiList[0].Fee_Amount_When_Instruct__c);
        
        Test.startTest();
        
        PageReference pageRef = Page.vfCreateInvoiceWithVariance;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('Id', String.valueOf(ordList[0].Id));
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(ordList);
        stdSetController.setSelected(ordList);
        CreateInvoiceWithVarianceController ext = new CreateInvoiceWithVarianceController(stdSetController);
        system.debug(ordList[0].id);
        ext.GetListViewURL();
        ext.GetSelectedOrderIds();
        ext.getAssets();
        
        Test.stopTest();
    }
}