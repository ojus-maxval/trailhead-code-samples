public with sharing class OrderController
{
    private ApexPages.StandardSetController pgStandardSetController;
    public List<Order__c> SelectedOrderList{set;get;}
    public List<Id> SelectedOrderIds{set;get;}
    public string listviewURL{set;get;}
    public string Result {get;set;}
    public OrderController(ApexPages.StandardSetController pgStandardSetController) 
    {
        this.pgStandardSetController = pgStandardSetController;
        SelectedOrderList = new List<Order__c>();
        SelectedOrderIds = new List<Id>();
        SelectedOrderList = this.pgStandardSetController.getSelected();
        for(Order__c objOrder : SelectedOrderList)
        {
            SelectedOrderIds.add(objOrder.Id); 
        }
        listviewURL = '/lightning/o/Order__c/list?filterName=All';
        //Result = InvoiceController.GenerateInvoice(SelectedOrderIds);
        //GenerateInvoiceBatch objGenerateInvoiceBatch = new GenerateInvoiceBatch(SelectedOrderIds);
        //Database.executeBatch(objGenerateInvoiceBatch,1);
        GenerateInvoiceBatch objGenerateInvoiceBatch = new GenerateInvoiceBatch();
         ID batchprocessid = Database.executeBatch(objGenerateInvoiceBatch,1);
        Result = 'Generating Invoice is In progress - ' + batchprocessid ;
    }
}